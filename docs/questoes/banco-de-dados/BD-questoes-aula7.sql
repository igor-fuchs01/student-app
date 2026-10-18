-- Banco de Dados — questões da aula 7 (Tipos de Entidades e Atributos). Acrescenta 6 questões
-- multiconceito às listas de exercícios que já existem (2 em cada lista) e as adiciona ao fim dos
-- dois simulados da disciplina.
-- Rode BD-questoes.sql, BD-questoes-autorelacionamento.sql, BD-simulado.sql e
-- BD-questoes-multiconceito.sql antes deste.
-- A aula é localizada pelo subassunto "Entidades fortes e fracas" dentro da disciplina Banco de
-- Dados, cada lista pela aula e pelo nível (easy, medium, hard) e cada simulado pelo nível
-- (medium e hard), pois números, nomes e títulos foram alterados no banco depois do cadastro.
-- Conteúdo: domínio de um atributo (CHECK), entidade forte e fraca, chave primária composta,
-- relacionamento identificador, atributos atômico, composto, multivalorado, derivado e
-- identificador, sempre combinados com CREATE TABLE, INSERT ou junções.
-- Distribuição: 3 multiple_choice, 2 multiple_answer e 1 drag_and_drop;
-- 2 médias (Exercícios 1), 2 difíceis (Exercícios 2) e 2 super difíceis (Exercícios 3).
-- Simulados: o de nível médio passa de 20 para 26 questões e de 50 para 60 minutos; o difícil,
-- de 30 para 36 questões e de 60 para 70 minutos.
-- Uma única transação: se qualquer comando falhar, nada é gravado.

BEGIN;

-- 1. Aula: a que tem o subassunto "Entidades fortes e fracas" em Banco de Dados
CREATE TEMP TABLE bd_aula7_aula ON COMMIT DROP AS
SELECT t.id AS topic_id
FROM topics t
JOIN subjects s ON s.id = t.subject_id
JOIN subtopics st ON st.topic_id = t.id
WHERE s.name = 'Banco de Dados' AND st.name = 'Entidades fortes e fracas';

-- 2. Trava: a aula é única, tem uma lista de cada nível, a disciplina tem um simulado de cada
-- nível e este script ainda não rodou
DO $$
BEGIN
  IF (SELECT COUNT(*) FROM bd_aula7_aula) <> 1 THEN
    RAISE EXCEPTION 'Deveria existir uma única aula de Banco de Dados com o subassunto "Entidades fortes e fracas"';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM (VALUES ('easy'), ('medium'), ('hard')) AS v(difficulty)
    WHERE (
      SELECT COUNT(*) FROM quizzes z
      JOIN bd_aula7_aula a ON a.topic_id = z.topic_id
      WHERE z.kind = 'exercise' AND z.difficulty = v.difficulty::difficulty_level
    ) <> 1
  ) THEN
    RAISE EXCEPTION 'A aula deveria ter exatamente uma lista de exercícios de cada nível (easy, medium, hard)';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM (VALUES ('medium'), ('hard')) AS v(difficulty)
    WHERE (
      SELECT COUNT(*) FROM quizzes z JOIN subjects s ON s.id = z.subject_id
      WHERE s.name = 'Banco de Dados' AND z.kind = 'exam' AND z.difficulty = v.difficulty::difficulty_level
    ) <> 1
  ) THEN
    RAISE EXCEPTION 'Banco de Dados deveria ter exatamente um simulado de cada nível (medium e hard)';
  END IF;

  IF EXISTS (
    SELECT 1 FROM questions q
    JOIN bd_aula7_aula a ON a.topic_id = q.topic_id
    WHERE q.prompt LIKE 'A tabela curso guarda o semestre de cada turma%'
  ) THEN
    RAISE EXCEPTION 'Este script da aula 7 já foi executado';
  END IF;
END $$;

-- 3. Questões

-- Q1 | multiple_choice | média | Domínio de um atributo (CHECK) | Exercícios 1 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT a.topic_id, 'multiple_choice', 'A tabela curso guarda o semestre de cada turma, e os únicos valores válidos são ''1º sem'', ''2º sem'', ''3º sem'' e ''4º sem''. O idCurso deve ser gerado automaticamente. Qual comando cria a tabela já validando o domínio do atributo semestre?', 'O domínio é o conjunto de valores que o atributo pode assumir, e quem o valida é uma constraint CHECK com IN e a lista de valores. DEFAULT só dá um valor padrão e UNIQUE impediria duas turmas no mesmo semestre.'
  FROM bd_aula7_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'easy'
  JOIN bd_aula7_aula a ON a.topic_id = z.topic_id
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('CREATE TABLE curso (idCurso INT PRIMARY KEY AUTO_INCREMENT, nome VARCHAR(40), semestre CHAR(6) DEFAULT ''1º sem'');', false, 1),
  ('CREATE TABLE curso (idCurso INT PRIMARY KEY AUTO_INCREMENT, nome VARCHAR(40), semestre CHAR(6) UNIQUE);', false, 2),
  ('CREATE TABLE curso (idCurso INT PRIMARY KEY AUTO_INCREMENT, nome VARCHAR(40), semestre CHAR(6), CONSTRAINT chkSem CHECK (semestre = ''1º sem''));', false, 3),
  ('CREATE TABLE curso (idCurso INT PRIMARY KEY AUTO_INCREMENT, nome VARCHAR(40), semestre CHAR(6), CONSTRAINT chkSem CHECK (semestre IN (''1º sem'', ''2º sem'', ''3º sem'', ''4º sem'')));', true, 4),
  ('CREATE TABLE curso (idCurso INT PRIMARY KEY, nome VARCHAR(40), semestre CHAR(6), CONSTRAINT chkSem CHECK (idCurso IN (''1º sem'', ''2º sem'', ''3º sem'', ''4º sem'')));', false, 5)
) AS o(text, is_correct, order_index);

-- Q2 | multiple_answer | média | Tipos de atributos | Exercícios 1 | corretas: B, D, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT a.topic_id, 'multiple_answer', 'Um sistema de rádio táxi cadastra motorista com cpf, sexo, endereço (rua, cidade, estado e CEP), vários telefones, data de nascimento, idade e o valor_fatura de cada conveniada, que é a soma das corridas do período. Assinale todas as corretas.', 'Endereço é composto, e telefone, com vários valores, é multivalorado e vira tabela própria com a chave estrangeira no lado N. Idade e valor_fatura são derivados, obtidos por processamento de outros dados; sexo é atômico.'
  FROM bd_aula7_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'easy'
  JOIN bd_aula7_aula a ON a.topic_id = z.topic_id
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Sexo é um atributo composto, pois pode ser dividido em subpartes', false, 1),
  ('Endereço é composto, pois se divide em rua, cidade, estado e CEP', true, 2),
  ('Telefone é monovalorado, pois cada número tem um só valor', false, 3),
  ('Idade e valor_fatura são derivados, obtidos por processamento', true, 4),
  ('Telefone pode virar a tabela telefone, com fkMotorista no lado N', true, 5)
) AS o(text, is_correct, order_index);

-- Q3 | multiple_choice | difícil | Entidade fraca e relacionamento identificador | Exercícios 2 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT a.topic_id, 'multiple_choice', 'A tabela fatura (idFatura INT PRIMARY KEY, dtEmissao DATE) já existe. Cada fatura tem de 0 a N itens, numerados 1, 2, 3... dentro de cada fatura, e um item não existe sem a sua fatura (relacionamento identificador). Qual comando cria itens_fatura como entidade fraca?', 'Na entidade fraca, o identificador depende do da entidade forte: a chave primária é composta (fkFatura, idItem), e fkFatura também é a chave estrangeira que referencia fatura.'
  FROM bd_aula7_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'medium'
  JOIN bd_aula7_aula a ON a.topic_id = z.topic_id
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('CREATE TABLE itens_fatura (idItem INT PRIMARY KEY AUTO_INCREMENT, fkFatura INT, valor DECIMAL(8,2), FOREIGN KEY (fkFatura) REFERENCES fatura(idFatura));', false, 1),
  ('CREATE TABLE itens_fatura (fkFatura INT, idItem INT, valor DECIMAL(8,2), PRIMARY KEY (fkFatura, idItem), FOREIGN KEY (fkFatura) REFERENCES fatura(idFatura));', true, 2),
  ('CREATE TABLE itens_fatura (fkFatura INT, idItem INT, valor DECIMAL(8,2), PRIMARY KEY (fkFatura, idItem));', false, 3),
  ('CREATE TABLE itens_fatura (fkFatura INT, idItem INT, valor DECIMAL(8,2), PRIMARY KEY (idItem, valor), FOREIGN KEY (fkFatura) REFERENCES fatura(idFatura));', false, 4),
  ('CREATE TABLE itens_fatura (fkFatura INT, idItem INT, valor DECIMAL(8,2), PRIMARY KEY (fkFatura, idItem), FOREIGN KEY (idItem) REFERENCES fatura(idFatura));', false, 5)
) AS o(text, is_correct, order_index);

-- Q4 | drag_and_drop | difícil | Atributo multivalorado e junção | Exercícios 2 | s1: multivalorado, s2: telefone, s3: fkRa, s4: LEFT JOIN
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT a.topic_id, 'drag_and_drop', 'Lucas tem 2 telefones e Pedro tem 3, e outros alunos ainda não cadastraram nenhum. Telefone é um atributo {{s1}}, então cria-se a tabela {{s2}}, com a chave estrangeira {{s3}} referenciando o ra do aluno. Para listar todos os alunos com seus telefones, inclusive os que não têm nenhum, usa-se aluno {{s4}} telefone.', 'Telefone tem vários valores por aluno, então é multivalorado e vira tabela própria, com a chave estrangeira fkRa no lado N. O LEFT JOIN, com aluno à esquerda, mantém quem não tem telefone.'
  FROM bd_aula7_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'medium'
  JOIN bd_aula7_aula a ON a.topic_id = z.topic_id
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('INNER JOIN', 1), ('fkRa', 2), ('composto', 3), ('telefone', 4), ('LEFT JOIN', 5),
    ('fkTelefone', 6), ('multivalorado', 7)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'multivalorado', 1), ('s2', 'telefone', 2), ('s3', 'fkRa', 3), ('s4', 'LEFT JOIN', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q5 | multiple_choice | super difícil | Entidade fraca e chave primária composta | Exercícios 3 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT a.topic_id, 'multiple_choice', 'Um sistema cadastra alunos de várias faculdades: faculdade (idFaculdade, nome) tem as linhas (1, Sptech) e (2, Fatec), e aluno (fkFaculdade, ra, nome), com chave primária composta (fkFaculdade, ra) e fkFaculdade referenciando idFaculdade, tem a linha (1, ''01221001'', ''Lucas''). Qual afirmação sobre um novo INSERT INTO aluno está correta?', 'Aluno é entidade fraca: só o par (fkFaculdade, ra) identifica o aluno. O mesmo RA em outra faculdade é aceito, o mesmo par é rejeitado por repetir a chave primária e uma faculdade inexistente é rejeitada pela chave estrangeira.'
  FROM bd_aula7_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'hard'
  JOIN bd_aula7_aula a ON a.topic_id = z.topic_id
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('(2, ''01221001'', ''Ana'') é rejeitado, pois o RA 01221001 já foi cadastrado', false, 1),
  ('(1, ''01221002'', ''Caio'') é rejeitado, pois a Sptech já tem um aluno', false, 2),
  ('(1, ''01221001'', ''Bia'') é rejeitado, pois repete a chave primária composta', true, 3),
  ('(3, ''01221003'', ''Davi'') é aceito, pois o par (3, 01221003) é inédito', false, 4),
  ('(2, ''01221001'', ''Ana'') é aceito e transforma aluno em entidade forte', false, 5)
) AS o(text, is_correct, order_index);

-- Q6 | multiple_answer | super difícil | Atributo identificador, composto e domínio | Exercícios 3 | corretas: A, C, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT a.topic_id, 'multiple_answer', 'Uma clínica modelou paciente (rg, nome, rua, cidade, estado, cep), com o rg como chave primária, e historico_paciente, que só existe junto do paciente. Alguns pacientes são irmãos e moram no mesmo endereço. Assinale todas as corretas.', 'O RG pode se repetir entre estados, então o identificador deve ser um código controlado pelo sistema. Endereço é composto e pode virar tabela com fkEndereco em paciente (1:N), e o domínio de estado é validado com CHECK. historico_paciente depende de paciente, logo é fraca.'
  FROM bd_aula7_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'hard'
  JOIN bd_aula7_aula a ON a.topic_id = z.topic_id
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('O rg deve ser trocado por um idPaciente gerado pelo sistema, pois pode se repetir entre estados', true, 1),
  ('rua, cidade, estado e cep formam um atributo atômico, que não pode virar outra tabela', false, 2),
  ('Com a tabela endereco, a chave estrangeira fkEndereco fica em paciente, numa relação 1:N', true, 3),
  ('historico_paciente é entidade forte, pois tem colunas próprias além das do paciente', false, 4),
  ('CHECK (estado IN (''SP'', ''RJ'', ''MG'')) define o domínio do atributo estado', true, 5)
) AS o(text, is_correct, order_index);

-- 4. Simulados: as 6 questões entram no fim de cada um, na ordem abaixo
CREATE TEMP TABLE bd_aula7_simulado_questoes ON COMMIT DROP AS
SELECT v.position, v.statement_start
FROM (VALUES
  (1, 'A tabela curso guarda o semestre de cada turma'), -- Q1 | domínio de atributo
  (2, 'Um sistema de rádio táxi cadastra motorista'), -- Q2 | tipos de atributos
  (3, 'A tabela fatura (idFatura INT PRIMARY KEY, dtEmissao DATE) já existe'), -- Q3 | entidade fraca
  (4, 'Lucas tem 2 telefones e Pedro tem 3'), -- Q4 | atributo multivalorado
  (5, 'Um sistema cadastra alunos de várias faculdades: faculdade (idFaculdade, nome) tem as linhas'), -- Q5 | chave composta
  (6, 'Uma clínica modelou paciente (rg, nome, rua, cidade, estado, cep)') -- Q6 | atributo identificador
) AS v(position, statement_start);

INSERT INTO quiz_questions (quiz_id, question_id, order_index)
SELECT z.id, q.id,
  (SELECT COALESCE(MAX(qq.order_index), 0) FROM quiz_questions qq WHERE qq.quiz_id = z.id) + v.position
FROM bd_aula7_simulado_questoes v
JOIN questions q ON left(COALESCE(q.prompt, q.template), length(v.statement_start)) = v.statement_start
JOIN bd_aula7_aula a ON a.topic_id = q.topic_id
CROSS JOIN quizzes z
JOIN subjects s ON s.id = z.subject_id
WHERE s.name = 'Banco de Dados' AND z.kind = 'exam' AND z.difficulty IN ('medium', 'hard');

UPDATE quizzes z SET duration_minutes = CASE z.difficulty WHEN 'medium' THEN 60 ELSE 70 END
FROM subjects s
WHERE s.id = z.subject_id AND s.name = 'Banco de Dados'
  AND z.kind = 'exam' AND z.difficulty IN ('medium', 'hard');

-- 5. Conferência: aborta se alguma questão ficou fora das listas, se alguma questão nova ficou
-- fora de um simulado ou se os simulados não ficaram com 26 e 36 questões
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM questions q
    JOIN bd_aula7_aula a ON a.topic_id = q.topic_id
    WHERE NOT EXISTS (
      SELECT 1 FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
      WHERE qq.question_id = q.id AND z.kind = 'exercise'
    )
  ) THEN
    RAISE EXCEPTION 'Há questão de Banco de Dados fora das listas de exercícios';
  END IF;

  IF (
    SELECT COUNT(*)
    FROM bd_aula7_simulado_questoes v
    JOIN questions q ON left(COALESCE(q.prompt, q.template), length(v.statement_start)) = v.statement_start
    JOIN quiz_questions qq ON qq.question_id = q.id
    JOIN quizzes z ON z.id = qq.quiz_id AND z.kind = 'exam'
  ) <> 12 THEN
    RAISE EXCEPTION 'As 6 questões da aula 7 deveriam estar nos dois simulados';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM (VALUES ('medium', 26), ('hard', 36)) AS v(difficulty, expected)
    JOIN quizzes z ON z.kind = 'exam' AND z.difficulty = v.difficulty::difficulty_level
    JOIN subjects s ON s.id = z.subject_id AND s.name = 'Banco de Dados'
    WHERE (SELECT COUNT(*) FROM quiz_questions qq WHERE qq.quiz_id = z.id) <> v.expected
  ) THEN
    RAISE EXCEPTION 'Os simulados de Banco de Dados deveriam ter 26 (medium) e 36 (hard) questões';
  END IF;
END $$;

COMMIT;
