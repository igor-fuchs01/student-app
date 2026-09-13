import { z } from "zod";

export const subjectSchema = z.object({
  id: z.string().min(1),
  name: z.string().min(1),
  shortLabel: z.string().min(1),
  materialsCount: z.number().int().nonnegative(),
  questionsCount: z.number().int().nonnegative(),
  preparationPercent: z.number().min(0).max(100),
});

export type Subject = z.infer<typeof subjectSchema>;

export const subjectsResponseSchema = z.array(subjectSchema);
