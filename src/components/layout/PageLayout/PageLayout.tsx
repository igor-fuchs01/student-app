import type { ReactNode } from "react";
import { AppHeader, type ActiveNavKey } from "@components/layout/AppHeader";
import { StyledPage, StyledContent } from "./PageLayout.styles";

type PageLayoutProps = {
  active: ActiveNavKey;
  streakDays?: number;
  logoutConfirmation?: string;
  hideMobileNav?: boolean;
  fitViewport?: boolean;
  children: ReactNode;
};

export function PageLayout({
  active,
  streakDays,
  logoutConfirmation,
  hideMobileNav,
  fitViewport = false,
  children,
}: PageLayoutProps) {
  return (
    <StyledPage $fitViewport={fitViewport}>
      <AppHeader
        active={active}
        streakDays={streakDays}
        logoutConfirmation={logoutConfirmation}
        hideMobileNav={hideMobileNav}
      />
      <StyledContent $fitViewport={fitViewport}>{children}</StyledContent>
    </StyledPage>
  );
}
