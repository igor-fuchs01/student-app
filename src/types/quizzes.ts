import { z } from "zod";

const difficultySchema = z.enum(["easy", "medium", "hard"]);

export type QuizDifficulty = z.infer<typeof difficultySchema>;

export const quizSummarySchema = z.object({
  id: z.string().min(1),
  title: z.string().min(1),
  subjectScope: z.enum(["single", "all"]),
  subjectName: z.string().optional(),
  questionCount: z.number().int().positive(),
  durationMinutes: z.number().int().positive(),
  attemptsRemaining: z.number().int().nonnegative(),
  difficulty: difficultySchema,
});

export type QuizSummary = z.infer<typeof quizSummarySchema>;

export const quizzesResponseSchema = z.array(quizSummarySchema);

const questionOptionSchema = z.object({
  id: z.string().min(1),
  text: z.string().min(1),
});

export type QuestionOption = z.infer<typeof questionOptionSchema>;

const multipleChoiceQuestionSchema = z.object({
  type: z.literal("multiple_choice"),
  id: z.string().min(1),
  subjectName: z.string().min(1),
  prompt: z.string().min(1),
  options: z.array(questionOptionSchema).min(2),
  correctOptionId: z.string().min(1),
  explanation: z.string().min(1),
});

const multipleAnswerQuestionSchema = z.object({
  type: z.literal("multiple_answer"),
  id: z.string().min(1),
  subjectName: z.string().min(1),
  prompt: z.string().min(1),
  options: z.array(questionOptionSchema).min(2),
  correctOptionIds: z.array(z.string().min(1)).min(1),
  explanation: z.string().min(1),
});

const blankSchema = z.object({
  id: z.string().min(1),
  options: z.array(questionOptionSchema).min(2),
  correctOptionId: z.string().min(1),
});

export type Blank = z.infer<typeof blankSchema>;

const singleChoiceQuestionSchema = z.object({
  type: z.literal("single_choice"),
  id: z.string().min(1),
  subjectName: z.string().min(1),
  template: z.string().min(1),
  blanks: z.array(blankSchema).min(1),
  explanation: z.string().min(1),
});

const dragDropTermSchema = z.object({
  id: z.string().min(1),
  text: z.string().min(1),
});

export type DragDropTerm = z.infer<typeof dragDropTermSchema>;

const dragDropSlotSchema = z.object({
  id: z.string().min(1),
  correctTermId: z.string().min(1),
});

export type DragDropSlot = z.infer<typeof dragDropSlotSchema>;

const dragAndDropQuestionSchema = z.object({
  type: z.literal("drag_and_drop"),
  id: z.string().min(1),
  subjectName: z.string().min(1),
  template: z.string().min(1),
  terms: z.array(dragDropTermSchema).min(2),
  slots: z.array(dragDropSlotSchema).min(1),
  explanation: z.string().min(1),
});

const essayQuestionSchema = z.object({
  type: z.literal("essay"),
  id: z.string().min(1),
  subjectName: z.string().min(1),
  prompt: z.string().min(1),
  maxLength: z.number().int().positive(),
  referenceAnswer: z.string().min(1),
});

const essayBlankSchema = z.object({
  id: z.string().min(1),
  referenceAnswer: z.string().min(1),
});

export type EssayBlank = z.infer<typeof essayBlankSchema>;

const essayBlanksQuestionSchema = z.object({
  type: z.literal("essay_blanks"),
  id: z.string().min(1),
  subjectName: z.string().min(1),
  prompt: z.string().min(1),
  template: z.string().min(1),
  blanks: z.array(essayBlankSchema).min(1),
});

export const questionSchema = z.discriminatedUnion("type", [
  multipleChoiceQuestionSchema,
  multipleAnswerQuestionSchema,
  singleChoiceQuestionSchema,
  dragAndDropQuestionSchema,
  essayQuestionSchema,
  essayBlanksQuestionSchema,
]);

export type Question = z.infer<typeof questionSchema>;
export type MultipleChoiceQuestion = z.infer<typeof multipleChoiceQuestionSchema>;
export type MultipleAnswerQuestion = z.infer<typeof multipleAnswerQuestionSchema>;
export type SingleChoiceQuestion = z.infer<typeof singleChoiceQuestionSchema>;
export type DragAndDropQuestion = z.infer<typeof dragAndDropQuestionSchema>;
export type EssayQuestion = z.infer<typeof essayQuestionSchema>;
export type EssayBlanksQuestion = z.infer<typeof essayBlanksQuestionSchema>;

export const quizDetailSchema = z.object({
  id: z.string().min(1),
  title: z.string().min(1),
  durationMinutes: z.number().int().positive(),
  questions: z.array(questionSchema).min(1),
});

export type QuizDetail = z.infer<typeof quizDetailSchema>;

export const quizAnswerSchema = z.object({
  questionId: z.string().min(1),
  optionId: z.string().optional(),
  optionIds: z.array(z.string()).optional(),
  text: z.string().optional(),
  blankAnswers: z.record(z.string(), z.string()).optional(),
  slotAnswers: z.record(z.string(), z.string()).optional(),
});

export type QuizAnswer = z.infer<typeof quizAnswerSchema>;

export const submitQuizAttemptSchema = z.object({
  answers: z.array(quizAnswerSchema),
});

export type SubmitQuizAttempt = z.infer<typeof submitQuizAttemptSchema>;

const reviewItemSchema = z.object({
  questionId: z.string().min(1),
  subjectName: z.string().min(1),
  promptExcerpt: z.string().min(1),
  status: z.enum(["incorrect", "self_review"]),
  explanation: z.string().optional(),
  studentAnswer: z.string().optional(),
  referenceAnswer: z.string().optional(),
});

export type QuizReviewItem = z.infer<typeof reviewItemSchema>;

const subjectPerformanceSchema = z.object({
  subjectName: z.string().min(1),
  percent: z.number().min(0).max(100),
});

export type QuizSubjectPerformance = z.infer<typeof subjectPerformanceSchema>;

export const quizResultSchema = z.object({
  quizId: z.string().min(1),
  submittedAt: z.string().min(1),
  correctCount: z.number().int().nonnegative(),
  incorrectCount: z.number().int().nonnegative(),
  unansweredCount: z.number().int().nonnegative(),
  selfReviewCount: z.number().int().nonnegative(),
  scorePercent: z.number().min(0).max(100),
  subjectPerformance: z.array(subjectPerformanceSchema),
  reviewItems: z.array(reviewItemSchema),
});

export type QuizResult = z.infer<typeof quizResultSchema>;

export const storedQuizAttemptSchema = z.object({
  quiz: quizDetailSchema,
  answers: z.array(quizAnswerSchema),
  result: quizResultSchema,
});

export type StoredQuizAttempt = z.infer<typeof storedQuizAttemptSchema>;
