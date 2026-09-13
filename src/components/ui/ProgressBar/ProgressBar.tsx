import { StyledTrack, StyledFill } from "./ProgressBar.styles";

type ProgressBarProps = {
  value: number;
  label?: string;
};

export function ProgressBar({ value, label }: ProgressBarProps) {
  const clamped = Math.min(100, Math.max(0, value));

  return (
    <StyledTrack
      role="progressbar"
      aria-valuenow={clamped}
      aria-valuemin={0}
      aria-valuemax={100}
      aria-label={label}
    >
      <StyledFill $value={clamped} />
    </StyledTrack>
  );
}
