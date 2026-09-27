-- Student App — internal helpers of the API functions (private schema).
--
-- Every client-facing function is security definer with search_path = '' and
-- fully qualified names. The read endpoints identify the student only through
-- auth.uid() and are executable by the authenticated role only; the submit
-- endpoint receives the Auth user id from the submit-quiz-attempt edge function,
-- which verified the JWT, and is executable by service_role only. The helpers
-- and views they build on live in the private schema, which the Data API does
-- not serve, so public holds nothing but the endpoints themselves.

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

-- The student of an Auth user, plus the 401 the endpoints owe the client.
--
-- The read endpoints call it without an argument, so the student is the one of
-- the request's JWT; the submit endpoint passes the Auth user id the edge
-- function verified.
create function private.require_student_id(p_auth_user_id uuid default auth.uid())
returns integer
language plpgsql
stable
set search_path = ''
as $$
declare
  v_student_id integer;
begin
  select s.id into v_student_id from public.students s where s.auth_user_id = p_auth_user_id;

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
