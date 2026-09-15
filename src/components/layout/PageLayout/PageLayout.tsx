import type { ReactNode } from "react";
import { AppHeader, type ActiveNavKey } from "@components/layout/AppHeader";
import { StyledPage, StyledContent } from "./PageLayout.styles";

type PageLayoutProps = {
  active: ActiveNavKey;
  streakDays?: number;
  logoutConfirmation?: string;
  children: ReactNode;
};

export function PageLayout({ active, streakDays, logoutConfirmation, children }: PageLayoutProps) {
  return (
    <StyledPage>
      <AppHeader active={active} streakDays={streakDays} logoutConfirmation={logoutConfirmation} />
      <StyledContent>{children}</StyledContent>
    </StyledPage>
  );
}
