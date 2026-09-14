import { Badge } from "@components/ui/Badge";
import { Button } from "@components/ui/Button";
import {
  StyledHeader,
  StyledHeaderInner,
  StyledBrand,
  StyledNav,
  StyledNavLink,
  StyledNavLinkActive,
  StyledHeaderActions,
} from "./AppHeader.styles";

export type ActiveNavKey = "inicio" | "disciplinas" | "simulados" | "ranking";

type AppHeaderProps = {
  active: ActiveNavKey;
  streakDays?: number;
  onLogout: () => void;
};

const NAV_ITEMS: { key: ActiveNavKey; label: string; to: string }[] = [
  { key: "inicio", label: "Início", to: "/" },
  { key: "disciplinas", label: "Disciplinas", to: "/disciplinas" },
  { key: "simulados", label: "Simulados", to: "/simulados" },
  { key: "ranking", label: "Ranking", to: "/ranking" },
];

export function AppHeader({ active, streakDays, onLogout }: AppHeaderProps) {
  return (
    <StyledHeader>
      <StyledHeaderInner>
        <StyledBrand>🎓 Student App</StyledBrand>
        <StyledNav aria-label="Navegação principal">
          {NAV_ITEMS.map((item) =>
            item.key === active ? (
              <StyledNavLinkActive key={item.key}>{item.label}</StyledNavLinkActive>
            ) : (
              <StyledNavLink key={item.key} to={item.to}>
                {item.label}
              </StyledNavLink>
            ),
          )}
        </StyledNav>
        <StyledHeaderActions>
          {streakDays !== undefined && <Badge tone="accent2">🔥 {streakDays} dias de estudo</Badge>}
          <Button variant="secondary" onClick={onLogout}>
            Sair
          </Button>
        </StyledHeaderActions>
      </StyledHeaderInner>
    </StyledHeader>
  );
}
