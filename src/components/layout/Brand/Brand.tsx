import logoMark from "../../../assets/logo-mark.png";
import {
  StyledBrand,
  StyledMark,
  StyledMarkImage,
  StyledName,
  StyledNameAccent,
  type BrandSize,
} from "./Brand.styles";

type BrandProps = {
  size?: BrandSize;
  className?: string;
};

export function Brand({ size = "md", className }: BrandProps) {
  return (
    <StyledBrand $size={size} className={className}>
      <StyledMark $size={size}>
        <StyledMarkImage src={logoMark} alt="" />
      </StyledMark>
      <StyledName>
        Student <StyledNameAccent>App</StyledNameAccent>
      </StyledName>
    </StyledBrand>
  );
}
