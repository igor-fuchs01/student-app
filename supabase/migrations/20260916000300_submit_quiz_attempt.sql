-- Student App — POST /quizzes/:id/attempts as an RPC function.
--
-- Grading happens here, never in the browser, with the rules of the mock server
-- (docs/04-contratos-de-api.md §5). Every id sent by the client is checked to be
-- numeric and to belong to this quiz and question before it is used, and the
-- student always comes from auth.uid(). Any invalid answer aborts the whole call,
-- so a rejected submission leaves no attempt behind.

create function public.submit_quiz_attempt(p_quiz_id integer, p_answers jsonb)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_student_id integer := private.require_student_id();
  v_attempt_id integer;
  v_answer jsonb;
  v_question public.questions%rowtype;
  v_question_id integer;
  v_option_id integer;
  v_selected integer[];
  v_expected integer[];
  v_values jsonb;
  v_status public.review_status;
begin
  if not exists (select 1 from public.quiz_questions qq where qq.quiz_id = p_quiz_id) then
    perform private.raise_api_error(404, 'NOT_FOUND', 'Simulado não encontrado.');
  end if;

  if p_answers is null or jsonb_typeof(p_answers) <> 'array' then
    perform private.raise_api_error(400, 'VALIDATION_ERROR', 'Respostas inválidas.');
  end if;

  insert into public.quiz_attempts (quiz_id, student_id)
  values (p_quiz_id, v_student_id)
  returning id into v_attempt_id;

  for v_answer in select value from jsonb_array_elements(p_answers) loop
    if jsonb_typeof(v_answer) <> 'object' or coalesce(v_answer ->> 'questionId', '') !~ '^[0-9]{1,9}$' then
      perform private.raise_api_error(400, 'VALIDATION_ERROR', 'Respostas inválidas.');
    end if;
    v_question_id := (v_answer ->> 'questionId')::integer;

    select q.* into v_question
    from public.questions q
    join public.quiz_questions qq on qq.question_id = q.id and qq.quiz_id = p_quiz_id
    where q.id = v_question_id;

    if not found or exists (
      select 1 from public.quiz_attempt_answers a
      where a.attempt_id = v_attempt_id and a.question_id = v_question_id
    ) then
      perform private.raise_api_error(400, 'VALIDATION_ERROR', 'Respostas inválidas.');
    end if;

    -- Stays null when the question was left blank or partially filled: no row, counted as unanswered.
    v_status := null;

    case v_question.type
      when 'multiple_choice' then
        if coalesce(v_answer ->> 'optionId', '') <> '' then
          if (v_answer ->> 'optionId') !~ '^[0-9]{1,9}$' then
            perform private.raise_api_error(400, 'VALIDATION_ERROR', 'Respostas inválidas.');
          end if;
          v_option_id := (v_answer ->> 'optionId')::integer;

          if not exists (
            select 1 from public.question_options o
            where o.id = v_option_id and o.question_id = v_question_id
          ) then
            perform private.raise_api_error(400, 'VALIDATION_ERROR', 'Respostas inválidas.');
          end if;

          v_status := case
            when exists (select 1 from public.question_options o where o.id = v_option_id and o.is_correct)
              then 'correct'
            else 'incorrect'
          end;

          insert into public.quiz_attempt_answers (attempt_id, question_id, selected_option_id, review_status)
          values (v_attempt_id, v_question_id, v_option_id, v_status);
        end if;

      when 'multiple_answer' then
        if jsonb_typeof(v_answer -> 'optionIds') = 'array' and jsonb_array_length(v_answer -> 'optionIds') > 0 then
          if exists (
            select 1 from jsonb_array_elements(v_answer -> 'optionIds') e
            where jsonb_typeof(e) <> 'string' or (e #>> '{}') !~ '^[0-9]{1,9}$'
          ) then
            perform private.raise_api_error(400, 'VALIDATION_ERROR', 'Respostas inválidas.');
          end if;

          select array_agg(distinct (e #>> '{}')::integer order by (e #>> '{}')::integer)
          into v_selected
          from jsonb_array_elements(v_answer -> 'optionIds') e;

          if exists (
            select 1 from unnest(v_selected) selected(id)
            where not exists (
              select 1 from public.question_options o
              where o.id = selected.id and o.question_id = v_question_id
            )
          ) then
            perform private.raise_api_error(400, 'VALIDATION_ERROR', 'Respostas inválidas.');
          end if;

          select coalesce(array_agg(o.id order by o.id), '{}')
          into v_expected
          from public.question_options o
          where o.question_id = v_question_id and o.is_correct;

          v_status := case when v_selected = v_expected then 'correct' else 'incorrect' end;

          insert into public.quiz_attempt_answers (attempt_id, question_id, selected_option_ids, review_status)
          values (v_attempt_id, v_question_id, to_jsonb(v_selected), v_status);
        end if;

      when 'single_choice' then
        if jsonb_typeof(v_answer -> 'blankAnswers') = 'object' and not exists (
          select 1 from public.question_blanks b
          where b.question_id = v_question_id
            and coalesce(v_answer -> 'blankAnswers' ->> b.blank_key, '') = ''
        ) then
          if exists (
            select 1 from public.question_blanks b
            where b.question_id = v_question_id
              and (v_answer -> 'blankAnswers' ->> b.blank_key) !~ '^[0-9]{1,9}$'
          ) then
            perform private.raise_api_error(400, 'VALIDATION_ERROR', 'Respostas inválidas.');
          end if;

          if exists (
            select 1 from public.question_blanks b
            where b.question_id = v_question_id
              and not exists (
                select 1 from public.question_blank_options bo
                where bo.blank_id = b.id
                  and bo.id = (v_answer -> 'blankAnswers' ->> b.blank_key)::integer
              )
          ) then
            perform private.raise_api_error(400, 'VALIDATION_ERROR', 'Respostas inválidas.');
          end if;

          v_status := case
            when not exists (
              select 1 from public.question_blanks b
              where b.question_id = v_question_id
                and not exists (
                  select 1 from public.question_blank_options bo
                  where bo.blank_id = b.id
                    and bo.is_correct
                    and bo.id = (v_answer -> 'blankAnswers' ->> b.blank_key)::integer
                )
            ) then 'correct'
            else 'incorrect'
          end;

          -- Only the question's own blanks are stored, whatever else the client sent.
          select jsonb_object_agg(b.blank_key, v_answer -> 'blankAnswers' ->> b.blank_key)
          into v_values
          from public.question_blanks b
          where b.question_id = v_question_id;

          insert into public.quiz_attempt_answers (attempt_id, question_id, blank_answers, review_status)
          values (v_attempt_id, v_question_id, v_values, v_status);
        end if;

      when 'drag_and_drop' then
        if jsonb_typeof(v_answer -> 'slotAnswers') = 'object' and not exists (
          select 1 from public.question_slots slot
          where slot.question_id = v_question_id
            and coalesce(v_answer -> 'slotAnswers' ->> slot.slot_key, '') = ''
        ) then
          if exists (
            select 1 from public.question_slots slot
            where slot.question_id = v_question_id
              and (v_answer -> 'slotAnswers' ->> slot.slot_key) !~ '^[0-9]{1,9}$'
          ) then
            perform private.raise_api_error(400, 'VALIDATION_ERROR', 'Respostas inválidas.');
          end if;

          if exists (
            select 1 from public.question_slots slot
            where slot.question_id = v_question_id
              and not exists (
                select 1 from public.question_terms term
                where term.question_id = v_question_id
                  and term.id = (v_answer -> 'slotAnswers' ->> slot.slot_key)::integer
              )
          ) then
            perform private.raise_api_error(400, 'VALIDATION_ERROR', 'Respostas inválidas.');
          end if;

          v_status := case
            when not exists (
              select 1 from public.question_slots slot
              where slot.question_id = v_question_id
                and slot.correct_term_id <> (v_answer -> 'slotAnswers' ->> slot.slot_key)::integer
            ) then 'correct'
            else 'incorrect'
          end;

          select jsonb_object_agg(slot.slot_key, v_answer -> 'slotAnswers' ->> slot.slot_key)
          into v_values
          from public.question_slots slot
          where slot.question_id = v_question_id;

          insert into public.quiz_attempt_answers (attempt_id, question_id, slot_answers, review_status)
          values (v_attempt_id, v_question_id, v_values, v_status);
        end if;

      when 'essay' then
        if btrim(coalesce(v_answer ->> 'text', '')) <> '' then
          if length(v_answer ->> 'text') > v_question.max_length then
            perform private.raise_api_error(400, 'VALIDATION_ERROR', 'Respostas inválidas.');
          end if;

          v_status := case
            when private.normalize_answer_text(v_answer ->> 'text')
              = private.normalize_answer_text(v_question.reference_answer)
              then 'correct'
            else 'pending_review'
          end;

          insert into public.quiz_attempt_answers (attempt_id, question_id, essay_text, review_status)
          values (v_attempt_id, v_question_id, v_answer ->> 'text', v_status);
        end if;

      when 'essay_blanks' then
        if jsonb_typeof(v_answer -> 'blankAnswers') = 'object' and not exists (
          select 1 from public.question_blanks b
          where b.question_id = v_question_id
            and btrim(coalesce(v_answer -> 'blankAnswers' ->> b.blank_key, '')) = ''
        ) then
          v_status := case
            when not exists (
              select 1 from public.question_blanks b
              where b.question_id = v_question_id
                and private.normalize_answer_text(v_answer -> 'blankAnswers' ->> b.blank_key)
                  <> private.normalize_answer_text(b.reference_answer)
            ) then 'correct'
            else 'pending_review'
          end;

          select jsonb_object_agg(b.blank_key, v_answer -> 'blankAnswers' ->> b.blank_key)
          into v_values
          from public.question_blanks b
          where b.question_id = v_question_id;

          insert into public.quiz_attempt_answers (attempt_id, question_id, blank_answers, review_status)
          values (v_attempt_id, v_question_id, v_values, v_status);
        end if;
    end case;
  end loop;

  insert into public.student_activity_days (student_id, activity_date)
  values (v_student_id, current_date)
  on conflict do nothing;

  -- QuizResult (§3.14).
  return (
    select jsonb_build_object(
      'quizId', result.quiz_id::text,
      'submittedAt', result.submitted_at,
      'correctCount', result.correct_count,
      'incorrectCount', result.incorrect_count,
      'unansweredCount', result.unanswered_count,
      'selfReviewCount', result.self_review_count,
      'scorePercent', coalesce(result.score_percent, 0),
      'subjectPerformance', coalesce(
        (
          select jsonb_agg(
            jsonb_build_object('subjectName', s.name, 'percent', performance.percent)
            order by s.name
          )
          from private.v_quiz_attempt_subject_performance performance
          join public.subjects s on s.id = performance.subject_id
          where performance.attempt_id = v_attempt_id and performance.percent is not null
        ),
        '[]'::jsonb
      ),
      'reviewItems', coalesce(
        (
          select jsonb_agg(review.item order by review.order_index)
          from (
            select
              qq.order_index,
              jsonb_strip_nulls(
                jsonb_build_object(
                  'questionId', q.id::text,
                  'subjectName', s.name,
                  'promptExcerpt', private.question_prompt_excerpt(q.type, q.prompt, q.template),
                  'status', case a.review_status when 'incorrect' then 'incorrect' else 'self_review' end,
                  'explanation', case when a.review_status = 'incorrect' then q.explanation end,
                  'studentAnswer', case
                    when a.review_status = 'pending_review' and q.type = 'essay' then btrim(a.essay_text)
                    when a.review_status = 'pending_review' then private.fill_template(q.template, a.blank_answers)
                  end,
                  'referenceAnswer', case
                    when a.review_status = 'pending_review' and q.type = 'essay' then q.reference_answer
                    when a.review_status = 'pending_review' then private.fill_template(
                      q.template,
                      (
                        select jsonb_object_agg(b.blank_key, b.reference_answer)
                        from public.question_blanks b
                        where b.question_id = q.id
                      )
                    )
                  end
                )
              ) as item
            from public.quiz_attempt_answers a
            join public.questions q on q.id = a.question_id
            join public.topics topic on topic.id = q.topic_id
            join public.subjects s on s.id = topic.subject_id
            join public.quiz_questions qq on qq.question_id = q.id and qq.quiz_id = p_quiz_id
            where a.attempt_id = v_attempt_id
              and a.review_status in ('incorrect', 'pending_review')
          ) review
        ),
        '[]'::jsonb
      )
    )
    from private.v_quiz_attempt_result result
    where result.attempt_id = v_attempt_id
  );
end;
$$;

-- Per schema, as in the previous migration: public holds only the endpoints.
revoke execute on all routines in schema public from public, anon;
grant execute on all routines in schema public to authenticated;
