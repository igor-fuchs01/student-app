-- Sistemas Operacionais — simulado "SO - Sprint 3": 30 questões, 60 minutos, nível médio, montado com questões
-- que JÁ estão no banco (as das listas de exercícios cadastradas por SO-questoes-sprint3.sql, da aula
-- "Cliente/Servidor, Diagrama de Solução, Redes e SSH").
-- Nenhuma questão é criada: o script só cria o simulado e o liga às questões pela tabela
-- quiz_questions.
-- Cada questão é localizada pela lista de exercícios e pela posição que ocupa nela.
-- Rode SO-questoes-sprint3.sql antes deste script.
-- Distribuição: 8 da lista Fundamentos, 11 da Aplicação e 11 do Desafio, intercaladas;
-- 13 multiple_choice, 3 multiple_answer, 6 single_choice e 8 drag_and_drop;
-- 30 questões de cenário prático; os 4 temas da aula aparecem.

BEGIN;

-- 1. Trava: aborta se o simulado já existir
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM quizzes WHERE title = 'SO - Sprint 3') THEN
    RAISE EXCEPTION 'O simulado "SO - Sprint 3" já existe';
  END IF;
END $$;

-- 2. Simulado
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT 'SO - Sprint 3', 'exam', s.id, NULL, 60, 'medium'::difficulty_level
FROM subjects s
WHERE s.name = 'Sistemas Operacionais';

-- 3. Questões: (lista de exercícios, posição na lista, posição no simulado)
INSERT INTO quiz_questions (quiz_id, question_id, order_index)
SELECT z.id, qq.question_id, v.order_index
FROM (VALUES
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos', 2, 1), -- Q2 | drag_and_drop | fácil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação', 1, 2), -- Q16 | multiple_choice | difícil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio', 1, 3), -- Q31 | multiple_choice | super difícil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos', 3, 4), -- Q3 | multiple_choice | fácil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação', 2, 5), -- Q17 | multiple_answer | difícil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio', 2, 6), -- Q32 | multiple_answer | super difícil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos', 4, 7), -- Q4 | single_choice | fácil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação', 4, 8), -- Q19 | multiple_choice | difícil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio', 3, 9), -- Q33 | single_choice | super difícil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos', 7, 10), -- Q7 | drag_and_drop | fácil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação', 5, 11), -- Q20 | single_choice | difícil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio', 4, 12), -- Q34 | drag_and_drop | super difícil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos', 11, 13), -- Q11 | multiple_choice | média
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação', 7, 14), -- Q22 | drag_and_drop | difícil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio', 5, 15), -- Q35 | multiple_choice | super difícil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos', 12, 16), -- Q12 | multiple_answer | média
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação', 9, 17), -- Q24 | multiple_choice | difícil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio', 6, 18), -- Q36 | drag_and_drop | super difícil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos', 13, 19), -- Q13 | single_choice | média
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação', 10, 20), -- Q25 | single_choice | difícil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio', 8, 21), -- Q38 | single_choice | super difícil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos', 14, 22), -- Q14 | multiple_choice | média
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação', 11, 23), -- Q26 | drag_and_drop | difícil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio', 10, 24), -- Q40 | drag_and_drop | super difícil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação', 12, 25), -- Q27 | multiple_choice | difícil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio', 11, 26), -- Q41 | multiple_choice | super difícil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação', 14, 27), -- Q29 | multiple_choice | difícil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio', 12, 28), -- Q42 | multiple_choice | super difícil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação', 15, 29), -- Q30 | drag_and_drop | difícil
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio', 15, 30) -- Q45 | multiple_choice | super difícil
) AS v(list_title, list_position, order_index)
JOIN quizzes l ON l.kind = 'exercise' AND l.title = v.list_title
JOIN quiz_questions qq ON qq.quiz_id = l.id AND qq.order_index = v.list_position
JOIN quizzes z ON z.kind = 'exam' AND z.title = 'SO - Sprint 3';

-- 4. Conferência: aborta se o simulado não ficou com as 30 questões
DO $$
BEGIN
  IF (
    SELECT count(*)
    FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
    WHERE z.kind = 'exam' AND z.title = 'SO - Sprint 3'
  ) <> 30 THEN
    RAISE EXCEPTION 'O simulado "SO - Sprint 3" não ficou com 30 questões: confira se as listas de exercícios existem';
  END IF;
END $$;

COMMIT;
