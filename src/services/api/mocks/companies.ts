import type { Company } from "@models/companies";

// Fictional companies, one of each category and work model, so the filter and the "Ver trajeto"
// links have every case to show. Already ordered by name, like the edge function.
const COMPANIES: Company[] = [
  {
    id: "banco-horizonte",
    name: "Banco Horizonte",
    category: "bank",
    workModel: "hybrid",
    description: "Banco digital com times de tecnologia para pagamentos, crédito e dados.",
    offices: [
      { label: "Sede", address: "Av. Paulista, 1.000 – Bela Vista, São Paulo/SP" },
      { label: "Alphaville", address: "Alameda Rio Negro, 500 – Alphaville, Barueri/SP" },
    ],
  },
  {
    id: "nuvem-consultoria",
    name: "Nuvem Consultoria",
    category: "consulting",
    workModel: "remote",
    description: "Consultoria em computação em nuvem e automação de infraestrutura.",
    offices: [],
  },
  {
    id: "rede-conecta",
    name: "Rede Conecta",
    category: "other",
    workModel: "on_site",
    description: "Operadora de internet por fibra para empresas e condomínios.",
    offices: [{ address: "Rua Vergueiro, 2.000 – Vila Mariana, São Paulo/SP" }],
  },
  {
    id: "sigma-sistemas",
    name: "Sigma Sistemas",
    category: "consulting",
    workModel: "hybrid",
    description: "Fábrica de software com projetos de sistemas web e integrações.",
    offices: [{ address: "Av. Brigadeiro Faria Lima, 2.000 – Jardim Paulistano, São Paulo/SP" }],
  },
];

export function buildMockCompanies(): Company[] {
  return COMPANIES;
}
