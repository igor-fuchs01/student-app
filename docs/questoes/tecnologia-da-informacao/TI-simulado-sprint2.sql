-- Tecnologia da Informação — Simulado Sprint 2: simulado montado com questões que JÁ estão no banco (as das listas de
-- exercícios das aulas 5, 6, 7 e 8, cadastradas por temp/TI-questoes.sql). Nenhuma questão é
-- criada: o script só cria o simulado e o liga às questões pela tabela quiz_questions.
-- Cada questão é localizada pela lista de exercícios e pela posição que ocupa nela.
-- Rode temp/TI-questoes.sql antes deste script.

BEGIN;

-- 1. Trava: aborta se o simulado já existir
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM quizzes WHERE title = 'Tecnologia da Informação — Simulado Sprint 2') THEN
    RAISE EXCEPTION 'O simulado "Tecnologia da Informação — Simulado Sprint 2" já existe';
  END IF;
END $$;

-- 2. Simulado
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT 'Tecnologia da Informação — Simulado Sprint 2', 'exam', s.id, NULL, 40, 'medium'::difficulty_level
FROM subjects s
WHERE s.name = 'Tecnologia da Informação';

-- 3. Questões: (lista de exercícios, posição na lista, posição no simulado)
INSERT INTO quiz_questions (quiz_id, question_id, order_index)
SELECT z.id, qq.question_id, v.order_index
FROM (VALUES
  ('Metodologias de Gestão de Projetos — Exercícios 1: Fundamentos', 1, 1), -- aula 5 Q1 | multiple_choice | fácil
  ('Metodologias de Gestão de Projetos — Exercícios 2: Aplicação', 1, 2), -- aula 5 Q3 | multiple_choice | difícil
  ('Metodologias de Gestão de Projetos — Exercícios 2: Aplicação', 3, 3), -- aula 5 Q5 | single_choice | difícil
  ('Metodologias de Gestão de Projetos — Exercícios 1: Fundamentos', 3, 4), -- aula 5 Q6 | multiple_choice | média
  ('Metodologias de Gestão de Projetos — Exercícios 3: Desafio', 1, 5), -- aula 5 Q8 | multiple_choice | super difícil
  ('Metodologia Ágil: Scrum — Exercícios 1: Fundamentos', 1, 6), -- aula 6 Q1 | multiple_choice | fácil
  ('Metodologia Ágil: Scrum — Exercícios 1: Fundamentos', 2, 7), -- aula 6 Q2 | drag_and_drop | média
  ('Metodologia Ágil: Scrum — Exercícios 2: Aplicação', 1, 8), -- aula 6 Q3 | multiple_choice | difícil
  ('Metodologia Ágil: Scrum — Exercícios 2: Aplicação', 2, 9), -- aula 6 Q4 | multiple_answer | difícil
  ('Metodologia Ágil: Scrum — Exercícios 3: Desafio', 2, 10), -- aula 6 Q11 | single_choice | super difícil
  ('Priorização, Estimativa e Backlog no Scrum — Exercícios 1: Fundamentos', 1, 11), -- aula 7 Q1 | multiple_choice | fácil
  ('Priorização, Estimativa e Backlog no Scrum — Exercícios 1: Fundamentos', 3, 12), -- aula 7 Q3 | multiple_choice | média
  ('Priorização, Estimativa e Backlog no Scrum — Exercícios 2: Aplicação', 1, 13), -- aula 7 Q4 | multiple_answer | difícil
  ('Priorização, Estimativa e Backlog no Scrum — Exercícios 2: Aplicação', 2, 14), -- aula 7 Q5 | single_choice | difícil
  ('Priorização, Estimativa e Backlog no Scrum — Exercícios 3: Desafio', 1, 15), -- aula 7 Q6 | multiple_choice | super difícil
  ('Infraestrutura e Diagrama de Solução Técnica — Exercícios 1: Fundamentos', 1, 16), -- aula 8 Q1 | multiple_choice | fácil
  ('Infraestrutura e Diagrama de Solução Técnica — Exercícios 1: Fundamentos', 3, 17), -- aula 8 Q3 | multiple_choice | média
  ('Infraestrutura e Diagrama de Solução Técnica — Exercícios 2: Aplicação', 1, 18), -- aula 8 Q4 | multiple_answer | difícil
  ('Infraestrutura e Diagrama de Solução Técnica — Exercícios 2: Aplicação', 2, 19), -- aula 8 Q5 | single_choice | difícil
  ('Infraestrutura e Diagrama de Solução Técnica — Exercícios 3: Desafio', 4, 20) -- aula 8 Q12 | drag_and_drop | super difícil
) AS v(list_title, list_position, order_index)
JOIN quizzes l ON l.kind = 'exercise' AND l.title = v.list_title
JOIN quiz_questions qq ON qq.quiz_id = l.id AND qq.order_index = v.list_position
JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Tecnologia da Informação — Simulado Sprint 2';

-- 4. Conferência: aborta se o simulado não ficou com as 20 questões
DO $$
BEGIN
  IF (
    SELECT count(*)
    FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
    WHERE z.kind = 'exam' AND z.title = 'Tecnologia da Informação — Simulado Sprint 2'
  ) <> 20 THEN
    RAISE EXCEPTION 'O simulado "Tecnologia da Informação — Simulado Sprint 2" não ficou com 20 questões: confira se as listas de exercícios existem';
  END IF;
END $$;

COMMIT;
