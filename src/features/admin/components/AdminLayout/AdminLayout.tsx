import type { ReactNode } from "react";
import { useNavigate } from "react-router-dom";
import { useQueryClient } from "@tanstack/react-query";
import { Button } from "@components/ui/Button";
import { Brand } from "@components/layout/Brand";
import { adminApi } from "@services/api/adminApi";
import {
  StyledPage,
  StyledHeader,
  StyledHeaderInner,
  StyledAreaLabel,
  StyledNav,
  StyledNavLink,
  StyledNavLinkActive,
  StyledHeaderActions,
  StyledContent,
  StyledPageHeader,
  StyledPageTitle,
  StyledPageSubtitle,
  StyledPageActions,
} from "./AdminLayout.styles";

export type AdminNavKey = "conteudo" | "questoes" | "simulados";

type AdminLayoutProps = {
  active: AdminNavKey;
  title: string;
  subtitle?: string;
  actions?: ReactNode;
  children: ReactNode;
};

const NAV_ITEMS: { key: AdminNavKey; label: string; to: string }[] = [
  { key: "conteudo", label: "Conteúdo", to: "/admin/conteudo" },
  { key: "questoes", label: "Questões", to: "/admin/questoes" },
  { key: "simulados", label: "Simulados e listas", to: "/admin/simulados" },
];

export function AdminLayout({ active, title, subtitle, actions, children }: AdminLayoutProps) {
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  async function handleLogout() {
    await adminApi.logout().catch(() => undefined);
    queryClient.removeQueries({ queryKey: ["admin"] });
    navigate("/admin/login", { replace: true });
  }

  return (
    <StyledPage>
      <StyledHeader>
        <StyledHeaderInner>
          <Brand />
          <StyledAreaLabel>Administração</StyledAreaLabel>
          <StyledNav aria-label="Navegação da administração">
            {NAV_ITEMS.map((item) =>
              item.key === active ? (
                <StyledNavLinkActive key={item.key} aria-current="page">
                  {item.label}
                </StyledNavLinkActive>
              ) : (
                <StyledNavLink key={item.key} to={item.to}>
                  {item.label}
                </StyledNavLink>
              ),
            )}
          </StyledNav>
          <StyledHeaderActions>
            <Button variant="secondary" onClick={handleLogout}>
              Sair
            </Button>
          </StyledHeaderActions>
        </StyledHeaderInner>
      </StyledHeader>
      <StyledContent>
        <StyledPageHeader>
          <div>
            <StyledPageTitle>{title}</StyledPageTitle>
            {subtitle && <StyledPageSubtitle>{subtitle}</StyledPageSubtitle>}
          </div>
          {actions && <StyledPageActions>{actions}</StyledPageActions>}
        </StyledPageHeader>
        {children}
      </StyledContent>
    </StyledPage>
  );
}
