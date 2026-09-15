import { Badge } from "@components/ui/Badge";
import { Button } from "@components/ui/Button";
import { useLogout } from "@features/auth/hooks/useLogout";
import { formatCount } from "@utils/formatCount";
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
  logoutConfirmation?: string;
};

const NAV_ITEMS: { key: ActiveNavKey; label: string; to: string }[] = [
  { key: "inicio", label: "Início", to: "/" },
  { key: "disciplinas", label: "Disciplinas", to: "/disciplinas" },
  { key: "simulados", label: "Simulados", to: "/simulados" },
  { key: "ranking", label: "Ranking", to: "/ranking" },
];

export function AppHeader({ active, streakDays, logoutConfirmation }: AppHeaderProps) {
  const logout = useLogout();

  function handleLogout() {
    if (logoutConfirmation && !window.confirm(logoutConfirmation)) return;
    logout();
  }

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
          {streakDays !== undefined && (
            <Badge tone="accent2">🔥 {formatCount(streakDays, "dia", "dias")} de estudo</Badge>
          )}
          <Button variant="secondary" onClick={handleLogout}>
            Sair
          </Button>
        </StyledHeaderActions>
      </StyledHeaderInner>
    </StyledHeader>
  );
}
