import type { ReactNode } from "react";
import { AppHeader, type ActiveNavKey } from "@components/layout/AppHeader";
import { StyledPage, StyledContent } from "./PageLayout.styles";

type PageLayoutProps = {
  active: ActiveNavKey;
  streakDays?: number;
  children: ReactNode;
};

export function PageLayout({ active, streakDays, children }: PageLayoutProps) {
  return (
    <StyledPage>
      <AppHeader active={active} streakDays={streakDays} />
      <StyledContent>{children}</StyledContent>
    </StyledPage>
  );
}
