-- Student App — RPC functions that serve the read endpoints of docs/04-contratos-de-api.md.
--
-- Each function returns exactly the JSON shape of its contract DTO, so the
-- frontend validates it with the same zod schemas used by the mock.
--
-- Every client-facing function is SECURITY DEFINER with search_path = '' and
-- fully qualified names, identifies the student only through auth.uid() (never
-- through an argument), and is executable by the authenticated role only. The
-- helpers and views they build on live in the private schema, which the Data API
-- does not serve, so public holds nothing but the endpoints themselves.

-- =============================================================================
-- 1. Internal helpers (private schema)
-- =============================================================================

-- Raises an error that PostgREST turns into this HTTP status and a body in the
-- ApiErrorBody shape ({ code, message }), with a Portuguese message for the student.
create function private.raise_api_error(p_status integer, p_code text, p_message text)
returns void
language plpgsql
set search_path = ''
as $$
begin
  raise sqlstate 'PGRST' using
    message = json_build_object('code', p_code, 'message', p_message)::text,
    detail = json_build_object('status', p_status, 'headers', json_build_object())::text;
end;
$$;

-- private.current_student_id() plus the 401 the endpoints owe the client.
create function private.require_student_id()
returns integer
language plpgsql
stable
set search_path = ''
as $$
declare
  v_student_id integer := private.current_student_id();
begin
  if v_student_id is null then
    perform private.raise_api_error(401, 'UNAUTHORIZED', 'Sessão expirada. Faça login novamente.');
  end if;

  return v_student_id;
end;
$$;

-- Same rule as src/features/quizzes/normalizeAnswerText.ts.
create function private.normalize_answer_text(p_text text)
returns text
language sql
immutable
set search_path = ''
as $$
  select lower(regexp_replace(btrim(coalesce(p_text, '')), '\s+', ' ', 'g'))
$$;

-- Replaces each {{key}} of a template with its value; unknown keys become "___".
create function private.fill_template(p_template text, p_values jsonb)
returns text
language plpgsql
immutable
set search_path = ''
as $$
declare
  v_key text;
  v_value text;
  v_result text := p_template;
begin
  for v_key, v_value in select key, value from jsonb_each_text(coalesce(p_values, '{}'::jsonb)) loop
    v_result := replace(v_result, '{{' || v_key || '}}', v_value);
  end loop;
  return regexp_replace(v_result, '\{\{\w+\}\}', '___', 'g');
end;
$$;

-- QuizReviewItem.promptExcerpt, same rule as the mock server.
create function private.question_prompt_excerpt(
  p_type public.question_type,
  p_prompt text,
  p_template text
)
returns text
language sql
immutable
set search_path = ''
as $$
  select case
    when length(v.text) <= 90 then v.text
    else regexp_replace(left(v.text, 89), '\s+$', '') || '…'
  end
  from (
    select case
      when p_type in ('single_choice', 'drag_and_drop')
        then private.fill_template(p_template, null)
      when p_type = 'essay_blanks'
        then p_prompt || ' ' || private.fill_template(p_template, null)
      else p_prompt
    end as text
  ) v
$$;

-- Question (docs/04-contratos-de-api.md §3.12), in the shape of its type.
create function private.question_json(p_question_id integer)
returns jsonb
language sql
stable
set search_path = ''
as $$
  select
    jsonb_build_object('type', q.type, 'id', q.id::text, 'subjectName', s.name)
    || case q.type
      when 'multiple_choice' then jsonb_build_object(
        'prompt', q.prompt,
        'options', options.list,
        'correctOptionId', (
          select o.id::text
          from public.question_options o
          where o.question_id = q.id and o.is_correct
          order by o.order_index
          limit 1
        ),
        'explanation', q.explanation
      )
      when 'multiple_answer' then jsonb_build_object(
        'prompt', q.prompt,
        'options', options.list,
        'correctOptionIds', (
          select coalesce(jsonb_agg(o.id::text order by o.order_index), '[]'::jsonb)
          from public.question_options o
          where o.question_id = q.id and o.is_correct
        ),
        'explanation', q.explanation
      )
      when 'single_choice' then jsonb_build_object(
        'template', q.template,
        'blanks', (
          select jsonb_agg(
            jsonb_build_object(
              'id', b.blank_key,
              'options', (
                select jsonb_agg(jsonb_build_object('id', bo.id::text, 'text', bo.text) order by bo.order_index)
                from public.question_blank_options bo
                where bo.blank_id = b.id
              ),
              'correctOptionId', (
                select bo.id::text
                from public.question_blank_options bo
                where bo.blank_id = b.id and bo.is_correct
                order by bo.order_index
                limit 1
              )
            )
            order by b.order_index
          )
          from public.question_blanks b
          where b.question_id = q.id
        ),
        'explanation', q.explanation
      )
      when 'drag_and_drop' then jsonb_build_object(
        'template', q.template,
        'terms', (
          select jsonb_agg(jsonb_build_object('id', term.id::text, 'text', term.text) order by term.order_index)
          from public.question_terms term
          where term.question_id = q.id
        ),
        'slots', (
          select jsonb_agg(
            jsonb_build_object('id', slot.slot_key, 'correctTermId', slot.correct_term_id::text)
            order by slot.order_index
          )
          from public.question_slots slot
          where slot.question_id = q.id
        ),
        'explanation', q.explanation
      )
      when 'essay' then jsonb_build_object(
        'prompt', q.prompt,
        'maxLength', q.max_length,
        'referenceAnswer', q.reference_answer
      )
      when 'essay_blanks' then jsonb_build_object(
        'prompt', q.prompt,
        'template', q.template,
        'blanks', (
          select jsonb_agg(
            jsonb_build_object('id', b.blank_key, 'referenceAnswer', b.reference_answer)
            order by b.order_index
          )
          from public.question_blanks b
          where b.question_id = q.id
        )
      )
    end
  from public.questions q
  join public.topics topic on topic.id = q.topic_id
  join public.subjects s on s.id = topic.subject_id
  cross join lateral (
    select coalesce(
      jsonb_agg(jsonb_build_object('id', o.id::text, 'text', o.text) order by o.order_index),
      '[]'::jsonb
    ) as list
    from public.question_options o
    where o.question_id = q.id
  ) options
  where q.id = p_question_id
$$;

-- =============================================================================
-- 2. Read endpoints
-- =============================================================================

-- StudentUser (§3.1): the signed-in student, returned after login.
create function public.get_current_student()
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
    select jsonb_build_object(
      'id', s.id::text,
      'name', s.name,
      'email', s.email,
      'registrationId', s.registration_id,
      'course', s.course
    )
    from public.students s
    where s.id = v_student_id
  );
end;
$$;

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

-- RankingData (§3.15, GET /ranking). Other students expose only name and streak,
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
            'studentName', ranking.student_name,
            'streakDays', ranking.streak_days,
            'isCurrentUser', ranking.student_id = v_student_id
          )
          order by ranking.position, ranking.student_name
        )
        from private.v_student_ranking ranking
      ),
      '[]'::jsonb
    )
  );
end;
$$;

-- Written per schema, not as a list of names: public holds only the endpoints
-- above, so this stays right when one is added, renamed or given an argument.
revoke execute on all routines in schema public from public, anon;
grant execute on all routines in schema public to authenticated;
