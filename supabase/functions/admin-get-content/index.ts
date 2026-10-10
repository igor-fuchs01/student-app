// GET admin-get-content: every subject with its assuntos, subassuntos, key points and materials
// (AdminSubject[], docs/04-contratos-de-api.md, GET /admin/content), in the order the admin
// edits them: subjects by name, assuntos by lesson number, the rest by their study order.
import { sql } from "../_shared/db.ts";
import { serveAdminEndpoint } from "../_shared/http.ts";

type SubjectRow = { id: number; name: string; short_label: string };
type TopicRow = { id: number; subject_id: number; number: number; name: string; description: string };
type SubtopicRow = { id: number; topic_id: number; name: string; summary: string };
type KeyPointRow = { subtopic_id: number; text: string };
type MaterialRow = { id: number; subtopic_id: number; title: string; file_url: string };

serveAdminEndpoint("GET", async () => {
  const [subjects, topics, subtopics, keyPoints, materials] = await Promise.all([
    sql<SubjectRow[]>`select id, name, short_label from subjects order by name`,
    sql<TopicRow[]>`select id, subject_id, number, name, description from topics order by number`,
    sql<SubtopicRow[]>`select id, topic_id, name, summary from subtopics order by order_index`,
    sql<KeyPointRow[]>`select subtopic_id, text from subtopic_key_points order by order_index`,
    sql<MaterialRow[]>`select id, subtopic_id, title, file_url from materials order by id`,
  ]);

  return subjects.map((subject) => ({
    id: String(subject.id),
    name: subject.name,
    shortLabel: subject.short_label,
    topics: topics
      .filter((topic) => topic.subject_id === subject.id)
      .map((topic) => ({
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
  }));
});
