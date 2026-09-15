import { useQuery } from "@tanstack/react-query";
import { ProgressBar } from "@components/ui/ProgressBar";
import { StatusMessage } from "@components/ui/StatusMessage";
import { PageLayout } from "@components/layout/PageLayout";
import { rankingApi } from "@services/api/rankingApi";
import { useAuthStore } from "@features/auth/store/useAuthStore";
import { formatCount } from "@utils/formatCount";
import {
  StyledLayout,
  StyledProfileCard,
  StyledAvatar,
  StyledProfileName,
  StyledProfileCourse,
  StyledDivider,
  StyledMutedLabel,
  StyledStreak,
  StyledStatsGrid,
  StyledStat,
  StyledStatValue,
  StyledStatLabel,
  StyledRankingTitle,
  StyledRankingList,
  StyledRankingRow,
  StyledPosition,
  StyledYouBadge,
  StyledStreakDays,
  StyledPrivacyNote,
} from "./RankingPage.styles";

const MEDALS: Record<number, string> = { 1: "🥇", 2: "🥈", 3: "🥉" };

function getInitials(name: string): string {
  const parts = name.split(" ").filter(Boolean);
  const first = parts[0]?.[0] ?? "";
  const last = parts.length > 1 ? parts[parts.length - 1][0] : "";
  return `${first}${last}`.toUpperCase();
}

export function RankingPage() {
  const user = useAuthStore((state) => state.user);

  const rankingQuery = useQuery({
    queryKey: ["ranking", user?.id],
    queryFn: ({ signal }) => rankingApi.getRanking(signal),
    enabled: Boolean(user),
  });

  return (
    <PageLayout active="ranking">
      {rankingQuery.isLoading && <StatusMessage message="Carregando ranking…" />}

      {rankingQuery.isError && (
        <StatusMessage
          message="Não foi possível carregar o ranking agora."
          error={rankingQuery.error}
          action={{ label: "Tentar novamente", onClick: () => rankingQuery.refetch() }}
        />
      )}

      {rankingQuery.data && user && (
        <StyledLayout>
          <StyledProfileCard tone="surface">
            <StyledAvatar aria-hidden="true">{getInitials(user.name)}</StyledAvatar>
            <StyledProfileName>{user.name}</StyledProfileName>
            <StyledProfileCourse>{user.course}</StyledProfileCourse>
            <StyledDivider />

            <StyledMutedLabel>Sequência atual</StyledMutedLabel>
            <StyledStreak>
              🔥 {formatCount(rankingQuery.data.profile.streakDays, "dia", "dias")}
            </StyledStreak>

            <StyledMutedLabel>
              Meta semanal — {rankingQuery.data.profile.weeklyGoalCompleted}/
              {rankingQuery.data.profile.weeklyGoalTarget} questões
            </StyledMutedLabel>
            <ProgressBar
              value={
                (rankingQuery.data.profile.weeklyGoalCompleted /
                  rankingQuery.data.profile.weeklyGoalTarget) *
                100
              }
              label="Progresso da meta semanal"
            />

            <StyledStatsGrid>
              <StyledStat $tone="accent">
                <StyledStatValue $tone="accent">
                  {rankingQuery.data.profile.questionsAnswered}
                </StyledStatValue>
                <StyledStatLabel>questões</StyledStatLabel>
              </StyledStat>
              <StyledStat $tone="accent2">
                <StyledStatValue $tone="accent2">
                  {rankingQuery.data.profile.quizzesCompleted}
                </StyledStatValue>
                <StyledStatLabel>simulados</StyledStatLabel>
              </StyledStat>
            </StyledStatsGrid>
          </StyledProfileCard>

          <div>
            <StyledRankingTitle>Ranking de consistência</StyledRankingTitle>
            <StyledRankingList tone="surface">
              {rankingQuery.data.entries.map((entry) => (
                <StyledRankingRow key={entry.studentId} $current={entry.isCurrentUser}>
                  <span>
                    <StyledPosition>
                      {MEDALS[entry.position] ? `${MEDALS[entry.position]} ` : ""}
                      {entry.position}.
                    </StyledPosition>
                    {entry.studentName}
                    {entry.isCurrentUser && <StyledYouBadge>Você</StyledYouBadge>}
                  </span>
                  <StyledStreakDays $current={entry.isCurrentUser}>
                    {formatCount(entry.streakDays, "dia", "dias")}
                  </StyledStreakDays>
                </StyledRankingRow>
              ))}
            </StyledRankingList>
            <StyledPrivacyNote>
              O ranking considera apenas consistência de estudo. Notas e desempenho acadêmico são
              privados e não são exibidos a outros alunos.
            </StyledPrivacyNote>
          </div>
        </StyledLayout>
      )}
    </PageLayout>
  );
}
