import { StyledErrorNotice } from "./ErrorNotice.styles";

type ErrorNoticeProps = {
  error: Error | null;
};

export function ErrorNotice({ error }: ErrorNoticeProps) {
  if (!error) return null;
  return <StyledErrorNotice role="alert">{error.message}</StyledErrorNotice>;
}
