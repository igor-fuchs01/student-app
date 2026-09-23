import type { ReactNode } from "react";
import { AppHeader, type ActiveNavKey } from "@components/layout/AppHeader";
import { StyledPage, StyledContent } from "./PageLayout.styles";

type PageLayoutProps = {
  active: ActiveNavKey;
  streakDays?: number;
  logoutConfirmation?: string;
  hideMobileNav?: boolean;
  children: ReactNode;
};

export function PageLayout({
  active,
  streakDays,
  logoutConfirmation,
  hideMobileNav,
  children,
}: PageLayoutProps) {
  return (
    <StyledPage>
      <AppHeader
        active={active}
        streakDays={streakDays}
        logoutConfirmation={logoutConfirmation}
        hideMobileNav={hideMobileNav}
      />
      <StyledContent>{children}</StyledContent>
    </StyledPage>
  );
}
