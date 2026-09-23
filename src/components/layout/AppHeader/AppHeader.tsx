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
  StyledNavIcon,
  StyledHeaderActions,
} from "./AppHeader.styles";

export type ActiveNavKey = "inicio" | "disciplinas" | "simulados" | "ranking";

type AppHeaderProps = {
  active: ActiveNavKey;
  streakDays?: number;
  logoutConfirmation?: string;
  hideMobileNav?: boolean;
};

const NAV_ITEMS: { key: ActiveNavKey; label: string; icon: string; to: string }[] = [
  { key: "inicio", label: "Início", icon: "🏠", to: "/" },
  { key: "disciplinas", label: "Disciplinas", icon: "📚", to: "/disciplinas" },
  { key: "simulados", label: "Simulados", icon: "📝", to: "/simulados" },
  { key: "ranking", label: "Ranking", icon: "🏆", to: "/ranking" },
];

export function AppHeader({
  active,
  streakDays,
  logoutConfirmation,
  hideMobileNav = false,
}: AppHeaderProps) {
  const logout = useLogout();

  function handleLogout() {
    if (logoutConfirmation && !window.confirm(logoutConfirmation)) return;
    logout();
  }

  return (
    <StyledHeader>
      <StyledHeaderInner>
        <StyledBrand>🎓 Student App</StyledBrand>
        <StyledNav aria-label="Navegação principal" $hideOnMobile={hideMobileNav}>
          {NAV_ITEMS.map((item) => {
            const icon = <StyledNavIcon aria-hidden="true">{item.icon}</StyledNavIcon>;

            return item.key === active ? (
              <StyledNavLinkActive key={item.key} aria-current="page">
                {icon}
                {item.label}
              </StyledNavLinkActive>
            ) : (
              <StyledNavLink key={item.key} to={item.to}>
                {icon}
                {item.label}
              </StyledNavLink>
            );
          })}
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
