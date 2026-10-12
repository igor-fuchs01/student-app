-- Limita a 30 questões cada "<Disciplina> — Simulado Difícil" criado por
-- simulados-questoes-dificeis.sql. Nenhuma questão é apagada: o script só desfaz a ligação das
-- questões excedentes com o simulado (tabela quiz_questions) e ajusta a duração.
-- As 30 que ficam são distribuídas entre as aulas e entre os dois níveis: o script percorre as
-- aulas em rodízio, alternando super difíceis (lista 'hard') e difíceis (lista 'medium'), em vez
-- de ficar só com as primeiras aulas.
-- Simulado que já tem 30 questões ou menos não é alterado. Pode rodar mais de uma vez.
-- Uma única transação: se qualquer comando falhar, nada é gravado.

BEGIN;

-- 1. Trava: aborta se nenhum Simulado Difícil existir
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM quizzes z JOIN subjects s ON z.title = s.name || ' — Simulado Difícil'
    WHERE z.kind = 'exam'
  ) THEN
    RAISE EXCEPTION 'Nenhum "Simulado Difícil" encontrado: rode simulados-questoes-dificeis.sql antes';
  END IF;
END $$;

-- 2. Questões que ficam: as 30 primeiras do rodízio, só dos simulados com mais de 30
CREATE TEMP TABLE simulado_dificil_mantidas ON COMMIT DROP AS
SELECT
  r.quiz_id,
  r.question_id,
  row_number() OVER (PARTITION BY r.quiz_id ORDER BY r.topic_number, r.old_order_index) AS order_index
FROM (
  SELECT
    c.quiz_id,
    c.question_id,
    c.topic_number,
    c.old_order_index,
    row_number() OVER (
      PARTITION BY c.quiz_id
      ORDER BY c.round, c.difficulty DESC, c.topic_number
    ) AS pick
  FROM (
    SELECT
      qq.quiz_id,
      qq.question_id,
      qq.order_index AS old_order_index,
      t.number AS topic_number,
      d.difficulty,
      row_number() OVER (
        PARTITION BY qq.quiz_id, t.id, d.difficulty
        ORDER BY qq.order_index
      ) AS round
    FROM quizzes z
    JOIN subjects s ON z.title = s.name || ' — Simulado Difícil'
    JOIN quiz_questions qq ON qq.quiz_id = z.id
    JOIN questions q ON q.id = qq.question_id
    JOIN topics t ON t.id = q.topic_id
    JOIN LATERAL (
      SELECT max(l.difficulty) AS difficulty
      FROM quiz_questions lq
      JOIN quizzes l ON l.id = lq.quiz_id
      WHERE lq.question_id = q.id AND l.kind = 'exercise'
    ) d ON true
    WHERE z.kind = 'exam'
      AND (SELECT count(*) FROM quiz_questions n WHERE n.quiz_id = z.id) > 30
  ) c
) r
WHERE r.pick <= 30;

-- 3. Refaz as ligações dos simulados alterados, já com a nova ordem (1 a 30)
DELETE FROM quiz_questions qq
WHERE qq.quiz_id IN (SELECT m.quiz_id FROM simulado_dificil_mantidas m);

INSERT INTO quiz_questions (quiz_id, question_id, order_index)
SELECT m.quiz_id, m.question_id, m.order_index
FROM simulado_dificil_mantidas m;

-- 4. Duração: 2 minutos por questão
UPDATE quizzes z
SET duration_minutes = 60
WHERE z.id IN (SELECT m.quiz_id FROM simulado_dificil_mantidas m);

-- 5. Conferência: aborta se algum Simulado Difícil ficou com mais de 30 questões
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM quizzes z
    JOIN subjects s ON z.title = s.name || ' — Simulado Difícil'
    JOIN quiz_questions qq ON qq.quiz_id = z.id
    WHERE z.kind = 'exam'
    GROUP BY z.id
    HAVING count(*) > 30
  ) THEN
    RAISE EXCEPTION 'Algum "Simulado Difícil" ficou com mais de 30 questões';
  END IF;
END $$;

-- 6. Resultado: questões e duração de cada Simulado Difícil
SELECT z.title, z.duration_minutes, count(*) AS questions
FROM quizzes z
JOIN subjects s ON z.title = s.name || ' — Simulado Difícil'
JOIN quiz_questions qq ON qq.quiz_id = z.id
WHERE z.kind = 'exam'
GROUP BY z.id, z.title, z.duration_minutes
ORDER BY z.title;

COMMIT;
