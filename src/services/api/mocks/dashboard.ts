import type {
  DashboardData,
  DashboardFilters,
  PreparationItem,
  StudyFocusLevel,
  StudyFocusTopic,
} from "@models/dashboard";
import type { ActivityCalendar } from "@models/ranking";
import { buildMockSubjects, getMockSubjectDetail } from "./subjects";

type MockAnswer = {
  day: number;
  subjectId: string;
  topicId: string;
  status: "correct" | "incorrect" | "pending_review";
};

type MockTopic = {
  id: string;
  name: string;
  number: number;
  subjectId: string;
  subjectShortLabel: string;
};

const HISTORY_DAYS = 360;
const WEEKLY_GOAL_TARGET = 50;
const FOCUS_LIMIT = 5;
const FEW_PRACTICE_BELOW = 10;
const RECENT_DAYS = 14;
const LEVEL_ORDER: Record<StudyFocusLevel, number> = { high: 0, medium: 1, few_practice: 2 };

const MOCK_TOPICS: MockTopic[] = buildMockSubjects().flatMap((subject) =>
  (getMockSubjectDetail(subject.id)?.topics ?? []).map((topic) => ({
    id: topic.id,
    name: topic.name,
    number: topic.number,
    subjectId: subject.id,
    subjectShortLabel: subject.shortLabel,
  })),
);

function mulberry32(seed: number): () => number {
  let state = seed;
  return () => {
    state = (state + 0x6d2b79f5) | 0;
    let t = Math.imul(state ^ (state >>> 15), 1 | state);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

// Days are relative to today (0 = today, -1 = yesterday). The same seed always gives the same
// history, so the screen is stable between reloads; the last 9 days are always studied.
function generateHistory(): { answers: MockAnswer[]; activityDays: Set<number> } {
  const random = mulberry32(20260930);
  const skill = new Map(MOCK_TOPICS.map((topic) => [topic.id, 0.2 + random() * 0.5]));
  const answers: MockAnswer[] = [];
  const activityDays = new Set<number>();

  for (let day = -HISTORY_DAYS + 1; day <= 0; day++) {
    const progress = (day + HISTORY_DAYS) / HISTORY_DAYS;
    const studied = day >= -8 || (day < -10 && random() < 0.28 + 0.4 * progress);
    if (!studied) continue;
    activityDays.add(day);

    const { subjectId } = MOCK_TOPICS[Math.floor(random() * MOCK_TOPICS.length)];
    const subjectTopics = MOCK_TOPICS.filter((topic) => topic.subjectId === subjectId);
    const questionCount = random() < 0.3 ? 15 : 10;
    for (let index = 0; index < questionCount; index++) {
      const topic = subjectTopics[Math.floor(random() * subjectTopics.length)];
      const chance = Math.min(0.97, (skill.get(topic.id) ?? 0.5) + 0.18 * progress);
      let status: MockAnswer["status"] = random() < chance ? "correct" : "incorrect";
      if (day > -12 && random() < 0.07) status = "pending_review";
      answers.push({ day, subjectId: topic.subjectId, topicId: topic.id, status });
    }
  }
  return { answers, activityDays };
}

const HISTORY = generateHistory();

function percent(part: number, total: number): number | null {
  return total === 0 ? null : Math.round((10000 * part) / total) / 100;
}

function tally(answers: MockAnswer[]) {
  const graded = answers.filter((answer) => answer.status !== "pending_review");
  const correct = graded.filter((answer) => answer.status === "correct").length;
  return {
    answered: answers.length,
    graded: graded.length,
    correct,
    percent: percent(correct, graded.length),
  };
}

function isoDate(day: number): string {
  const date = new Date();
  date.setDate(date.getDate() + day);
  const month = String(date.getMonth() + 1).padStart(2, "0");
  return `${date.getFullYear()}-${month}-${String(date.getDate()).padStart(2, "0")}`;
}

function streakDays(activityDays: Set<number>): number {
  const start = activityDays.has(0) ? 0 : activityDays.has(-1) ? -1 : null;
  if (start === null) return 0;
  let count = 0;
  while (activityDays.has(start - count)) count++;
  return count;
}

function focusLevel(graded: number, value: number | null): StudyFocusLevel | null {
  if (graded < FEW_PRACTICE_BELOW || value === null) return "few_practice";
  if (value < 50) return "high";
  if (value < 80) return "medium";
  return null;
}

// Same aggregation as supabase/functions/get-dashboard. Undefined for an unknown subject.
export function buildMockDashboard({
  period,
  subjectId,
}: DashboardFilters): DashboardData | undefined {
  if (subjectId && !getMockSubjectDetail(subjectId)) return undefined;

  const periodStart = -period + 1;
  const scoped = HISTORY.answers.filter((answer) => !subjectId || answer.subjectId === subjectId);
  const current = scoped.filter((answer) => answer.day >= periodStart);
  const previous = scoped.filter(
    (answer) => answer.day < periodStart && answer.day >= periodStart - period,
  );
  const now = tally(current);
  const before = tally(previous);
  const weekStart = -((new Date().getDay() + 6) % 7);

  const weekCount = Math.ceil(period / 7);
  const weeklyAccuracy = Array.from({ length: weekCount }, (_, index) => {
    const end = -(weekCount - 1 - index) * 7;
    const start = Math.max(end - 6, periodStart);
    const week = tally(current.filter((answer) => answer.day >= start && answer.day <= end));
    return {
      weekStart: isoDate(start),
      weekEnd: isoDate(end),
      answeredCount: week.answered,
      gradedCount: week.graded,
      correctCount: week.correct,
      percent: week.percent,
    };
  });

  const breakdownSources = subjectId
    ? MOCK_TOPICS.filter((topic) => topic.subjectId === subjectId).map((topic) => ({
        id: topic.id,
        name: topic.name,
        topicNumber: topic.number,
        answers: current.filter((answer) => answer.topicId === topic.id),
      }))
    : buildMockSubjects().map((subject) => ({
        id: subject.id,
        name: subject.name,
        answers: current.filter((answer) => answer.subjectId === subject.id),
      }));
  const breakdownItems: PreparationItem[] = breakdownSources
    .map(({ answers, ...item }) => {
      const stats = tally(answers);
      return {
        ...item,
        gradedCount: stats.graded,
        correctCount: stats.correct,
        percent: stats.percent ?? 0,
      };
    })
    .filter((item) => item.gradedCount > 0)
    .sort((a, b) => b.percent - a.percent || a.name.localeCompare(b.name));

  const focus = MOCK_TOPICS.filter((topic) => !subjectId || topic.subjectId === subjectId)
    .map((topic): StudyFocusTopic | null => {
      const answers = current.filter((answer) => answer.topicId === topic.id);
      const stats = tally(answers);
      const level = focusLevel(stats.graded, stats.percent);
      if (!level) return null;
      return {
        topicId: topic.id,
        topicName: topic.name,
        topicNumber: topic.number,
        subjectId: topic.subjectId,
        subjectShortLabel: topic.subjectShortLabel,
        percent: stats.percent,
        gradedCount: stats.graded,
        recentWrongCount: answers.filter(
          (answer) => answer.status === "incorrect" && answer.day > -RECENT_DAYS,
        ).length,
        level,
      };
    })
    .filter((topic): topic is StudyFocusTopic => topic !== null)
    .sort(
      (a, b) =>
        LEVEL_ORDER[a.level] - LEVEL_ORDER[b.level] ||
        b.recentWrongCount - a.recentWrongCount ||
        (a.percent ?? 0) - (b.percent ?? 0) ||
        a.topicName.localeCompare(b.topicName),
    );

  return {
    streakDays: streakDays(HISTORY.activityDays),
    preparation: { percent: now.percent, previousPercent: before.percent },
    questionsAnswered: { count: now.answered, previousCount: before.answered },
    weeklyGoal: {
      completed: HISTORY.answers.filter((answer) => answer.day >= weekStart).length,
      target: WEEKLY_GOAL_TARGET,
    },
    weeklyAccuracy,
    preparationBreakdown: { scope: subjectId ? "topic" : "subject", items: breakdownItems },
    studyFocus: { items: focus.slice(0, FOCUS_LIMIT), totalCount: focus.length },
  };
}

// GET /ranking/activity over the same history, so the calendar agrees with the dashboard. Each
// study day gets a fixed mix of simulados and exercise lists, derived from the day itself.
export function buildMockActivityCalendar(month: string): ActivityCalendar {
  const days = [...HISTORY.activityDays]
    .sort((a, b) => a - b)
    .map((day) => ({ day, date: isoDate(day) }))
    .filter(({ date }) => date.startsWith(`${month}-`))
    .map(({ day, date }) => ({
      date,
      examsCount: day % 3 === 0 ? 1 : 0,
      exercisesCount: day % 3 === 0 ? 0 : 1 + (Math.abs(day) % 2),
    }));

  return { month, days };
}
