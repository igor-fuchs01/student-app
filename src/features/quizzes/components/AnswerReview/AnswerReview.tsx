import type { QuestionOption, Question, QuizAnswer } from "@models/quizzes";
import { Badge } from "@components/ui/Badge";
import { AnswerComparison } from "@features/quizzes/components/AnswerComparison";
import { normalizeAnswerText } from "@features/quizzes/normalizeAnswerText";
import {
  QUESTION_STATUS_LABEL,
  QUESTION_STATUS_TONE,
  type QuestionReviewStatus,
} from "@features/quizzes/questionReviewStatus";
import { splitTemplate } from "@features/quizzes/splitTemplate";
import {
  StyledReviewCard,
  StyledReviewQuestionHeader,
  StyledReviewSubject,
  StyledReviewPrompt,
  StyledReviewOptionList,
  StyledReviewOption,
  StyledReviewOptionTag,
  StyledReviewSentence,
  StyledReviewBlank,
  StyledReviewExplanation,
  type ReviewTone,
} from "./AnswerReview.styles";

type AnswerReviewProps = {
  index: number;
  question: Question;
  answer: QuizAnswer | undefined;
  status: QuestionReviewStatus;
};

function OptionsReview({
  options,
  correctIds,
  selectedIds,
}: {
  options: QuestionOption[];
  correctIds: Set<string>;
  selectedIds: Set<string>;
}) {
  return (
    <StyledReviewOptionList>
      {options.map((option) => {
        const isCorrect = correctIds.has(option.id);
        const isSelected = selectedIds.has(option.id);
        const tone: ReviewTone = isCorrect ? "correct" : isSelected ? "wrong" : "neutral";
        const tag = isCorrect
          ? isSelected
            ? "✓ Sua resposta"
            : "✓ Resposta correta"
          : isSelected
            ? "✗ Sua resposta"
            : null;

        return (
          <StyledReviewOption key={option.id} $tone={tone}>
            <span>{option.text}</span>
            {tag && <StyledReviewOptionTag>{tag}</StyledReviewOptionTag>}
          </StyledReviewOption>
        );
      })}
    </StyledReviewOptionList>
  );
}

function BlankReview({
  chosen,
  expected,
}: {
  chosen: QuestionOption | undefined;
  expected: QuestionOption | undefined;
}) {
  if (chosen && chosen.id === expected?.id) {
    return <StyledReviewBlank $tone="correct">{chosen.text}</StyledReviewBlank>;
  }
  return (
    <>
      <StyledReviewBlank $tone="wrong">{chosen?.text ?? "sem resposta"}</StyledReviewBlank>
      <StyledReviewBlank $tone="correct">{expected?.text}</StyledReviewBlank>
    </>
  );
}

function QuestionBody({
  question,
  answer,
}: {
  question: Question;
  answer: QuizAnswer | undefined;
}) {
  switch (question.type) {
    case "multiple_choice":
      return (
        <>
          <StyledReviewPrompt>{question.prompt}</StyledReviewPrompt>
          <OptionsReview
            options={question.options}
            correctIds={new Set([question.correctOptionId])}
            selectedIds={new Set(answer?.optionId ? [answer.optionId] : [])}
          />
          <StyledReviewExplanation>{question.explanation}</StyledReviewExplanation>
        </>
      );
    case "multiple_answer":
      return (
        <>
          <StyledReviewPrompt>{question.prompt}</StyledReviewPrompt>
          <OptionsReview
            options={question.options}
            correctIds={new Set(question.correctOptionIds)}
            selectedIds={new Set(answer?.optionIds ?? [])}
          />
          <StyledReviewExplanation>{question.explanation}</StyledReviewExplanation>
        </>
      );
    case "single_choice":
      return (
        <>
          <StyledReviewSentence>
            {splitTemplate(question.template).map((part, index) => {
              if (part.kind === "text") return <span key={index}>{part.value}</span>;
              const blank = question.blanks.find((b) => b.id === part.id);
              if (!blank) return null;
              const optionOf = (optionId: string | undefined) =>
                blank.options.find((option) => option.id === optionId);
              return (
                <BlankReview
                  key={part.id}
                  chosen={optionOf(answer?.blankAnswers?.[part.id])}
                  expected={optionOf(blank.correctOptionId)}
                />
              );
            })}
          </StyledReviewSentence>
          <StyledReviewExplanation>{question.explanation}</StyledReviewExplanation>
        </>
      );
    case "drag_and_drop":
      return (
        <>
          <StyledReviewSentence>
            {splitTemplate(question.template).map((part, index) => {
              if (part.kind === "text") return <span key={index}>{part.value}</span>;
              const slot = question.slots.find((s) => s.id === part.id);
              if (!slot) return null;
              const termOf = (termId: string | undefined) =>
                question.terms.find((term) => term.id === termId);
              return (
                <BlankReview
                  key={part.id}
                  chosen={termOf(answer?.slotAnswers?.[part.id])}
                  expected={termOf(slot.correctTermId)}
                />
              );
            })}
          </StyledReviewSentence>
          <StyledReviewExplanation>{question.explanation}</StyledReviewExplanation>
        </>
      );
    case "essay_blanks":
      return (
        <>
          <StyledReviewPrompt>{question.prompt}</StyledReviewPrompt>
          <StyledReviewSentence>
            {splitTemplate(question.template).map((part, index) => {
              if (part.kind === "text") return <span key={index}>{part.value}</span>;
              const blank = question.blanks.find((b) => b.id === part.id);
              if (!blank) return null;
              const written = answer?.blankAnswers?.[part.id]?.trim();
              if (
                written &&
                normalizeAnswerText(written) === normalizeAnswerText(blank.referenceAnswer)
              ) {
                return (
                  <StyledReviewBlank key={part.id} $tone="correct">
                    {written}
                  </StyledReviewBlank>
                );
              }
              return (
                <span key={part.id}>
                  <StyledReviewBlank $tone={written ? "self" : "wrong"}>
                    {written || "sem resposta"}
                  </StyledReviewBlank>
                  <StyledReviewBlank $tone="correct">{blank.referenceAnswer}</StyledReviewBlank>
                </span>
              );
            })}
          </StyledReviewSentence>
        </>
      );
    case "essay":
      return (
        <>
          <StyledReviewPrompt>{question.prompt}</StyledReviewPrompt>
          <AnswerComparison
            studentAnswer={answer?.text?.trim() || "Sem resposta"}
            referenceAnswer={question.referenceAnswer}
          />
        </>
      );
  }
}

export function AnswerReview({ index, question, answer, status }: AnswerReviewProps) {
  return (
    <StyledReviewCard tone="surface">
      <StyledReviewQuestionHeader>
        <StyledReviewSubject>
          Questão {index + 1} · {question.subjectName}
        </StyledReviewSubject>
        <Badge tone={QUESTION_STATUS_TONE[status]}>{QUESTION_STATUS_LABEL[status]}</Badge>
      </StyledReviewQuestionHeader>
      <QuestionBody question={question} answer={answer} />
    </StyledReviewCard>
  );
}
