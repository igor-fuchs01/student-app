-- Arquitetura Computacional — Simulado Sprint 1: simulado montado com questões que JÁ estão no banco (as das listas de
-- exercícios das aulas 1 e 2, cadastradas por temp/ARQ-questoes.sql). Nenhuma questão é criada:
-- o script só cria o simulado e o liga às questões pela tabela quiz_questions.
-- Cada questão é localizada pela lista de exercícios e pela posição que ocupa nela.

BEGIN;

-- 1. Trava: aborta se o simulado já existir
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM quizzes WHERE title = 'Arquitetura Computacional — Simulado Sprint 1') THEN
    RAISE EXCEPTION 'O simulado "Arquitetura Computacional — Simulado Sprint 1" já existe';
  END IF;
END $$;

-- 2. Simulado
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT 'Arquitetura Computacional — Simulado Sprint 1', 'exam', s.id, NULL, 40, 'medium'::difficulty_level
FROM subjects s
WHERE s.name = 'Arquitetura Computacional';

-- 3. Questões: (lista de exercícios, posição na lista, posição no simulado)
INSERT INTO quiz_questions (quiz_id, question_id, order_index)
SELECT z.id, qq.question_id, v.order_index
FROM (VALUES
  ('Características Técnicas de um Sistema Computacional — Exercícios 2: Aplicação', 1, 1), -- aula 1 Q1 | multiple_choice | difícil
  ('Características Técnicas de um Sistema Computacional — Exercícios 3: Desafio', 1, 2), -- aula 1 Q3 | multiple_answer | super difícil
  ('Características Técnicas de um Sistema Computacional — Exercícios 1: Fundamentos', 2, 3), -- aula 1 Q4 | multiple_choice | fácil
  ('Características Técnicas de um Sistema Computacional — Exercícios 2: Aplicação', 2, 4), -- aula 1 Q5 | single_choice | difícil
  ('Características Técnicas de um Sistema Computacional — Exercícios 3: Desafio', 2, 5), -- aula 1 Q6 | multiple_choice | super difícil
  ('Características Técnicas de um Sistema Computacional — Exercícios 1: Fundamentos', 3, 6), -- aula 1 Q7 | drag_and_drop | média
  ('Características Técnicas de um Sistema Computacional — Exercícios 2: Aplicação', 3, 7), -- aula 1 Q8 | multiple_answer | difícil
  ('Características Técnicas de um Sistema Computacional — Exercícios 1: Fundamentos', 4, 8), -- aula 1 Q9 | multiple_choice | fácil
  ('Características Técnicas de um Sistema Computacional — Exercícios 3: Desafio', 4, 9), -- aula 1 Q12 | drag_and_drop | super difícil
  ('Características Técnicas de um Sistema Computacional — Exercícios 2: Aplicação', 4, 10), -- aula 1 Q13 | multiple_choice | difícil
  ('Sistemas de Numeração na Computação — Exercícios 2: Aplicação', 1, 11), -- aula 2 Q2 | multiple_choice | difícil
  ('Sistemas de Numeração na Computação — Exercícios 1: Fundamentos', 2, 12), -- aula 2 Q3 | drag_and_drop | média
  ('Sistemas de Numeração na Computação — Exercícios 2: Aplicação', 2, 13), -- aula 2 Q4 | multiple_answer | difícil
  ('Sistemas de Numeração na Computação — Exercícios 1: Fundamentos', 3, 14), -- aula 2 Q5 | essay_blanks | fácil
  ('Sistemas de Numeração na Computação — Exercícios 3: Desafio', 1, 15), -- aula 2 Q6 | multiple_choice | super difícil
  ('Sistemas de Numeração na Computação — Exercícios 2: Aplicação', 3, 16), -- aula 2 Q7 | single_choice | difícil
  ('Sistemas de Numeração na Computação — Exercícios 1: Fundamentos', 4, 17), -- aula 2 Q8 | multiple_choice | média
  ('Sistemas de Numeração na Computação — Exercícios 3: Desafio', 2, 18), -- aula 2 Q9 | multiple_answer | super difícil
  ('Sistemas de Numeração na Computação — Exercícios 2: Aplicação', 4, 19), -- aula 2 Q12 | essay_blanks | difícil
  ('Sistemas de Numeração na Computação — Exercícios 3: Desafio', 4, 20) -- aula 2 Q13 | multiple_choice | super difícil
) AS v(list_title, list_position, order_index)
JOIN quizzes l ON l.kind = 'exercise' AND l.title = v.list_title
JOIN quiz_questions qq ON qq.quiz_id = l.id AND qq.order_index = v.list_position
JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Arquitetura Computacional — Simulado Sprint 1';

-- 4. Conferência: aborta se o simulado não ficou com as 20 questões
DO $$
BEGIN
  IF (
    SELECT count(*)
    FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
    WHERE z.kind = 'exam' AND z.title = 'Arquitetura Computacional — Simulado Sprint 1'
  ) <> 20 THEN
    RAISE EXCEPTION 'O simulado "Arquitetura Computacional — Simulado Sprint 1" não ficou com 20 questões: confira se as listas de exercícios existem';
  END IF;
END $$;

COMMIT;
