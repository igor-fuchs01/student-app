-- Banco de Dados — questões complementares de autorelacionamento. Acrescenta 15 questões do
-- subassunto "Autorelacionamento" às listas de exercícios que já existem (5 em cada lista).
-- Rode BD-questoes.sql (os dois scripts) antes deste.
-- A aula é localizada pelo subassunto "Autorelacionamento" dentro da disciplina Banco de Dados, e
-- cada lista pela aula e pelo nível (easy, medium, hard). O script não depende do número nem do
-- nome da aula, nem do título das listas, que podem ter sido alterados depois do cadastro.
-- Distribuição: 6 multiple_choice, 3 multiple_answer, 3 single_choice, 3 drag_and_drop;
-- 2 fáceis, 3 médias, 5 difíceis, 5 super difíceis.
-- Observações:
--  * O autorelacionamento não consta nos slides: as questões seguem o subassunto já cadastrado.
--  * Q7, Q10 e Q13 (FK que aceita NULL, ordem de inserção e exclusão de linha referenciada) e
--    Q12 e Q14 (três níveis da hierarquia) são extensões do que os pontos-chave trazem.
-- Uma única transação: se qualquer comando falhar, nada é gravado.

BEGIN;

-- 1. Aula: a que tem o subassunto "Autorelacionamento" em Banco de Dados
CREATE TEMP TABLE bd_autorelacionamento_aula ON COMMIT DROP AS
SELECT t.id AS topic_id
FROM topics t
JOIN subjects s ON s.id = t.subject_id
JOIN subtopics st ON st.topic_id = t.id
WHERE s.name = 'Banco de Dados' AND st.name = 'Autorelacionamento';

-- 2. Trava: a aula é única, tem uma lista de cada nível e este script ainda não rodou
DO $$
BEGIN
  IF (SELECT COUNT(*) FROM bd_autorelacionamento_aula) <> 1 THEN
    RAISE EXCEPTION 'Deveria existir uma única aula de Banco de Dados com o subassunto "Autorelacionamento": rode primeiro os dois scripts de BD-questoes.sql';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM (VALUES ('easy'), ('medium'), ('hard')) AS v(difficulty)
    WHERE (
      SELECT COUNT(*) FROM quizzes z
      JOIN bd_autorelacionamento_aula a ON a.topic_id = z.topic_id
      WHERE z.kind = 'exercise' AND z.difficulty = v.difficulty::difficulty_level
    ) <> 1
  ) THEN
    RAISE EXCEPTION 'A aula deveria ter exatamente uma lista de exercícios de cada nível (easy, medium, hard)';
  END IF;

  IF EXISTS (
    SELECT 1 FROM questions q
    JOIN bd_autorelacionamento_aula a ON a.topic_id = q.topic_id
    WHERE q.prompt = 'Em modelagem de banco de dados, o que caracteriza um autorelacionamento?'
  ) THEN
    RAISE EXCEPTION 'Este script de autorelacionamento já foi executado';
  END IF;
END $$;

-- 3. Questões

-- Q1 | multiple_choice | fácil | Autorelacionamento | Exercícios 1 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT a.topic_id, 'multiple_choice', 'Em modelagem de banco de dados, o que caracteriza um autorelacionamento?', 'No autorelacionamento a tabela se relaciona com ela mesma: a chave estrangeira referencia a chave primária da própria tabela.'
  FROM bd_autorelacionamento_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'easy'
  JOIN bd_autorelacionamento_aula a ON a.topic_id = z.topic_id
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Duas tabelas diferentes ligadas por uma tabela associativa', false, 1),
  ('Uma chave estrangeira que referencia a chave primária da própria tabela', true, 2),
  ('Uma tabela sem chave primária, identificada apenas pelo nome', false, 3),
  ('Uma chave primária composta por chaves estrangeiras de outras tabelas', false, 4),
  ('Uma coluna com UNIQUE, que impede valores repetidos na tabela', false, 5)
) AS o(text, is_correct, order_index);

-- Q2 | multiple_choice | fácil | Autorelacionamento | Exercícios 1 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT a.topic_id, 'multiple_choice', 'Na tabela aluno (ra, nome, fkMonitor), cada aluno pode ter outro aluno como monitor. Para modelar isso como autorelacionamento, a chave estrangeira fkMonitor deve referenciar qual coluna?', 'O monitor também é um aluno, então fkMonitor guarda o ra de outro registro da mesma tabela: a FK referencia a chave primária ra de aluno.'
  FROM bd_autorelacionamento_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'easy'
  JOIN bd_autorelacionamento_aula a ON a.topic_id = z.topic_id
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A coluna nome da tabela aluno', false, 1),
  ('A chave primária de uma nova tabela monitor', false, 2),
  ('A própria coluna fkMonitor', false, 3),
  ('A coluna ra da tabela aluno', true, 4),
  ('Nenhuma, pois não existe chave estrangeira dentro da mesma tabela', false, 5)
) AS o(text, is_correct, order_index);

-- Q3 | single_choice | média | Autorelacionamento | Exercícios 1 | b1: estrangeira, b2: primária, b3: a própria tabela
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT a.topic_id, 'single_choice', 'No autorelacionamento, a chave {{b1}} de uma tabela referencia a chave {{b2}} de {{b3}}.', 'A chave estrangeira aponta para a chave primária, e no autorelacionamento as duas ficam na mesma tabela.'
  FROM bd_autorelacionamento_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'easy'
  JOIN bd_autorelacionamento_aula a ON a.topic_id = z.topic_id
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'primária', false, 1), ('b1', 'estrangeira', true, 2), ('b1', 'composta', false, 3),
  ('b2', 'primária', true, 1), ('b2', 'estrangeira', false, 2), ('b2', 'composta', false, 3),
  ('b3', 'outra tabela', false, 1), ('b3', 'uma tabela associativa', false, 2), ('b3', 'a própria tabela', true, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q4 | drag_and_drop | média | Autorelacionamento | Exercícios 1 | s1: fkSupervisor, s2: funcionario, s3: idFunc
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT a.topic_id, 'drag_and_drop', 'Cada funcionário pode ter outro funcionário como supervisor: CREATE TABLE funcionario (idFunc INT PRIMARY KEY, nome VARCHAR(45), fkSupervisor INT, CONSTRAINT fkSup FOREIGN KEY ({{s1}}) REFERENCES {{s2}}({{s3}}));', 'A coluna fkSupervisor é a chave estrangeira e referencia a chave primária idFunc da própria tabela funcionario.'
  FROM bd_autorelacionamento_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'easy'
  JOIN bd_autorelacionamento_aula a ON a.topic_id = z.topic_id
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('idFunc', 1), ('supervisor', 2), ('fkSupervisor', 3), ('nome', 4), ('funcionario', 5)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'fkSupervisor', 1), ('s2', 'funcionario', 2), ('s3', 'idFunc', 3)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q5 | multiple_answer | média | Autorelacionamento | Exercícios 1 | corretas: A, B, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT a.topic_id, 'multiple_answer', 'A tabela funcionario (idFunc, nome, fkSupervisor), em que fkSupervisor referencia idFunc, tem as linhas (1, Ana, NULL), (2, Bruno, 1), (3, Carla, 1) e (4, Diego, 2). Assinale todas as corretas.', 'O fkSupervisor de cada linha guarda o idFunc do supervisor: Ana (NULL) não tem supervisor, Bruno e Carla apontam para Ana (1) e Diego aponta para Bruno (2).'
  FROM bd_autorelacionamento_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'easy'
  JOIN bd_autorelacionamento_aula a ON a.topic_id = z.topic_id
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Ana não tem supervisor cadastrado', true, 1),
  ('Bruno e Carla têm o mesmo supervisor', true, 2),
  ('Diego é supervisionado diretamente por Ana', false, 3),
  ('Ana supervisiona diretamente dois funcionários', true, 4),
  ('Carla é a supervisora de Diego', false, 5)
) AS o(text, is_correct, order_index);

-- Q6 | multiple_choice | difícil | Autorelacionamento | Exercícios 2 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT a.topic_id, 'multiple_choice', 'A tabela funcionario (idFunc, nome, fkSupervisor) tem as linhas (1, Ana, NULL), (2, Bruno, 1), (3, Carla, 1) e (4, Diego, 2). Quantas linhas retorna a consulta SELECT f.nome, s.nome FROM funcionario f INNER JOIN funcionario s ON f.fkSupervisor = s.idFunc;?', 'O INNER JOIN só retorna quem encontrou supervisor: Bruno, Carla e Diego. Ana tem fkSupervisor nulo e fica fora do resultado.'
  FROM bd_autorelacionamento_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'medium'
  JOIN bd_autorelacionamento_aula a ON a.topic_id = z.topic_id
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('1', false, 1),
  ('2', false, 2),
  ('3', true, 3),
  ('4', false, 4),
  ('16', false, 5)
) AS o(text, is_correct, order_index);

-- Q7 | multiple_choice | difícil | Autorelacionamento | Exercícios 2 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT a.topic_id, 'multiple_choice', 'Na tabela funcionario (idFunc, nome, fkSupervisor), em que fkSupervisor referencia idFunc, por que a coluna fkSupervisor não deve ser declarada como NOT NULL?', 'Quem está no topo da hierarquia não tem supervisor, então precisa ficar com fkSupervisor nulo. Com NOT NULL, nem o primeiro funcionário poderia ser inserido.'
  FROM bd_autorelacionamento_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'medium'
  JOIN bd_autorelacionamento_aula a ON a.topic_id = z.topic_id
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Porque quem está no topo da hierarquia não tem supervisor para referenciar', true, 1),
  ('Porque NOT NULL impediria dois funcionários de terem o mesmo supervisor', false, 2),
  ('Porque NOT NULL transformaria fkSupervisor na chave primária da tabela', false, 3),
  ('Porque colunas do tipo INT não aceitam a constraint NOT NULL', false, 4),
  ('Porque NOT NULL obrigaria o supervisor a ficar em outra tabela', false, 5)
) AS o(text, is_correct, order_index);

-- Q8 | single_choice | difícil | Autorelacionamento | Exercícios 2 | b1: FOREIGN KEY, b2: REFERENCES, b3: idFunc
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT a.topic_id, 'single_choice', 'Para criar o autorelacionamento na tabela funcionario (idFunc, nome, fkSupervisor) já existente: ALTER TABLE funcionario ADD CONSTRAINT fkSup {{b1}} (fkSupervisor) {{b2}} funcionario({{b3}});', 'A constraint é uma FOREIGN KEY sobre fkSupervisor, e REFERENCES aponta para a chave primária idFunc da própria tabela funcionario.'
  FROM bd_autorelacionamento_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'medium'
  JOIN bd_autorelacionamento_aula a ON a.topic_id = z.topic_id
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'PRIMARY KEY', false, 1), ('b1', 'FOREIGN KEY', true, 2), ('b1', 'CHECK', false, 3), ('b1', 'UNIQUE', false, 4),
  ('b2', 'REFERENCES', true, 1), ('b2', 'ON', false, 2), ('b2', 'JOIN', false, 3),
  ('b3', 'fkSupervisor', false, 1), ('b3', 'nome', false, 2), ('b3', 'idFunc', true, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q9 | drag_and_drop | difícil | Autorelacionamento | Exercícios 2 | s1: NULL, s2: Ana, s3: Bruno
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT a.topic_id, 'drag_and_drop', 'A tabela funcionario (idFunc, nome, fkSupervisor) tem as linhas (1, Ana, NULL), (2, Bruno, 1), (3, Carla, 1) e (4, Diego, 2). Na consulta SELECT f.nome, s.nome FROM funcionario f LEFT JOIN funcionario s ON f.fkSupervisor = s.idFunc; a coluna s.nome vale {{s1}} na linha de Ana, {{s2}} na linha de Carla e {{s3}} na linha de Diego.', 'O LEFT JOIN mantém Ana, que não tem supervisor, com s.nome nulo. Carla aponta para o idFunc 1 (Ana) e Diego aponta para o idFunc 2 (Bruno).'
  FROM bd_autorelacionamento_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'medium'
  JOIN bd_autorelacionamento_aula a ON a.topic_id = z.topic_id
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('Bruno', 1), ('Carla', 2), ('NULL', 3), ('Diego', 4), ('Ana', 5)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'NULL', 1), ('s2', 'Ana', 2), ('s3', 'Bruno', 3)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q10 | multiple_answer | difícil | Autorelacionamento | Exercícios 2 | corretas: A, C, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT a.topic_id, 'multiple_answer', 'Sobre a inserção de dados na tabela funcionario (idFunc, nome, fkSupervisor), em que fkSupervisor é chave estrangeira para idFunc, assinale todas as corretas.', 'A chave estrangeira só aceita um idFunc que já exista ou NULL. Por isso o supervisor é inserido antes dos supervisionados, e quem está no topo fica com fkSupervisor nulo.'
  FROM bd_autorelacionamento_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'medium'
  JOIN bd_autorelacionamento_aula a ON a.topic_id = z.topic_id
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('O supervisor precisa ser inserido antes dos funcionários que ele supervisiona', true, 1),
  ('O valor de fkSupervisor precisa ser igual ao idFunc da própria linha', false, 2),
  ('Um INSERT com fkSupervisor 99, sem existir o idFunc 99, é rejeitado', true, 3),
  ('O funcionário do topo da hierarquia é inserido com fkSupervisor NULL', true, 4),
  ('A chave estrangeira impede que dois funcionários tenham o mesmo supervisor', false, 5)
) AS o(text, is_correct, order_index);

-- Q11 | multiple_choice | super difícil | Autorelacionamento | Exercícios 3 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT a.topic_id, 'multiple_choice', 'Na tabela funcionario (idFunc, nome, fkSupervisor), qual consulta lista os funcionários que não supervisionam ninguém?', 'O LEFT JOIN parte do possível supervisor s e procura supervisionados f com f.fkSupervisor = s.idFunc. WHERE f.idFunc IS NULL isola quem não encontrou nenhum supervisionado.'
  FROM bd_autorelacionamento_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'hard'
  JOIN bd_autorelacionamento_aula a ON a.topic_id = z.topic_id
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT s.nome FROM funcionario s INNER JOIN funcionario f ON f.fkSupervisor = s.idFunc WHERE f.idFunc IS NULL;', false, 1),
  ('SELECT s.nome FROM funcionario s WHERE s.fkSupervisor IS NULL;', false, 2),
  ('SELECT s.nome FROM funcionario s LEFT JOIN funcionario f ON f.idFunc = s.idFunc WHERE f.idFunc IS NULL;', false, 3),
  ('SELECT s.nome FROM funcionario s LEFT JOIN funcionario f ON f.fkSupervisor = s.idFunc WHERE s.idFunc IS NULL;', false, 4),
  ('SELECT s.nome FROM funcionario s LEFT JOIN funcionario f ON f.fkSupervisor = s.idFunc WHERE f.idFunc IS NULL;', true, 5)
) AS o(text, is_correct, order_index);

-- Q12 | multiple_choice | super difícil | Autorelacionamento | Exercícios 3 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT a.topic_id, 'multiple_choice', 'A tabela funcionario (idFunc, nome, fkSupervisor) tem as linhas (1, Ana, NULL), (2, Bruno, 1), (3, Carla, 1) e (4, Diego, 2). O que retorna a consulta SELECT f.nome, s.nome, ss.nome FROM funcionario f INNER JOIN funcionario s ON f.fkSupervisor = s.idFunc INNER JOIN funcionario ss ON s.fkSupervisor = ss.idFunc;?', 'A tabela é usada três vezes: funcionário, supervisor e supervisor do supervisor. Só Diego tem os dois níveis acima (Bruno e Ana); Bruno e Carla caem no segundo INNER JOIN, pois Ana não tem supervisor.'
  FROM bd_autorelacionamento_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'hard'
  JOIN bd_autorelacionamento_aula a ON a.topic_id = z.topic_id
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Três linhas: (Bruno, Ana, NULL), (Carla, Ana, NULL) e (Diego, Bruno, Ana)', false, 1),
  ('Quatro linhas, uma para cada funcionário da tabela', false, 2),
  ('Uma linha: (Diego, Bruno, Ana)', true, 3),
  ('Uma linha: (Ana, Bruno, Diego)', false, 4),
  ('Nenhuma linha, pois Ana não tem supervisor', false, 5)
) AS o(text, is_correct, order_index);

-- Q13 | single_choice | super difícil | Autorelacionamento | Exercícios 3 | b1: rejeitado, pois Bruno e Carla referenciam Ana, b2: alterar com UPDATE o fkSupervisor, b3: aceito, pois ninguém referencia Diego
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT a.topic_id, 'single_choice', 'A tabela funcionario (idFunc, nome, fkSupervisor), em que fkSupervisor é chave estrangeira para idFunc, tem as linhas (1, Ana, NULL), (2, Bruno, 1), (3, Carla, 1) e (4, Diego, 2). O comando DELETE FROM funcionario WHERE idFunc = 1; é {{b1}}. Para conseguir excluir Ana, antes é preciso {{b2}} de Bruno e Carla. Já o comando DELETE FROM funcionario WHERE idFunc = 4; é {{b3}}.', 'A chave estrangeira não deixa apagar uma linha que ainda é referenciada: Ana é supervisora de Bruno e Carla. Diego não é supervisor de ninguém, então pode ser excluído.'
  FROM bd_autorelacionamento_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'hard'
  JOIN bd_autorelacionamento_aula a ON a.topic_id = z.topic_id
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'aceito, e Bruno e Carla são apagados junto', false, 1), ('b1', 'rejeitado, pois Bruno e Carla referenciam Ana', true, 2), ('b1', 'aceito, e o fkSupervisor deles vira NULL sozinho', false, 3),
  ('b2', 'consultar com SELECT o fkSupervisor', false, 1), ('b2', 'apagar com DROP a coluna idFunc', false, 2), ('b2', 'alterar com UPDATE o fkSupervisor', true, 3),
  ('b3', 'aceito, pois ninguém referencia Diego', true, 1), ('b3', 'rejeitado, pois Diego tem supervisor', false, 2), ('b3', 'rejeitado, pois a tabela referencia a si mesma', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q14 | drag_and_drop | super difícil | Autorelacionamento | Exercícios 3 | s1: f.fkSupervisor, s2: s.idFunc, s3: s.fkSupervisor, s4: ss.idFunc
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT a.topic_id, 'drag_and_drop', 'A consulta lista o funcionário (apelido f), o seu supervisor (apelido s) e o supervisor do supervisor (apelido ss), com a chave estrangeira à esquerda de cada igualdade: SELECT f.nome, s.nome, ss.nome FROM funcionario f INNER JOIN funcionario s ON {{s1}} = {{s2}} INNER JOIN funcionario ss ON {{s3}} = {{s4}};', 'Cada nível repete a mesma ligação: a chave estrangeira fkSupervisor de quem está abaixo é comparada com a chave primária idFunc de quem está acima, de f para s e de s para ss.'
  FROM bd_autorelacionamento_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'hard'
  JOIN bd_autorelacionamento_aula a ON a.topic_id = z.topic_id
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('s.idFunc', 1), ('ss.fkSupervisor', 2), ('f.fkSupervisor', 3), ('ss.idFunc', 4),
    ('f.idFunc', 5), ('s.fkSupervisor', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'f.fkSupervisor', 1), ('s2', 's.idFunc', 2), ('s3', 's.fkSupervisor', 3), ('s4', 'ss.idFunc', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q15 | multiple_answer | super difícil | Autorelacionamento | Exercícios 3 | corretas: A, C, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT a.topic_id, 'multiple_answer', 'A tabela categoria (idCategoria, nome, fkCategoriaPai), em que fkCategoriaPai referencia idCategoria, tem as linhas (1, Eletrônicos, NULL), (2, Celulares, 1), (3, Notebooks, 1) e (4, Smartphones, 2). Sobre a consulta SELECT c.nome, p.nome FROM categoria c RIGHT JOIN categoria p ON c.fkCategoriaPai = p.idCategoria; assinale todas as corretas.', 'O RIGHT JOIN mantém todas as categorias no papel de pai (p): três linhas com filhas e mais Notebooks e Smartphones, que não têm filhas, com c.nome nulo. Eletrônicos não tem pai, então nunca aparece em c.nome.'
  FROM bd_autorelacionamento_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'hard'
  JOIN bd_autorelacionamento_aula a ON a.topic_id = z.topic_id
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A consulta retorna 5 linhas', true, 1),
  ('Eletrônicos aparece na coluna c.nome, com p.nome nulo', false, 2),
  ('Notebooks e Smartphones aparecem em p.nome com c.nome nulo', true, 3),
  ('Trocar RIGHT JOIN por INNER JOIN reduz o resultado a 3 linhas', true, 4),
  ('Trocar RIGHT JOIN por LEFT JOIN mantém as mesmas 5 linhas', false, 5)
) AS o(text, is_correct, order_index);

-- 4. Conferência: aborta se alguma questão ficou fora das listas ou alguma lista ficou vazia
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM questions q
    JOIN bd_autorelacionamento_aula a ON a.topic_id = q.topic_id
    WHERE NOT EXISTS (
      SELECT 1 FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
      WHERE qq.question_id = q.id AND z.kind = 'exercise'
    )
  ) THEN
    RAISE EXCEPTION 'Há questão da aula de autorelacionamento de Banco de Dados fora das listas de exercícios';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM quizzes z
    JOIN bd_autorelacionamento_aula a ON a.topic_id = z.topic_id
    WHERE z.kind = 'exercise'
      AND NOT EXISTS (SELECT 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  ) THEN
    RAISE EXCEPTION 'Há lista de exercícios da aula de autorelacionamento de Banco de Dados sem questões';
  END IF;
END $$;

COMMIT;
