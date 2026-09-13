import { z } from "zod";

const priorityLevelSchema = z.enum(["high", "medium", "low"]);

export type PriorityLevel = z.infer<typeof priorityLevelSchema>;

const topicPrioritySchema = z.object({
  id: z.string().min(1),
  topicName: z.string(),
  level: priorityLevelSchema,
});

export type TopicPriority = z.infer<typeof topicPrioritySchema>;

const nextExamSchema = z.object({
  subjectName: z.string(),
  dateLabel: z.string(),
  note: z.string(),
  overallPreparation: z.number().min(0).max(100),
  priorities: z.array(topicPrioritySchema),
});

export type NextExam = z.infer<typeof nextExamSchema>;

const studyPlanItemSchema = z.object({
  id: z.string().min(1),
  label: z.string(),
  done: z.boolean(),
});

export type StudyPlanItem = z.infer<typeof studyPlanItemSchema>;

const dashboardSummaryCardSchema = z.object({
  id: z.enum(["subjects", "quizzes", "ranking"]),
  title: z.string(),
  value: z.string(),
  description: z.string(),
});

export type DashboardSummaryCard = z.infer<typeof dashboardSummaryCardSchema>;

export const dashboardDataSchema = z.object({
  streakDays: z.number().int().nonnegative(),
  nextExam: nextExamSchema,
  todayPlan: z.array(studyPlanItemSchema),
  summaryCards: z.array(dashboardSummaryCardSchema),
});

export type DashboardData = z.infer<typeof dashboardDataSchema>;
