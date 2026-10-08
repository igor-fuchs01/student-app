import { useEffect, useId, useRef, useState, type KeyboardEvent } from "react";
import { subjectProgress, type SubjectGroup } from "@features/exercises/groupExercises";
import {
  StyledPicker,
  StyledLabel,
  StyledTrigger,
  StyledTriggerText,
  StyledChevron,
  StyledListbox,
  StyledOption,
  StyledOptionName,
  StyledOptionCount,
} from "./SubjectPicker.styles";

type SubjectPickerProps = {
  subjects: SubjectGroup[];
  value: string;
  onChange: (subjectId: string) => void;
};

// A listbox instead of a native select, so long subject names wrap instead of being cut off.
export function SubjectPicker({ subjects, value, onChange }: SubjectPickerProps) {
  const baseId = useId();
  const labelId = `${baseId}-label`;
  const listboxId = `${baseId}-listbox`;
  const optionId = (index: number) => `${baseId}-option-${index}`;
  const [isOpen, setIsOpen] = useState(false);
  const [activeIndex, setActiveIndex] = useState(0);
  const pickerRef = useRef<HTMLDivElement>(null);
  const triggerRef = useRef<HTMLButtonElement>(null);
  const listboxRef = useRef<HTMLUListElement>(null);
  const selectedIndex = Math.max(
    0,
    subjects.findIndex((subject) => subject.subjectId === value),
  );

  useEffect(() => {
    if (!isOpen) return;
    listboxRef.current?.focus();

    function handlePointerDown(event: PointerEvent) {
      if (!pickerRef.current?.contains(event.target as Node)) setIsOpen(false);
    }
    document.addEventListener("pointerdown", handlePointerDown);
    return () => document.removeEventListener("pointerdown", handlePointerDown);
  }, [isOpen]);

  useEffect(() => {
    if (isOpen)
      document.getElementById(optionId(activeIndex))?.scrollIntoView({ block: "nearest" });
  });

  function open() {
    setActiveIndex(selectedIndex);
    setIsOpen(true);
  }

  function close() {
    setIsOpen(false);
    triggerRef.current?.focus();
  }

  function choose(index: number) {
    close();
    if (subjects[index].subjectId !== value) onChange(subjects[index].subjectId);
  }

  function handleTriggerKeyDown(event: KeyboardEvent<HTMLButtonElement>) {
    if (event.key !== "ArrowDown" && event.key !== "ArrowUp") return;
    event.preventDefault();
    open();
  }

  function handleListboxKeyDown(event: KeyboardEvent<HTMLUListElement>) {
    const lastIndex = subjects.length - 1;
    const moves: Record<string, number> = {
      ArrowDown: Math.min(activeIndex + 1, lastIndex),
      ArrowUp: Math.max(activeIndex - 1, 0),
      Home: 0,
      End: lastIndex,
    };

    if (event.key in moves) {
      event.preventDefault();
      setActiveIndex(moves[event.key]);
    } else if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      choose(activeIndex);
    } else if (event.key === "Escape") {
      event.preventDefault();
      close();
    } else if (event.key === "Tab") {
      setIsOpen(false);
    }
  }

  return (
    <StyledPicker ref={pickerRef}>
      <StyledLabel id={labelId}>Disciplina</StyledLabel>
      <StyledTrigger
        ref={triggerRef}
        type="button"
        aria-haspopup="listbox"
        aria-expanded={isOpen}
        aria-controls={listboxId}
        aria-labelledby={`${labelId} ${baseId}-value`}
        onClick={() => (isOpen ? close() : open())}
        onKeyDown={handleTriggerKeyDown}
      >
        <StyledTriggerText id={`${baseId}-value`}>
          {subjects[selectedIndex]?.subjectName}
        </StyledTriggerText>
        <StyledChevron $open={isOpen} aria-hidden="true" />
      </StyledTrigger>

      {isOpen && (
        <StyledListbox
          ref={listboxRef}
          id={listboxId}
          role="listbox"
          tabIndex={-1}
          aria-labelledby={labelId}
          aria-activedescendant={optionId(activeIndex)}
          onKeyDown={handleListboxKeyDown}
        >
          {subjects.map((subject, index) => {
            const { done, total } = subjectProgress(subject);
            return (
              <StyledOption
                key={subject.subjectId}
                id={optionId(index)}
                role="option"
                aria-selected={index === selectedIndex}
                $active={index === activeIndex}
                $selected={index === selectedIndex}
                onClick={() => choose(index)}
                onPointerMove={() => setActiveIndex(index)}
              >
                <StyledOptionName>{subject.subjectName}</StyledOptionName>
                <StyledOptionCount aria-label={`${done} de ${total} listas feitas`}>
                  {done}/{total}
                </StyledOptionCount>
              </StyledOption>
            );
          })}
        </StyledListbox>
      )}
    </StyledPicker>
  );
}
