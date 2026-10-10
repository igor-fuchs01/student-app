import { useId } from "react";
import { FieldGroup } from "@features/admin/components/FieldGroup";
import { TextButton } from "@features/admin/components/TextButton";
import { removeAt, replaceAt } from "@features/admin/listEdits";
import type { AdminOption } from "@models/admin";
import { StyledOption, StyledCorrect, StyledText } from "./OptionsEditor.styles";

type OptionsEditorProps = {
  legend: string;
  options: AdminOption[];
  // True when exactly one option is correct: marking one unmarks the others.
  single: boolean;
  onChange: (options: AdminOption[]) => void;
};

export function OptionsEditor({ legend, options, single, onChange }: OptionsEditorProps) {
  const groupName = useId();

  function markCorrect(index: number, isCorrect: boolean) {
    onChange(
      single
        ? options.map((option, position) => ({ ...option, isCorrect: position === index }))
        : replaceAt(options, index, { ...options[index], isCorrect }),
    );
  }

  return (
    <FieldGroup
      legend={legend}
      hint={single ? "Marque a alternativa correta." : "Marque todas as alternativas corretas."}
      addLabel="Adicionar alternativa"
      onAdd={() => onChange([...options, { text: "", isCorrect: false }])}
    >
      {options.map((option, index) => (
        <StyledOption key={index}>
          <StyledCorrect
            type={single ? "radio" : "checkbox"}
            name={groupName}
            checked={option.isCorrect}
            aria-label={`Alternativa ${index + 1} é correta`}
            onChange={(event) => markCorrect(index, event.target.checked)}
          />
          <StyledText
            value={option.text}
            maxLength={1000}
            aria-label={`Texto da alternativa ${index + 1}`}
            onChange={(event) =>
              onChange(replaceAt(options, index, { ...option, text: event.target.value }))
            }
            required
          />
          <TextButton
            tone="danger"
            disabled={options.length <= 2}
            aria-label={`Remover alternativa ${index + 1}`}
            onClick={() => onChange(removeAt(options, index))}
          >
            Remover
          </TextButton>
        </StyledOption>
      ))}
    </FieldGroup>
  );
}
