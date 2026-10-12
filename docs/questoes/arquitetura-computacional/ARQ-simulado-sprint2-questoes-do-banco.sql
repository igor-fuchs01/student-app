-- Arquitetura Computacional — Simulado Sprint 2: simulado montado com questões que JÁ estão no banco (as das listas de
-- exercícios das aulas 3 e 4, cadastradas por temp/ARQ-questoes.sql). Nenhuma questão é criada:
-- o script só cria o simulado e o liga às questões pela tabela quiz_questions.
-- Cada questão é localizada pela lista de exercícios e pela posição que ocupa nela.

BEGIN;

-- 1. Trava: aborta se o simulado já existir
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM quizzes WHERE title = 'Arquitetura Computacional — Simulado Sprint 2') THEN
    RAISE EXCEPTION 'O simulado "Arquitetura Computacional — Simulado Sprint 2" já existe';
  END IF;
END $$;

-- 2. Simulado
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT 'Arquitetura Computacional — Simulado Sprint 2', 'exam', s.id, NULL, 40, 'medium'::difficulty_level
FROM subjects s
WHERE s.name = 'Arquitetura Computacional';

-- 3. Questões: (lista de exercícios, posição na lista, posição no simulado)
INSERT INTO quiz_questions (quiz_id, question_id, order_index)
SELECT z.id, qq.question_id, v.order_index
FROM (VALUES
  ('Aquisição de Dados com API — Exercícios 2: Aplicação', 1, 1), -- aula 3 Q2 | multiple_answer | difícil
  ('Aquisição de Dados com API — Exercícios 1: Fundamentos', 2, 2), -- aula 3 Q3 | drag_and_drop | fácil
  ('Aquisição de Dados com API — Exercícios 3: Desafio', 1, 3), -- aula 3 Q4 | multiple_choice | super difícil
  ('Aquisição de Dados com API — Exercícios 2: Aplicação', 2, 4), -- aula 3 Q5 | single_choice | difícil
  ('Aquisição de Dados com API — Exercícios 1: Fundamentos', 3, 5), -- aula 3 Q6 | multiple_choice | fácil
  ('Aquisição de Dados com API — Exercícios 3: Desafio', 2, 6), -- aula 3 Q7 | multiple_answer | super difícil
  ('Aquisição de Dados com API — Exercícios 2: Aplicação', 3, 7), -- aula 3 Q8 | essay_blanks | difícil
  ('Aquisição de Dados com API — Exercícios 1: Fundamentos', 4, 8), -- aula 3 Q9 | multiple_choice | média
  ('Aquisição de Dados com API — Exercícios 2: Aplicação', 4, 9), -- aula 3 Q12 | multiple_choice | difícil
  ('Aquisição de Dados com API — Exercícios 3: Desafio', 4, 10), -- aula 3 Q13 | multiple_answer | super difícil
  ('Aquisição de Dados: Gravando no Banco — Exercícios 2: Aplicação', 1, 11), -- aula 4 Q1 | multiple_answer | difícil
  ('Aquisição de Dados: Gravando no Banco — Exercícios 3: Desafio', 1, 12), -- aula 4 Q3 | essay_blanks | super difícil
  ('Aquisição de Dados: Gravando no Banco — Exercícios 1: Fundamentos', 2, 13), -- aula 4 Q4 | single_choice | média
  ('Aquisição de Dados: Gravando no Banco — Exercícios 3: Desafio', 2, 14), -- aula 4 Q5 | multiple_choice | super difícil
  ('Aquisição de Dados: Gravando no Banco — Exercícios 2: Aplicação', 2, 15), -- aula 4 Q6 | multiple_choice | difícil
  ('Aquisição de Dados: Gravando no Banco — Exercícios 1: Fundamentos', 3, 16), -- aula 4 Q7 | drag_and_drop | fácil
  ('Aquisição de Dados: Gravando no Banco — Exercícios 2: Aplicação', 3, 17), -- aula 4 Q9 | essay_blanks | difícil
  ('Aquisição de Dados: Gravando no Banco — Exercícios 3: Desafio', 4, 18), -- aula 4 Q10 | multiple_choice | super difícil
  ('Aquisição de Dados: Gravando no Banco — Exercícios 2: Aplicação', 4, 19), -- aula 4 Q11 | drag_and_drop | difícil
  ('Aquisição de Dados: Gravando no Banco — Exercícios 1: Fundamentos', 4, 20) -- aula 4 Q12 | multiple_choice | fácil
) AS v(list_title, list_position, order_index)
JOIN quizzes l ON l.kind = 'exercise' AND l.title = v.list_title
JOIN quiz_questions qq ON qq.quiz_id = l.id AND qq.order_index = v.list_position
JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Arquitetura Computacional — Simulado Sprint 2';

-- 4. Conferência: aborta se o simulado não ficou com as 20 questões
DO $$
BEGIN
  IF (
    SELECT count(*)
    FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
    WHERE z.kind = 'exam' AND z.title = 'Arquitetura Computacional — Simulado Sprint 2'
  ) <> 20 THEN
    RAISE EXCEPTION 'O simulado "Arquitetura Computacional — Simulado Sprint 2" não ficou com 20 questões: confira se as listas de exercícios existem';
  END IF;
END $$;

COMMIT;
