import { Button } from "@components/ui/Button";
import { StyledStatusMessage } from "./StatusMessage.styles";

type StatusMessageProps = {
  message: string;
  error?: unknown;
  action?: { label: string; onClick: () => void };
};

export function StatusMessage({ message, error, action }: StatusMessageProps) {
  return (
    <StyledStatusMessage>
      <p role={error === undefined ? undefined : "alert"}>
        {message}
        {error instanceof Error && ` ${error.message}`}
      </p>
      {action && (
        <Button variant="secondary" onClick={action.onClick}>
          {action.label}
        </Button>
      )}
    </StyledStatusMessage>
  );
}
