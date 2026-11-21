import { Badge } from "@components/ui/Badge";
import { CATEGORY_LABEL, WORK_MODEL_LABEL } from "@features/companies/companyLabels";
import type { Company } from "@models/companies";
import {
  StyledCard,
  StyledName,
  StyledBadges,
  StyledDescription,
  StyledOffices,
  StyledOfficeLabel,
  StyledAddress,
  StyledRouteLink,
  StyledNoOffice,
  StyledVisuallyHidden,
} from "./CompanyCard.styles";

type CompanyCardProps = {
  company: Company;
  // The student's address, sent only to Google Maps as the route origin; empty lets Maps ask.
  origin: string;
};

// Google Maps URLs (no API key): opens the route by public transport, with the travel time.
function routeUrl(origin: string, destination: string): string {
  const params = new URLSearchParams({ api: "1", destination, travelmode: "transit" });
  if (origin) params.set("origin", origin);
  return `https://www.google.com/maps/dir/?${params}`;
}

export function CompanyCard({ company, origin }: CompanyCardProps) {
  const isRemote = company.workModel === "remote";

  return (
    <StyledCard>
      <StyledName>{company.name}</StyledName>
      <StyledBadges>
        <Badge tone="accent">{CATEGORY_LABEL[company.category]}</Badge>
        <Badge tone="accent2">{WORK_MODEL_LABEL[company.workModel]}</Badge>
      </StyledBadges>
      <StyledDescription>{company.description}</StyledDescription>

      {company.offices.length === 0 ? (
        <StyledNoOffice>
          {isRemote
            ? "Trabalho remoto, sem escritório para visitar."
            : "Endereço do escritório ainda não cadastrado."}
        </StyledNoOffice>
      ) : (
        <StyledOffices>
          {company.offices.map((office) => (
            <li key={office.address}>
              {office.label && <StyledOfficeLabel>{office.label}</StyledOfficeLabel>}
              <StyledAddress>{office.address}</StyledAddress>
              {!isRemote && (
                <StyledRouteLink
                  href={routeUrl(origin.trim(), office.address)}
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  Ver trajeto no Google Maps
                  <span aria-hidden="true"> ↗</span>
                  <StyledVisuallyHidden> (abre em nova aba)</StyledVisuallyHidden>
                </StyledRouteLink>
              )}
            </li>
          ))}
        </StyledOffices>
      )}
    </StyledCard>
  );
}
