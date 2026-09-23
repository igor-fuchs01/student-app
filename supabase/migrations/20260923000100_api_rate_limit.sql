-- Student App — rate limiting and answer size validation for the API functions.
--
-- The hosted project is what runs in production, and supabase/config.toml does
-- not reach it: the [auth.rate_limit] block there only shapes the local stack,
-- and on the cloud those numbers live in the dashboard. Whatever protects the
-- endpoints has to be in the database, which is what ships through migrations.
-- That is what this migration adds.
--
-- Two holes are closed:
--
--   * no endpoint had any request limit. Auth rate limiting covers the login,
--     but once a student holds a token, every RPC answered as fast as it was
--     called — including submit_quiz_attempt, which writes rows;
--   * essay_blanks was the one answer type with no size check. essay is bounded
--     by questions.max_length, and every other type only accepts ids matched
--     against '^[0-9]{1,9}$', but a dissertative blank took text of any length
--     and stored it in quiz_attempt_answers.blank_answers.

-- =============================================================================
-- 1. The counter
-- =============================================================================

-- In private, like every other internal object: the Data API does not serve this
-- schema, and no client role has a privilege on this table, so a student can
-- neither read their own counter nor anyone else's.
create table private.api_rate_limit (
  student_id   integer not null references public.students (id) on delete cascade,
  endpoint     text not null,
  window_start timestamptz not null,
  call_count   integer not null default 1,
  constraint api_rate_limit_pkey primary key (student_id, endpoint, window_start)
);

comment on table private.api_rate_limit is 'Requests per student, endpoint and time bucket. Rows outside the current window are deleted on that student''s next call, so the table stays proportional to the students online, not to the traffic they made.';

-- Counts one call and refuses it when the bucket is already full.
--
-- Raising aborts the transaction, so the increment that crossed the limit rolls
-- back with it: the stored count settles at the limit and every further call in
-- the window is refused, which is the behaviour wanted. Only calls that go
-- through commit their increment.
create function private.enforce_rate_limit(
  p_student_id integer,
  p_endpoint text,
  p_limit integer,
  p_window_seconds integer
)
returns void
language plpgsql
volatile
set search_path = ''
as $$
declare
  v_window_start timestamptz := to_timestamp(
    floor(extract(epoch from now()) / p_window_seconds) * p_window_seconds
  );
  v_count integer;
begin
  delete from private.api_rate_limit
  where student_id = p_student_id and window_start < v_window_start;

  insert into private.api_rate_limit (student_id, endpoint, window_start)
  values (p_student_id, p_endpoint, v_window_start)
  on conflict on constraint api_rate_limit_pkey
    do update set call_count = private.api_rate_limit.call_count + 1
  returning call_count into v_count;

  if v_count > p_limit then
    perform private.raise_api_error(
      429,
      'RATE_LIMITED',
      'Muitas requisições em pouco tempo. Espere um instante e tente de novo.'
    );
  end if;
end;
$$;

-- =============================================================================
-- 2. The limit every endpoint gets
-- =============================================================================

-- require_student_id is the first statement of all eight endpoints, so the
-- budget goes here instead of being repeated in each one: one counter per
-- student for the whole API. 120 calls a minute is far above what the screens
-- ask for — opening the dashboard costs a handful — and far below what a loop
-- left running would.
--
-- It writes now, so it is volatile, and so is every function that calls it: a
-- stable function may not modify the database. The volatility of the endpoints
-- is changed below without redefining them.
create or replace function private.require_student_id()
returns integer
language plpgsql
volatile
set search_path = ''
as $$
declare
  v_student_id integer := private.current_student_id();
begin
  if v_student_id is null then
    perform private.raise_api_error(401, 'UNAUTHORIZED', 'Sessão expirada. Faça login novamente.');
  end if;

  perform private.enforce_rate_limit(v_student_id, 'api', 120, 60);

  return v_student_id;
end;
$$;

alter function public.get_current_student() volatile;
alter function public.get_dashboard() volatile;
alter function public.list_subjects() volatile;
alter function public.get_subject(integer) volatile;
alter function public.list_quizzes() volatile;
alter function public.get_quiz(integer) volatile;
alter function public.get_ranking() volatile;

-- =============================================================================
-- 3. submit_quiz_attempt: its own limit, and the size of a dissertative blank
-- =============================================================================
--
-- Replaced whole, because a migration cannot patch a function body. Two changes
-- against the baseline, both marked below with a comment:
--
--   * a second, stricter budget of its own. It is the only endpoint that writes,
--     so it is the one whose abuse costs storage. Six submissions a minute is
--     more than a student answering a simulado ever needs;
--   * a dissertative blank is refused past 2000 characters. The contract has no
--     per-blank limit to check against (Question of type essay_blanks carries
--     only id and referenceAnswer, §3.12), so this is a safety ceiling, not a
--     rule the student is meant to feel: a real answer to a blank is a word or a
--     sentence, three orders of magnitude below it.

create or replace function public.submit_quiz_attempt(p_quiz_id integer, p_answers jsonb)
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
  -- Added here: a budget of its own, charged after the shared one that
  -- require_student_id already counted. This is the only endpoint that writes.
  perform private.enforce_rate_limit(v_student_id, 'submit_quiz_attempt', 6, 60);

  if not exists (select 1 from public.quiz_questions qq where qq.quiz_id = p_quiz_id) then
    perform private.raise_api_error(404, 'NOT_FOUND', 'Simulado não encontrado.');
  end if;

  if p_answers is null or jsonb_typeof(p_answers) <> 'array' then
    perform private.reject_answers();
  end if;

  insert into public.quiz_attempts (quiz_id, student_id)
  values (p_quiz_id, v_student_id)
  returning id into v_attempt_id;

  for v_answer in select value from jsonb_array_elements(p_answers) loop
    if jsonb_typeof(v_answer) <> 'object' or coalesce(v_answer ->> 'questionId', '') !~ '^[0-9]{1,9}$' then
      perform private.reject_answers();
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
      perform private.reject_answers();
    end if;

    -- Stays null when the question was left blank or partially filled: no row, counted as unanswered.
    v_status := null;

    case v_question.type
      when 'multiple_choice' then
        if coalesce(v_answer ->> 'optionId', '') <> '' then
          if (v_answer ->> 'optionId') !~ '^[0-9]{1,9}$' then
            perform private.reject_answers();
          end if;
          v_option_id := (v_answer ->> 'optionId')::integer;

          if not exists (
            select 1 from public.question_options o
            where o.id = v_option_id and o.question_id = v_question_id
          ) then
            perform private.reject_answers();
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
            perform private.reject_answers();
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
            perform private.reject_answers();
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
            perform private.reject_answers();
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
            perform private.reject_answers();
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
            perform private.reject_answers();
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
            perform private.reject_answers();
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
            perform private.reject_answers();
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
          -- Added here: a blank longer than this is refused, like an essay past
          -- questions.max_length. Nothing in the contract bounded it before.
          if exists (
            select 1 from public.question_blanks b
            where b.question_id = v_question_id
              and length(v_answer -> 'blankAnswers' ->> b.blank_key) > 2000
          ) then
            perform private.reject_answers();
          end if;

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
