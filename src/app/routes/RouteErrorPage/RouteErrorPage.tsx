import { Button } from "@components/ui/Button";
import { StyledErrorPage, StyledTitle, StyledMessage } from "./RouteErrorPage.styles";

export function RouteErrorPage() {
  return (
    <StyledErrorPage>
      <StyledTitle>Algo deu errado</StyledTitle>
      <StyledMessage role="alert">
        Não foi possível carregar esta página. Tente novamente em instantes.
      </StyledMessage>
      <Button onClick={() => window.location.assign("/")}>Voltar para o início</Button>
    </StyledErrorPage>
  );
}
