import { useState, type ChangeEvent, type DragEvent } from "react";
import type {
  DragAndDropQuestion,
  EssayBlanksQuestion,
  MultipleAnswerQuestion,
  MultipleChoiceQuestion,
  Question,
  QuizAnswer,
  SingleChoiceQuestion,
} from "@models/quizzes";
import { splitTemplate } from "@features/quizzes/splitTemplate";
import {
  StyledSubjectTag,
  StyledPrompt,
  StyledOptionList,
  StyledOptionLabel,
  StyledDropdownSentence,
  StyledDropdown,
  StyledTextarea,
  StyledCharCount,
  StyledTermBank,
  StyledTermBankLabel,
  StyledTermChip,
  StyledSlot,
  StyledCodeSentence,
  StyledBlankInput,
  StyledDragHandle,
  StyledDragDropHint,
  StyledPointerHint,
  StyledTouchHint,
} from "./QuestionField.styles";

type QuestionFieldProps = {
  question: Question;
  answer: QuizAnswer | undefined;
  onChange: (patch: Omit<QuizAnswer, "questionId">) => void;
};

type FieldProps<TQuestion> = {
  question: TQuestion;
  answer: QuizAnswer | undefined;
  onChange: QuestionFieldProps["onChange"];
};

function MultipleChoiceField({ question, answer, onChange }: FieldProps<MultipleChoiceQuestion>) {
  return (
    <>
      <StyledSubjectTag>{question.subjectName}</StyledSubjectTag>
      <StyledPrompt>{question.prompt}</StyledPrompt>
      <StyledOptionList>
        {question.options.map((option) => (
          <StyledOptionLabel key={option.id} $selected={answer?.optionId === option.id}>
            <input
              type="radio"
              name={question.id}
              checked={answer?.optionId === option.id}
              onChange={() => onChange({ optionId: option.id })}
            />
            {option.text}
          </StyledOptionLabel>
        ))}
      </StyledOptionList>
    </>
  );
}

function MultipleAnswerField({ question, answer, onChange }: FieldProps<MultipleAnswerQuestion>) {
  const selected = answer?.optionIds ?? [];

  function toggle(optionId: string) {
    const next = selected.includes(optionId)
      ? selected.filter((id) => id !== optionId)
      : [...selected, optionId];
    onChange({ optionIds: next });
  }

  return (
    <>
      <StyledSubjectTag>{question.subjectName}</StyledSubjectTag>
      <StyledPrompt>{question.prompt}</StyledPrompt>
      <StyledOptionList>
        {question.options.map((option) => (
          <StyledOptionLabel key={option.id} $selected={selected.includes(option.id)}>
            <input
              type="checkbox"
              checked={selected.includes(option.id)}
              onChange={() => toggle(option.id)}
            />
            {option.text}
          </StyledOptionLabel>
        ))}
      </StyledOptionList>
    </>
  );
}

function SingleChoiceField({ question, answer, onChange }: FieldProps<SingleChoiceQuestion>) {
  const blankAnswers = answer?.blankAnswers ?? {};

  function handleSelect(blankId: string, event: ChangeEvent<HTMLSelectElement>) {
    const next = { ...blankAnswers };
    if (event.target.value) {
      next[blankId] = event.target.value;
    } else {
      delete next[blankId];
    }
    onChange({ blankAnswers: next });
  }

  return (
    <>
      <StyledSubjectTag>{question.subjectName}</StyledSubjectTag>
      <StyledDropdownSentence>
        {splitTemplate(question.template).map((part, index) => {
          if (part.kind === "text") return <span key={index}>{part.value}</span>;

          const blank = question.blanks.find((b) => b.id === part.id);
          if (!blank) return null;

          return (
            <StyledDropdown
              key={part.id}
              aria-label={`Lacuna ${question.blanks.indexOf(blank) + 1}`}
              value={blankAnswers[part.id] ?? ""}
              onChange={(event) => handleSelect(part.id, event)}
              $answered={Boolean(blankAnswers[part.id])}
            >
              <option value="">Selecione…</option>
              {blank.options.map((option) => (
                <option key={option.id} value={option.id}>
                  {option.text}
                </option>
              ))}
            </StyledDropdown>
          );
        })}
      </StyledDropdownSentence>
    </>
  );
}

function DragAndDropField({ question, answer, onChange }: FieldProps<DragAndDropQuestion>) {
  const [selectedTermId, setSelectedTermId] = useState<string | null>(null);
  const slotAnswers = answer?.slotAnswers ?? {};
  const usedTermIds = new Set(Object.values(slotAnswers));

  function placeTerm(slotId: string, termId: string) {
    const next = Object.fromEntries(
      Object.entries(slotAnswers).filter(([, placedTermId]) => placedTermId !== termId),
    );
    next[slotId] = termId;
    onChange({ slotAnswers: next });
    setSelectedTermId(null);
  }

  function clearSlot(slotId: string) {
    const next = { ...slotAnswers };
    delete next[slotId];
    onChange({ slotAnswers: next });
  }

  function handleSlotClick(slotId: string) {
    if (slotAnswers[slotId]) {
      clearSlot(slotId);
      return;
    }
    if (selectedTermId) {
      placeTerm(slotId, selectedTermId);
    }
  }

  function handleTermClick(termId: string) {
    setSelectedTermId((current) => (current === termId ? null : termId));
  }

  function handleDragStart(event: DragEvent<HTMLButtonElement>, termId: string) {
    event.dataTransfer.setData("text/plain", termId);
  }

  function handleDrop(event: DragEvent<HTMLButtonElement>, slotId: string) {
    event.preventDefault();
    const termId = event.dataTransfer.getData("text/plain");
    if (termId) placeTerm(slotId, termId);
  }

  return (
    <>
      <StyledSubjectTag>{question.subjectName}</StyledSubjectTag>
      <StyledDropdownSentence>
        {splitTemplate(question.template).map((part, index) => {
          if (part.kind === "text") return <span key={index}>{part.value}</span>;

          const filledTermId = slotAnswers[part.id];
          const filledTerm = question.terms.find((term) => term.id === filledTermId);
          const slotNumber = question.slots.findIndex((slot) => slot.id === part.id) + 1;

          return (
            <StyledSlot
              key={part.id}
              type="button"
              aria-label={`Lacuna ${slotNumber}: ${filledTerm ? filledTerm.text : "vazia"}`}
              $filled={Boolean(filledTerm)}
              $awaiting={!filledTerm && selectedTermId !== null}
              onClick={() => handleSlotClick(part.id)}
              onDragOver={(event) => event.preventDefault()}
              onDrop={(event) => handleDrop(event, part.id)}
            >
              {filledTerm ? filledTerm.text : "solte aqui"}
            </StyledSlot>
          );
        })}
      </StyledDropdownSentence>

      <StyledTermBank>
        <StyledTermBankLabel>Banco de termos</StyledTermBankLabel>
        {question.terms.map((term) => (
          <StyledTermChip
            key={term.id}
            type="button"
            draggable
            $used={usedTermIds.has(term.id)}
            $selected={selectedTermId === term.id}
            onDragStart={(event) => handleDragStart(event, term.id)}
            onClick={() => handleTermClick(term.id)}
          >
            <StyledDragHandle>⠿</StyledDragHandle>
            {term.text}
          </StyledTermChip>
        ))}
      </StyledTermBank>
      <StyledDragDropHint>
        <StyledPointerHint>
          Arraste um termo até a lacuna, ou clique em um termo e depois na lacuna desejada.
        </StyledPointerHint>
        <StyledTouchHint>
          Toque em um termo e depois na lacuna desejada. Toque em uma lacuna preenchida para
          esvaziá-la.
        </StyledTouchHint>
      </StyledDragDropHint>
    </>
  );
}

function EssayBlanksField({ question, answer, onChange }: FieldProps<EssayBlanksQuestion>) {
  const blankAnswers = answer?.blankAnswers ?? {};

  function handleInput(blankId: string, value: string) {
    const next = { ...blankAnswers };
    if (value) {
      next[blankId] = value;
    } else {
      delete next[blankId];
    }
    onChange({ blankAnswers: next });
  }

  return (
    <>
      <StyledSubjectTag>{question.subjectName}</StyledSubjectTag>
      <StyledPrompt>{question.prompt}</StyledPrompt>
      <StyledCodeSentence>
        {splitTemplate(question.template).map((part, index) => {
          if (part.kind === "text") return <span key={index}>{part.value}</span>;

          return (
            <StyledBlankInput
              key={part.id}
              value={blankAnswers[part.id] ?? ""}
              placeholder="_____"
              aria-label={`Lacuna ${question.blanks.findIndex((blank) => blank.id === part.id) + 1}`}
              $answered={Boolean(blankAnswers[part.id]?.trim())}
              onChange={(event) => handleInput(part.id, event.target.value)}
            />
          );
        })}
      </StyledCodeSentence>
    </>
  );
}

export function QuestionField({ question, answer, onChange }: QuestionFieldProps) {
  switch (question.type) {
    case "multiple_choice":
      return <MultipleChoiceField question={question} answer={answer} onChange={onChange} />;
    case "multiple_answer":
      return <MultipleAnswerField question={question} answer={answer} onChange={onChange} />;
    case "single_choice":
      return <SingleChoiceField question={question} answer={answer} onChange={onChange} />;
    case "drag_and_drop":
      return <DragAndDropField question={question} answer={answer} onChange={onChange} />;
    case "essay_blanks":
      return <EssayBlanksField question={question} answer={answer} onChange={onChange} />;
    case "essay":
      return (
        <>
          <StyledSubjectTag>{question.subjectName}</StyledSubjectTag>
          <StyledPrompt>{question.prompt}</StyledPrompt>
          <StyledTextarea
            aria-label="Sua resposta"
            value={answer?.text ?? ""}
            maxLength={question.maxLength}
            placeholder="Digite sua resposta aqui..."
            onChange={(event) => onChange({ text: event.target.value })}
          />
          <StyledCharCount>
            {(answer?.text ?? "").length}/{question.maxLength} caracteres
          </StyledCharCount>
        </>
      );
  }
}
