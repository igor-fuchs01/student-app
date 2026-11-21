-- Banco de Dados — simulado "Simulado das atividades sprint3": 19 questões de múltipla escolha, 40 minutos,
-- nível médio, sprint 3. Tema: GROUP BY, HAVING, funções de agregação, JOINs, subconsultas e
-- filtros de data, com sintaxe de MySQL 8.
-- As questões são criadas aqui, na aula "Funções, GROUP BY, Subqueries, Views e Relacionamento N:M"
-- (localizada pelo nome), e entram só neste simulado: nenhuma lista de exercícios muda.
-- Todas as alternativas com SQL foram executadas no MySQL 8.4 com ONLY_FULL_GROUP_BY ativo (como no
-- Workbench), sobre dados de exemplo, para conferir que só o gabarito atende ao enunciado.
-- Ajustes feitos sobre o material original, depois dessa execução:
--   Q2: alternativa D (a alternativa D original (MATRICULAS RIGHT JOIN PLANOS) é equivalente à A e devolve o mesmo resultado).
--   Q3: alternativa C (a alternativa C original dá as mesmas médias que a A, porque AVG já ignora nulos; só lista, com média NULL, a pesquisa sem nota).
--   Q6: só a explicação (a alternativa D roda sem erro: não retorna várias linhas, retorna vazio).
--   Q13: alternativa E (as alternativas C e E originais são idênticas).
--   Q16: alternativa A (a alternativa A original (LIKE '2025-03%') funciona no MySQL e dá o mesmo resultado que a E).
--   Q17: alternativa C (a alternativa C original (apelidos no GROUP BY e no HAVING) é aceita pelo MySQL e dá o mesmo resultado que a B).
-- Uma única transação: se qualquer comando falhar, nada é gravado.

BEGIN;

-- 1. Trava: aborta se o simulado já existir ou se a aula não for encontrada
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM quizzes WHERE title = 'Simulado das atividades sprint3') THEN
    RAISE EXCEPTION 'O simulado "Simulado das atividades sprint3" já existe';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM topics t JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  ) THEN
    RAISE EXCEPTION 'A aula "Funções, GROUP BY, Subqueries, Views e Relacionamento N:M" de Banco de Dados não foi encontrada';
  END IF;
END $$;

-- 2. Simulado e sprint
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT 'Simulado das atividades sprint3', 'exam', s.id, NULL, 40, 'medium'::difficulty_level
FROM subjects s WHERE s.name = 'Banco de Dados';

INSERT INTO quiz_sprints (quiz_id, sprint)
SELECT z.id, s.sprint FROM quizzes z CROSS JOIN (VALUES (3)) AS s(sprint)
WHERE z.kind = 'exam' AND z.title = 'Simulado das atividades sprint3';

-- 3. Questões, na ordem do simulado: cada uma é um comando, com o comentário "número | correta".
-- O CTE "l" põe a questão no fim do simulado.

-- Q1 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Cenário: Tênis (Tabelas: JOGADORES J, RESULTADOS R). Qual consulta SQL lista os nomes dos jogadores que possuem mais de 5 vitórias?',
    'Filtro sobre agregação usa HAVING depois do GROUP BY. A compara o ID e não a contagem, B usa COUNT no WHERE e D usa HAVING sem GROUP BY.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Simulado das atividades sprint3'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT J.nome_jogador FROM JOGADORES J JOIN RESULTADOS R ON J.id_jogador = R.vencedor_id WHERE R.vencedor_id > 5;', false, 1),
  ('SELECT J.nome_jogador FROM JOGADORES J JOIN RESULTADOS R ON J.id_jogador = R.vencedor_id WHERE COUNT(R.vencedor_id) > 5 GROUP BY J.nome_jogador;', false, 2),
  ('SELECT J.nome_jogador FROM JOGADORES J JOIN RESULTADOS R ON J.id_jogador = R.vencedor_id GROUP BY J.nome_jogador HAVING COUNT(R.vencedor_id) > 5;', true, 3),
  ('SELECT J.nome_jogador FROM JOGADORES J JOIN RESULTADOS R ON J.id_jogador = R.vencedor_id HAVING COUNT(R.vencedor_id) > 5;', false, 4)
) AS o(text, is_correct, order_index);

-- Q2 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Cenário: Academia (Tabelas: PLANOS P, MATRICULAS M). Qual consulta SQL lista o título do plano e o número de alunos que o possuem, incluindo planos que não têm alunos (contagem zero)?',
    'Para manter planos sem alunos é preciso LEFT JOIN a partir de PLANOS. B não tem JOIN, C usa INNER JOIN, que descarta planos sem alunos, e D faz o LEFT JOIN a partir de MATRICULAS, que também descarta planos sem alunos.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Simulado das atividades sprint3'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT P.titulo, COUNT(M.id_aluno) AS total_alunos FROM PLANOS P LEFT JOIN MATRICULAS M ON P.id_plano = M.id_plano GROUP BY P.titulo;', true, 1),
  ('SELECT P.titulo, COUNT(M.id_aluno) AS total_alunos FROM PLANOS P WHERE M.id_aluno IS NULL GROUP BY P.titulo;', false, 2),
  ('SELECT P.titulo, COUNT(M.id_aluno) AS total_alunos FROM PLANOS P JOIN MATRICULAS M ON P.id_plano = M.id_plano GROUP BY P.titulo;', false, 3),
  ('SELECT P.titulo, COUNT(M.id_aluno) AS total_alunos FROM MATRICULAS M LEFT JOIN PLANOS P ON P.id_plano = M.id_plano GROUP BY P.titulo;', false, 4)
) AS o(text, is_correct, order_index);

-- Q3 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Cenário: Pesquisa (Tabelas: PESQUISAS P, RESPOSTAS R, SESSAO_RESPOSTA SR). Qual consulta SQL lista o título da pesquisa e a nota média obtida para a pergunta de ID = 1 em cada pesquisa?',
    'O filtro da pergunta 1 deve ficar no WHERE, antes do agrupamento, e a nota nula é descartada. B não filtra a pergunta, C usa OR e mistura as notas das outras perguntas, e D usa HAVING com coluna fora do GROUP BY.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Simulado das atividades sprint3'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT P.titulo, AVG(R.nota_resposta) AS media_nota FROM PESQUISAS P JOIN SESSAO_RESPOSTA SR ON P.id_pesquisa = SR.id_pesquisa JOIN RESPOSTAS R ON SR.id_sessao = R.id_sessao WHERE R.id_pergunta = 1 AND R.nota_resposta IS NOT NULL GROUP BY P.titulo;', true, 1),
  ('SELECT P.titulo, AVG(R.nota_resposta) AS media_nota FROM PESQUISAS P JOIN SESSAO_RESPOSTA SR ON P.id_pesquisa = SR.id_pesquisa JOIN RESPOSTAS R ON SR.id_sessao = R.id_sessao WHERE R.nota_resposta IS NOT NULL GROUP BY P.titulo;', false, 2),
  ('SELECT P.titulo, AVG(R.nota_resposta) AS media_nota FROM PESQUISAS P JOIN SESSAO_RESPOSTA SR ON P.id_pesquisa = SR.id_pesquisa JOIN RESPOSTAS R ON SR.id_sessao = R.id_sessao WHERE R.id_pergunta = 1 OR R.nota_resposta IS NOT NULL GROUP BY P.titulo;', false, 3),
  ('SELECT P.titulo, AVG(R.nota_resposta) AS media_nota FROM PESQUISAS P JOIN SESSAO_RESPOSTA SR ON P.id_pesquisa = SR.id_pesquisa JOIN RESPOSTAS R ON SR.id_sessao = R.id_sessao GROUP BY P.titulo HAVING R.id_pergunta = 1;', false, 4)
) AS o(text, is_correct, order_index);

-- Q4 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Cenário: Academia (Tabelas: ALUNOS A, PAGAMENTOS PG). Qual consulta SQL lista os nomes dos alunos cuja média de valor pago por pagamento é superior a R$ 300,00?',
    'A média por aluno exige GROUP BY e filtro com HAVING AVG(...). A não tem GROUP BY, B usa AVG no WHERE e C filtra pagamentos individuais.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Simulado das atividades sprint3'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT A.nome_aluno FROM ALUNOS A JOIN MATRICULAS M ON A.id_aluno = M.id_aluno JOIN PAGAMENTOS PG ON M.id_matricula = PG.id_matricula HAVING SUM(PG.valor_pago) / COUNT(PG.id_pagamento) > 300.00;', false, 1),
  ('SELECT A.nome_aluno FROM ALUNOS A JOIN MATRICULAS M ON A.id_aluno = M.id_aluno JOIN PAGAMENTOS PG ON M.id_matricula = PG.id_matricula WHERE AVG(PG.valor_pago) > 300.00 GROUP BY A.nome_aluno;', false, 2),
  ('SELECT A.nome_aluno, AVG(PG.valor_pago) FROM ALUNOS A JOIN MATRICULAS M ON A.id_aluno = M.id_aluno JOIN PAGAMENTOS PG ON M.id_matricula = PG.id_matricula WHERE PG.valor_pago > 300.00 GROUP BY A.nome_aluno;', false, 3),
  ('SELECT A.nome_aluno FROM ALUNOS A JOIN MATRICULAS M ON A.id_aluno = M.id_aluno JOIN PAGAMENTOS PG ON M.id_matricula = PG.id_matricula GROUP BY A.nome_aluno HAVING AVG(PG.valor_pago) > 300.00;', true, 4)
) AS o(text, is_correct, order_index);

-- Q5 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Cenário: Tênis (Tabela: JOGADORES). Qual consulta SQL calcula a idade média dos jogadores, arredondada para uma casa decimal?',
    'ROUND(AVG(idade), 1) calcula a média e arredonda para 1 casa. A não arredonda, B arredonda para 2 casas e C aplica AVG sobre uma data, o que não dá idade.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Simulado das atividades sprint3'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT AVG(TIMESTAMPDIFF(YEAR, data_nascimento, CURDATE())) AS idade_media FROM JOGADORES;', false, 1),
  ('SELECT ROUND(SUM(TIMESTAMPDIFF(YEAR, data_nascimento, CURDATE())) / COUNT(*), 2) AS idade_media FROM JOGADORES;', false, 2),
  ('SELECT TRUNCATE(AVG(data_nascimento), 1) AS idade_media FROM JOGADORES;', false, 3),
  ('SELECT ROUND(AVG(TIMESTAMPDIFF(YEAR, data_nascimento, CURDATE())), 1) AS idade_media FROM JOGADORES;', true, 4)
) AS o(text, is_correct, order_index);

-- Q6 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Cenário: Academia (Tabelas: ALUNOS A, PLANOS P). Qual consulta SQL lista os nomes dos alunos que possuem um plano cujo preço é superior ao preço médio de todos os planos?',
    'A média global exige subconsulta escalar no WHERE. A usa AVG direto no WHERE, B usa coluna fora do GROUP BY no HAVING e D usa P.preco da consulta externa dentro da subconsulta, então compara o preço com ele mesmo e não retorna nenhum aluno.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Simulado das atividades sprint3'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT A.nome_aluno FROM ALUNOS A JOIN MATRICULAS M ON A.id_aluno = M.id_aluno JOIN PLANOS P ON M.id_plano = P.id_plano WHERE P.preco > AVG(P.preco);', false, 1),
  ('SELECT A.nome_aluno FROM ALUNOS A JOIN MATRICULAS M ON A.id_aluno = M.id_aluno JOIN PLANOS P ON M.id_plano = P.id_plano GROUP BY A.nome_aluno HAVING P.preco > (SELECT AVG(preco) FROM PLANOS);', false, 2),
  ('SELECT A.nome_aluno FROM ALUNOS A JOIN MATRICULAS M ON A.id_aluno = M.id_aluno JOIN PLANOS P ON M.id_plano = P.id_plano WHERE P.preco > (SELECT AVG(preco) FROM PLANOS);', true, 3),
  ('SELECT A.nome_aluno FROM ALUNOS A JOIN MATRICULAS M ON A.id_aluno = M.id_aluno JOIN PLANOS P ON M.id_plano = P.id_plano WHERE P.preco > (SELECT P.preco FROM PLANOS GROUP BY P.preco);', false, 4)
) AS o(text, is_correct, order_index);

-- Q7 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Cenário: Pesquisa (Tabela: CONSUMIDORES). Qual consulta SQL lista as cidades que tiveram mais de 2 consumidores registrados?',
    'Contagem por grupo é filtrada com HAVING após o GROUP BY. B, C e D usam COUNT no WHERE.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Simulado das atividades sprint3'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT cidade, COUNT(id_consumidor) AS total_consumidores FROM CONSUMIDORES GROUP BY cidade HAVING COUNT(id_consumidor) > 2;', true, 1),
  ('SELECT cidade FROM CONSUMIDORES GROUP BY cidade WHERE COUNT(id_consumidor) > 2;', false, 2),
  ('SELECT cidade, COUNT(id_consumidor) AS total_consumidores FROM CONSUMIDORES WHERE COUNT(id_consumidor) > 2 GROUP BY cidade;', false, 3),
  ('SELECT DISTINCT cidade FROM CONSUMIDORES WHERE COUNT(id_consumidor) > 2;', false, 4)
) AS o(text, is_correct, order_index);

-- Q8 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Cenário: Tênis (Tabelas: JOGADORES J, PARTIDAS P, RESULTADOS R). Qual consulta SQL lista o nome do jogador vencedor e o nome do jogador perdedor para todas as partidas?',
    'O CASE escolhe como perdedor o jogador da partida que não é o vencedor. B traz os dois jogadores (inclusive o vencedor), C liga o vencedor a todos os outros jogadores e D sempre pega o jogador 1.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Simulado das atividades sprint3'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT JV.nome_jogador AS Vencedor, JP.nome_jogador AS Perdedor FROM RESULTADOS R JOIN JOGADORES JV ON R.vencedor_id = JV.id_jogador JOIN PARTIDAS P ON R.id_partida = P.id_partida JOIN JOGADORES JP ON JP.id_jogador = CASE WHEN P.jogador1_id = R.vencedor_id THEN P.jogador2_id ELSE P.jogador1_id END;', true, 1),
  ('SELECT JV.nome_jogador AS Vencedor, JP.nome_jogador AS Perdedor FROM RESULTADOS R JOIN JOGADORES JV ON R.vencedor_id = JV.id_jogador JOIN PARTIDAS P ON R.id_partida = P.id_partida JOIN JOGADORES JP ON JP.id_jogador = P.jogador1_id OR JP.id_jogador = P.jogador2_id;', false, 2),
  ('SELECT JV.nome_jogador AS Vencedor, JP.nome_jogador AS Perdedor FROM RESULTADOS R JOIN JOGADORES JV ON R.vencedor_id = JV.id_jogador JOIN JOGADORES JP ON JP.id_jogador <> R.vencedor_id;', false, 3),
  ('SELECT JV.nome_jogador AS Vencedor, JP.nome_jogador AS Perdedor FROM RESULTADOS R JOIN JOGADORES JV ON R.vencedor_id = JV.id_jogador JOIN PARTIDAS P ON R.id_partida = P.id_partida JOIN JOGADORES JP ON JP.id_jogador = P.jogador1_id;', false, 4)
) AS o(text, is_correct, order_index);

-- Q9 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Cenário: Tênis (Tabela: JOGADORES). Qual consulta SQL lista os nomes dos jogadores cuja idade é superior à idade média de todos os jogadores?',
    'Comparar a idade de cada jogador com a média exige subconsulta escalar no WHERE. A tem GROUP BY na subconsulta e ela retorna várias linhas, B usa uma coluna "idade" que não existe e C usa AVG no WHERE.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Simulado das atividades sprint3'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT nome_jogador FROM JOGADORES WHERE TIMESTAMPDIFF(YEAR, data_nascimento, CURDATE()) > (SELECT AVG(TIMESTAMPDIFF(YEAR, data_nascimento, CURDATE())) FROM JOGADORES GROUP BY nome_jogador);', false, 1),
  ('SELECT J.nome_jogador FROM JOGADORES J JOIN (SELECT AVG(TIMESTAMPDIFF(YEAR, data_nascimento, CURDATE())) AS media_idade FROM JOGADORES) M ON J.idade > M.media_idade;', false, 2),
  ('SELECT nome_jogador FROM JOGADORES WHERE TIMESTAMPDIFF(YEAR, data_nascimento, CURDATE()) > AVG(TIMESTAMPDIFF(YEAR, data_nascimento, CURDATE()));', false, 3),
  ('SELECT J.nome_jogador FROM JOGADORES J WHERE TIMESTAMPDIFF(YEAR, data_nascimento, CURDATE()) > (SELECT AVG(TIMESTAMPDIFF(YEAR, data_nascimento, CURDATE())) FROM JOGADORES);', true, 4)
) AS o(text, is_correct, order_index);

-- Q10 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Cenário: Pesquisa (Tabelas: CONSUMIDORES C, PESQUISAS P, SESSAO_RESPOSTA SR). Qual consulta SQL lista o nome do consumidor e o título da pesquisa para todas as respostas registradas no ano de 2024?',
    'O filtro por ano é de linha e fica no WHERE com YEAR(). A usa HAVING com coluna fora do GROUP BY, C e D comparam uma data completa com 2024 (número ou texto).'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Simulado das atividades sprint3'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT C.nome_consumidor, P.titulo FROM CONSUMIDORES C JOIN SESSAO_RESPOSTA SR ON C.id_consumidor = SR.id_consumidor JOIN PESQUISAS P ON SR.id_pesquisa = P.id_pesquisa GROUP BY C.nome_consumidor, P.titulo HAVING YEAR(SR.data_resposta) = 2024;', false, 1),
  ('SELECT C.nome_consumidor, P.titulo FROM CONSUMIDORES C JOIN SESSAO_RESPOSTA SR ON C.id_consumidor = SR.id_consumidor JOIN PESQUISAS P ON SR.id_pesquisa = P.id_pesquisa WHERE YEAR(SR.data_resposta) = 2024;', true, 2),
  ('SELECT C.nome_consumidor, P.titulo FROM CONSUMIDORES C, PESQUISAS P, SESSAO_RESPOSTA SR WHERE C.id_consumidor = SR.id_consumidor AND P.id_pesquisa = SR.id_pesquisa AND SR.data_resposta = 2024;', false, 3),
  ('SELECT C.nome_consumidor, P.titulo FROM CONSUMIDORES C JOIN SESSAO_RESPOSTA SR ON C.id_consumidor = SR.id_consumidor JOIN PESQUISAS P ON SR.id_pesquisa = P.id_pesquisa WHERE SR.data_resposta = ''2024'';', false, 4)
) AS o(text, is_correct, order_index);

-- Q11 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Cenário: Sistema de controle acadêmico. Considere as tabelas: CREATE TABLE aluno (id INT PRIMARY KEY, nome VARCHAR(100)); CREATE TABLE disciplina (id INT PRIMARY KEY, nome VARCHAR(100)); CREATE TABLE notas (aluno_id INT, disciplina_id INT, nota DECIMAL(4,2), PRIMARY KEY (aluno_id, disciplina_id), FOREIGN KEY (aluno_id) REFERENCES aluno(id), FOREIGN KEY (disciplina_id) REFERENCES disciplina(id)); Você deseja obter a média das notas por disciplina, mostrando apenas as disciplinas cuja média seja maior ou igual a 7.0. Qual das consultas abaixo retorna corretamente o resultado esperado?',
    'Filtro sobre a média usa HAVING AVG(...) após o GROUP BY. B e E usam AVG no WHERE e C filtra por coluna não agregada.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Simulado das atividades sprint3'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Todas as alternativas estão corretas.', false, 1),
  ('SELECT d.nome, AVG(n.nota) FROM notas n JOIN disciplina d ON n.disciplina_id = d.id WHERE AVG(n.nota) >= 7.0 GROUP BY d.nome;', false, 2),
  ('SELECT d.nome, n.nota FROM notas n JOIN disciplina d ON n.disciplina_id = d.id GROUP BY d.nome HAVING n.nota >= 7.0;', false, 3),
  ('SELECT d.nome, AVG(n.nota) AS media FROM notas n JOIN disciplina d ON n.disciplina_id = d.id GROUP BY d.nome HAVING AVG(n.nota) >= 7.0;', true, 4),
  ('SELECT d.nome, AVG(n.nota) FROM notas n JOIN disciplina d ON n.disciplina_id = d.id GROUP BY d.nome WHERE AVG(n.nota) >= 7.0;', false, 5)
) AS o(text, is_correct, order_index);

-- Q12 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Cenário: Sistema de vendas. Considere as tabelas: CREATE TABLE colaborador (id INT PRIMARY KEY, nome VARCHAR(100)); CREATE TABLE venda (id INT PRIMARY KEY, colaborador_id INT, data DATE, valor_total DECIMAL(10,2), comissao DECIMAL(10,2), FOREIGN KEY (colaborador_id) REFERENCES colaborador(id)); Você deseja consultar o total de comissão recebida por colaborador, exibindo apenas os colaboradores cuja comissão total ultrapassa R$ 1.000,00. Qual das seguintes consultas SQL está correta?',
    'O total por colaborador precisa de SUM com GROUP BY e filtro em HAVING SUM(...). B filtra vendas individuais, C usa SUM no WHERE depois do GROUP BY e D usa coluna não agregada no HAVING.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Simulado das atividades sprint3'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Todas as alternativas estão corretas.', false, 1),
  ('SELECT c.nome, SUM(v.comissao) AS total_comissao FROM venda v JOIN colaborador c ON v.colaborador_id = c.id WHERE v.comissao > 1000 GROUP BY c.nome;', false, 2),
  ('SELECT c.nome, SUM(v.comissao) FROM venda v JOIN colaborador c ON v.colaborador_id = c.id GROUP BY c.nome WHERE SUM(v.comissao) > 1000;', false, 3),
  ('SELECT c.nome, v.comissao FROM venda v JOIN colaborador c ON v.colaborador_id = c.id GROUP BY c.nome HAVING v.comissao > 1000;', false, 4),
  ('SELECT c.nome, SUM(v.comissao) AS total_comissao FROM venda v JOIN colaborador c ON v.colaborador_id = c.id GROUP BY c.nome HAVING SUM(v.comissao) > 1000;', true, 5)
) AS o(text, is_correct, order_index);

-- Q13 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Cenário: Tabela funcionarios. CREATE TABLE funcionarios (id INT PRIMARY KEY, nome VARCHAR(100), area VARCHAR(50), salario DECIMAL(10,2)); Você deseja obter o salário médio por área e exibir somente as áreas que possuem salário médio acima de R$ 3.000,00. Qual das seguintes consultas SQL está correta para esse objetivo?',
    'A média por área é filtrada com HAVING AVG(...) após o GROUP BY. B usa coluna não agregada no HAVING, C usa AVG no WHERE e E filtra os salários individuais antes de agrupar, então calcula a média só dos salários acima de 3000.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Simulado das atividades sprint3'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT area, AVG(salario) AS media_salarial FROM funcionarios GROUP BY area HAVING AVG(salario) > 3000;', true, 1),
  ('SELECT area, salario FROM funcionarios GROUP BY area HAVING salario > 3000;', false, 2),
  ('SELECT area, AVG(salario) FROM funcionarios WHERE AVG(salario) > 3000 GROUP BY area;', false, 3),
  ('Nenhuma alternativa está correta.', false, 4),
  ('SELECT area, AVG(salario) FROM funcionarios WHERE salario > 3000 GROUP BY area;', false, 5)
) AS o(text, is_correct, order_index);

-- Q14 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Cenário: Loja virtual. Tabela cliente (id_cliente, nome_cliente): (1, Lucas Andrade), (2, Marina Costa), (3, Felipe Moura). Tabela pedido (id_pedido, id_cliente, data_pedido, valor_total): (101, 1, 2024-01-10, 150.00), (102, 2, 2024-01-12, 200.00), (103, 1, 2024-02-05, 300.00), (104, 3, 2024-02-18, 180.00), (105, 2, 2024-03-03, 250.00). Crie uma consulta SQL que exiba o nome de cada cliente, a quantidade total de pedidos realizados e o valor total gasto. Os resultados devem ser ordenados pelo valor total gasto em ordem decrescente.',
    'Precisa de JOIN com ON, COUNT e SUM, GROUP BY e ORDER BY por último. A não declara os apelidos nem ordena, C coloca ORDER BY antes de GROUP BY, D troca as funções (AVG e COUNT) e E faz produto cartesiano sem condição.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Simulado das atividades sprint3'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT c.nome_cliente, COUNT(p.id_pedido) AS total_pedidos, SUM(p.valor_total) AS total_gasto FROM cliente JOIN pedido ON c.id_cliente = p.id_cliente GROUP BY c.nome_cliente;', false, 1),
  ('SELECT c.nome_cliente, COUNT(p.id_pedido) AS total_pedidos, SUM(p.valor_total) AS total_gasto FROM cliente c JOIN pedido p ON c.id_cliente = p.id_cliente GROUP BY c.nome_cliente ORDER BY total_gasto DESC;', true, 2),
  ('SELECT c.nome_cliente, COUNT(p.id_pedido) AS total_pedidos, SUM(p.valor_total) AS total_gasto FROM cliente c JOIN pedido p ON c.id_cliente = p.id_cliente ORDER BY total_gasto DESC GROUP BY c.nome_cliente;', false, 3),
  ('SELECT c.nome_cliente, AVG(p.id_pedido) AS total_pedidos, COUNT(p.valor_total) AS total_gasto FROM cliente c JOIN pedido p ON c.id_cliente = p.id_cliente GROUP BY c.nome_cliente ORDER BY total_gasto DESC;', false, 4),
  ('SELECT c.nome_cliente, COUNT(p.id_pedido) AS total_pedidos, SUM(p.valor_total) AS total_gasto FROM cliente c, pedido as p GROUP BY c.nome_cliente ORDER BY total_gasto DESC;', false, 5)
) AS o(text, is_correct, order_index);

-- Q15 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Cenário: Tabelas alunos e presencas. Tabela alunos (id_aluno, nome): (1, Ana Souza), (2, Bruno Lima), (3, Carla Mendes). Tabela presencas (id_presenca, id_aluno, data_presenca): (1, 1, 2025-04-01), (2, 2, 2025-04-01), (3, 1, 2025-04-02), (4, 3, 2025-04-02), (5, 2, 2025-04-03). Qual das consultas abaixo retorna corretamente a quantidade de alunos presentes por data, ordenada pela data de forma crescente?',
    'Contar por data exige GROUP BY data_presenca, e a ordem crescente exige ORDER BY. A não tem GROUP BY, D não ordena e E usa uma coluna total_presentes que não existe.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Simulado das atividades sprint3'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT data_presenca, COUNT(*) AS total_presentes FROM presencas ORDER BY data_presenca;', false, 1),
  ('Nenhuma das alternativas está correta.', false, 2),
  ('SELECT data_presenca, COUNT(id_aluno) AS total_presentes FROM presencas GROUP BY data_presenca ORDER BY data_presenca;', true, 3),
  ('SELECT data_presenca, COUNT(data_presenca) AS total_presentes FROM presencas GROUP BY data_presenca;', false, 4),
  ('SELECT data_presenca, total_presentes FROM presencas GROUP BY data_presenca;', false, 5)
) AS o(text, is_correct, order_index);

-- Q16 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Cenário: Academia. Considere as tabelas: CREATE TABLE cliente (id INT PRIMARY KEY, nome VARCHAR(100)); CREATE TABLE presenca (id INT PRIMARY KEY, cliente_id INT, data_presenca DATE, FOREIGN KEY (cliente_id) REFERENCES cliente(id)); A academia deseja gerar um relatório com o nome de cada cliente e a quantidade de presenças registradas durante o mês de março de 2025. Qual das consultas abaixo gera corretamente esse relatório?',
    'O filtro do período usa BETWEEN com as datas de 01/03/2025 a 31/03/2025. A pega o ano de 2025 inteiro e B pega março de qualquer ano.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Simulado das atividades sprint3'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT c.nome, COUNT(p.id) AS total_presencas FROM cliente c JOIN presenca p ON c.id = p.cliente_id WHERE YEAR(p.data_presenca) = 2025 GROUP BY c.nome ORDER BY total_presencas DESC;', false, 1),
  ('SELECT c.nome, COUNT(*) AS total_presencas FROM cliente c JOIN presenca p ON c.id = p.cliente_id WHERE MONTH(p.data_presenca) = 3 GROUP BY c.nome ORDER BY total_presencas DESC;', false, 2),
  ('Todas as alternativas acima estão corretas e retornam o mesmo resultado para o mês de março de 2025.', false, 3),
  ('Todas as alternativas acima estão incorretas.', false, 4),
  ('SELECT c.nome, COUNT(p.id) AS total_presencas FROM cliente c JOIN presenca p ON c.id = p.cliente_id WHERE p.data_presenca BETWEEN ''2025-03-01'' AND ''2025-03-31'' GROUP BY c.nome ORDER BY total_presencas DESC;', true, 5)
) AS o(text, is_correct, order_index);

-- Q17 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Cenário: Sistema de controle de ponto. Considere as tabelas: CREATE TABLE funcionario (id INT PRIMARY KEY, nome VARCHAR(100)); CREATE TABLE ponto (funcionario_id INT, data DATE, horas_extras DECIMAL(4,2), PRIMARY KEY (funcionario_id, data), FOREIGN KEY (funcionario_id) REFERENCES funcionario(id)); Você deseja consultar o total de horas extras por funcionário em cada mês, exibindo apenas os casos em que o total ultrapasse 10 horas extras no mês. Qual das consultas abaixo realiza corretamente esse cálculo?',
    'Agrupa por funcionário e mês e filtra a soma com HAVING SUM(...). A agrupa só por nome, C filtra pela média diária de horas extras, e não pelo total do mês, e E usa SUM no WHERE.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Simulado das atividades sprint3'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT f.nome, MONTH(p.data), SUM(p.horas_extras) FROM ponto p JOIN funcionario f ON p.funcionario_id = f.id GROUP BY f.nome HAVING SUM(p.horas_extras) > 10;', false, 1),
  ('SELECT f.nome, MONTH(p.data) AS mes, SUM(p.horas_extras) AS total FROM ponto p JOIN funcionario f ON p.funcionario_id = f.id GROUP BY f.nome, MONTH(p.data) HAVING SUM(p.horas_extras) > 10;', true, 2),
  ('SELECT f.nome, MONTH(p.data) AS mes, AVG(p.horas_extras) AS total FROM ponto p JOIN funcionario f ON p.funcionario_id = f.id GROUP BY f.nome, MONTH(p.data) HAVING AVG(p.horas_extras) > 10;', false, 3),
  ('Nenhuma alternativa está correta.', false, 4),
  ('SELECT f.nome, MONTH(p.data) AS mes, SUM(p.horas_extras) FROM ponto p JOIN funcionario f ON p.funcionario_id = f.id WHERE SUM(p.horas_extras) > 10 GROUP BY f.nome, MONTH(p.data);', false, 5)
) AS o(text, is_correct, order_index);

-- Q18 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Cenário: Passagens aéreas. Considere as tabelas: CREATE TABLE voo (id INT PRIMARY KEY, origem VARCHAR(50), destino VARCHAR(50), data_voo DATE); CREATE TABLE passagem (id INT PRIMARY KEY, voo_id INT, preco DECIMAL(10,2), FOREIGN KEY (voo_id) REFERENCES voo(id)); Você deseja consultar o menor preço de passagem para um voo de ida e volta entre duas datas específicas de ida e volta, por exemplo, entre ''2025-05-01'' (data de ida) e ''2025-05-15'' (data de volta). Qual das seguintes consultas SQL retorna corretamente o menor preço de passagem nesse intervalo de datas?',
    'MIN(preco) por origem e destino, com as datas entre aspas e filtradas no WHERE. A não usa aspas nas datas, B usa coluna não agregada no HAVING, D tem condição impossível e E agrupa só por origem, deixando destino fora do GROUP BY.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Simulado das atividades sprint3'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SELECT v.origem, v.destino, MIN(p.preco) AS menor_preco FROM passagem p JOIN voo v ON p.voo_id = v.id WHERE v.data_voo >= 2025-05-01 AND v.data_voo <= 2025-05-15 GROUP BY v.origem, v.destino;', false, 1),
  ('SELECT v.origem, v.destino, p.preco FROM passagem p JOIN voo v ON p.voo_id = v.id WHERE v.data_voo BETWEEN ''2025-05-01'' AND ''2025-05-15'' GROUP BY v.origem, v.destino HAVING p.preco = MIN(p.preco);', false, 2),
  ('SELECT v.origem, v.destino, MIN(p.preco) AS menor_preco FROM passagem p JOIN voo v ON p.voo_id = v.id WHERE v.data_voo BETWEEN ''2025-05-01'' AND ''2025-05-15'' GROUP BY v.origem, v.destino;', true, 3),
  ('SELECT v.origem, v.destino, MIN(p.preco) AS menor_preco FROM passagem p JOIN voo v ON p.voo_id = v.id WHERE v.data_voo < ''2025-05-01'' AND v.data_voo > ''2025-05-15'' GROUP BY v.origem, v.destino;', false, 4),
  ('SELECT v.origem, v.destino, MIN(p.preco) as MenorPreço FROM passagem p JOIN voo v ON p.voo_id = v.id WHERE v.data_voo BETWEEN ''2025-05-01'' AND ''2025-05-15'' GROUP BY v.origem HAVING MIN(p.preco) > 0;', false, 5)
) AS o(text, is_correct, order_index);

-- Q19 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Cenário: Biblioteca. Considere as tabelas: livros(id, titulo, autor_id); autores(id, nome); emprestimos(id, livro_id, data_emprestimo, data_devolucao). Você quer listar o nome dos autores que têm livros emprestados atualmente (ou seja, que ainda não foram devolvidos, com data_devolucao nula). Qual das opções abaixo corresponde a essa consulta?',
    'Autores com algum empréstimo ainda não devolvido, usando EXISTS com data_devolucao IS NULL. B e C usam IS NOT NULL (livros já devolvidos) e E seleciona a coluna titulo, que não existe em autores.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados' AND t.name = 'Funções, GROUP BY, Subqueries, Views e Relacionamento N:M'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Simulado das atividades sprint3'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Nenhuma alternativa está correta.', false, 1),
  ('SELECT nome FROM autores JOIN livros ON autores.id = livros.autor_id JOIN emprestimos ON livros.id = emprestimos.livro_id WHERE data_devolucao IS NOT NULL;', false, 2),
  ('SELECT DISTINCT a.nome FROM autores a JOIN livros l ON a.id = l.autor_id WHERE l.id IN (SELECT livro_id FROM emprestimos WHERE data_devolucao IS NOT NULL);', false, 3),
  ('SELECT a.nome FROM autores a WHERE EXISTS (SELECT 1 FROM livros l JOIN emprestimos e ON l.id = e.livro_id WHERE l.autor_id = a.id AND e.data_devolucao IS NULL);', true, 4),
  ('SELECT nome, titulo FROM autores WHERE id IN (SELECT autor_id FROM livros JOIN emprestimos ON livros.id = emprestimos.livro_id WHERE data_devolucao IS NULL);', false, 5)
) AS o(text, is_correct, order_index);

-- 4. Conferência: aborta se o simulado não ficou com as 19 questões, uma correta em cada
DO $$
BEGIN
  IF (
    SELECT count(*) FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
    WHERE z.kind = 'exam' AND z.title = 'Simulado das atividades sprint3'
  ) <> 19 OR EXISTS (
    SELECT 1 FROM quiz_questions qq
    JOIN quizzes z ON z.id = qq.quiz_id
    JOIN question_options o ON o.question_id = qq.question_id
    WHERE z.kind = 'exam' AND z.title = 'Simulado das atividades sprint3'
    GROUP BY qq.question_id HAVING count(*) FILTER (WHERE o.is_correct) <> 1
  ) THEN
    RAISE EXCEPTION 'O simulado "Simulado das atividades sprint3" não ficou com 19 questões de uma alternativa correta';
  END IF;
END $$;

COMMIT;
