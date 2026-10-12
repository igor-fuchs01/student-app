Gere um SCRIPT SQL (PostgreSQL / Supabase) que cadastra no Student App o conteúdo do material
anexado (slides de uma aula): a disciplina (se não existir), o assunto da aula, os subassuntos com
pontos-chave, as questões e as 3 listas de exercícios do assunto. O script é colado no SQL Editor
do Supabase e precisa rodar do início ao fim sem erro.

As listas de exercícios (quizzes com kind = 'exercise') são o que o aluno pratica na aba
"Exercícios": sem elas o assunto fica vazio. NÃO crie simulado (kind = 'exam'); ele é feito por
outro script.

=====================================================================
MODELO DE DADOS (não altere)
=====================================================================
subjects (disciplina)
  └── topics (assunto = uma aula, exibido como "Aula {number}")
        ├── subtopics → subtopic_key_points
        ├── questions (toda questão é do assunto, não do subassunto)
        └── quizzes kind 'exercise' → quiz_questions (questões de cada lista)

Colunas que você pode usar (ids são gerados pelo banco: NUNCA informe id):
- subjects (name, short_label)
- topics (subject_id, number, name, description)
- subtopics (topic_id, name, summary, order_index)
- subtopic_key_points (subtopic_id, text, order_index)
- questions (topic_id, type, prompt, template, explanation)
- question_options (question_id, text, is_correct, order_index)            → multiple_choice, multiple_answer
- question_blanks (question_id, blank_key, reference_answer, order_index)  → single_choice, essay_blanks
- question_blank_options (blank_id, text, is_correct, order_index)         → single_choice
- question_terms (question_id, text, order_index)                          → drag_and_drop
- question_slots (question_id, slot_key, correct_term_id, order_index)     → drag_and_drop
- quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty) → só listas de exercícios
- quiz_questions (quiz_id, question_id, order_index)
NÃO insira em materials.

Regras que o banco valida (qualquer violação derruba o script inteiro):
| type            | prompt      | template    | explanation |
|-----------------|-------------|-------------|-------------|
| multiple_choice | obrigatório | NULL        | obrigatório |
| multiple_answer | obrigatório | NULL        | obrigatório |
| single_choice   | NULL        | obrigatório | obrigatório |
| drag_and_drop   | NULL        | obrigatório | obrigatório |
| essay_blanks    | obrigatório | obrigatório | NULL        |
- Nenhum texto vazio ou só com espaços.
- order_index começa em 1 e não repete dentro do mesmo pai (inclusive em cada lista).
- blank_key/slot_key (b1, b2… / s1, s2…) não repetem na questão e cada um aparece como {{chave}}
  no template, e vice-versa.
- drag_and_drop: termos com textos distintos; dois slots nunca têm o mesmo termo correto.
- topics: (subject_id, name) e (subject_id, number) únicos; subtopics: (topic_id, name) e
  (topic_id, order_index) únicos.
- Lista de exercícios: kind 'exercise', subject_id da disciplina, topic_id da aula,
  duration_minutes NULL e difficulty 'easy' | 'medium' | 'hard' (cast ::difficulty_level).

=====================================================================
ESTRUTURA DA AULA (a partir dos slides)
=====================================================================
- Assunto: número da aula em DADOS DESTE LOTE; name curto (até ~60 caracteres), use o nome
  sugerido se representar bem os slides; description em UMA frase.
- Subassuntos: de 3 a 6, um por bloco temático, na ordem dos slides; name até ~50 caracteres;
  summary com 1 ou 2 frases.
- Pontos-chave: de 2 a 5 por subassunto, frases curtas e autossuficientes (definição, regra,
  comando). Ex.: "chmod 755: dono lê, escreve e executa; grupo e outros leem e executam."
- summary, description e pontos-chave são texto simples (sem Markdown/HTML).
- Disciplina: só é criada se não existir; short_label com 2 a 4 letras maiúsculas.
- As questões cobrem TODOS os subassuntos, proporcionalmente ao peso nos slides.
- Listas (títulos exatos, trocando só o nome do assunto, idêntico ao topics.name):
    '<NOME DO ASSUNTO> — Exercícios 1: Fundamentos'  'easy'   → fáceis e médias
    '<NOME DO ASSUNTO> — Exercícios 2: Aplicação'    'medium' → difíceis
    '<NOME DO ASSUNTO> — Exercícios 3: Desafio'      'hard'   → super difíceis
  Toda questão entra em EXATAMENTE UMA lista.

=====================================================================
TIPOS DE QUESTÃO
=====================================================================
1) multiple_choice: EXATAMENTE 5 alternativas (A–E), 1 correta.
2) multiple_answer: 4 ou 5 alternativas, 2 ou 3 corretas; o prompt diz "Assinale todas as
   corretas".
3) single_choice: lacunas {{b1}}… com um dropdown de 3 ou 4 opções cada, 1 correta por lacuna.
4) drag_and_drop: slots {{s1}}…; o aluno arrasta termos para associar ou ordenar; pelo menos 2
   termos distratores.
5) essay_blanks: lacunas de resposta livre; prompt é a instrução ("Complete…") e cada lacuna tem
   reference_answer de 1 a 3 palavras.
explanation (tipos 1 a 4): 1 ou 2 frases dizendo por que a resposta certa está certa.
Sequências longas sem espaço (ex.: "username:x:UID:GID:...") são escritas como no material.

=====================================================================
FORMATO DO SCRIPT (copie os moldes)
=====================================================================
BEGIN; … COMMIT;, nesta ordem: 1. disciplina  2. assunto  3. trava  4. subassuntos
5. pontos-chave  6. listas  7. questões  8. conferência. Apóstrofos dobrados: 'd''água'.
O assunto é sempre achado por:
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = '<DISCIPLINA>' AND t.number = <AULA>

-- 1. Disciplina
INSERT INTO subjects (name, short_label)
SELECT '<DISCIPLINA>', '<SIGLA>'
WHERE NOT EXISTS (SELECT 1 FROM subjects WHERE name = '<DISCIPLINA>');

-- 2. Assunto
INSERT INTO topics (subject_id, number, name, description)
SELECT s.id, <AULA>, '<NOME DO ASSUNTO>', '<Descrição em uma frase.>'
FROM subjects s
WHERE s.name = '<DISCIPLINA>'
ON CONFLICT DO NOTHING;

-- 3. Trava: aborta se a aula não existir ou já existir com outro nome
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM topics t JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = '<DISCIPLINA>' AND t.number = <AULA> AND t.name = '<NOME DO ASSUNTO>'
  ) THEN
    RAISE EXCEPTION 'A aula <AULA> de <DISCIPLINA> não existe ou já está cadastrada com outro nome';
  END IF;
END $$;

-- 4. Subassuntos
INSERT INTO subtopics (topic_id, name, summary, order_index)
SELECT t.id, v.name, v.summary, v.order_index
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Subassunto 1', 'Resumo em uma ou duas frases.', 1),
  ('Subassunto 2', 'Resumo em uma ou duas frases.', 2)
) AS v(name, summary, order_index)
WHERE s.name = '<DISCIPLINA>' AND t.number = <AULA>
ON CONFLICT DO NOTHING;

-- 5. Pontos-chave
INSERT INTO subtopic_key_points (subtopic_id, text, order_index)
SELECT st.id, v.text, v.order_index
FROM subtopics st
JOIN topics t ON t.id = st.topic_id
JOIN subjects s ON s.id = t.subject_id
JOIN (VALUES
  ('Subassunto 1', 'Ponto-chave 1.', 1),
  ('Subassunto 1', 'Ponto-chave 2.', 2),
  ('Subassunto 2', 'Ponto-chave 1.', 1)
) AS v(subtopic_name, text, order_index) ON v.subtopic_name = st.name
WHERE s.name = '<DISCIPLINA>' AND t.number = <AULA>
ON CONFLICT DO NOTHING;

-- 6. Listas de exercícios
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT v.title, 'exercise', t.subject_id, t.id, NULL, v.difficulty::difficulty_level
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('<NOME DO ASSUNTO> — Exercícios 1: Fundamentos', 'easy'),
  ('<NOME DO ASSUNTO> — Exercícios 2: Aplicação', 'medium'),
  ('<NOME DO ASSUNTO> — Exercícios 3: Desafio', 'hard')
) AS v(title, difficulty)
WHERE s.name = '<DISCIPLINA>' AND t.number = <AULA>
  AND NOT EXISTS (SELECT 1 FROM quizzes z WHERE z.title = v.title);

-- 7. Questões: cada uma é UM comando, com um comentário "número | tipo | dificuldade |
-- subassunto | lista | resposta". O CTE "l" põe a questão no fim da sua lista: copie-o em toda
-- questão, trocando só o título (idêntico ao da seção 6). Ele roda mesmo sem ser referenciado.

-- Q1 | multiple_choice | média | Subassunto 1 | Exercícios 1 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Enunciado…', 'Explicação…'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = '<DISCIPLINA>' AND t.number = <AULA>
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = '<NOME DO ASSUNTO> — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Alternativa A', false, 1),
  ('Alternativa B', false, 2),
  ('Alternativa C', true, 3),
  ('Alternativa D', false, 4),
  ('Alternativa E', false, 5)
) AS o(text, is_correct, order_index);

(multiple_answer: mesmo molde, com 'multiple_answer', mais de um true e o comentário
 "corretas: B, D".)

-- Q2 | single_choice | difícil | Subassunto 2 | Exercícios 2 | b1: X, b2: Y
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Texto com {{b1}} e {{b2}}.', 'Explicação…'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = '<DISCIPLINA>' AND t.number = <AULA>
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = '<NOME DO ASSUNTO> — Exercícios 2: Aplicação'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'opção 1', false, 1), ('b1', 'X', true, 2), ('b1', 'opção 3', false, 3),
  ('b2', 'Y', true, 1), ('b2', 'opção 2', false, 2), ('b2', 'opção 3', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q3 | drag_and_drop | super difícil | Subassunto 1 | Exercícios 3 | s1: Termo A, s2: Termo B
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Texto com {{s1}} e {{s2}}.', 'Explicação…'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = '<DISCIPLINA>' AND t.number = <AULA>
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = '<NOME DO ASSUNTO> — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('Termo C', 1), ('Termo A', 2), ('Termo D', 3), ('Termo B', 4)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'Termo A', 1), ('s2', 'Termo B', 2))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q4 | essay_blanks | fácil | Subassunto 2 | Exercícios 1 | b1: resposta
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, template)
  SELECT t.id, 'essay_blanks', 'Complete o texto.', 'Texto com {{b1}}.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = '<DISCIPLINA>' AND t.number = <AULA>
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = '<NOME DO ASSUNTO> — Exercícios 1: Fundamentos'
)
INSERT INTO question_blanks (question_id, blank_key, reference_answer, order_index)
SELECT q.id, v.blank_key, v.reference_answer, v.order_index
FROM q CROSS JOIN (VALUES ('b1', 'resposta', 1)) AS v(blank_key, reference_answer, order_index);

-- 8. Conferência: aborta se alguma questão ficou fora das listas ou alguma lista ficou vazia
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM questions q
    JOIN topics t ON t.id = q.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = '<DISCIPLINA>' AND t.number = <AULA>
      AND NOT EXISTS (
        SELECT 1 FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
        WHERE qq.question_id = q.id AND z.kind = 'exercise'
      )
  ) THEN
    RAISE EXCEPTION 'Há questão da aula <AULA> de <DISCIPLINA> fora das listas de exercícios';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM quizzes z
    JOIN topics t ON t.id = z.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = '<DISCIPLINA>' AND t.number = <AULA> AND z.kind = 'exercise'
      AND NOT EXISTS (SELECT 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  ) THEN
    RAISE EXCEPTION 'Há lista de exercícios da aula <AULA> de <DISCIPLINA> sem questões';
  END IF;
END $$;

=====================================================================
DADOS DESTE LOTE (eu preencho)
=====================================================================
Disciplina (subjects.name, exatamente como está no banco): Arquitetura Computacional
Sigla (short_label, só usada se a disciplina não existir): ARQ
Número da aula (topics.number): 4
Nome sugerido do assunto (topics.name): Permissões de Arquivos e Gerenciamento de Usuários
Situação: a disciplina já existe; o assunto (aula 4) ainda NÃO está cadastrado.

=====================================================================
O QUE GERAR
=====================================================================
EXATAMENTE 15 questões sobre o material:
- Dificuldade (só no comentário): 3 fáceis, 2 médias, 5 difíceis, 5 super difíceis, embaralhadas.
- Listas: fáceis e médias → Exercícios 1 (5 questões); difíceis → Exercícios 2 (5); super
  difíceis → Exercícios 3 (5).
- Tipos, embaralhados: 6 multiple_choice, 3 multiple_answer, 2 single_choice, 4 drag_and_drop e
  0 essay_blanks.
- Conteúdo: cenários realistas (empresas, equipes, sistemas) em que o aluno APLICA os conceitos,
  sem deixar de cobrar as definições básicas. Use só o que está no material.

Alternativas:
- multiple_choice: a correta aparece em A, B, C, D e E ao menos uma vez cada, nunca na mesma letra
  duas vezes seguidas.
- multiple_answer: as corretas nunca são só as primeiras (A+B, A+B+C) nem só as últimas (D+E,
  C+D+E); cada uma tem uma combinação diferente.
- Alternativas de tamanho parecido (diferença de até ~15%); a correta não é sistematicamente a
  mais longa.
- Distratores plausíveis, que diferem por detalhes (uma palavra, uma etapa, um conceito vizinho).
- Sem "todas/nenhuma das anteriores", sem pegadinha de português, sem ambiguidade.

=====================================================================
SAÍDA
=====================================================================
Retorne APENAS um bloco ```sql com o script completo, sem texto antes ou depois. Antes, confira:
1. Disciplina, número e nome do assunto idênticos em todos os WHERE e na trava.
2. Todo subtopic_name dos pontos-chave idêntico a um name de subassunto.
3. Colunas de cada questão batem com a tabela do type; toda {{chave}} tem lacuna/slot e
   vice-versa.
4. O true está onde o comentário indica.
5. Toda questão tem o CTE l com um título idêntico (inclusive o "—") a um da seção 6, na lista
   certa para a dificuldade.
6. Contagens de dificuldade, tipo e lista batem; apóstrofos dobrados; todo comando termina em ";".
