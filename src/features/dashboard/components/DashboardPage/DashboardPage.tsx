import { useEffect, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Badge, type BadgeTone } from "@components/ui/Badge";
import { Card } from "@components/ui/Card";
import { ProgressBar } from "@components/ui/ProgressBar";
import { Button } from "@components/ui/Button";
import { AppHeader } from "@components/layout/AppHeader";
import { dashboardApi } from "@services/api/dashboardApi";
import { useAuthStore } from "@features/auth/store/useAuthStore";
import { useLogout } from "@features/auth/hooks/useLogout";
import type { PriorityLevel, StudyPlanItem } from "@models/dashboard";
import {
  StyledPage,
  StyledContent,
  StyledStateMessage,
  StyledGreeting,
  StyledPageTitle,
  StyledMainGrid,
  StyledEyebrow,
  StyledExamSubject,
  StyledExamMeta,
  StyledProgressLabel,
  StyledProgressValue,
  StyledPriorityList,
  StyledPriorityItem,
  StyledPlanList,
  StyledPlanItemLabel,
  StyledSummaryGrid,
  StyledSummaryCard,
  StyledSummaryValue,
  StyledSummaryDescription,
} from "./DashboardPage.styles";

const PRIORITY_LABEL: Record<PriorityLevel, string> = {
  high: "Prioridade alta",
  medium: "Prioridade média",
  low: "Em dia",
};

const PRIORITY_TONE: Record<PriorityLevel, BadgeTone> = {
  high: "accent2",
  medium: "neutral",
  low: "accent",
};

export function DashboardPage() {
  const user = useAuthStore((state) => state.user);
  const handleLogout = useLogout();

  const firstName = user?.name.split(" ")[0] ?? "Estudante";

  const dashboardQuery = useQuery({
    queryKey: ["dashboard", user?.id],
    queryFn: ({ signal }) => dashboardApi.getDashboard(signal),
    enabled: Boolean(user),
  });

  const [plan, setPlan] = useState<StudyPlanItem[]>([]);

  useEffect(() => {
    if (dashboardQuery.data) {
      setPlan(dashboardQuery.data.todayPlan);
    }
  }, [dashboardQuery.data]);

  function toggleTask(id: string) {
    setPlan((current) =>
      current.map((item) => (item.id === id ? { ...item, done: !item.done } : item)),
    );
  }

  return (
    <StyledPage>
      <AppHeader
        active="inicio"
        streakDays={dashboardQuery.data?.streakDays}
        onLogout={handleLogout}
      />

      <StyledContent>
        {dashboardQuery.isLoading && (
          <StyledStateMessage>Carregando seu painel…</StyledStateMessage>
        )}

        {dashboardQuery.isError && (
          <StyledStateMessage>
            <p role="alert">
              Não foi possível carregar seus dados agora.{" "}
              {dashboardQuery.error instanceof Error ? dashboardQuery.error.message : ""}
            </p>
            <Button variant="secondary" onClick={() => dashboardQuery.refetch()}>
              Tentar novamente
            </Button>
          </StyledStateMessage>
        )}

        {dashboardQuery.data && (
          <>
            <StyledGreeting>Olá, {firstName} 👋</StyledGreeting>
            <StyledPageTitle>O que você vai estudar hoje?</StyledPageTitle>

            <StyledMainGrid>
              <Card tone="surface2">
                <StyledEyebrow>Próxima prova</StyledEyebrow>
                <StyledExamSubject>{dashboardQuery.data.nextExam.subjectName}</StyledExamSubject>
                <StyledExamMeta>
                  {dashboardQuery.data.nextExam.dateLabel} · {dashboardQuery.data.nextExam.note}
                </StyledExamMeta>

                <StyledProgressLabel>Preparação geral</StyledProgressLabel>
                <ProgressBar
                  value={dashboardQuery.data.nextExam.overallPreparation}
                  label="Preparação geral para a próxima prova"
                />
                <StyledProgressValue>
                  {dashboardQuery.data.nextExam.overallPreparation}%
                </StyledProgressValue>

                <StyledPriorityList>
                  {dashboardQuery.data.nextExam.priorities.map((priority, index) => (
                    <StyledPriorityItem key={priority.id}>
                      <span>
                        {index + 1}. {priority.topicName}
                      </span>
                      <Badge tone={PRIORITY_TONE[priority.level]}>
                        {PRIORITY_LABEL[priority.level]}
                      </Badge>
                    </StyledPriorityItem>
                  ))}
                </StyledPriorityList>
              </Card>

              <Card tone="surface">
                <StyledEyebrow>Plano recomendado para hoje</StyledEyebrow>
                <StyledPlanList>
                  {plan.map((item) => (
                    <li key={item.id}>
                      <StyledPlanItemLabel $done={item.done}>
                        <input
                          type="checkbox"
                          checked={item.done}
                          onChange={() => toggleTask(item.id)}
                        />
                        {item.label}
                      </StyledPlanItemLabel>
                    </li>
                  ))}
                </StyledPlanList>
              </Card>
            </StyledMainGrid>

            <StyledSummaryGrid>
              {dashboardQuery.data.summaryCards.map((card) => (
                <StyledSummaryCard key={card.id}>
                  <StyledEyebrow>{card.title}</StyledEyebrow>
                  <StyledSummaryValue>{card.value}</StyledSummaryValue>
                  <StyledSummaryDescription>{card.description}</StyledSummaryDescription>
                </StyledSummaryCard>
              ))}
            </StyledSummaryGrid>
          </>
        )}
      </StyledContent>
    </StyledPage>
  );
}
