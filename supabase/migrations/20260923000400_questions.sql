-- Student App — question bank (docs/04-contratos-de-api.md §3.12).

-- The subject is reached through topic_id; storing it here too would be a
-- transitive dependency (docs/06-modelagem-de-dados.md, section 2.2).
create table questions (
  id               integer generated always as identity primary key,
  topic_id         integer not null references topics (id) on delete restrict,
  type             question_type not null,
  prompt           text, -- multiple_choice, multiple_answer, essay, essay_blanks
  template         text, -- single_choice, drag_and_drop, essay_blanks ("{{id}}" placeholders)
  explanation      text, -- multiple_choice, multiple_answer, single_choice, drag_and_drop
  max_length       integer, -- essay
  reference_answer text,    -- essay

  constraint questions_statement_per_type_check check (
    (type in ('multiple_choice', 'multiple_answer', 'essay') and prompt is not null)
    or (type in ('single_choice', 'drag_and_drop') and template is not null)
    or (type = 'essay_blanks' and prompt is not null and template is not null)
  ),
  constraint questions_explanation_per_type_check check (
    (type in ('multiple_choice', 'multiple_answer', 'single_choice', 'drag_and_drop'))
    = (explanation is not null)
  ),
  -- Written with is not null on both sides: a check that evaluates to null passes.
  constraint questions_essay_fields_check check (
    case
      when type = 'essay'
        then max_length is not null and max_length > 0 and reference_answer is not null
      else max_length is null and reference_answer is null
    end
  )
);

comment on table questions is 'Question bank; one row per question, with the columns required by its type.';

create table question_options (
  id          integer generated always as identity primary key,
  question_id integer not null references questions (id) on delete cascade,
  text        text not null check (btrim(text) <> ''),
  is_correct  boolean not null default false,
  order_index integer not null,
  constraint question_options_question_id_order_index_key unique (question_id, order_index)
);

comment on table question_options is 'Options of multiple_choice and multiple_answer questions.';

create table question_blanks (
  id               integer generated always as identity primary key,
  question_id      integer not null references questions (id) on delete cascade,
  blank_key        text not null check (btrim(blank_key) <> ''),
  reference_answer text, -- essay_blanks
  order_index      integer not null,
  constraint question_blanks_question_id_blank_key_key unique (question_id, blank_key)
);

comment on table question_blanks is 'Blanks of single_choice (dropdown) and essay_blanks (free text) questions; blank_key matches a {{id}} in questions.template.';

create table question_blank_options (
  id          integer generated always as identity primary key,
  blank_id    integer not null references question_blanks (id) on delete cascade,
  text        text not null check (btrim(text) <> ''),
  is_correct  boolean not null default false,
  order_index integer not null,
  constraint question_blank_options_blank_id_order_index_key unique (blank_id, order_index)
);

comment on table question_blank_options is 'Dropdown options of a single_choice blank.';

create table question_terms (
  id          integer generated always as identity primary key,
  question_id integer not null references questions (id) on delete cascade,
  text        text not null check (btrim(text) <> ''),
  order_index integer not null,
  constraint question_terms_question_id_order_index_key unique (question_id, order_index)
);

comment on table question_terms is 'Draggable terms of a drag_and_drop question.';

create table question_slots (
  id              integer generated always as identity primary key,
  question_id     integer not null references questions (id) on delete cascade,
  slot_key        text not null check (btrim(slot_key) <> ''),
  correct_term_id integer not null references question_terms (id) on delete cascade,
  order_index     integer not null,
  constraint question_slots_question_id_slot_key_key unique (question_id, slot_key)
);

comment on table question_slots is 'Drop targets of a drag_and_drop question; slot_key matches a {{id}} in questions.template.';

create index idx_questions_topic_id on questions (topic_id);
create index idx_question_slots_correct_term_id on question_slots (correct_term_id);
