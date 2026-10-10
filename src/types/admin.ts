import { z } from "zod";

const id = z.string().min(1);

export const adminUserSchema = z.object({ id });

export type AdminUser = z.infer<typeof adminUserSchema>;

// What every admin write answers with: the id of the row it created, updated or deleted.
export const adminSavedSchema = z.object({ id });

export type AdminSaved = z.infer<typeof adminSavedSchema>;

const adminMaterialSchema = z.object({
  id,
  title: z.string().min(1),
  fileUrl: z.string().min(1),
});

const adminSubtopicSchema = z.object({
  id,
  name: z.string().min(1),
  summary: z.string().min(1),
  keyPoints: z.array(z.string().min(1)),
  materials: z.array(adminMaterialSchema),
});

export type AdminSubtopic = z.infer<typeof adminSubtopicSchema>;

const adminTopicSchema = z.object({
  id,
  number: z.number().int().positive(),
  name: z.string().min(1),
  description: z.string().min(1),
  subtopics: z.array(adminSubtopicSchema),
});

export type AdminTopic = z.infer<typeof adminTopicSchema>;

const adminSubjectSchema = z.object({
  id,
  name: z.string().min(1),
  shortLabel: z.string().min(1),
  topics: z.array(adminTopicSchema),
});

export type AdminSubject = z.infer<typeof adminSubjectSchema>;

export const adminContentSchema = z.array(adminSubjectSchema);

export type AdminSubjectInput = { id?: string; name: string; shortLabel: string };

export type AdminTopicInput = {
  id?: string;
  subjectId: string;
  number: number;
  name: string;
  description: string;
};

export type AdminSubtopicInput = {
  id?: string;
  topicId: string;
  name: string;
  summary: string;
  keyPoints: string[];
  materials: { id?: string; title: string; fileUrl: string }[];
};

const questionTypeSchema = z.enum([
  "multiple_choice",
  "multiple_answer",
  "single_choice",
  "drag_and_drop",
  "essay",
  "essay_blanks",
]);

export type AdminQuestionType = z.infer<typeof questionTypeSchema>;

const adminOptionSchema = z.object({ text: z.string(), isCorrect: z.boolean() });

export type AdminOption = z.infer<typeof adminOptionSchema>;

// A question as the admin writes it: the answer key is part of each option, blank and slot,
// instead of the ids the student's Question carries.
const adminQuestionInputSchema = z.discriminatedUnion("type", [
  z.object({
    type: z.literal("multiple_choice"),
    prompt: z.string(),
    explanation: z.string(),
    options: z.array(adminOptionSchema),
  }),
  z.object({
    type: z.literal("multiple_answer"),
    prompt: z.string(),
    explanation: z.string(),
    options: z.array(adminOptionSchema),
  }),
  z.object({
    type: z.literal("single_choice"),
    template: z.string(),
    explanation: z.string(),
    blanks: z.array(z.object({ key: z.string(), options: z.array(adminOptionSchema) })),
  }),
  z.object({
    type: z.literal("drag_and_drop"),
    template: z.string(),
    explanation: z.string(),
    terms: z.array(z.string()),
    slots: z.array(z.object({ key: z.string(), correctTerm: z.string() })),
  }),
  z.object({
    type: z.literal("essay"),
    prompt: z.string(),
    maxLength: z.number().int().positive(),
    referenceAnswer: z.string(),
  }),
  z.object({
    type: z.literal("essay_blanks"),
    prompt: z.string(),
    template: z.string(),
    blanks: z.array(z.object({ key: z.string(), referenceAnswer: z.string() })),
  }),
]);

export type AdminQuestionInput = z.infer<typeof adminQuestionInputSchema>;

export type AdminQuestionSave = AdminQuestionInput & { id?: string; topicId: string };

export const adminQuestionSchema = z
  .object({ id, topicId: id, subjectId: id, answered: z.boolean() })
  .and(adminQuestionInputSchema);

export type AdminQuestion = z.infer<typeof adminQuestionSchema>;

const adminQuestionSummarySchema = z.object({
  id,
  type: questionTypeSchema,
  statement: z.string().min(1),
  topicId: id,
  topicNumber: z.number().int().positive(),
  topicName: z.string().min(1),
  subjectId: id,
  subjectName: z.string().min(1),
  quizCount: z.number().int().nonnegative(),
  answered: z.boolean(),
});

export type AdminQuestionSummary = z.infer<typeof adminQuestionSummarySchema>;

export const adminQuestionsSchema = z.array(adminQuestionSummarySchema);

export type AdminQuestionFilters = { subjectId?: string; topicId?: string };

const quizKindSchema = z.enum(["exam", "exercise"]);

export type AdminQuizKind = z.infer<typeof quizKindSchema>;

const adminQuizSummarySchema = z.object({
  id,
  title: z.string().min(1),
  kind: quizKindSchema,
  subjectId: id,
  subjectName: z.string().min(1),
  // Only an exercise list has an assunto, and only a simulado has a time limit.
  topicId: id.optional(),
  topicName: z.string().min(1).optional(),
  durationMinutes: z.number().int().positive().optional(),
  difficulty: z.enum(["easy", "medium", "hard"]),
  questionCount: z.number().int().nonnegative(),
  attemptsCount: z.number().int().nonnegative(),
});

export type AdminQuizSummary = z.infer<typeof adminQuizSummarySchema>;

export const adminQuizzesSchema = z.array(adminQuizSummarySchema);

export const adminQuizDetailSchema = adminQuizSummarySchema.extend({
  questions: z.array(adminQuestionSummarySchema),
});

export type AdminQuizDetail = z.infer<typeof adminQuizDetailSchema>;

export type AdminQuizInput = {
  id?: string;
  title: string;
  kind: AdminQuizKind;
  subjectId: string;
  topicId?: string;
  durationMinutes?: number;
  difficulty: AdminQuizSummary["difficulty"];
  questionIds: string[];
};
