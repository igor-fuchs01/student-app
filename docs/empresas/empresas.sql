-- Empresas que deram palestra na universidade e seus escritórios (aba Empresas).
-- Tabelas companies e company_offices, da migration 20261121000100_companies.
--
-- Rode no SQL Editor do Supabase depois de aplicar a migration. Rodar de novo não duplica nada:
-- uma empresa que já existe (pelo nome) é ignorada, e só ganha escritórios a que ainda não tem
-- nenhum. Para corrigir os dados de uma empresa já cadastrada, use UPDATE.
--
-- Endereços ainda a confirmar (não aparecem na tela como tal):
--   * Octea (antiga VIA\W + 4MapIT) e V8.Tech: endereço de fonte secundária.
--   * Stefanini: escritório do Itaim/Vila Olímpia não confirmado.
--   * ACS PRO: o nome "ACPro" da lista provavelmente é a ACS PRO; não tem escritório em São Paulo.
--   * Deloitte: também há escritórios em Campinas e Ribeirão Preto, sem endereço levantado.
--   * Indra: há uma fábrica de software em Campinas/SP, sem endereço; na capital não foi localizado.
--   * Evertec Brasil: não se sabe qual dos dois endereços está em uso hoje.
--   * Accenture: outra fonte indica o CEP 04730-090 (o mesmo prédio da Avanade); há também
--     escritórios em Alphaville/Barueri e Ribeirão Preto, sem endereço levantado.
--   * Junto Seguros: tem escritório em São Paulo, mas o endereço não foi localizado.

BEGIN;

INSERT INTO companies (name, category, work_model, description)
VALUES
  ('Octea', 'consulting', 'hybrid',
   'Hub de eficiência para gestão e auditoria de contratos, ativos e custos de TI e telecom, incluindo FinOps, combinando plataforma e especialistas.'),
  ('V8.Tech', 'consulting', 'hybrid',
   'Integradora de TI do grupo TIM, focada em transformação digital: nuvem e FinOps, inteligência artificial, cibersegurança e serviços gerenciados.'),
  ('Stefanini', 'consulting', 'hybrid',
   'Grupo global de tecnologia fundado em 1987: serviços de TI, automação, nuvem, inteligência artificial, outsourcing e transformação digital.'),
  ('ACS PRO', 'consulting', 'remote',
   'Consultoria de TI e revenda autorizada ManageEngine/Zoho: gestão de TI, segurança e automação.'),
  ('Deloitte', 'consulting', 'hybrid',
   'Auditoria, consultoria, tributário, gestão de riscos e assessoria financeira; no Brasil desde 1911.'),
  ('Avanade', 'consulting', 'hybrid',
   'Consultoria no ecossistema Microsoft (nuvem, inteligência artificial, dados e sustentabilidade); joint venture entre Microsoft e Accenture.'),
  ('Vivo (Telefônica Brasil)', 'other', 'hybrid',
   'Maior operadora de telecomunicações do Brasil: telefonia móvel, fibra, TV e soluções corporativas e de TI.'),
  ('Indra (Minsait Brasil)', 'consulting', 'hybrid',
   'Grupo espanhol de tecnologia e defesa, no Brasil desde 1996; a unidade Minsait atua em transformação digital, consultoria de TI e cibersegurança.'),
  ('Think Digital', 'other', 'on_site',
   'Soluções de conectividade para empresas: infraestrutura de rede, Wi-Fi inteligente, inteligência de dados, IoT, antifraude e cibersegurança, além de análise de vídeo.'),
  ('Buildbox', 'consulting', 'hybrid',
   'Empresa de software corporativo: engenharia e inteligência artificial em todo o ciclo de desenvolvimento, com origem em QA e testes.'),
  ('Smart Fit', 'other', 'on_site',
   'Maior rede de academias da América Latina (Smart Fit, Bio Ritmo e Nation), iniciada em 2009.'),
  ('Núclea (ex-CIP)', 'consulting', 'hybrid',
   'Infraestrutura do mercado financeiro: processamento de transações, registro de recebíveis e inteligência de dados; processa cerca de R$ 18 trilhões por ano.'),
  ('EY (Ernst & Young)', 'consulting', 'hybrid',
   'Auditoria, consultoria, tributário e estratégia (EY-Parthenon).'),
  ('PwC', 'consulting', 'hybrid',
   'Auditoria, consultoria tributária e de negócios; cerca de 4.300 profissionais em 19 escritórios no Brasil.'),
  ('Evertec Brasil (ex-Sinqia)', 'consulting', 'hybrid',
   'A fintech porto-riquenha Evertec atua no Brasil com software para o mercado financeiro e meios de pagamento, após absorver a Sinqia (nova marca em março de 2026); mais de mil colaboradores no país.'),
  ('Vocare', 'consulting', 'hybrid',
   'Consultoria de inovação, inteligência artificial e desenvolvimento sob medida: gestão de back-office com Odoo, desenho de processos de vendas e CRM, projetos e capacitação em IA, agentes de IA e automação, aplicações web e integrações de dados.'),
  ('Accenture', 'consulting', 'hybrid',
   'Consultoria global em estratégia, tecnologia e operações.'),
  ('Junto Seguros', 'other', 'hybrid',
   'Seguradora digital especializada em Seguro Garantia, Fiança Locatícia e D&O, antiga JMalucelli Seguradora; passou de R$ 1 bilhão em prêmios de Seguro Garantia em 2025.')
ON CONFLICT (name) DO NOTHING;

-- label NULL: a empresa tem um escritório só.
INSERT INTO company_offices (company_id, label, address, order_index)
SELECT c.id, o.label, o.address, o.order_index
FROM (VALUES
  ('Octea', NULL, 'Av. Nove de Julho, 4.877 – São Paulo/SP', 1),
  ('V8.Tech', NULL, 'Av. Roque Petroni Júnior, 850, Torre Jaceru, 3º andar – Vila Gertrudes, São Paulo/SP', 1),
  ('Stefanini', 'Pinheiros', 'Av. Eusébio Matoso, 1.375 – Pinheiros, São Paulo/SP, CEP 05423-905', 1),
  ('Stefanini', 'Sede histórica', 'Av. Marginal, 156 – Jaguariúna/SP, CEP 13820-000', 2),
  ('ACS PRO', 'Endereço registrado em Goiânia/GO', 'Rua C-244, nº 227, Qd. 573 Lt. 20, Box 11 – Nova Suíça, Goiânia/GO, CEP 74280-145', 1),
  ('Deloitte', NULL, 'Av. Dr. Chucri Zaidan, 1.240, Golden Tower, 4º ao 12º andar – São Paulo/SP, CEP 04711-130', 1),
  ('Avanade', 'São Paulo', 'Av. das Nações Unidas, 14.401, Torre Paineira (B2), 11º andar – Chácara Santo Antônio, São Paulo/SP, CEP 04730-090', 1),
  ('Avanade', 'Alphaville', 'Rua Bonnard, 980, Bloco 10, Nível 6 – Barueri/SP, CEP 06465-134', 2),
  ('Vivo (Telefônica Brasil)', NULL, 'Av. Engenheiro Luís Carlos Berrini, 1.376 – Cidade Monções, São Paulo/SP, CEP 04571-936', 1),
  ('Indra (Minsait Brasil)', 'Sede no Brasil', 'Alameda Mamoré, 687, 16º andar – Alphaville, Barueri/SP, CEP 06454-040', 1),
  ('Think Digital', NULL, 'Rua Tamoios, 246 – Jardim Aeroporto, São Paulo/SP, CEP 04630-000', 1),
  ('Buildbox', 'Local de trabalho (híbrido)', 'Centro Empresarial Itaquiti – Av. Prefeito João Villalobo Quero, 1505 – Jardim Itaquiti, Barueri/SP', 1),
  ('Buildbox', 'Escritório da empresa', 'Av. Selma Parada, 201 – Jardim Madalena, Campinas/SP, CEP 13091-904', 2),
  ('Smart Fit', 'Sede', 'Av. Paulista, 1.294, 2º andar – Bela Vista, São Paulo/SP, CEP 01310-100', 1),
  ('Núclea (ex-CIP)', NULL, 'Av. Brigadeiro Faria Lima, 1.485, Torre Norte, 9º andar – Jardim Paulistano, São Paulo/SP, CEP 01452-002', 1),
  ('EY (Ernst & Young)', 'São Paulo', 'São Paulo Corporate Towers, Av. Pres. Juscelino Kubitschek, 1.909, Torre Norte, 6º ao 9º andar – Itaim Bibi, São Paulo/SP, CEP 04543-011', 1),
  ('EY (Ernst & Young)', 'Campinas', 'Trade Tower, Av. José de Souza Campos, 900, 1º andar – Campinas/SP, CEP 13092-123', 2),
  ('EY (Ernst & Young)', 'Ribeirão Preto', 'Iguatemi Business, Av. Luiz Eduardo Toledo Prado, 900, torre 2 – Ribeirão Preto/SP, CEP 14027-250', 3),
  ('PwC', 'São Paulo', 'Av. Brigadeiro Faria Lima, 3.732, Ed. Adalmiro Dellape Baptista B32, 16º e 17º andar – São Paulo/SP, CEP 04538-132', 1),
  ('PwC', 'Barueri', 'Av. Marcos Penteado de Ulhôa Rodrigues, 939, Castelo Branco Office Park, Torre Jatobá, 12º andar – Barueri/SP, CEP 06460-040', 2),
  ('PwC', 'São José dos Campos', 'Colinas Green Tower, 17º andar, cj. 1703 – São José dos Campos/SP, CEP 12242-000', 3),
  ('Evertec Brasil (ex-Sinqia)', 'Sede da Sinqia', 'Rua Bela Cintra, 755, 7º andar – Consolação, São Paulo/SP, CEP 01415-003', 1),
  ('Evertec Brasil (ex-Sinqia)', 'Evertec BR', 'Alameda Lorena, 638, 3º andar, cj. 31 e 32 – Jardim Paulista, São Paulo/SP, CEP 01424-002', 2),
  ('Vocare', 'Local de trabalho (híbrido)', 'Centro Empresarial Itaquiti – Av. Prefeito João Villalobo Quero, 1505 – Jardim Itaquiti, Barueri/SP', 1),
  ('Accenture', NULL, 'Parque da Cidade, Av. das Nações Unidas, 14.401, Torre Paineira, 11º ao 13º andar – Chácara Santo Antônio, São Paulo/SP, CEP 04794-000', 1),
  ('Junto Seguros', 'Sede em Curitiba/PR', 'Av. Dr. Dário Lopes dos Santos, 2.197, 3º andar, Torre C – Jardim Botânico, Curitiba/PR, CEP 80210-010', 1)
) AS o (company, label, address, order_index)
JOIN companies c ON c.name = o.company
WHERE NOT EXISTS (SELECT 1 FROM company_offices existing WHERE existing.company_id = c.id);

-- Conferência: 18 empresas e 26 escritórios.
SELECT
  (SELECT count(*) FROM companies) AS empresas,
  (SELECT count(*) FROM company_offices) AS escritorios;

COMMIT;
