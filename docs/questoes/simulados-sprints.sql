-- Sprints dos simulados já cadastrados (quiz_sprints, migration 20261121000000_quiz_sprints).
--
-- Rode uma vez no SQL Editor do Supabase, depois de aplicar a migration. Os simulados são achados
-- pelo título; rodar de novo não duplica nada (ON CONFLICT DO NOTHING). Os "xSimulado Impossível"
-- e os "Sprint 1 e 2" cobrem as aulas das sprints 1 e 2, então ficam com as duas.
-- Um simulado novo grava as próprias sprints no script que o cria.

BEGIN;

INSERT INTO quiz_sprints (quiz_id, sprint)
SELECT z.id, s.sprint
FROM (VALUES
  ('ALG - Sprint 1 e 2', 1), ('ALG - Sprint 1 e 2', 2),
  ('ALG - Sprint 3', 3),
  ('xSimulado Impossível - ALG', 1), ('xSimulado Impossível - ALG', 2),
  ('Arq Comp - Sprint 1', 1),
  ('Arq Comp - Sprint 2', 2),
  ('Arq Comp - Sprint 3', 3),
  ('xSimulado Impossível - Arq Comp', 1), ('xSimulado Impossível - Arq Comp', 2),
  ('BD - Sprint 1 e 2', 1), ('BD - Sprint 1 e 2', 2),
  ('BD - Sprint 3', 3),
  ('xSimulado Impossível - BD', 1), ('xSimulado Impossível - BD', 2),
  ('SO - Sprint 1', 1),
  ('SO - Sprint 2', 2),
  ('SO - Sprint 3', 3),
  ('xSimulado Impossível - SO', 1), ('xSimulado Impossível - SO', 2),
  ('TI - Sprint 1', 1),
  ('TI - Sprint 2', 2),
  ('TI - Sprint 3', 3),
  ('xSimulado Impossível - TI', 1), ('xSimulado Impossível - TI', 2)
) AS s (title, sprint)
JOIN quizzes z ON z.title = s.title AND z.kind = 'exam'
ON CONFLICT DO NOTHING;

-- Simulados que ficaram sem sprint: só aparecem com o filtro de sprint vazio.
SELECT z.id, z.title AS simulado_sem_sprint
FROM quizzes z
WHERE z.kind = 'exam'
  AND NOT EXISTS (SELECT 1 FROM quiz_sprints qs WHERE qs.quiz_id = z.id)
ORDER BY z.title;

COMMIT;
