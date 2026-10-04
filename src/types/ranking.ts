import { z } from "zod";

const rankingEntrySchema = z.object({
  position: z.number().int().positive(),
  studentId: z.string().min(1),
  streakDays: z.number().int().nonnegative(),
  isCurrentUser: z.boolean(),
});

export type RankingEntry = z.infer<typeof rankingEntrySchema>;

const rankingProfileSchema = z.object({
  streakDays: z.number().int().nonnegative(),
  weeklyGoalCompleted: z.number().int().nonnegative(),
  weeklyGoalTarget: z.number().int().positive(),
  questionsAnswered: z.number().int().nonnegative(),
  quizzesCompleted: z.number().int().nonnegative(),
});

export type RankingProfile = z.infer<typeof rankingProfileSchema>;

export const rankingDataSchema = z.object({
  profile: rankingProfileSchema,
  entries: z.array(rankingEntrySchema),
});

export type RankingData = z.infer<typeof rankingDataSchema>;

// "YYYY-MM", the month the activity calendar shows.
export const activityMonthSchema = z.string().regex(/^\d{4}-(0[1-9]|1[0-2])$/);

const activityDaySchema = z.object({
  date: z.iso.date(),
  examsCount: z.number().int().nonnegative(),
  exercisesCount: z.number().int().nonnegative(),
});

export type ActivityDay = z.infer<typeof activityDaySchema>;

export const activityCalendarSchema = z.object({
  month: activityMonthSchema,
  days: z.array(activityDaySchema),
});

export type ActivityCalendar = z.infer<typeof activityCalendarSchema>;
