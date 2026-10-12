-- Aula 4 de Banco de Dados: Constraints + Tutorial DCL.
-- Assumido: número da aula = 4 (do lote) e sigla BD (só usada se a disciplina não existir).
BEGIN;

-- 1. Disciplina
INSERT INTO subjects (name, short_label)
SELECT 'Banco de Dados', 'BD'
WHERE NOT EXISTS (SELECT 1 FROM subjects WHERE name = 'Banco de Dados');

-- 2. Assunto
INSERT INTO topics (subject_id, number, name, description)
SELECT s.id, 4, 'Constraints e Controle de Acesso (DCL)', 'Restrições aplicadas às colunas das tabelas (NOT NULL, UNIQUE, CHECK, DEFAULT, INDEX) e criação de usuários e permissões com DCL.'
FROM subjects s
WHERE s.name = 'Banco de Dados'
ON CONFLICT DO NOTHING;

-- 3. Trava: aborta se a aula não existir ou já existir com outro nome
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM topics t JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Banco de Dados' AND t.number = 4 AND t.name = 'Constraints e Controle de Acesso (DCL)'
  ) THEN
    RAISE EXCEPTION 'A aula 4 de Banco de Dados não existe ou já está cadastrada com outro nome';
  END IF;
END $$;

-- 4. Subassuntos
INSERT INTO subtopics (topic_id, name, summary, order_index)
SELECT t.id, v.name, v.summary, v.order_index
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Conceito de constraint', 'Constraints são restrições, ou regras, aplicadas às colunas de uma tabela. As vistas são PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, CHECK, DEFAULT e INDEX.', 1),
  ('NOT NULL e UNIQUE', 'NOT NULL impede valores nulos em uma coluna e UNIQUE impede valores repetidos nela.', 2),
  ('CHECK', 'A constraint CHECK garante que os valores de uma coluna satisfaçam uma condição específica. Ela pode ser criada com a tabela ou adicionada e removida com ALTER TABLE.', 3),
  ('DEFAULT e INDEX', 'DEFAULT define um valor padrão para a coluna e INDEX serve para criar e recuperar dados muito rapidamente.', 4),
  ('Criação de usuários com CREATE USER', 'A Data Control Language (DCL) controla o acesso ao banco. O administrador entra com mysql -u root -p e cria o usuário com CREATE USER.', 5),
  ('Permissões com GRANT e REVOKE', 'GRANT concede permissões a um usuário sobre um schema e REVOKE as retira. Em seguida executa-se FLUSH PRIVILEGES.', 6)
) AS v(name, summary, order_index)
WHERE s.name = 'Banco de Dados' AND t.number = 4
ON CONFLICT DO NOTHING;

-- 5. Pontos-chave
INSERT INTO subtopic_key_points (subtopic_id, text, order_index)
SELECT st.id, v.text, v.order_index
FROM subtopics st
JOIN topics t ON t.id = st.topic_id
JOIN subjects s ON s.id = t.subject_id
JOIN (VALUES
  ('Conceito de constraint', 'Constraint significa restrição: são regras aplicadas nas colunas de uma tabela.', 1),
  ('Conceito de constraint', 'As constraints vistas são PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, CHECK, DEFAULT e INDEX.', 2),
  ('NOT NULL e UNIQUE', 'NOT NULL garante que um valor nulo não pode ser armazenado em uma coluna.', 1),
  ('NOT NULL e UNIQUE', 'UNIQUE garante que todos os valores de uma coluna são diferentes.', 2),
  ('CHECK', 'CHECK garante que todos os valores de uma coluna satisfaçam uma condição específica.', 1),
  ('CHECK', 'Exemplo: constraint chkStatusSensor check (statusSensor in (''ativo'', ''inativo'')).', 2),
  ('CHECK', 'Inserir um valor fora da condição gera o erro 3819, de violação da constraint.', 3),
  ('CHECK', 'ALTER TABLE sensor add constraint chkStatusSensor check (...); adiciona a regra.', 4),
  ('CHECK', 'ALTER TABLE sensor drop constraint chkStatusSensor; exclui a regra.', 5),
  ('DEFAULT e INDEX', 'DEFAULT é um conjunto de valores padrão para a coluna quando nenhum valor é inserido ou especificado.', 1),
  ('DEFAULT e INDEX', 'INDEX é usado para criar e recuperar dados do banco de dados muito rapidamente.', 2),
  ('Criação de usuários com CREATE USER', 'O login do administrador é feito com mysql -u root -p, a partir do diretório bin do MySQL Server.', 1),
  ('Criação de usuários com CREATE USER', 'Sintaxe: CREATE USER ''nomedousuario''@''servidor'' IDENTIFIED BY ''senha'';', 2),
  ('Criação de usuários com CREATE USER', 'Exemplo: CREATE USER ''app''@''localhost'' IDENTIFIED BY ''lobo595'';', 3),
  ('Criação de usuários com CREATE USER', 'Para entrar com o novo usuário, digita-se EXIT e depois mysql -u app -p.', 4),
  ('Permissões com GRANT e REVOKE', 'GRANT regra ON schema.tabelas TO ''usuario''@''servidor''; concede permissões.', 1),
  ('Permissões com GRANT e REVOKE', 'GRANT ALL ON projeto.* TO ''app''@''localhost''; dá todas as permissões no schema projeto.', 2),
  ('Permissões com GRANT e REVOKE', 'GRANT SELECT, UPDATE ON projeto.* TO ''app''@''localhost''; concede só consulta e atualização.', 3),
  ('Permissões com GRANT e REVOKE', 'REVOKE ALL ON projeto.* FROM ''app''@''localhost''; retira as permissões do usuário.', 4),
  ('Permissões com GRANT e REVOKE', 'FLUSH PRIVILEGES; é executado depois de GRANT e de REVOKE.', 5)
) AS v(subtopic_name, text, order_index) ON v.subtopic_name = st.name
WHERE s.name = 'Banco de Dados' AND t.number = 4
ON CONFLICT DO NOTHING;

-- 6. Listas de exercícios
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT v.title, 'exercise', t.subject_id, t.id, NULL, v.difficulty::difficulty_level
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Constraints e Controle de Acesso (DCL) — Exercícios 1: Fundamentos', 'easy'),
  ('Constraints e Controle de Acesso (DCL) — Exercícios 2: Aplicação', 'medium'),
  ('Constraints e Controle de Acesso (DCL) — Exercícios 3: Desafio', 'hard')
) AS v(title, difficulty)
WHERE s.name = 'Banco de Dados' AND t.number = 4
  AND NOT EXISTS (SELECT 1 FROM quizzes z WHERE z.title = v.title);

-- 7. Questões

-- Q1 | multiple_choice | fácil | Conceito de constraint | Exercícios 1 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Em um sistema de cadastro de uma loja, a equipe de banco de dados quer que certas regras sejam aplicadas automaticamente nas colunas das tabelas. O que são constraints em SQL?', 'Constraint significa restrição: são regras aplicadas nas colunas de uma tabela para garantir a qualidade dos dados.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Comandos que apagam todos os registros de uma tabela de uma vez', false, 1),
  ('Contas de usuário que recebem permissões sobre um banco de dados', false, 2),
  ('Restrições, ou regras, aplicadas às colunas de uma tabela', true, 3),
  ('Estruturas criadas apenas para acelerar a leitura dos registros', false, 4),
  ('Tipos de dados que definem o tamanho máximo de cada coluna', false, 5)
) AS o(text, is_correct, order_index);

-- Q2 | single_choice | fácil | NOT NULL e UNIQUE | Exercícios 1 | b1: NOT NULL, b2: UNIQUE
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'A constraint {{b1}} impede que um valor nulo seja armazenado em uma coluna, enquanto a constraint {{b2}} garante que todos os valores da coluna sejam diferentes.', 'NOT NULL impede valores nulos na coluna e UNIQUE garante que todos os valores sejam diferentes entre si.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 1: Fundamentos'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'UNIQUE', false, 1), ('b1', 'NOT NULL', true, 2), ('b1', 'DEFAULT', false, 3),
  ('b2', 'CHECK', false, 1), ('b2', 'UNIQUE', true, 2), ('b2', 'INDEX', false, 3), ('b2', 'NOT NULL', false, 4)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q3 | multiple_choice | média | CHECK | Exercícios 1 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma empresa de monitoramento cadastra sensores na tabela sensor, que tem a coluna statusSensor. Para aceitar somente ''ativo'' ou ''inativo'' nessa coluna, qual constraint deve ser usada?', 'CHECK garante que os valores da coluna satisfaçam uma condição específica, como a lista de status permitidos.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('CHECK, com a condição statusSensor in (''ativo'', ''inativo'')', true, 1),
  ('UNIQUE, para que cada sensor tenha um status diferente dos demais', false, 2),
  ('DEFAULT, definindo ''ativo'' como valor inicial do status', false, 3),
  ('NOT NULL, para que o status nunca fique vazio no registro', false, 4),
  ('INDEX, para que o status seja localizado mais rapidamente', false, 5)
) AS o(text, is_correct, order_index);

-- Q4 | drag_and_drop | difícil | Criação de usuários com CREATE USER | Exercícios 2 | s1: mysql -u root -p, s2: CREATE USER, s3: GRANT ALL ON projeto.*, s4: FLUSH PRIVILEGES
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Ordene as etapas para criar o usuário app e liberar o schema projeto: 1º {{s1}}; 2º {{s2}}; 3º {{s3}}; 4º {{s4}}.', 'Primeiro entra-se como administrador (root), depois cria-se o usuário e concede-se a permissão com GRANT. Por fim, FLUSH PRIVILEGES aplica a mudança.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('GRANT ALL ON projeto.*', 1), ('mysql -u root -p', 2), ('REVOKE ALL ON projeto.*', 3),
    ('FLUSH PRIVILEGES', 4), ('TRUNCATE TABLE Aluno', 5), ('CREATE USER', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'mysql -u root -p', 1), ('s2', 'CREATE USER', 2),
  ('s3', 'GRANT ALL ON projeto.*', 3), ('s4', 'FLUSH PRIVILEGES', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q5 | multiple_answer | fácil | DEFAULT e INDEX | Exercícios 1 | corretas: A, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma equipe de banco de dados está revisando as constraints DEFAULT e INDEX em uma tabela de produtos. Assinale todas as corretas.', 'DEFAULT fornece um valor padrão quando nenhum valor é especificado e INDEX serve para criar e recuperar dados com rapidez. As demais alternativas descrevem NOT NULL, UNIQUE e CHECK.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('DEFAULT define um valor padrão para a coluna quando nenhum valor é informado', true, 1),
  ('INDEX impede que valores nulos sejam armazenados em qualquer coluna da tabela', false, 2),
  ('DEFAULT garante que todos os valores da coluna sejam diferentes entre si', false, 3),
  ('INDEX é usado para criar e recuperar dados do banco de dados muito rapidamente', true, 4),
  ('DEFAULT restringe a coluna a uma lista fixa de valores que são permitidos', false, 5)
) AS o(text, is_correct, order_index);

-- Q6 | multiple_choice | média | Permissões com GRANT e REVOKE | Exercícios 1 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um estagiário precisa de um usuário que apenas consulte e atualize dados do schema projeto, sem outras permissões. Qual comando o administrador deve executar para o usuário ''app''@''localhost''?', 'GRANT com SELECT e UPDATE concede apenas essas permissões ao usuário no schema, usando TO. Já ALL daria acesso total.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('GRANT ALL PRIVILEGES ON projeto.* TO ''app''@''localhost'';', false, 1),
  ('REVOKE SELECT, UPDATE ON projeto.* FROM ''app''@''localhost'';', false, 2),
  ('CREATE USER SELECT, UPDATE ON projeto.* TO ''app''@''localhost'';', false, 3),
  ('GRANT SELECT, UPDATE ON projeto.* FROM ''app''@''localhost'';', false, 4),
  ('GRANT SELECT, UPDATE ON projeto.* TO ''app''@''localhost'';', true, 5)
) AS o(text, is_correct, order_index);

-- Q7 | drag_and_drop | difícil | CHECK | Exercícios 2 | s1: add, s2: drop
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Para adicionar a regra de status na tabela sensor: ALTER TABLE sensor {{s1}} constraint chkStatusSensor check (statusSensor in (''ativo'', ''inativo'', ''manutencao'')); e, para excluí-la: ALTER TABLE sensor {{s2}} constraint chkStatusSensor;', 'ALTER TABLE com add constraint cria a regra CHECK e com drop constraint a remove da tabela.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('modify', 1), ('add', 2), ('rename', 3), ('drop', 4)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'add', 1), ('s2', 'drop', 2))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q8 | multiple_choice | difícil | NOT NULL e UNIQUE | Exercícios 2 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma clínica cria a tabela paciente e quer que a coluna email não aceite valores repetidos e que nenhum paciente seja cadastrado sem e-mail. Quais constraints devem ser combinadas nessa coluna?', 'UNIQUE garante que os valores sejam diferentes e NOT NULL impede valores nulos. Juntas, atendem às duas regras.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('UNIQUE, para bloquear repetições, e DEFAULT, para bloquear campos vazios', false, 1),
  ('UNIQUE, para bloquear repetições, e NOT NULL, para bloquear campos vazios', true, 2),
  ('INDEX, para bloquear repetições, e NOT NULL, para bloquear campos vazios', false, 3),
  ('NOT NULL, para bloquear repetições, e UNIQUE, para bloquear campos vazios', false, 4),
  ('DEFAULT, para bloquear repetições, e INDEX, para bloquear campos vazios', false, 5)
) AS o(text, is_correct, order_index);

-- Q9 | single_choice | super difícil | Permissões com GRANT e REVOKE | Exercícios 3 | b1: GRANT, b2: TO, b3: REVOKE, b4: FROM
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Para conceder somente leitura e atualização ao usuário app, usa-se: {{b1}} SELECT, UPDATE ON projeto.* {{b2}} ''app''@''localhost''; e, para retirar todas as permissões dele, usa-se: {{b3}} ALL ON projeto.* {{b4}} ''app''@''localhost'';', 'GRANT concede permissões usando TO, enquanto REVOKE as retira usando FROM.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 3: Desafio'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'CREATE', false, 1), ('b1', 'GRANT', true, 2), ('b1', 'REVOKE', false, 3),
  ('b2', 'TO', true, 1), ('b2', 'FROM', false, 2), ('b2', 'BY', false, 3),
  ('b3', 'GRANT', false, 1), ('b3', 'DROP', false, 2), ('b3', 'REVOKE', true, 3),
  ('b4', 'IN', false, 1), ('b4', 'TO', false, 2), ('b4', 'FROM', true, 3), ('b4', 'BY', false, 4)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q10 | multiple_answer | super difícil | CHECK | Exercícios 3 | corretas: B, C, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma indústria criou a tabela sensor com a constraint chkStatusSensor check (statusSensor in (''ativo'', ''inativo'')). Um operador tentou inserir o status ''manutenção'' e, depois, a equipe decidiu aceitar também ''manutencao''. Assinale todas as corretas.', 'O CHECK rejeita valores fora da lista com erro de violação. Para ampliar a lista, remove-se a constraint com drop e cria-se outra com add, e sem ela a coluna deixa de validar os valores.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A inserção de ''manutenção'' é aceita, pois o CHECK só valida o primeiro registro', false, 1),
  ('A inserção de ''manutenção'' gera erro de violação da constraint chkStatusSensor', true, 2),
  ('Para aceitar ''manutencao'', exclui-se a constraint e recria-se com o novo valor', true, 3),
  ('Inserir ''ativo'' ou ''inativo'' também gera erro, pois o CHECK bloqueia todo valor', false, 4),
  ('Após o drop constraint, a coluna deixa de validar a lista de status permitidos', true, 5)
) AS o(text, is_correct, order_index);

-- Q11 | multiple_choice | super difícil | Criação de usuários com CREATE USER | Exercícios 3 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um administrador abriu o prompt como administrador, entrou na pasta bin do MySQL Server e executou mysql -u root -p. Qual comando cria o usuário app, restrito ao próprio servidor, com a senha lobo595?', 'A sintaxe é CREATE USER ''usuario''@''servidor'' IDENTIFIED BY ''senha''. As demais alternativas trocam a ordem, omitem IDENTIFIED BY ou usam outro comando.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('CREATE USER ''app''@''localhost'' PASSWORD ''lobo595'';', false, 1),
  ('CREATE USER ''app'' IDENTIFIED BY ''lobo595'' @''localhost'';', false, 2),
  ('CREATE USER ''localhost''@''app'' IDENTIFIED BY ''lobo595'';', false, 3),
  ('CREATE USER ''app''@''localhost'' IDENTIFIED BY ''lobo595'';', true, 4),
  ('GRANT USER ''app''@''localhost'' IDENTIFIED BY ''lobo595'';', false, 5)
) AS o(text, is_correct, order_index);

-- Q12 | drag_and_drop | difícil | Conceito de constraint | Exercícios 2 | s1: CHECK, s2: UNIQUE, s3: NOT NULL, s4: DEFAULT
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Na tabela pedido: a coluna status só aceita ''aberto'' ou ''fechado'' ({{s1}}); o numeroPedido não pode se repetir ({{s2}}); o campo cliente não pode ficar nulo ({{s3}}); e a dataPedido recebe um valor padrão quando não é informada ({{s4}}).', 'CHECK limita os valores a uma condição, UNIQUE evita repetições, NOT NULL impede nulos e DEFAULT define o valor padrão.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('INDEX', 1), ('NOT NULL', 2), ('CHECK', 3), ('REVOKE', 4), ('DEFAULT', 5), ('UNIQUE', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'CHECK', 1), ('s2', 'UNIQUE', 2), ('s3', 'NOT NULL', 3), ('s4', 'DEFAULT', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q13 | multiple_choice | difícil | DEFAULT e INDEX | Exercícios 2 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma loja virtual tem a tabela produto com milhões de registros, e as buscas pela coluna codigoBarras estão lentas. Qual recurso estudado é indicado para acelerar a recuperação desses dados?', 'INDEX é usado para criar e recuperar dados do banco de dados muito rapidamente, o que resolve a lentidão nas buscas.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('INDEX sobre codigoBarras, para criar e recuperar dados com rapidez', true, 1),
  ('DEFAULT em codigoBarras, para preencher valores automaticamente', false, 2),
  ('NOT NULL em codigoBarras, para que o banco leia menos registros', false, 3),
  ('CHECK em codigoBarras, para filtrar os registros mais depressa', false, 4),
  ('REVOKE SELECT sobre produto, para reduzir o volume lido nas buscas', false, 5)
) AS o(text, is_correct, order_index);

-- Q14 | drag_and_drop | super difícil | Permissões com GRANT e REVOKE | Exercícios 3 | s1: Acessar como administrador (root), s2: REVOKE ALL ON projeto.*, s3: FLUSH PRIVILEGES
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Ao encerrar o acesso do usuário app ao schema projeto, o administrador executa, nesta ordem: 1º {{s1}}; 2º {{s2}}; 3º {{s3}}.', 'É preciso estar logado como administrador para usar REVOKE, que retira as permissões. Depois, FLUSH PRIVILEGES aplica a mudança.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('FLUSH PRIVILEGES', 1), ('GRANT ALL ON projeto.*', 2), ('Acessar como administrador (root)', 3),
    ('TRUNCATE TABLE Aluno', 4), ('REVOKE ALL ON projeto.*', 5), ('CREATE USER', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'Acessar como administrador (root)', 1), ('s2', 'REVOKE ALL ON projeto.*', 2), ('s3', 'FLUSH PRIVILEGES', 3)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q15 | multiple_answer | super difícil | Criação de usuários com CREATE USER | Exercícios 3 | corretas: A, C, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Após executar CREATE USER ''app''@''localhost'' IDENTIFIED BY ''lobo595''; como administrador, a equipe quer validar o acesso do novo usuário. Assinale todas as corretas.', 'EXIT sai da sessão do administrador, mysql -u app -p abre a sessão do novo usuário e, depois do GRANT, show databases; lista o schema liberado. O CREATE USER sozinho não concede permissões.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Para sair da sessão do administrador, digita-se EXIT no prompt do MySQL', true, 1),
  ('O login do usuário app é feito com mysql -u root -p, informando a senha dele', false, 2),
  ('O login do novo usuário usa mysql -u app -p, com a senha pedida em seguida', true, 3),
  ('Com GRANT ALL ON projeto.*, o comando show databases; lista o schema projeto', true, 4),
  ('O CREATE USER já concede ao usuário todas as permissões sobre o schema projeto', false, 5)
) AS o(text, is_correct, order_index);

-- 8. Conferência: aborta se alguma questão ficou fora das listas ou alguma lista ficou vazia
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM questions q
    JOIN topics t ON t.id = q.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Banco de Dados' AND t.number = 4
      AND NOT EXISTS (
        SELECT 1 FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
        WHERE qq.question_id = q.id AND z.kind = 'exercise'
      )
  ) THEN
    RAISE EXCEPTION 'Há questão da aula 4 de Banco de Dados fora das listas de exercícios';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM quizzes z
    JOIN topics t ON t.id = z.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Banco de Dados' AND t.number = 4 AND z.kind = 'exercise'
      AND NOT EXISTS (SELECT 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  ) THEN
    RAISE EXCEPTION 'Há lista de exercícios da aula 4 de Banco de Dados sem questões';
  END IF;
END $$;

COMMIT;






-- SCRIPT COMPLEMENTAR da Aula 4 de Banco de Dados (rode DEPOIS do primeiro script).
-- Soma 30 questões às 15 já cadastradas, nas mesmas 3 listas: 10 novas em cada uma (45 no total).
-- Distribuição dos 30 novos: 12 multiple_choice, 6 multiple_answer, 4 single_choice, 8 drag_and_drop;
-- 6 fáceis, 4 médias, 10 difíceis, 10 super difíceis.
-- Foco: SELECT com JOIN, variações de FK e autorelacionamento.
-- Observações:
--  * O AUTORELACIONAMENTO (subassunto 12) NÃO consta nos slides enviados. Foi incluído a pedido,
--    como extensão natural do JOIN (mesma tabela com apelidos). Remova-o se quiser só o que está nos slides.
--  * O JOIN encadeado de 3 tabelas (Q26) também é extensão: os slides só mostram JOIN entre 2 tabelas.
--  * O nome do assunto não foi alterado (a trava e os títulos das listas dependem dele);
--    apenas a descrição foi atualizada para refletir o conteúdo ampliado.
--  * Os subassuntos passam de 6 para 13, porque o material agora reúne várias aulas.
BEGIN;

-- 1. Trava: a aula existe com o nome certo, o 1º script já rodou e este ainda não
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM topics t JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Banco de Dados' AND t.number = 4 AND t.name = 'Constraints e Controle de Acesso (DCL)'
  ) THEN
    RAISE EXCEPTION 'A aula 4 de Banco de Dados não existe ou está cadastrada com outro nome';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM subtopics st
    JOIN topics t ON t.id = st.topic_id JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Banco de Dados' AND t.number = 4 AND st.name = 'Conceito de constraint'
  ) THEN
    RAISE EXCEPTION 'Rode primeiro o script original da aula 4 de Banco de Dados';
  END IF;

  IF EXISTS (
    SELECT 1 FROM subtopics st
    JOIN topics t ON t.id = st.topic_id JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Banco de Dados' AND t.number = 4 AND st.name = 'INNER JOIN e junção de tabelas'
  ) THEN
    RAISE EXCEPTION 'Este script complementar já foi executado';
  END IF;

  IF (
    SELECT COUNT(*) FROM quizzes z
    JOIN topics t ON t.id = z.topic_id JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Banco de Dados' AND t.number = 4 AND z.kind = 'exercise'
  ) < 3 THEN
    RAISE EXCEPTION 'As 3 listas de exercícios da aula 4 não foram encontradas';
  END IF;
END $$;

-- 2. Descrição do assunto (nome mantido)
UPDATE topics t
SET description = 'Restrições (constraints), controle de acesso com DCL, junções (JOIN), chaves estrangeiras, entidades, atributos e autorelacionamento.'
FROM subjects s
WHERE s.id = t.subject_id AND s.name = 'Banco de Dados' AND t.number = 4;

-- 3. Novos subassuntos
INSERT INTO subtopics (topic_id, name, summary, order_index)
SELECT t.id, v.name, v.summary, v.order_index
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('INNER JOIN e junção de tabelas', 'O JOIN junta duas tabelas ligando a chave primária de uma à chave estrangeira da outra pela cláusula ON. O INNER JOIN retorna só a interseção, ou seja, os registros com correspondência nas duas tabelas.', 7),
  ('LEFT JOIN e RIGHT JOIN', 'O LEFT JOIN mantém todos os registros da tabela 1 e o RIGHT JOIN mantém todos os da tabela 2. Com WHERE fk IS NULL, retornam apenas os registros sem correspondência.', 8),
  ('FULL OUTER JOIN', 'O FULL OUTER JOIN retorna os registros das duas tabelas, com ou sem correspondência. Nos slides ele é montado com um LEFT JOIN e um RIGHT JOIN unidos por UNION.', 9),
  ('Chave estrangeira e relacionamentos', 'A chave estrangeira fica no lado N e referencia a chave primária do lado 1. Uma tabela pode ter várias FKs, e atributos compostos ou multivalorados podem virar tabelas próprias.', 10),
  ('Entidades fortes e fracas', 'A entidade forte tem identificador próprio, e a fraca depende de outra entidade e tem identificador composto com o da forte. O relacionamento entre elas é o identificador.', 11),
  ('Autorelacionamento', 'No autorelacionamento a chave estrangeira de uma tabela referencia a chave primária da própria tabela. Na consulta, a mesma tabela é usada duas vezes, com apelidos diferentes.', 12),
  ('Atributos e alteração de tabelas', 'Os atributos podem ser atômicos, compostos, monovalorados, multivalorados, derivados ou identificadores. ALTER TABLE adiciona, renomeia, modifica e exclui colunas, e TRUNCATE limpa a tabela.', 13)
) AS v(name, summary, order_index)
WHERE s.name = 'Banco de Dados' AND t.number = 4
ON CONFLICT DO NOTHING;

-- 4. Pontos-chave dos novos subassuntos
INSERT INTO subtopic_key_points (subtopic_id, text, order_index)
SELECT st.id, v.text, v.order_index
FROM subtopics st
JOIN topics t ON t.id = st.topic_id
JOIN subjects s ON s.id = t.subject_id
JOIN (VALUES
  ('INNER JOIN e junção de tabelas', 'O JOIN faz a junção de duas tabelas, ligando a chave primária (id) de uma à chave estrangeira (fk) da outra.', 1),
  ('INNER JOIN e junção de tabelas', 'Sintaxe: SELECT nome_da_coluna FROM tabela1 INNER JOIN tabela2 ON id = fk;', 2),
  ('INNER JOIN e junção de tabelas', 'O INNER JOIN retorna apenas a interseção: os registros que têm correspondência nas duas tabelas.', 3),
  ('LEFT JOIN e RIGHT JOIN', 'O LEFT JOIN retorna todos os registros da tabela 1 e os correspondentes da tabela 2.', 1),
  ('LEFT JOIN e RIGHT JOIN', 'LEFT JOIN com WHERE fk IS NULL retorna só os registros da tabela 1 sem correspondência na tabela 2.', 2),
  ('LEFT JOIN e RIGHT JOIN', 'O RIGHT JOIN retorna todos os registros da tabela 2 e os correspondentes da tabela 1.', 3),
  ('LEFT JOIN e RIGHT JOIN', 'RIGHT JOIN com WHERE fk IS NULL retorna só os registros da tabela 2 sem correspondência na tabela 1.', 4),
  ('FULL OUTER JOIN', 'O FULL OUTER JOIN retorna os registros das duas tabelas, com ou sem correspondência.', 1),
  ('FULL OUTER JOIN', 'Nos slides, ele é feito com um SELECT com LEFT JOIN e outro com RIGHT JOIN, unidos por UNION.', 2),
  ('FULL OUTER JOIN', 'Com WHERE fk IS NULL em cada SELECT antes do UNION, retorna só os registros sem correspondência dos dois lados.', 3),
  ('Chave estrangeira e relacionamentos', 'A chave estrangeira fica na tabela do lado N e referencia a chave primária da tabela do lado 1.', 1),
  ('Chave estrangeira e relacionamentos', 'Uma tabela pode ter mais de uma FK: aluno tem fkEmpresa e fkCurso, ligadas a empresa e curso.', 2),
  ('Chave estrangeira e relacionamentos', 'Atributo composto, como endereço, pode ir para tabela própria ligada por fkEndereco, em 1:1 ou 1:N (alunos irmãos).', 3),
  ('Chave estrangeira e relacionamentos', 'Atributo multivalorado, como telefone, vira tabela própria com fkRa, em 1:N: um aluno tem vários telefones.', 4),
  ('Entidades fortes e fracas', 'A entidade forte não depende de nenhuma outra e tem chave primária própria.', 1),
  ('Entidades fortes e fracas', 'A entidade fraca não existe por si só: seu identificador depende do identificador da entidade forte, como ITENS_PEDIDO e PEDIDO.', 2),
  ('Entidades fortes e fracas', 'Se o mesmo RA pode existir em várias faculdades, aluno vira fraca, com chave primária composta (fkFaculdade, RA).', 3),
  ('Entidades fortes e fracas', 'O relacionamento identificador liga a entidade forte à fraca, como FATURA e ITENS_FATURA.', 4),
  ('Autorelacionamento', 'No autorelacionamento a tabela se relaciona com ela mesma: a FK referencia a chave primária da própria tabela.', 1),
  ('Autorelacionamento', 'Exemplo: funcionario (idFunc, nome, fkGerente), em que fkGerente referencia idFunc.', 2),
  ('Autorelacionamento', 'Na consulta, a tabela aparece duas vezes com apelidos, como f e g, e o ON compara f.fkGerente = g.idFunc.', 3),
  ('Autorelacionamento', 'Com LEFT JOIN, quem não tem gerente continua no resultado, com os dados do gerente nulos.', 4),
  ('Atributos e alteração de tabelas', 'Atômico não se divide; composto se divide em subpartes; monovalorado tem um valor; multivalorado pode ter vários.', 1),
  ('Atributos e alteração de tabelas', 'Atributo derivado é obtido por processamento de dados do banco, como idade; o identificador é a chave primária e não deve ser o RG.', 2),
  ('Atributos e alteração de tabelas', 'ALTER TABLE usa ADD COLUMN, RENAME COLUMN ... TO, MODIFY COLUMN e DROP COLUMN para adicionar, renomear, modificar e excluir colunas.', 3),
  ('Atributos e alteração de tabelas', 'TRUNCATE TABLE limpa a tabela, inclusive todos os dados e registros.', 4)
) AS v(subtopic_name, text, order_index) ON v.subtopic_name = st.name
WHERE s.name = 'Banco de Dados' AND t.number = 4
ON CONFLICT DO NOTHING;

-- 5. Questões (as listas já existem)

-- Q16 | multiple_choice | fácil | INNER JOIN e junção de tabelas | Exercícios 1 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma faculdade tem as tabelas curso (idCurso, nomeCurso) e aluno (ra, nomeAluno, fkCurso). Qual consulta lista o nome de cada aluno com o nome do seu curso, mostrando apenas os alunos que têm curso correspondente?', 'O INNER JOIN liga a chave estrangeira fkCurso, de aluno, à chave primária idCurso, de curso, e retorna só os registros com correspondência.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT nomeAluno, nomeCurso FROM aluno INNER JOIN curso ON ra = idCurso;', false, 1),
  ('SELECT nomeAluno, nomeCurso FROM aluno INNER JOIN curso ON fkCurso = idCurso;', true, 2),
  ('SELECT nomeAluno, nomeCurso FROM aluno INNER JOIN curso ON ra = fkCurso;', false, 3),
  ('SELECT nomeAluno, nomeCurso FROM aluno LEFT JOIN curso ON fkCurso = idCurso;', false, 4),
  ('SELECT nomeAluno, nomeCurso FROM aluno INNER JOIN curso ON fkCurso = nomeCurso;', false, 5)
) AS o(text, is_correct, order_index);

-- Q17 | multiple_choice | fácil | LEFT JOIN e RIGHT JOIN | Exercícios 1 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma loja tem as tabelas cliente (idCliente, nome) e pedido (idPedido, fkCliente). A gerente quer listar todos os clientes, inclusive os que nunca fizeram pedido. Qual junção atende a esse pedido?', 'O LEFT JOIN mantém todos os registros da tabela da esquerda, aqui cliente, mesmo sem correspondência na tabela pedido.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('cliente INNER JOIN pedido, que retorna só os clientes com pedido', false, 1),
  ('cliente RIGHT JOIN pedido, que mantém todos os registros de pedido', false, 2),
  ('pedido LEFT JOIN cliente, que mantém todos os registros de pedido', false, 3),
  ('cliente LEFT JOIN pedido, que mantém todos os registros de cliente', true, 4),
  ('pedido INNER JOIN cliente, que retorna só os pedidos com cliente', false, 5)
) AS o(text, is_correct, order_index);

-- Q18 | single_choice | fácil | INNER JOIN e junção de tabelas | Exercícios 1 | b1: INNER JOIN, b2: ON, b3: chave estrangeira
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Para retornar somente os registros com correspondência nas duas tabelas, usa-se a sintaxe FROM tabela1 {{b1}} tabela2 {{b2}} id = fk. Nessa condição, id é a chave primária de uma tabela e fk é a {{b3}} da outra.', 'O INNER JOIN retorna só os registros com correspondência, e a cláusula ON liga a chave primária (id) à chave estrangeira (fk).'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 1: Fundamentos'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'LEFT JOIN', false, 1), ('b1', 'INNER JOIN', true, 2), ('b1', 'UNION', false, 3),
  ('b2', 'WHERE', false, 1), ('b2', 'AS', false, 2), ('b2', 'ON', true, 3),
  ('b3', 'chave estrangeira', true, 1), ('b3', 'chave primária', false, 2), ('b3', 'chave composta', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q19 | multiple_answer | fácil | LEFT JOIN e RIGHT JOIN | Exercícios 1 | corretas: A, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma consulta usa tabela1 LEFT JOIN tabela2 ON id = fk. Assinale todas as corretas.', 'O LEFT JOIN retorna todos os registros da tabela 1 e também os da tabela 2 que têm correspondência. Não retorna registros da tabela 2 sem correspondência.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Todos os registros da tabela 1 são retornados, tenham ou não correspondência', true, 1),
  ('Apenas os registros presentes nas duas tabelas são retornados, sem exceção', false, 2),
  ('Todos os registros da tabela 2 são retornados, mesmo sem correspondência', false, 3),
  ('Registros da tabela 2 sem correspondência aparecem no resultado final', false, 4),
  ('Os registros da tabela 2 com correspondência na tabela 1 também aparecem', true, 5)
) AS o(text, is_correct, order_index);

-- Q20 | drag_and_drop | fácil | FULL OUTER JOIN | Exercícios 1 | s1: registros das duas tabelas, s2: LEFT JOIN, s3: RIGHT JOIN, s4: UNION
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'O FULL OUTER JOIN retorna {{s1}}. Nos slides, o primeiro SELECT usa {{s2}}, o segundo SELECT usa {{s3}} e os dois são unidos por {{s4}}.', 'O FULL OUTER JOIN traz os registros das duas tabelas, com ou sem correspondência. Ele é montado com um LEFT JOIN e um RIGHT JOIN unidos por UNION.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('INNER JOIN', 1), ('os registros das duas tabelas, com ou sem correspondência', 2), ('UNION', 3),
    ('WHERE', 4), ('LEFT JOIN', 5), ('apenas os registros com correspondência nas duas tabelas', 6), ('RIGHT JOIN', 7)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'os registros das duas tabelas, com ou sem correspondência', 1), ('s2', 'LEFT JOIN', 2),
  ('s3', 'RIGHT JOIN', 3), ('s4', 'UNION', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q21 | multiple_choice | média | Chave estrangeira e relacionamentos | Exercícios 1 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'No modelo de uma faculdade, a tabela aluno tem as colunas ra, nomeAluno, fkEmpresa e fkCurso, ligadas às tabelas empresa e curso. O que esse modelo mostra sobre chaves estrangeiras?', 'Uma tabela pode ter várias chaves estrangeiras: aluno tem fkEmpresa e fkCurso, e a chave primária continua sendo o ra.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Uma tabela pode ter mais de uma chave estrangeira, cada uma ligada a outra tabela', true, 1),
  ('Cada tabela só pode ter uma chave estrangeira, ligada à tabela principal', false, 2),
  ('As chaves estrangeiras ficam nas tabelas empresa e curso, que são o lado N', false, 3),
  ('As colunas fkEmpresa e fkCurso formam, juntas, a chave primária de aluno', false, 4),
  ('A chave estrangeira substitui o ra na identificação de cada aluno da tabela', false, 5)
) AS o(text, is_correct, order_index);

-- Q22 | multiple_choice | média | Entidades fortes e fracas | Exercícios 1 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Em um sistema de pedidos, a tabela itens_pedido só faz sentido junto com a tabela pedido, e o identificador dela depende do identificador de pedido. Como itens_pedido é classificada?', 'Entidade fraca é a que não existe por si só e depende de outra entidade, como ITENS_PEDIDO em relação a PEDIDO.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Entidade forte, pois possui chave primária própria e independente', false, 1),
  ('Atributo derivado, pois é calculado a partir dos dados de pedido', false, 2),
  ('Entidade fraca, pois a existência dela depende da entidade pedido', true, 3),
  ('Atributo multivalorado, pois um pedido pode ter vários itens nele', false, 4),
  ('Entidade primária, pois não precisa de nenhuma outra tabela', false, 5)
) AS o(text, is_correct, order_index);

-- Q23 | single_choice | média | Chave estrangeira e relacionamentos | Exercícios 1 | b1: multivalorado, b2: fkRa, b3: 1:N
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Como um aluno pode ter vários telefones, telefone é um atributo {{b1}}. Por isso cria-se a tabela telefone com a coluna {{b2}}, que referencia o aluno, e a relação entre aluno e telefone é {{b3}}.', 'Telefone é multivalorado e vira tabela própria, com a chave estrangeira fkRa no lado N. A relação é 1:N: um aluno tem muitos telefones e cada telefone é de um só aluno.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 1: Fundamentos'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'monovalorado', false, 1), ('b1', 'multivalorado', true, 2), ('b1', 'derivado', false, 3),
  ('b2', 'idTelefone', false, 1), ('b2', 'telefone', false, 2), ('b2', 'fkRa', true, 3),
  ('b3', '1:1', false, 1), ('b3', '1:N', true, 2), ('b3', 'N:N', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q24 | drag_and_drop | média | Atributos e alteração de tabelas | Exercícios 1 | s1: ADD COLUMN, s2: RENAME COLUMN, s3: DROP COLUMN
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Para adicionar uma coluna: ALTER TABLE Aluno {{s1}} dtNasc DATE; para renomeá-la: ALTER TABLE Aluno {{s2}} dtNasc TO dtNascimento; para excluí-la: ALTER TABLE Aluno {{s3}} dtNascimento;', 'ADD COLUMN adiciona a coluna, RENAME COLUMN ... TO muda o nome e DROP COLUMN exclui a coluna. MODIFY COLUMN altera o tipo, e TRUNCATE TABLE limpa os dados.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('MODIFY COLUMN', 1), ('DROP COLUMN', 2), ('TRUNCATE TABLE', 3), ('ADD COLUMN', 4), ('RENAME COLUMN', 5)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'ADD COLUMN', 1), ('s2', 'RENAME COLUMN', 2), ('s3', 'DROP COLUMN', 3)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q25 | multiple_answer | fácil | Atributos e alteração de tabelas | Exercícios 1 | corretas: B, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Sobre os tipos de atributos em modelagem de dados, assinale todas as corretas.', 'O atributo composto pode ser dividido em subpartes e o derivado é obtido por processamento dos dados, como a idade. O atômico não se divide, o monovalorado tem um só valor e o RG não é bom identificador, pois pode se repetir entre estados.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('O atributo atômico pode ser dividido em subpartes, como o endereço', false, 1),
  ('O atributo composto pode ser dividido em rua, cidade, estado e CEP', true, 2),
  ('O atributo monovalorado pode ter mais de um valor, como o telefone', false, 3),
  ('O atributo derivado tem valor obtido por processamento, como a idade', true, 4),
  ('O atributo identificador deve ser o RG, pois ele é único em todo o país', false, 5)
) AS o(text, is_correct, order_index);

-- Q26 | multiple_choice | difícil | INNER JOIN e junção de tabelas | Exercícios 2 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'A faculdade tem aluno (ra, nomeAluno, fkEmpresa, fkCurso), empresa (idEmpresa, nomeEmpresa) e curso (idCurso, nomeCurso). Qual consulta lista aluno, empresa e curso somente dos alunos que têm os dois vínculos?', 'Cada INNER JOIN liga uma FK de aluno à PK correspondente: fkEmpresa com idEmpresa e fkCurso com idCurso. Só os alunos com os dois vínculos permanecem.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT nomeAluno, nomeEmpresa, nomeCurso FROM aluno INNER JOIN empresa ON fkEmpresa = idEmpresa INNER JOIN curso ON fkEmpresa = idCurso;', false, 1),
  ('SELECT nomeAluno, nomeEmpresa, nomeCurso FROM aluno INNER JOIN empresa ON fkCurso = idEmpresa INNER JOIN curso ON fkEmpresa = idCurso;', false, 2),
  ('SELECT nomeAluno, nomeEmpresa, nomeCurso FROM aluno INNER JOIN empresa ON ra = idEmpresa INNER JOIN curso ON ra = idCurso;', false, 3),
  ('SELECT nomeAluno, nomeEmpresa, nomeCurso FROM aluno LEFT JOIN empresa ON fkEmpresa = idEmpresa LEFT JOIN curso ON fkCurso = idCurso;', false, 4),
  ('SELECT nomeAluno, nomeEmpresa, nomeCurso FROM aluno INNER JOIN empresa ON fkEmpresa = idEmpresa INNER JOIN curso ON fkCurso = idCurso;', true, 5)
) AS o(text, is_correct, order_index);

-- Q27 | multiple_choice | difícil | LEFT JOIN e RIGHT JOIN | Exercícios 2 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma loja tem cliente (idCliente, nome) e pedido (idPedido, fkCliente). Qual consulta lista apenas os clientes que nunca fizeram pedido?', 'O LEFT JOIN mantém todos os clientes, e WHERE fkCliente IS NULL deixa só os que não encontraram pedido. Com INNER JOIN o resultado seria vazio, pois não há registros sem correspondência.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT nome FROM cliente INNER JOIN pedido ON idCliente = fkCliente WHERE fkCliente IS NULL;', false, 1),
  ('SELECT nome FROM cliente LEFT JOIN pedido ON idCliente = fkCliente WHERE fkCliente IS NULL;', true, 2),
  ('SELECT nome FROM cliente RIGHT JOIN pedido ON idCliente = fkCliente WHERE fkCliente IS NULL;', false, 3),
  ('SELECT nome FROM cliente LEFT JOIN pedido ON idCliente = fkCliente WHERE idCliente IS NULL;', false, 4),
  ('SELECT nome FROM pedido LEFT JOIN cliente ON idCliente = fkCliente WHERE fkCliente IS NULL;', false, 5)
) AS o(text, is_correct, order_index);

-- Q28 | multiple_choice | difícil | Chave estrangeira e relacionamentos | Exercícios 2 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Existem aluno (ra, nomeAluno) e telefone (idTelefone, telefone, fkRa), com relação 1:N. Qual consulta lista cada aluno com seus telefones, mantendo também os alunos sem telefone?', 'Para manter todos os alunos usa-se LEFT JOIN com aluno à esquerda, e o ON liga a chave primária ra à chave estrangeira fkRa, que fica no lado N.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT nomeAluno, telefone FROM aluno INNER JOIN telefone ON ra = fkRa;', false, 1),
  ('SELECT nomeAluno, telefone FROM aluno LEFT JOIN telefone ON ra = idTelefone;', false, 2),
  ('SELECT nomeAluno, telefone FROM aluno LEFT JOIN telefone ON fkRa = idTelefone;', false, 3),
  ('SELECT nomeAluno, telefone FROM aluno LEFT JOIN telefone ON ra = fkRa;', true, 4),
  ('SELECT nomeAluno, telefone FROM telefone LEFT JOIN aluno ON ra = fkRa;', false, 5)
) AS o(text, is_correct, order_index);

-- Q29 | multiple_choice | difícil | Autorelacionamento | Exercícios 2 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Na tabela funcionario (idFunc, nome, fkGerente), a coluna fkGerente guarda o idFunc do gerente de cada funcionário. Qual consulta lista cada funcionário com o nome do seu gerente, apenas de quem tem gerente?', 'No autorelacionamento a tabela aparece duas vezes, com apelidos: f é o funcionário e g é o gerente. O INNER JOIN com f.fkGerente = g.idFunc descarta quem não tem gerente.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT f.nome, g.nome FROM funcionario f INNER JOIN funcionario g ON f.fkGerente = g.idFunc;', true, 1),
  ('SELECT f.nome, g.nome FROM funcionario f INNER JOIN funcionario g ON f.idFunc = g.idFunc;', false, 2),
  ('SELECT f.nome, g.nome FROM funcionario f INNER JOIN funcionario g ON g.fkGerente = f.idFunc;', false, 3),
  ('SELECT nome, nome FROM funcionario INNER JOIN funcionario ON fkGerente = idFunc;', false, 4),
  ('SELECT f.nome, g.nome FROM funcionario f LEFT JOIN funcionario g ON f.fkGerente = g.idFunc;', false, 5)
) AS o(text, is_correct, order_index);

-- Q30 | multiple_answer | difícil | INNER JOIN e junção de tabelas | Exercícios 2 | corretas: A, B, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Considere aluno (ra, nomeAluno, fkCurso), curso (idCurso, nomeCurso) e a consulta SELECT nomeAluno, nomeCurso FROM aluno INNER JOIN curso ON fkCurso = idCurso; Assinale todas as corretas.', 'O INNER JOIN retorna só a interseção: aluno sem curso e curso sem alunos ficam de fora. O ON liga a FK de aluno à PK de curso.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Um aluno sem curso (fkCurso nulo) não aparece no resultado da consulta', true, 1),
  ('Um curso sem nenhum aluno também não aparece no resultado da consulta', true, 2),
  ('Um curso sem nenhum aluno aparece com o nomeAluno nulo no resultado', false, 3),
  ('O ON liga a chave estrangeira de aluno à chave primária de curso', true, 4),
  ('Trocar a ordem das tabelas transforma a consulta em um LEFT JOIN', false, 5)
) AS o(text, is_correct, order_index);

-- Q31 | multiple_answer | difícil | LEFT JOIN e RIGHT JOIN | Exercícios 2 | corretas: C, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Com cliente (idCliente, nome) e pedido (idPedido, fkCliente), assinale todas as corretas sobre as junções entre cliente e pedido.', 'O RIGHT JOIN mantém todos os pedidos. O LEFT JOIN com WHERE fkCliente IS NULL deixa só os clientes sem pedido; as outras alternativas invertem o efeito do lado ou do IS NULL.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('cliente RIGHT JOIN pedido retorna todos os clientes, mesmo os sem pedido', false, 1),
  ('cliente LEFT JOIN pedido com idCliente IS NULL retorna clientes sem pedido', false, 2),
  ('cliente RIGHT JOIN pedido retorna todos os pedidos, mesmo sem cliente ligado', true, 3),
  ('cliente LEFT JOIN pedido com fkCliente IS NULL retorna só clientes com pedido', false, 4),
  ('cliente LEFT JOIN pedido com fkCliente IS NULL retorna só clientes sem pedido', true, 5)
) AS o(text, is_correct, order_index);

-- Q32 | drag_and_drop | difícil | Chave estrangeira e relacionamentos | Exercícios 2 | s1: fkRa, s2: telefone, s3: fkEndereco, s4: aluno
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Na relação 1:N entre aluno e telefone, a chave estrangeira {{s1}} fica na tabela {{s2}}. Na relação entre aluno e endereço, em que um mesmo endereço pode ser de vários alunos (irmãos), a chave estrangeira {{s3}} fica na tabela {{s4}}.', 'A chave estrangeira sempre fica no lado N: fkRa em telefone, pois um aluno tem vários telefones, e fkEndereco em aluno, pois um endereço pode ter vários alunos.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('idEndereco', 1), ('aluno', 2), ('fkRa', 3), ('idTelefone', 4), ('telefone', 5), ('fkEndereco', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'fkRa', 1), ('s2', 'telefone', 2), ('s3', 'fkEndereco', 3), ('s4', 'aluno', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q33 | drag_and_drop | difícil | INNER JOIN e junção de tabelas | Exercícios 2 | s1: SELECT, s2: FROM, s3: INNER JOIN, s4: ON
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Para listar apenas os alunos que têm curso correspondente: {{s1}} nomeAluno, nomeCurso {{s2}} aluno {{s3}} curso {{s4}} fkCurso = idCurso;', 'A consulta usa SELECT para as colunas, FROM para a primeira tabela, INNER JOIN para a segunda e ON para ligar a FK à PK. O LEFT JOIN manteria também os alunos sem curso.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('LEFT JOIN', 1), ('ON', 2), ('WHERE', 3), ('SELECT', 4), ('UNION', 5), ('INNER JOIN', 6), ('FROM', 7)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'SELECT', 1), ('s2', 'FROM', 2), ('s3', 'INNER JOIN', 3), ('s4', 'ON', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q34 | single_choice | difícil | Autorelacionamento | Exercícios 2 | b1: apelidos (aliases), b2: LEFT JOIN, b3: fkGerente
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Na consulta de autorelacionamento sobre funcionario (idFunc, nome, fkGerente), a mesma tabela aparece duas vezes e é diferenciada por {{b1}}. Para incluir também quem não tem gerente, usa-se {{b2}} entre funcionario f e funcionario g, e a condição é f.{{b3}} = g.idFunc.', 'Os apelidos permitem tratar a mesma tabela como duas. O LEFT JOIN mantém quem não tem gerente, e a FK fkGerente de f é comparada com a PK idFunc de g.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 2: Aplicação'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'chaves primárias', false, 1), ('b1', 'apelidos (aliases)', true, 2), ('b1', 'constraints', false, 3),
  ('b2', 'INNER JOIN', false, 1), ('b2', 'RIGHT JOIN', false, 2), ('b2', 'LEFT JOIN', true, 3), ('b2', 'UNION', false, 4),
  ('b3', 'idFunc', false, 1), ('b3', 'nome', false, 2), ('b3', 'fkGerente', true, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q35 | drag_and_drop | difícil | Autorelacionamento | Exercícios 2 | s1: idFunc, s2: fkGerente, s3: a própria tabela funcionario, s4: g.idFunc
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Em funcionario, {{s1}} é a chave primária; {{s2}} é a chave estrangeira, que referencia {{s3}}; e a junção que traz o gerente de cada funcionário usa ON f.fkGerente = {{s4}}.', 'No autorelacionamento, a chave estrangeira fkGerente referencia a chave primária idFunc da própria tabela. Na junção, a FK de f é comparada com g.idFunc.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('f.idFunc', 1), ('g.idFunc', 2), ('nome', 3), ('fkGerente', 4),
    ('outra tabela chamada gerente', 5), ('idFunc', 6), ('a própria tabela funcionario', 7)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'idFunc', 1), ('s2', 'fkGerente', 2), ('s3', 'a própria tabela funcionario', 3), ('s4', 'g.idFunc', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q36 | multiple_choice | super difícil | LEFT JOIN e RIGHT JOIN | Exercícios 3 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma empresa tem departamento (idDepto, nomeDepto) e funcionario (idFunc, nome, fkDepto). Qual consulta, usando RIGHT JOIN, lista apenas os departamentos que não têm nenhum funcionário?', 'Em funcionario RIGHT JOIN departamento, todos os departamentos são mantidos. Os sem funcionário ficam com fkDepto nulo, e WHERE fkDepto IS NULL isola esses casos.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT nomeDepto FROM departamento RIGHT JOIN funcionario ON idDepto = fkDepto WHERE fkDepto IS NULL;', false, 1),
  ('SELECT nomeDepto FROM funcionario RIGHT JOIN departamento ON idDepto = fkDepto WHERE idDepto IS NULL;', false, 2),
  ('SELECT nomeDepto FROM funcionario RIGHT JOIN departamento ON idDepto = fkDepto WHERE fkDepto IS NULL;', true, 3),
  ('SELECT nomeDepto FROM funcionario LEFT JOIN departamento ON idDepto = fkDepto WHERE fkDepto IS NULL;', false, 4),
  ('SELECT nomeDepto FROM funcionario RIGHT JOIN departamento ON idDepto = fkDepto WHERE fkDepto IS NOT NULL;', false, 5)
) AS o(text, is_correct, order_index);

-- Q37 | multiple_choice | super difícil | FULL OUTER JOIN | Exercícios 3 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Com cliente (idCliente, nome) e pedido (idPedido, fkCliente), qual consulta, no estilo dos slides, retorna todos os clientes e todos os pedidos, com ou sem correspondência?', 'O FULL OUTER JOIN dos slides une, por UNION, um SELECT com LEFT JOIN e outro com RIGHT JOIN, sem filtro IS NULL. Com o filtro, só os registros sem correspondência apareceriam.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT nome, idPedido FROM cliente LEFT JOIN pedido ON idCliente = fkCliente WHERE fkCliente IS NULL UNION SELECT nome, idPedido FROM cliente RIGHT JOIN pedido ON idCliente = fkCliente WHERE fkCliente IS NULL;', false, 1),
  ('SELECT nome, idPedido FROM cliente INNER JOIN pedido ON idCliente = fkCliente UNION SELECT nome, idPedido FROM cliente INNER JOIN pedido ON idCliente = fkCliente;', false, 2),
  ('SELECT nome, idPedido FROM cliente LEFT JOIN pedido ON idCliente = fkCliente UNION SELECT nome, idPedido FROM cliente LEFT JOIN pedido ON idCliente = fkCliente;', false, 3),
  ('SELECT nome, idPedido FROM cliente RIGHT JOIN pedido ON idCliente = fkCliente UNION SELECT nome, idPedido FROM cliente RIGHT JOIN pedido ON idCliente = fkCliente;', false, 4),
  ('SELECT nome, idPedido FROM cliente LEFT JOIN pedido ON idCliente = fkCliente UNION SELECT nome, idPedido FROM cliente RIGHT JOIN pedido ON idCliente = fkCliente;', true, 5)
) AS o(text, is_correct, order_index);

-- Q38 | multiple_choice | super difícil | Autorelacionamento | Exercícios 3 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Na tabela funcionario (idFunc, nome, fkGerente), qual consulta lista os funcionários que não têm gerente cadastrado, usando o autorelacionamento?', 'O LEFT JOIN com f.fkGerente = g.idFunc mantém todos os funcionários, e WHERE g.idFunc IS NULL isola os que não encontraram gerente. Com INNER JOIN o resultado seria vazio.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT f.nome FROM funcionario f INNER JOIN funcionario g ON f.fkGerente = g.idFunc WHERE g.idFunc IS NULL;', false, 1),
  ('SELECT f.nome FROM funcionario f LEFT JOIN funcionario g ON f.fkGerente = g.idFunc WHERE g.idFunc IS NULL;', true, 2),
  ('SELECT f.nome FROM funcionario f LEFT JOIN funcionario g ON f.idFunc = g.idFunc WHERE g.idFunc IS NULL;', false, 3),
  ('SELECT g.nome FROM funcionario f LEFT JOIN funcionario g ON f.fkGerente = g.idFunc WHERE g.idFunc IS NULL;', false, 4),
  ('SELECT f.nome FROM funcionario f RIGHT JOIN funcionario g ON f.fkGerente = g.idFunc WHERE f.idFunc IS NULL;', false, 5)
) AS o(text, is_correct, order_index);

-- Q39 | multiple_choice | super difícil | Entidades fortes e fracas | Exercícios 3 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Em um sistema que cadastra alunos de várias faculdades (Sptech, Fatec, USP), o mesmo RA pode existir em faculdades diferentes. A tabela aluno tem chave primária composta (fkFaculdade, ra) e faculdade tem (idFaculdade, nomeFaculdade). Qual alternativa classifica aluno e escreve a junção corretamente?', 'Como o ra se repete entre faculdades, ele sozinho não identifica o aluno: aluno é entidade fraca, com chave composta (fkFaculdade, ra). A junção liga a FK fkFaculdade à PK idFaculdade.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Entidade forte, pois o ra identifica o aluno; junção: ON ra = idFaculdade', false, 1),
  ('Entidade forte, pois o ra identifica o aluno; junção: ON fkFaculdade = idFaculdade', false, 2),
  ('Entidade fraca, pois o ra sozinho não identifica o aluno; junção: ON ra = idFaculdade', false, 3),
  ('Entidade fraca, pois o ra sozinho não identifica o aluno; junção: ON fkFaculdade = idFaculdade', true, 4),
  ('Entidade fraca, pois não tem chave estrangeira; junção: ON fkFaculdade = ra', false, 5)
) AS o(text, is_correct, order_index);

-- Q40 | multiple_answer | super difícil | FULL OUTER JOIN | Exercícios 3 | corretas: A, C, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Sobre o FULL OUTER JOIN entre tabela1 e tabela2, como mostrado nos slides, assinale todas as corretas.', 'O FULL OUTER JOIN é um LEFT JOIN unido a um RIGHT JOIN por UNION e retorna registros com e sem correspondência. Com WHERE fk IS NULL nos dois SELECTs, retorna só os sem correspondência. Ele não equivale ao INNER JOIN.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Ele é montado com um LEFT JOIN e um RIGHT JOIN unidos por UNION', true, 1),
  ('Ele equivale a um INNER JOIN, pois retorna só a interseção das tabelas', false, 2),
  ('Com WHERE fk IS NULL em cada SELECT, retorna só os registros sem correspondência', true, 3),
  ('Com WHERE fk IS NULL em cada SELECT, retorna também os que têm correspondência', false, 4),
  ('Sem o WHERE, o resultado inclui registros com e sem correspondência', true, 5)
) AS o(text, is_correct, order_index);

-- Q41 | multiple_answer | super difícil | Autorelacionamento | Exercícios 3 | corretas: B, D, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Sobre o autorelacionamento na tabela funcionario (idFunc, nome, fkGerente), assinale todas as corretas.', 'No autorelacionamento a FK fkGerente referencia a PK da própria tabela. Os apelidos permitem usar a tabela duas vezes na junção, e o LEFT JOIN mantém quem não tem gerente.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A tabela funcionario não pode ter chave estrangeira, pois existe só uma tabela', false, 1),
  ('fkGerente é chave estrangeira e referencia a chave primária idFunc da mesma tabela', true, 2),
  ('Na consulta, a tabela aparece uma única vez, sem apelidos, nos dois papéis', false, 3),
  ('Apelidos diferentes, como f e g, permitem tratar a tabela como se fossem duas', true, 4),
  ('Com LEFT JOIN, o funcionário sem gerente continua no resultado, com gerente nulo', true, 5)
) AS o(text, is_correct, order_index);

-- Q42 | drag_and_drop | super difícil | FULL OUTER JOIN | Exercícios 3 | s1: LEFT JOIN, s2: WHERE, s3: UNION, s4: RIGHT JOIN
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Para retornar apenas os registros sem correspondência dos dois lados: SELECT nome_da_coluna FROM tabela1 {{s1}} tabela2 ON id = fk {{s2}} fk IS NULL {{s3}} SELECT nome_da_coluna FROM tabela1 {{s4}} tabela2 ON id = fk WHERE fk IS NULL;', 'O primeiro SELECT usa LEFT JOIN com WHERE fk IS NULL, o segundo usa RIGHT JOIN com o mesmo filtro, e o UNION junta os dois resultados.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('INNER JOIN', 1), ('UNION', 2), ('AND', 3), ('RIGHT JOIN', 4), ('WHERE', 5), ('LEFT JOIN', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'LEFT JOIN', 1), ('s2', 'WHERE', 2), ('s3', 'UNION', 3), ('s4', 'RIGHT JOIN', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q43 | drag_and_drop | super difícil | Autorelacionamento | Exercícios 3 | s1: f, s2: g, s3: f.fkGerente, s4: g.idFunc
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'A consulta lista cada funcionário (apelido f) e seu gerente (apelido g), mesmo sem gerente, com a chave estrangeira à esquerda da igualdade: SELECT f.nome, g.nome FROM funcionario {{s1}} LEFT JOIN funcionario {{s2}} ON {{s3}} = {{s4}};', 'f é o funcionário e g é o gerente. A chave estrangeira f.fkGerente é comparada com a chave primária g.idFunc, e o LEFT JOIN mantém quem não tem gerente.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('g.fkGerente', 1), ('g.idFunc', 2), ('f', 3), ('f.idFunc', 4), ('g', 5), ('f.fkGerente', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'f', 1), ('s2', 'g', 2), ('s3', 'f.fkGerente', 3), ('s4', 'g.idFunc', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q44 | single_choice | super difícil | LEFT JOIN e RIGHT JOIN | Exercícios 3 | b1: LEFT JOIN, b2: fkDepto, b3: RIGHT JOIN
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Com departamento (idDepto, nomeDepto) e funcionario (idFunc, nome, fkDepto): para listar todos os departamentos, inclusive os sem funcionários, escreve-se departamento {{b1}} funcionario ON idDepto = fkDepto; para listar só os departamentos sem funcionários, acrescenta-se WHERE {{b2}} IS NULL; e para listar todos os funcionários, inclusive os sem departamento, escreve-se departamento {{b3}} funcionario ON idDepto = fkDepto.', 'LEFT JOIN mantém todos os registros da tabela da esquerda (departamento) e WHERE fkDepto IS NULL isola os sem correspondência. RIGHT JOIN mantém todos os da direita (funcionario).'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 3: Desafio'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'RIGHT JOIN', false, 1), ('b1', 'INNER JOIN', false, 2), ('b1', 'LEFT JOIN', true, 3),
  ('b2', 'idDepto', false, 1), ('b2', 'fkDepto', true, 2), ('b2', 'nomeDepto', false, 3),
  ('b3', 'LEFT JOIN', false, 1), ('b3', 'RIGHT JOIN', true, 2), ('b3', 'INNER JOIN', false, 3), ('b3', 'UNION', false, 4)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q45 | drag_and_drop | super difícil | Entidades fortes e fracas | Exercícios 3 | s1: fraca, s2: composta (fkFaculdade, ra), s3: forte, s4: identificador
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Em um sistema com várias faculdades, o mesmo RA pode se repetir. Por isso aluno é uma entidade {{s1}} e sua chave primária é {{s2}}. Já faculdade é uma entidade {{s3}}, e o relacionamento entre as duas é do tipo {{s4}}.', 'Como o RA se repete entre faculdades, aluno é fraca e usa chave composta (fkFaculdade, ra). Faculdade tem chave própria, logo é forte, e o relacionamento entre forte e fraca é o identificador.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Constraints e Controle de Acesso (DCL) — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('forte', 1), ('somente o ra', 2), ('identificador', 3), ('derivada', 4),
    ('fraca', 5), ('composta (fkFaculdade, ra)', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'fraca', 1), ('s2', 'composta (fkFaculdade, ra)', 2), ('s3', 'forte', 3), ('s4', 'identificador', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- 6. Conferência: aborta se alguma questão ficou fora das listas ou alguma lista ficou vazia
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM questions q
    JOIN topics t ON t.id = q.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Banco de Dados' AND t.number = 4
      AND NOT EXISTS (
        SELECT 1 FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
        WHERE qq.question_id = q.id AND z.kind = 'exercise'
      )
  ) THEN
    RAISE EXCEPTION 'Há questão da aula 4 de Banco de Dados fora das listas de exercícios';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM quizzes z
    JOIN topics t ON t.id = z.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Banco de Dados' AND t.number = 4 AND z.kind = 'exercise'
      AND NOT EXISTS (SELECT 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  ) THEN
    RAISE EXCEPTION 'Há lista de exercícios da aula 4 de Banco de Dados sem questões';
  END IF;

  IF (
    SELECT COUNT(*) FROM questions q
    JOIN topics t ON t.id = q.topic_id JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Banco de Dados' AND t.number = 4
  ) <> 45 THEN
    RAISE EXCEPTION 'A aula 4 de Banco de Dados deveria ter 45 questões após este script';
  END IF;
END $$;

COMMIT;
