import styled from "styled-components";
export type BrandSize = "md" | "lg";

const MARK_SIZE: Record<BrandSize, number> = { md: 44, lg: 56 };
const NAME_SIZE: Record<BrandSize, number> = { md: 17, lg: 22 };

export const StyledBrand = styled.span<{ $size: BrandSize }>`
  display: inline-flex;
  align-items: center;
  gap: ${({ $size }) => ($size === "lg" ? 12 : 10)}px;
  font-family: ${({ theme }) => theme.fonts.heading};
  font-weight: 800;
  font-size: ${({ $size }) => NAME_SIZE[$size]}px;
  line-height: 1;
`;

export const StyledMark = styled.span<{ $size: BrandSize }>`
  display: inline-flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  width: ${({ $size }) => MARK_SIZE[$size]}px;
  height: ${({ $size }) => MARK_SIZE[$size]}px;
  padding: ${({ $size }) => ($size === "lg" ? 6 : 3)}px;
  background: ${({ theme }) => theme.colors.surface};
  border: 1px solid ${({ theme }) => theme.colors.divider};
  border-radius: ${({ $size }) => ($size === "lg" ? 14 : 11)}px;
  box-shadow: ${({ theme }) => theme.shadows.sm};
`;

export const StyledMarkImage = styled.img`
  width: 100%;
  height: 100%;
  object-fit: contain;
`;

export const StyledName = styled.span`
  color: ${({ theme }) => theme.colors.brand};
  white-space: nowrap;
`;

export const StyledNameAccent = styled.span`
  color: ${({ theme }) => theme.colors.brandAccent};
`;
