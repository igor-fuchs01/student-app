import type { QuizTopic } from "@models/quizzes";
import {
  StyledSummary,
  StyledHeading,
  StyledTopicList,
  StyledTopicName,
  StyledSubtopics,
  StyledEmpty,
} from "./QuizContentSummary.styles";

type QuizContentSummaryProps = {
  id: string;
  topics: QuizTopic[];
};

// The assuntos (aulas) a simulado's questions come from, each with its subassuntos.
export function QuizContentSummary({ id, topics }: QuizContentSummaryProps) {
  return (
    <StyledSummary id={id}>
      <StyledHeading>O que este simulado aborda</StyledHeading>
      {topics.length === 0 ? (
        <StyledEmpty>Os assuntos deste simulado ainda não foram cadastrados.</StyledEmpty>
      ) : (
        <StyledTopicList>
          {topics.map((topic) => (
            <li key={topic.number}>
              <StyledTopicName>
                Aula {topic.number} · {topic.name}
              </StyledTopicName>
              {topic.subtopics.length > 0 && (
                <StyledSubtopics>{topic.subtopics.join(" · ")}</StyledSubtopics>
              )}
            </li>
          ))}
        </StyledTopicList>
      )}
    </StyledSummary>
  );
}
