-- Student App — imports one quiz (simulado) described in JSON straight into the
-- database. It is an operator tool, not part of the API: the app never calls it
-- and it leaves nothing behind that the Data API could reach.
--
-- How to use it: replace the JSON between the $json$ markers below with the
-- quiz to import, then run this whole file — in the Supabase Studio SQL editor
-- (http://127.0.0.1:54323 locally), or with psql:
--
--   psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" \
--     -f supabase/scripts/import-quiz.sql
--
-- The JSON format is documented in docs/07-importacao-de-simulados.md.
--
-- How it works:
--   * everything runs inside one transaction: the whole payload is validated
--     first and, when anything is wrong, every problem is reported at once and
--     no row is written;
--   * subjects and topics are never created here. A question naming one that
--     does not exist is an error, so a typo cannot silently create a duplicate
--     subject beside the real one;
--   * questions are always new rows; the bank is never searched for an
--     equivalent question to reuse;
--   * the validation helpers are created in pg_temp, so they vanish with the
--     session instead of becoming permanent surface in the database, and they
--     are replaced on every run, because the SQL editor reuses its connection;
--   * messages are in English, like the rest of the code: this is developer
--     tooling, not something a student ever reads.

BEGIN;

-- =============================================================================
-- The quiz to import — this is the only part meant to be edited.
--
-- $json$ quoting keeps the JSON exactly as it is: no escaping, not even for the
-- single quotes of words like "d'água".
-- =============================================================================

CREATE TEMP TABLE quiz_import_payload ON COMMIT DROP AS
SELECT $json$
{
  "title": "Banco de Dados — Simulado 2",
  "subjectScope": "single",
  "subject": "Banco de Dados",
  "durationMinutes": 20,
  "difficulty": "medium",
  "questions": [
    {
      "type": "multiple_choice",
      "topic": "Modelagem ER",
      "prompt": "O que a cardinalidade de um relacionamento indica?",
      "explanation": "A cardinalidade diz quantas ocorrências de uma entidade podem se relacionar com ocorrências da outra.",
      "options": [
        { "text": "Quantas ocorrências de uma entidade se ligam a ocorrências da outra", "isCorrect": true },
        { "text": "Quantos atributos a entidade possui", "isCorrect": false },
        { "text": "Quantas tabelas o banco terá no final", "isCorrect": false }
      ]
    },
    {
      "type": "multiple_answer",
      "topic": "Modelagem ER",
      "prompt": "Quais itens fazem parte de um modelo entidade-relacionamento?",
      "explanation": "Entidades, atributos e relacionamentos compõem o MER; índices são decisão do modelo físico.",
      "options": [
        { "text": "Entidades", "isCorrect": true },
        { "text": "Atributos", "isCorrect": true },
        { "text": "Índices de performance", "isCorrect": false }
      ]
    },
    {
      "type": "single_choice",
      "topic": "Normalização",
      "template": "A forma normal que elimina dependências parciais é a {{b1}}.",
      "explanation": "A 2FN elimina dependências parciais em relação à chave primária composta.",
      "blanks": [
        {
          "key": "b1",
          "options": [
            { "text": "2FN", "isCorrect": true },
            { "text": "1FN", "isCorrect": false },
            { "text": "3FN", "isCorrect": false }
          ]
        }
      ]
    },
    {
      "type": "drag_and_drop",
      "topic": "Normalização",
      "template": "Valores atômicos são exigidos pela {{s1}}, e dependências transitivas são eliminadas pela {{s2}}.",
      "explanation": "A 1FN exige valores atômicos; a 3FN elimina dependências transitivas.",
      "terms": ["1FN", "2FN", "3FN"],
      "slots": [
        { "key": "s1", "correctTerm": "1FN" },
        { "key": "s2", "correctTerm": "3FN" }
      ]
    },
    {
      "type": "essay",
      "topic": "Modelagem ER",
      "prompt": "Explique, em poucas linhas, a diferença entre chave primária e chave estrangeira.",
      "maxLength": 400,
      "referenceAnswer": "A chave primária identifica cada linha da própria tabela; a chave estrangeira aponta para a chave primária de outra tabela e garante a integridade referencial."
    },
    {
      "type": "essay_blanks",
      "topic": "Normalização",
      "prompt": "Complete a definição.",
      "template": "Uma tabela está na {{b1}} quando todos os seus atributos contêm apenas valores {{b2}}.",
      "blanks": [
        { "key": "b1", "referenceAnswer": "primeira forma normal" },
        { "key": "b2", "referenceAnswer": "atômicos" }
      ]
    }
  ]
}
$json$::jsonb AS doc;

-- =============================================================================
-- Validation helpers
-- =============================================================================

-- Problems are collected instead of raised one at a time, so a single run
-- reports everything that is wrong with the payload.
CREATE OR REPLACE FUNCTION pg_temp.text_errors(p_object jsonb, p_key text, p_where text)
RETURNS text[]
LANGUAGE sql
IMMUTABLE
AS $fn$
  SELECT CASE
    WHEN jsonb_typeof(p_object -> p_key) = 'string' AND btrim(p_object ->> p_key) <> ''
      THEN '{}'::text[]
    ELSE ARRAY[format('%s: "%s" must be a non-empty string', p_where, p_key)]
  END
$fn$;

-- p_max_correct NULL means "no upper bound" (multiple_answer).
CREATE OR REPLACE FUNCTION pg_temp.option_errors(p_options jsonb, p_where text, p_min_correct integer, p_max_correct integer)
RETURNS text[]
LANGUAGE sql
IMMUTABLE
AS $fn$
  SELECT CASE
    WHEN jsonb_typeof(p_options) IS DISTINCT FROM 'array' OR jsonb_array_length(p_options) < 2
      THEN ARRAY[format('%s: "options" must be an array with at least 2 options', p_where)]
    ELSE COALESCE((
      SELECT array_agg(message)
      FROM (
        SELECT format('%s: option %s needs a non-empty "text"', p_where, o.ord) AS message
        FROM jsonb_array_elements(p_options) WITH ORDINALITY AS o(value, ord)
        WHERE jsonb_typeof(o.value -> 'text') IS DISTINCT FROM 'string'
           OR btrim(o.value ->> 'text') = ''
        UNION ALL
        SELECT format('%s: option %s needs "isCorrect" set to true or false', p_where, o.ord)
        FROM jsonb_array_elements(p_options) WITH ORDINALITY AS o(value, ord)
        WHERE jsonb_typeof(o.value -> 'isCorrect') IS DISTINCT FROM 'boolean'
        UNION ALL
        SELECT format(
          '%s: expected %s correct option(s), found %s',
          p_where,
          CASE
            WHEN p_max_correct IS NULL THEN format('at least %s', p_min_correct)
            WHEN p_min_correct = p_max_correct THEN p_min_correct::text
            ELSE format('%s to %s', p_min_correct, p_max_correct)
          END,
          counted.correct_count
        )
        FROM (
          SELECT count(*) FILTER (WHERE o.value -> 'isCorrect' = 'true'::jsonb) AS correct_count
          FROM jsonb_array_elements(p_options) AS o(value)
        ) AS counted
        WHERE counted.correct_count < p_min_correct
           OR (p_max_correct IS NOT NULL AND counted.correct_count > p_max_correct)
      ) AS found
    ), '{}')
  END
$fn$;

-- Blanks and slots are both arrays of objects identified by a unique "key",
-- which becomes question_blanks.blank_key / question_slots.slot_key.
CREATE OR REPLACE FUNCTION pg_temp.entry_errors(p_entries jsonb, p_where text, p_label text)
RETURNS text[]
LANGUAGE sql
IMMUTABLE
AS $fn$
  SELECT CASE
    WHEN jsonb_typeof(p_entries) IS DISTINCT FROM 'array' OR jsonb_array_length(p_entries) = 0
      THEN ARRAY[format('%s: "%s" must be a non-empty array', p_where, p_label)]
    ELSE COALESCE((
      SELECT array_agg(message)
      FROM (
        SELECT format('%s: %s %s needs a non-empty "key"', p_where, p_label, e.ord) AS message
        FROM jsonb_array_elements(p_entries) WITH ORDINALITY AS e(value, ord)
        WHERE jsonb_typeof(e.value -> 'key') IS DISTINCT FROM 'string'
           OR btrim(e.value ->> 'key') = ''
        UNION ALL
        SELECT format('%s: "%s" repeats the key %L', p_where, p_label, e.value ->> 'key')
        FROM jsonb_array_elements(p_entries) AS e(value)
        WHERE jsonb_typeof(e.value -> 'key') = 'string'
        GROUP BY e.value ->> 'key'
        HAVING count(*) > 1
      ) AS found
    ), '{}')
  END
$fn$;

-- The {{key}} placeholders of a template and the keys the question declares must
-- match one to one, or the student would see a blank nothing answers.
CREATE OR REPLACE FUNCTION pg_temp.placeholder_errors(p_template text, p_keys text[], p_where text, p_label text)
RETURNS text[]
LANGUAGE sql
IMMUTABLE
AS $fn$
  WITH declared AS (
    SELECT unnest(p_keys) AS key
  ),
  used AS (
    SELECT DISTINCT m[1] AS key
    FROM regexp_matches(COALESCE(p_template, ''), '\{\{([^{}]+)\}\}', 'g') AS m
  )
  SELECT COALESCE((
    SELECT array_agg(message)
    FROM (
      SELECT format('%s: the template has no {{%s}} placeholder for this %s', p_where, d.key, p_label) AS message
      FROM declared d
      WHERE NOT EXISTS (SELECT 1 FROM used u WHERE u.key = d.key)
      UNION ALL
      SELECT format('%s: the template has a {{%s}} placeholder with no matching %s', p_where, u.key, p_label)
      FROM used u
      WHERE NOT EXISTS (SELECT 1 FROM declared d WHERE d.key = u.key)
    ) AS found
  ), '{}')
$fn$;

-- =============================================================================
-- Validation and insertion
-- =============================================================================

DO $do$
DECLARE
  payload        jsonb;
  problems       text[] := '{}';
  entry_problems text[];
  question       jsonb;
  entry          jsonb;
  idx            bigint;
  entry_idx      bigint;
  quiz_title     text;
  quiz_scope     text;
  quiz_subject   text;
  subject_name   text;
  q_type         text;
  q_where        text;
  entry_keys     text[];
  term_texts     text[];
  v_subject_id   integer;
  v_topic_id     integer;
  v_quiz_id      integer;
  v_question_id  integer;
  v_blank_id     integer;
BEGIN
  SELECT doc INTO payload FROM quiz_import_payload;

  IF jsonb_typeof(payload) IS DISTINCT FROM 'object' THEN
    RAISE EXCEPTION 'the payload must be a JSON object describing one quiz';
  END IF;

  -- ===========================================================================
  -- 1. Validation — the quiz
  -- ===========================================================================

  problems := problems || pg_temp.text_errors(payload, 'title', 'quiz');
  quiz_title := btrim(COALESCE(payload ->> 'title', ''));
  quiz_scope := payload ->> 'subjectScope';
  quiz_subject := payload ->> 'subject';

  IF quiz_title <> '' AND EXISTS (SELECT 1 FROM quizzes WHERE title = quiz_title) THEN
    problems := problems || format('quiz: a quiz titled %L already exists', quiz_title);
  END IF;

  IF quiz_scope IS DISTINCT FROM 'single' AND quiz_scope IS DISTINCT FROM 'all' THEN
    problems := problems || 'quiz: "subjectScope" must be "single" or "all"';
  ELSIF quiz_scope = 'single' THEN
    IF quiz_subject IS NULL OR btrim(quiz_subject) = '' THEN
      problems := problems || 'quiz: "subject" is required when "subjectScope" is "single"';
    ELSE
      SELECT id INTO v_subject_id FROM subjects WHERE name = quiz_subject;
      IF NOT FOUND THEN
        problems := problems || format('quiz: subject %L was not found', quiz_subject);
      END IF;
    END IF;
  ELSIF quiz_subject IS NOT NULL THEN
    problems := problems || 'quiz: "subject" must be omitted when "subjectScope" is "all"';
  END IF;

  IF payload ->> 'difficulty' IS NULL
     OR payload ->> 'difficulty' NOT IN ('easy', 'medium', 'hard') THEN
    problems := problems || 'quiz: "difficulty" must be "easy", "medium" or "hard"';
  END IF;

  IF jsonb_typeof(payload -> 'durationMinutes') IS DISTINCT FROM 'number' THEN
    problems := problems || 'quiz: "durationMinutes" must be a positive whole number';
  ELSIF (payload ->> 'durationMinutes')::numeric <= 0
     OR (payload ->> 'durationMinutes')::numeric % 1 <> 0 THEN
    problems := problems || 'quiz: "durationMinutes" must be a positive whole number';
  END IF;

  IF jsonb_typeof(payload -> 'questions') IS DISTINCT FROM 'array' THEN
    problems := problems || 'quiz: "questions" must be an array';
  ELSIF jsonb_array_length(payload -> 'questions') = 0 THEN
    problems := problems || 'quiz: "questions" must have at least one question';
  END IF;

  -- ===========================================================================
  -- 2. Validation — the questions
  -- ===========================================================================

  FOR idx, question IN
    SELECT q.ord, q.value
    FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(payload -> 'questions') = 'array'
           THEN payload -> 'questions'
           ELSE '[]'::jsonb END
    ) WITH ORDINALITY AS q(value, ord)
  LOOP
    q_where := format('question %s', idx);
    q_type := question ->> 'type';
    -- Outside a single-subject quiz each question says which subject it belongs
    -- to, because topic names are unique per subject, not globally.
    subject_name := COALESCE(question ->> 'subject', quiz_subject);

    IF q_type IS NULL
       OR q_type NOT IN ('multiple_choice', 'multiple_answer', 'single_choice',
                         'drag_and_drop', 'essay', 'essay_blanks') THEN
      problems := problems || format(
        '%s: "type" must be one of multiple_choice, multiple_answer, single_choice, drag_and_drop, essay, essay_blanks',
        q_where
      );
      CONTINUE;
    END IF;

    IF jsonb_typeof(question -> 'topic') IS DISTINCT FROM 'string'
       OR btrim(question ->> 'topic') = '' THEN
      problems := problems || format('%s: "topic" must be a non-empty string', q_where);
    ELSIF subject_name IS NULL OR btrim(subject_name) = '' THEN
      problems := problems || format('%s: "subject" is required because the quiz covers every subject', q_where);
    ELSE
      PERFORM 1
      FROM topics t
      JOIN subjects s ON s.id = t.subject_id
      WHERE s.name = subject_name AND t.name = question ->> 'topic';

      IF NOT FOUND THEN
        problems := problems || format('%s: topic %L of subject %L was not found', q_where, question ->> 'topic', subject_name);
      END IF;
    END IF;

    CASE q_type
      WHEN 'multiple_choice' THEN
        problems := problems
          || pg_temp.text_errors(question, 'prompt', q_where)
          || pg_temp.text_errors(question, 'explanation', q_where)
          || pg_temp.option_errors(question -> 'options', q_where, 1, 1);

      WHEN 'multiple_answer' THEN
        problems := problems
          || pg_temp.text_errors(question, 'prompt', q_where)
          || pg_temp.text_errors(question, 'explanation', q_where)
          || pg_temp.option_errors(question -> 'options', q_where, 1, NULL);

      WHEN 'single_choice' THEN
        entry_problems := pg_temp.entry_errors(question -> 'blanks', q_where, 'blanks');
        problems := problems
          || pg_temp.text_errors(question, 'template', q_where)
          || pg_temp.text_errors(question, 'explanation', q_where)
          || entry_problems;

        IF cardinality(entry_problems) = 0 THEN
          SELECT array_agg(b.value ->> 'key' ORDER BY b.ord) INTO entry_keys
          FROM jsonb_array_elements(question -> 'blanks') WITH ORDINALITY AS b(value, ord);

          problems := problems
            || pg_temp.placeholder_errors(question ->> 'template', entry_keys, q_where, 'blank');

          FOR entry IN SELECT b.value FROM jsonb_array_elements(question -> 'blanks') AS b(value)
          LOOP
            problems := problems || pg_temp.option_errors(
              entry -> 'options',
              format('%s, blank %L', q_where, entry ->> 'key'),
              1, 1
            );
          END LOOP;
        END IF;

      WHEN 'drag_and_drop' THEN
        entry_problems := pg_temp.entry_errors(question -> 'slots', q_where, 'slots');
        problems := problems
          || pg_temp.text_errors(question, 'template', q_where)
          || pg_temp.text_errors(question, 'explanation', q_where)
          || entry_problems;

        term_texts := '{}';

        IF jsonb_typeof(question -> 'terms') IS DISTINCT FROM 'array'
           OR jsonb_array_length(question -> 'terms') < 2 THEN
          problems := problems || format('%s: "terms" must be an array with at least 2 terms', q_where);
        ELSIF EXISTS (
          SELECT 1
          FROM jsonb_array_elements(question -> 'terms') AS t(value)
          WHERE jsonb_typeof(t.value) IS DISTINCT FROM 'string' OR btrim(t.value #>> '{}') = ''
        ) THEN
          problems := problems || format('%s: every term must be a non-empty string', q_where);
        ELSE
          SELECT array_agg(t.value #>> '{}' ORDER BY t.ord) INTO term_texts
          FROM jsonb_array_elements(question -> 'terms') WITH ORDINALITY AS t(value, ord);

          -- The slots point at a term by its text, so two identical terms would
          -- be ambiguous.
          IF cardinality(term_texts) <> (SELECT count(DISTINCT x) FROM unnest(term_texts) AS x) THEN
            problems := problems || format('%s: "terms" repeats a term; each term must be unique', q_where);
          END IF;
        END IF;

        IF cardinality(entry_problems) = 0 THEN
          SELECT array_agg(s.value ->> 'key' ORDER BY s.ord) INTO entry_keys
          FROM jsonb_array_elements(question -> 'slots') WITH ORDINALITY AS s(value, ord);

          problems := problems
            || pg_temp.placeholder_errors(question ->> 'template', entry_keys, q_where, 'slot');

          IF cardinality(term_texts) > 0 THEN
            FOR entry IN SELECT s.value FROM jsonb_array_elements(question -> 'slots') AS s(value)
            LOOP
              IF jsonb_typeof(entry -> 'correctTerm') IS DISTINCT FROM 'string'
                 OR NOT ((entry ->> 'correctTerm') = ANY (term_texts)) THEN
                problems := problems || format('%s: slot %L needs a "correctTerm" listed in "terms"', q_where, entry ->> 'key');
              END IF;
            END LOOP;
          END IF;
        END IF;

      WHEN 'essay' THEN
        problems := problems
          || pg_temp.text_errors(question, 'prompt', q_where)
          || pg_temp.text_errors(question, 'referenceAnswer', q_where);

        IF jsonb_typeof(question -> 'maxLength') IS DISTINCT FROM 'number' THEN
          problems := problems || format('%s: "maxLength" must be a positive whole number', q_where);
        ELSIF (question ->> 'maxLength')::numeric <= 0
           OR (question ->> 'maxLength')::numeric % 1 <> 0 THEN
          problems := problems || format('%s: "maxLength" must be a positive whole number', q_where);
        END IF;

      WHEN 'essay_blanks' THEN
        entry_problems := pg_temp.entry_errors(question -> 'blanks', q_where, 'blanks');
        problems := problems
          || pg_temp.text_errors(question, 'prompt', q_where)
          || pg_temp.text_errors(question, 'template', q_where)
          || entry_problems;

        IF cardinality(entry_problems) = 0 THEN
          SELECT array_agg(b.value ->> 'key' ORDER BY b.ord) INTO entry_keys
          FROM jsonb_array_elements(question -> 'blanks') WITH ORDINALITY AS b(value, ord);

          problems := problems
            || pg_temp.placeholder_errors(question ->> 'template', entry_keys, q_where, 'blank');

          FOR entry IN SELECT b.value FROM jsonb_array_elements(question -> 'blanks') AS b(value)
          LOOP
            problems := problems || pg_temp.text_errors(
              entry, 'referenceAnswer', format('%s, blank %L', q_where, entry ->> 'key')
            );
          END LOOP;
        END IF;
    END CASE;
  END LOOP;

  IF cardinality(problems) > 0 THEN
    RAISE EXCEPTION E'the quiz JSON is invalid:\n  %', array_to_string(problems, E'\n  ');
  END IF;

  -- ===========================================================================
  -- 3. Insert
  -- ===========================================================================

  INSERT INTO quizzes (title, subject_scope, subject_id, duration_minutes, difficulty)
  VALUES (
    quiz_title,
    quiz_scope::quiz_subject_scope,
    CASE WHEN quiz_scope = 'single' THEN v_subject_id END,
    (payload ->> 'durationMinutes')::integer,
    (payload ->> 'difficulty')::difficulty_level
  )
  RETURNING id INTO v_quiz_id;

  FOR idx, question IN
    SELECT q.ord, q.value
    FROM jsonb_array_elements(payload -> 'questions') WITH ORDINALITY AS q(value, ord)
  LOOP
    q_type := question ->> 'type';
    subject_name := COALESCE(question ->> 'subject', quiz_subject);

    SELECT t.id INTO STRICT v_topic_id
    FROM topics t
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = subject_name AND t.name = question ->> 'topic';

    -- Only the columns the type uses are filled; the CHECK constraints in
    -- 20260916000000_initial_schema.sql reject anything else.
    INSERT INTO questions (topic_id, type, prompt, template, explanation, max_length, reference_answer)
    VALUES (
      v_topic_id,
      q_type::question_type,
      CASE WHEN q_type IN ('multiple_choice', 'multiple_answer', 'essay', 'essay_blanks')
           THEN question ->> 'prompt' END,
      CASE WHEN q_type IN ('single_choice', 'drag_and_drop', 'essay_blanks')
           THEN question ->> 'template' END,
      CASE WHEN q_type IN ('multiple_choice', 'multiple_answer', 'single_choice', 'drag_and_drop')
           THEN question ->> 'explanation' END,
      CASE WHEN q_type = 'essay' THEN (question ->> 'maxLength')::integer END,
      CASE WHEN q_type = 'essay' THEN question ->> 'referenceAnswer' END
    )
    RETURNING id INTO v_question_id;

    IF q_type IN ('multiple_choice', 'multiple_answer') THEN
      INSERT INTO question_options (question_id, text, is_correct, order_index)
      SELECT v_question_id, o.value ->> 'text', (o.value ->> 'isCorrect')::boolean, o.ord
      FROM jsonb_array_elements(question -> 'options') WITH ORDINALITY AS o(value, ord);

    ELSIF q_type = 'single_choice' THEN
      FOR entry_idx, entry IN
        SELECT b.ord, b.value
        FROM jsonb_array_elements(question -> 'blanks') WITH ORDINALITY AS b(value, ord)
      LOOP
        INSERT INTO question_blanks (question_id, blank_key, order_index)
        VALUES (v_question_id, entry ->> 'key', entry_idx)
        RETURNING id INTO v_blank_id;

        INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
        SELECT v_blank_id, o.value ->> 'text', (o.value ->> 'isCorrect')::boolean, o.ord
        FROM jsonb_array_elements(entry -> 'options') WITH ORDINALITY AS o(value, ord);
      END LOOP;

    ELSIF q_type = 'drag_and_drop' THEN
      INSERT INTO question_terms (question_id, text, order_index)
      SELECT v_question_id, t.value #>> '{}', t.ord
      FROM jsonb_array_elements(question -> 'terms') WITH ORDINALITY AS t(value, ord);

      INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
      SELECT v_question_id, s.value ->> 'key', term.id, s.ord
      FROM jsonb_array_elements(question -> 'slots') WITH ORDINALITY AS s(value, ord)
      JOIN question_terms term
        ON term.question_id = v_question_id AND term.text = s.value ->> 'correctTerm';

    ELSIF q_type = 'essay_blanks' THEN
      INSERT INTO question_blanks (question_id, blank_key, reference_answer, order_index)
      SELECT v_question_id, b.value ->> 'key', b.value ->> 'referenceAnswer', b.ord
      FROM jsonb_array_elements(question -> 'blanks') WITH ORDINALITY AS b(value, ord);
    END IF;

    INSERT INTO quiz_questions (quiz_id, question_id, order_index)
    VALUES (v_quiz_id, v_question_id, idx);
  END LOOP;

  RAISE NOTICE 'imported quiz % (id %) with % question(s)',
    quiz_title, v_quiz_id, jsonb_array_length(payload -> 'questions');
END;
$do$;

COMMIT;
