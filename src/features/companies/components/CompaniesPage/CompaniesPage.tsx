import { useId, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { FilterBar } from "@components/ui/FilterBar";
import { StatusMessage } from "@components/ui/StatusMessage";
import { TextField } from "@components/ui/TextField";
import { PageLayout } from "@components/layout/PageLayout";
import { CompanyCard } from "@features/companies/components/CompanyCard";
import { CATEGORY_LABEL } from "@features/companies/companyLabels";
import { companiesApi } from "@services/api/companiesApi";
import type { CompanyCategory } from "@models/companies";
import {
  StyledPageTitle,
  StyledPageSubtitle,
  StyledAddressField,
  StyledAddressNote,
  StyledGrid,
} from "./CompaniesPage.styles";

export function CompaniesPage() {
  const noteId = useId();
  const [categoryFilter, setCategoryFilter] = useState<CompanyCategory>();
  // Kept only while the page is open: the address is never stored nor sent to the backend.
  const [homeAddress, setHomeAddress] = useState("");

  const companiesQuery = useQuery({
    queryKey: ["companies"],
    queryFn: ({ signal }) => companiesApi.getCompanies(signal),
  });

  const companies = companiesQuery.data ?? [];
  const visibleCompanies = companies.filter(
    (company) => !categoryFilter || company.category === categoryFilter,
  );

  return (
    <PageLayout active="empresas">
      {companiesQuery.isLoading && <StatusMessage message="Carregando empresas…" />}

      {companiesQuery.isError && (
        <StatusMessage
          message="Não foi possível carregar as empresas agora."
          error={companiesQuery.error}
          action={{ label: "Tentar novamente", onClick: () => companiesQuery.refetch() }}
        />
      )}

      {companiesQuery.data && (
        <>
          <StyledPageTitle>Empresas</StyledPageTitle>
          <StyledPageSubtitle>
            Empresas que já deram palestra na universidade, com o escritório e o modelo de trabalho.
          </StyledPageSubtitle>

          <StyledAddressField>
            <TextField
              label="Seu endereço"
              placeholder="Rua, número, bairro e cidade"
              autoComplete="street-address"
              value={homeAddress}
              onChange={(event) => setHomeAddress(event.target.value)}
              aria-describedby={noteId}
            />
            <StyledAddressNote id={noteId}>
              Com o endereço preenchido, &quot;Ver trajeto&quot; mostra o caminho e o tempo de
              transporte público da sua casa até o escritório. O endereço não é salvo: ele só vai
              para o Google Maps quando você abre um trajeto.
            </StyledAddressNote>
          </StyledAddressField>

          {companies.length > 0 && (
            <FilterBar
              label="Filtros das empresas"
              filters={[
                {
                  label: "Categoria",
                  allLabel: "Todas as categorias",
                  options: Object.entries(CATEGORY_LABEL).map(([value, label]) => ({
                    value,
                    label,
                  })),
                  value: categoryFilter,
                  onChange: (value) => setCategoryFilter(value as CompanyCategory | undefined),
                },
              ]}
            />
          )}

          {companies.length === 0 && <StatusMessage message="Nenhuma empresa cadastrada ainda." />}

          {companies.length > 0 && visibleCompanies.length === 0 && (
            <StatusMessage message="Nenhuma empresa encontrada nessa categoria." />
          )}

          {visibleCompanies.length > 0 && (
            <StyledGrid>
              {visibleCompanies.map((company) => (
                <CompanyCard key={company.id} company={company} origin={homeAddress} />
              ))}
            </StyledGrid>
          )}
        </>
      )}
    </PageLayout>
  );
}
