import { z } from "zod";

export const DASHBOARD_PERIODS = [30, 90, 180] as const;

export const dashboardPeriodSchema = z.union([z.literal(30), z.literal(90), z.literal(180)]);

export type DashboardPeriod = z.infer<typeof dashboardPeriodSchema>;

export type DashboardFilters = {
  period: DashboardPeriod;
  subjectId?: string;
};

const percentSchema = z.number().min(0).max(100);
const countSchema = z.number().int().nonnegative();

const weeklyAccuracySchema = z.object({
  weekStart: z.iso.date(),
  weekEnd: z.iso.date(),
  answeredCount: countSchema,
  gradedCount: countSchema,
  correctCount: countSchema,
  percent: percentSchema.nullable(),
});

export type WeeklyAccuracy = z.infer<typeof weeklyAccuracySchema>;

const preparationItemSchema = z.object({
  id: z.string().min(1),
  name: z.string().min(1),
  topicNumber: z.number().int().positive().optional(),
  gradedCount: countSchema,
  correctCount: countSchema,
  percent: percentSchema,
});

export type PreparationItem = z.infer<typeof preparationItemSchema>;

const studyFocusLevelSchema = z.enum(["high", "medium", "few_practice"]);

export type StudyFocusLevel = z.infer<typeof studyFocusLevelSchema>;

const studyFocusTopicSchema = z.object({
  topicId: z.string().min(1),
  topicName: z.string().min(1),
  topicNumber: z.number().int().positive(),
  subjectId: z.string().min(1),
  subjectShortLabel: z.string().min(1),
  percent: percentSchema.nullable(),
  gradedCount: countSchema,
  recentWrongCount: countSchema,
  level: studyFocusLevelSchema,
});

export type StudyFocusTopic = z.infer<typeof studyFocusTopicSchema>;

export const dashboardDataSchema = z.object({
  streakDays: countSchema,
  preparation: z.object({
    percent: percentSchema.nullable(),
    previousPercent: percentSchema.nullable(),
  }),
  questionsAnswered: z.object({
    count: countSchema,
    previousCount: countSchema,
  }),
  weeklyGoal: z.object({
    completed: countSchema,
    target: z.number().int().positive(),
  }),
  weeklyAccuracy: z.array(weeklyAccuracySchema),
  preparationBreakdown: z.object({
    scope: z.enum(["subject", "topic"]),
    items: z.array(preparationItemSchema),
  }),
  studyFocus: z.object({
    items: z.array(studyFocusTopicSchema).max(5),
    totalCount: countSchema,
  }),
});

export type DashboardData = z.infer<typeof dashboardDataSchema>;
