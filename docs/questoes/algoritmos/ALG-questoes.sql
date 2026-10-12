-- Algoritmos: aulas 1, 2 — disciplina, assuntos, subassuntos, pontos-chave, questões e listas
-- de exercícios. Gerado a partir de temp/prompt-questoes.txt e das pastas
-- "Aula 01 - Diagrama de atividades" e "Aula 02 - HTML e Javascript".
-- Uma única transação: se qualquer comando falhar, nada é gravado.
-- Não rode duas vezes: as questões seriam duplicadas.

BEGIN;

-- =====================================================================
-- AULA 1 — Diagrama de Atividades (pasta Aula 01 - Diagrama de atividades)
-- =====================================================================

-- 1. Disciplina
INSERT INTO subjects (name, short_label)
SELECT 'Algoritmos', 'ALG'
WHERE NOT EXISTS (SELECT 1 FROM subjects WHERE name = 'Algoritmos');

-- 2. Assunto
INSERT INTO topics (subject_id, number, name, description)
SELECT s.id, 1, 'Diagrama de Atividades', 'Como representar um algoritmo em um diagrama de atividades, com ações de receber, calcular e exibir, decisões guiadas por condições e repetições com contador.'
FROM subjects s
WHERE s.name = 'Algoritmos'
ON CONFLICT DO NOTHING;

-- 3. Trava: aborta se a aula não existir ou já existir com outro nome
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM topics t JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Algoritmos' AND t.number = 1 AND t.name = 'Diagrama de Atividades'
  ) THEN
    RAISE EXCEPTION 'A aula 1 de Algoritmos não existe ou já está cadastrada com outro nome';
  END IF;
END $$;

-- 4. Subassuntos
INSERT INTO subtopics (topic_id, name, summary, order_index)
SELECT t.id, v.name, v.summary, v.order_index
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Ações: receber, calcular e exibir', 'Todo diagrama parte de ações em sequência: receber os dados, calcular com eles e exibir o resultado. A ordem importa, pois um cálculo só pode usar valores já recebidos.', 1),
  ('Decisões e condições', 'Uma decisão divide o fluxo em caminhos, e cada caminho tem uma condição. As condições não se sobrepõem e, juntas, cobrem todos os valores possíveis.', 2),
  ('Faixas de valores e operadores lógicos', 'Faixas de valores são escritas com operadores relacionais combinados por operadores lógicos. O && exige as duas partes verdadeiras, o || aceita apenas uma e o ! inverte a condição.', 3),
  ('Decisões aninhadas', 'Uma decisão pode ficar dentro do caminho de outra, quando o resultado depende de mais de um dado. Cada caminho completo corresponde a uma combinação de condições.', 4),
  ('Repetição com contador e acumulador', 'Para repetir ações, o fluxo volta a um ponto anterior enquanto uma condição for verdadeira. O contador controla quantas voltas foram dadas e o acumulador soma valores a cada volta.', 5)
) AS v(name, summary, order_index)
WHERE s.name = 'Algoritmos' AND t.number = 1
ON CONFLICT DO NOTHING;

-- 5. Pontos-chave
INSERT INTO subtopic_key_points (subtopic_id, text, order_index)
SELECT st.id, v.text, v.order_index
FROM subtopics st
JOIN topics t ON t.id = st.topic_id
JOIN subjects s ON s.id = t.subject_id
JOIN (VALUES
  ('Ações: receber, calcular e exibir', 'Receber: guarda em uma variável o valor informado pelo usuário, como nota1 ou salEstagio.', 1),
  ('Ações: receber, calcular e exibir', 'Calcular: produz um novo valor a partir de outros, como media = (nota1 + nota2) / 2.', 2),
  ('Ações: receber, calcular e exibir', 'Exibir: mostra ao usuário uma mensagem ou o valor de uma variável.', 3),
  ('Ações: receber, calcular e exibir', 'Uma variável só pode ser usada em um cálculo depois de ter sido recebida ou declarada.', 4),
  ('Decisões e condições', 'Cada caminho de saída de uma decisão leva uma condição, como media < 5 e media >= 5.', 1),
  ('Decisões e condições', 'As condições de uma decisão são excludentes: um valor nunca atende a duas ao mesmo tempo.', 2),
  ('Decisões e condições', 'Juntas, as condições cobrem todos os valores: media < 5 e media >= 5 não deixam nenhuma média de fora.', 3),
  ('Faixas de valores e operadores lógicos', '&& (e): a condição só é verdadeira quando as duas partes são verdadeiras, como horasNoite >= 5 && horasNoite < 7.', 1),
  ('Faixas de valores e operadores lógicos', '|| (ou): basta uma das partes ser verdadeira, como nota1 < 0 || nota1 > 10.', 2),
  ('Faixas de valores e operadores lógicos', '! (não): inverte o resultado da condição que vem depois dele.', 3),
  ('Faixas de valores e operadores lógicos', 'O oposto de media >= 6 && frequencia >= 70 é media < 6 || frequencia < 70.', 4),
  ('Faixas de valores e operadores lógicos', 'Faixas vizinhas não repetem o limite: se uma usa < 7, a seguinte começa em >= 7.', 5),
  ('Decisões aninhadas', 'No diagrama de sexo e idade, a primeira decisão testa o sexo e, em cada caminho, outra decisão testa a idade.', 1),
  ('Decisões aninhadas', 'Duas decisões de dois caminhos, uma dentro da outra, formam quatro resultados possíveis.', 2),
  ('Decisões aninhadas', 'Para ordenar três números, o diagrama compara dois a dois: primeiro numA com numB, depois cada um deles com numC.', 3),
  ('Repetição com contador e acumulador', 'O contador é declarado antes do laço (contador = 0) e incrementado a cada volta (contador = contador + 1).', 1),
  ('Repetição com contador e acumulador', 'O laço continua enquanto contador < numFilho e termina quando contador >= numFilho.', 2),
  ('Repetição com contador e acumulador', 'O acumulador também nasce antes do laço (valorBolsa = 0) e recebe uma soma a cada volta.', 3),
  ('Repetição com contador e acumulador', 'Validação de entrada: se nota1 < 0 || nota1 > 10, o fluxo volta a receber a nota.', 4)
) AS v(subtopic_name, text, order_index) ON v.subtopic_name = st.name
WHERE s.name = 'Algoritmos' AND t.number = 1
ON CONFLICT DO NOTHING;

-- 6. Listas de exercícios
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT v.title, 'exercise', t.subject_id, t.id, NULL, v.difficulty::difficulty_level
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Diagrama de Atividades — Exercícios 1: Fundamentos', 'easy'),
  ('Diagrama de Atividades — Exercícios 2: Aplicação', 'medium'),
  ('Diagrama de Atividades — Exercícios 3: Desafio', 'hard')
) AS v(title, difficulty)
WHERE s.name = 'Algoritmos' AND t.number = 1
  AND NOT EXISTS (SELECT 1 FROM quizzes z WHERE z.title = v.title);

-- 7. Questões

-- Q1 | multiple_choice | fácil | Ações: receber, calcular e exibir | Exercícios 1 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um diagrama de atividades deve calcular e mostrar a média de duas notas de um aluno. Qual sequência de ações resolve o problema?', 'A média só pode ser calculada depois que as duas notas foram recebidas, e só pode ser exibida depois de calculada.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Diagrama de Atividades — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Calcular a média, receber nota1, receber nota2 e exibir a média.', false, 1),
  ('Receber nota1, receber nota2, calcular a média e exibir a média.', true, 2),
  ('Receber nota1, exibir a média, receber nota2 e calcular a média.', false, 3),
  ('Exibir a média, receber nota1, receber nota2 e calcular a média.', false, 4),
  ('Receber nota1, calcular a média, receber nota2 e exibir a média.', false, 5)
) AS o(text, is_correct, order_index);

-- Q2 | drag_and_drop | média | Decisões e condições | Exercícios 1 | s1: media < 5, s2: media >= 5
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Um diagrama calcula media = (nota1 + nota2) / 2. O aluno com média abaixo de 5 deve tentar de novo, e o aluno com média a partir de 5 segue para o estágio. Por isso o diagrama se divide em dois caminhos: se {{s1}}, exibe "#partiutentardenovo"; se {{s2}}, exibe "#partiuestágio".', 'As condições media < 5 e media >= 5 são excludentes e cobrem todas as médias possíveis, inclusive a média 5.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Diagrama de Atividades — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('media > 5', 1),
    ('media < 5', 2),
    ('media == 5', 3),
    ('media >= 5', 4),
    ('media <= 5', 5)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'media < 5', 1),
  ('s2', 'media >= 5', 2)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q3 | multiple_choice | difícil | Faixas de valores e operadores lógicos | Exercícios 2 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um aplicativo de saúde classifica as horas dormidas por noite. Quem dorme de 5 horas até menos de 7 horas recebe a mensagem "Pouca Concentração". Qual condição representa essa faixa?', 'A faixa inclui o 5 (>=) e exclui o 7 (<), e as duas partes precisam valer juntas, por isso o operador é &&.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Diagrama de Atividades — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('horasNoite > 5 && horasNoite < 7', false, 1),
  ('horasNoite >= 5 || horasNoite < 7', false, 2),
  ('horasNoite >= 5 && horasNoite <= 7', false, 3),
  ('horasNoite >= 5 && horasNoite < 7', true, 4),
  ('horasNoite > 5 || horasNoite <= 7', false, 5)
) AS o(text, is_correct, order_index);

-- Q4 | multiple_answer | fácil | Ações: receber, calcular e exibir | Exercícios 1 | corretas: A, C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Um diagrama calcula a média diária do salário líquido de um estagiário com media = (salEstagio - valorFacul) / 30. Assinale todas as corretas.', 'As duas variáveis precisam ser recebidas antes do cálculo, e os parênteses fazem a subtração acontecer antes da divisão por 30.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Diagrama de Atividades — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('salEstagio e valorFacul precisam ser recebidos antes do cálculo.', true, 1),
  ('A média pode ser exibida antes de o valorFacul ser recebido.', false, 2),
  ('O valor da faculdade é subtraído do salário antes da divisão.', true, 3),
  ('A divisão por 30 acontece antes da subtração do valorFacul.', false, 4)
) AS o(text, is_correct, order_index);

-- Q5 | single_choice | difícil | Decisões aninhadas | Exercícios 2 | b1: o sexo, b2: a idade, b3: "Você é mulher e menina"
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Um diagrama recebe sexo e idade do usuário e exibe uma de quatro mensagens: "Você é mulher maior de idade" ou "Você é homem maior de idade" para idade >= 18, e "Você é mulher e menina" ou "Você é homem e menino" para idade < 18. A primeira decisão separa homens e mulheres, testando {{b1}}; dentro de cada caminho, uma segunda decisão testa {{b2}}. Para sexo == "mulher" e idade = 16, a mensagem exibida é {{b3}}.', 'A decisão do sexo vem primeiro e a da idade fica dentro de cada caminho; como 16 é menor que 18, o caminho é o de mulher com idade < 18.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Diagrama de Atividades — Exercícios 2: Aplicação'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'a idade', false, 1), ('b1', 'o sexo', true, 2), ('b1', 'a média', false, 3),
  ('b2', 'a idade', true, 1), ('b2', 'o nome', false, 2), ('b2', 'o sexo', false, 3),
  ('b3', '"Você é mulher maior de idade"', false, 1), ('b3', '"Você é homem e menino"', false, 2), ('b3', '"Você é mulher e menina"', true, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q6 | multiple_choice | super difícil | Decisões aninhadas | Exercícios 3 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um diagrama recebe numA, numB e numC e, com decisões aninhadas que comparam os valores dois a dois, exibe as três variáveis do maior valor para o menor. Para numA = 4, numB = 9 e numC = 6, qual é a saída?', 'Como numA < numB e numC < numB, numB é o maior; entre os restantes, numC (6) é maior que numA (4).'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Diagrama de Atividades — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('numB, numC, numA', true, 1),
  ('numB, numA, numC', false, 2),
  ('numC, numB, numA', false, 3),
  ('numA, numC, numB', false, 4),
  ('numC, numA, numB', false, 5)
) AS o(text, is_correct, order_index);

-- Q7 | drag_and_drop | difícil | Repetição com contador e acumulador | Exercícios 2 | s1: declarar valorBolsa = 0 e contador = 0, s2: receber a idade do filho, s3: somar a valorBolsa o valor da faixa de idade, s4: fazer contador = contador + 1
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Uma empresa paga uma bolsa por filho do funcionário, conforme a idade de cada um. No diagrama, antes do laço vem {{s1}}; a cada volta, o fluxo executa {{s2}}, depois {{s3}} e, por fim, {{s4}}.', 'Contador e acumulador nascem antes do laço; em cada volta a idade é recebida, o valor da faixa é somado e o contador é incrementado.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Diagrama de Atividades — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('somar a valorBolsa o valor da faixa de idade', 1),
    ('exibir o valor total da bolsa', 2),
    ('declarar valorBolsa = 0 e contador = 0', 3),
    ('fazer contador = contador + 1', 4),
    ('receber o salário bruto', 5),
    ('receber a idade do filho', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'declarar valorBolsa = 0 e contador = 0', 1),
  ('s2', 'receber a idade do filho', 2),
  ('s3', 'somar a valorBolsa o valor da faixa de idade', 3),
  ('s4', 'fazer contador = contador + 1', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q8 | multiple_choice | média | Decisões e condições | Exercícios 1 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Em uma decisão de um diagrama de atividades, como devem ser as condições escritas nos caminhos de saída?', 'Cada valor deve seguir por um único caminho e nenhum valor pode ficar sem caminho, como em media < 5 e media >= 5.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Diagrama de Atividades — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Iguais em todos os caminhos, para o fluxo nunca parar.', false, 1),
  ('Verdadeiras ao mesmo tempo, para seguir dois caminhos.', false, 2),
  ('Escritas só no primeiro caminho, deixando o outro livre.', false, 3),
  ('Avaliadas depois da ação que cada caminho executa.', false, 4),
  ('Excludentes entre si, cobrindo todos os valores possíveis.', true, 5)
) AS o(text, is_correct, order_index);

-- Q9 | multiple_answer | difícil | Faixas de valores e operadores lógicos | Exercícios 2 | corretas: B, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Um sistema de notas só aceita valores de 0 a 10. No diagrama, se nota1 < 0 || nota1 > 10, o fluxo volta a receber a nota. Assinale todas as corretas.', 'Com ||, basta uma parte verdadeira para a nota ser recusada; a nota válida exige as duas partes ao mesmo tempo, por isso usa &&.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Diagrama de Atividades — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('nota1 = 10 é inválida e o diagrama volta a pedir a nota.', false, 1),
  ('nota1 = -1 torna a condição nota1 < 0 || nota1 > 10 verdadeira.', true, 2),
  ('A nota válida é descrita por nota1 >= 0 || nota1 <= 10.', false, 3),
  ('A nota válida é descrita por nota1 >= 0 && nota1 <= 10.', true, 4),
  ('Com ||, as duas partes precisam ser verdadeiras juntas.', false, 5)
) AS o(text, is_correct, order_index);

-- Q10 | multiple_choice | super difícil | Repetição com contador e acumulador | Exercícios 3 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma empresa paga bolsa por filho: 25 se idade >= 0 && idade <= 3, 20 se idade > 3 && idade <= 16 e 15 se idade > 16. O diagrama começa com valorBolsa = 0 e soma o valor de cada filho dentro do laço. Para um funcionário com filhos de 2, 10 e 17 anos, qual valorBolsa é exibido?', 'O filho de 2 anos soma 25, o de 10 anos soma 20 e o de 17 anos soma 15: 25 + 20 + 15 = 60.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Diagrama de Atividades — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('45', false, 1),
  ('55', false, 2),
  ('60', true, 3),
  ('65', false, 4),
  ('75', false, 5)
) AS o(text, is_correct, order_index);

-- Q11 | drag_and_drop | super difícil | Faixas de valores e operadores lógicos | Exercícios 3 | s1: media >= 6, s2: &&, s3: frequencia >= 70, s4: ||
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Uma escola aprova o aluno com média a partir de 6 e frequência a partir de 70. O caminho "Parabéns, aprovado" usa a condição {{s1}} {{s2}} {{s3}}; o caminho "Infelizmente, reprovado" usa a condição oposta: media < 6 {{s4}} frequencia < 70.', 'A aprovação exige as duas partes verdadeiras (&&); para reprovar basta uma delas falhar, por isso a condição oposta usa ||.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Diagrama de Atividades — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('frequencia > 70', 1),
    ('&&', 2),
    ('media >= 6', 3),
    ('!', 4),
    ('||', 5),
    ('frequencia >= 70', 6),
    ('media > 6', 7)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'media >= 6', 1),
  ('s2', '&&', 2),
  ('s3', 'frequencia >= 70', 3),
  ('s4', '||', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q12 | multiple_choice | difícil | Repetição com contador e acumulador | Exercícios 2 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um laço começa com contador = 0, repete enquanto contador < numFilho e, no fim de cada volta, faz contador = contador + 1. Para numFilho = 3, quantas vezes a idade do filho é recebida?', 'As voltas acontecem com contador 0, 1 e 2; quando ele chega a 3, a condição contador < numFilho é falsa e o laço termina.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Diagrama de Atividades — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('3 vezes, com contador valendo 0, 1 e 2.', true, 1),
  ('4 vezes, com contador valendo 0, 1, 2 e 3.', false, 2),
  ('2 vezes, com contador valendo 1 e 2.', false, 3),
  ('3 vezes, com contador valendo 1, 2 e 3.', false, 4),
  ('2 vezes, com contador valendo 0 e 1.', false, 5)
) AS o(text, is_correct, order_index);

-- Q13 | single_choice | super difícil | Repetição com contador e acumulador | Exercícios 3 | b1: 200, b2: 1600, b3: 1900
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Em um diagrama de folha de pagamento, com salBruto = 2000 e totalBeneficio = 300, o cálculo descontoInss = salBruto * 0.10 resulta em {{b1}}, e descontoIr tem o mesmo valor. Depois de subtrair os dois descontos, salLiquido vale {{b2}}; ao somar os benefícios, o valor exibido é {{b3}}.', 'Cada desconto é 10% de 2000, ou seja, 200; 2000 - 200 - 200 = 1600 e 1600 + 300 = 1900.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Diagrama de Atividades — Exercícios 3: Desafio'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', '100', false, 1), ('b1', '200', true, 2), ('b1', '400', false, 3),
  ('b2', '1800', false, 1), ('b2', '1700', false, 2), ('b2', '1600', true, 3),
  ('b3', '1900', true, 1), ('b3', '2100', false, 2), ('b3', '2300', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q14 | multiple_answer | super difícil | Faixas de valores e operadores lógicos | Exercícios 3 | corretas: A, C, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'O diagrama do caixa de um mercado usa a condição codigo != "abacaxi" || codigo != "morango" || codigo != "tomate" para exibir "Código não reconhecido". Assinale todas as corretas.', 'Qualquer código é diferente de pelo menos dois dos três nomes, então com || a condição é sempre verdadeira; com &&, ela só vale para códigos que não são nenhum dos três.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Diagrama de Atividades — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Para codigo == "morango" ela é verdadeira, pois ele difere de "abacaxi".', true, 1),
  ('A condição só é verdadeira quando o código não é nenhum dos três.', false, 2),
  ('Trocar || por && faz a condição valer só para códigos desconhecidos.', true, 3),
  ('Com ||, basta uma parte falsa para a condição inteira ser falsa.', false, 4),
  ('Escrita assim, ela é verdadeira para qualquer código informado.', true, 5)
) AS o(text, is_correct, order_index);

-- Q15 | drag_and_drop | fácil | Ações: receber, calcular e exibir | Exercícios 1 | s1: Receber, s2: Calcular, s3: Exibir
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Em um diagrama de atividades, a ação {{s1}} guarda em uma variável o valor informado pelo usuário, a ação {{s2}} produz um novo valor a partir de outros e a ação {{s3}} mostra uma mensagem ou um valor ao usuário.', 'Receber é a entrada de dados, Calcular é o processamento e Exibir é a saída do algoritmo.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Diagrama de Atividades — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('Exibir', 1),
    ('Decidir', 2),
    ('Receber', 3),
    ('Repetir', 4),
    ('Calcular', 5)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'Receber', 1),
  ('s2', 'Calcular', 2),
  ('s3', 'Exibir', 3)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- 8. Conferência: aborta se alguma questão ficou fora das listas ou alguma lista ficou vazia
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM questions q
    JOIN topics t ON t.id = q.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Algoritmos' AND t.number = 1
      AND NOT EXISTS (
        SELECT 1 FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
        WHERE qq.question_id = q.id AND z.kind = 'exercise'
      )
  ) THEN
    RAISE EXCEPTION 'Há questão da aula 1 de Algoritmos fora das listas de exercícios';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM quizzes z
    JOIN topics t ON t.id = z.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Algoritmos' AND t.number = 1 AND z.kind = 'exercise'
      AND NOT EXISTS (SELECT 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  ) THEN
    RAISE EXCEPTION 'Há lista de exercícios da aula 1 de Algoritmos sem questões';
  END IF;
END $$;

-- =====================================================================
-- AULA 2 — JavaScript: Funções, Variáveis e Decisões (pasta Aula 02 - HTML e Javascript)
-- =====================================================================

-- 1. Disciplina
INSERT INTO subjects (name, short_label)
SELECT 'Algoritmos', 'ALG'
WHERE NOT EXISTS (SELECT 1 FROM subjects WHERE name = 'Algoritmos');

-- 2. Assunto
INSERT INTO topics (subject_id, number, name, description)
SELECT s.id, 2, 'JavaScript: Funções, Variáveis e Decisões', 'Como escrever a lógica de um programa em JavaScript com funções, variáveis locais e globais, operadores aritméticos e decisões com if, else e else if.'
FROM subjects s
WHERE s.name = 'Algoritmos'
ON CONFLICT DO NOTHING;

-- 3. Trava: aborta se a aula não existir ou já existir com outro nome
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM topics t JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Algoritmos' AND t.number = 2 AND t.name = 'JavaScript: Funções, Variáveis e Decisões'
  ) THEN
    RAISE EXCEPTION 'A aula 2 de Algoritmos não existe ou já está cadastrada com outro nome';
  END IF;
END $$;

-- 4. Subassuntos
INSERT INTO subtopics (topic_id, name, summary, order_index)
SELECT t.id, v.name, v.summary, v.order_index
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Funções: declarar e chamar', 'Uma função guarda um bloco de código com um nome. Declarar a função não executa nada: o bloco só roda quando ela é chamada, e roda de novo a cada chamada.', 1),
  ('Texto: concatenação e interpolação', 'Mensagens que misturam texto e variáveis são montadas por concatenação, com +, ou por interpolação, com crases e ${ }. Atribuir com = troca a mensagem e com += acrescenta ao que já existia.', 2),
  ('Number() e operadores aritméticos', 'Todo valor digitado chega como texto, e Number() o converte para que as contas funcionem. Os operadores +, -, *, / e % seguem a precedência da matemática, e os parênteses mudam a ordem.', 3),
  ('Variáveis locais e globais', 'A variável declarada dentro da função é local: é recriada a cada chamada e não existe fora dela. A declarada fora das funções é global: todas as funções a enxergam e ela mantém o valor entre as chamadas.', 4),
  ('Decisão com if e else', 'O if executa um bloco apenas quando a condição é verdadeira, e o else cobre o caso contrário. O código escrito depois do bloco executa sempre, e vários if separados são todos testados.', 5),
  ('Encadeamento com else if', 'O else if encadeia várias condições em uma única decisão. Elas são testadas em ordem e apenas o bloco da primeira condição verdadeira executa, por isso a ordem muda o resultado.', 6)
) AS v(name, summary, order_index)
WHERE s.name = 'Algoritmos' AND t.number = 2
ON CONFLICT DO NOTHING;

-- 5. Pontos-chave
INSERT INTO subtopic_key_points (subtopic_id, text, order_index)
SELECT st.id, v.text, v.order_index
FROM subtopics st
JOIN topics t ON t.id = st.topic_id
JOIN subjects s ON s.id = t.subject_id
JOIN (VALUES
  ('Funções: declarar e chamar', 'function somar() { ... } declara a função; o código entre chaves fica guardado, sem executar.', 1),
  ('Funções: declarar e chamar', 'A função só executa quando é chamada pelo nome, como somar(); na página, quem chama é o clique do botão.', 2),
  ('Funções: declarar e chamar', 'Cada chamada executa o bloco inteiro de novo, do início ao fim.', 3),
  ('Funções: declarar e chamar', 'alert(texto) mostra o texto em uma caixa de mensagem e é útil para conferir o resultado da lógica.', 4),
  ('Texto: concatenação e interpolação', 'Concatenação: ''O time '' + nome + '' tem '' + titulos + '' títulos''; os espaços precisam estar dentro das aspas.', 1),
  ('Texto: concatenação e interpolação', 'Interpolação: o texto fica entre crases e cada variável ou conta entra em ${ }, como `Falta ${meta - economia}`.', 2),
  ('Texto: concatenação e interpolação', '${ } só funciona entre crases; entre aspas, ele aparece como texto comum.', 3),
  ('Texto: concatenação e interpolação', 'mensagem = texto substitui o conteúdo anterior; mensagem += texto acrescenta ao fim do que já existia.', 4),
  ('Number() e operadores aritméticos', 'Number(texto) converte o texto digitado em número; sem ele, ''2'' + ''3'' resulta em ''23''.', 1),
  ('Number() e operadores aritméticos', 'O operador % devolve o resto da divisão: 7 % 2 resulta em 1, e num % 2 == 0 indica número par.', 2),
  ('Number() e operadores aritméticos', '* e / são calculados antes de + e -; os parênteses mudam a ordem, como em (nota1 + nota2) / 2.', 3),
  ('Number() e operadores aritméticos', 'Porcentagem é multiplicação: valor * 0.10 calcula 10% do valor.', 4),
  ('Number() e operadores aritméticos', 'toFixed(n) formata com n casas decimais e arredonda: (3.5).toFixed(0) devolve 4.', 5),
  ('Variáveis locais e globais', 'Local: let idade = Number(...) dentro da função é recriada a cada chamada.', 1),
  ('Variáveis locais e globais', 'Global: let saldo = 0 fora das funções guarda o valor entre uma chamada e outra.', 2),
  ('Variáveis locais e globais', 'Várias funções podem ler e alterar a mesma variável global, como depositar() e retirar() com o saldo.', 3),
  ('Variáveis locais e globais', 'saldo += 100 equivale a saldo = saldo + 100; saldo -= 50 equivale a saldo = saldo - 50.', 4),
  ('Variáveis locais e globais', 'Usar uma variável que nunca foi declarada gera erro e interrompe a função naquele ponto.', 5),
  ('Decisão com if e else', 'if (condição) { ... } executa o bloco só se a condição for verdadeira.', 1),
  ('Decisão com if e else', 'O código depois do fechamento do if executa sempre, seja a condição verdadeira ou falsa.', 2),
  ('Decisão com if e else', 'else { ... } executa quando a condição do if é falsa; os dois blocos nunca executam juntos.', 3),
  ('Decisão com if e else', 'Vários if separados são todos testados, um após o outro, mesmo que um anterior tenha sido verdadeiro.', 4),
  ('Decisão com if e else', 'A condição usa ==, !=, <, <=, > e >=; o limite só entra na faixa com <= ou >=.', 5),
  ('Encadeamento com else if', 'Em if / else if / else, as condições são testadas de cima para baixo e só o primeiro bloco verdadeiro executa.', 1),
  ('Encadeamento com else if', 'Cada else if só é testado se todas as condições anteriores forem falsas.', 2),
  ('Encadeamento com else if', 'Por isso basta o limite superior de cada faixa: depois de nota < 5, o teste nota <= 7 já significa de 5 a 7.', 3),
  ('Encadeamento com else if', 'A ordem importa: uma condição mais ampla escrita antes impede que a mais específica seja alcançada.', 4),
  ('Encadeamento com else if', 'O else final cobre tudo o que não entrou em nenhuma condição; sem ele, pode não acontecer nada.', 5)
) AS v(subtopic_name, text, order_index) ON v.subtopic_name = st.name
WHERE s.name = 'Algoritmos' AND t.number = 2
ON CONFLICT DO NOTHING;

-- 6. Listas de exercícios
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT v.title, 'exercise', t.subject_id, t.id, NULL, v.difficulty::difficulty_level
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('JavaScript: Funções, Variáveis e Decisões — Exercícios 1: Fundamentos', 'easy'),
  ('JavaScript: Funções, Variáveis e Decisões — Exercícios 2: Aplicação', 'medium'),
  ('JavaScript: Funções, Variáveis e Decisões — Exercícios 3: Desafio', 'hard')
) AS v(title, difficulty)
WHERE s.name = 'Algoritmos' AND t.number = 2
  AND NOT EXISTS (SELECT 1 FROM quizzes z WHERE z.title = v.title);

-- 7. Questões

-- Q1 | multiple_choice | fácil | Funções: declarar e chamar | Exercícios 1 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'O script de um semáforo contém apenas: function stop() { alert("Pare e Aguarde!"); } function think() { alert("Pense se pode seguir ou se deve parar!"); } function go() { alert("Pode seguir adiante."); }. O que acontece quando esse script é carregado, antes de qualquer clique?', 'Declarar uma função apenas guarda o código; nenhum alert aparece enquanto stop(), think() ou go() não forem chamadas.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'JavaScript: Funções, Variáveis e Decisões — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Os três alertas aparecem, na ordem das declarações.', false, 1),
  ('Só o alerta de stop aparece, pois ela vem primeiro.', false, 2),
  ('Nenhum alerta aparece, pois nada foi chamado ainda.', true, 3),
  ('Só o alerta de go aparece, pois ela é a última.', false, 4),
  ('O script gera erro, pois falta chamar as funções.', false, 5)
) AS o(text, is_correct, order_index);

-- Q2 | drag_and_drop | difícil | Variáveis locais e globais | Exercícios 2 | s1: 880, s2: 780, s3: 540, s4: 1000
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'O controle de uma caldeira começa com let horasRestantes = 1000; fora das funções. processar(dias) faz horasRestantes = horasRestantes - dias * 24; stop() faz horasRestantes = horasRestantes - 100; e reiniciar() faz horasRestantes = 1000. Em sequência: após processar 5 dias, a variável vale {{s1}}; após stop(), vale {{s2}}; após processar mais 10 dias, vale {{s3}}; após reiniciar(), vale {{s4}}.', 'Como a variável é global, cada função parte do valor deixado pela anterior: 1000 - 120 = 880, 880 - 100 = 780, 780 - 240 = 540, e reiniciar devolve 1000.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'JavaScript: Funções, Variáveis e Decisões — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('780', 1),
    ('900', 2),
    ('1000', 3),
    ('540', 4),
    ('640', 5),
    ('880', 6),
    ('760', 7)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', '880', 1),
  ('s2', '780', 2),
  ('s3', '540', 3),
  ('s4', '1000', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q3 | multiple_choice | média | Texto: concatenação e interpolação | Exercícios 1 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Em um script de torcida, let nome = ''Santos''; e let titulos = 8;. Qual expressão resulta exatamente no texto O time Santos tem 8 títulos?', 'Na concatenação, as variáveis ficam fora das aspas, ligadas por +, e os espaços precisam estar dentro dos textos.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'JavaScript: Funções, Variáveis e Decisões — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('''O time '' + nome + '' tem '' + titulos + '' títulos''', true, 1),
  ('''O time'' + nome + ''tem'' + titulos + ''títulos''', false, 2),
  ('''O time + nome + tem + titulos + títulos''', false, 3),
  ('''O time '' nome '' tem '' titulos '' títulos''', false, 4),
  ('''O time ${nome} tem ${titulos} títulos''', false, 5)
) AS o(text, is_correct, order_index);

-- Q4 | multiple_answer | super difícil | Encadeamento com else if | Exercícios 3 | corretas: B, C, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Um monitor de umidade do ar usa: if (umidade < 0) { alert("abaixo do permitido"); } else if (umidade > 100) { alert("acima do permitido"); } else if (umidade < 12) { "Estado de Emergência" } else if (umidade <= 20) { "Estado de Alerta" } else if (umidade <= 30) { "Estado de Atenção" } else { "Nenhum risco" }. Assinale todas as corretas.', 'Só o primeiro bloco verdadeiro executa: 12 < 12 é falso, então 12 cai em Alerta; 20 <= 20 é Alerta; e os valores fora de 0 a 100 param nos dois primeiros testes.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'JavaScript: Funções, Variáveis e Decisões — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Para umidade = 12, o resultado é "Estado de Emergência".', false, 1),
  ('Para umidade = 20, o resultado é "Estado de Alerta".', true, 2),
  ('Para umidade = 150, só o alerta de valor acima aparece.', true, 3),
  ('Para umidade = -5, o resultado é "Estado de Emergência".', false, 4),
  ('O teste umidade < 12 só ocorre com umidade de 0 a 100.', true, 5)
) AS o(text, is_correct, order_index);

-- Q5 | drag_and_drop | fácil | Number() e operadores aritméticos | Exercícios 1 | s1: Number, s2: -, s3: 45
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Uma função calcula quantos anos faltam para a aposentadoria aos 70 anos: let idade = {{s1}}(input_idade.value); let resultado = 70 {{s2}} idade;. Para idade = 25, resultado vale {{s3}}.', 'Number() converte o texto digitado em número e a subtração 70 - 25 resulta nos 45 anos que faltam.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'JavaScript: Funções, Variáveis e Decisões — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('+', 1),
    ('45', 2),
    ('String', 3),
    ('95', 4),
    ('Number', 5),
    ('-', 6),
    ('%', 7)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'Number', 1),
  ('s2', '-', 2),
  ('s3', '45', 3)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q6 | multiple_choice | média | Decisão com if e else | Exercícios 1 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'A função de entrada de uma festa executa: if (idade < 18) { alert("Pedir permissão pro responsável"); } alert("#partiuFesta");. Para idade = 15, o que é exibido?', '15 < 18 é verdadeiro, então o primeiro alert executa; o segundo está fora do if e executa sempre, logo em seguida.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'JavaScript: Funções, Variáveis e Decisões — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Só o alerta de pedir permissão ao responsável.', false, 1),
  ('Só o alerta #partiuFesta, sem o de permissão.', false, 2),
  ('Nenhum alerta, pois a condição do if é falsa.', false, 3),
  ('O alerta #partiuFesta e depois o de permissão.', false, 4),
  ('O alerta de permissão e depois o #partiuFesta.', true, 5)
) AS o(text, is_correct, order_index);

-- Q7 | single_choice | difícil | Number() e operadores aritméticos | Exercícios 2 | b1: 1, b2: 3.5, b3: 4
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Uma função de divisão recebe n1 = 7 e n2 = 2. A expressão n1 % n2 resulta em {{b1}} e n1 / n2 resulta em {{b2}}. Já (n1 / n2).toFixed(0) devolve {{b3}}, por isso toFixed(0) não serve para obter o quociente inteiro.', '7 dividido por 2 dá 3.5 e sobra 1; toFixed(0) arredonda 3.5 para 4, em vez de cortar a parte decimal.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'JavaScript: Funções, Variáveis e Decisões — Exercícios 2: Aplicação'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', '0', false, 1), ('b1', '1', true, 2), ('b1', '2', false, 3),
  ('b2', '3', false, 1), ('b2', '4', false, 2), ('b2', '3.5', true, 3),
  ('b3', '4', true, 1), ('b3', '3', false, 2), ('b3', '3.5', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q8 | multiple_choice | difícil | Decisão com if e else | Exercícios 2 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma função de conta de luz executa: let total = consumo * 0.85; if (consumo < 100) { total = total - total * 0.1; }. Para consumo = 100, quanto vale total ao final?', '100 * 0.85 = 85 e a condição 100 < 100 é falsa, então o bloco do desconto não executa.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'JavaScript: Funções, Variáveis e Decisões — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('76.5, pois o desconto de 10% vale para consumo 100.', false, 1),
  ('85, pois 100 < 100 é falso e o desconto não entra.', true, 2),
  ('75, pois o desconto é subtraído antes da tarifa.', false, 3),
  ('100, pois o if impede o cálculo da tarifa de 0.85.', false, 4),
  ('8.5, pois total passa a guardar apenas o desconto.', false, 5)
) AS o(text, is_correct, order_index);

-- Q9 | multiple_answer | fácil | Variáveis locais e globais | Exercícios 1 | corretas: B, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Um contador é escrito assim: let contador = 0; fora das funções, function incrementar() { contador += 1; } e function decrementar() { contador -= 1; }. Assinale todas as corretas.', 'A variável global mantém o valor entre as chamadas e é enxergada pelas duas funções; += 1 soma 1 ao valor atual.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'JavaScript: Funções, Variáveis e Decisões — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A cada chamada de incrementar, contador volta a valer 0.', false, 1),
  ('Após três chamadas de incrementar, contador vale 3.', true, 2),
  ('decrementar não enxerga contador, que é de incrementar.', false, 3),
  ('contador += 1 equivale a contador = contador + 1.', true, 4)
) AS o(text, is_correct, order_index);

-- Q10 | drag_and_drop | super difícil | Number() e operadores aritméticos | Exercícios 3 | s1: 8, s2: 22, s3: 28
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Amigos dividem uma pizza com 10% de caixinha. Com valorCompra = 80 e qtdAmigos = 4, let valorCaixinha = valorCompra * 0.10; resulta em {{s1}} e let valorPorAmigo = (valorCaixinha + valorCompra) / qtdAmigos; resulta em {{s2}}. Sem os parênteses, valorCaixinha + valorCompra / qtdAmigos resultaria em {{s3}}.', '10% de 80 é 8; (8 + 80) / 4 = 22; sem os parênteses, a divisão vem antes da soma: 8 + 80 / 4 = 8 + 20 = 28.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'JavaScript: Funções, Variáveis e Decisões — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('20', 1),
    ('28', 2),
    ('8', 3),
    ('88', 4),
    ('22', 5),
    ('2', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', '8', 1),
  ('s2', '22', 2),
  ('s3', '28', 3)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q11 | multiple_choice | difícil | Encadeamento com else if | Exercícios 2 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma função classifica o peso com: if (peso <= 13.5) { "Abaixo do peso" } else if (peso == 18.3) { "Peso perfeito" } else if (peso <= 21.2) { "Peso na média" } else { "Acima do peso" }. Se o teste peso <= 21.2 fosse escrito antes do teste peso == 18.3, qual seria o resultado para peso = 18.3?', 'As condições são testadas em ordem e só o primeiro bloco verdadeiro executa: 18.3 <= 21.2 seria verdadeiro antes de o teste de igualdade ser alcançado.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'JavaScript: Funções, Variáveis e Decisões — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('"Peso perfeito", pois o == tem prioridade sobre o <=.', false, 1),
  ('"Abaixo do peso", pois 18.3 entraria no primeiro if.', false, 2),
  ('"Acima do peso", pois nenhuma condição seria verdadeira.', false, 3),
  ('"Peso na média", pois 18.3 <= 21.2 seria testado antes.', true, 4),
  ('"Peso perfeito" e "Peso na média", um após o outro.', false, 5)
) AS o(text, is_correct, order_index);

-- Q12 | single_choice | super difícil | Encadeamento com else if | Exercícios 3 | b1: 96, b2: "Atenção", b3: "Multa grave"
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Um radar usa: if (velocidade <= limite) { "Boa direção" } else if (velocidade <= (limite + limite * 20 / 100)) { "Atenção" } else { "Multa grave" }. Com limite = 80, a expressão limite + limite * 20 / 100 vale {{b1}}. Para velocidade = 96, o resultado é {{b2}}; para velocidade = 97, é {{b3}}.', '80 * 20 / 100 = 16, então o teto é 96; como o teste usa <=, 96 ainda é Atenção e 97 já cai no else.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'JavaScript: Funções, Variáveis e Decisões — Exercícios 3: Desafio'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', '100', false, 1), ('b1', '96', true, 2), ('b1', '20', false, 3),
  ('b2', '"Boa direção"', false, 1), ('b2', '"Multa grave"', false, 2), ('b2', '"Atenção"', true, 3),
  ('b3', '"Multa grave"', true, 1), ('b3', '"Atenção"', false, 2), ('b3', '"Boa direção"', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q13 | multiple_answer | difícil | Decisão com if e else | Exercícios 2 | corretas: A, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma função de finanças usa três if separados: if (saldo == 0) { "Conta zerada" } if (saldo < 0) { "Está devendo!" } if (saldo > 0) { "Saldo positivo!" }. Assinale todas as corretas.', 'Sem else, cada if é testado de forma independente; como as três condições são excludentes, só uma mensagem aparece para cada saldo.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'JavaScript: Funções, Variáveis e Decisões — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Os três if são sempre testados, um após o outro.', true, 1),
  ('Depois de um if verdadeiro, os seguintes são pulados.', false, 2),
  ('Para saldo = 0, o resultado é "Está devendo!".', false, 3),
  ('Para saldo = -50, o resultado é "Está devendo!".', true, 4),
  ('Para saldo = 10, nenhuma mensagem é exibida.', false, 5)
) AS o(text, is_correct, order_index);

-- Q14 | multiple_choice | super difícil | Texto: concatenação e interpolação | Exercícios 3 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma função de metas monta a variável mensagem assim: if (economia >= meta) { mensagem = `Parabéns, meta alcançada!`; } if (economia > meta) { mensagem += ` Meta ultrapassada em ${economia - meta}`; } if (economia < meta) { mensagem = `Falta ${meta - economia}`; }. Para meta = 500 e economia = 650, qual é o valor final de mensagem?', 'Os dois primeiros if são verdadeiros: o primeiro atribui a mensagem com = e o segundo acrescenta com +=, calculando 650 - 500 = 150.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'JavaScript: Funções, Variáveis e Decisões — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Parabéns, meta alcançada! Meta ultrapassada em 150', true, 1),
  ('Meta ultrapassada em 150', false, 2),
  ('Parabéns, meta alcançada!', false, 3),
  ('Parabéns, meta alcançada! Falta 150', false, 4),
  ('Parabéns, meta alcançada! Meta ultrapassada em -150', false, 5)
) AS o(text, is_correct, order_index);

-- Q15 | drag_and_drop | super difícil | Variáveis locais e globais | Exercícios 3 | s1: latasNoAno, s2: latasPorDia, s3: gera um erro, s4: nunca é exibido
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Uma função de consumo de refrigerante contém: let latasNoAno = Number(input_latas.value) * 365; if (latasPorDia > 500) { alert(`Cuidado com a diabetes!`); }. A variável {{s1}} foi declarada com let e pode ser usada; já {{s2}} nunca foi declarada. Por isso, ao chegar no if, a função {{s3}} e o alerta {{s4}}.', 'Só latasNoAno foi declarada; usar latasPorDia, que não existe, gera erro e interrompe a função antes do alert.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'JavaScript: Funções, Variáveis e Decisões — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('nunca é exibido', 1),
    ('latasPorDia', 2),
    ('considera o valor 0', 3),
    ('gera um erro', 4),
    ('latasNoAno', 5),
    ('sempre é exibido', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'latasNoAno', 1),
  ('s2', 'latasPorDia', 2),
  ('s3', 'gera um erro', 3),
  ('s4', 'nunca é exibido', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- 8. Conferência: aborta se alguma questão ficou fora das listas ou alguma lista ficou vazia
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM questions q
    JOIN topics t ON t.id = q.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Algoritmos' AND t.number = 2
      AND NOT EXISTS (
        SELECT 1 FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
        WHERE qq.question_id = q.id AND z.kind = 'exercise'
      )
  ) THEN
    RAISE EXCEPTION 'Há questão da aula 2 de Algoritmos fora das listas de exercícios';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM quizzes z
    JOIN topics t ON t.id = z.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Algoritmos' AND t.number = 2 AND z.kind = 'exercise'
      AND NOT EXISTS (SELECT 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  ) THEN
    RAISE EXCEPTION 'Há lista de exercícios da aula 2 de Algoritmos sem questões';
  END IF;
END $$;

COMMIT;
