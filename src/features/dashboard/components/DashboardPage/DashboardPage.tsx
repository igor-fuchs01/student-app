import { keepPreviousData, useQuery } from "@tanstack/react-query";
import { useNavigate, useSearchParams } from "react-router-dom";
import { Button } from "@components/ui/Button";
import { ProgressBar } from "@components/ui/ProgressBar";
import { StatusMessage } from "@components/ui/StatusMessage";
import { PageLayout } from "@components/layout/PageLayout";
import { dashboardApi } from "@services/api/dashboardApi";
import { subjectsApi } from "@services/api/subjectsApi";
import { useAuthStore } from "@features/auth/store/useAuthStore";
import { formatPercent } from "@features/dashboard/percent";
import { DASHBOARD_PERIODS, type DashboardFilters as Filters } from "@models/dashboard";
import { AccuracyTrendChart } from "./AccuracyTrendChart";
import { ChartCard } from "./ChartCard";
import { DashboardFilters } from "./DashboardFilters";
import { KpiCard } from "./KpiCard";
import { PreparationChart } from "./PreparationChart";
import { Sparkline } from "./Sparkline";
import { StudyFocusCard } from "./StudyFocusCard";
import {
  StyledDashboard,
  StyledHead,
  StyledGreeting,
  StyledSubtitle,
  StyledGrid,
  StyledKpis,
  StyledCharts,
  StyledFocusArea,
  StyledEmptyState,
} from "./DashboardPage.styles";

const DEFAULT_PERIOD = 90;

function readFilters(searchParams: URLSearchParams): Filters {
  const period = DASHBOARD_PERIODS.find((value) => String(value) === searchParams.get("periodo"));
  return {
    period: period ?? DEFAULT_PERIOD,
    subjectId: searchParams.get("disciplina") || undefined,
  };
}

export function DashboardPage() {
  const navigate = useNavigate();
  const user = useAuthStore((state) => state.user);
  const displayName = useAuthStore((state) => state.displayName);
  const firstName = displayName?.split(" ")[0] ?? "Estudante";

  const [searchParams, setSearchParams] = useSearchParams();
  const filters = readFilters(searchParams);

  const dashboardQuery = useQuery({
    queryKey: ["dashboard", user?.id, filters.period, filters.subjectId],
    queryFn: ({ signal }) => dashboardApi.getDashboard(filters, signal),
    enabled: Boolean(user),
    placeholderData: keepPreviousData,
  });

  const subjectsQuery = useQuery({
    queryKey: ["subjects"],
    queryFn: ({ signal }) => subjectsApi.getSubjects(signal),
  });

  function changeFilters({ period, subjectId }: Filters) {
    const next = new URLSearchParams();
    if (period !== DEFAULT_PERIOD) next.set("periodo", String(period));
    if (subjectId) next.set("disciplina", subjectId);
    setSearchParams(next, { replace: true });
  }

  const data = dashboardQuery.data;
  const comparisonLabel =
    filters.period === 180 ? "vs semestre anterior" : `vs ${filters.period} dias anteriores`;
  const weeklyGoalPercent = data
    ? Math.min(100, (100 * data.weeklyGoal.completed) / data.weeklyGoal.target)
    : 0;

  return (
    <PageLayout active="inicio" streakDays={data?.streakDays} fitViewport>
      {dashboardQuery.isLoading && <StatusMessage message="Carregando seu painel…" />}

      {dashboardQuery.isError && !data && (
        <StatusMessage
          message="Não foi possível carregar seus dados agora."
          error={dashboardQuery.error}
          action={{ label: "Tentar novamente", onClick: () => dashboardQuery.refetch() }}
        />
      )}

      {data && (
        <StyledDashboard $updating={dashboardQuery.isPlaceholderData}>
          <StyledHead>
            <div>
              <StyledGreeting>Olá, {firstName} 👋</StyledGreeting>
              <StyledSubtitle>Veja como está o seu preparo</StyledSubtitle>
            </div>
            <DashboardFilters
              filters={filters}
              subjects={subjectsQuery.data ?? []}
              onChange={changeFilters}
            />
          </StyledHead>

          {data.questionsAnswered.count === 0 ? (
            <StyledEmptyState as="section">
              <h2>Nenhuma questão respondida neste período</h2>
              <p>Faça um simulado para acompanhar aqui o seu preparo e a sua evolução.</p>
              <Button onClick={() => navigate("/simulados")}>Ver simulados</Button>
            </StyledEmptyState>
          ) : (
            <StyledGrid>
              <StyledKpis>
                <KpiCard
                  label="Preparo geral"
                  value={formatPercent(data.preparation.percent)}
                  aside={<Sparkline values={data.weeklyAccuracy.map((week) => week.percent)} />}
                  delta={{
                    current: data.preparation.percent,
                    previous: data.preparation.previousPercent,
                    unit: "points",
                    comparisonLabel,
                  }}
                />
                <KpiCard
                  label="Questões respondidas"
                  value={data.questionsAnswered.count.toLocaleString("pt-BR")}
                  delta={{
                    current: data.questionsAnswered.count,
                    previous: data.questionsAnswered.previousCount,
                    unit: "percent",
                    comparisonLabel,
                  }}
                />
                <KpiCard
                  label="Meta da semana"
                  value={String(data.weeklyGoal.completed)}
                  unit={`/ ${data.weeklyGoal.target} questões`}
                >
                  <ProgressBar value={weeklyGoalPercent} label="Progresso da meta da semana" />
                </KpiCard>
              </StyledKpis>

              <StyledCharts>
                <ChartCard
                  title="Evolução do acerto"
                  subtitle="Acerto por semana"
                  legend={[
                    { mark: "line", label: "Seu acerto" },
                    { mark: "target", label: "Meta (80%)" },
                  ]}
                >
                  {(showTable) => (
                    <AccuracyTrendChart weeks={data.weeklyAccuracy} showTable={showTable} />
                  )}
                </ChartCard>
                <ChartCard
                  title={
                    data.preparationBreakdown.scope === "topic"
                      ? "Preparo por assunto"
                      : "Preparo por disciplina"
                  }
                  subtitle="Do maior para o menor acerto"
                  legend={[{ mark: "target", label: "Meta (80%)" }]}
                >
                  {(showTable) => (
                    <PreparationChart breakdown={data.preparationBreakdown} showTable={showTable} />
                  )}
                </ChartCard>
              </StyledCharts>

              <StyledFocusArea>
                <StudyFocusCard studyFocus={data.studyFocus} />
              </StyledFocusArea>
            </StyledGrid>
          )}
        </StyledDashboard>
      )}
    </PageLayout>
  );
}
