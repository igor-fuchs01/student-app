-- Banco de Dados — simulado "BD - Sprint 3": 30 questões, 60 minutos, nível médio, montado com questões
-- que JÁ estão no banco (as das listas de exercícios cadastradas por BD-questoes-sprint3.sql, da aula
-- "Funções, GROUP BY, Subqueries, Views e Relacionamento N:M").
-- Nenhuma questão é criada: o script só cria o simulado e o liga às questões pela tabela
-- quiz_questions.
-- Cada questão é localizada pela lista de exercícios e pela posição que ocupa nela.
-- Rode BD-questoes-sprint3.sql antes deste script.
-- Distribuição: 8 da lista Fundamentos, 11 da Aplicação e 11 do Desafio, intercaladas;
-- 16 multiple_choice, 7 multiple_answer, 3 single_choice e 4 drag_and_drop;
-- 30 questões de comparação de queries.

BEGIN;

-- 1. Trava: aborta se o simulado já existir
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM quizzes WHERE title = 'BD - Sprint 3') THEN
    RAISE EXCEPTION 'O simulado "BD - Sprint 3" já existe';
  END IF;
END $$;

-- 2. Simulado
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT 'BD - Sprint 3', 'exam', s.id, NULL, 60, 'medium'::difficulty_level
FROM subjects s
WHERE s.name = 'Banco de Dados';

-- 3. Questões: (lista de exercícios, posição na lista, posição no simulado)
INSERT INTO quiz_questions (quiz_id, question_id, order_index)
SELECT z.id, qq.question_id, v.order_index
FROM (VALUES
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos', 1, 1), -- Q1 | multiple_choice | fácil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação', 1, 2), -- Q16 | multiple_choice | difícil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio', 1, 3), -- Q31 | multiple_choice | super difícil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos', 2, 4), -- Q2 | single_choice | fácil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação', 2, 5), -- Q17 | multiple_answer | difícil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio', 2, 6), -- Q32 | multiple_answer | super difícil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos', 4, 7), -- Q4 | multiple_choice | fácil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação', 3, 8), -- Q18 | single_choice | difícil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio', 3, 9), -- Q33 | multiple_choice | super difícil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos', 8, 10), -- Q8 | multiple_choice | fácil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação', 5, 11), -- Q20 | multiple_choice | difícil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio', 4, 12), -- Q34 | drag_and_drop | super difícil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos', 10, 13), -- Q10 | multiple_choice | média
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação', 6, 14), -- Q21 | multiple_choice | difícil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio', 5, 15), -- Q35 | multiple_choice | super difícil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos', 11, 16), -- Q11 | multiple_answer | média
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação', 7, 17), -- Q22 | multiple_answer | difícil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio', 6, 18), -- Q36 | multiple_answer | super difícil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos', 13, 19), -- Q13 | drag_and_drop | média
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação', 8, 20), -- Q23 | drag_and_drop | difícil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio', 7, 21), -- Q37 | drag_and_drop | super difícil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 1: Fundamentos', 15, 22), -- Q15 | multiple_choice | média
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação', 9, 23), -- Q24 | multiple_choice | difícil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio', 9, 24), -- Q39 | single_choice | super difícil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação', 12, 25), -- Q27 | multiple_choice | difícil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio', 11, 26), -- Q41 | multiple_choice | super difícil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação', 13, 27), -- Q28 | multiple_choice | difícil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio', 12, 28), -- Q42 | multiple_answer | super difícil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 2: Aplicação', 14, 29), -- Q29 | multiple_answer | difícil
  ('Funções, GROUP BY, Subqueries, Views e Relacionamento N:M — Exercícios 3: Desafio', 13, 30) -- Q43 | multiple_choice | super difícil
) AS v(list_title, list_position, order_index)
JOIN quizzes l ON l.kind = 'exercise' AND l.title = v.list_title
JOIN quiz_questions qq ON qq.quiz_id = l.id AND qq.order_index = v.list_position
JOIN quizzes z ON z.kind = 'exam' AND z.title = 'BD - Sprint 3';

-- 4. Conferência: aborta se o simulado não ficou com as 30 questões
DO $$
BEGIN
  IF (
    SELECT count(*)
    FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
    WHERE z.kind = 'exam' AND z.title = 'BD - Sprint 3'
  ) <> 30 THEN
    RAISE EXCEPTION 'O simulado "BD - Sprint 3" não ficou com 30 questões: confira se as listas de exercícios existem';
  END IF;
END $$;

COMMIT;
