-- Tecnologia da Informação — questões complementares sobre os pilares do Scrum. Cria o subassunto
-- "Pilares do Scrum" na aula de Scrum, acrescenta 15 questões às listas de exercícios que já
-- existem (5 em cada lista) e liga 5 delas ao simulado da Sprint 2.
-- Rode TI-questoes.sql e TI-simulado-sprint2.sql antes deste.
-- A aula é localizada pelo subassunto "Origem e ideia central do Scrum" dentro da disciplina
-- Tecnologia da Informação, cada lista pela aula e pelo nível (easy, medium, hard), e o simulado
-- como o único simulado 'medium' da disciplina que já tem questões dessa aula. O script não
-- depende do número nem do nome da aula, nem do título das listas e do simulado, que podem ter
-- sido alterados depois do cadastro.
-- Distribuição: 6 multiple_choice, 3 multiple_answer, 3 single_choice, 3 drag_and_drop;
-- 2 fáceis, 3 médias, 5 difíceis, 5 super difíceis.
-- Simulado: Q1, Q4, Q6, Q7 e Q13 entram no fim do simulado, que passa a ter 25 questões.
-- Observações:
--  * Os slides citam inspeção, adaptação e transparência como boas práticas, sem chamá-las de
--    pilares: o subassunto e as questões seguem o Scrum Guide (empirismo e os três pilares).
--  * Q8, Q10 e Q12 (Daily, Review e Retrospectiva como momentos de inspeção e adaptação) são
--    extensões do que os pontos-chave trazem.
-- Uma única transação: se qualquer comando falhar, nada é gravado.

BEGIN;

-- 1. Aula: a que tem o subassunto "Origem e ideia central do Scrum" em Tecnologia da Informação
CREATE TEMP TABLE ti_pilares_aula ON COMMIT DROP AS
SELECT t.id AS topic_id
FROM topics t
JOIN subjects s ON s.id = t.subject_id
JOIN subtopics st ON st.topic_id = t.id
WHERE s.name = 'Tecnologia da Informação' AND st.name = 'Origem e ideia central do Scrum';

-- 2. Simulado: o simulado 'medium' da disciplina que já tem questões da aula de Scrum
CREATE TEMP TABLE ti_pilares_simulado ON COMMIT DROP AS
SELECT DISTINCT z.id AS quiz_id
FROM quizzes z
JOIN quiz_questions qq ON qq.quiz_id = z.id
JOIN questions q ON q.id = qq.question_id
JOIN ti_pilares_aula a ON a.topic_id = q.topic_id
WHERE z.kind = 'exam' AND z.difficulty = 'medium';

-- 3. Trava: a aula e o simulado são únicos, há uma lista de cada nível e este script ainda não rodou
DO $$
BEGIN
  IF (SELECT COUNT(*) FROM ti_pilares_aula) <> 1 THEN
    RAISE EXCEPTION 'Deveria existir uma única aula de Tecnologia da Informação com o subassunto "Origem e ideia central do Scrum": rode primeiro TI-questoes.sql';
  END IF;

  IF (SELECT COUNT(*) FROM ti_pilares_simulado) <> 1 THEN
    RAISE EXCEPTION 'Deveria existir um único simulado medium com questões da aula de Scrum: rode primeiro TI-simulado-sprint2.sql';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM (VALUES ('easy'), ('medium'), ('hard')) AS v(difficulty)
    WHERE (
      SELECT COUNT(*) FROM quizzes z
      JOIN ti_pilares_aula a ON a.topic_id = z.topic_id
      WHERE z.kind = 'exercise' AND z.difficulty = v.difficulty::difficulty_level
    ) <> 1
  ) THEN
    RAISE EXCEPTION 'A aula deveria ter exatamente uma lista de exercícios de cada nível (easy, medium, hard)';
  END IF;

  IF EXISTS (
    SELECT 1 FROM subtopics st
    JOIN ti_pilares_aula a ON a.topic_id = st.topic_id
    WHERE st.name = 'Pilares do Scrum'
  ) THEN
    RAISE EXCEPTION 'Este script dos pilares do Scrum já foi executado';
  END IF;
END $$;

-- 4. Subassunto
INSERT INTO subtopics (topic_id, name, summary, order_index)
SELECT a.topic_id, 'Pilares do Scrum', 'O Scrum se apoia no empirismo e em três pilares: transparência, inspeção e adaptação. Cada pilar depende do anterior para funcionar.',
  (SELECT COALESCE(MAX(st.order_index), 0) + 1 FROM subtopics st WHERE st.topic_id = a.topic_id)
FROM ti_pilares_aula a;

-- 5. Pontos-chave
INSERT INTO subtopic_key_points (subtopic_id, text, order_index)
SELECT st.id, v.text, v.order_index
FROM subtopics st
JOIN ti_pilares_aula a ON a.topic_id = st.topic_id
CROSS JOIN (VALUES
  ('Empirismo: o conhecimento vem da experiência e as decisões se baseiam no que é observado.', 1),
  ('Transparência: o processo e o trabalho ficam visíveis para quem faz e para quem recebe o trabalho.', 2),
  ('Inspeção: os artefatos e o progresso rumo às metas são verificados com frequência para detectar problemas.', 3),
  ('Adaptação: se algo se desviar do aceitável, o processo ou o produto é ajustado o quanto antes.', 4),
  ('A transparência permite a inspeção e a inspeção permite a adaptação; inspeção sem adaptação é inútil.', 5)
) AS v(text, order_index)
WHERE st.name = 'Pilares do Scrum';

-- 6. Questões

-- Q1 | multiple_choice | fácil | Pilares do Scrum | Exercícios 1 | correta: C | simulado
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT a.topic_id, 'multiple_choice', 'Quais são os três pilares do Scrum?', 'O Scrum é empírico e se apoia em três pilares: transparência, inspeção e adaptação. Compromisso, foco e coragem são valores do Scrum, não pilares.'
  FROM ti_pilares_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'easy'
  JOIN ti_pilares_aula a ON a.topic_id = z.topic_id
), e AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT sm.quiz_id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = sm.quiz_id)
  FROM q CROSS JOIN ti_pilares_simulado sm
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Compromisso, foco e coragem', false, 1),
  ('Planejamento, execução e entrega', false, 2),
  ('Transparência, inspeção e adaptação', true, 3),
  ('Product Owner, Scrum Master e time', false, 4),
  ('Backlog, sprint e daily', false, 5)
) AS o(text, is_correct, order_index);

-- Q2 | multiple_choice | fácil | Pilares do Scrum | Exercícios 1 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT a.topic_id, 'multiple_choice', 'Em um squad, o quadro de tarefas fica visível para todos e qualquer pessoa sabe o que está pronto, em andamento ou bloqueado. Qual pilar do Scrum está sendo aplicado?', 'Deixar o trabalho e o progresso visíveis para todos é a transparência: todo mundo sabe de tudo e tudo fica às claras.'
  FROM ti_pilares_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'easy'
  JOIN ti_pilares_aula a ON a.topic_id = z.topic_id
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Adaptação', false, 1),
  ('Transparência', true, 2),
  ('Inspeção', false, 3),
  ('Autonomia', false, 4),
  ('Priorização', false, 5)
) AS o(text, is_correct, order_index);

-- Q3 | single_choice | média | Pilares do Scrum | Exercícios 1 | b1: empirismo, b2: experiência, b3: observado
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT a.topic_id, 'single_choice', 'O Scrum é baseado no {{b1}}: o conhecimento vem da {{b2}} e as decisões são tomadas com base no que é {{b3}}.', 'O Scrum é empírico: em vez de prever tudo no início, o time aprende com a experiência e decide a partir do que observa, por isso precisa de transparência, inspeção e adaptação.'
  FROM ti_pilares_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'easy'
  JOIN ti_pilares_aula a ON a.topic_id = z.topic_id
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'planejamento detalhado', false, 1), ('b1', 'empirismo', true, 2), ('b1', 'modelo cascata', false, 3),
  ('b2', 'documentação', false, 1), ('b2', 'hierarquia', false, 2), ('b2', 'experiência', true, 3),
  ('b3', 'observado', true, 1), ('b3', 'previsto no contrato', false, 2), ('b3', 'decidido pelo gerente', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q4 | drag_and_drop | média | Pilares do Scrum | Exercícios 1 | s1: Transparência, s2: Inspeção, s3: Adaptação | simulado
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT a.topic_id, 'drag_and_drop', 'Associe cada situação ao pilar do Scrum. Todo o time vê o andamento das tarefas no quadro: {{s1}}. Na daily, o time verifica se está no caminho da meta da sprint: {{s2}}. Depois disso, o time muda o plano do dia para recuperar um atraso: {{s3}}.', 'Deixar o trabalho visível é transparência, verificar o progresso é inspeção e mudar o plano a partir do que foi verificado é adaptação.'
  FROM ti_pilares_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'easy'
  JOIN ti_pilares_aula a ON a.topic_id = z.topic_id
), e AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT sm.quiz_id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = sm.quiz_id)
  FROM q CROSS JOIN ti_pilares_simulado sm
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('Adaptação', 1), ('Compromisso', 2), ('Transparência', 3), ('Coragem', 4), ('Inspeção', 5)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'Transparência', 1), ('s2', 'Inspeção', 2), ('s3', 'Adaptação', 3))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q5 | multiple_choice | média | Pilares do Scrum | Exercícios 1 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT a.topic_id, 'multiple_choice', 'Segundo os pilares do Scrum, o que precisa existir para que a inspeção seja confiável?', 'A transparência permite a inspeção: se o trabalho não está visível, o time inspeciona informação incompleta e a inspeção se torna enganosa.'
  FROM ti_pilares_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'easy'
  JOIN ti_pilares_aula a ON a.topic_id = z.topic_id
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Adaptação, pois o time só inspeciona o que já mudou', false, 1),
  ('Um gerente que aprove cada inspeção', false, 2),
  ('Um contrato que defina todo o escopo no início', false, 3),
  ('Transparência, pois só é possível inspecionar o que está visível', true, 4),
  ('Uma reunião de inspeção apenas no fim do projeto', false, 5)
) AS o(text, is_correct, order_index);

-- Q6 | multiple_choice | difícil | Pilares do Scrum | Exercícios 2 | correta: E | simulado
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT a.topic_id, 'multiple_choice', 'Na revisão da sprint, o time e o cliente percebem que uma funcionalidade entregue não atende ao que o cliente precisa, mas o time mantém o backlog como estava e segue o plano original. Que problema isso representa em relação aos pilares do Scrum?', 'O problema foi identificado (inspeção), mas nada mudou: sem adaptação, a inspeção é inútil. O backlog pode e deve ser ajustado a partir do que foi inspecionado.'
  FROM ti_pilares_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'medium'
  JOIN ti_pilares_aula a ON a.topic_id = z.topic_id
), e AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT sm.quiz_id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = sm.quiz_id)
  FROM q CROSS JOIN ti_pilares_simulado sm
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Faltou transparência, pois o cliente não deveria ver o que foi entregue', false, 1),
  ('Houve adaptação sem inspeção, pois o time mudou sem analisar a entrega', false, 2),
  ('Nenhum, pois os pilares só se aplicam à retrospectiva', false, 3),
  ('Nenhum, pois mudar o backlog depois do início do projeto contraria o Scrum', false, 4),
  ('Houve inspeção sem adaptação, o que torna a inspeção inútil', true, 5)
) AS o(text, is_correct, order_index);

-- Q7 | multiple_answer | difícil | Pilares do Scrum | Exercícios 2 | corretas: A, C, D | simulado
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT a.topic_id, 'multiple_answer', 'Quais práticas de um squad reforçam o pilar da transparência? Assinale todas as corretas.', 'Transparência é deixar o trabalho, o progresso e os problemas visíveis para todos. Guardar a priorização ou esconder atrasos vai no sentido contrário.'
  FROM ti_pilares_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'medium'
  JOIN ti_pilares_aula a ON a.topic_id = z.topic_id
), e AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT sm.quiz_id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = sm.quiz_id)
  FROM q CROSS JOIN ti_pilares_simulado sm
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Manter o quadro de tarefas visível e atualizado para todo o time', true, 1),
  ('O Product Owner guardar a priorização do backlog só para si, para evitar discussões', false, 2),
  ('Combinar com todos o que significa uma tarefa estar pronta', true, 3),
  ('Contar na daily, assim que surgem, os impedimentos que travam o trabalho', true, 4),
  ('Esconder do cliente os atrasos até a entrega final, para não gerar pressão', false, 5)
) AS o(text, is_correct, order_index);

-- Q8 | multiple_choice | difícil | Pilares do Scrum | Exercícios 2 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT a.topic_id, 'multiple_choice', 'Na daily, o time verifica o progresso rumo à meta da sprint e, se preciso, reorganiza as tarefas dos próximos dias. Que pilares do Scrum esse momento coloca em prática, nessa ordem?', 'Verificar o progresso é inspeção e reorganizar as tarefas a partir disso é adaptação: a daily é uma oportunidade diária para os dois pilares.'
  FROM ti_pilares_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'medium'
  JOIN ti_pilares_aula a ON a.topic_id = z.topic_id
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Adaptação e transparência', false, 1),
  ('Inspeção e adaptação', true, 2),
  ('Transparência e compromisso', false, 3),
  ('Foco e coragem', false, 4),
  ('Planejamento e execução', false, 5)
) AS o(text, is_correct, order_index);

-- Q9 | single_choice | difícil | Pilares do Scrum | Exercícios 2 | b1: transparência, b2: enganosa, b3: adaptação, b4: inútil
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT a.topic_id, 'single_choice', 'A {{b1}} permite a inspeção; inspeção sem transparência é {{b2}}. A inspeção permite a {{b3}}; inspeção sem adaptação é {{b4}}.', 'Cada pilar depende do anterior: sem transparência a inspeção se baseia em informação incompleta e engana; sem adaptação, o que foi inspecionado não muda nada.'
  FROM ti_pilares_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'medium'
  JOIN ti_pilares_aula a ON a.topic_id = z.topic_id
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'adaptação', false, 1), ('b1', 'transparência', true, 2), ('b1', 'priorização', false, 3),
  ('b2', 'enganosa', true, 1), ('b2', 'inútil', false, 2), ('b2', 'mais rápida', false, 3),
  ('b3', 'documentação', false, 1), ('b3', 'transparência', false, 2), ('b3', 'adaptação', true, 3),
  ('b4', 'enganosa', false, 1), ('b4', 'mais segura', false, 2), ('b4', 'inútil', true, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q10 | drag_and_drop | difícil | Pilares do Scrum | Exercícios 2 | s1: o progresso rumo à meta da sprint, s2: o incremento entregue, junto com o cliente, s3: a forma de trabalhar do time
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT a.topic_id, 'drag_and_drop', 'Cada evento do Scrum é um momento de inspeção. Associe o evento ao que é inspecionado nele. Daily: {{s1}}. Revisão da sprint: {{s2}}. Retrospectiva: {{s3}}.', 'Na daily o time inspeciona o progresso rumo à meta da sprint, na revisão inspeciona com o cliente o que foi entregue e na retrospectiva inspeciona a própria forma de trabalhar.'
  FROM ti_pilares_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'medium'
  JOIN ti_pilares_aula a ON a.topic_id = z.topic_id
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('a forma de trabalhar do time', 1), ('o contrato assinado com o cliente', 2),
    ('o progresso rumo à meta da sprint', 3), ('o orçamento anual da empresa', 4),
    ('o incremento entregue, junto com o cliente', 5)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'o progresso rumo à meta da sprint', 1),
  ('s2', 'o incremento entregue, junto com o cliente', 2),
  ('s3', 'a forma de trabalhar do time', 3)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q11 | multiple_choice | super difícil | Pilares do Scrum | Exercícios 3 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT a.topic_id, 'multiple_choice', 'Uma empresa diz usar Scrum: faz daily, revisão e retrospectiva, mas o quadro de tarefas só é atualizado pelo gerente no fim do mês e os problemas só aparecem quando o prazo estoura. Segundo os pilares, por que os eventos não estão gerando melhoria?', 'Os eventos são momentos de inspeção e adaptação, mas dependem da transparência: sem o trabalho visível, o time inspeciona informação desatualizada e se adapta tarde ou na direção errada.'
  FROM ti_pilares_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'hard'
  JOIN ti_pilares_aula a ON a.topic_id = z.topic_id
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Porque o quadro deveria ser atualizado apenas pelo Scrum Master', false, 1),
  ('Porque a adaptação só deve acontecer no fim do projeto', false, 2),
  ('Porque, sem transparência, a inspeção nos eventos usa informação incompleta e leva a decisões erradas', true, 3),
  ('Porque faltam reuniões: com mais eventos, a inspeção resolveria o problema sozinha', false, 4),
  ('Porque a transparência substitui a inspeção, e os eventos se tornam desnecessários', false, 5)
) AS o(text, is_correct, order_index);

-- Q12 | multiple_answer | super difícil | Pilares do Scrum | Exercícios 3 | corretas: A, B, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT a.topic_id, 'multiple_answer', 'Sobre os pilares do Scrum, assinale todas as corretas.', 'Os eventos do Scrum existem para inspecionar e adaptar com frequência, e a adaptação deve vir o quanto antes, como em "fracasse rápido". Inspecionar só no fim e restringir a informação ao PO contrariam os pilares.'
  FROM ti_pilares_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'hard'
  JOIN ti_pilares_aula a ON a.topic_id = z.topic_id
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A adaptação deve acontecer o quanto antes, para evitar que o desvio cresça', true, 1),
  ('A daily, a revisão e a retrospectiva são momentos de inspeção e adaptação', true, 2),
  ('A inspeção deve ser feita só na entrega final, para não interromper o trabalho', false, 3),
  ('"Fracasse rápido" se apoia na inspeção frequente, que revela os problemas cedo', true, 4),
  ('Transparência significa que só o Product Owner precisa conhecer o andamento do projeto', false, 5)
) AS o(text, is_correct, order_index);

-- Q13 | single_choice | super difícil | Pilares do Scrum | Exercícios 3 | b1: identificar, b2: adaptação, b3: transparência | simulado
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT a.topic_id, 'single_choice', 'Na retrospectiva, o time percebe que os testes sempre ficam para o último dia da sprint. Ao {{b1}} esse ponto, o time aplica a inspeção; ao decidir testar cada tarefa assim que ela termina na próxima sprint, aplica a {{b2}}. O problema só foi percebido porque o andamento dos testes estava visível no quadro, graças à {{b3}}.', 'Identificar o problema é inspeção, mudar a forma de trabalhar é adaptação, e as duas só foram possíveis porque o andamento estava visível, o que é transparência.'
  FROM ti_pilares_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'hard'
  JOIN ti_pilares_aula a ON a.topic_id = z.topic_id
), e AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT sm.quiz_id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = sm.quiz_id)
  FROM q CROSS JOIN ti_pilares_simulado sm
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'esconder', false, 1), ('b1', 'identificar', true, 2), ('b1', 'adiar', false, 3),
  ('b2', 'transparência', false, 1), ('b2', 'inspeção', false, 2), ('b2', 'adaptação', true, 3),
  ('b3', 'transparência', true, 1), ('b3', 'adaptação', false, 2), ('b3', 'hierarquia', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q14 | drag_and_drop | super difícil | Pilares do Scrum | Exercícios 3 | s1: atraso visível no quadro, s2: daily encontra o desvio, s3: time redistribui as tarefas
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT a.topic_id, 'drag_and_drop', 'Um squad está atrasado em uma tarefa da sprint. Ordene o que acontece quando os pilares do Scrum funcionam. 1º (transparência): {{s1}}. 2º (inspeção): {{s2}}. 3º (adaptação): {{s3}}.', 'Primeiro o atraso precisa estar visível (transparência), depois o time o encontra ao comparar o progresso com a meta (inspeção) e por fim muda o plano (adaptação). Esperar o fim do projeto ou esconder o atraso quebra o ciclo.'
  FROM ti_pilares_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'hard'
  JOIN ti_pilares_aula a ON a.topic_id = z.topic_id
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('o time redistribui as tarefas para recuperar o atraso', 1),
    ('o gerente decide sozinho, no fim do projeto, se o atraso importa', 2),
    ('o atraso aparece no quadro, visível para todo o time', 3),
    ('o time esconde o atraso até a revisão da sprint', 4),
    ('na daily, o time compara o progresso com a meta e encontra o desvio', 5)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'o atraso aparece no quadro, visível para todo o time', 1),
  ('s2', 'na daily, o time compara o progresso com a meta e encontra o desvio', 2),
  ('s3', 'o time redistribui as tarefas para recuperar o atraso', 3)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q15 | multiple_choice | super difícil | Pilares do Scrum | Exercícios 3 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT a.topic_id, 'multiple_choice', 'O material afirma que "hesitação significa morte": saiba onde está, avalie as alternativas, tome uma decisão e siga em frente. Que relação essa frase tem com os pilares do Scrum?', 'Saber onde está e avaliar as alternativas é inspecionar; decidir e seguir em frente é adaptar, e a adaptação deve acontecer o quanto antes para o desvio não crescer.'
  FROM ti_pilares_aula a
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'hard'
  JOIN ti_pilares_aula a ON a.topic_id = z.topic_id
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Trata só da transparência, pois pede que todos saibam o que acontece no projeto', false, 1),
  ('Contraria os pilares, pois o Scrum exige seguir o plano inicial sem mudanças', false, 2),
  ('Descreve a Cascata, em que cada fase é concluída uma única vez', false, 3),
  ('Saber onde está e avaliar as alternativas é inspeção; decidir e seguir em frente é adaptação, feita o quanto antes', true, 4),
  ('Refere-se ao Scrum Master, que decide sozinho o que deverá ser feito', false, 5)
) AS o(text, is_correct, order_index);

-- 7. Conferência: aborta se alguma questão ficou fora das listas ou o simulado não recebeu as 5
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM questions q
    JOIN ti_pilares_aula a ON a.topic_id = q.topic_id
    WHERE NOT EXISTS (
      SELECT 1 FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
      WHERE qq.question_id = q.id AND z.kind = 'exercise'
    )
  ) THEN
    RAISE EXCEPTION 'Há questão da aula de Scrum de Tecnologia da Informação fora das listas de exercícios';
  END IF;

  IF (
    SELECT COUNT(*)
    FROM quiz_questions qq
    JOIN ti_pilares_simulado sm ON sm.quiz_id = qq.quiz_id
    JOIN questions q ON q.id = qq.question_id
    JOIN ti_pilares_aula a ON a.topic_id = q.topic_id
    WHERE q.prompt IN (
      'Quais são os três pilares do Scrum?',
      'Na revisão da sprint, o time e o cliente percebem que uma funcionalidade entregue não atende ao que o cliente precisa, mas o time mantém o backlog como estava e segue o plano original. Que problema isso representa em relação aos pilares do Scrum?',
      'Quais práticas de um squad reforçam o pilar da transparência? Assinale todas as corretas.'
    )
    OR q.template LIKE 'Associe cada situação ao pilar do Scrum.%'
    OR q.template LIKE 'Na retrospectiva, o time percebe que os testes sempre ficam%'
  ) <> 5 THEN
    RAISE EXCEPTION 'O simulado não recebeu as 5 questões dos pilares do Scrum';
  END IF;
END $$;

COMMIT;
