import { useState } from "react";
import type { QuizAnswer, QuizDetail, QuizResult } from "@models/quizzes";
import { AnswerReview } from "@features/quizzes/components/AnswerReview";
import {
  QUESTION_STATUS_LABEL,
  getQuestionReviewStatus,
  type QuestionReviewStatus,
} from "@features/quizzes/questionReviewStatus";
import {
  StyledExamLayout,
  StyledExamMain,
  StyledExamSidebar,
  StyledExamSidebarLabel,
  StyledExamGrid,
  StyledExamTile,
  StyledExamLegend,
  StyledExamLegendItem,
  StyledExamLegendDot,
} from "./QuizResultPage.styles";

type ExamReviewProps = {
  quiz: QuizDetail;
  answers: QuizAnswer[];
  result: QuizResult;
};

const LEGEND_ORDER: QuestionReviewStatus[] = ["correct", "incorrect", "self_review", "unanswered"];

export function ExamReview({ quiz, answers, result }: ExamReviewProps) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const answerByQuestionId = new Map(answers.map((answer) => [answer.questionId, answer]));
  const statuses = quiz.questions.map((question) =>
    getQuestionReviewStatus(question, answerByQuestionId.get(question.id), result),
  );

  const question = quiz.questions[currentIndex];

  return (
    <StyledExamLayout>
      <StyledExamMain>
        <AnswerReview
          index={currentIndex}
          question={question}
          answer={answerByQuestionId.get(question.id)}
          status={statuses[currentIndex]}
        />
      </StyledExamMain>

      <StyledExamSidebar tone="surface">
        <StyledExamSidebarLabel>Questões</StyledExamSidebarLabel>
        <StyledExamGrid>
          {quiz.questions.map((q, index) => (
            <StyledExamTile
              key={q.id}
              type="button"
              $status={statuses[index]}
              $current={index === currentIndex}
              aria-label={`Questão ${index + 1}: ${QUESTION_STATUS_LABEL[statuses[index]]}`}
              onClick={() => setCurrentIndex(index)}
            >
              {index + 1}
            </StyledExamTile>
          ))}
        </StyledExamGrid>
        <StyledExamLegend>
          {LEGEND_ORDER.map((status) => (
            <StyledExamLegendItem key={status}>
              <StyledExamLegendDot $status={status} />
              {QUESTION_STATUS_LABEL[status]}
            </StyledExamLegendItem>
          ))}
        </StyledExamLegend>
      </StyledExamSidebar>
    </StyledExamLayout>
  );
}
