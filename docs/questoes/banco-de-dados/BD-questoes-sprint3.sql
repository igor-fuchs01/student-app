-- Banco de Dados — conteúdo da Sprint 3: funções do MySQL (numéricas, texto, data, nulos e
-- condicionais), agregação com GROUP BY e HAVING, subqueries (conteúdo complementar), views e
-- relacionamento N:M. Cadastra a aula, os subassuntos com pontos-chave, as 3 listas de exercícios
-- e as 45 questões; o simulado é criado por BD-simulado-sprint3.sql.
-- Aula: "Funções, GROUP BY, Subqueries, Views e Relacionamento N:M".
-- Questões, gabaritos e explicações: BD-questoes-sprint3.md (as queries foram executadas no MySQL 8).
-- O número da aula não é fixo: o script usa o próximo número livre de Banco de Dados e o mostra
-- em um NOTICE. A aula é localizada pelo nome, que é único dentro da disciplina.
-- Distribuição: 18 multiple_choice, 9 multiple_answer, 6 single_choice e 12 drag_and_drop;
-- 9 fáceis e 6 médias (Exercícios 1), 15 difíceis (Exercícios 2) e 15 super difíceis (Exercícios 3);
-- 38 questões de comparação de queries.
-- Uma única transação: se qualquer comando falhar, nada é gravado.

BEGIN;

-- 1. Disciplina
INSERT INTO subjects (name, short_label)
SELECT 'Banco de Dados', 'BD'
WHERE NOT EXISTS (SELECT 1 FROM subjects WHERE name = 'Banco de Dados');

-- 2. Trava: aborta se a aula ou alguma das listas já estiver cadastrada
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM topics t JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  ) THEN
    RAISE EXCEPTION 'A aula "Funções, GROUP BY, Subqueries, Views e Relacionamento N:M" de Banco de Dados já está cadastrada';
  END IF;

  IF EXISTS (
    SELECT 1 FROM quizzes WHERE title IN ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos', 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação', 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio')
  ) THEN
    RAISE EXCEPTION 'Já existe uma lista de exercícios com o título de uma das listas desta aula';
  END IF;
END $$;

-- 3. Assunto, com o próximo número de aula livre da disciplina
INSERT INTO topics (subject_id, number, name, description)
SELECT s.id,
  (SELECT COALESCE(MAX(t.number), 0) + 1 FROM topics t WHERE t.subject_id = s.id),
  'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M',
  'Funções de linha e de agregação do MySQL, GROUP BY e HAVING, subqueries, views e relacionamento N:M com tabela associativa, cobrados pela comparação de consultas.'
FROM subjects s
WHERE s.name = 'Banco de Dados';

DO $$
DECLARE
  lesson integer;
BEGIN
  SELECT t.number INTO lesson
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M';
  RAISE NOTICE 'Aula cadastrada com o número %', lesson;
END $$;

-- 4. Subassuntos
INSERT INTO subtopics (topic_id, name, summary, order_index)
SELECT t.id, v.name, v.summary, v.order_index
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Funções numéricas, de texto e de data', 'Funções de linha transformam o valor de cada linha: arredondamento (CEIL, FLOOR, ROUND, TRUNCATE), cálculo (SQRT, POWER, MOD), texto (TRIM, SUBSTRING, LOCATE, CONCAT) e data (WEEKDAY, DATEDIFF, DATE_FORMAT).', 1),
  ('Tratamento de nulos e condicionais', 'NULL é ausência de valor: qualquer conta ou CONCAT com ele dá NULL. IFNULL, COALESCE e NULLIF tratam o nulo, e CASE escolhe um valor pela primeira condição verdadeira.', 2),
  ('Agregação, GROUP BY e HAVING', 'Funções de agregação resumem várias linhas. GROUP BY aplica a agregação em cada grupo, e HAVING filtra os grupos depois de formados.', 3),
  ('Subqueries e comparação com JOIN', 'Conteúdo complementar: uma subquery é um SELECT dentro de outro, no WHERE, no FROM ou no SELECT. Muitas consultas podem ser escritas com JOIN ou com subquery, mas nem sempre dão o mesmo resultado.', 4),
  ('Views', 'View é uma consulta salva usada como tabela virtual: ela guarda o SELECT, não uma cópia dos dados, e é criada, alterada e apagada com CREATE, ALTER e DROP VIEW.', 5),
  ('Relacionamento N:M e tabela associativa', 'Quando um aluno faz vários cursos e um curso tem vários alunos, o relacionamento é N:M e vira uma tabela associativa com as duas chaves estrangeiras.', 6)
) AS v(name, summary, order_index)
WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M';

-- 5. Pontos-chave
INSERT INTO subtopic_key_points (subtopic_id, text, order_index)
SELECT st.id, v.text, v.order_index
FROM subtopics st
JOIN topics t ON t.id = st.topic_id
JOIN subjects s ON s.id = t.subject_id
JOIN (VALUES
  ('Funções numéricas, de texto e de data', 'CEIL sobe, FLOOR desce, ROUND vai ao mais próximo e TRUNCATE corta: FLOOR(-4.7) é -5 e CEIL(-4.7) é -4.', 1),
  ('Funções numéricas, de texto e de data', 'TRUNCATE(7333.338888, 2) dá 7333.33, enquanto ROUND(7333.338888, 2) dá 7333.34.', 2),
  ('Funções numéricas, de texto e de data', 'SUBSTRING começa na posição 1, e LOCATE devolve 0 quando não acha o trecho.', 3),
  ('Funções numéricas, de texto e de data', 'WEEKDAY conta 0 na segunda e DAYOFWEEK conta 1 no domingo; em DATE_FORMAT, %m é o mês e %i são os minutos.', 4),
  ('Tratamento de nulos e condicionais', 'Teste nulos com IS NULL ou IS NOT NULL, nunca com = NULL.', 1),
  ('Tratamento de nulos e condicionais', 'IFNULL aceita 2 argumentos; COALESCE aceita vários e devolve o primeiro não nulo.', 2),
  ('Tratamento de nulos e condicionais', 'NULLIF(x, 0) devolve NULL quando x é 0 e evita a divisão por zero.', 3),
  ('Tratamento de nulos e condicionais', 'COUNT(coluna) e AVG(coluna) ignoram nulos: AVG(desconto) é diferente de AVG(IFNULL(desconto, 0)).', 4),
  ('Tratamento de nulos e condicionais', 'CASE testa os WHEN na ordem e para no primeiro verdadeiro; o ELSE cobre o resto.', 5),
  ('Agregação, GROUP BY e HAVING', 'COUNT(*) conta linhas, COUNT(coluna) ignora nulos e COUNT(DISTINCT coluna) não repete valores.', 1),
  ('Agregação, GROUP BY e HAVING', 'Toda coluna do SELECT fica no GROUP BY ou dentro de uma agregação; senão o MySQL 8 dá o erro 1055.', 2),
  ('Agregação, GROUP BY e HAVING', 'O GROUP BY cria um grupo próprio para o NULL.', 3),
  ('Agregação, GROUP BY e HAVING', 'WHERE filtra linhas antes de agrupar e HAVING filtra grupos depois; agregação no WHERE dá o erro 1111.', 4),
  ('Agregação, GROUP BY e HAVING', 'Ordem de execução: FROM e JOIN, WHERE, GROUP BY, HAVING, SELECT, ORDER BY e LIMIT.', 5),
  ('Subqueries e comparação com JOIN', 'Subquery escalar: WHERE preco > (SELECT AVG(preco) FROM produto).', 1),
  ('Subqueries e comparação com JOIN', 'NOT IN com uma subquery que devolve NULL não devolve nenhuma linha; NOT EXISTS e LEFT JOIN ... IS NULL não têm esse problema.', 2),
  ('Subqueries e comparação com JOIN', 'Subquery no FROM é uma tabela derivada e exige alias no MySQL (erro 1248).', 3),
  ('Subqueries e comparação com JOIN', 'Subquery correlacionada usa uma coluna da consulta externa e roda para cada linha dela.', 4),
  ('Subqueries e comparação com JOIN', 'JOIN repete a linha para cada correspondência; IN e EXISTS devolvem cada linha uma vez.', 5),
  ('Views', 'CREATE VIEW nome AS SELECT ...; ALTER VIEW nome AS SELECT ...; DROP VIEW nome;', 1),
  ('Views', 'A view não aceita nomes de coluna repetidos: use alias.', 2),
  ('Views', 'View com GROUP BY não aceita UPDATE nem DELETE (erro 1288).', 3),
  ('Views', 'Na criação, nunca use CREATE OR REPLACE: ele sobrepõe sem aviso uma view que já existe.', 4),
  ('Relacionamento N:M e tabela associativa', 'A tabela associativa (matricula) tem fk_ra e fk_curso, que juntas formam a chave primária composta.', 1),
  ('Relacionamento N:M e tabela associativa', 'Uma FK só em aluno ou só em curso limita um dos lados a um vínculo.', 2),
  ('Relacionamento N:M e tabela associativa', 'Atributos do vínculo, como data de início e nível, ficam na tabela associativa.', 3),
  ('Relacionamento N:M e tabela associativa', 'Um N:M vira duas relações 1:N no modelo lógico.', 4)
) AS v(subtopic_name, text, order_index) ON v.subtopic_name = st.name
WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M';

-- 6. Listas de exercícios
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT v.title, 'exercise', t.subject_id, t.id, NULL, v.difficulty::difficulty_level
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos', 'easy'),
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação', 'medium'),
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio', 'hard')
) AS v(title, difficulty)
WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M';

-- 7. Questões: cada uma é um comando, com o comentário "número | tipo | dificuldade | subassunto |
-- lista | resposta". O CTE "l" põe a questão no fim da sua lista.

-- Q1 | multiple_choice | fácil | Funções numéricas, de texto e de data | Exercícios 1 | correta: C | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Um relatório de ajuste de estoque precisa tratar valores negativos. Query A: SELECT CEIL(-4.7), FLOOR(-4.7); Query B: SELECT ROUND(-4.7), TRUNCATE(-4.7, 0); Quais valores cada query devolve, na ordem das colunas?',
    'CEIL sobe em direção ao mais infinito (-4) e FLOOR desce em direção ao menos infinito (-5). ROUND vai para o inteiro mais próximo (-5) e TRUNCATE só corta as casas, andando em direção ao zero (-4).'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A: -5 e -4; B: -5 e -4', false, 1),
  ('A: -4 e -5; B: -4 e -5', false, 2),
  ('A: -4 e -5; B: -5 e -4', true, 3),
  ('A: -5 e -4; B: -4 e -5', false, 4),
  ('A: -4 e -4; B: -5 e -5', false, 5)
) AS o(text, is_correct, order_index);

-- Q2 | single_choice | fácil | Tratamento de nulos e condicionais | Exercícios 1 | b1: 20, b2: 11, b3: 20 | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice',
    'A tabela item do banco vendas_funcoes tem 20 linhas, e só 11 delas têm desconto preenchido (as outras 9 são NULL). SELECT COUNT(*) FROM item; devolve {{b1}}, SELECT COUNT(desconto) FROM item; devolve {{b2}} e AVG(IFNULL(desconto, 0)) divide a soma dos descontos por {{b3}}.',
    'COUNT(*) conta todas as linhas, e COUNT(coluna) ignora os nulos. Com IFNULL(desconto, 0) os nulos viram 0 e entram na conta, então a média passa a usar as 20 linhas.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', '20', true, 1),
  ('b1', '11', false, 2),
  ('b1', '9', false, 3),
  ('b2', '20', false, 1),
  ('b2', '11', true, 2),
  ('b2', '9', false, 3),
  ('b3', '11', false, 1),
  ('b3', '20', true, 2),
  ('b3', '9', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q3 | drag_and_drop | fácil | Funções numéricas, de texto e de data | Exercícios 1 | s1: 7333.34, s2: 7333.33, s3: 5, s4: 1
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'Associe cada expressão ao valor que ela devolve no MySQL: ROUND(7333.338888, 2) devolve {{s1}}; TRUNCATE(7333.338888, 2) devolve {{s2}}; CEIL(4.1) devolve {{s3}}; MOD(11, 5) devolve {{s4}}.',
    'ROUND arredonda olhando a terceira casa (8, então sobe) e TRUNCATE só corta. CEIL sempre sobe para o próximo inteiro, mesmo com 4.1, e MOD devolve o resto da divisão de 11 por 5.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('4', 1),
    ('7333.34', 2),
    ('1', 3),
    ('7333.3', 4),
    ('5', 5),
    ('7333.33', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', '7333.34', 1),
  ('s2', '7333.33', 2),
  ('s3', '5', 3),
  ('s4', '1', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q4 | multiple_choice | fácil | Agregação, GROUP BY e HAVING | Exercícios 1 | correta: A | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Na tabela venda (idVenda, dataHora, vendedor), Ana Souza tem 5 vendas, Bruno Lima 3, Carla Mendes 2 e Diego Rocha 2. Qual query lista os vendedores com mais de duas vendas?',
    'A contagem só existe depois do GROUP BY, então o filtro de grupo vai no HAVING. COUNT(*) no WHERE dá o erro 1111, e sem GROUP BY o MySQL 8 recusa misturar vendedor com COUNT(*).'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT vendedor, COUNT(*) FROM venda GROUP BY vendedor HAVING COUNT(*) > 2;', true, 1),
  ('SELECT vendedor, COUNT(*) FROM venda WHERE COUNT(*) > 2 GROUP BY vendedor;', false, 2),
  ('SELECT vendedor, COUNT(*) FROM venda GROUP BY vendedor HAVING vendedor > 2;', false, 3),
  ('SELECT vendedor, COUNT(*) FROM venda WHERE idVenda > 2 GROUP BY vendedor;', false, 4),
  ('SELECT vendedor, COUNT(*) FROM venda HAVING COUNT(*) > 2;', false, 5)
) AS o(text, is_correct, order_index);

-- Q5 | multiple_answer | fácil | Views | Exercícios 1 | corretas: A, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer',
    'Uma equipe vai criar views para o relatório de aeroportos. Sobre views no MySQL, assinale todas as corretas.',
    'A view é uma consulta salva usada como tabela virtual e não aceita nomes de coluna repetidos, por isso o alias. UPDATE e DELETE só valem para views sem GROUP BY, o material proíbe REPLACE na criação e DROP VIEW não mexe nas tabelas.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A view guarda o SELECT e funciona como tabela virtual, sem copiar os dados', true, 1),
  ('Uma view com GROUP BY aceita UPDATE e DELETE como uma tabela comum', false, 2),
  ('Ao criar uma view, o recomendado é usar sempre CREATE OR REPLACE VIEW', false, 3),
  ('Colunas com o mesmo nome no SELECT da view precisam receber um alias', true, 4),
  ('DROP VIEW apaga a view e também as linhas das tabelas usadas nela', false, 5)
) AS o(text, is_correct, order_index);

-- Q6 | multiple_choice | fácil | Relacionamento N:M e tabela associativa | Exercícios 1 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Uma escola de idiomas mudou a regra: um aluno pode se matricular em vários cursos e um curso pode receber vários alunos. Como fica o modelo lógico?',
    'Qualquer FK única limita um dos lados a um só vínculo, e guardar ''1,2'' mistura valores. A tabela associativa tem uma linha por vínculo, e as duas FKs formam a PK composta.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('fk_curso na tabela aluno, como no relacionamento 1:N de antes', false, 1),
  ('fk_aluno na tabela curso, apontando para o aluno mais recente', false, 2),
  ('fk_curso em aluno e fk_aluno em curso, uma chave em cada lado', false, 3),
  ('fk_curso em aluno guardando vários ids juntos, como ''1,2''', false, 4),
  ('Tabela matricula com fk_ra e fk_curso formando a chave primária', true, 5)
) AS o(text, is_correct, order_index);

-- Q7 | drag_and_drop | fácil | Relacionamento N:M e tabela associativa | Exercícios 1 | s1: aluno, s2: curso, s3: matricula, s4: (fk_ra, fk_curso)
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'No modelo aluno (ra, nome), curso (id_curso, nome) e matricula, João começou Espanhol em 2026-02-01 no nível A2. O nome de João fica em {{s1}}, o nome do curso fica em {{s2}}, a data de início e o nível ficam em {{s3}} e a chave primária de matricula é {{s4}}.',
    'Dados do aluno ficam em aluno e dados do curso em curso. Data de início e nível descrevem o vínculo, então ficam em matricula, cuja PK é composta pelas duas FKs.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('curso', 1),
    ('(fk_ra)', 2),
    ('matricula', 3),
    ('aluno', 4),
    ('(data_inicio, nivel)', 5),
    ('(fk_ra, fk_curso)', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'aluno', 1),
  ('s2', 'curso', 2),
  ('s3', 'matricula', 3),
  ('s4', '(fk_ra, fk_curso)', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q8 | multiple_choice | fácil | Tratamento de nulos e condicionais | Exercícios 1 | correta: B | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'O produto 10 (nome ''Fone Bluetooth'') está sem categoria (NULL). Query A: SELECT CONCAT(nome, '' - '', categoria) FROM produto WHERE idProduto = 10; Query B: SELECT CONCAT(nome, '' - '', IFNULL(categoria, ''Sem categoria'')) FROM produto WHERE idProduto = 10; O que cada query devolve?',
    'Se qualquer argumento do CONCAT for NULL, o resultado inteiro é NULL. Tratando o nulo antes com IFNULL, B monta o texto normalmente.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A: ''Fone Bluetooth - ''; B: ''Fone Bluetooth - Sem categoria''', false, 1),
  ('A: NULL (o texto inteiro); B: ''Fone Bluetooth - Sem categoria''', true, 2),
  ('A: ''Fone Bluetooth - NULL''; B: ''Fone Bluetooth - Sem categoria''', false, 3),
  ('A: NULL; B: NULL, pois IFNULL não funciona dentro de CONCAT', false, 4),
  ('A: erro de tipo; B: ''Fone Bluetooth - Sem categoria''', false, 5)
) AS o(text, is_correct, order_index);

-- Q9 | single_choice | fácil | Views | Exercícios 1 | b1: CREATE VIEW, b2: vw_cidade, b3: DROP VIEW
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice',
    'Para criar a view do exercício sem correr o risco de sobrepor outra: {{b1}} vw_cidade AS SELECT c.id AS id_cidade, e.sigla AS sigla_estado, c.nome AS nome_cidade FROM cidade c JOIN estado e ON e.id = c.id_estado; Para consultar as cidades de São Paulo: SELECT nome_cidade FROM {{b2}} WHERE sigla_estado = ''SP''; Para apagar a view no fim: {{b3}} vw_cidade;',
    'Na criação, o material pede CREATE VIEW sem REPLACE, para não sobrepor uma view existente. A view é consultada pelo nome, como uma tabela, e removida com DROP VIEW.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'CREATE VIEW', true, 1),
  ('b1', 'CREATE OR REPLACE VIEW', false, 2),
  ('b1', 'ALTER VIEW', false, 3),
  ('b2', 'cidade', false, 1),
  ('b2', 'vw_cidade', true, 2),
  ('b2', 'VIEW vw_cidade', false, 3),
  ('b3', 'DELETE FROM', false, 1),
  ('b3', 'TRUNCATE TABLE', false, 2),
  ('b3', 'DROP VIEW', true, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q10 | multiple_choice | média | Agregação, GROUP BY e HAVING | Exercícios 1 | correta: D | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'A coluna categoria de produto tem os valores Periféricos (3 produtos), Monitores (2), Computadores (2), Acessórios (2) e NULL (1). Query A: SELECT COUNT(DISTINCT categoria) FROM produto; Query B: SELECT categoria FROM produto GROUP BY categoria; Qual valor A devolve e quantas linhas B devolve?',
    'COUNT(DISTINCT categoria) não conta o nulo, então dá 4. Já o GROUP BY não descarta nulos: o NULL forma um grupo próprio, e B devolve 5 linhas.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A devolve 5 e B devolve 5 linhas', false, 1),
  ('A devolve 4 e B devolve 4 linhas', false, 2),
  ('A devolve 9 e B devolve 5 linhas', false, 3),
  ('A devolve 4 e B devolve 5 linhas', true, 4),
  ('A devolve 5 e B devolve 4 linhas', false, 5)
) AS o(text, is_correct, order_index);

-- Q11 | multiple_answer | média | Agregação, GROUP BY e HAVING | Exercícios 1 | corretas: B, D | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer',
    'A query base SELECT categoria, COUNT(*) AS qtd FROM produto WHERE preco > 100 GROUP BY categoria HAVING COUNT(*) >= 2; devolve Periféricos (3), Monitores (2) e Computadores (2). Acessórios tem um produto de 29.90 e outro de 159.90. Assinale todas as queries que devolvem exatamente o mesmo resultado.',
    'O MySQL aceita o apelido qtd no HAVING, e COUNT(idProduto) conta o mesmo que COUNT(*) porque a PK nunca é nula. Sem o WHERE, Acessórios entra com 2; COUNT(*) no WHERE dá o erro 1111; e > 2 deixa só Periféricos.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT categoria, COUNT(*) AS qtd FROM produto GROUP BY categoria HAVING COUNT(*) >= 2;', false, 1),
  ('SELECT categoria, COUNT(*) AS qtd FROM produto WHERE preco > 100 GROUP BY categoria HAVING qtd >= 2;', true, 2),
  ('SELECT categoria, COUNT(*) AS qtd FROM produto WHERE preco > 100 AND COUNT(*) >= 2 GROUP BY categoria;', false, 3),
  ('SELECT categoria, COUNT(idProduto) AS qtd FROM produto WHERE preco > 100 GROUP BY categoria HAVING COUNT(idProduto) >= 2;', true, 4),
  ('SELECT categoria, COUNT(*) AS qtd FROM produto WHERE preco > 100 GROUP BY categoria HAVING COUNT(*) > 2;', false, 5)
) AS o(text, is_correct, order_index);

-- Q12 | drag_and_drop | média | Views | Exercícios 1 | s1: Lista as categorias com 2 ou mais produtos, s2: Erro: a view com GROUP BY não é atualizável, s3: Erro: nome de coluna repetido na view, s4: Remove só a view; produto continua igual
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'Existem a tabela categoria (id, nome) e a view vw_qtd_categoria AS SELECT categoria, COUNT(*) AS qtd FROM produto GROUP BY categoria. Associe cada comando ao que acontece: SELECT * FROM vw_qtd_categoria WHERE qtd >= 2; {{s1}}. UPDATE vw_qtd_categoria SET qtd = 0; {{s2}}. CREATE VIEW vw_nomes AS SELECT p.nome, c.nome FROM produto p JOIN categoria c ON c.nome = p.categoria; {{s3}}. DROP VIEW vw_qtd_categoria; {{s4}}.',
    'A view pode ser consultada com WHERE como uma tabela, mas, por ter GROUP BY, não aceita UPDATE. Duas colunas nome sem alias dão erro, e DROP VIEW remove só o objeto view.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('Erro: nome de coluna repetido na view', 1),
    ('Zera a quantidade de produtos de todas as categorias', 2),
    ('Lista as categorias com 2 ou mais produtos', 3),
    ('Apaga a view e as linhas de produto', 4),
    ('Remove só a view; produto continua igual', 5),
    ('Erro: a view com GROUP BY não é atualizável', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'Lista as categorias com 2 ou mais produtos', 1),
  ('s2', 'Erro: a view com GROUP BY não é atualizável', 2),
  ('s3', 'Erro: nome de coluna repetido na view', 3),
  ('s4', 'Remove só a view; produto continua igual', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q13 | drag_and_drop | média | Relacionamento N:M e tabela associativa | Exercícios 1 | s1: 4, s2: 2, s3: 5, s4: 1 | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'Com aluno (1000 Maria, 1001 João, 1002 Ana) e matricula (fk_ra, fk_curso) com as linhas (1000, 1), (1000, 2), (1001, 1) e (1001, 2), associe cada query ao número que ela devolve: SELECT COUNT(*) FROM matricula; devolve {{s1}}. SELECT COUNT(DISTINCT fk_ra) FROM matricula; devolve {{s2}}. SELECT COUNT(*) FROM aluno a LEFT JOIN matricula m ON m.fk_ra = a.ra; devolve {{s3}}. SELECT COUNT(*) FROM aluno a LEFT JOIN matricula m ON m.fk_ra = a.ra WHERE m.fk_ra IS NULL; devolve {{s4}}.',
    'Há 4 matrículas de 2 alunos diferentes. O LEFT JOIN mantém Ana, que não tem matrícula, como uma linha extra (4 + 1 = 5), e o filtro IS NULL deixa só ela.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('3', 1),
    ('4', 2),
    ('1', 3),
    ('5', 4),
    ('2', 5),
    ('0', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', '4', 1),
  ('s2', '2', 2),
  ('s3', '5', 3),
  ('s4', '1', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q14 | multiple_answer | média | Tratamento de nulos e condicionais | Exercícios 1 | corretas: B, C, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer',
    'Um relatório trata descontos nulos e divisões por zero. Sobre IFNULL, COALESCE e NULLIF no MySQL, assinale todas as corretas.',
    'IFNULL aceita só 2 argumentos e COALESCE devolve o primeiro não nulo de vários. NULLIF(a, b) dá NULL quando a = b, o que evita a divisão por zero, e NULL = NULL dá NULL, por isso se usa IS NULL.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('IFNULL(desconto, 0, 5) é válido e testa os argumentos em ordem', false, 1),
  ('COALESCE(NULL, NULL, ''terceiro'') devolve ''terceiro''', true, 2),
  ('NULLIF(desconto, 0) devolve NULL quando o desconto é 0', true, 3),
  ('NULL = NULL devolve 1, então WHERE desconto = NULL acha os nulos', false, 4),
  ('100 / NULLIF(0, 0) devolve NULL em vez de dividir por zero', true, 5)
) AS o(text, is_correct, order_index);

-- Q15 | multiple_choice | média | Subqueries e comparação com JOIN | Exercícios 1 | correta: C | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'O preço médio da tabela produto é 1200.68. Qual query lista o nome e o preço dos produtos mais caros que essa média, sem digitar o valor na mão?',
    'A subquery escalar calcula a média uma vez e o WHERE compara cada preço com ela. AVG direto no WHERE dá o erro 1111, a subquery sem AVG devolve várias linhas (erro 1242) e agrupar por produto compara cada preço com ele mesmo.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT nome, preco FROM produto WHERE preco > AVG(preco);', false, 1),
  ('SELECT nome, preco FROM produto WHERE preco > (SELECT preco FROM produto);', false, 2),
  ('SELECT nome, preco FROM produto WHERE preco > (SELECT AVG(preco) FROM produto);', true, 3),
  ('SELECT nome, preco FROM produto GROUP BY idProduto HAVING preco > AVG(preco);', false, 4),
  ('SELECT nome, preco FROM produto HAVING preco > AVG(preco);', false, 5)
) AS o(text, is_correct, order_index);

-- Q16 | multiple_choice | difícil | Agregação, GROUP BY e HAVING | Exercícios 2 | correta: B | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Um dashboard mostra o ticket médio por dia: faturamento do dia dividido pelo número de vendas do dia. Os dados são venda (idVenda, dataHora): (1, ''2026-10-02 09:00''), (2, ''2026-10-02 15:00'') e (3, ''2026-10-03 10:00''); e item (fkVenda, valor): (1, 100), (1, 50), (2, 30) e (3, 80). Qual query devolve o ticket médio correto de cada dia?',
    'Depois do JOIN há uma linha por item, então o divisor precisa ser COUNT(DISTINCT v.idVenda): 180 / 2 = 90 no dia 02 e 80 no dia 03. AVG e COUNT(*) dividem por itens (60), agrupar por dataHora separa cada venda e a subquery divide pelo total de vendas de todos os dias.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT DATE(v.dataHora) AS dia, AVG(i.valor) AS ticket FROM venda v JOIN item i ON i.fkVenda = v.idVenda GROUP BY DATE(v.dataHora);', false, 1),
  ('SELECT DATE(v.dataHora) AS dia, SUM(i.valor) / COUNT(DISTINCT v.idVenda) AS ticket FROM venda v JOIN item i ON i.fkVenda = v.idVenda GROUP BY DATE(v.dataHora);', true, 2),
  ('SELECT DATE(v.dataHora) AS dia, SUM(i.valor) / COUNT(*) AS ticket FROM venda v JOIN item i ON i.fkVenda = v.idVenda GROUP BY DATE(v.dataHora);', false, 3),
  ('SELECT DATE(v.dataHora) AS dia, SUM(i.valor) / COUNT(DISTINCT v.idVenda) AS ticket FROM venda v JOIN item i ON i.fkVenda = v.idVenda GROUP BY v.dataHora;', false, 4),
  ('SELECT DATE(v.dataHora) AS dia, SUM(i.valor) / (SELECT COUNT(*) FROM venda) AS ticket FROM venda v JOIN item i ON i.fkVenda = v.idVenda GROUP BY DATE(v.dataHora);', false, 5)
) AS o(text, is_correct, order_index);

-- Q17 | multiple_answer | difícil | Agregação, GROUP BY e HAVING | Exercícios 2 | corretas: A, B, E | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer',
    'Em vendas_funcoes, Ana Souza tem as vendas 1, 3, 5, 7 e 12; Bruno Lima, 2, 6 e 10; Carla Mendes, 4 e 8; Diego Rocha, 9 e 11. As vendas 1, 2, 4, 5, 7, 8, 9 e 12 têm 2 itens cada e as demais, 1. Assinale todas as queries que devolvem só Ana Souza e Bruno Lima (mais de duas vendas).',
    'Sem JOIN, cada linha é uma venda e > 2 equivale a >= 3, enquanto C dá o erro 1111. Com o JOIN, cada venda vira uma linha por item, então COUNT(*) passa a contar itens (Carla e Diego somam 4 e 3) e só COUNT(DISTINCT v.idVenda) volta a contar vendas.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT vendedor FROM venda GROUP BY vendedor HAVING COUNT(*) > 2;', true, 1),
  ('SELECT vendedor FROM venda GROUP BY vendedor HAVING COUNT(*) >= 3;', true, 2),
  ('SELECT vendedor FROM venda WHERE COUNT(*) > 2 GROUP BY vendedor;', false, 3),
  ('SELECT v.vendedor FROM venda v JOIN item i ON i.fkVenda = v.idVenda GROUP BY v.vendedor HAVING COUNT(*) > 2;', false, 4),
  ('SELECT v.vendedor FROM venda v JOIN item i ON i.fkVenda = v.idVenda GROUP BY v.vendedor HAVING COUNT(DISTINCT v.idVenda) > 2;', true, 5)
) AS o(text, is_correct, order_index);

-- Q18 | single_choice | difícil | Subqueries e comparação com JOIN | Exercícios 2 | b1: nenhuma linha, b2: Teclado e Webcam, b3: WHERE fkProduto IS NOT NULL | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice',
    'produto tem os ids 1 (Mouse), 2 (Teclado), 3 (Monitor) e 4 (Webcam), e destaque (fkProduto) tem as linhas 1, 3 e NULL. A query SELECT nome FROM produto WHERE idProduto NOT IN (SELECT fkProduto FROM destaque); devolve {{b1}}. Já SELECT nome FROM produto p WHERE NOT EXISTS (SELECT 1 FROM destaque d WHERE d.fkProduto = p.idProduto); devolve {{b2}}. Para a versão com NOT IN dar o mesmo resultado, basta acrescentar {{b3}} na subquery.',
    'NOT IN compara com cada valor da lista, e idProduto <> NULL é desconhecido, então nenhuma linha passa. NOT EXISTS só verifica se existe linha correspondente e ignora o NULL; filtrar IS NOT NULL na subquery corrige o NOT IN.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'nenhuma linha', true, 1),
  ('b1', 'Teclado e Webcam', false, 2),
  ('b1', 'Teclado, Webcam e uma linha NULL', false, 3),
  ('b2', 'nenhuma linha', false, 1),
  ('b2', 'Teclado e Webcam', true, 2),
  ('b2', 'Mouse e Monitor', false, 3),
  ('b3', 'DISTINCT', false, 1),
  ('b3', 'WHERE fkProduto IS NOT NULL', true, 2),
  ('b3', 'LIMIT 1', false, 3),
  ('b3', 'ORDER BY fkProduto', false, 4)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q19 | drag_and_drop | difícil | Tratamento de nulos e condicionais | Exercícios 2 | s1: 5, s2: 3, s3: 10.0000, s4: 6.0000 | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'A tabela item tem 5 linhas com os descontos NULL, 0, 10, NULL e 20. Associe cada query ao valor devolvido: SELECT COUNT(*) FROM item; devolve {{s1}}. SELECT COUNT(desconto) FROM item; devolve {{s2}}. SELECT AVG(desconto) FROM item; devolve {{s3}}. SELECT AVG(IFNULL(desconto, 0)) FROM item; devolve {{s4}}.',
    'COUNT(*) conta as 5 linhas e COUNT(desconto) só as 3 não nulas. AVG(desconto) divide 30 por 3 (10), e com IFNULL os nulos viram 0 e a soma 30 é dividida por 5 (6).'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('10.0000', 1),
    ('5', 2),
    ('7.5000', 3),
    ('3', 4),
    ('6.0000', 5),
    ('2', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', '5', 1),
  ('s2', '3', 2),
  ('s3', '10.0000', 3),
  ('s4', '6.0000', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q20 | multiple_choice | difícil | Views | Exercícios 2 | correta: D | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Existe a view vw_aeroporto AS SELECT e.sigla AS sigla_estado, a.sigla AS sigla_aeroporto FROM aeroporto a JOIN cidade c ON c.id = a.id_cidade JOIN estado e ON e.id = c.id_estado. Query A: SELECT sigla_aeroporto FROM vw_aeroporto WHERE sigla_estado = ''PE''; Query B: SELECT a.sigla FROM aeroporto a JOIN cidade c ON c.id = a.id_cidade JOIN estado e ON e.id = c.id_estado WHERE e.sigla = ''PE''; Hoje as duas devolvem REC. Depois do INSERT de um aeroporto novo em Recife, o que acontece?',
    'A view é uma consulta salva usada como tabela virtual: a cada SELECT ela roda o JOIN de novo sobre os dados atuais. Por isso A e B são equivalentes e as duas enxergam o INSERT.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Só B mostra o aeroporto novo, pois a view guarda uma cópia dos dados', false, 1),
  ('A dá erro, pois não é permitido filtrar uma view com WHERE', false, 2),
  ('Só A mostra o aeroporto novo, e só depois de um ALTER VIEW', false, 3),
  ('As duas mostram REC e o novo, pois a view guarda a consulta', true, 4),
  ('A mostra o aeroporto novo duas vezes, pois repete o JOIN de B', false, 5)
) AS o(text, is_correct, order_index);

-- Q21 | multiple_choice | difícil | Relacionamento N:M e tabela associativa | Exercícios 2 | correta: A | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'curso tem Espanhol (1), Inglês (2) e Francês (3). matricula tem 3 alunos em Espanhol, 2 em Inglês e nenhum em Francês. Qual query mostra quantos alunos cada curso tem, com Francês aparecendo com 0?',
    'O LEFT JOIN a partir de curso mantém Francês com uma linha de colunas NULL, e COUNT(m.fk_ra) ignora esse NULL e dá 0. COUNT(*) conta essa linha e mostra 1, e o JOIN e o LEFT JOIN a partir de matricula nem trazem Francês.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT c.nome, COUNT(m.fk_ra) FROM curso c LEFT JOIN matricula m ON m.fk_curso = c.id_curso GROUP BY c.id_curso, c.nome;', true, 1),
  ('SELECT c.nome, COUNT(*) FROM curso c LEFT JOIN matricula m ON m.fk_curso = c.id_curso GROUP BY c.id_curso, c.nome;', false, 2),
  ('SELECT c.nome, COUNT(*) FROM curso c JOIN matricula m ON m.fk_curso = c.id_curso GROUP BY c.id_curso, c.nome;', false, 3),
  ('SELECT c.nome, COUNT(m.fk_ra) FROM matricula m LEFT JOIN curso c ON c.id_curso = m.fk_curso GROUP BY c.id_curso, c.nome;', false, 4),
  ('SELECT c.nome, COUNT(DISTINCT c.id_curso) FROM curso c LEFT JOIN matricula m ON m.fk_curso = c.id_curso GROUP BY c.id_curso, c.nome;', false, 5)
) AS o(text, is_correct, order_index);

-- Q22 | multiple_answer | difícil | Subqueries e comparação com JOIN | Exercícios 2 | corretas: B, E | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer',
    'produto tem 1 (Mouse), 2 (Teclado) e 3 (Monitor), e item (fkVenda, fkProduto) tem (1, 1), (2, 1) e (2, 3). A query SELECT nome FROM produto WHERE idProduto IN (SELECT fkProduto FROM item); devolve Mouse e Monitor. Assinale todas as queries equivalentes a ela.',
    'EXISTS correlacionado devolve cada produto uma vez, como o IN, e o JOIN só fica equivalente com DISTINCT, pois sem ele repete o Mouse, vendido duas vezes. NOT IN e LEFT JOIN ... IS NULL fazem o contrário e devolvem o Teclado.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT p.nome FROM produto p JOIN item i ON i.fkProduto = p.idProduto;', false, 1),
  ('SELECT nome FROM produto p WHERE EXISTS (SELECT 1 FROM item i WHERE i.fkProduto = p.idProduto);', true, 2),
  ('SELECT nome FROM produto WHERE idProduto NOT IN (SELECT fkProduto FROM item);', false, 3),
  ('SELECT p.nome FROM produto p LEFT JOIN item i ON i.fkProduto = p.idProduto WHERE i.fkProduto IS NULL;', false, 4),
  ('SELECT DISTINCT p.nome FROM produto p JOIN item i ON i.fkProduto = p.idProduto;', true, 5)
) AS o(text, is_correct, order_index);

-- Q23 | drag_and_drop | difícil | Agregação, GROUP BY e HAVING | Exercícios 2 | s1: Erro 1111: uso inválido de função de grupo, s2: Erro 1055: nome não está no GROUP BY, s3: Ana Souza (5) e Bruno Lima (3), s4: Periféricos, Monitores e Computadores | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'Com o banco vendas_funcoes no MySQL 8, associe cada query ao resultado: SELECT vendedor, COUNT(*) FROM venda WHERE COUNT(*) > 2 GROUP BY vendedor; {{s1}}. SELECT categoria, nome, COUNT(*) FROM produto GROUP BY categoria; {{s2}}. SELECT vendedor, COUNT(*) FROM venda GROUP BY vendedor HAVING COUNT(*) > 2; {{s3}}. SELECT categoria, COUNT(*) FROM produto WHERE preco > 100 GROUP BY categoria HAVING COUNT(*) >= 2; {{s4}}.',
    'Agregação no WHERE dá o erro 1111, porque o WHERE roda antes do GROUP BY, e coluna solta fora do GROUP BY dá o erro 1055 no MySQL 8. O HAVING filtra os grupos depois de formados, e o WHERE pode descartar linhas antes de agrupar.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('Ana Souza (5) e Bruno Lima (3)', 1),
    ('Todas as categorias, com um nome qualquer', 2),
    ('Erro 1055: nome não está no GROUP BY', 3),
    ('Periféricos, Monitores e Computadores', 4),
    ('Os quatro vendedores, com a contagem de vendas', 5),
    ('Erro 1111: uso inválido de função de grupo', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'Erro 1111: uso inválido de função de grupo', 1),
  ('s2', 'Erro 1055: nome não está no GROUP BY', 2),
  ('s3', 'Ana Souza (5) e Bruno Lima (3)', 3),
  ('s4', 'Periféricos, Monitores e Computadores', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q24 | multiple_choice | difícil | Subqueries e comparação com JOIN | Exercícios 2 | correta: E | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'A tabela item tem 20 linhas de 12 vendas diferentes, e a soma da coluna quantidade é 37. Query A: SELECT AVG(total) FROM (SELECT fkVenda, SUM(quantidade) AS total FROM item GROUP BY fkVenda); Query B: SELECT AVG(total) FROM (SELECT fkVenda, SUM(quantidade) AS total FROM item GROUP BY fkVenda) AS t; O que acontece no MySQL?',
    'No MySQL, toda subquery no FROM (tabela derivada) precisa de alias, senão dá o erro 1248. Com o alias, a média é feita sobre os 12 totais por venda: 37 / 12 = 3.0833.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('As duas devolvem 3.0833, a média de peças por venda', false, 1),
  ('As duas devolvem 1.8500, a média de peças por item', false, 2),
  ('A devolve 3.0833 e B dá erro, pois AS não vale no FROM', false, 3),
  ('A dá erro de alias e B devolve 1.8500, a média por item', false, 4),
  ('A dá erro, pois falta o alias, e B devolve 3.0833', true, 5)
) AS o(text, is_correct, order_index);

-- Q25 | single_choice | difícil | Funções numéricas, de texto e de data | Exercícios 2 | b1: 'Carla', b2: ' Mendes' (com o espaço), b3: 0, b4: um texto vazio ('') | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice',
    'Para o vendedor ''Carla Mendes'', SUBSTRING(vendedor, 1, LOCATE('' '', vendedor) - 1) devolve {{b1}} e SUBSTRING(vendedor, LOCATE('' '', vendedor)) devolve {{b2}}. Se o vendedor fosse só ''Mariana'', sem espaço, LOCATE('' '', vendedor) devolveria {{b3}} e a primeira expressão devolveria {{b4}}.',
    'LOCATE acha o espaço na posição 6: cortar até a posição 5 dá ''Carla'', e começar na 6 inclui o espaço. Sem espaço, LOCATE devolve 0, e SUBSTRING com tamanho -1 devolve texto vazio, não o nome inteiro.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', '''Carla''', true, 1),
  ('b1', '''Carla '' (com o espaço)', false, 2),
  ('b1', '''Carl''', false, 3),
  ('b2', '''Mendes''', false, 1),
  ('b2', ''' Mendes'' (com o espaço)', true, 2),
  ('b2', '''Carla Mendes''', false, 3),
  ('b3', '0', true, 1),
  ('b3', 'NULL', false, 2),
  ('b3', '-1', false, 3),
  ('b4', 'um texto vazio ('''')', true, 1),
  ('b4', '''Mariana''', false, 2),
  ('b4', 'NULL', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q26 | drag_and_drop | difícil | Views | Exercícios 2 | s1: Muda o preço do produto 3 na tabela produto, s2: Erro 1288: a view não é atualizável, s3: Erro 1050: a view já existe, s4: Redefine a view, que passa a ter 4 colunas | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'Considere vw_monitor AS SELECT idProduto, nome, preco FROM produto WHERE categoria = ''Monitores'' e vw_qtd_categoria AS SELECT categoria, COUNT(*) AS qtd FROM produto GROUP BY categoria. Associe cada comando ao resultado: UPDATE vw_monitor SET preco = 809.10 WHERE idProduto = 3; {{s1}}. DELETE FROM vw_qtd_categoria WHERE categoria = ''Acessórios''; {{s2}}. CREATE VIEW vw_monitor AS SELECT idProduto, nome FROM produto; {{s3}}. ALTER VIEW vw_monitor AS SELECT idProduto, nome, preco, categoria FROM produto WHERE categoria = ''Monitores''; {{s4}}.',
    'Sem GROUP BY, a view repassa o UPDATE para a tabela de origem; com GROUP BY, UPDATE e DELETE dão o erro 1288. CREATE VIEW falha se a view já existe, e ALTER VIEW é o comando para redefinir o SELECT.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('Erro 1050: a view já existe', 1),
    ('Muda só a view; produto fica igual', 2),
    ('Muda o preço do produto 3 na tabela produto', 3),
    ('Redefine a view, que passa a ter 4 colunas', 4),
    ('Apaga os produtos de Acessórios da tabela', 5),
    ('Erro 1288: a view não é atualizável', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'Muda o preço do produto 3 na tabela produto', 1),
  ('s2', 'Erro 1288: a view não é atualizável', 2),
  ('s3', 'Erro 1050: a view já existe', 3),
  ('s4', 'Redefine a view, que passa a ter 4 colunas', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q27 | multiple_choice | difícil | Relacionamento N:M e tabela associativa | Exercícios 2 | correta: C | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'A tabela matricula (fk_ra, fk_curso) tem as linhas (1000, 1), (1000, 2), (1001, 1), (1001, 3) e (1002, 2), em que 1 é Espanhol, 2 é Inglês e 3 é Francês. Qual query lista o ra dos alunos matriculados em Espanhol e também em Inglês?',
    'Cada matrícula é uma linha, então nenhuma linha tem fk_curso 1 e 2 ao mesmo tempo, e A vem vazia. Filtrar os dois cursos e exigir 2 linhas por aluno devolve só 1000; sem o WHERE, 1001 também entra por ter Espanhol e Francês.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT fk_ra FROM matricula WHERE fk_curso = 1 AND fk_curso = 2;', false, 1),
  ('SELECT DISTINCT fk_ra FROM matricula WHERE fk_curso IN (1, 2);', false, 2),
  ('SELECT fk_ra FROM matricula WHERE fk_curso IN (1, 2) GROUP BY fk_ra HAVING COUNT(*) = 2;', true, 3),
  ('SELECT fk_ra FROM matricula GROUP BY fk_ra HAVING COUNT(*) = 2;', false, 4),
  ('SELECT fk_ra FROM matricula WHERE fk_curso = 1 OR fk_curso = 2 GROUP BY fk_ra HAVING COUNT(*) >= 1;', false, 5)
) AS o(text, is_correct, order_index);

-- Q28 | multiple_choice | difícil | Tratamento de nulos e condicionais | Exercícios 2 | correta: B | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Os preços dos 10 produtos de vendas_funcoes são 29.90, 129.90, 159.90, 199.90, 239.90, 349.90, 899.00, 1599.90, 2899.50 e 5499.00. Query A: SELECT nome, CASE WHEN preco < 200 THEN ''Barato'' WHEN preco < 1000 THEN ''Médio'' ELSE ''Caro'' END AS faixa FROM produto; Query B: SELECT nome, CASE WHEN preco < 1000 THEN ''Médio'' WHEN preco < 200 THEN ''Barato'' ELSE ''Caro'' END AS faixa FROM produto; Quantos produtos ficam na faixa ''Barato'' em cada query?',
    'O CASE testa as condições na ordem e para na primeira verdadeira. Em B, todo preço abaixo de 200 também é menor que 1000, então cai em ''Médio'' antes de chegar ao WHEN de ''Barato''.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A: 4 e B: 4, pois a ordem dos WHEN não muda o resultado', false, 1),
  ('A: 4 e B: 0, pois o CASE para no primeiro WHEN verdadeiro', true, 2),
  ('A: 3 e B: 0, pois 199.90 arredonda para 200 e vira Médio', false, 3),
  ('A: 4 e B: 7, pois B testa os dois WHEN e fica com o último', false, 4),
  ('A: 0 e B: 4, pois o CASE testa os WHEN de baixo para cima', false, 5)
) AS o(text, is_correct, order_index);

-- Q29 | multiple_answer | difícil | Subqueries e comparação com JOIN | Exercícios 2 | corretas: A, C | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer',
    'produto tem Fone (100, Áudio), Caixa de som (1000, Áudio), Webcam (300, Vídeo), Câmera (420, Vídeo) e Cabo (50, Cabos), e o preço médio geral é 374. Assinale todas as queries que listam só as categorias cujo preço médio é maior que o preço médio geral.',
    'Só Áudio tem média (550) acima de 374: A compara a média do grupo com a subquery no HAVING e C faz o mesmo sobre a tabela derivada. B filtra produtos e traz também Vídeo (Câmera de 420), D compara o grupo com ele mesmo e E dá erro, pois preco não está no GROUP BY.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT categoria FROM produto GROUP BY categoria HAVING AVG(preco) > (SELECT AVG(preco) FROM produto);', true, 1),
  ('SELECT categoria FROM produto WHERE preco > (SELECT AVG(preco) FROM produto) GROUP BY categoria;', false, 2),
  ('SELECT categoria FROM (SELECT categoria, AVG(preco) AS media FROM produto GROUP BY categoria) AS t WHERE media > (SELECT AVG(preco) FROM produto);', true, 3),
  ('SELECT categoria FROM produto GROUP BY categoria HAVING AVG(preco) > AVG(preco);', false, 4),
  ('SELECT categoria FROM produto GROUP BY categoria HAVING preco > (SELECT AVG(preco) FROM produto);', false, 5)
) AS o(text, is_correct, order_index);

-- Q30 | drag_and_drop | difícil | Funções numéricas, de texto e de data | Exercícios 2 | s1: 5, s2: 7, s3: sábado, s4: 28 | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'A venda 4 foi em 2026-10-03, um sábado, e a sessão usa SET lc_time_names = ''pt_BR''. Associe cada expressão ao valor: WEEKDAY(''2026-10-03'') devolve {{s1}}; DAYOFWEEK(''2026-10-03'') devolve {{s2}}; DAYNAME(''2026-10-03'') devolve {{s3}}; DATEDIFF(''2026-10-31'', ''2026-10-03'') devolve {{s4}}.',
    'WEEKDAY começa em 0 na segunda (sábado é 5) e DAYOFWEEK começa em 1 no domingo (sábado é 7). DATEDIFF é positivo quando a primeira data é a maior: 28 dias.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('7', 1),
    ('sábado', 2),
    ('-28', 3),
    ('5', 4),
    ('28', 5),
    ('6', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', '5', 1),
  ('s2', '7', 2),
  ('s3', 'sábado', 3),
  ('s4', '28', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q31 | multiple_choice | super difícil | Subqueries e comparação com JOIN | Exercícios 3 | correta: E | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'aluno tem Maria (1000), João (1001), Ana (1002) e Bia (1003), e monitoria (fk_ra) tem as linhas 1000 e NULL. Query A: SELECT nome FROM aluno WHERE ra IN (SELECT fk_ra FROM monitoria); Query B: SELECT nome FROM aluno WHERE ra NOT IN (SELECT fk_ra FROM monitoria); Query C: SELECT nome FROM aluno a WHERE NOT EXISTS (SELECT 1 FROM monitoria mo WHERE mo.fk_ra = a.ra); Query D: SELECT a.nome FROM aluno a LEFT JOIN monitoria mo ON mo.fk_ra = a.ra WHERE mo.fk_ra IS NULL; Quantas linhas cada query devolve?',
    'O NULL não atrapalha o IN, que acha a Maria, mas derruba o NOT IN: ra <> NULL é desconhecido e nenhuma linha passa. NOT EXISTS e LEFT JOIN ... IS NULL ignoram o NULL e devolvem João, Ana e Bia.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A: 1, B: 3, C: 3 e D: 3', false, 1),
  ('A: 2, B: 0, C: 3 e D: 3', false, 2),
  ('A: 1, B: 0, C: 3 e D: 4', false, 3),
  ('A: 1, B: 3, C: 3 e D: 4', false, 4),
  ('A: 1, B: 0, C: 3 e D: 3', true, 5)
) AS o(text, is_correct, order_index);

-- Q32 | multiple_answer | super difícil | Subqueries e comparação com JOIN | Exercícios 3 | corretas: B, D | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer',
    'Em vendas_funcoes, os maiores preços por categoria são Periféricos 349.90 (Teclado), Monitores 1599.90 (Monitor 27 pol), Computadores 5499.00 (Notebook) e Acessórios 159.90 (Mochila), e o Fone Bluetooth, sem categoria, custa 199.90. Assinale todas as queries que listam categoria, nome e preço só do produto mais caro de cada categoria, sem o Fone.',
    'A subquery correlacionada calcula o máximo da categoria de cada linha e a tabela derivada faz o mesmo com JOIN; nas duas, a comparação com categoria NULL falha e o Fone sai. A dá o erro 1055, C traz só o Notebook e E traz o Fone, porque 199.90 é o máximo do grupo NULL e o IN não olha a categoria.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT categoria, nome, MAX(preco) FROM produto GROUP BY categoria;', false, 1),
  ('SELECT p.categoria, p.nome, p.preco FROM produto p WHERE p.preco = (SELECT MAX(p2.preco) FROM produto p2 WHERE p2.categoria = p.categoria);', true, 2),
  ('SELECT p.categoria, p.nome, p.preco FROM produto p WHERE p.preco = (SELECT MAX(preco) FROM produto);', false, 3),
  ('SELECT p.categoria, p.nome, p.preco FROM produto p JOIN (SELECT categoria, MAX(preco) AS maior FROM produto GROUP BY categoria) AS t ON t.categoria = p.categoria AND t.maior = p.preco;', true, 4),
  ('SELECT p.categoria, p.nome, p.preco FROM produto p WHERE p.preco IN (SELECT MAX(preco) FROM produto GROUP BY categoria);', false, 5)
) AS o(text, is_correct, order_index);

-- Q33 | multiple_choice | super difícil | Agregação, GROUP BY e HAVING | Exercícios 3 | correta: A | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Em vendas_funcoes, Periféricos tem os preços 129.90, 349.90 e 239.90; Monitores, 899.00 e 1599.90; Computadores, 5499.00 e 2899.50; Acessórios, 29.90 e 159.90; e o Fone, sem categoria, custa 199.90. Query A: SELECT categoria, COUNT(*) FROM produto WHERE preco > 100 GROUP BY categoria; Query B: SELECT categoria, COUNT(*) FROM produto GROUP BY categoria HAVING MIN(preco) > 100; Quantas linhas cada uma devolve e onde aparece Acessórios?',
    'O WHERE descarta só o cabo de 29.90 antes de agrupar, então Acessórios fica com 1 (a mochila) e o grupo NULL também entra. O HAVING olha o grupo inteiro: o menor preço de Acessórios é 29.90, então o grupo sai de B.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A: 5 linhas e B: 4; Acessórios só aparece em A, com 1', true, 1),
  ('A: 4 linhas e B: 4; Acessórios não aparece em nenhuma', false, 2),
  ('A: 5 linhas e B: 5; Acessórios aparece nas duas, com 1', false, 3),
  ('A: 4 linhas e B: 5; Acessórios só aparece em B, com 2', false, 4),
  ('A: 5 linhas e B: 4; Acessórios só aparece em B, com 2', false, 5)
) AS o(text, is_correct, order_index);

-- Q34 | drag_and_drop | super difícil | Tratamento de nulos e condicionais | Exercícios 3 | s1: 819.53, s2: 1079.33, s3: 1139.30, s4: 1079 | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'A venda 7 tem os itens Mochila (preço 159.90, quantidade 3, desconto 0), Fone (199.90, quantidade 2, desconto 15) e Mouse (129.90, quantidade 2, desconto NULL). Com FROM item i JOIN produto p, associe cada expressão ao valor: ROUND(SUM(p.preco * i.quantidade * (1 - i.desconto / 100)), 2) dá {{s1}}; ROUND(SUM(p.preco * i.quantidade * (1 - IFNULL(i.desconto, 0) / 100)), 2) dá {{s2}}; ROUND(SUM(p.preco * i.quantidade), 2) dá {{s3}}; FLOOR(SUM(p.preco * i.quantidade * (1 - IFNULL(i.desconto, 0) / 100))) dá {{s4}}.',
    'Sem IFNULL, a conta do Mouse vira NULL e o SUM a ignora, sobrando 479.70 + 339.83. Com IFNULL o Mouse entra com 259.80; sem desconto nenhum o total é 1139.30, e FLOOR leva 1079.33 para 1079.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('1079.33', 1),
    ('NULL', 2),
    ('819.53', 3),
    ('1080', 4),
    ('1139.30', 5),
    ('1079', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', '819.53', 1),
  ('s2', '1079.33', 2),
  ('s3', '1139.30', 3),
  ('s4', '1079', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q35 | multiple_choice | super difícil | Views | Exercícios 3 | correta: C | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'A view vw_aeroporto já existe e alimenta outro relatório. Um desenvolvedor quer redefini-la e tem duas opções. Comando A: CREATE VIEW vw_aeroporto AS SELECT e.sigla AS sigla_estado, a.sigla AS sigla_aeroporto, a.nome AS nome_aeroporto FROM aeroporto a JOIN cidade c ON c.id = a.id_cidade JOIN estado e ON e.id = c.id_estado; Comando B: o mesmo, mas com CREATE OR REPLACE VIEW. O que acontece com cada um?',
    'CREATE VIEW falha com o erro 1050 quando o nome já existe, o que protege a view antiga. CREATE OR REPLACE sobrepõe sem perguntar, e é por isso que o material manda nunca usar REPLACE na criação.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Os dois substituem a view antiga, pois CREATE VIEW também sobrepõe', false, 1),
  ('A substitui a view antiga e B dá erro, pois REPLACE exige um DROP antes', false, 2),
  ('A dá erro, pois a view já existe; B a substitui sem aviso e muda o relatório', true, 3),
  ('Os dois dão erro, pois só ALTER VIEW pode mexer em uma view que já existe', false, 4),
  ('B cria uma segunda view com o mesmo nome, e o outro relatório fica igual', false, 5)
) AS o(text, is_correct, order_index);

-- Q36 | multiple_answer | super difícil | Relacionamento N:M e tabela associativa | Exercícios 3 | corretas: A, C, D | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer',
    'curso tem Espanhol (1), Inglês (2) e Francês (3), e matricula (fk_ra, fk_curso) tem (1000, 1), (1000, 2), (1001, 1) e (1002, 1); ninguém faz Francês. Assinale todas as queries que listam só os cursos com pelo menos um aluno matriculado.',
    'JOIN com GROUP BY, EXISTS correlacionado e IN chegam a Espanhol e Inglês. No LEFT JOIN, Francês vem com uma linha de NULLs que o COUNT(*) conta como 1, e em E a subquery não é correlacionada: conta a tabela toda e libera todos os cursos.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT c.nome FROM curso c JOIN matricula m ON m.fk_curso = c.id_curso GROUP BY c.id_curso, c.nome HAVING COUNT(*) >= 1;', true, 1),
  ('SELECT c.nome FROM curso c LEFT JOIN matricula m ON m.fk_curso = c.id_curso GROUP BY c.id_curso, c.nome HAVING COUNT(*) >= 1;', false, 2),
  ('SELECT c.nome FROM curso c WHERE EXISTS (SELECT 1 FROM matricula m WHERE m.fk_curso = c.id_curso);', true, 3),
  ('SELECT c.nome FROM curso c WHERE c.id_curso IN (SELECT fk_curso FROM matricula);', true, 4),
  ('SELECT c.nome FROM curso c WHERE (SELECT COUNT(*) FROM matricula) >= 1;', false, 5)
) AS o(text, is_correct, order_index);

-- Q37 | drag_and_drop | super difícil | Subqueries e comparação com JOIN | Exercícios 3 | s1: 1, s2: 0, s3: 2, s4: 5 | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'produto tem 1 Mouse (100), 2 Teclado (300), 3 Monitor (900) e 4 Cabo (20), e item (fkVenda, fkProduto) tem (1, 1), (1, 4), (2, 3), (3, 1) e (3, 2). Associe cada query ao número de linhas que ela devolve: SELECT nome FROM produto WHERE preco > (SELECT AVG(preco) FROM produto); {{s1}}. SELECT nome FROM produto p WHERE NOT EXISTS (SELECT 1 FROM item i WHERE i.fkProduto = p.idProduto); {{s2}}. SELECT fkVenda FROM item GROUP BY fkVenda HAVING COUNT(*) > (SELECT COUNT(*) FROM item) / 3; {{s3}}. SELECT p.nome FROM produto p JOIN item i ON i.fkProduto = p.idProduto; {{s4}}.',
    'A média é 330 e só o Monitor passa, e todo produto aparece em item, então NOT EXISTS não devolve nada. 5 / 3 dá 1.67 e só as vendas 1 e 3 têm 2 itens, enquanto o JOIN repete o Mouse e devolve 5 linhas.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('4', 1),
    ('1', 2),
    ('5', 3),
    ('0', 4),
    ('3', 5),
    ('2', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', '1', 1),
  ('s2', '0', 2),
  ('s3', '2', 3),
  ('s4', '5', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q38 | multiple_choice | super difícil | Funções numéricas, de texto e de data | Exercícios 3 | correta: B | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Com SET lc_time_names = ''pt_BR'', um relatório formata a data ''2026-10-03 16:30:00''. Query A: SELECT DATE_FORMAT(''2026-10-03 16:30:00'', ''%d/%m/%Y %H:%i''); Query B: SELECT DATE_FORMAT(''2026-10-03 16:30:00'', ''%d/%M/%Y %H:%m''); O que cada uma devolve?',
    '%m é o mês com dois dígitos e %i são os minutos. Em B, %M pede o nome do mês (outubro), e %m no lugar dos minutos mostra o mês de novo, 10.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A: 03/10/2026 16:30; B: 03/10/2026 16:30, pois a caixa não importa', false, 1),
  ('A: 03/10/2026 16:30; B: 03/outubro/2026 16:10', true, 2),
  ('A: 03/10/2026 16:30; B: 03/outubro/2026 16:30', false, 3),
  ('A: 03/10/2026 16:10; B: 03/outubro/2026 16:30', false, 4),
  ('A: 03/10/2026 16:30; B: erro, pois %M não existe', false, 5)
) AS o(text, is_correct, order_index);

-- Q39 | single_choice | super difícil | Subqueries e comparação com JOIN | Exercícios 3 | b1: 2 linhas: Ana 5 e Bruno 1, b2: 3 linhas, uma por venda, b3: NULL, b4: IFNULL(..., 0) | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice',
    'venda tem (1, Ana), (2, Bruno) e (3, Ana), e item (fkVenda, quantidade) tem (1, 2), (1, 3) e (2, 1); a venda 3 não tem itens. Query A: SELECT v.vendedor, SUM(i.quantidade) FROM venda v JOIN item i ON i.fkVenda = v.idVenda GROUP BY v.vendedor; devolve {{b1}}. Query B: SELECT v.vendedor, (SELECT SUM(i.quantidade) FROM item i WHERE i.fkVenda = v.idVenda) AS pecas FROM venda v; devolve {{b2}}, e a venda 3 aparece com pecas igual a {{b3}}. Para B mostrar 0 nesse caso, a subquery deve ficar dentro de {{b4}}.',
    'O JOIN descarta a venda 3 e o GROUP BY junta as vendas da Ana. A subquery no SELECT roda para cada venda e, sem itens, o SUM devolve NULL, que o IFNULL troca por 0.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', '2 linhas: Ana 5 e Bruno 1', true, 1),
  ('b1', '3 linhas: Ana 5, Bruno 1 e Ana 0', false, 2),
  ('b1', '2 linhas: Ana 6 e Bruno 1', false, 3),
  ('b2', '2 linhas, uma por vendedor', false, 1),
  ('b2', '3 linhas, uma por venda', true, 2),
  ('b2', '3 linhas, uma por item', false, 3),
  ('b3', 'NULL', true, 1),
  ('b3', '0', false, 2),
  ('b3', '5', false, 3),
  ('b4', 'IFNULL(..., 0)', true, 1),
  ('b4', 'NULLIF(..., 0)', false, 2),
  ('b4', 'COUNT(...)', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q40 | drag_and_drop | super difícil | Agregação, GROUP BY e HAVING | Exercícios 3 | s1: 4, s2: 2, s3: 6, s4: 12 | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'Em venda, Ana Souza vendeu em 28/09, 02/10, 04/10, 09/10 e 21/10; Bruno Lima, em 30/09, 07/10 e 16/10; Carla Mendes, em 03/10 e 10/10; e Diego Rocha, em 14/10 e 19/10, uma venda por dia. Associe cada query ao número de linhas: SELECT vendedor, COUNT(*) FROM venda GROUP BY vendedor; {{s1}}. SELECT MONTH(dataHora), COUNT(*) FROM venda GROUP BY MONTH(dataHora); {{s2}}. SELECT vendedor, MONTH(dataHora), COUNT(*) FROM venda GROUP BY vendedor, MONTH(dataHora); {{s3}}. SELECT DATE(dataHora), COUNT(*) FROM venda GROUP BY DATE(dataHora); {{s4}}.',
    'São 4 vendedores e 2 meses; com as duas colunas, cada combinação existente vira um grupo: Ana e Bruno em setembro e outubro, Carla e Diego só em outubro (6). Como cada venda foi em um dia diferente, DATE gera 12 grupos.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('6', 1),
    ('12', 2),
    ('8', 3),
    ('4', 4),
    ('2', 5),
    ('10', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', '4', 1),
  ('s2', '2', 2),
  ('s3', '6', 3),
  ('s4', '12', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q41 | multiple_choice | super difícil | Relacionamento N:M e tabela associativa | Exercícios 3 | correta: D | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Modelo A: matricula (fk_ra, fk_curso, data_inicio, nivel, PRIMARY KEY (fk_ra, fk_curso)). Modelo B: matricula (id INT PRIMARY KEY AUTO_INCREMENT, fk_ra, fk_curso, data_inicio, nivel). Em cada modelo, a secretaria executa duas vezes o INSERT da matrícula do aluno 1000 em Espanhol (curso 1) e depois SELECT COUNT(*) FROM matricula WHERE fk_curso = 1; O que acontece?',
    'Com a PK composta, o par (1000, 1) não pode se repetir e o segundo INSERT dá o erro 1062. Com um id artificial como PK, nada impede o vínculo duplicado, e a contagem de alunos do curso fica errada.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Nos dois modelos o segundo INSERT falha e a contagem dá 1', false, 1),
  ('Nos dois modelos o segundo INSERT é aceito e a contagem dá 2', false, 2),
  ('No modelo A a contagem dá 2; no B, o segundo INSERT falha', false, 3),
  ('No A o segundo INSERT falha e a contagem dá 1; no B dá 2', true, 4),
  ('No modelo A a contagem dá 0, pois o erro desfaz os dois INSERT', false, 5)
) AS o(text, is_correct, order_index);

-- Q42 | multiple_answer | super difícil | Views | Exercícios 3 | corretas: B, C, E | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer',
    'Existem vw_vendas_vendedor AS SELECT vendedor, COUNT(*) AS vendas FROM venda GROUP BY vendedor e vw_vendas_ana AS SELECT idVenda, dataHora, vendedor FROM venda WHERE vendedor = ''Ana Souza''. Ana tem 5 vendas e Diego, 2. Assinale todas as corretas.',
    'Para quem consulta a view, vendas é uma coluna comum, então o WHERE nela equivale ao HAVING na tabela, mas COUNT(*) no WHERE ainda dá o erro 1111. A view sem GROUP BY repassa o UPDATE para venda, a com GROUP BY recusa o DELETE (erro 1288), e as duas sempre leem os dados atuais.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('DELETE FROM vw_vendas_vendedor WHERE vendedor = ''Diego Rocha''; apaga as 2 vendas do Diego', false, 1),
  ('SELECT vendedor FROM vw_vendas_vendedor WHERE vendas > 2; devolve o mesmo que agrupar venda com HAVING COUNT(*) > 2', true, 2),
  ('UPDATE vw_vendas_ana SET dataHora = ''2026-10-02 10:00:00'' WHERE idVenda = 3; altera a venda 3 na tabela venda', true, 3),
  ('SELECT * FROM vw_vendas_vendedor WHERE COUNT(*) > 2; funciona, pois a view já está agrupada', false, 4),
  ('Após o INSERT de mais uma venda da Ana na tabela venda, vw_vendas_vendedor mostra Ana com 6', true, 5)
) AS o(text, is_correct, order_index);

-- Q43 | multiple_choice | super difícil | Agregação, GROUP BY e HAVING | Exercícios 3 | correta: A | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'A tabela item (fkVenda, desconto) tem as linhas (1, NULL), (1, 0), (2, 10), (2, NULL), (3, NULL), (4, 6) e (4, 2). Query A: SELECT fkVenda FROM item GROUP BY fkVenda HAVING AVG(desconto) < 5; Query B: SELECT fkVenda FROM item GROUP BY fkVenda HAVING AVG(IFNULL(desconto, 0)) < 5; Quais vendas cada query devolve?',
    'Em A, a venda 3 tem média NULL, e NULL < 5 não é verdadeiro, enquanto a venda 2 tem média 10. Em B os nulos viram 0: a venda 3 passa com 0 e a venda 2 fica com exatamente 5, que não é menor que 5.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A: 1 e 4; B: 1, 3 e 4', true, 1),
  ('A: 1, 3 e 4; B: 1, 3 e 4', false, 2),
  ('A: 1 e 4; B: 1, 2, 3 e 4', false, 3),
  ('A: 1, 3 e 4; B: 1 e 4', false, 4),
  ('A: 1 e 4; B: 1 e 4', false, 5)
) AS o(text, is_correct, order_index);

-- Q44 | single_choice | super difícil | Tratamento de nulos e condicionais | Exercícios 3 | b1: NULL, b2: 30, b3: dá erro, pois IFNULL aceita só 2 argumentos, b4: NULLIF(visitas, 0) | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice',
    'Um dashboard calcula a taxa de conversão (compras / visitas) da tabela campanha (nome, visitas, cliques, compras), com as linhas (''Instagram'', 200, 40, 10), (''Email'', 0, 0, 0) e (''Site'', NULL, 30, 5). Para o Site, 100 * compras / visitas devolve {{b1}}; COALESCE(visitas, cliques, 0) devolve {{b2}}; e IFNULL(visitas, cliques, 0) {{b3}}. Para o Email, o material recomenda dividir por {{b4}} para não dividir por zero.',
    'Conta com NULL dá NULL, e COALESCE devolve o primeiro não nulo da lista (cliques, 30). IFNULL só aceita 2 argumentos, e NULLIF(visitas, 0) troca o zero por NULL, deixando a divisão segura.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'NULL', true, 1),
  ('b1', '0', false, 2),
  ('b1', '500', false, 3),
  ('b2', '30', true, 1),
  ('b2', '0', false, 2),
  ('b2', 'NULL', false, 3),
  ('b3', 'dá erro, pois IFNULL aceita só 2 argumentos', true, 1),
  ('b3', 'devolve 30', false, 2),
  ('b3', 'devolve 0', false, 3),
  ('b4', 'NULLIF(visitas, 0)', true, 1),
  ('b4', 'IFNULL(visitas, 0)', false, 2),
  ('b4', 'COALESCE(visitas, 0)', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q45 | drag_and_drop | super difícil | Subqueries e comparação com JOIN | Exercícios 3 | s1: SELECT a.nome FROM aluno a WHERE EXISTS (SELECT 1 FROM matricula m WHERE m.fk_ra = a.ra), s2: SELECT a.nome FROM aluno a WHERE NOT EXISTS (SELECT 1 FROM matricula m WHERE m.fk_ra = a.ra), s3: SELECT a.nome FROM aluno a WHERE (SELECT COUNT(*) FROM matricula m WHERE m.fk_ra = a.ra) > (SELECT COUNT(*) FROM matricula) / (SELECT COUNT(*) FROM aluno), s4: SELECT a.nome, (SELECT COUNT(*) FROM matricula m WHERE m.fk_ra = a.ra) FROM aluno a | comparação de queries
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'aluno tem Maria, João, Ana e Bia; Maria e João têm 2 matrículas cada, Ana tem 1 e Bia nenhuma (5 matrículas, 4 alunos). Associe cada pergunta à query que a responde: alunos com pelo menos uma matrícula, sem repetir: {{s1}}; alunos sem matrícula: {{s2}}; alunos com mais matrículas que a média por aluno: {{s3}}; quantidade de matrículas de cada aluno, incluindo 0: {{s4}}.',
    'EXISTS e NOT EXISTS testam a presença de matrícula sem repetir o aluno, ao contrário do JOIN, que repete Maria e João. A média é 5 / 4 = 1.25, então só Maria e João passam; a subquery no SELECT conta 0 para Bia, e <> com subquery de várias linhas dá o erro 1242.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('SELECT a.nome FROM aluno a JOIN matricula m ON m.fk_ra = a.ra', 1),
    ('SELECT a.nome, (SELECT COUNT(*) FROM matricula m WHERE m.fk_ra = a.ra) FROM aluno a', 2),
    ('SELECT a.nome FROM aluno a WHERE NOT EXISTS (SELECT 1 FROM matricula m WHERE m.fk_ra = a.ra)', 3),
    ('SELECT a.nome FROM aluno a WHERE a.ra <> (SELECT fk_ra FROM matricula)', 4),
    ('SELECT a.nome FROM aluno a WHERE EXISTS (SELECT 1 FROM matricula m WHERE m.fk_ra = a.ra)', 5),
    ('SELECT a.nome FROM aluno a WHERE (SELECT COUNT(*) FROM matricula m WHERE m.fk_ra = a.ra) > (SELECT COUNT(*) FROM matricula) / (SELECT COUNT(*) FROM aluno)', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'SELECT a.nome FROM aluno a WHERE EXISTS (SELECT 1 FROM matricula m WHERE m.fk_ra = a.ra)', 1),
  ('s2', 'SELECT a.nome FROM aluno a WHERE NOT EXISTS (SELECT 1 FROM matricula m WHERE m.fk_ra = a.ra)', 2),
  ('s3', 'SELECT a.nome FROM aluno a WHERE (SELECT COUNT(*) FROM matricula m WHERE m.fk_ra = a.ra) > (SELECT COUNT(*) FROM matricula) / (SELECT COUNT(*) FROM aluno)', 3),
  ('s4', 'SELECT a.nome, (SELECT COUNT(*) FROM matricula m WHERE m.fk_ra = a.ra) FROM aluno a', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- 8. Conferência: aborta se a aula não ficou com 45 questões, 3 listas de 15 e nenhuma questão fora delas
DO $$
BEGIN
  IF (
    SELECT count(*) FROM questions q
    JOIN topics t ON t.id = q.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  ) <> 45 THEN
    RAISE EXCEPTION 'A aula deveria ter 45 questões';
  END IF;

  IF (
    SELECT count(*) FROM (
      SELECT z.id
      FROM quizzes z
      JOIN topics t ON t.id = z.topic_id
      JOIN subjects s ON s.id = t.subject_id
      JOIN quiz_questions qq ON qq.quiz_id = z.id
      WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M' AND z.kind = 'exercise'
      GROUP BY z.id
      HAVING count(*) = 15
    ) AS full_lists
  ) <> 3 THEN
    RAISE EXCEPTION 'A aula deveria ter 3 listas de exercícios com 15 questões cada';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM questions q
    JOIN topics t ON t.id = q.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
      AND NOT EXISTS (
        SELECT 1 FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
        WHERE qq.question_id = q.id AND z.kind = 'exercise'
      )
  ) THEN
    RAISE EXCEPTION 'Há questão da aula fora das listas de exercícios';
  END IF;
END $$;

COMMIT;
