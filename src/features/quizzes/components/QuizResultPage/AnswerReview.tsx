import type { QuestionOption, Question, QuizAnswer } from "@models/quizzes";
import { splitTemplate } from "../../splitTemplate";
import {
  StyledReviewCard,
  StyledReviewQuestionHeader,
  StyledReviewSubject,
  StyledBadge,
  StyledReviewPrompt,
  StyledReviewOptionList,
  StyledReviewOption,
  StyledReviewOptionTag,
  StyledReviewSentence,
  StyledReviewBlank,
  StyledReviewExplanation,
  StyledAnswerComparison,
  StyledAnswerLabel,
  StyledAnswerText,
  type ReviewTone,
} from "./QuizResultPage.styles";
import {
  QUESTION_STATUS_LABEL,
  QUESTION_STATUS_TONE,
  type QuestionReviewStatus,
} from "./questionReviewStatus";

type AnswerReviewProps = {
  index: number;
  question: Question;
  answer: QuizAnswer | undefined;
  status: QuestionReviewStatus;
};

function normalizeText(text: string): string {
  return text.trim().toLowerCase().replace(/\s+/g, " ");
}

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

function BlankReview({ chosen, expected }: { chosen: string | undefined; expected: string }) {
  if (chosen === expected) {
    return <StyledReviewBlank $tone="correct">{chosen}</StyledReviewBlank>;
  }
  return (
    <>
      <StyledReviewBlank $tone="wrong">
        {chosen ?? "sem resposta"}
      </StyledReviewBlank>
      <StyledReviewBlank $tone="correct">{expected}</StyledReviewBlank>
    </>
  );
}

function QuestionBody({ question, answer }: { question: Question; answer: QuizAnswer | undefined }) {
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
              const textOf = (optionId: string | undefined) =>
                blank.options.find((option) => option.id === optionId)?.text;
              return (
                <BlankReview
                  key={part.id}
                  chosen={textOf(answer?.blankAnswers?.[part.id])}
                  expected={textOf(blank.correctOptionId) ?? ""}
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
              const textOf = (termId: string | undefined) =>
                question.terms.find((term) => term.id === termId)?.text;
              return (
                <BlankReview
                  key={part.id}
                  chosen={textOf(answer?.slotAnswers?.[part.id])}
                  expected={textOf(slot.correctTermId) ?? ""}
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
              if (written && normalizeText(written) === normalizeText(blank.referenceAnswer)) {
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
          <StyledAnswerComparison>
            <div>
              <StyledAnswerLabel>Sua resposta</StyledAnswerLabel>
              <StyledAnswerText>{answer?.text?.trim() || "Sem resposta"}</StyledAnswerText>
            </div>
            <div>
              <StyledAnswerLabel>Resposta esperada</StyledAnswerLabel>
              <StyledAnswerText>{question.referenceAnswer}</StyledAnswerText>
            </div>
          </StyledAnswerComparison>
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
        <StyledBadge $tone={QUESTION_STATUS_TONE[status]}>{QUESTION_STATUS_LABEL[status]}</StyledBadge>
      </StyledReviewQuestionHeader>
      <QuestionBody question={question} answer={answer} />
    </StyledReviewCard>
  );
}
