-- Student App — read endpoints.
--
-- Each function returns exactly the JSON shape of its contract DTO, so the
-- frontend validates it with the same zod schemas used by the mock.

-- Subject[] (§3.9, GET /subjects).
create function public.list_subjects()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_student_id integer := private.require_student_id();
begin
  return (
    select coalesce(
      jsonb_agg(
        jsonb_build_object(
          'id', s.id::text,
          'name', s.name,
          'shortLabel', s.short_label,
          'materialsCount', summary.materials_count,
          'questionsCount', summary.questions_count,
          'preparationPercent', coalesce(performance.preparation_percent, 0)
        )
        order by s.name
      ),
      '[]'::jsonb
    )
    from public.subjects s
    join private.v_subject_summary summary on summary.subject_id = s.id
    left join private.v_student_subject_performance performance
      on performance.subject_id = s.id and performance.student_id = v_student_id
  );
end;
$$;

-- SubjectDetail (§3.16, GET /subjects/:id). The counters and the preparation
-- come from the same views list_subjects reads, so the two endpoints can never
-- disagree about a subject.
create function public.get_subject(p_subject_id integer)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_student_id integer := private.require_student_id();
  v_subject jsonb;
begin
  select jsonb_build_object(
    'id', s.id::text,
    'name', s.name,
    'shortLabel', s.short_label,
    'materialsCount', summary.materials_count,
    'questionsCount', summary.questions_count,
    'preparationPercent', coalesce(performance.preparation_percent, 0),
    -- Assuntos by number, the label the student reads (§3.17); subassuntos, key
    -- points and materials by the study order the team defined, which for
    -- materials is the order they were inserted in.
    'topics', (
      select coalesce(
        jsonb_agg(
          jsonb_build_object(
            'id', t.id::text,
            'number', t.number,
            'name', t.name,
            'description', t.description,
            'subtopics', (
              select coalesce(
                jsonb_agg(
                  jsonb_build_object(
                    'id', st.id::text,
                    'name', st.name,
                    'summary', st.summary,
                    'keyPoints', (
                      select coalesce(jsonb_agg(kp.text order by kp.order_index), '[]'::jsonb)
                      from public.subtopic_key_points kp
                      where kp.subtopic_id = st.id
                    ),
                    'materials', (
                      select coalesce(
                        jsonb_agg(
                          jsonb_build_object(
                            'id', m.id::text,
                            'title', m.title,
                            'fileUrl', m.file_url
                          )
                          order by m.id
                        ),
                        '[]'::jsonb
                      )
                      from public.materials m
                      where m.subtopic_id = st.id
                    )
                  )
                  order by st.order_index
                ),
                '[]'::jsonb
              )
              from public.subtopics st
              where st.topic_id = t.id
            )
          )
          order by t.number
        ),
        '[]'::jsonb
      )
      from public.topics t
      where t.subject_id = s.id
    )
  )
  into v_subject
  from public.subjects s
  join private.v_subject_summary summary on summary.subject_id = s.id
  left join private.v_student_subject_performance performance
    on performance.subject_id = s.id and performance.student_id = v_student_id
  where s.id = p_subject_id;

  if v_subject is null then
    perform private.raise_api_error(404, 'NOT_FOUND', 'Disciplina não encontrada.');
  end if;

  return v_subject;
end;
$$;

-- DashboardData (§3.4, GET /dashboard). todayPlan is always empty: study plans
-- are not persisted yet (docs/05-melhorias-futuras.md, item 4).
create function public.get_dashboard()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_student_id integer := private.require_student_id();
  v_streak_days integer;
  v_exam_date date;
  v_exam_note text;
  v_exam_subject_id integer;
  v_exam_subject_name text;
  v_next_exam jsonb;
  v_subject_count integer;
  v_subject_names text;
  v_quiz_count integer;
begin
  select coalesce(
    (select st.streak_days from private.v_student_streak st where st.student_id = v_student_id),
    0
  ) into v_streak_days;

  select e.exam_date, e.note, s.id, s.name
  into v_exam_date, v_exam_note, v_exam_subject_id, v_exam_subject_name
  from public.scheduled_exams e
  join public.subjects s on s.id = e.subject_id
  where e.exam_date >= current_date
  order by e.exam_date, e.id
  limit 1;

  if v_exam_subject_id is null then
    v_next_exam := jsonb_build_object(
      'subjectName', 'Nenhuma prova agendada',
      'dateLabel', 'Sem data',
      'note', 'As prioridades aparecem quando houver uma prova',
      'overallPreparation', 0,
      'priorities', '[]'::jsonb
    );
  else
    v_next_exam := jsonb_build_object(
      'subjectName', v_exam_subject_name,
      'dateLabel',
        (array['Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado', 'Domingo'])[extract(isodow from v_exam_date)::integer]
        || ', ' || to_char(v_exam_date, 'DD/MM'),
      'note', v_exam_note,
      'overallPreparation', coalesce(
        (
          select performance.preparation_percent
          from private.v_student_subject_performance performance
          where performance.student_id = v_student_id and performance.subject_id = v_exam_subject_id
        ),
        0
      ),
      'priorities', coalesce(
        (
          select jsonb_agg(
            jsonb_build_object(
              'id', topic.id::text,
              'topicName', topic.name,
              'level', case
                when performance.percent < 50 then 'high'
                when performance.percent < 80 then 'medium'
                else 'low'
              end
            )
            order by performance.percent, topic.name
          )
          from private.v_student_topic_performance performance
          join public.topics topic on topic.id = performance.topic_id
          where performance.student_id = v_student_id
            and topic.subject_id = v_exam_subject_id
            and performance.percent is not null
        ),
        '[]'::jsonb
      )
    );
  end if;

  select count(*), string_agg(s.name, ', ' order by s.name)
  into v_subject_count, v_subject_names
  from public.subjects s;

  select count(*) into v_quiz_count
  from private.v_quiz_summary summary
  where summary.question_count > 0;

  return jsonb_build_object(
    'streakDays', v_streak_days,
    'nextExam', v_next_exam,
    'todayPlan', '[]'::jsonb,
    'summaryCards', jsonb_build_array(
      jsonb_build_object(
        'id', 'subjects',
        'title', 'Disciplinas',
        'value', v_subject_count || case when v_subject_count = 1 then ' matéria' else ' matérias' end,
        'description', coalesce(v_subject_names || '.', 'Nenhuma disciplina cadastrada.')
      ),
      jsonb_build_object(
        'id', 'quizzes',
        'title', 'Simulados',
        'value', v_quiz_count || case when v_quiz_count = 1 then ' disponível' else ' disponíveis' end,
        'description', 'Por disciplina ou integrados, quantas vezes você quiser.'
      ),
      jsonb_build_object(
        'id', 'ranking',
        'title', 'Ranking',
        'value', v_streak_days || case when v_streak_days = 1 then ' dia de sequência' else ' dias de sequência' end,
        'description', 'Baseado em consistência de estudo, não em nota.'
      )
    )
  );
end;
$$;

-- QuizSummary[] (§3.10, GET /quizzes). Quizzes without questions are left out.
create function public.list_quizzes()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_student_id integer := private.require_student_id();
begin
  return (
    select coalesce(jsonb_agg(quiz.item order by quiz.is_integrated desc, quiz.title), '[]'::jsonb)
    from (
      select
        z.subject_scope = 'all' as is_integrated,
        z.title,
        jsonb_strip_nulls(
          jsonb_build_object(
            'id', z.id::text,
            'title', z.title,
            'subjectScope', z.subject_scope,
            'subjectName', s.name,
            'questionCount', summary.question_count,
            'durationMinutes', z.duration_minutes,
            'attemptsCount', (
              select count(*)
              from public.quiz_attempts a
              where a.quiz_id = z.id and a.student_id = v_student_id
            ),
            'difficulty', z.difficulty
          )
        ) as item
      from public.quizzes z
      join private.v_quiz_summary summary on summary.quiz_id = z.id
      left join public.subjects s on s.id = z.subject_id
      where summary.question_count > 0
    ) quiz
  );
end;
$$;

-- QuizDetail (§3.11, GET /quizzes/:id).
create function public.get_quiz(p_quiz_id integer)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_quiz jsonb;
begin
  perform private.require_student_id();

  select jsonb_build_object(
    'id', z.id::text,
    'title', z.title,
    'durationMinutes', z.duration_minutes,
    'questions', (
      select jsonb_agg(private.question_json(qq.question_id) order by qq.order_index)
      from public.quiz_questions qq
      where qq.quiz_id = z.id
    )
  )
  into v_quiz
  from public.quizzes z
  where z.id = p_quiz_id
    and exists (select 1 from public.quiz_questions qq where qq.quiz_id = z.id);

  if v_quiz is null then
    perform private.raise_api_error(404, 'NOT_FOUND', 'Simulado não encontrado.');
  end if;

  return v_quiz;
end;
$$;

-- RankingData (§3.15, GET /ranking). Other students expose only an id and a streak,
-- never grades (docs/02-regras-de-negocio.md §11).
create function public.get_ranking()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_student_id integer := private.require_student_id();
begin
  return jsonb_build_object(
    'profile', (
      select jsonb_build_object(
        'streakDays', profile.streak_days,
        'weeklyGoalCompleted', profile.weekly_goal_completed,
        'weeklyGoalTarget', profile.weekly_goal_target,
        'questionsAnswered', profile.questions_answered,
        'quizzesCompleted', profile.quizzes_completed
      )
      from private.v_student_ranking_profile profile
      where profile.student_id = v_student_id
    ),
    'entries', coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'position', ranking.position,
            'studentId', ranking.student_id::text,
            'streakDays', ranking.streak_days,
            'isCurrentUser', ranking.student_id = v_student_id
          )
          order by ranking.position, ranking.student_id
        )
        from private.v_student_ranking ranking
      ),
      '[]'::jsonb
    )
  );
end;
$$;
