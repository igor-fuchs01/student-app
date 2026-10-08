import styled from "styled-components";
import type { LessonStatus } from "@features/exercises/groupExercises";

export const StyledNav = styled.nav`
  background: ${({ theme }) => theme.colors.surface};
  border-radius: ${({ theme }) => theme.radii.lg};
  box-shadow: ${({ theme }) => theme.shadows.sm};
  display: flex;
  flex-direction: column;
  gap: 10px;
  min-height: 0;
  padding: 16px;
  position: sticky;
  top: 74px;
  max-height: calc(100vh - 100px);

  @media (max-width: ${({ theme }) => theme.breakpoints.md}) {
    position: static;
    max-height: none;
  }
`;

export const StyledSubjectMeta = styled.p`
  margin: -2px 0 4px;
  font-size: 12px;
  color: ${({ theme }) => theme.colors.muted};
`;

export const StyledVisuallyHidden = styled.label`
  position: absolute;
  width: 1px;
  height: 1px;
  overflow: hidden;
  clip: rect(0 0 0 0);
  white-space: nowrap;
`;

export const StyledSearch = styled.input`
  width: 100%;
  min-height: 44px;
  padding: 8px 14px;
  border-radius: ${({ theme }) => theme.radii.pill};
  border: 1px solid ${({ theme }) => theme.colors.divider};
  background: ${({ theme }) => theme.colors.bg};
  color: ${({ theme }) => theme.colors.text};
  font-size: 13px;

  &:focus-visible {
    outline: 2px solid ${({ theme }) => theme.colors.accent};
    outline-offset: 1px;
  }
`;

export const StyledSegmented = styled.div`
  display: flex;
  background: ${({ theme }) => theme.colors.bg};
  border: 1px solid ${({ theme }) => theme.colors.divider};
  border-radius: ${({ theme }) => theme.radii.pill};
  padding: 3px;
`;

export const StyledSegment = styled.button<{ $active: boolean }>`
  flex: 1;
  min-height: 38px;
  border: 0;
  background: ${({ theme, $active }) => ($active ? theme.colors.accent100 : "transparent")};
  color: ${({ theme, $active }) => ($active ? theme.colors.accent600 : theme.colors.muted)};
  font-size: 12.5px;
  font-weight: 600;
  border-radius: ${({ theme }) => theme.radii.pill};
`;

export const StyledLessonList = styled.ul`
  flex: 1;
  min-height: 0;
  overflow-y: auto;
  list-style: none;
  margin: 4px -6px 0;
  padding: 0;
`;

export const StyledLessonButton = styled.button<{ $selected: boolean }>`
  display: flex;
  align-items: center;
  gap: 10px;
  width: 100%;
  min-height: 44px;
  padding: 8px 10px;
  border: 0;
  border-radius: ${({ theme }) => theme.radii.md};
  text-align: left;
  font-size: 13px;
  font-weight: 600;
  background: ${({ theme, $selected }) => ($selected ? theme.colors.accent100 : "transparent")};
  color: ${({ theme, $selected }) => ($selected ? theme.colors.accent600 : theme.colors.text)};

  &:hover {
    background: ${({ theme, $selected }) => ($selected ? theme.colors.accent100 : theme.colors.bg)};
  }

  &:focus-visible {
    outline: 2px solid ${({ theme }) => theme.colors.accent};
    outline-offset: -2px;
  }
`;

export const StyledStatusIcon = styled.span<{ $status: LessonStatus }>`
  flex: none;
  width: 16px;
  text-align: center;
  color: ${({ theme, $status }) =>
    $status === "pending" ? theme.colors.muted : theme.colors.accent600};
`;

export const StyledLessonName = styled.span`
  flex: 1;
  min-width: 0;
`;

export const StyledLessonCount = styled.span`
  flex: none;
  font-size: 12px;
  font-weight: 500;
  color: ${({ theme }) => theme.colors.muted};
  font-variant-numeric: tabular-nums;
`;

export const StyledEmpty = styled.p`
  margin: 8px 0 0;
  font-size: 13px;
  color: ${({ theme }) => theme.colors.muted};
`;
