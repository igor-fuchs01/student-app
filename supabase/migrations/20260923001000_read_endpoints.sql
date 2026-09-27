-- Student App — read endpoints.
--
-- Each function returns exactly the JSON shape of its contract DTO, so the
-- frontend validates it with the same zod schemas used by the mock.

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

