-- Student App — content: subject -> topic -> subtopic -> material
-- (docs/02-regras-de-negocio.md §1, docs/04-contratos-de-api.md §3.16-§3.19).
--
-- Only a foreign key that no unique constraint already indexes by its first
-- column gets an index of its own, here and in the other table migrations:
-- Postgres does not index the referencing side, and on delete has to find the
-- child rows.

create table subjects (
  id          integer generated always as identity primary key,
  name        text not null check (btrim(name) <> ''),
  short_label text not null check (btrim(short_label) <> '')
);

comment on table subjects is 'Course subjects (disciplinas).';

create table topics (
  id          integer generated always as identity primary key,
  subject_id  integer not null references subjects (id) on delete cascade,
  number      integer not null,
  name        text not null check (btrim(name) <> ''),
  description text not null check (btrim(description) <> ''),
  constraint topics_number_check check (number >= 1),
  constraint topics_subject_id_name_key unique (subject_id, name),
  constraint topics_subject_id_number_key unique (subject_id, number)
);

comment on table topics is 'Topics (assuntos) of a subject, one per lesson of the ementa; the unit used to diagnose difficulties.';
comment on column topics.number is 'Lesson number in the ementa; the screen labels the assunto "Aula {number}", so reordering the list never renumbers it.';
comment on column topics.description is 'One sentence on what the assunto covers (SubjectTopic.description).';

create table subtopics (
  id          integer generated always as identity primary key,
  topic_id    integer not null references topics (id) on delete cascade,
  name        text not null check (btrim(name) <> ''),
  summary     text not null check (btrim(summary) <> ''),
  order_index integer not null,
  constraint subtopics_topic_id_name_key unique (topic_id, name),
  constraint subtopics_topic_id_order_index_key unique (topic_id, order_index)
);

comment on table subtopics is 'Subassuntos of an assunto; the unit the subject detail screen shows, with the short summary the student reviews before studying.';

create table subtopic_key_points (
  id          integer generated always as identity primary key,
  subtopic_id integer not null references subtopics (id) on delete cascade,
  text        text not null check (btrim(text) <> ''),
  order_index integer not null,
  constraint subtopic_key_points_subtopic_id_order_index_key unique (subtopic_id, order_index)
);

comment on table subtopic_key_points is 'Key points of a subassunto, in display order (Subtopic.keyPoints); plain text, like the summary.';

create table materials (
  id          integer generated always as identity primary key,
  subtopic_id integer not null references subtopics (id) on delete cascade,
  title       text not null check (btrim(title) <> ''),
  file_url    text not null check (btrim(file_url) <> '')
);

comment on table materials is 'Study materials (PDFs) of a subassunto.';

create index idx_materials_subtopic_id on materials (subtopic_id);
