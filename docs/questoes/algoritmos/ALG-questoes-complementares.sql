-- Algoritmos: aulas 1, 2 — questões complementares. Acrescenta 15 questões a cada aula, nas
-- listas de exercícios que já existem (5 em cada lista). Rode ALG-questoes.sql antes deste.
-- Cada lista é localizada pela aula e pelo nível (easy, medium, hard), não pelo título.
-- Gerado a partir de temp/prompt-questoes.txt e das pastas
-- "Aula 01 - Diagrama de atividades" e "Aula 02 - HTML e Javascript".
-- Uma única transação: se qualquer comando falhar, nada é gravado.
-- Não rode duas vezes: as questões seriam duplicadas.

BEGIN;

-- =====================================================================
-- AULA 1 — Diagrama de Atividades (pasta Aula 01 - Diagrama de atividades)
-- =====================================================================

-- 1. Trava: aborta se a aula não existir ou já existir com outro nome
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM topics t JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Algoritmos' AND t.number = 1 AND t.name = 'Diagrama de Atividades'
  ) THEN
    RAISE EXCEPTION 'A aula 1 de Algoritmos não existe ou já está cadastrada com outro nome';
  END IF;
END $$;

-- 2. Questões

-- Q1 | multiple_choice | fácil | Ações: receber, calcular e exibir | Exercícios 1 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um diagrama recebe a largura e a altura de um terreno e calcula area = largura * altura. Para largura = 10 e altura = 25, qual valor é guardado em area?', 'A ação de calcular multiplica os dois valores recebidos: 10 * 25 = 250.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'easy'
  JOIN topics t ON t.id = z.topic_id AND t.number = 1
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('35', false, 1),
  ('70', false, 2),
  ('125', false, 3),
  ('250', true, 4),
  ('2500', false, 5)
) AS o(text, is_correct, order_index);

-- Q2 | drag_and_drop | difícil | Faixas de valores e operadores lógicos | Exercícios 2 | s1: "#ragazzonosabado", s2: "#cinemanamorada", s3: "#novogame"
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Um diagrama calcula a média diária que sobra do salário e escolhe uma mensagem: se media >= 15 && media <= 20, exibe "#ragazzonosabado"; se media > 20 && media < 25, exibe "#cinemanamorada"; se media >= 25 && media <= 30, exibe "#novogame". Abaixo de 15 a mensagem é "#controletotal" e acima de 30 é "#tobonito". Para media = 15, o diagrama exibe {{s1}}; para media = 20.5, exibe {{s2}}; para media = 25, exibe {{s3}}.', '15 entra em media >= 15 && media <= 20; 20.5 fica entre 20 e 25; e 25 entra em media >= 25 && media <= 30, pois o >= inclui o limite.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'medium'
  JOIN topics t ON t.id = z.topic_id AND t.number = 1
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('"#novogame"', 1),
    ('"#controletotal"', 2),
    ('"#ragazzonosabado"', 3),
    ('"#tobonito"', 4),
    ('"#cinemanamorada"', 5)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', '"#ragazzonosabado"', 1),
  ('s2', '"#cinemanamorada"', 2),
  ('s3', '"#novogame"', 3)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q3 | multiple_choice | média | Decisões e condições | Exercícios 1 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um diagrama exibe uma mensagem conforme a quantidade de filhos, que nunca é negativa. A decisão tem cinco caminhos: filhos == 0, filhos == 1, filhos == 2, filhos == 3 e um último caminho para todos os demais valores. Qual condição o último caminho deve ter?', 'Os quatro primeiros caminhos cobrem de 0 a 3; para cobrir o restante sem sobrepor nenhum deles, o último caminho usa filhos > 3.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'easy'
  JOIN topics t ON t.id = z.topic_id AND t.number = 1
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('filhos >= 3', false, 1),
  ('filhos > 3', true, 2),
  ('filhos != 3', false, 3),
  ('filhos < 3', false, 4),
  ('filhos == 4', false, 5)
) AS o(text, is_correct, order_index);

-- Q4 | multiple_answer | super difícil | Decisões aninhadas | Exercícios 3 | corretas: A, C, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Um diagrama recebe sexo e idade. A primeira decisão separa sexo == "homem" de sexo == "mulher"; dentro de cada caminho, outra decisão separa idade >= 18 de idade < 18, e cada um dos quatro caminhos exibe uma mensagem diferente. Assinale todas as corretas.', 'Toda pessoa passa pela decisão do sexo e depois por uma das duas decisões de idade; testar a idade primeiro levaria às mesmas quatro combinações.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'hard'
  JOIN topics t ON t.id = z.topic_id AND t.number = 1
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Cada pessoa passa por exatamente duas decisões até a mensagem.', true, 1),
  ('A idade é testada antes do sexo em todos os quatro caminhos.', false, 2),
  ('Trocar a ordem das decisões mantém as quatro combinações.', true, 3),
  ('A decisão da idade aparece duas vezes, uma em cada caminho.', true, 4),
  ('Uma mulher de 18 anos segue o caminho da condição idade < 18.', false, 5)
) AS o(text, is_correct, order_index);

-- Q5 | drag_and_drop | fácil | Decisões e condições | Exercícios 1 | s1: "#terrenopequeno", s2: "#terrenomedio", s3: "#terrenogrande"
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Um diagrama classifica um terreno pela área: se area < 100, exibe "#terrenopequeno"; se area >= 100 && area <= 250, exibe "#terrenomedio"; se area > 250, exibe "#terrenogrande". Para area = 99, o diagrama exibe {{s1}}; para area = 250, exibe {{s2}}; para area = 251, exibe {{s3}}.', '99 é menor que 100; 250 ainda atende a area <= 250; e 251 só atende a area > 250.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'easy'
  JOIN topics t ON t.id = z.topic_id AND t.number = 1
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('"#terrenogrande"', 1),
    ('"#semterreno"', 2),
    ('"#terrenopequeno"', 3),
    ('"#terrenoenorme"', 4),
    ('"#terrenomedio"', 5)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', '"#terrenopequeno"', 1),
  ('s2', '"#terrenomedio"', 2),
  ('s3', '"#terrenogrande"', 3)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q6 | multiple_choice | difícil | Faixas de valores e operadores lógicos | Exercícios 2 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um diagrama trata de forma especial quem mora na região Sul, usando a condição uf == "PR" || uf == "SC" || uf == "RS". Qual condição deve ficar no outro caminho, o de quem não mora no Sul?', 'O caminho oposto é a negação da condição inteira: o ! na frente dos parênteses inverte o resultado dos três testes ligados por ||.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'medium'
  JOIN topics t ON t.id = z.topic_id AND t.number = 1
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('uf != "PR" || uf != "SC" || uf != "RS"', false, 1),
  ('uf == "PR" && uf == "SC" && uf == "RS"', false, 2),
  ('!(uf == "PR" && uf == "SC" && uf == "RS")', false, 3),
  ('uf != "PR" || uf == "SC" || uf == "RS"', false, 4),
  ('!(uf == "PR" || uf == "SC" || uf == "RS")', true, 5)
) AS o(text, is_correct, order_index);

-- Q7 | single_choice | difícil | Decisões aninhadas | Exercícios 2 | b1: verdadeira, b2: falsa, b3: falsa
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Para exibir três números do maior para o menor, um diagrama usa decisões aninhadas. Com numA = 8, numB = 3 e numC = 5, a primeira condição, numA >= numB, é {{b1}}. Em seguida, a condição numB >= numC é {{b2}} e, por fim, a condição numC >= numA é {{b3}}. Por isso a saída é numA, numC, numB.', '8 >= 3 é verdadeiro, 3 >= 5 é falso e 5 >= 8 é falso: numA é o maior, numC fica no meio e numB é o menor.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'medium'
  JOIN topics t ON t.id = z.topic_id AND t.number = 1
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'verdadeira', true, 1), ('b1', 'falsa', false, 2), ('b1', 'indefinida', false, 3),
  ('b2', 'verdadeira', false, 1), ('b2', 'falsa', true, 2), ('b2', 'indefinida', false, 3),
  ('b3', 'verdadeira', false, 1), ('b3', 'falsa', true, 2), ('b3', 'indefinida', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q8 | multiple_answer | fácil | Ações: receber, calcular e exibir | Exercícios 1 | corretas: A, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Um diagrama de folha de pagamento recebe salBruto e calcula descontoInss = salBruto * 0.10. Assinale todas as corretas.', 'Multiplicar por 0.10 calcula 10% do salário, e o cálculo só pode usar salBruto depois que ele foi recebido.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'easy'
  JOIN topics t ON t.id = z.topic_id AND t.number = 1
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Para salBruto = 3000, descontoInss vale 300.', true, 1),
  ('Para salBruto = 3000, descontoInss vale 30.', false, 2),
  ('O desconto pode ser calculado antes de receber salBruto.', false, 3),
  ('salBruto precisa ser recebido antes de calcular o desconto.', true, 4)
) AS o(text, is_correct, order_index);

-- Q9 | multiple_choice | difícil | Repetição com contador e acumulador | Exercícios 2 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um diagrama multiplica dois números usando apenas somas: começa com resultado = 0 e repete a ação resultado = resultado + fator1 até completar fator2 repetições. Para fator1 = 6 e fator2 = 4, quais valores resultado assume ao longo das repetições?', 'O acumulador soma fator1 (6) em cada uma das 4 repetições: 6, 12, 18 e 24.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'medium'
  JOIN topics t ON t.id = z.topic_id AND t.number = 1
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('6, 12, 18 e 24', true, 1),
  ('4, 8, 12, 16, 20 e 24', false, 2),
  ('6, 12 e 18', false, 3),
  ('0, 6, 12 e 18', false, 4),
  ('10, 16, 22 e 28', false, 5)
) AS o(text, is_correct, order_index);

-- Q10 | drag_and_drop | super difícil | Repetição com contador e acumulador | Exercícios 3 | s1: 25, s2: 1, s3: 45, s4: 2
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Uma empresa paga bolsa por filho: 25 se idade >= 0 && idade <= 3, 20 se idade > 3 && idade <= 16 e 15 se idade > 16. O diagrama começa com valorBolsa = 0 e contador = 0 e repete enquanto contador < numFilho. Para numFilho = 2, com filhos de 1 e 16 anos: ao fim da primeira volta, valorBolsa vale {{s1}} e contador vale {{s2}}; ao fim da segunda volta, valorBolsa vale {{s3}} e contador vale {{s4}}, e o laço termina.', 'O filho de 1 ano soma 25 e o de 16 anos soma 20 (16 ainda atende a idade <= 16); o contador sobe 1 por volta e o laço para quando contador chega a 2.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'hard'
  JOIN topics t ON t.id = z.topic_id AND t.number = 1
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('40', 1),
    ('1', 2),
    ('45', 3),
    ('0', 4),
    ('25', 5),
    ('2', 6),
    ('20', 7)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', '25', 1),
  ('s2', '1', 2),
  ('s3', '45', 3),
  ('s4', '2', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q11 | multiple_choice | super difícil | Repetição com contador e acumulador | Exercícios 3 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um diagrama divide dois números usando apenas subtrações: começa com resultado = 0 e resto = dividendo; enquanto resto >= divisor, faz resto = resto - divisor e resultado = resultado + 1. Para dividendo = 17 e divisor = 5, quais são os valores finais?', 'O resto passa por 12, 7 e 2 em três voltas; como 2 >= 5 é falso, o laço termina com resultado = 3 e resto = 2.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'hard'
  JOIN topics t ON t.id = z.topic_id AND t.number = 1
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('resultado = 2 e resto = 7', false, 1),
  ('resultado = 4 e resto = -3', false, 2),
  ('resultado = 3 e resto = 2', true, 3),
  ('resultado = 3 e resto = 5', false, 4),
  ('resultado = 5 e resto = 17', false, 5)
) AS o(text, is_correct, order_index);

-- Q12 | drag_and_drop | média | Repetição com contador e acumulador | Exercícios 1 | s1: 90, s2: 50, s3: 0
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Em um jogo, o personagem começa com energia = 100. A cada golpe sofrido, o diagrama faz energia = energia - 10 e, enquanto energia > 5, volta a receber o próximo golpe. Depois do primeiro golpe, energia vale {{s1}}; depois do quinto, vale {{s2}}; e o laço termina quando energia chega a {{s3}}.', 'Cada volta subtrai 10: 90 após o primeiro golpe e 50 após o quinto; o laço só para quando energia > 5 é falso, o que acontece em 0.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'easy'
  JOIN topics t ON t.id = z.topic_id AND t.number = 1
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('5', 1),
    ('90', 2),
    ('10', 3),
    ('0', 4),
    ('95', 5),
    ('50', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', '90', 1),
  ('s2', '50', 2),
  ('s3', '0', 3)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q13 | multiple_answer | difícil | Repetição com contador e acumulador | Exercícios 2 | corretas: B, C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'O diagrama de um caixa começa com valorCompra = 0. A cada produto informado, soma 5 para "abacaxi", 10 para "morango" e 15 para "tomate"; depois pergunta se há outro produto e repete enquanto resp == "Sim". Assinale todas as corretas.', 'O acumulador nasce antes do laço e não é zerado nas voltas: 5 + 15 + 15 = 35; o laço continua enquanto a resposta for Sim.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'medium'
  JOIN topics t ON t.id = z.topic_id AND t.number = 1
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('valorCompra deve ser zerado no início de cada volta do laço.', false, 1),
  ('Para abacaxi, tomate e tomate, o valor final da compra é 35.', true, 2),
  ('valorCompra precisa ser declarado antes de o laço começar.', true, 3),
  ('Para morango e morango, o valor final da compra é 10.', false, 4),
  ('O laço termina assim que resp recebe o valor "Sim".', false, 5)
) AS o(text, is_correct, order_index);

-- Q14 | single_choice | super difícil | Faixas de valores e operadores lógicos | Exercícios 3 | b1: 6, b2: falsa, b3: "Infelizmente, reprovado"
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Uma escola calcula media = (nota1 + nota2) / 2 e exibe "Parabéns, aprovado" se media >= 6 && frequencia >= 70; caso contrário, exibe "Infelizmente, reprovado". Para nota1 = 7, nota2 = 5 e frequencia = 65, media vale {{b1}}, a condição de aprovação é {{b2}} e a mensagem exibida é {{b3}}.', 'A média é (7 + 5) / 2 = 6, mas 65 >= 70 é falso; como o && exige as duas partes verdadeiras, o aluno é reprovado.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'hard'
  JOIN topics t ON t.id = z.topic_id AND t.number = 1
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', '5.5', false, 1), ('b1', '6', true, 2), ('b1', '6.5', false, 3),
  ('b2', 'verdadeira', false, 1), ('b2', 'falsa', true, 2), ('b2', 'indefinida', false, 3),
  ('b3', '"Parabéns, aprovado"', false, 1), ('b3', '"Infelizmente, reprovado"', true, 2), ('b3', '"Nota inválida"', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q15 | multiple_choice | super difícil | Decisões e condições | Exercícios 3 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um diagrama classifica as horas de sono com quatro caminhos: horas < 5, horas >= 5 && horas <= 7, horas >= 7 && horas <= 9 e horas > 9. Qual é o problema dessas condições?', 'As condições de uma decisão devem ser excludentes, mas o valor 7 atende ao segundo e ao terceiro caminho ao mesmo tempo.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'hard'
  JOIN topics t ON t.id = z.topic_id AND t.number = 1
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('O valor 5 não atende a nenhuma das quatro condições.', false, 1),
  ('O valor 7 atende a duas condições ao mesmo tempo.', true, 2),
  ('O valor 9 não atende a nenhuma das quatro condições.', false, 3),
  ('O valor 8 atende a duas condições ao mesmo tempo.', false, 4),
  ('O valor 4 atende a duas condições ao mesmo tempo.', false, 5)
) AS o(text, is_correct, order_index);

-- 3. Conferência: aborta se alguma questão ficou fora das listas ou alguma lista ficou vazia
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

-- 1. Trava: aborta se a aula não existir ou já existir com outro nome
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM topics t JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Algoritmos' AND t.number = 2 AND t.name = 'JavaScript: Funções, Variáveis e Decisões'
  ) THEN
    RAISE EXCEPTION 'A aula 2 de Algoritmos não existe ou já está cadastrada com outro nome';
  END IF;
END $$;

-- 2. Questões

-- Q1 | multiple_choice | fácil | Funções: declarar e chamar | Exercícios 1 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um script declara: function ondeMoro() { alert("Seu logradouro é " + rua); alert("O número do seu logradouro é " + numero); }. O que acontece a cada chamada de ondeMoro()?', 'A função executa o bloco inteiro, do início ao fim: os dois alert aparecem, um após o outro, na ordem em que foram escritos.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'easy'
  JOIN topics t ON t.id = z.topic_id AND t.number = 2
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Aparece uma caixa, com os dois textos juntos.', false, 1),
  ('Aparecem duas caixas, na ordem do código.', true, 2),
  ('Aparecem duas caixas, a segunda antes da primeira.', false, 3),
  ('Aparece uma caixa, só com o texto do segundo alert.', false, 4),
  ('Não aparece nada, pois alert não roda em função.', false, 5)
) AS o(text, is_correct, order_index);

-- Q2 | drag_and_drop | difícil | Number() e operadores aritméticos | Exercícios 2 | s1: 22, s2: 33, s3: 82
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Cada episódio de uma série dura 22 minutos, e a função calcula let horasAssistidas = (qtdAssistida * 22) / 60;. Para qtdAssistida = 60, horasAssistidas vale {{s1}}; para qtdAssistida = 90, vale {{s2}}. A mensagem "Uau, você realmente gosta dessa série!" exige horasAssistidas > 30, o que só acontece a partir de {{s3}} episódios.', '60 * 22 / 60 = 22 e 90 * 22 / 60 = 33; para passar de 30 horas são necessários mais de 1800 minutos, ou seja, 82 episódios (81 dão 29.7 horas).'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'medium'
  JOIN topics t ON t.id = z.topic_id AND t.number = 2
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('81', 1),
    ('33', 2),
    ('1320', 3),
    ('22', 4),
    ('30', 5),
    ('82', 6),
    ('60', 7)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', '22', 1),
  ('s2', '33', 2),
  ('s3', '82', 3)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q3 | multiple_choice | média | Number() e operadores aritméticos | Exercícios 1 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma função calcula a média final com let media = notaContinuada * 0.4 + notaSemestral * 0.6;. Para notaContinuada = 5 e notaSemestral = 10, quanto vale media?', 'As multiplicações são feitas antes da soma: 5 * 0.4 = 2 e 10 * 0.6 = 6, e 2 + 6 = 8.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'easy'
  JOIN topics t ON t.id = z.topic_id AND t.number = 2
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('7.5', false, 1),
  ('6', false, 2),
  ('15', false, 3),
  ('9', false, 4),
  ('8', true, 5)
) AS o(text, is_correct, order_index);

-- Q4 | multiple_answer | super difícil | Encadeamento com else if | Exercícios 3 | corretas: A, C, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma função de torcida usa: if (time == "Corinthians") { ... } else if (time == "Palmeiras") { ... } else if (time == "Santos") { ... } else if (time == "São Paulo") { ... }, sem else final, e cada bloco define uma mensagem diferente. Assinale todas as corretas.', 'Sem else final, um time fora da lista não entra em nenhum bloco; e, como só o primeiro bloco verdadeiro executa, os testes seguintes nem são feitos.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'hard'
  JOIN topics t ON t.id = z.topic_id AND t.number = 2
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Para time = "Flamengo", nenhuma mensagem é definida.', true, 1),
  ('Para time = "Santos", os dois primeiros testes são pulados.', false, 2),
  ('Para time = "Palmeiras", o teste de "Santos" não é feito.', true, 3),
  ('Sem o else final, a cadeia gera erro para outros times.', false, 4),
  ('Um else final cobriria todos os times fora da lista.', true, 5)
) AS o(text, is_correct, order_index);

-- Q5 | drag_and_drop | fácil | Decisão com if e else | Exercícios 1 | s1: Lia, vai jogar PlayStation!, s2: Lia, vamos tirar a CNH?
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Uma autoescola usa: if (idade >= 18) { mensagem = `${nome}, vamos tirar a CNH?`; } else { mensagem = `${nome}, vai jogar PlayStation!`; }. Com nome = ''Lia'', para idade = 17 a mensagem é {{s1}} e para idade = 18 a mensagem é {{s2}}.', '17 >= 18 é falso, então vale o else; 18 >= 18 é verdadeiro, então vale o bloco do if. A interpolação troca ${nome} por Lia.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'easy'
  JOIN topics t ON t.id = z.topic_id AND t.number = 2
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('nome, vai jogar PlayStation!', 1),
    ('Lia, vamos tirar a CNH?', 2),
    ('${nome}, vamos tirar a CNH?', 3),
    ('Lia, vai jogar PlayStation!', 4)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'Lia, vai jogar PlayStation!', 1),
  ('s2', 'Lia, vamos tirar a CNH?', 2)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q6 | multiple_choice | difícil | Variáveis locais e globais | Exercícios 2 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma conta bancária é escrita com let saldo = 0; fora das funções. A função depositar() faz saldo += valor; e a função retirar() faz saldo -= valor;, em que valor é o número digitado pelo usuário. Ele deposita 200, retira 50 e deposita 30. Quanto vale saldo ao final?', 'As duas funções alteram a mesma variável global, que mantém o valor entre as chamadas: 0 + 200 - 50 + 30 = 180.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'medium'
  JOIN topics t ON t.id = z.topic_id AND t.number = 2
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('180, pois as duas funções alteram o mesmo saldo global.', true, 1),
  ('30, pois saldo volta a valer 0 no início de cada chamada.', false, 2),
  ('230, pois retirar altera apenas uma cópia local do saldo.', false, 3),
  ('280, pois o operador -= também soma o valor ao saldo.', false, 4),
  ('150, pois só as duas primeiras chamadas são guardadas.', false, 5)
) AS o(text, is_correct, order_index);

-- Q7 | single_choice | difícil | Decisão com if e else | Exercícios 2 | b1: 570, b2: falsa, b3: 70
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'O controle de um elevador calcula let peso = 90 * qtdHomens + 70 * qtdMulheres; e depois usa if (peso <= 500) { ... } else { excesso = peso - 500; }. Para qtdHomens = 4 e qtdMulheres = 3, peso vale {{b1}}, a condição peso <= 500 é {{b2}} e excesso vale {{b3}}.', '90 * 4 + 70 * 3 = 360 + 210 = 570; como 570 <= 500 é falso, executa o else, que calcula 570 - 500 = 70.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'medium'
  JOIN topics t ON t.id = z.topic_id AND t.number = 2
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', '480', false, 1), ('b1', '570', true, 2), ('b1', '640', false, 3),
  ('b2', 'verdadeira', false, 1), ('b2', 'falsa', true, 2), ('b2', 'indefinida', false, 3),
  ('b3', '70', true, 1), ('b3', '500', false, 2), ('b3', '570', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q8 | multiple_answer | fácil | Number() e operadores aritméticos | Exercícios 1 | corretas: A, C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma função verifica um número com: if ((num % 2) == 0) { "Esse número é PAR" } else { "Esse número é ímpar" }. Assinale todas as corretas.', 'O operador % devolve o resto da divisão por 2: 0 para os pares (como 10 e 0) e 1 para os ímpares (como 7).'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'easy'
  JOIN topics t ON t.id = z.topic_id AND t.number = 2
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Para num = 10, a expressão num % 2 resulta em 0.', true, 1),
  ('Para num = 7, a expressão num % 2 resulta em 3.', false, 2),
  ('Para num = 7, o resultado é "Esse número é ímpar".', true, 3),
  ('Para num = 0, o resultado é "Esse número é ímpar".', false, 4)
) AS o(text, is_correct, order_index);

-- Q9 | multiple_choice | difícil | Decisão com if e else | Exercícios 2 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma função divide a conta da pizza: let calculo = valor / amigos; let mensagem = `Cada amigo vai pagar R$${calculo}`; if (calculo > 20) { mensagem += ` Deu ruim! Pizza muito cara!`; }. Para valor = 80 e amigos = 4, qual é o valor final de mensagem?', '80 / 4 = 20 e a condição 20 > 20 é falsa, então o trecho do if não é acrescentado à mensagem.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'medium'
  JOIN topics t ON t.id = z.topic_id AND t.number = 2
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Cada amigo vai pagar R$20 Deu ruim! Pizza muito cara!', false, 1),
  ('Deu ruim! Pizza muito cara!', false, 2),
  ('Cada amigo vai pagar R$${calculo}', false, 3),
  ('Cada amigo vai pagar R$20', true, 4),
  ('Cada amigo vai pagar R$80 Deu ruim! Pizza muito cara!', false, 5)
) AS o(text, is_correct, order_index);

-- Q10 | drag_and_drop | super difícil | Number() e operadores aritméticos | Exercícios 3 | s1: 51, s2: 6, s3: 12, s4: 57
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'O valor digitado em um campo chega como texto. Com let texto = ''5'';, a instrução texto += 1; deixa texto valendo {{s1}}. Com let numero = Number(''5'');, a instrução numero += 1; deixa numero valendo {{s2}}. Da mesma forma, Number(''5'') + Number(''7'') resulta em {{s3}}, enquanto ''5'' + ''7'' resulta em {{s4}}.', 'Com texto, o + e o += juntam os valores (51 e 57); depois de Number(), eles somam (6 e 12).'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'hard'
  JOIN topics t ON t.id = z.topic_id AND t.number = 2
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('12', 1),
    ('5', 2),
    ('51', 3),
    ('13', 4),
    ('57', 5),
    ('6', 6),
    ('35', 7)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', '51', 1),
  ('s2', '6', 2),
  ('s3', '12', 3),
  ('s4', '57', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q11 | multiple_choice | super difícil | Variáveis locais e globais | Exercícios 3 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um script declara let caixa = 0; fora das funções e a função alternar() { if (caixa == 1) { caixa = 0; } else { caixa = 1; } }. Depois de três chamadas de alternar(), quanto vale caixa?', 'A variável global guarda o valor entre as chamadas e a função o inverte a cada vez: 0 vira 1, 1 vira 0 e 0 vira 1.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'hard'
  JOIN topics t ON t.id = z.topic_id AND t.number = 2
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('0, pois o if devolve a variável ao valor inicial.', false, 1),
  ('3, pois cada chamada soma 1 à variável global.', false, 2),
  ('1, pois o valor alterna entre 0 e 1 a cada chamada.', true, 3),
  ('0, pois a variável é recriada em cada chamada.', false, 4),
  ('2, pois o else executa em duas das três chamadas.', false, 5)
) AS o(text, is_correct, order_index);

-- Q12 | drag_and_drop | média | Texto: concatenação e interpolação | Exercícios 1 | s1: 6, s2: 3, s3: 18
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Em uma calculadora, let n1 = 6; let n2 = 3; e let resultado = n1 * n2;. A expressão `O produto entre ${n1} e ${n2} é ${resultado}` gera o texto: O produto entre {{s1}} e {{s2}} é {{s3}}.', 'Na interpolação, cada ${ } é trocado pelo valor da variável: n1 vale 6, n2 vale 3 e resultado vale 18.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'easy'
  JOIN topics t ON t.id = z.topic_id AND t.number = 2
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('resultado', 1),
    ('3', 2),
    ('9', 3),
    ('6', 4),
    ('n1', 5),
    ('18', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', '6', 1),
  ('s2', '3', 2),
  ('s3', '18', 3)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q13 | multiple_answer | difícil | Encadeamento com else if | Exercícios 2 | corretas: B, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma função de metas usa: if (guardado == meta) { "Parabéns, meta alcançada!" } else if (guardado > meta) { `Meta ultrapassada em ${guardado - meta}` } else { `Falta ${meta - guardado}` }. Assinale todas as corretas.', 'Só um bloco executa: com valores iguais vale o primeiro; com guardado maior, o segundo, que calcula 700 - 500 = 200; o else fica para quando guardado é menor.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'medium'
  JOIN topics t ON t.id = z.topic_id AND t.number = 2
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Para guardado = 500 e meta = 500, aparecem duas mensagens.', false, 1),
  ('Para guardado = 700 e meta = 500, a meta é ultrapassada em 200.', true, 2),
  ('Para guardado = 300 e meta = 500, o resultado é "Falta -200".', false, 3),
  ('O else só executa quando guardado é menor que meta.', true, 4),
  ('O teste guardado > meta é feito mesmo se guardado == meta.', false, 5)
) AS o(text, is_correct, order_index);

-- Q14 | single_choice | super difícil | Encadeamento com else if | Exercícios 3 | b1: 3, b2: "Com mais dois daria certo", b3: "Só faltou 1"
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Uma função analisa um número positivo com: if ((num % 5) == 0) { "É múltiplo de cinco" } else if ((num % 5) == 1) { "Sobrou um" } else if ((num % 5) == 2) { "O resto é dois" } else if ((num % 5) == 3) { "Com mais dois daria certo" } else { "Só faltou 1" }. Para num = 23, num % 5 resulta em {{b1}} e a mensagem é {{b2}}; para num = 19, a mensagem é {{b3}}.', '23 % 5 = 3, que cai no quarto teste; 19 % 5 = 4, que não atende a nenhum teste e cai no else.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'hard'
  JOIN topics t ON t.id = z.topic_id AND t.number = 2
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', '2', false, 1), ('b1', '3', true, 2), ('b1', '4', false, 3),
  ('b2', '"O resto é dois"', false, 1), ('b2', '"Sobrou um"', false, 2), ('b2', '"Com mais dois daria certo"', true, 3),
  ('b3', '"Só faltou 1"', true, 1), ('b3', '"Sobrou um"', false, 2), ('b3', '"É múltiplo de cinco"', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q15 | multiple_choice | super difícil | Texto: concatenação e interpolação | Exercícios 3 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Em uma calculadora, let n1 = 2; e let n2 = 3; guardam números. Quais textos resultam de ''Soma: '' + n1 + n2 e de ''Soma: '' + (n1 + n2), nessa ordem?', 'Sem parênteses, a expressão é lida da esquerda para a direita e o texto vai juntando os números (23); com parênteses, a soma 2 + 3 é feita antes.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Algoritmos' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.difficulty = 'hard'
  JOIN topics t ON t.id = z.topic_id AND t.number = 2
  JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Soma: 23 e Soma: 5', true, 1),
  ('Soma: 5 e Soma: 5', false, 2),
  ('Soma: 23 e Soma: 23', false, 3),
  ('Soma: 5 e Soma: 23', false, 4),
  ('Soma: 2 3 e Soma: 5', false, 5)
) AS o(text, is_correct, order_index);

-- 3. Conferência: aborta se alguma questão ficou fora das listas ou alguma lista ficou vazia
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
