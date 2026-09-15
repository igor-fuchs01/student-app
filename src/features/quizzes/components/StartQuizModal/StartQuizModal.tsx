import { useState } from "react";
import { Button } from "@components/ui/Button";
import { Modal } from "@components/ui/Modal";
import {
  StyledTitle,
  StyledBody,
  StyledOptionList,
  StyledOptionLabel,
  StyledOptionText,
  StyledOptionHint,
  StyledActions,
} from "./StartQuizModal.styles";

type StartQuizModalProps = {
  quizTitle: string;
  questionCount: number;
  durationMinutes: number;
  onCancel: () => void;
  onConfirm: (timeLimitEnabled: boolean) => void;
};

export function StartQuizModal({
  quizTitle,
  questionCount,
  durationMinutes,
  onCancel,
  onConfirm,
}: StartQuizModalProps) {
  const [timeLimitEnabled, setTimeLimitEnabled] = useState(true);

  return (
    <Modal ariaLabel="Pronto para começar o simulado?">
      <StyledTitle>Pronto para começar?</StyledTitle>
      <StyledBody>
        Você está prestes a iniciar o simulado <strong>{quizTitle}</strong> ({questionCount}{" "}
        questões).
        <br />
        Escolha o tipo do cronômetro:
      </StyledBody>

      <StyledOptionList>
        <StyledOptionLabel $selected={timeLimitEnabled}>
          <input
            type="radio"
            name="time-limit-mode"
            checked={timeLimitEnabled}
            onChange={() => setTimeLimitEnabled(true)}
          />
          <StyledOptionText>
            Com tempo limite ({durationMinutes} min)
            <StyledOptionHint>
              Ao acabar o tempo, suas respostas são enviadas automaticamente.
            </StyledOptionHint>
          </StyledOptionText>
        </StyledOptionLabel>

        <StyledOptionLabel $selected={!timeLimitEnabled}>
          <input
            type="radio"
            name="time-limit-mode"
            checked={!timeLimitEnabled}
            onChange={() => setTimeLimitEnabled(false)}
          />
          <StyledOptionText>
            Sem tempo limite
            <StyledOptionHint>
              Você decide quando ir para a revisão e enviar o simulado.
            </StyledOptionHint>
          </StyledOptionText>
        </StyledOptionLabel>
      </StyledOptionList>

      <StyledActions>
        <Button variant="secondary" onClick={onCancel}>
          Voltar
        </Button>
        <Button variant="primary" onClick={() => onConfirm(timeLimitEnabled)}>
          Começar simulado
        </Button>
      </StyledActions>
    </Modal>
  );
}
