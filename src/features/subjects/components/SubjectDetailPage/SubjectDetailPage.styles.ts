import styled from "styled-components";
import { Link } from "react-router-dom";
import { Card } from "@components/ui/Card";

export const StyledBackLink = styled(Link)`
  display: inline-block;
  color: ${({ theme }) => theme.colors.muted};
  font-size: 12.5px;
  font-weight: 600;
  text-decoration: none;
  margin-bottom: 16px;

  &:hover {
    color: ${({ theme }) => theme.colors.accent600};
  }

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    display: inline-flex;
    align-items: center;
    min-height: 44px;
    margin-bottom: 8px;
  }
`;

export const StyledSubjectHeader = styled.div`
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
  margin-bottom: 22px;
`;

export const StyledInitial = styled.div`
  width: 48px;
  height: 48px;
  border-radius: ${({ theme }) => theme.radii.pill};
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 700;
  font-size: 14px;
  background: ${({ theme }) => theme.colors.accent100};
  color: ${({ theme }) => theme.colors.accent600};
`;

export const StyledSubjectName = styled.h1`
  font-weight: 700;
  font-size: 22px;
  margin: 0;
`;

export const StyledSubjectMeta = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 13px;
  margin: 0;
`;

export const StyledPreparation = styled.div`
  margin-left: auto;
  min-width: 180px;

  @media (max-width: ${({ theme }) => theme.breakpoints.md}) {
    margin-left: 0;
    width: 100%;
  }
`;

export const StyledPreparationLabel = styled.div`
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  font-weight: 700;
  color: ${({ theme }) => theme.colors.muted};
  margin-bottom: 6px;

  strong {
    color: ${({ theme }) => theme.colors.accent600};
  }
`;

export const StyledLayout = styled.div`
  display: grid;
  grid-template-columns: 272px 1fr;
  gap: 22px;
  align-items: start;

  @media (max-width: ${({ theme }) => theme.breakpoints.md}) {
    grid-template-columns: 1fr;
  }
`;

export const StyledRail = styled(Card)`
  padding: 18px 16px;
  position: sticky;
  top: 74px;

  @media (max-width: ${({ theme }) => theme.breakpoints.md}) {
    position: static;
  }
`;

export const StyledTopicGroup = styled.div`
  & + & {
    margin-top: 18px;
    padding-top: 18px;
    border-top: 1px solid ${({ theme }) => theme.colors.divider};
  }
`;

export const StyledTopicGroupLabel = styled.p`
  font-family: ${({ theme }) => theme.fonts.heading};
  font-size: 12px;
  font-weight: 700;
  color: ${({ theme }) => theme.colors.text};
  margin: 0 0 8px;
  padding: 0 10px;
`;

export const StyledSubtopicList = styled.ul`
  list-style: none;
  margin: 0;
  padding: 0;
`;

export const StyledSubtopicButton = styled.button<{ $selected: boolean }>`
  display: flex;
  align-items: center;
  gap: 9px;
  width: 100%;
  text-align: left;
  border: none;
  border-radius: ${({ theme }) => theme.radii.md};
  padding: 8px 10px;
  font-size: 12.5px;
  font-weight: 600;
  background: ${({ theme, $selected }) => ($selected ? theme.colors.accent100 : "transparent")};
  color: ${({ theme, $selected }) => ($selected ? theme.colors.accent600 : theme.colors.muted)};
  transition: background-color 0.15s ease;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    min-height: 44px;
  }

  &:hover {
    background: ${({ theme, $selected }) => ($selected ? theme.colors.accent100 : theme.colors.bg)};
    color: ${({ theme, $selected }) => ($selected ? theme.colors.accent600 : theme.colors.text)};
  }
`;

export const StyledSubtopicDot = styled.span<{ $selected: boolean }>`
  width: 7px;
  height: 7px;
  border-radius: ${({ theme }) => theme.radii.pill};
  flex-shrink: 0;
  background: ${({ theme, $selected }) => ($selected ? theme.colors.accent : theme.colors.divider)};
`;

export const StyledSections = styled.div`
  display: grid;
  gap: 18px;
`;

export const StyledEyebrow = styled.span`
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  color: ${({ theme }) => theme.colors.accent600};
`;

export const StyledTopicName = styled.h2`
  font-weight: 700;
  font-size: 16px;
  margin: 5px 0;
`;

export const StyledTopicDescription = styled.p`
  color: ${({ theme }) => theme.colors.muted};
  font-size: 13.5px;
  margin: 0;
`;

export const StyledSubtopicName = styled.h2`
  font-weight: 700;
  font-size: 19px;
  margin: 0 0 8px;
`;

export const StyledSubtopicSummary = styled.p`
  font-size: 14px;
  margin: 0 0 20px;
`;

export const StyledSectionTitle = styled.p`
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  color: ${({ theme }) => theme.colors.muted};
  margin: 0 0 10px;
`;

export const StyledKeyPoints = styled.ul`
  list-style: none;
  margin: 0 0 22px;
  padding: 0;
  font-size: 13.5px;

  li {
    position: relative;
    padding-left: 18px;
    margin-bottom: 5px;
  }

  li::before {
    content: "";
    position: absolute;
    left: 0;
    top: 8px;
    width: 6px;
    height: 6px;
    border-radius: ${({ theme }) => theme.radii.pill};
    background: ${({ theme }) => theme.colors.accent};
  }
`;

export const StyledMaterialList = styled.ul`
  list-style: none;
  margin: 0 0 22px;
  padding: 0;
  display: grid;
  gap: 8px;
`;

export const StyledMaterialLink = styled.a`
  display: flex;
  align-items: center;
  gap: 10px;
  background: ${({ theme }) => theme.colors.bg};
  border: 1px solid ${({ theme }) => theme.colors.divider};
  border-radius: ${({ theme }) => theme.radii.md};
  padding: 10px 14px;
  font-size: 13px;
  color: ${({ theme }) => theme.colors.text};
  text-decoration: none;
  transition: border-color 0.15s ease;

  @media (max-width: ${({ theme }) => theme.breakpoints.sm}) {
    min-height: 44px;
  }

  &:hover {
    border-color: ${({ theme }) => theme.colors.accent};
  }
`;
