-- Student App — content of the subject detail screen (docs/05-melhorias-futuras.md, item 7).
--
-- GET /subjects/:id (docs/04-contratos-de-api.md §3.16) needs four levels —
-- disciplina, assunto, subassunto, material — and the MVP schema stops at three:
-- subtopics was left out of it (docs/06-modelagem-de-dados.md, section 3) and
-- topics carries neither the lesson number the screen shows nor a description.
-- This migration closes that gap, so get_subject can be written against it; the
-- function itself is not here, and the endpoint keeps answering from the mock
-- until it lands.
--
-- Each block keeps the conventions of the file that owns its subject: the
-- physical model follows 20260916000000_initial_schema.sql (named table-level
-- constraints, explicit ON DELETE, COMMENT ON TABLE) and the security block
-- follows 20260916000100_auth_and_security.sql.
--
-- Rows that already exist are backfilled rather than rejected, so this also runs
-- on a database that was seeded before.

-- =============================================================================
-- 1. Assunto: lesson number and description (§3.17)
-- =============================================================================

ALTER TABLE topics
  ADD COLUMN number      INTEGER,
  ADD COLUMN description TEXT;

-- Backfill before NOT NULL. Numbering by name keeps the order the screens showed
-- while the column did not exist, and the description repeats the name: a valid
-- placeholder for text the team curates (docs/05-melhorias-futuras.md, item 7.4).
UPDATE topics t
SET number      = ordered.position,
    description = t.name
FROM (
  SELECT id, ROW_NUMBER() OVER (PARTITION BY subject_id ORDER BY name) AS position
  FROM topics
) AS ordered
WHERE ordered.id = t.id;

ALTER TABLE topics
  ALTER COLUMN number SET NOT NULL,
  ALTER COLUMN description SET NOT NULL,
  ADD CONSTRAINT topics_number_check CHECK (number >= 1),
  ADD CONSTRAINT topics_description_check CHECK (btrim(description) <> ''),
  ADD CONSTRAINT topics_subject_id_number_key UNIQUE (subject_id, number);

COMMENT ON COLUMN topics.number IS 'Lesson number in the ementa; the screen labels the assunto "Aula {number}", so reordering the list never renumbers it.';
COMMENT ON COLUMN topics.description IS 'One sentence on what the assunto covers (SubjectTopic.description).';

-- =============================================================================
-- 2. Subassunto (§3.18)
-- =============================================================================

CREATE TABLE subtopics (
  id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  topic_id    INTEGER NOT NULL REFERENCES topics (id) ON DELETE CASCADE,
  name        TEXT NOT NULL CHECK (btrim(name) <> ''),
  summary     TEXT NOT NULL CHECK (btrim(summary) <> ''),
  order_index INTEGER NOT NULL,
  CONSTRAINT subtopics_topic_id_name_key UNIQUE (topic_id, name),
  CONSTRAINT subtopics_topic_id_order_index_key UNIQUE (topic_id, order_index)
);

COMMENT ON TABLE subtopics IS 'Subassuntos of an assunto; the unit the subject detail screen shows, with the short summary the student reviews before studying.';

CREATE TABLE subtopic_key_points (
  id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  subtopic_id INTEGER NOT NULL REFERENCES subtopics (id) ON DELETE CASCADE,
  text        TEXT NOT NULL CHECK (btrim(text) <> ''),
  order_index INTEGER NOT NULL,
  CONSTRAINT subtopic_key_points_subtopic_id_order_index_key UNIQUE (subtopic_id, order_index)
);

COMMENT ON TABLE subtopic_key_points IS 'Key points of a subassunto, in display order (Subtopic.keyPoints); plain text, like the summary.';

-- =============================================================================
-- 3. Materials hang from the subassunto, not from the assunto (§3.19)
-- =============================================================================

ALTER TABLE materials ADD COLUMN subtopic_id INTEGER REFERENCES subtopics (id) ON DELETE CASCADE;

-- Existing materials belong to an assunto and there is no subassunto to hold
-- them, so every assunto that has one gets a subassunto carrying its own name.
INSERT INTO subtopics (topic_id, name, summary, order_index)
SELECT DISTINCT t.id, t.name, t.name, 1
FROM topics t
JOIN materials m ON m.topic_id = t.id;

UPDATE materials m
SET subtopic_id = s.id
FROM subtopics s
WHERE s.topic_id = m.topic_id AND s.order_index = 1;

ALTER TABLE materials ALTER COLUMN subtopic_id SET NOT NULL;

COMMENT ON TABLE materials IS 'Study materials (PDFs) of a subassunto.';

-- =============================================================================
-- 4. Views (the count reaches the material through the subassunto)
-- =============================================================================

-- Replaced before topic_id is dropped: the view still depends on that column.
CREATE OR REPLACE VIEW private.v_subject_summary AS
SELECT
  s.id AS subject_id,
  (
    SELECT COUNT(*)
    FROM materials m
    JOIN subtopics st ON st.id = m.subtopic_id
    JOIN topics t ON t.id = st.topic_id
    WHERE t.subject_id = s.id
  ) AS materials_count,
  (SELECT COUNT(*) FROM questions q JOIN topics t ON t.id = q.topic_id WHERE t.subject_id = s.id) AS questions_count
FROM subjects s;

-- Takes idx_materials_topic_id with it; the FK that replaces it gets its own
-- index because no UNIQUE constraint covers subtopic_id.
ALTER TABLE materials DROP COLUMN topic_id;

CREATE INDEX idx_materials_subtopic_id ON materials (subtopic_id);

-- =============================================================================
-- 5. Row level security
-- =============================================================================

-- Content without answer keys, like subjects, topics and materials. No revoke is
-- needed: the default privileges set in 20260916000100_auth_and_security.sql
-- already keep anon and authenticated off every table created here.
alter table public.subtopics enable row level security;
alter table public.subtopic_key_points enable row level security;

create policy "signed-in students read subtopics"
  on public.subtopics for select to authenticated using (true);

create policy "signed-in students read subtopic key points"
  on public.subtopic_key_points for select to authenticated using (true);
