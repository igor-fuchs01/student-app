import { useState } from "react";
import type { QuizAnswer, QuizDetail, QuizResult } from "@models/quizzes";
import { AnswerReview } from "@features/quizzes/components/AnswerReview";
import {
  QuestionGrid,
  type QuestionGridLegendItem,
} from "@features/quizzes/components/QuestionGrid";
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
} from "./ExamReview.styles";

type ExamReviewProps = {
  quiz: QuizDetail;
  answers: QuizAnswer[];
  result: QuizResult;
};

const LEGEND_ORDER: QuestionReviewStatus[] = ["correct", "incorrect", "self_review", "unanswered"];

const LEGEND: QuestionGridLegendItem[] = LEGEND_ORDER.map((status) => ({
  label: QUESTION_STATUS_LABEL[status],
  tone: status,
}));

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
        <QuestionGrid
          tiles={quiz.questions.map((q, index) => ({
            id: q.id,
            tone: statuses[index],
            current: index === currentIndex,
          }))}
          legend={LEGEND}
          onSelect={setCurrentIndex}
        />
      </StyledExamSidebar>
    </StyledExamLayout>
  );
}
