-- Simulado Difícil de cada disciplina: um simulado por disciplina, montado com as questões difíceis
-- que JÁ estão no banco. Nenhuma questão é criada: o script só cria os simulados e os liga às
-- questões pela tabela quiz_questions.
-- A questão não guarda dificuldade; ela vem da lista de exercícios em que a questão está:
--   'medium' (Exercícios 2: Aplicação) → questões difíceis
--   'hard'   (Exercícios 3: Desafio)   → questões super difíceis
-- O script não cita nenhuma disciplina: vale para todas as que tiverem questões nessas listas
-- (Arquitetura Computacional, Banco de Dados, Sistemas Operacionais, Tecnologia da Informação…).
-- Rode os scripts de questões de cada disciplina antes deste.
-- Uma única transação: se qualquer comando falhar, nada é gravado.

BEGIN;

-- 1. Questões escolhidas: as das listas de exercícios dos níveis abaixo, na ordem das aulas.
--    Para usar só as super difíceis, deixe apenas 'hard' no filtro.
CREATE TEMP TABLE simulado_dificil_questoes ON COMMIT DROP AS
SELECT
  d.subject_id,
  d.question_id,
  row_number() OVER (
    PARTITION BY d.subject_id
    ORDER BY d.topic_number, d.difficulty, d.list_position, d.question_id
  ) AS order_index
FROM (
  SELECT DISTINCT ON (q.id)
    t.subject_id,
    q.id AS question_id,
    t.number AS topic_number,
    l.difficulty,
    qq.order_index AS list_position
  FROM quizzes l
  JOIN quiz_questions qq ON qq.quiz_id = l.id
  JOIN questions q ON q.id = qq.question_id
  JOIN topics t ON t.id = q.topic_id
  WHERE l.kind = 'exercise'
    AND l.difficulty IN ('medium', 'hard')
  ORDER BY q.id, l.difficulty DESC
) d;

-- 2. Trava: aborta se não houver questão difícil ou se algum simulado já existir
DO $$
DECLARE
  existing text;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM simulado_dificil_questoes) THEN
    RAISE EXCEPTION 'Nenhuma questão difícil encontrada: confira se as listas de exercícios existem';
  END IF;

  SELECT string_agg(format('"%s"', z.title), ', ' ORDER BY z.title)
  INTO existing
  FROM quizzes z
  JOIN subjects s ON z.title = s.name || ' — Simulado Difícil';

  IF existing IS NOT NULL THEN
    RAISE EXCEPTION 'Nenhum simulado foi criado; já existe(m): %', existing;
  END IF;
END $$;

-- 3. Simulados: um por disciplina, com 2 minutos por questão
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT s.name || ' — Simulado Difícil', 'exam', s.id, NULL, count(*) * 2, 'hard'::difficulty_level
FROM simulado_dificil_questoes v
JOIN subjects s ON s.id = v.subject_id
GROUP BY s.id, s.name;

-- 4. Questões dos simulados
INSERT INTO quiz_questions (quiz_id, question_id, order_index)
SELECT z.id, v.question_id, v.order_index
FROM simulado_dificil_questoes v
JOIN subjects s ON s.id = v.subject_id
JOIN quizzes z ON z.kind = 'exam' AND z.title = s.name || ' — Simulado Difícil';

-- 5. Conferência: lista os simulados criados e quantas questões cada um recebeu
SELECT z.title, z.duration_minutes, count(*) AS questions
FROM quizzes z
JOIN quiz_questions qq ON qq.quiz_id = z.id
JOIN subjects s ON z.title = s.name || ' — Simulado Difícil'
WHERE z.kind = 'exam'
GROUP BY z.id, z.title, z.duration_minutes
ORDER BY z.title;

COMMIT;
