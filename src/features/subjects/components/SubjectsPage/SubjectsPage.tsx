import { useQuery } from "@tanstack/react-query";
import { StatusMessage } from "@components/ui/StatusMessage";
import { PageLayout } from "@components/layout/PageLayout";
import { subjectsApi } from "@services/api/subjectsApi";
import { formatCount } from "@utils/formatCount";
import {
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
  const subjectsQuery = useQuery({
    queryKey: ["subjects"],
    queryFn: ({ signal }) => subjectsApi.getSubjects(signal),
  });

  return (
    <PageLayout active="disciplinas">
      {subjectsQuery.isLoading && <StatusMessage message="Carregando disciplinas…" />}

      {subjectsQuery.isError && (
        <StatusMessage
          message="Não foi possível carregar as disciplinas agora."
          error={subjectsQuery.error}
          action={{ label: "Tentar novamente", onClick: () => subjectsQuery.refetch() }}
        />
      )}

      {subjectsQuery.data && (
        <>
          <StyledPageTitle>Disciplinas</StyledPageTitle>
          <StyledPageSubtitle>ADS · 1º Semestre</StyledPageSubtitle>

          <StyledGrid>
            {subjectsQuery.data.map((subject, index) => (
              <StyledSubjectCard key={subject.id}>
                <StyledInitial $accent2={index % 2 === 0}>{subject.shortLabel}</StyledInitial>
                <StyledSubjectName>{subject.name}</StyledSubjectName>
                <StyledSubjectMeta>
                  {formatCount(subject.materialsCount, "material", "materiais")} ·{" "}
                  {formatCount(subject.questionsCount, "questão", "questões")}
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
                Questões combinadas das{" "}
                {formatCount(subjectsQuery.data.length, "disciplina", "disciplinas")} em uma única
                prova.
              </StyledIntegratedDescription>
            </StyledIntegratedCard>
          </StyledGrid>
        </>
      )}
    </PageLayout>
  );
}
