-- Algoritmos - Aulas 1 e 2: simulado de nível médio de Algoritmos, montado com questões que JÁ
-- estão no banco (cadastradas por ALG-questoes.sql). Nenhuma questão é criada: o script só cria o
-- simulado e o liga às questões pela tabela quiz_questions.
-- Cada questão é localizada pelo início do seu enunciado, dentro da disciplina Algoritmos, então
-- o script não depende do título nem da ordem das listas de exercícios.
-- Rode ALG-questoes.sql antes deste.
-- Distribuição das 20 questões (10 de cada aula): 6 fáceis, 4 médias, 8 difíceis e 2 super
-- difíceis; 8 multiple_choice, 4 multiple_answer, 3 single_choice e 5 drag_and_drop.

BEGIN;

-- 1. Trava: aborta se o simulado já existir
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM quizzes WHERE title = 'Algoritmos - Aulas 1 e 2') THEN
    RAISE EXCEPTION 'O simulado "Algoritmos - Aulas 1 e 2" já existe';
  END IF;
END $$;

-- 2. Questões escolhidas: (posição no simulado, início do enunciado)
CREATE TEMP TABLE alg_simulado_questoes ON COMMIT DROP AS
SELECT v.order_index, v.statement_start
FROM (VALUES
  (1, 'Um diagrama de atividades deve calcular e mostrar a média de duas notas'), -- aula 1 Q1 | multiple_choice | fácil | Ações: receber, calcular e exibir
  (2, 'Em um diagrama de atividades, a ação {{s1}} guarda em uma variável'), -- aula 1 Q15 | drag_and_drop | fácil | Ações: receber, calcular e exibir
  (3, 'Um diagrama calcula media = (nota1 + nota2) / 2'), -- aula 1 Q2 | drag_and_drop | média | Decisões e condições
  (4, 'Um diagrama calcula a média diária do salário líquido de um estagiário'), -- aula 1 Q4 | multiple_answer | fácil | Ações: receber, calcular e exibir
  (5, 'Em uma decisão de um diagrama de atividades, como devem ser as condições'), -- aula 1 Q8 | multiple_choice | média | Decisões e condições
  (6, 'Um aplicativo de saúde classifica as horas dormidas por noite'), -- aula 1 Q3 | multiple_choice | difícil | Faixas de valores e operadores lógicos
  (7, 'Um diagrama recebe sexo e idade do usuário'), -- aula 1 Q5 | single_choice | difícil | Decisões aninhadas
  (8, 'Um sistema de notas só aceita valores de 0 a 10'), -- aula 1 Q9 | multiple_answer | difícil | Faixas de valores e operadores lógicos
  (9, 'Um laço começa com contador = 0, repete enquanto contador < numFilho'), -- aula 1 Q12 | multiple_choice | difícil | Repetição com contador e acumulador
  (10, 'Uma escola aprova o aluno com média a partir de 6 e frequência a partir de 70'), -- aula 1 Q11 | drag_and_drop | super difícil | Faixas de valores e operadores lógicos
  (11, 'O script de um semáforo contém apenas'), -- aula 2 Q1 | multiple_choice | fácil | Funções: declarar e chamar
  (12, 'Uma função calcula quantos anos faltam para a aposentadoria aos 70 anos'), -- aula 2 Q5 | drag_and_drop | fácil | Number() e operadores aritméticos
  (13, 'Um contador é escrito assim: let contador = 0;'), -- aula 2 Q9 | multiple_answer | fácil | Variáveis locais e globais
  (14, 'Em um script de torcida, let nome = ''Santos'';'), -- aula 2 Q3 | multiple_choice | média | Texto: concatenação e interpolação
  (15, 'A função de entrada de uma festa executa'), -- aula 2 Q6 | multiple_choice | média | Decisão com if e else
  (16, 'O controle de uma caldeira começa com let horasRestantes = 1000;'), -- aula 2 Q2 | drag_and_drop | difícil | Variáveis locais e globais
  (17, 'Uma função de divisão recebe n1 = 7 e n2 = 2'), -- aula 2 Q7 | single_choice | difícil | Number() e operadores aritméticos
  (18, 'Uma função classifica o peso com: if (peso <= 13.5)'), -- aula 2 Q11 | multiple_choice | difícil | Encadeamento com else if
  (19, 'Uma função de finanças usa três if separados'), -- aula 2 Q13 | multiple_answer | difícil | Decisão com if e else
  (20, 'Um radar usa: if (velocidade <= limite)') -- aula 2 Q12 | single_choice | super difícil | Encadeamento com else if
) AS v(order_index, statement_start);

-- 3. Conferência: aborta, dizendo quais, se alguma questão não foi encontrada ou está duplicada
DO $$
DECLARE
  problems text;
BEGIN
  IF NOT EXISTS (SELECT 1 FROM subjects WHERE name = 'Algoritmos') THEN
    RAISE EXCEPTION 'A disciplina "Algoritmos" não existe';
  END IF;

  SELECT string_agg(
    format('posição %s (%s questão(ões) com o enunciado "%s...")', c.order_index, c.found, c.statement_start),
    E'\n  ' ORDER BY c.order_index
  )
  INTO problems
  FROM (
    SELECT v.order_index, v.statement_start, count(q.id) AS found
    FROM alg_simulado_questoes v
    LEFT JOIN (
      SELECT q.id, COALESCE(q.prompt, q.template) AS statement
      FROM questions q
      JOIN topics t ON t.id = q.topic_id
      JOIN subjects s ON s.id = t.subject_id
      WHERE s.name = 'Algoritmos'
    ) q ON starts_with(q.statement, v.statement_start)
    GROUP BY v.order_index, v.statement_start
  ) c
  WHERE c.found <> 1;

  IF problems IS NOT NULL THEN
    RAISE EXCEPTION E'O simulado não foi criado; cada questão deveria existir uma única vez em Algoritmos:\n  %', problems;
  END IF;
END $$;

-- 4. Simulado
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT 'Algoritmos - Aulas 1 e 2', 'exam', s.id, NULL, 40, 'medium'::difficulty_level
FROM subjects s
WHERE s.name = 'Algoritmos';

-- 5. Questões do simulado
INSERT INTO quiz_questions (quiz_id, question_id, order_index)
SELECT z.id, q.id, v.order_index
FROM alg_simulado_questoes v
JOIN questions q ON starts_with(COALESCE(q.prompt, q.template), v.statement_start)
JOIN topics t ON t.id = q.topic_id
JOIN subjects s ON s.id = t.subject_id AND s.name = 'Algoritmos'
JOIN quizzes z ON z.kind = 'exam' AND z.title = 'Algoritmos - Aulas 1 e 2';

COMMIT;
