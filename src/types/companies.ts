import { z } from "zod";

const companyCategorySchema = z.enum(["consulting", "bank", "other"]);

export type CompanyCategory = z.infer<typeof companyCategorySchema>;

const workModelSchema = z.enum(["on_site", "hybrid", "remote"]);

export type WorkModel = z.infer<typeof workModelSchema>;

const companyOfficeSchema = z.object({
  // Absent when the company has a single office.
  label: z.string().min(1).optional(),
  address: z.string().min(1),
});

export type CompanyOffice = z.infer<typeof companyOfficeSchema>;

export const companySchema = z.object({
  id: z.string().min(1),
  name: z.string().min(1),
  category: companyCategorySchema,
  workModel: workModelSchema,
  description: z.string().min(1),
  offices: z.array(companyOfficeSchema),
});

export type Company = z.infer<typeof companySchema>;

export const companiesResponseSchema = z.array(companySchema);
