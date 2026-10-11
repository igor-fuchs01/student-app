import { useState } from "react";
import type { QuizAnswer, QuizDetail, QuizResult } from "@models/quizzes";
import { AnswerReview } from "@features/quizzes/components/AnswerReview";
import { QuestionGrid } from "@features/quizzes/components/QuestionGrid";
import {
  QUESTION_STATUS_LEGEND,
  getQuestionReviewStatuses,
} from "@features/quizzes/questionReviewStatus";
import {
  StyledExamLayout,
  StyledExamMain,
  StyledExamSidebar,
  StyledExamSidebarLabel,
} from "./ExamReview.styles";

type ExamReviewProps = {
  quiz: QuizDetail;
  answers: QuizAnswer[];
  result: QuizResult;
  initialIndex?: number;
};

export function ExamReview({ quiz, answers, result, initialIndex = 0 }: ExamReviewProps) {
  const [currentIndex, setCurrentIndex] = useState(initialIndex);
  const statuses = getQuestionReviewStatuses(quiz.questions, answers, result);

  const question = quiz.questions[currentIndex];

  return (
    <StyledExamLayout>
      <StyledExamMain>
        <AnswerReview
          index={currentIndex}
          question={question}
          answer={answers.find((answer) => answer.questionId === question.id)}
          status={statuses[currentIndex]}
        />
      </StyledExamMain>

      <StyledExamSidebar tone="surface">
        <StyledExamSidebarLabel>Questões</StyledExamSidebarLabel>
        <QuestionGrid
          tiles={quiz.questions.map((q, index) => ({
            id: q.id,
            tone: statuses[index],
            current: index === currentIndex,
          }))}
          legend={QUESTION_STATUS_LEGEND}
          onSelect={setCurrentIndex}
        />
      </StyledExamSidebar>
    </StyledExamLayout>
  );
}
