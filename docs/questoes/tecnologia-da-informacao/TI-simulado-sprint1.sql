-- Tecnologia da Informação — Simulado Sprint 1: simulado montado com questões que JÁ estão no banco (as das listas de
-- exercícios das aulas 1, 2, 3 e 4, cadastradas por temp/TI-questoes.sql). Nenhuma questão é
-- criada: o script só cria o simulado e o liga às questões pela tabela quiz_questions.
-- Cada questão é localizada pela lista de exercícios e pela posição que ocupa nela.
-- Rode temp/TI-questoes.sql antes deste script.

BEGIN;

-- 1. Trava: aborta se o simulado já existir
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM quizzes WHERE title = 'Tecnologia da Informação — Simulado Sprint 1') THEN
    RAISE EXCEPTION 'O simulado "Tecnologia da Informação — Simulado Sprint 1" já existe';
  END IF;
END $$;

-- 2. Simulado
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT 'Tecnologia da Informação — Simulado Sprint 1', 'exam', s.id, NULL, 40, 'medium'::difficulty_level
FROM subjects s
WHERE s.name = 'Tecnologia da Informação';

-- 3. Questões: (lista de exercícios, posição na lista, posição no simulado)
INSERT INTO quiz_questions (quiz_id, question_id, order_index)
SELECT z.id, qq.question_id, v.order_index
FROM (VALUES
  ('Introdução à Tecnologia da Informação — Exercícios 1: Fundamentos', 1, 1), -- aula 1 Q1 | multiple_choice | fácil
  ('Introdução à Tecnologia da Informação — Exercícios 2: Aplicação', 1, 2), -- aula 1 Q3 | multiple_answer | difícil
  ('Introdução à Tecnologia da Informação — Exercícios 2: Aplicação', 3, 3), -- aula 1 Q5 | single_choice | difícil
  ('Introdução à Tecnologia da Informação — Exercícios 3: Desafio', 2, 4), -- aula 1 Q8 | multiple_choice | super difícil
  ('Introdução à Tecnologia da Informação — Exercícios 1: Fundamentos', 4, 5), -- aula 1 Q10 | multiple_choice | média
  ('Documentação de Projetos de TI — Exercícios 1: Fundamentos', 1, 6), -- aula 2 Q1 | multiple_choice | média
  ('Documentação de Projetos de TI — Exercícios 1: Fundamentos', 3, 7), -- aula 2 Q3 | multiple_choice | fácil
  ('Documentação de Projetos de TI — Exercícios 2: Aplicação', 2, 8), -- aula 2 Q5 | single_choice | difícil
  ('Documentação de Projetos de TI — Exercícios 2: Aplicação', 4, 9), -- aula 2 Q7 | drag_and_drop | difícil
  ('Documentação de Projetos de TI — Exercícios 3: Desafio', 2, 10), -- aula 2 Q9 | multiple_answer | super difícil
  ('Escopo, Premissas e Restrições — Exercícios 1: Fundamentos', 1, 11), -- aula 3 Q1 | multiple_choice | fácil
  ('Escopo, Premissas e Restrições — Exercícios 2: Aplicação', 1, 12), -- aula 3 Q3 | multiple_choice | difícil
  ('Escopo, Premissas e Restrições — Exercícios 2: Aplicação', 5, 13), -- aula 3 Q7 | drag_and_drop | difícil
  ('Escopo, Premissas e Restrições — Exercícios 1: Fundamentos', 4, 14), -- aula 3 Q10 | multiple_choice | média
  ('Escopo, Premissas e Restrições — Exercícios 3: Desafio', 4, 15), -- aula 3 Q14 | multiple_answer | super difícil
  ('Requisitos e Backlog — Exercícios 1: Fundamentos', 1, 16), -- aula 4 Q1 | multiple_choice | fácil
  ('Requisitos e Backlog — Exercícios 1: Fundamentos', 2, 17), -- aula 4 Q2 | multiple_choice | média
  ('Requisitos e Backlog — Exercícios 2: Aplicação', 1, 18), -- aula 4 Q4 | multiple_answer | difícil
  ('Requisitos e Backlog — Exercícios 2: Aplicação', 3, 19), -- aula 4 Q8 | drag_and_drop | difícil
  ('Requisitos e Backlog — Exercícios 3: Desafio', 3, 20) -- aula 4 Q10 | multiple_choice | super difícil
) AS v(list_title, list_position, order_index)
JOIN quizzes l ON l.kind = 'exercise' AND l.title = v.list_title
JOIN quiz_questions qq ON qq.quiz_id = l.id AND qq.order_index = v.list_position
JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Tecnologia da Informação — Simulado Sprint 1';

-- 4. Conferência: aborta se o simulado não ficou com as 20 questões
DO $$
BEGIN
  IF (
    SELECT count(*)
    FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
    WHERE z.kind = 'exam' AND z.title = 'Tecnologia da Informação — Simulado Sprint 1'
  ) <> 20 THEN
    RAISE EXCEPTION 'O simulado "Tecnologia da Informação — Simulado Sprint 1" não ficou com 20 questões: confira se as listas de exercícios existem';
  END IF;
END $$;

COMMIT;
