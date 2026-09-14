import { z } from "zod";

const rankingEntrySchema = z.object({
  position: z.number().int().positive(),
  studentId: z.string().min(1),
  studentName: z.string().min(1),
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
