// GET get-subject?id=: SubjectDetail (docs/04-contratos-de-api.md §3.16, GET /subjects/:id).
//
// Assuntos come from the most recent lesson to the oldest, by the number the student reads
// (§3.17); subassuntos, key points and materials by the study order the team defined, which for
// materials is the order they were inserted in.
import { sql } from "../_shared/db.ts";
import { ApiError, serveEndpoint } from "../_shared/http.ts";
import { loadSubjectSummaries } from "../_shared/subjects.ts";

type TopicRow = { id: number; number: number; name: string; description: string };
type SubtopicRow = { id: number; topic_id: number; name: string; summary: string };
type KeyPointRow = { subtopic_id: number; text: string };
type MaterialRow = { id: number; subtopic_id: number; title: string; file_url: string };

serveEndpoint("GET", async ({ url, studentId }) => {
  // A non-numeric id answers 404, like an unknown subject.
  const id = url.searchParams.get("id") ?? "";
  const [subject] = /^\d{1,9}$/.test(id) ? await loadSubjectSummaries(studentId, Number(id)) : [];
  if (!subject) throw new ApiError(404, "NOT_FOUND", "Disciplina não encontrada.");

  const subjectId = Number(subject.id);
  const [topics, subtopics, keyPoints, materials] = await Promise.all([
    sql<TopicRow[]>`
      select id, number, name, description
      from topics
      where subject_id = ${subjectId}
      order by number desc
    `,
    sql<SubtopicRow[]>`
      select st.id, st.topic_id, st.name, st.summary
      from subtopics st
      join topics t on t.id = st.topic_id
      where t.subject_id = ${subjectId}
      order by st.order_index
    `,
    sql<KeyPointRow[]>`
      select kp.subtopic_id, kp.text
      from subtopic_key_points kp
      join subtopics st on st.id = kp.subtopic_id
      join topics t on t.id = st.topic_id
      where t.subject_id = ${subjectId}
      order by kp.order_index
    `,
    sql<MaterialRow[]>`
      select m.id, m.subtopic_id, m.title, m.file_url
      from materials m
      join subtopics st on st.id = m.subtopic_id
      join topics t on t.id = st.topic_id
      where t.subject_id = ${subjectId}
      order by m.id
    `,
  ]);

  return {
    ...subject,
    topics: topics.map((topic) => ({
      id: String(topic.id),
      number: topic.number,
      name: topic.name,
      description: topic.description,
      subtopics: subtopics
        .filter((subtopic) => subtopic.topic_id === topic.id)
        .map((subtopic) => ({
          id: String(subtopic.id),
          name: subtopic.name,
          summary: subtopic.summary,
          keyPoints: keyPoints
            .filter((keyPoint) => keyPoint.subtopic_id === subtopic.id)
            .map((keyPoint) => keyPoint.text),
          materials: materials
            .filter((material) => material.subtopic_id === subtopic.id)
            .map((material) => ({
              id: String(material.id),
              title: material.title,
              fileUrl: material.file_url,
            })),
        })),
    })),
  };
});
