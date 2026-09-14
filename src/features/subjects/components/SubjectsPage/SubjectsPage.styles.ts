import styled from "styled-components";
import { Card } from "@components/ui/Card";

export const StyledPage = styled.div`
  min-height: 100%;
  background: ${({ theme }) => theme.colors.bg};
`;

export const StyledContent = styled.main`
  padding: 26px 28px 64px;
  max-width: 1280px;
  margin: 0 auto;
`;

export const StyledStateMessage = styled.div`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 14px;
`;

export const StyledPageTitle = styled.h1`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 20px;
  margin: 0 0 4px;
`;

export const StyledPageSubtitle = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 13px;
  margin: 0 0 18px;
`;

export const StyledGrid = styled.div`
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;

  @media (max-width: 860px) {
    grid-template-columns: 1fr;
  }
`;

export const StyledSubjectCard = styled(Card)`
  padding: 18px;
`;

export const StyledIntegratedCard = styled(Card)`
  padding: 18px;
  color: #fff;
`;

export const StyledInitial = styled.div<{ $accent2?: boolean }>`
  width: 44px;
  height: 44px;
  border-radius: ${({ theme }) => theme.radii.pill};
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 13px;
  margin-bottom: 10px;
  background: ${({ theme, $accent2 }) => ($accent2 ? theme.colors.accent2100 : theme.colors.accent100)};
  color: ${({ theme, $accent2 }) => ($accent2 ? theme.colors.accent2600 : theme.colors.accent600)};
`;

export const StyledIntegratedInitial = styled.div`
  width: 44px;
  height: 44px;
  border-radius: ${({ theme }) => theme.radii.pill};
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 11px;
  margin-bottom: 10px;
  background: rgba(255, 255, 255, 0.22);
`;

export const StyledSubjectName = styled.div`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 15px;
  margin-bottom: 4px;
`;

export const StyledSubjectMeta = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 12.5px;
  margin: 0 0 8px;
`;

export const StyledSubjectPreparation = styled.span`
  color: ${({ theme }) => theme.colors.accent600};
  font-size: 12px;
  font-weight: 700;
`;

export const StyledIntegratedEyebrow = styled.span`
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  opacity: 0.85;
`;

export const StyledIntegratedTitle = styled.div`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 15px;
  margin: 4px 0 6px;
`;

export const StyledIntegratedDescription = styled.p`
  font-size: 12.5px;
  margin: 0;
  opacity: 0.9;
`;
