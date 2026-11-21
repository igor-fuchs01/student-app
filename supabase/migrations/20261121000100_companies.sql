-- Student App — companies that gave a talk at the university and their offices
-- (docs/02-regras-de-negocio.md §12, docs/04-contratos-de-api.md GET /companies).
--
-- A company may have several offices, so they are rows of their own. A remote
-- company may have none; that rule spans both tables, so it is documented
-- instead of enforced. The student's home address is never stored: the route is
-- calculated by Google Maps, in the browser.

-- docs/04-contratos-de-api.md §3.22 Company.category
create type company_category as enum ('consulting', 'bank', 'other');

-- docs/04-contratos-de-api.md §3.22 Company.workModel
create type company_work_model as enum ('on_site', 'hybrid', 'remote');

create table companies (
  id          integer generated always as identity primary key,
  name        text not null check (btrim(name) <> ''),
  category    company_category not null,
  work_model  company_work_model not null,
  description text not null check (btrim(description) <> ''),
  constraint companies_name_key unique (name)
);

comment on table companies is 'Companies that gave a talk at the university (aba Empresas).';
comment on column companies.description is 'What the company does, in one or two sentences (Company.description).';

create table company_offices (
  id          integer generated always as identity primary key,
  company_id  integer not null references companies (id) on delete cascade,
  label       text check (btrim(label) <> ''),
  address     text not null check (btrim(address) <> ''),
  order_index integer not null,
  constraint company_offices_company_id_order_index_key unique (company_id, order_index)
);

comment on table company_offices is 'Office addresses of a company, in display order (Company.offices).';
comment on column company_offices.label is 'Which office it is (e.g. Alphaville); null when the company has a single office.';

alter table public.companies enable row level security;
alter table public.company_offices enable row level security;

create policy "signed-in students read companies"
  on public.companies for select to authenticated using (true);

create policy "signed-in students read company offices"
  on public.company_offices for select to authenticated using (true);
