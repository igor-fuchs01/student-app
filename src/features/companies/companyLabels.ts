import type { CompanyCategory, WorkModel } from "@models/companies";

export const CATEGORY_LABEL: Record<CompanyCategory, string> = {
  consulting: "Consultoria",
  bank: "Banco",
  other: "Outros",
};

export const WORK_MODEL_LABEL: Record<WorkModel, string> = {
  on_site: "Presencial",
  hybrid: "Híbrido",
  remote: "Remoto",
};
