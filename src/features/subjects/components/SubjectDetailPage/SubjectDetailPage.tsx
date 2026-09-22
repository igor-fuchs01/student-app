import { useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { useQuery } from "@tanstack/react-query";
import { Button } from "@components/ui/Button";
import { Card } from "@components/ui/Card";
import { ProgressBar } from "@components/ui/ProgressBar";
import { StatusMessage } from "@components/ui/StatusMessage";
import { PageLayout } from "@components/layout/PageLayout";
import { subjectsApi } from "@services/api/subjectsApi";
import type { SubjectDetail, SubjectTopic, Subtopic } from "@models/subjects";
import { formatCount } from "@utils/formatCount";
import {
  StyledBackLink,
  StyledSubjectHeader,
  StyledInitial,
  StyledSubjectName,
  StyledSubjectMeta,
  StyledPreparation,
  StyledPreparationLabel,
  StyledLayout,
  StyledRail,
  StyledTopicGroup,
  StyledTopicGroupLabel,
  StyledSubtopicList,
  StyledSubtopicButton,
  StyledSubtopicDot,
  StyledSections,
  StyledEyebrow,
  StyledTopicName,
  StyledTopicDescription,
  StyledSubtopicName,
  StyledSubtopicSummary,
  StyledSectionTitle,
  StyledKeyPoints,
  StyledMaterialList,
  StyledMaterialLink,
} from "./SubjectDetailPage.styles";

type Selection = { topic: SubjectTopic; subtopic: Subtopic };

// The selected subassunto, falling back to the first one while the student has not picked any.
function findSelection(subject: SubjectDetail, subtopicId: string | null): Selection | null {
  let fallback: Selection | null = null;

  for (const topic of subject.topics) {
    for (const subtopic of topic.subtopics) {
      const selection = { topic, subtopic };
      if (subtopic.id === subtopicId) return selection;
      if (!fallback) fallback = selection;
    }
  }

  return fallback;
}

export function SubjectDetailPage() {
  const { subjectId = "" } = useParams<{ subjectId: string }>();
  const navigate = useNavigate();
  const [selectedSubtopicId, setSelectedSubtopicId] = useState<string | null>(null);

  const subjectQuery = useQuery({
    queryKey: ["subject", subjectId],
    queryFn: ({ signal }) => subjectsApi.getSubject(subjectId, signal),
  });

  const subject = subjectQuery.data;
  const selection = subject ? findSelection(subject, selectedSubtopicId) : null;

  return (
    <PageLayout active="disciplinas">
      {subjectQuery.isLoading && <StatusMessage message="Carregando disciplina…" />}

      {subjectQuery.isError && (
        <StatusMessage
          message="Não foi possível carregar esta disciplina."
          error={subjectQuery.error}
          action={{ label: "Voltar para disciplinas", onClick: () => navigate("/disciplinas") }}
        />
      )}

      {subject && (
        <>
          <StyledBackLink to="/disciplinas">← Disciplinas</StyledBackLink>

          <StyledSubjectHeader>
            <StyledInitial>{subject.shortLabel}</StyledInitial>
            <div>
              <StyledSubjectName>{subject.name}</StyledSubjectName>
              <StyledSubjectMeta>
                ADS · 1º Semestre · {formatCount(subject.topics.length, "assunto", "assuntos")}
              </StyledSubjectMeta>
            </div>
            <StyledPreparation>
              <StyledPreparationLabel>
                <span>Seu preparo</span>
                <strong>{subject.preparationPercent}%</strong>
              </StyledPreparationLabel>
              <ProgressBar
                value={subject.preparationPercent}
                label={`Preparo em ${subject.name}`}
              />
            </StyledPreparation>
          </StyledSubjectHeader>

          {!selection && (
            <StatusMessage message="Os assuntos desta disciplina ainda não foram publicados." />
          )}

          {selection && (
            <StyledLayout>
              <StyledRail role="navigation" aria-label="Assuntos da disciplina">
                {subject.topics.map((topic) => (
                  <StyledTopicGroup key={topic.id}>
                    <StyledTopicGroupLabel>
                      Aula {topic.number} - {topic.name}
                    </StyledTopicGroupLabel>
                    <StyledSubtopicList>
                      {topic.subtopics.map((subtopic) => {
                        const isSelected = subtopic.id === selection.subtopic.id;

                        return (
                          <li key={subtopic.id}>
                            <StyledSubtopicButton
                              type="button"
                              $selected={isSelected}
                              aria-current={isSelected}
                              onClick={() => setSelectedSubtopicId(subtopic.id)}
                            >
                              <StyledSubtopicDot $selected={isSelected} />
                              {subtopic.name}
                            </StyledSubtopicButton>
                          </li>
                        );
                      })}
                    </StyledSubtopicList>
                  </StyledTopicGroup>
                ))}
              </StyledRail>

              <StyledSections>
                <Card tone="surface2">
                  <StyledEyebrow>Aula {selection.topic.number}</StyledEyebrow>
                  <StyledTopicName>{selection.topic.name}</StyledTopicName>
                  <StyledTopicDescription>{selection.topic.description}</StyledTopicDescription>
                </Card>

                <Card>
                  <StyledSubtopicName>{selection.subtopic.name}</StyledSubtopicName>
                  <StyledSubtopicSummary>{selection.subtopic.summary}</StyledSubtopicSummary>

                  <StyledSectionTitle>Pontos-chave</StyledSectionTitle>
                  <StyledKeyPoints>
                    {selection.subtopic.keyPoints.map((keyPoint) => (
                      <li key={keyPoint}>{keyPoint}</li>
                    ))}
                  </StyledKeyPoints>

                  <StyledSectionTitle>Materiais</StyledSectionTitle>
                  <StyledMaterialList>
                    {selection.subtopic.materials.map((material) => (
                      <li key={material.id}>
                        <StyledMaterialLink
                          href={material.fileUrl}
                          target="_blank"
                          rel="noreferrer"
                        >
                          📄 {material.title}
                        </StyledMaterialLink>
                      </li>
                    ))}
                  </StyledMaterialList>

                  <Button onClick={() => navigate("/simulados")}>Praticar questões</Button>
                </Card>
              </StyledSections>
            </StyledLayout>
          )}
        </>
      )}
    </PageLayout>
  );
}
