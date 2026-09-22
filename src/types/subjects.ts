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

export const materialSchema = z.object({
  id: z.string().min(1),
  title: z.string().min(1),
  fileUrl: z.string().min(1),
});

export type Material = z.infer<typeof materialSchema>;

export const subtopicSchema = z.object({
  id: z.string().min(1),
  name: z.string().min(1),
  summary: z.string().min(1),
  keyPoints: z.array(z.string().min(1)),
  materials: z.array(materialSchema),
});

export type Subtopic = z.infer<typeof subtopicSchema>;

export const subjectTopicSchema = z.object({
  id: z.string().min(1),
  number: z.number().int().positive(),
  name: z.string().min(1),
  description: z.string().min(1),
  subtopics: z.array(subtopicSchema),
});

export type SubjectTopic = z.infer<typeof subjectTopicSchema>;

export const subjectDetailSchema = subjectSchema.extend({
  topics: z.array(subjectTopicSchema),
});

export type SubjectDetail = z.infer<typeof subjectDetailSchema>;
