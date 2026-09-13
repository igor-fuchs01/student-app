import { useQuery } from "@tanstack/react-query";
import { Button } from "@components/ui/Button";
import { AppHeader } from "@components/layout/AppHeader";
import { subjectsApi } from "@services/api/subjectsApi";
import { useLogout } from "@features/auth/hooks/useLogout";
import {
  StyledPage,
  StyledContent,
  StyledStateMessage,
  StyledPageTitle,
  StyledPageSubtitle,
  StyledGrid,
  StyledSubjectCard,
  StyledIntegratedCard,
  StyledInitial,
  StyledIntegratedInitial,
  StyledSubjectName,
  StyledSubjectMeta,
  StyledSubjectPreparation,
  StyledIntegratedEyebrow,
  StyledIntegratedTitle,
  StyledIntegratedDescription,
} from "./SubjectsPage.styles";

export function SubjectsPage() {
  const handleLogout = useLogout();

  const subjectsQuery = useQuery({
    queryKey: ["subjects"],
    queryFn: ({ signal }) => subjectsApi.getSubjects(signal),
  });

  return (
    <StyledPage>
      <AppHeader active="disciplinas" onLogout={handleLogout} />

      <StyledContent>
        {subjectsQuery.isLoading && (
          <StyledStateMessage>Carregando disciplinas…</StyledStateMessage>
        )}

        {subjectsQuery.isError && (
          <StyledStateMessage>
            <p role="alert">
              Não foi possível carregar as disciplinas agora.{" "}
              {subjectsQuery.error instanceof Error ? subjectsQuery.error.message : ""}
            </p>
            <Button variant="secondary" onClick={() => subjectsQuery.refetch()}>
              Tentar novamente
            </Button>
          </StyledStateMessage>
        )}

        {subjectsQuery.data && (
          <>
            <StyledPageTitle>Disciplinas</StyledPageTitle>
            <StyledPageSubtitle>ADS · 1º Semestre</StyledPageSubtitle>

            <StyledGrid>
              {subjectsQuery.data.map((subject, index) => (
                <StyledSubjectCard key={subject.id}>
                  <StyledInitial
                    $accent2={
                      index % 2 == 0
                    }
                  >
                    {subject.shortLabel}
                  </StyledInitial>
                  <StyledSubjectName>{subject.name}</StyledSubjectName>
                  <StyledSubjectMeta>
                    {subject.materialsCount} materiais · {subject.questionsCount} questões
                  </StyledSubjectMeta>
                  <StyledSubjectPreparation>
                    Preparo: {subject.preparationPercent}%
                  </StyledSubjectPreparation>
                </StyledSubjectCard>
              ))}

              <StyledIntegratedCard tone="accent">
                <StyledIntegratedInitial>TODAS</StyledIntegratedInitial>
                <StyledIntegratedEyebrow>Simulado integrado</StyledIntegratedEyebrow>
                <StyledIntegratedTitle>Todas as disciplinas</StyledIntegratedTitle>
                <StyledIntegratedDescription>
                  Questões combinadas das 5 disciplinas em uma única prova.
                </StyledIntegratedDescription>
              </StyledIntegratedCard>
            </StyledGrid>
          </>
        )}
      </StyledContent>
    </StyledPage>
  );
}
