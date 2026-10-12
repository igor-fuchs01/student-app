-- Conteúdo Completo (Sprint 1 e 2): simulado de nível médio de Banco de Dados, montado com questões
-- que JÁ estão no banco (cadastradas por temp/BD-questoes.sql). Nenhuma questão é criada: o script
-- só cria o simulado e o liga às questões pela tabela quiz_questions.
-- Cada questão é localizada pelo início do seu enunciado, dentro da disciplina Banco de Dados, então
-- o script não depende do título nem da ordem das listas de exercícios.
-- Rode os dois scripts de temp/BD-questoes.sql (o original e o complementar) antes deste.
-- Distribuição das 20 questões: 6 fáceis, 6 médias, 6 difíceis e 2 super difíceis;
-- 9 multiple_choice, 4 multiple_answer, 3 single_choice e 4 drag_and_drop.

BEGIN;

-- 1. Trava: aborta se o simulado já existir
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM quizzes WHERE title = 'Conteúdo Completo (Sprint 1 e 2)') THEN
    RAISE EXCEPTION 'O simulado "Conteúdo Completo (Sprint 1 e 2)" já existe';
  END IF;
END $$;

-- 2. Questões escolhidas: (posição no simulado, início do enunciado)
CREATE TEMP TABLE bd_simulado_questoes ON COMMIT DROP AS
SELECT v.order_index, v.statement_start
FROM (VALUES
  (1, 'Em um sistema de cadastro de uma loja, a equipe de banco de dados'), -- Q1 | multiple_choice | fácil | Conceito de constraint
  (2, 'Uma clínica cria a tabela paciente'), -- Q8 | multiple_choice | difícil | NOT NULL e UNIQUE
  (3, 'Uma empresa de monitoramento cadastra sensores'), -- Q3 | multiple_choice | média | CHECK
  (4, 'Para adicionar a regra de status na tabela sensor'), -- Q7 | drag_and_drop | difícil | CHECK
  (5, 'Uma equipe de banco de dados está revisando as constraints DEFAULT e INDEX'), -- Q5 | multiple_answer | fácil | DEFAULT e INDEX
  (6, 'Ordene as etapas para criar o usuário app'), -- Q4 | drag_and_drop | difícil | Criação de usuários com CREATE USER
  (7, 'Um estagiário precisa de um usuário que apenas consulte'), -- Q6 | multiple_choice | média | Permissões com GRANT e REVOKE
  (8, 'Para conceder somente leitura e atualização ao usuário app'), -- Q9 | single_choice | super difícil | Permissões com GRANT e REVOKE
  (9, 'Para retornar somente os registros com correspondência nas duas tabelas'), -- Q18 | single_choice | fácil | INNER JOIN e junção de tabelas
  (10, 'Considere aluno (ra, nomeAluno, fkCurso), curso (idCurso, nomeCurso) e a consulta'), -- Q30 | multiple_answer | difícil | INNER JOIN e junção de tabelas
  (11, 'Uma loja tem as tabelas cliente (idCliente, nome) e pedido (idPedido, fkCliente). A gerente'), -- Q17 | multiple_choice | fácil | LEFT JOIN e RIGHT JOIN
  (12, 'Uma loja tem cliente (idCliente, nome) e pedido (idPedido, fkCliente). Qual consulta lista apenas'), -- Q27 | multiple_choice | difícil | LEFT JOIN e RIGHT JOIN
  (13, 'O FULL OUTER JOIN retorna {{s1}}'), -- Q20 | drag_and_drop | fácil | FULL OUTER JOIN
  (14, 'No modelo de uma faculdade, a tabela aluno tem as colunas ra, nomeAluno, fkEmpresa e fkCurso'), -- Q21 | multiple_choice | média | Chave estrangeira e relacionamentos
  (15, 'Como um aluno pode ter vários telefones'), -- Q23 | single_choice | média | Chave estrangeira e relacionamentos
  (16, 'Em um sistema de pedidos, a tabela itens_pedido'), -- Q22 | multiple_choice | média | Entidades fortes e fracas
  (17, 'Na tabela funcionario (idFunc, nome, fkGerente), a coluna fkGerente guarda'), -- Q29 | multiple_choice | difícil | Autorelacionamento
  (18, 'Sobre o autorelacionamento na tabela funcionario'), -- Q41 | multiple_answer | super difícil | Autorelacionamento
  (19, 'Para adicionar uma coluna: ALTER TABLE Aluno'), -- Q24 | drag_and_drop | média | Atributos e alteração de tabelas
  (20, 'Sobre os tipos de atributos em modelagem de dados') -- Q25 | multiple_answer | fácil | Atributos e alteração de tabelas
) AS v(order_index, statement_start);

-- 3. Conferência: aborta, dizendo quais, se alguma questão não foi encontrada ou está duplicada
DO $$
DECLARE
  problems text;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM subjects WHERE name = 'Banco de Dados') THEN
    RAISE EXCEPTION 'A disciplina "Banco de Dados" não existe';
  END IF;

  SELECT string_agg(
    format('posição %s (%s questão(ões) com o enunciado "%s...")', c.order_index, c.found, c.statement_start),
    E'\n  ' ORDER BY c.order_index
  )
  INTO problems
  FROM (
    SELECT v.order_index, v.statement_start, count(q.id) AS found
    FROM bd_simulado_questoes v
    LEFT JOIN (
      SELECT q.id, COALESCE(q.prompt, q.template) AS statement
      FROM questions q
      JOIN topics t ON t.id = q.topic_id
      JOIN subjects s ON s.id = t.subject_id
      WHERE s.name = 'Banco de Dados'
    ) q ON starts_with(q.statement, v.statement_start)
    GROUP BY v.order_index, v.statement_start
  ) c
  WHERE c.found <> 1;

  IF problems IS NOT NULL THEN
    RAISE EXCEPTION E'O simulado não foi criado; cada questão deveria existir uma única vez em Banco de Dados:\n  %', problems;
  END IF;
END $$;

-- 4. Simulado
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT 'Conteúdo Completo (Sprint 1 e 2)', 'exam', s.id, NULL, 40, 'medium'::difficulty_level
FROM subjects s
WHERE s.name = 'Banco de Dados';

-- 5. Questões do simulado
INSERT INTO quiz_questions (quiz_id, question_id, order_index)
SELECT z.id, q.id, v.order_index
FROM bd_simulado_questoes v
JOIN questions q ON starts_with(COALESCE(q.prompt, q.template), v.statement_start)
JOIN topics t ON t.id = q.topic_id
JOIN subjects s ON s.id = t.subject_id AND s.name = 'Banco de Dados'
JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Conteúdo Completo (Sprint 1 e 2)';

COMMIT;
