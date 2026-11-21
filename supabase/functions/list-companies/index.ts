// GET list-companies: Company[] (docs/04-contratos-de-api.md §3.22, GET /companies). Ordered by
// name, each with its offices in display order. The same for every student.
import { sql } from "../_shared/db.ts";
import { serveEndpoint } from "../_shared/http.ts";

type CompanyRow = {
  id: number;
  name: string;
  category: "consulting" | "bank" | "other";
  work_model: "on_site" | "hybrid" | "remote";
  description: string;
};

type OfficeRow = {
  company_id: number;
  label: string | null;
  address: string;
};

serveEndpoint("GET", async () => {
  const [companies, offices] = await Promise.all([
    sql<CompanyRow[]>`
      select id, name, category, work_model, description
      from companies
      order by name
    `,
    sql<OfficeRow[]>`
      select company_id, label, address
      from company_offices
      order by company_id, order_index
    `,
  ]);

  return companies.map((company) => ({
    id: String(company.id),
    name: company.name,
    category: company.category,
    workModel: company.work_model,
    description: company.description,
    offices: offices
      .filter((office) => office.company_id === company.id)
      .map(({ label, address }) => (label === null ? { address } : { label, address })),
  }));
});
