-- Tecnologia da Informação: aulas 1, 2, 3, 4, 5, 6, 7, 8 — disciplina, assuntos, subassuntos,
-- pontos-chave, questões e listas de exercícios. Gerado a partir de temp/prompt-questoes.txt e dos
-- PDFs TI-Sprint 1-Aula 01.pdf a TI-Sprint 2-Aula 08.pdf.
-- Uma única transação: se qualquer comando falhar, nada é gravado.
-- Não rode duas vezes: as questões seriam duplicadas.

BEGIN;

-- =====================================================================
-- AULA 1 — Introdução à Tecnologia da Informação (TI-Sprint 1-Aula 01.pdf)
-- =====================================================================

-- 1. Disciplina
INSERT INTO subjects (name, short_label)
SELECT 'Tecnologia da Informação', 'TI'
WHERE NOT EXISTS (SELECT 1 FROM subjects WHERE name = 'Tecnologia da Informação');

-- 2. Assunto
INSERT INTO topics (subject_id, number, name, description)
SELECT s.id, 1, 'Introdução à Tecnologia da Informação', 'O que são tecnologia, informação e TI, como a IA entra no dia a dia e como uma proposta de projeto se apoia em contexto, objetivo e justificativa.'
FROM subjects s
WHERE s.name = 'Tecnologia da Informação'
ON CONFLICT DO NOTHING;

-- 3. Trava: aborta se a aula não existir ou já existir com outro nome
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM topics t JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 1 AND t.name = 'Introdução à Tecnologia da Informação'
  ) THEN
    RAISE EXCEPTION 'A aula 1 de Tecnologia da Informação não existe ou já está cadastrada com outro nome';
  END IF;
END $$;

-- 4. Subassuntos
INSERT INTO subtopics (topic_id, name, summary, order_index)
SELECT t.id, v.name, v.summary, v.order_index
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Tecnologia, informação e TI', 'Tecnologia é o uso de técnicas e métodos para criar coisas úteis, e informação é o conhecimento que resulta do processamento de dados. A TI une as duas com computadores e dispositivos digitais.', 1),
  ('Evolução da TI nas organizações', 'A TI é uma área funcional relativamente recente nas organizações. A cada década o foco mudou, da produtividade obtida com a automação do trabalho até a próxima onda.', 2),
  ('A era da Inteligência Artificial', 'IA é a capacidade de um sistema realizar tarefas que normalmente exigiriam inteligência humana. Ela aprende padrões a partir de muitos exemplos, pode errar e deve ser usada como ferramenta.', 3),
  ('TI nas empresas: processo e projeto', 'Nas empresas a TI sustenta os processos do dia a dia, como pedir um lanche. Mudar um processo de forma significativa, como implantar o totem de pedido, pede um projeto.', 4),
  ('Contexto, objetivo e justificativa', 'Toda proposta de projeto diz o que será feito e em que contexto, o que se pretende alcançar e por que vale a pena. São os três pilares da proposta de um projeto de TI.', 5)
) AS v(name, summary, order_index)
WHERE s.name = 'Tecnologia da Informação' AND t.number = 1
ON CONFLICT DO NOTHING;

-- 5. Pontos-chave
INSERT INTO subtopic_key_points (subtopic_id, text, order_index)
SELECT st.id, v.text, v.order_index
FROM subtopics st
JOIN topics t ON t.id = st.topic_id
JOIN subjects s ON s.id = t.subject_id
JOIN (VALUES
  ('Tecnologia, informação e TI', 'Tecnologia: uso de técnicas, habilidades, métodos e processos para criar coisas úteis, como produtos, serviços ou soluções.', 1),
  ('Tecnologia, informação e TI', 'Informação: conhecimento em forma escrita, oral ou audiovisual, resultante do processamento, manipulação e organização de dados.', 2),
  ('Tecnologia, informação e TI', 'O processamento transforma dados brutos em conteúdos estruturados, que modificam o conhecimento de quem os recebe.', 3),
  ('Tecnologia, informação e TI', 'TI: conjunto de recursos, técnicas e sistemas que usam computadores e dispositivos digitais para criar, processar, armazenar, recuperar e compartilhar dados e informações.', 4),
  ('Evolução da TI nas organizações', 'A TI passou a ser adotada oficialmente pela maioria das organizações há aproximadamente 50 anos.', 1),
  ('Evolução da TI nas organizações', 'Foco por período: 1970–1980 produtividade; 1980–1990 qualidade; 1990–2000 serviço.', 2),
  ('Evolução da TI nas organizações', 'Foco por período: 2000–2010 inovação; 2010–2020 design; o futuro é a próxima onda.', 3),
  ('A era da Inteligência Artificial', 'IA: capacidade de um computador ou sistema realizar tarefas que normalmente exigiriam inteligência humana.', 1),
  ('A era da Inteligência Artificial', 'Um LLM (Large Language Model) é treinado com uma quantidade enorme de exemplos (textos, imagens, dados) e aprende padrões a partir deles.', 2),
  ('A era da Inteligência Artificial', 'A IA já está no dia a dia: desbloqueio do celular com o rosto, sugestão de série na Netflix, pedido no iFood.', 3),
  ('A era da Inteligência Artificial', 'A IA pode misturar coisas e inventar detalhes que parecem verdade: é ótima fonte de rascunho, mas é preciso conferir antes de confiar.', 4),
  ('A era da Inteligência Artificial', 'A IA não é mágica, é um sistema treinado com muitos dados: ela é a ferramenta, você é o mestre.', 5),
  ('TI nas empresas: processo e projeto', 'Uma empresa tem departamentos, processos e tecnologias ou sistemas envolvidos em cada processo.', 1),
  ('TI nas empresas: processo e projeto', 'Pedir um lanche em uma rede de fast-food é um processo; implantar o totem de pedido foi um projeto.', 2),
  ('TI nas empresas: processo e projeto', 'Para criar ou modificar um sistema é preciso um projeto, com planejamento e entendimento do processo.', 3),
  ('Contexto, objetivo e justificativa', 'Projeto/contexto: o que será feito, em qual ambiente, condições e recursos disponíveis, e como será conduzido.', 1),
  ('Contexto, objetivo e justificativa', 'A condução de um projeto tem início, meio e fim, com etapas, prazos e objetivos claros.', 2),
  ('Contexto, objetivo e justificativa', 'Objetivo: o que se pretende conquistar ao término do projeto, com resultados esperados, objetivos alcançáveis e impacto desejado.', 3),
  ('Contexto, objetivo e justificativa', 'Justificativa: responde por que realizar o projeto, com argumento sólido e convincente que demonstra relevância, necessidade e benefícios.', 4)
) AS v(subtopic_name, text, order_index) ON v.subtopic_name = st.name
WHERE s.name = 'Tecnologia da Informação' AND t.number = 1
ON CONFLICT DO NOTHING;

-- 6. Listas de exercícios
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT v.title, 'exercise', t.subject_id, t.id, NULL, v.difficulty::difficulty_level
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Introdução à Tecnologia da Informação — Exercícios 1: Fundamentos', 'easy'),
  ('Introdução à Tecnologia da Informação — Exercícios 2: Aplicação', 'medium'),
  ('Introdução à Tecnologia da Informação — Exercícios 3: Desafio', 'hard')
) AS v(title, difficulty)
WHERE s.name = 'Tecnologia da Informação' AND t.number = 1
  AND NOT EXISTS (SELECT 1 FROM quizzes z WHERE z.title = v.title);

-- 7. Questões

-- Q1 | multiple_choice | fácil | Tecnologia, informação e TI | Exercícios 1 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma loja de bairro passa a usar computadores e um sistema para registrar vendas, guardar o histórico e consultar relatórios. Qual definição descreve a Tecnologia da Informação nesse caso?', 'TI é o conjunto de recursos, técnicas e sistemas que usam computadores e dispositivos digitais para criar, processar, armazenar, recuperar e compartilhar dados e informações.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Introdução à Tecnologia da Informação — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Conjunto de técnicas manuais usadas para criar produtos e serviços úteis para a loja.', false, 1),
  ('Conjunto de recursos, técnicas e sistemas digitais que tratam dados e informações.', true, 2),
  ('Conhecimento em forma escrita, oral ou audiovisual obtido a partir de dados.', false, 3),
  ('Capacidade de um sistema fazer tarefas que exigiriam inteligência humana.', false, 4),
  ('Conjunto de etapas, prazos e objetivos que conduzem um projeto até o seu fim.', false, 5)
) AS o(text, is_correct, order_index);

-- Q2 | drag_and_drop | média | Tecnologia, informação e TI | Exercícios 1 | s1: Tecnologia, s2: Informação, s3: Tecnologia da Informação
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', '{{s1}} é o uso de técnicas, habilidades, métodos e processos para criar coisas úteis. {{s2}} é o conhecimento que resulta do processamento e da organização de dados. {{s3}} é o conjunto de recursos e sistemas que usam dispositivos digitais para criar, armazenar e compartilhar dados.', 'Tecnologia cria coisas úteis com técnicas e métodos; informação é o conhecimento obtido de dados processados; a TI usa computadores e dispositivos digitais para tratar dados e informações.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Introdução à Tecnologia da Informação — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('Tecnologia da Informação', 1), ('Tecnologia', 2), ('Inteligência Artificial', 3), ('Informação', 4), ('Justificativa', 5)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'Tecnologia', 1), ('s2', 'Informação', 2), ('s3', 'Tecnologia da Informação', 3))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q3 | multiple_answer | difícil | A era da Inteligência Artificial | Exercícios 2 | corretas: A, C, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma analista usa uma IA generativa para redigir um relatório técnico para a diretoria. Segundo o material, o que vale para esse uso? Assinale todas as corretas.', 'A IA aprendeu padrões com muitos exemplos, mas não viveu nada daquilo: pode inventar detalhes que parecem verdade. Por isso é ótima fonte de rascunho, que precisa ser conferida.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Introdução à Tecnologia da Informação — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A IA pode inventar detalhes que parecem verdadeiros, mas não são.', true, 1),
  ('A IA tem experiência prática sobre aquilo que leu no treinamento.', false, 2),
  ('A resposta é uma boa fonte de rascunho, que deve ser conferida.', true, 3),
  ('A IA aprendeu padrões a partir de uma enorme massa de exemplos.', true, 4),
  ('A IA dispensa conferência, pois foi treinada com muitos dados.', false, 5)
) AS o(text, is_correct, order_index);

-- Q4 | multiple_choice | difícil | Contexto, objetivo e justificativa | Exercícios 2 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Na proposta de melhoria tecnológica de sua casa, um aluno escreveu: "Vale a pena fazer porque a conta de luz subiu 30% e as lâmpadas ficam acesas sem ninguém nos cômodos". A que parte da proposta esse trecho corresponde?', 'A justificativa responde por que realizar o projeto, com um argumento sólido e convincente que demonstra a relevância, a necessidade e os benefícios da proposta.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Introdução à Tecnologia da Informação — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Ao contexto, pois identifica o ambiente e os recursos disponíveis.', false, 1),
  ('Ao objetivo, pois define com clareza os resultados esperados.', false, 2),
  ('À condução, pois estabelece etapas com início, meio e fim.', false, 3),
  ('À informação, pois organiza dados brutos em conteúdo útil.', false, 4),
  ('À justificativa, pois argumenta por que realizar o projeto.', true, 5)
) AS o(text, is_correct, order_index);

-- Q5 | single_choice | difícil | Contexto, objetivo e justificativa | Exercícios 2 | b1: contexto, b2: objetivo, b3: justificativa
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Na proposta de um projeto de TI, o {{b1}} identifica o ambiente, as condições e os recursos disponíveis; o {{b2}} define o que se pretende conquistar ao término do projeto; e a {{b3}} apresenta um argumento sólido que demonstra relevância, necessidade e benefícios.', 'O contexto situa o projeto no ambiente e nos recursos, o objetivo diz o que se pretende conquistar ao final e a justificativa responde por que realizar o projeto.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Introdução à Tecnologia da Informação — Exercícios 2: Aplicação'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'objetivo', false, 1), ('b1', 'contexto', true, 2), ('b1', 'processo', false, 3),
  ('b2', 'objetivo', true, 1), ('b2', 'contexto', false, 2), ('b2', 'treinamento', false, 3),
  ('b3', 'tecnologia', false, 1), ('b3', 'informação', false, 2), ('b3', 'justificativa', true, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q6 | multiple_choice | fácil | A era da Inteligência Artificial | Exercícios 1 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Segundo o material, o que é Inteligência Artificial?', 'IA é a capacidade de um computador ou sistema realizar tarefas que normalmente exigiriam inteligência humana.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Introdução à Tecnologia da Informação — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A capacidade de um sistema realizar tarefas que exigiriam inteligência humana.', true, 1),
  ('A capacidade de um sistema armazenar e recuperar grandes volumes de dados digitais.', false, 2),
  ('O conjunto de dispositivos digitais usados para compartilhar informações.', false, 3),
  ('O uso de métodos e processos para criar produtos, serviços ou soluções.', false, 4),
  ('O conhecimento estruturado que resulta do processamento de dados brutos.', false, 5)
) AS o(text, is_correct, order_index);

-- Q7 | drag_and_drop | super difícil | Evolução da TI nas organizações | Exercícios 3 | s1: produtividade, s2: qualidade, s3: serviço, s4: inovação, s5: design
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Na evolução da TI nas organizações, o foco de cada período foi: 1970–1980, {{s1}}; 1980–1990, {{s2}}; 1990–2000, {{s3}}; 2000–2010, {{s4}}; 2010–2020, {{s5}}.', 'A linha do tempo do material vai da produtividade, obtida com a automação do trabalho, passando por qualidade, serviço e inovação, até o design na década de 2010.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Introdução à Tecnologia da Informação — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('design', 1), ('mobilidade', 2), ('qualidade', 3), ('produtividade', 4), ('serviço', 5), ('segurança', 6), ('inovação', 7)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'produtividade', 1), ('s2', 'qualidade', 2), ('s3', 'serviço', 3), ('s4', 'inovação', 4), ('s5', 'design', 5))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q8 | multiple_choice | super difícil | TI nas empresas: processo e projeto | Exercícios 3 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma rede de lanchonetes atende no balcão há anos: o cliente pede, paga e retira o lanche. A diretoria decide implantar totens de autoatendimento em todas as lojas. Como classificar as duas situações?', 'Pedir um lanche é um processo do dia a dia da empresa. Implantar o totem é uma mudança significativa desse processo, feita por meio de um projeto, com planejamento, início, meio e fim.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Introdução à Tecnologia da Informação — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('O atendimento no balcão é um projeto, e a implantação dos totens é um processo.', false, 1),
  ('As duas situações são processos, pois ambas envolvem tecnologias e sistemas.', false, 2),
  ('O atendimento no balcão é um processo, e a implantação dos totens é um projeto.', true, 3),
  ('As duas situações são projetos, pois ambas envolvem departamentos e áreas.', false, 4),
  ('O atendimento no balcão é um contexto, e a implantação dos totens é um objetivo.', false, 5)
) AS o(text, is_correct, order_index);

-- Q9 | multiple_answer | super difícil | TI nas empresas: processo e projeto | Exercícios 3 | corretas: A, B, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Antes de implantar totens de pedido em suas lojas, a equipe de TI de uma rede de fast-food prepara o projeto. Segundo o material, o que faz parte dessa preparação? Assinale todas as corretas.', 'Criar ou modificar um sistema pede um projeto: é preciso entender o processo que será alterado e planejar a condução com início, meio e fim, etapas, prazos e objetivos claros.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Introdução à Tecnologia da Informação — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Entender o processo de pedido que será modificado.', true, 1),
  ('Planejar a condução com início, meio e fim definidos.', true, 2),
  ('Dispensar os prazos, pois um projeto não tem um fim.', false, 3),
  ('Estabelecer etapas, prazos e objetivos bem claros.', true, 4),
  ('Tratar a mudança como rotina, sem um planejamento.', false, 5)
) AS o(text, is_correct, order_index);

-- Q10 | multiple_choice | média | Tecnologia, informação e TI | Exercícios 1 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma planilha guarda milhares de registros de vendas soltos. Depois de organizados e processados, eles mostram ao gerente quais produtos vendem mais, e ele muda suas decisões de compra. O que esse resultado representa?', 'Informação é o conhecimento que resulta do processamento e da organização de dados brutos, de modo que provoque uma modificação no conhecimento de quem a recebe.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Introdução à Tecnologia da Informação — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Tecnologia, pois é um método usado para criar um serviço.', false, 1),
  ('Dado bruto, pois ainda não passou por um processamento.', false, 2),
  ('Justificativa, pois demonstra a relevância de um projeto.', false, 3),
  ('Informação, pois modifica o conhecimento de quem a recebe.', true, 4),
  ('Contexto, pois identifica o ambiente e as suas condições.', false, 5)
) AS o(text, is_correct, order_index);

-- Q11 | single_choice | super difícil | A era da Inteligência Artificial | Exercícios 3 | b1: Large Language Model, b2: treinamento, b3: padrões, b4: inventar detalhes
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Um modelo do tipo {{b1}} aprende por meio de {{b2}} com uma quantidade enorme de exemplos, dos quais extrai {{b3}}. Como não viveu nada do que leu, ele pode {{b4}}, e por isso suas respostas devem ser conferidas.', 'LLM significa Large Language Model: é treinado com muitos textos, imagens e dados e aprende padrões. Sem experiência prática, às vezes inventa detalhes que parecem verdade.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Introdução à Tecnologia da Informação — Exercícios 3: Desafio'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'Large Logic Memory', false, 1), ('b1', 'Large Language Model', true, 2), ('b1', 'Long Learning Machine', false, 3),
  ('b2', 'treinamento', true, 1), ('b2', 'experiência prática', false, 2), ('b2', 'programação manual', false, 3),
  ('b3', 'regras fixas', false, 1), ('b3', 'opiniões próprias', false, 2), ('b3', 'padrões', true, 3),
  ('b4', 'apagar os dados', false, 1), ('b4', 'inventar detalhes', true, 2), ('b4', 'parar de responder', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q12 | drag_and_drop | fácil | Contexto, objetivo e justificativa | Exercícios 1 | s1: o que, s2: contexto, s3: como
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'O bloco projeto/contexto de uma proposta responde: {{s1}} será feito, que é a definição da ação; em qual {{s2}} será realizado, com o ambiente, as condições e os recursos; e {{s3}} será conduzido, com início, meio e fim.', 'O projeto/contexto define o que será feito, em qual contexto será realizado e como será conduzido, com etapas, prazos e objetivos claros.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Introdução à Tecnologia da Informação — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('como', 1), ('impacto', 2), ('por que', 3), ('contexto', 4), ('o que', 5)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'o que', 1), ('s2', 'contexto', 2), ('s3', 'como', 3))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q13 | drag_and_drop | difícil | A era da Inteligência Artificial | Exercícios 2 | s1: ferramenta, s2: mestre, s3: mágica, s4: dados
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Sobre o uso consciente da IA: ela é a {{s1}} e você é o {{s2}}. A IA não é {{s3}}, e sim um sistema treinado com muitos {{s4}}.', 'O material resume: a IA é a ferramenta e você é o mestre. Ela não é mágica, é um sistema treinado com muitos dados, e a diferença está em usá-la com intenção.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Introdução à Tecnologia da Informação — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('rascunho', 1), ('mágica', 2), ('mestre', 3), ('colega', 4), ('ferramenta', 5), ('dados', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'ferramenta', 1), ('s2', 'mestre', 2), ('s3', 'mágica', 3), ('s4', 'dados', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q14 | multiple_choice | super difícil | Contexto, objetivo e justificativa | Exercícios 3 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Na proposta "Automatizar a irrigação do jardim de casa", qual trecho é um objetivo, e não contexto, justificativa ou forma de condução?', 'O objetivo é o que se pretende conquistar ao término do projeto, com resultados esperados claros. As demais descrevem o ambiente, o motivo, as etapas ou uma definição.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Introdução à Tecnologia da Informação — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Ao final, o jardim será regado sozinho todos os dias às 6h, sem desperdício.', true, 1),
  ('A casa tem um jardim de 20 m², uma torneira externa e Wi-Fi no quintal.', false, 2),
  ('Vale a pena porque as plantas secam nas viagens e a conta de água sobe.', false, 3),
  ('O trabalho terá três etapas, comprar, instalar e testar, em até duas semanas.', false, 4),
  ('Irrigar é usar técnicas e métodos para criar algo útil para o jardim.', false, 5)
) AS o(text, is_correct, order_index);

-- Q15 | multiple_answer | difícil | Tecnologia, informação e TI | Exercícios 2 | corretas: B, C, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma escola quer explicar aos pais o que a área de TI faz. Pela definição do material, quais ações com dados e informações fazem parte da TI? Assinale todas as corretas.', 'A TI usa computadores e dispositivos digitais para criar, processar, armazenar, recuperar e compartilhar dados e informações.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Introdução à Tecnologia da Informação — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Precificar e vender os dados.', false, 1),
  ('Criar e processar os dados.', true, 2),
  ('Armazenar e recuperar dados.', true, 3),
  ('Auditar e tributar os dados.', false, 4),
  ('Compartilhar as informações.', true, 5)
) AS o(text, is_correct, order_index);

-- 8. Conferência: aborta se alguma questão ficou fora das listas ou alguma lista ficou vazia
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM questions q
    JOIN topics t ON t.id = q.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 1
      AND NOT EXISTS (
        SELECT 1 FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
        WHERE qq.question_id = q.id AND z.kind = 'exercise'
      )
  ) THEN
    RAISE EXCEPTION 'Há questão da aula 1 de Tecnologia da Informação fora das listas de exercícios';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM quizzes z
    JOIN topics t ON t.id = z.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 1 AND z.kind = 'exercise'
      AND NOT EXISTS (SELECT 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  ) THEN
    RAISE EXCEPTION 'Há lista de exercícios da aula 1 de Tecnologia da Informação sem questões';
  END IF;
END $$;

-- =====================================================================
-- AULA 2 — Documentação de Projetos de TI (TI-Sprint 1-Aula 02.pdf)
-- =====================================================================

-- 1. Disciplina
INSERT INTO subjects (name, short_label)
SELECT 'Tecnologia da Informação', 'TI'
WHERE NOT EXISTS (SELECT 1 FROM subjects WHERE name = 'Tecnologia da Informação');

-- 2. Assunto
INSERT INTO topics (subject_id, number, name, description)
SELECT s.id, 2, 'Documentação de Projetos de TI', 'Como nascem os projetos de TI nas empresas, as etapas da iniciação ao encerramento e por que a documentação é a ponte entre a ideia e a execução.'
FROM subjects s
WHERE s.name = 'Tecnologia da Informação'
ON CONFLICT DO NOTHING;

-- 3. Trava: aborta se a aula não existir ou já existir com outro nome
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM topics t JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 2 AND t.name = 'Documentação de Projetos de TI'
  ) THEN
    RAISE EXCEPTION 'A aula 2 de Tecnologia da Informação não existe ou já está cadastrada com outro nome';
  END IF;
END $$;

-- 4. Subassuntos
INSERT INTO subtopics (topic_id, name, summary, order_index)
SELECT t.id, v.name, v.summary, v.order_index
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Como nascem os projetos', 'Um projeto de TI nasce de um problema, de uma necessidade ou de uma oportunidade. Identificar a origem é o primeiro passo para definir o propósito do projeto.', 1),
  ('Etapas de um projeto de TI', 'O projeto passa por iniciação, planejamento, execução e encerramento, acompanhados por processos de monitoramento e controle. Cada etapa responde a uma pergunta diferente.', 2),
  ('Por que documentar um projeto', 'A documentação transforma uma ideia em um plano. Sem ela cada pessoa entende o projeto de um jeito; com ela todos compartilham o mesmo objetivo e as decisões ficam registradas.', 3),
  ('As quatro perguntas da documentação', 'Toda documentação de projeto responde a quatro perguntas fundamentais, cada uma ligada a um elemento: contexto, objetivo, justificativa e escopo.', 4)
) AS v(name, summary, order_index)
WHERE s.name = 'Tecnologia da Informação' AND t.number = 2
ON CONFLICT DO NOTHING;

-- 5. Pontos-chave
INSERT INTO subtopic_key_points (subtopic_id, text, order_index)
SELECT st.id, v.text, v.order_index
FROM subtopics st
JOIN topics t ON t.id = st.topic_id
JOIN subjects s ON s.id = t.subject_id
JOIN (VALUES
  ('Como nascem os projetos', 'Problemas: falhas, interrupções, mau funcionamento, bugs e erros de processos, como a lentidão na navegação do site.', 1),
  ('Como nascem os projetos', 'Necessidade: melhorias de processos, inovações e demandas normativas e regulatórias, como uma nova legislação.', 2),
  ('Como nascem os projetos', 'Oportunidades: melhorias de processos, inovações e demandas de negócio, como um novo produto ou serviço.', 3),
  ('Etapas de um projeto de TI', 'Iniciação: define o propósito do projeto, isto é, qual problema será resolvido, que necessidade será atendida ou que oportunidade será aproveitada.', 1),
  ('Etapas de um projeto de TI', 'Planejamento: define as estratégias, a equipe e os recursos necessários; ferramentas como o 5W2H ajudam a organizar.', 2),
  ('Etapas de um projeto de TI', 'Execução: as ideias são colocadas em prática e o progresso é acompanhado com base em indicadores; se algo sair do planejado, as estratégias são ajustadas.', 3),
  ('Etapas de um projeto de TI', 'Encerramento: avalia se os objetivos foram alcançados e se o produto está pronto para entrega, além dos resultados e da eficácia do projeto.', 4),
  ('Etapas de um projeto de TI', 'No encerramento também se analisa a necessidade de novas etapas, replanejamento ou encerramento definitivo.', 5),
  ('Por que documentar um projeto', 'Sem documentação: cada pessoa entende de um jeito, o projeto muda durante o desenvolvimento e a equipe trabalha com interpretações diferentes.', 1),
  ('Por que documentar um projeto', 'Sem documentação aumentam os erros, o retrabalho e os custos.', 2),
  ('Por que documentar um projeto', 'Com documentação: todos entendem o mesmo objetivo e o cliente e a equipe falam a mesma linguagem.', 3),
  ('Por que documentar um projeto', 'Com documentação: as decisões ficam registradas e o projeto ganha organização e previsibilidade.', 4),
  ('Por que documentar um projeto', 'A documentação é a ponte entre a ideia e a execução.', 5),
  ('As quatro perguntas da documentação', 'O quê? Contexto.', 1),
  ('As quatro perguntas da documentação', 'Onde queremos chegar? Objetivo.', 2),
  ('As quatro perguntas da documentação', 'Por quê? Justificativa.', 3),
  ('As quatro perguntas da documentação', 'O que faz parte e o que não faz? Escopo.', 4),
  ('As quatro perguntas da documentação', 'Uma boa documentação reduz dúvidas, melhora a comunicação e aumenta as chances de sucesso do projeto.', 5)
) AS v(subtopic_name, text, order_index) ON v.subtopic_name = st.name
WHERE s.name = 'Tecnologia da Informação' AND t.number = 2
ON CONFLICT DO NOTHING;

-- 6. Listas de exercícios
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT v.title, 'exercise', t.subject_id, t.id, NULL, v.difficulty::difficulty_level
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Documentação de Projetos de TI — Exercícios 1: Fundamentos', 'easy'),
  ('Documentação de Projetos de TI — Exercícios 2: Aplicação', 'medium'),
  ('Documentação de Projetos de TI — Exercícios 3: Desafio', 'hard')
) AS v(title, difficulty)
WHERE s.name = 'Tecnologia da Informação' AND t.number = 2
  AND NOT EXISTS (SELECT 1 FROM quizzes z WHERE z.title = v.title);

-- 7. Questões

-- Q1 | multiple_choice | média | Como nascem os projetos | Exercícios 1 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'O site de uma loja virtual está lento e os clientes desistem das compras no meio do caminho. A empresa abre um projeto de TI para resolver a situação. Qual é a origem desse projeto?', 'A lentidão na navegação do site é o exemplo do material para projetos que nascem de problemas: falhas, interrupções, mau funcionamento, bugs e erros de processos.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Documentação de Projetos de TI — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Uma necessidade, pois decorre de uma nova demanda regulatória.', false, 1),
  ('Uma oportunidade, pois decorre de um novo produto ou serviço.', false, 2),
  ('Um problema, pois decorre de uma falha ou mau funcionamento.', true, 3),
  ('Uma justificativa, pois decorre de um argumento convincente.', false, 4),
  ('Um encerramento, pois decorre da avaliação dos resultados.', false, 5)
) AS o(text, is_correct, order_index);

-- Q2 | drag_and_drop | fácil | Etapas de um projeto de TI | Exercícios 1 | s1: Iniciação, s2: Planejamento, s3: Execução, s4: Encerramento
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'As etapas de um projeto de TI seguem esta ordem: {{s1}} → {{s2}} → {{s3}} → {{s4}}.', 'O projeto começa na iniciação, passa pelo planejamento e pela execução e termina no encerramento, sempre acompanhado pelos processos de monitoramento e controle.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Documentação de Projetos de TI — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('Documentação', 1), ('Justificativa', 2), ('Encerramento', 3), ('Execução', 4), ('Planejamento', 5), ('Iniciação', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'Iniciação', 1), ('s2', 'Planejamento', 2), ('s3', 'Execução', 3), ('s4', 'Encerramento', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q3 | multiple_choice | fácil | As quatro perguntas da documentação | Exercícios 1 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Qual das quatro perguntas fundamentais da documentação de um projeto é respondida pelo escopo?', 'O escopo responde "o que faz parte e o que não faz?". O contexto responde "o quê?", o objetivo "onde queremos chegar?" e a justificativa "por quê?".'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Documentação de Projetos de TI — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('O que faz parte do projeto e o que não faz?', true, 1),
  ('Aonde queremos chegar ao fim do projeto?', false, 2),
  ('Por que vale a pena realizar o projeto?', false, 3),
  ('O que é o projeto e qual é o seu cenário?', false, 4),
  ('Quem responde pela execução do projeto?', false, 5)
) AS o(text, is_correct, order_index);

-- Q4 | multiple_answer | difícil | Por que documentar um projeto | Exercícios 2 | corretas: B, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma startup desenvolve um aplicativo durante seis meses sem produzir nenhuma documentação. Quais consequências o material aponta para essa escolha? Assinale todas as corretas.', 'Sem documentação cada pessoa entende o projeto de um jeito e aumentam erros, retrabalho e custos. Registro de decisões, linguagem comum e previsibilidade são ganhos de quem documenta.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Documentação de Projetos de TI — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('As decisões tomadas ficam registradas para toda a equipe.', false, 1),
  ('Cada pessoa entende o projeto de um jeito diferente.', true, 2),
  ('O cliente e a equipe passam a falar a mesma linguagem.', false, 3),
  ('Aumentam os erros, o retrabalho e os custos do projeto.', true, 4),
  ('O projeto ganha mais organização e previsibilidade.', false, 5)
) AS o(text, is_correct, order_index);

-- Q5 | single_choice | difícil | Etapas de um projeto de TI | Exercícios 2 | b1: iniciação, b2: planejamento, b3: 5W2H, b4: execução
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Na {{b1}}, define-se claramente o propósito do projeto. No {{b2}}, definem-se as estratégias, a equipe e os recursos, com apoio de ferramentas como o {{b3}}. Na {{b4}}, as ideias são colocadas em prática e o progresso é acompanhado por indicadores.', 'A iniciação define o propósito; o planejamento organiza estratégias, equipe e recursos, com ferramentas como o 5W2H; a execução põe as ideias em prática e acompanha indicadores.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Documentação de Projetos de TI — Exercícios 2: Aplicação'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'iniciação', true, 1), ('b1', 'execução', false, 2), ('b1', 'documentação', false, 3),
  ('b2', 'encerramento', false, 1), ('b2', 'planejamento', true, 2), ('b2', 'monitoramento', false, 3),
  ('b3', '2W5H', false, 1), ('b3', '5H2W', false, 2), ('b3', '5W2H', true, 3),
  ('b4', 'iniciação', false, 1), ('b4', 'execução', true, 2), ('b4', 'justificativa', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q6 | multiple_choice | difícil | Etapas de um projeto de TI | Exercícios 2 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Durante o desenvolvimento de um sistema de matrículas, os indicadores mostram que o progresso saiu do que foi planejado. Segundo o material, o que deve ser feito nessa etapa?', 'Na execução, se algo sair do planejado, ajustes nas estratégias devem ser feitos para garantir que os objetivos sejam alcançados.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Documentação de Projetos de TI — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Encerrar o projeto e avaliar se o produto está pronto.', false, 1),
  ('Voltar à iniciação e redefinir o propósito do projeto.', false, 2),
  ('Seguir o plano original até a data final da entrega.', false, 3),
  ('Trocar a equipe e os recursos definidos no começo.', false, 4),
  ('Ajustar as estratégias para alcançar os objetivos.', true, 5)
) AS o(text, is_correct, order_index);

-- Q7 | drag_and_drop | difícil | As quatro perguntas da documentação | Exercícios 2 | s1: Contexto, s2: Objetivo, s3: Justificativa, s4: Escopo
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Cada pergunta da documentação leva a um elemento. "O quê?": {{s1}}. "Onde queremos chegar?": {{s2}}. "Por quê?": {{s3}}. "O que faz parte e o que não faz?": {{s4}}.', 'Toda documentação de projeto responde a quatro perguntas: o quê (contexto), onde queremos chegar (objetivo), por quê (justificativa) e o que faz parte e o que não faz (escopo).'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Documentação de Projetos de TI — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('Indicador', 1), ('Execução', 2), ('Contexto', 3), ('Escopo', 4), ('Justificativa', 5), ('Objetivo', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'Contexto', 1), ('s2', 'Objetivo', 2), ('s3', 'Justificativa', 3), ('s4', 'Escopo', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q8 | multiple_choice | super difícil | Como nascem os projetos | Exercícios 3 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma lei recém-aprovada obriga as clínicas a guardar os prontuários em formato digital. Uma clínica abre um projeto de TI para se adequar. Pela classificação do material, esse projeto nasce de:', 'Uma nova legislação é o exemplo do material para projetos que nascem de uma necessidade, grupo que inclui as demandas normativas e regulatórias.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Documentação de Projetos de TI — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('um problema, como os bugs e as interrupções do sistema atual.', false, 1),
  ('uma necessidade, como uma demanda normativa e regulatória.', true, 2),
  ('uma oportunidade, como um novo produto para os clientes.', false, 3),
  ('um encerramento, como a análise da eficácia do projeto.', false, 4),
  ('um planejamento, como a definição de equipe e recursos.', false, 5)
) AS o(text, is_correct, order_index);

-- Q9 | multiple_answer | super difícil | Etapas de um projeto de TI | Exercícios 3 | corretas: A, C, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma equipe chega ao encerramento do projeto de um portal de atendimento. Segundo o material, o que é avaliado nessa fase? Assinale todas as corretas.', 'No encerramento avalia-se se os objetivos foram alcançados, se o produto está pronto para entrega e se há necessidade de novas etapas. Propósito e recursos são da iniciação e do planejamento.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Documentação de Projetos de TI — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Se os objetivos do projeto foram alcançados.', true, 1),
  ('Qual problema ou oportunidade será tratado.', false, 2),
  ('Se o produto está pronto para ser entregue.', true, 3),
  ('Quais equipe e recursos serão necessários.', false, 4),
  ('Se há necessidade de novas etapas no projeto.', true, 5)
) AS o(text, is_correct, order_index);

-- Q10 | multiple_choice | fácil | Por que documentar um projeto | Exercícios 1 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Segundo o material, a documentação de um projeto é:', 'A documentação transforma uma ideia em um plano: ela é a ponte entre a ideia e a execução.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Documentação de Projetos de TI — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('a etapa final, feita depois da entrega.', false, 1),
  ('um registro opcional, útil só ao cliente.', false, 2),
  ('a lista de bugs achados na execução.', false, 3),
  ('a ponte entre a ideia e a execução.', true, 4),
  ('o contrato de custos entre as partes.', false, 5)
) AS o(text, is_correct, order_index);

-- Q11 | drag_and_drop | média | Como nascem os projetos | Exercícios 1 | s1: problema, s2: necessidade, s3: oportunidade
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Classifique a origem de cada projeto. Lentidão na navegação do site: {{s1}}. Nova legislação a ser cumprida: {{s2}}. Lançamento de um novo produto ou serviço: {{s3}}.', 'Falhas e mau funcionamento são problemas; demandas normativas e regulatórias são necessidades; demandas de negócio, como um novo produto ou serviço, são oportunidades.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Documentação de Projetos de TI — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('problema', 1), ('encerramento', 2), ('justificativa', 3), ('oportunidade', 4), ('necessidade', 5)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'problema', 1), ('s2', 'necessidade', 2), ('s3', 'oportunidade', 3))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q12 | single_choice | super difícil | Por que documentar um projeto | Exercícios 3 | b1: ideia, b2: plano, b3: decisões, b4: previsibilidade
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'A documentação transforma uma {{b1}} em um {{b2}}. Com ela, as {{b3}} ficam registradas e o projeto ganha organização e {{b4}}.', 'A documentação transforma uma ideia em um plano. Com documentação, as decisões ficam registradas e o projeto ganha organização e previsibilidade.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Documentação de Projetos de TI — Exercícios 3: Desafio'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'falha', false, 1), ('b1', 'ideia', true, 2), ('b1', 'equipe', false, 3),
  ('b2', 'custo', false, 1), ('b2', 'indicador', false, 2), ('b2', 'plano', true, 3),
  ('b3', 'decisões', true, 1), ('b3', 'interpretações', false, 2), ('b3', 'dúvidas', false, 3),
  ('b4', 'retrabalho', false, 1), ('b4', 'previsibilidade', true, 2), ('b4', 'lentidão', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q13 | multiple_answer | difícil | As quatro perguntas da documentação | Exercícios 2 | corretas: B, C, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma fábrica de software decide documentar todos os seus projetos. Que ganhos o material atribui a uma boa documentação? Assinale todas as corretas.', 'Uma boa documentação reduz dúvidas, melhora a comunicação e aumenta as chances de sucesso do projeto. Ela não substitui o cliente nem impede mudanças.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Documentação de Projetos de TI — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Elimina a necessidade de conversar com o cliente.', false, 1),
  ('Reduz as dúvidas das pessoas sobre o projeto.', true, 2),
  ('Melhora a comunicação entre todos os envolvidos.', true, 3),
  ('Aumenta as chances de sucesso de cada projeto.', true, 4),
  ('Garante que o projeto jamais sofrerá mudanças.', false, 5)
) AS o(text, is_correct, order_index);

-- Q14 | multiple_choice | super difícil | Por que documentar um projeto | Exercícios 3 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um cliente lista 20 funcionalidades para uma rede social jovem, do login facial à versão premium. Sem nada escrito, três desenvolvedores começam a programar e cada um prioriza itens diferentes. Que efeito da falta de documentação o caso mostra?', 'Sem documentação, cada pessoa entende de um jeito e a equipe trabalha com interpretações diferentes, o que aumenta erros, retrabalho e custos.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Documentação de Projetos de TI — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('As decisões ficam registradas, mas ninguém as consulta depois.', false, 1),
  ('O cliente e a equipe passam a falar a mesma linguagem.', false, 2),
  ('A equipe trabalha com interpretações diferentes do pedido.', true, 3),
  ('O projeto ganha previsibilidade, mas perde a organização.', false, 4),
  ('Os indicadores de progresso deixam de ser acompanhados.', false, 5)
) AS o(text, is_correct, order_index);

-- Q15 | drag_and_drop | super difícil | Etapas de um projeto de TI | Exercícios 3 | s1: Iniciação, s2: Planejamento, s3: Execução, s4: Encerramento, s5: Monitoramento e Controle
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Relacione cada pergunta à etapa do projeto. "Que problema será resolvido?": {{s1}}. "Quais estratégias, equipe e recursos?": {{s2}}. "O progresso segue os indicadores?": {{s3}}. "Os objetivos foram alcançados?": {{s4}}. Tudo isso é acompanhado pelos processos de {{s5}}.', 'A iniciação define o propósito, o planejamento define estratégias, equipe e recursos, a execução acompanha indicadores e o encerramento avalia os objetivos, sob monitoramento e controle.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Documentação de Projetos de TI — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('Documentação', 1), ('Iniciação', 2), ('Planejamento', 3), ('Execução', 4), ('Monitoramento e Controle', 5), ('Oportunidade', 6), ('Encerramento', 7)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'Iniciação', 1), ('s2', 'Planejamento', 2), ('s3', 'Execução', 3), ('s4', 'Encerramento', 4), ('s5', 'Monitoramento e Controle', 5))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- 8. Conferência: aborta se alguma questão ficou fora das listas ou alguma lista ficou vazia
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM questions q
    JOIN topics t ON t.id = q.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 2
      AND NOT EXISTS (
        SELECT 1 FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
        WHERE qq.question_id = q.id AND z.kind = 'exercise'
      )
  ) THEN
    RAISE EXCEPTION 'Há questão da aula 2 de Tecnologia da Informação fora das listas de exercícios';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM quizzes z
    JOIN topics t ON t.id = z.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 2 AND z.kind = 'exercise'
      AND NOT EXISTS (SELECT 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  ) THEN
    RAISE EXCEPTION 'Há lista de exercícios da aula 2 de Tecnologia da Informação sem questões';
  END IF;
END $$;

-- =====================================================================
-- AULA 3 — Escopo, Premissas e Restrições (TI-Sprint 1-Aula 03.pdf)
-- =====================================================================

-- 1. Disciplina
INSERT INTO subjects (name, short_label)
SELECT 'Tecnologia da Informação', 'TI'
WHERE NOT EXISTS (SELECT 1 FROM subjects WHERE name = 'Tecnologia da Informação');

-- 2. Assunto
INSERT INTO topics (subject_id, number, name, description)
SELECT s.id, 3, 'Escopo, Premissas e Restrições', 'Como montar o escopo de um projeto, com módulos, limites e prazo, e como registrar as premissas e as restrições que o cercam.'
FROM subjects s
WHERE s.name = 'Tecnologia da Informação'
ON CONFLICT DO NOTHING;

-- 3. Trava: aborta se a aula não existir ou já existir com outro nome
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM topics t JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 3 AND t.name = 'Escopo, Premissas e Restrições'
  ) THEN
    RAISE EXCEPTION 'A aula 3 de Tecnologia da Informação não existe ou já está cadastrada com outro nome';
  END IF;
END $$;

-- 4. Subassuntos
INSERT INTO subtopics (topic_id, name, summary, order_index)
SELECT t.id, v.name, v.summary, v.order_index
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Os elementos da documentação', 'Contexto, objetivo, justificativa e escopo têm papéis distintos na documentação. O contexto explica o cenário, o objetivo diz o que se quer alcançar, a justificativa convence e o escopo delimita.', 1),
  ('O que deve ter no escopo', 'O escopo reúne a descrição resumida do projeto, os módulos e requisitos, os limites e exclusões, os recursos necessários e o prazo desejado.', 2),
  ('WBS e backlog ágil: terminologias', 'O modelo WBS (ou EAP) e o modelo ágil organizam o trabalho em três níveis, com nomes diferentes para a mesma ideia.', 3),
  ('Premissas', 'Premissas são fatores ligados ao escopo que o planejamento assume como verdadeiros, sem exigir prova. Se uma delas não se confirmar, o plano é afetado.', 4),
  ('Restrições', 'Restrições são limitações que comprometem a execução do trabalho, impostas por alguém ou por um contexto. As principais são prazo, escopo e custos.', 5)
) AS v(name, summary, order_index)
WHERE s.name = 'Tecnologia da Informação' AND t.number = 3
ON CONFLICT DO NOTHING;

-- 5. Pontos-chave
INSERT INTO subtopic_key_points (subtopic_id, text, order_index)
SELECT st.id, v.text, v.order_index
FROM subtopics st
JOIN topics t ON t.id = st.topic_id
JOIN subjects s ON s.id = t.subject_id
JOIN (VALUES
  ('Os elementos da documentação', 'Contexto: texto dissertativo que apresenta o cenário, traz dados e fatos relevantes e apresenta o problema, a necessidade ou a oportunidade.', 1),
  ('Os elementos da documentação', 'Objetivo: aquilo que se espera ao final do projeto; precisa ser sucinto e SMART.', 2),
  ('Os elementos da documentação', 'Justificativa: um argumento muito convincente para realizar o projeto.', 3),
  ('Os elementos da documentação', 'Escopo: declaração das atividades, recursos e requisitos do que será feito, que apresenta também o que não será feito.', 4),
  ('Os elementos da documentação', 'Dentro do escopo ficam as premissas e as restrições; ele define a abrangência e os limites do projeto.', 5),
  ('O que deve ter no escopo', 'Descrição resumida: visão geral do projeto, com seu contexto, a motivação por trás da iniciativa e sua relevância.', 1),
  ('O que deve ter no escopo', 'Módulos e requisitos: critérios técnicos e funcionais que devem ser atendidos para o projeto alcançar seus objetivos.', 2),
  ('O que deve ter no escopo', 'Limites e exclusões: o que está incluído e, igualmente importante, o que está fora do projeto, para evitar mal-entendidos.', 3),
  ('O que deve ter no escopo', 'Macro cronograma: visão geral das principais fases e atividades, com durações e datas previstas de início e término.', 4),
  ('O que deve ter no escopo', 'O cronograma permite acompanhar o progresso, identificar interdependências e antecipar possíveis atrasos.', 5),
  ('WBS e backlog ágil: terminologias', 'WBS (Work Breakdown Structure) é a Estrutura Analítica do Projeto (EAP).', 1),
  ('WBS e backlog ágil: terminologias', 'No WBS os níveis são módulo, requisito e requisito detalhado.', 2),
  ('WBS e backlog ágil: terminologias', 'No modelo ágil (backlog) os níveis são épico, feature (funcionalidade) e história do usuário (user story).', 3),
  ('Premissas', 'Premissas: fatores associados ao escopo que, para fins de planejamento, são assumidos como verdadeiros, reais ou certos, sem necessidade de prova ou demonstração.', 1),
  ('Premissas', 'Exemplo do totem: todas as lojas terão energia elétrica (110 V) disponível e acessível para cada totem.', 2),
  ('Premissas', 'Exemplo do totem: haverá internet com velocidade mínima de 100 Mb.', 3),
  ('Premissas', 'Exemplo do totem: a loja disponibilizará um responsável no local durante a instalação.', 4),
  ('Restrições', 'Restrições: limitações que comprometem a execução de um trabalho e podem afetar o desempenho e até o resultado do projeto.', 1),
  ('Restrições', 'São situações impostas por alguém ou por um contexto.', 2),
  ('Restrições', 'Normalmente, as principais restrições de um projeto são o prazo, o escopo e os custos.', 3),
  ('Restrições', 'Exemplos do totem: orçamento máximo de R$ 20 milhões e implantação concluída antes da Black Friday.', 4)
) AS v(subtopic_name, text, order_index) ON v.subtopic_name = st.name
WHERE s.name = 'Tecnologia da Informação' AND t.number = 3
ON CONFLICT DO NOTHING;

-- 6. Listas de exercícios
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT v.title, 'exercise', t.subject_id, t.id, NULL, v.difficulty::difficulty_level
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Escopo, Premissas e Restrições — Exercícios 1: Fundamentos', 'easy'),
  ('Escopo, Premissas e Restrições — Exercícios 2: Aplicação', 'medium'),
  ('Escopo, Premissas e Restrições — Exercícios 3: Desafio', 'hard')
) AS v(title, difficulty)
WHERE s.name = 'Tecnologia da Informação' AND t.number = 3
  AND NOT EXISTS (SELECT 1 FROM quizzes z WHERE z.title = v.title);

-- 7. Questões

-- Q1 | multiple_choice | fácil | Premissas | Exercícios 1 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'O que são as premissas de um projeto?', 'Premissas são fatores associados ao escopo que, para fins de planejamento, são assumidos como verdadeiros, reais ou certos, sem a necessidade de prova ou demonstração.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Escopo, Premissas e Restrições — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Limitações impostas que comprometem a execução de um trabalho.', false, 1),
  ('Critérios técnicos e funcionais que o projeto deve atender.', false, 2),
  ('Itens deixados fora do escopo para evitar mal-entendidos.', false, 3),
  ('Fatores assumidos como verdadeiros para fins de planejamento.', true, 4),
  ('Fases do projeto com as suas durações e datas previstas.', false, 5)
) AS o(text, is_correct, order_index);

-- Q2 | drag_and_drop | média | WBS e backlog ágil: terminologias | Exercícios 1 | s1: módulo, s2: épico, s3: feature, s4: história do usuário
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'No modelo WBS, a hierarquia é {{s1}} → requisito → requisito detalhado. No modelo ágil, a hierarquia equivalente é {{s2}} → {{s3}} → {{s4}}.', 'O módulo do WBS equivale ao épico do modelo ágil; o requisito equivale à feature (funcionalidade); e o requisito detalhado equivale à história do usuário.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Escopo, Premissas e Restrições — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('módulo', 1), ('épico', 2), ('cronograma', 3), ('premissa', 4), ('feature', 5), ('história do usuário', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'módulo', 1), ('s2', 'épico', 2), ('s3', 'feature', 3), ('s4', 'história do usuário', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q3 | multiple_choice | difícil | Restrições | Exercícios 2 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'No projeto de totens de uma rede de lanchonetes, a diretoria determina: "o orçamento máximo é de R$ 20 milhões e a implantação deve terminar antes da Black Friday". Essas duas determinações são:', 'Restrições são limitações impostas por alguém ou por um contexto que comprometem a execução. As principais são prazo, escopo e custos, como o orçamento e a data da Black Friday.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Escopo, Premissas e Restrições — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('premissas, pois são assumidas como certas sem precisar de prova.', false, 1),
  ('restrições, pois são limitações impostas de custo e de prazo.', true, 2),
  ('requisitos, pois são critérios funcionais que o totem atenderá.', false, 3),
  ('exclusões, pois indicam o que vai ficar de fora do projeto.', false, 4),
  ('objetivos, pois indicam o que se espera ao final do projeto.', false, 5)
) AS o(text, is_correct, order_index);

-- Q4 | multiple_answer | difícil | O que deve ter no escopo | Exercícios 2 | corretas: A, C, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma equipe monta o escopo de um sistema para os alunos enviarem atestados que justificam faltas. Quais itens o material indica que devem constar no escopo? Assinale todas as corretas.', 'O escopo traz a descrição resumida do projeto, os módulos e requisitos, os limites e exclusões, os recursos necessários e o prazo desejado.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Escopo, Premissas e Restrições — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A descrição resumida do projeto.', true, 1),
  ('O currículo de cada desenvolvedor.', false, 2),
  ('Os módulos e requisitos do projeto.', true, 3),
  ('Os limites e exclusões do projeto.', true, 4),
  ('A pesquisa salarial do mercado.', false, 5)
) AS o(text, is_correct, order_index);

-- Q5 | single_choice | difícil | Premissas | Exercícios 2 | b1: Premissas, b2: prova, b3: Restrições, b4: escopo
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', '{{b1}} são fatores assumidos como verdadeiros para fins de planejamento, sem necessidade de {{b2}}. {{b3}} são limitações que comprometem a execução de um trabalho; normalmente as principais são o prazo, o {{b4}} e os custos.', 'Premissas são assumidas como verdadeiras, reais ou certas, sem prova ou demonstração. Restrições são limitações impostas, e as principais são prazo, escopo e custos.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Escopo, Premissas e Restrições — Exercícios 2: Aplicação'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'Restrições', false, 1), ('b1', 'Premissas', true, 2), ('b1', 'Requisitos', false, 3),
  ('b2', 'prova', true, 1), ('b2', 'prazo', false, 2), ('b2', 'escopo', false, 3),
  ('b3', 'Restrições', true, 1), ('b3', 'Premissas', false, 2), ('b3', 'Exclusões', false, 3),
  ('b4', 'objetivo', false, 1), ('b4', 'contexto', false, 2), ('b4', 'escopo', true, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q6 | multiple_choice | difícil | O que deve ter no escopo | Exercícios 2 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'O macro cronograma de um projeto prevê: levantamento de requisitos, 20 dias; desenvolvimento, 45 dias; testes e homologação, 10 dias; implantação, 2 dias; acompanhamento pós-implantação, 2 dias. Se os testes e a homologação dobrarem de duração, qual passa a ser a duração total?', 'O total original é 20 + 45 + 10 + 2 + 2 = 79 dias úteis. Dobrar os testes e a homologação acrescenta 10 dias: 79 + 10 = 89 dias úteis.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Escopo, Premissas e Restrições — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('89 dias úteis', true, 1),
  ('79 dias úteis', false, 2),
  ('84 dias úteis', false, 3),
  ('99 dias úteis', false, 4),
  ('81 dias úteis', false, 5)
) AS o(text, is_correct, order_index);

-- Q7 | drag_and_drop | difícil | Premissas | Exercícios 2 | s1: premissa, s2: restrição, s3: item incluído, s4: item excluído
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Classifique os itens registrados no escopo de um projeto. "Cada loja terá energia elétrica de 110 V disponível": {{s1}}. "O orçamento máximo é de R$ 20 milhões": {{s2}}. "Será entregue apenas o módulo web": {{s3}}. "O aplicativo não faz parte do projeto": {{s4}}.', 'A energia disponível é assumida como verdadeira (premissa); o orçamento é uma limitação imposta (restrição); o módulo web é o que está incluído e o aplicativo é o que foi excluído.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Escopo, Premissas e Restrições — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('item incluído', 1), ('objetivo', 2), ('item excluído', 3), ('justificativa', 4), ('premissa', 5), ('restrição', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'premissa', 1), ('s2', 'restrição', 2), ('s3', 'item incluído', 3), ('s4', 'item excluído', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q8 | multiple_choice | fácil | Os elementos da documentação | Exercícios 1 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Segundo o material, o objetivo de um projeto precisa ser:', 'O objetivo é aquilo que se espera ao final do projeto: precisa ser sucinto e tem que ser SMART.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Escopo, Premissas e Restrições — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('dissertativo e cheio de dados e fatos.', false, 1),
  ('detalhado, com módulos e requisitos.', false, 2),
  ('convincente, um argumento certeiro.', false, 3),
  ('abrangente, com premissas e limites.', false, 4),
  ('sucinto e seguir o critério SMART.', true, 5)
) AS o(text, is_correct, order_index);

-- Q9 | multiple_answer | super difícil | Os elementos da documentação | Exercícios 3 | corretas: B, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Um analista revisa a documentação de um projeto e confere a seção de escopo. Segundo o material, o que vale para o escopo? Assinale todas as corretas.', 'O escopo declara atividades, recursos e requisitos, apresenta também o que não será feito e contém as premissas e as restrições. As demais descrevem contexto, justificativa e objetivo.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Escopo, Premissas e Restrições — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('É um texto dissertativo que apresenta o cenário.', false, 1),
  ('Apresenta também aquilo que não será feito.', true, 2),
  ('É o argumento que convence a fazer o projeto.', false, 3),
  ('Deve ser sucinto e seguir o critério SMART.', false, 4),
  ('Contém as premissas e as restrições do projeto.', true, 5)
) AS o(text, is_correct, order_index);

-- Q10 | multiple_choice | média | Restrições | Exercícios 1 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma prefeitura contrata um portal de serviços e determina que ele entre no ar antes do início das matrículas escolares. Para a equipe do projeto, essa determinação é:', 'Uma data imposta pelo cliente é uma limitação de prazo que compromete a execução: é uma restrição, das quais as principais são prazo, escopo e custos.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Escopo, Premissas e Restrições — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('uma premissa, pois é assumida como verdadeira.', false, 1),
  ('um requisito, pois é um critério funcional.', false, 2),
  ('uma restrição, pois é uma limitação de prazo.', true, 3),
  ('uma exclusão, pois fica de fora do escopo.', false, 4),
  ('um épico, pois agrupa diversas features.', false, 5)
) AS o(text, is_correct, order_index);

-- Q11 | single_choice | super difícil | O que deve ter no escopo | Exercícios 3 | b1: limites e exclusões, b2: mal-entendidos, b3: macro cronograma, b4: interdependências
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'No escopo, a seção de {{b1}} especifica o que está incluído e o que está fora do projeto, para evitar {{b2}}. Já o {{b3}} apresenta as principais fases com durações e datas, o que permite acompanhar o progresso, identificar {{b4}} e antecipar possíveis atrasos.', 'Limites e exclusões evitam mal-entendidos sobre o que faz parte do projeto. O macro cronograma mostra fases, durações e datas, e ajuda a identificar interdependências e atrasos.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Escopo, Premissas e Restrições — Exercícios 3: Desafio'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'módulos e requisitos', false, 1), ('b1', 'limites e exclusões', true, 2), ('b1', 'recursos necessários', false, 3),
  ('b2', 'custos', false, 1), ('b2', 'premissas', false, 2), ('b2', 'mal-entendidos', true, 3),
  ('b3', 'macro cronograma', true, 1), ('b3', 'épico', false, 2), ('b3', 'backlog', false, 3),
  ('b4', 'justificativas', false, 1), ('b4', 'interdependências', true, 2), ('b4', 'exclusões', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q12 | drag_and_drop | fácil | Os elementos da documentação | Exercícios 1 | s1: contexto, s2: objetivo, s3: justificativa, s4: escopo
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Na documentação de um projeto, o {{s1}} explica o que envolve o projeto; o {{s2}} diz o que se quer alcançar; a {{s3}} convence de que vale a pena; e o {{s4}} define a abrangência e os limites.', 'O contexto apresenta o cenário, o objetivo é o que se espera ao final, a justificativa é o argumento convincente e o escopo declara o que será e o que não será feito.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Escopo, Premissas e Restrições — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('justificativa', 1), ('cronograma', 2), ('contexto', 3), ('objetivo', 4), ('escopo', 5), ('premissa', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'contexto', 1), ('s2', 'objetivo', 2), ('s3', 'justificativa', 3), ('s4', 'escopo', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q13 | multiple_choice | super difícil | Premissas | Exercícios 3 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma empresa vai instalar câmeras inteligentes em 40 filiais. No planejamento, a equipe registrou: "cada filial terá um responsável no local durante a instalação". Semanas depois, uma filial não disponibiliza ninguém e a instalação atrasa. O que o caso ilustra?', 'Ter um responsável no local foi assumido como verdadeiro para planejar, sem prova: é uma premissa. Como não se confirmou, o plano foi afetado.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Escopo, Premissas e Restrições — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Uma restrição que foi imposta à equipe pelo cliente.', false, 1),
  ('Uma premissa que se mostrou falsa durante o projeto.', true, 2),
  ('Uma exclusão que foi registrada no escopo por engano.', false, 3),
  ('Um requisito detalhado que não tinha sido validado.', false, 4),
  ('Um objetivo que não seguia nenhum critério SMART.', false, 5)
) AS o(text, is_correct, order_index);

-- Q14 | multiple_answer | super difícil | WBS e backlog ágil: terminologias | Exercícios 3 | corretas: A, C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'No escopo de um projeto no sistema acadêmico, "Módulo Requerimentos" e "Upload de atestado" aparecem em níveis diferentes: o segundo é um requisito do primeiro. Comparando com o modelo ágil, o que é correto? Assinale todas as corretas.', 'O módulo do WBS equivale ao épico do modelo ágil, e o requisito equivale à feature. A história do usuário corresponde ao requisito detalhado.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Escopo, Premissas e Restrições — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('"Módulo Requerimentos" equivale a um épico.', true, 1),
  ('"Upload de atestado" equivale a um épico.', false, 2),
  ('"Upload de atestado" equivale a uma feature.', true, 3),
  ('"Módulo Requerimentos" equivale a uma feature.', false, 4)
) AS o(text, is_correct, order_index);

-- Q15 | drag_and_drop | super difícil | O que deve ter no escopo | Exercícios 3 | s1: levantamento de requisitos, s2: desenvolvimento, s3: testes e homologação, s4: implantação
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Ordene as etapas do macro cronograma de exemplo, que soma 79 dias úteis: {{s1}} (20 dias) → {{s2}} (45 dias) → {{s3}} (10 dias) → {{s4}} (2 dias) → acompanhamento pós-implantação (2 dias).', 'O exemplo começa pelo levantamento de requisitos (20 dias), segue com desenvolvimento (45), testes e homologação (10), implantação (2) e acompanhamento pós-implantação (2).'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Escopo, Premissas e Restrições — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('levantamento de requisitos', 1), ('encerramento', 2), ('testes e homologação', 3), ('implantação', 4), ('planejamento', 5), ('desenvolvimento', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'levantamento de requisitos', 1), ('s2', 'desenvolvimento', 2), ('s3', 'testes e homologação', 3), ('s4', 'implantação', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- 8. Conferência: aborta se alguma questão ficou fora das listas ou alguma lista ficou vazia
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM questions q
    JOIN topics t ON t.id = q.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 3
      AND NOT EXISTS (
        SELECT 1 FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
        WHERE qq.question_id = q.id AND z.kind = 'exercise'
      )
  ) THEN
    RAISE EXCEPTION 'Há questão da aula 3 de Tecnologia da Informação fora das listas de exercícios';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM quizzes z
    JOIN topics t ON t.id = z.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 3 AND z.kind = 'exercise'
      AND NOT EXISTS (SELECT 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  ) THEN
    RAISE EXCEPTION 'Há lista de exercícios da aula 3 de Tecnologia da Informação sem questões';
  END IF;
END $$;

-- =====================================================================
-- AULA 4 — Requisitos e Backlog (TI-Sprint 1-Aula 04.pdf)
-- =====================================================================

-- 1. Disciplina
INSERT INTO subjects (name, short_label)
SELECT 'Tecnologia da Informação', 'TI'
WHERE NOT EXISTS (SELECT 1 FROM subjects WHERE name = 'Tecnologia da Informação');

-- 2. Assunto
INSERT INTO topics (subject_id, number, name, description)
SELECT s.id, 4, 'Requisitos e Backlog', 'O que são requisitos, como coletá-los e classificá-los com o cliente, como organizá-los em um backlog e como estruturar um bom prompt para a IA.'
FROM subjects s
WHERE s.name = 'Tecnologia da Informação'
ON CONFLICT DO NOTHING;

-- 3. Trava: aborta se a aula não existir ou já existir com outro nome
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM topics t JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 4 AND t.name = 'Requisitos e Backlog'
  ) THEN
    RAISE EXCEPTION 'A aula 4 de Tecnologia da Informação não existe ou já está cadastrada com outro nome';
  END IF;
END $$;

-- 4. Subassuntos
INSERT INTO subtopics (topic_id, name, summary, order_index)
SELECT t.id, v.name, v.summary, v.order_index
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('O que são requisitos', 'Requisitos são os elementos que detalham o escopo do projeto. Eles guiam o que deve ser entregue, como deve funcionar e quais critérios devem ser atendidos.', 1),
  ('Coleta de requisitos', 'Coletar requisitos é identificar, entender e documentar as necessidades das partes interessadas. O trabalho vai da entrevista com os usuários até a validação da lista com o cliente.', 2),
  ('Classificação dos requisitos', 'Classificar os requisitos pela importância para o negócio ajuda a priorizar as entregas. Os três níveis são essencial, importante e desejável.', 3),
  ('Backlog', 'O backlog é a pilha de trabalho que aguarda para ser processada: uma lista organizada de requisitos pendentes. Precisa estar sempre organizado e bem escrito.', 4),
  ('Prompts: como pedir à IA', 'Um prompt é como um pedido na lanchonete: quanto mais vago, mais genérica a resposta. Estruturar o pedido em papel, tarefa, objetivo e detalhes melhora o resultado.', 5)
) AS v(name, summary, order_index)
WHERE s.name = 'Tecnologia da Informação' AND t.number = 4
ON CONFLICT DO NOTHING;

-- 5. Pontos-chave
INSERT INTO subtopic_key_points (subtopic_id, text, order_index)
SELECT st.id, v.text, v.order_index
FROM subtopics st
JOIN topics t ON t.id = st.topic_id
JOIN subjects s ON s.id = t.subject_id
JOIN (VALUES
  ('O que são requisitos', 'Requisitos detalham o escopo e definem o que deve ser entregue, como deve funcionar e quais critérios devem ser atendidos.', 1),
  ('O que são requisitos', 'Estabelecem o caminho do projeto, as funcionalidades esperadas e os padrões de qualidade e desempenho.', 2),
  ('O que são requisitos', 'Incluem detalhes técnicos, desejos do cliente e o que deve estar presente (ou não) no resultado final.', 3),
  ('O que são requisitos', 'Transformam uma ideia em algo concreto, mensurável e possível de ser desenvolvido com clareza e controle.', 4),
  ('Coleta de requisitos', 'Coleta de requisitos: processo de identificar, entender e documentar as necessidades das partes interessadas para alcançar os objetivos do projeto.', 1),
  ('Coleta de requisitos', 'Os requisitos devem ser obtidos com clareza diretamente com os envolvidos, analisados cuidadosamente e registrados de forma detalhada.', 2),
  ('Coleta de requisitos', 'Passos: entrevistar os usuários, observar o processo e considerar o contexto; documentar, classificar e apresentar ao cliente; validar e formalizar a lista e o escopo.', 3),
  ('Coleta de requisitos', 'Segundo o Gartner Group, 70% das falhas em projetos estão relacionadas a problemas com os requisitos.', 4),
  ('Coleta de requisitos', 'Problemas típicos: falta de clareza, mudanças mal gerenciadas ou entendimento incorreto.', 5),
  ('Classificação dos requisitos', 'Essencial: sem este requisito a solução não pode ser entregue. Ex.: o e-commerce permitir o cadastro e o pagamento de pedidos.', 1),
  ('Classificação dos requisitos', 'Importante: a solução pode ser entregue sem ele, mas é um diferencial significativo. Ex.: cálculo automático de frete.', 2),
  ('Classificação dos requisitos', 'Desejável: acrescenta valor, mas não tem impacto imediato e pode ser implementado futuramente. Ex.: recomendações personalizadas.', 3),
  ('Classificação dos requisitos', 'Classificar ajuda a priorizar entregas e a compreender o impacto de cada requisito para o negócio.', 4),
  ('Backlog', 'Backlog: registro acumulado de tarefas, demandas ou pedidos que ainda não foram concluídos.', 1),
  ('Backlog', 'Funciona como um repositório de requisitos, uma pilha de itens a serem feitos e entregues após desenvolvidos.', 2),
  ('Backlog', 'Deve estar sempre organizado e classificado, e pode conter itens em estado bruto ou já detalhados e refinados.', 3),
  ('Backlog', 'Um backlog mal escrito às vezes é pior do que não ter nenhum: seguir na direção errada só se descobre depois de percorrido o caminho.', 4),
  ('Prompts: como pedir à IA', 'Dizer só "quero comida" no balcão pode trazer qualquer coisa, até algo de que você não goste ou não consiga pagar.', 1),
  ('Prompts: como pedir à IA', 'Um pedido vago à IA gera uma resposta genérica, que devolve perguntas em vez de resolver.', 2),
  ('Prompts: como pedir à IA', 'Estrutura do prompt: papel, tarefa, objetivo e detalhes.', 3)
) AS v(subtopic_name, text, order_index) ON v.subtopic_name = st.name
WHERE s.name = 'Tecnologia da Informação' AND t.number = 4
ON CONFLICT DO NOTHING;

-- 6. Listas de exercícios
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT v.title, 'exercise', t.subject_id, t.id, NULL, v.difficulty::difficulty_level
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Requisitos e Backlog — Exercícios 1: Fundamentos', 'easy'),
  ('Requisitos e Backlog — Exercícios 2: Aplicação', 'medium'),
  ('Requisitos e Backlog — Exercícios 3: Desafio', 'hard')
) AS v(title, difficulty)
WHERE s.name = 'Tecnologia da Informação' AND t.number = 4
  AND NOT EXISTS (SELECT 1 FROM quizzes z WHERE z.title = v.title);

-- 7. Questões

-- Q1 | multiple_choice | fácil | O que são requisitos | Exercícios 1 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'O que são os requisitos de um projeto?', 'Os requisitos são os elementos que detalham o escopo do projeto e funcionam como um guia para definir o que deve ser entregue, como deve funcionar e quais critérios atender.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Requisitos e Backlog — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Os fatores assumidos como verdadeiros no planejamento.', false, 1),
  ('As limitações de prazo e de custo impostas ao projeto.', false, 2),
  ('Os elementos que detalham o escopo e guiam a entrega.', true, 3),
  ('As tarefas que já foram concluídas e entregues ao time.', false, 4),
  ('Os argumentos que justificam a realização do projeto.', false, 5)
) AS o(text, is_correct, order_index);

-- Q2 | multiple_choice | média | Classificação dos requisitos | Exercícios 1 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Em um e-commerce, o cálculo automático de frete pode ficar fora da primeira entrega, mas representa um diferencial significativo para o produto. Como classificar esse requisito?', 'Um requisito importante é aquele sem o qual a solução ainda pode ser entregue, mas que representa um diferencial significativo para o produto.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Requisitos e Backlog — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Importante: a solução sai sem ele, mas é um diferencial.', true, 1),
  ('Essencial: sem ele a solução não pode ser entregue.', false, 2),
  ('Desejável: agrega valor, mas pode ficar para o futuro.', false, 3),
  ('Restrição: é uma limitação imposta à execução do projeto.', false, 4),
  ('Premissa: é assumido como certo em todo o planejamento.', false, 5)
) AS o(text, is_correct, order_index);

-- Q3 | drag_and_drop | fácil | Classificação dos requisitos | Exercícios 1 | s1: essencial, s2: importante, s3: desejável
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Sem um requisito {{s1}}, a solução não pode ser entregue. Um requisito {{s2}} é um diferencial significativo, mas a solução pode sair sem ele. Um requisito {{s3}} acrescenta valor e pode ser implementado futuramente.', 'Essencial é indispensável para o funcionamento mínimo; importante é um diferencial significativo; desejável acrescenta valor, sem impacto imediato.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Requisitos e Backlog — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('essencial', 1), ('importante', 2), ('opcional', 3), ('desejável', 4), ('urgente', 5)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'essencial', 1), ('s2', 'importante', 2), ('s3', 'desejável', 3))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q4 | multiple_answer | difícil | Coleta de requisitos | Exercícios 2 | corretas: A, B, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma consultoria vai levantar os requisitos de um sistema de agendamento para uma clínica. Segundo o material, como os requisitos devem ser tratados na coleta? Assinale todas as corretas.', 'Os requisitos devem ser obtidos com clareza diretamente com os envolvidos, analisados cuidadosamente e registrados de forma detalhada, para serem medidos e acompanhados.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Requisitos e Backlog — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Obtidos com clareza, diretamente com os envolvidos.', true, 1),
  ('Analisados para garantir que fazem sentido no projeto.', true, 2),
  ('Deduzidos pela equipe, sem consulta aos usuários.', false, 3),
  ('Registrados em detalhe, para serem acompanhados.', true, 4),
  ('Guardados apenas na memória de quem entrevistou.', false, 5)
) AS o(text, is_correct, order_index);

-- Q5 | single_choice | difícil | Coleta de requisitos | Exercícios 2 | b1: entrevistar, b2: classificados, b3: escopo
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Na coleta de requisitos, o primeiro passo é {{b1}} os usuários, observar o processo e considerar o contexto. Depois, os requisitos são documentados, {{b2}} e apresentados ao cliente. Por fim, a lista de requisitos e o {{b3}} são validados e formalizados com o cliente.', 'A coleta começa por entrevistar os usuários e observar o processo; segue com documentar, classificar e apresentar ao cliente; e termina com validar e formalizar a lista e o escopo.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Requisitos e Backlog — Exercícios 2: Aplicação'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'treinar', false, 1), ('b1', 'entrevistar', true, 2), ('b1', 'substituir', false, 3),
  ('b2', 'classificados', true, 1), ('b2', 'descartados', false, 2), ('b2', 'programados', false, 3),
  ('b3', 'orçamento', false, 1), ('b3', 'prompt', false, 2), ('b3', 'escopo', true, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q6 | multiple_choice | fácil | Backlog | Exercícios 1 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma equipe mantém uma lista organizada e classificada de tudo o que ainda precisa ser desenvolvido em um aplicativo, com itens em estado bruto e itens já refinados. Como essa lista é chamada?', 'O backlog é a lista organizada de tarefas ou requisitos pendentes, uma "pilha de trabalho" que aguarda para ser processada.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Requisitos e Backlog — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Cronograma, a visão das fases e das datas previstas.', false, 1),
  ('Escopo, a declaração dos limites e das exclusões.', false, 2),
  ('Premissa, o fator assumido como certo no plano.', false, 3),
  ('Requisito, o critério que a entrega deve atender.', false, 4),
  ('Backlog, a pilha de trabalho que aguarda execução.', true, 5)
) AS o(text, is_correct, order_index);

-- Q7 | multiple_choice | super difícil | Coleta de requisitos | Exercícios 3 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma criança pede um balanço em uma árvore. O gerente entende uma coisa, o arquiteto desenha outra, o programador constrói uma terceira e o cliente recebe algo de que não precisava. Segundo o material, onde está a origem mais comum desse tipo de falha?', 'Segundo o Gartner Group, 70% das falhas em projetos estão relacionadas a problemas com os requisitos, como falta de clareza, mudanças mal gerenciadas ou entendimento incorreto.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Requisitos e Backlog — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Na escolha da ferramenta de gestão usada pela equipe.', false, 1),
  ('Em problemas com requisitos, como entendimento errado.', true, 2),
  ('No orçamento máximo definido pelo cliente no início.', false, 3),
  ('Na falta de um backlog com itens em estado bruto.', false, 4),
  ('No prazo curto para os testes de carga do produto.', false, 5)
) AS o(text, is_correct, order_index);

-- Q8 | drag_and_drop | difícil | Prompts: como pedir à IA | Exercícios 2 | s1: Papel, s2: Tarefa, s3: Objetivo, s4: Detalhes
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Identifique cada parte de um prompt bem estruturado. {{s1}}: "Sou um vendedor e estou com pressa." {{s2}}: "Me recomende um lanche nutritivo com no máximo 500 calorias." {{s3}}: "Preciso almoçar rápido, pois tenho uma reunião em 20 minutos." {{s4}}: "Deixe tudo pronto para viagem e use o molho de mostarda."', 'O papel diz quem está pedindo, a tarefa diz o que a IA deve fazer, o objetivo explica para que serve o pedido e os detalhes trazem preferências e condições extras.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Requisitos e Backlog — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('Objetivo', 1), ('Escopo', 2), ('Premissa', 3), ('Tarefa', 4), ('Papel', 5), ('Detalhes', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'Papel', 1), ('s2', 'Tarefa', 2), ('s3', 'Objetivo', 3), ('s4', 'Detalhes', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q9 | multiple_answer | super difícil | Backlog | Exercícios 3 | corretas: B, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Um time de produto discute como manter o backlog de um sistema de reservas. Segundo o material, o que vale para o backlog? Assinale todas as corretas.', 'O backlog reúne o que ainda não foi concluído, deve estar sempre organizado e classificado, aceita itens brutos ou refinados e, se mal escrito, pode ser pior do que não ter nenhum.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Requisitos e Backlog — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Reúne apenas as tarefas concluídas no período.', false, 1),
  ('Deve estar sempre organizado e classificado.', true, 2),
  ('Só aceita itens já detalhados e refinados.', false, 3),
  ('Mal escrito, pode ser pior do que não existir.', true, 4),
  ('Dispensa requisitos, pois lista somente bugs.', false, 5)
) AS o(text, is_correct, order_index);

-- Q10 | multiple_choice | super difícil | Classificação dos requisitos | Exercícios 3 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'A equipe de um aplicativo de delivery só consegue entregar parte dos requisitos na primeira versão: (1) cadastrar e pagar pedidos; (2) exibir recomendações personalizadas de pratos; (3) calcular automaticamente a taxa de entrega. Pela classificação do material, qual é a ordem do mais para o menos prioritário?', 'Cadastrar e pagar pedidos é essencial; o cálculo automático da entrega é importante, um diferencial significativo; as recomendações personalizadas são desejáveis e podem ficar para depois.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Requisitos e Backlog — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Primeiro 2, depois 3 e por fim 1.', false, 1),
  ('Primeiro 3, depois 1 e por fim 2.', false, 2),
  ('Primeiro 2, depois 1 e por fim 3.', false, 3),
  ('Primeiro 1, depois 3 e por fim 2.', true, 4),
  ('Primeiro 3, depois 2 e por fim 1.', false, 5)
) AS o(text, is_correct, order_index);

-- Q11 | single_choice | super difícil | Coleta de requisitos | Exercícios 3 | b1: Gartner Group, b2: 70%, b3: clareza
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Segundo o {{b1}}, {{b2}} das falhas em projetos estão relacionadas a problemas com os requisitos, como falta de {{b3}}, mudanças mal gerenciadas ou entendimento incorreto.', 'O dado citado no material é do Gartner Group: 70% das falhas em projetos têm relação com requisitos, por falta de clareza, mudanças mal gerenciadas ou entendimento incorreto.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Requisitos e Backlog — Exercícios 3: Desafio'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'Gartner Group', true, 1), ('b1', 'Manifesto Ágil', false, 2), ('b1', 'Scrum Guide', false, 3),
  ('b2', '30%', false, 1), ('b2', '50%', false, 2), ('b2', '70%', true, 3),
  ('b3', 'orçamento', false, 1), ('b3', 'clareza', true, 2), ('b3', 'equipe', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q12 | multiple_choice | difícil | Prompts: como pedir à IA | Exercícios 2 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um aluno digita para a IA apenas "Qual a melhor faculdade de tecnologia?" e recebe uma resposta genérica, dizendo que tudo depende do objetivo dele. Pela analogia do material, esse prompt equivale a:', 'Prompt é como fazer um pedido em uma lanchonete: quem diz só "quero comida" pode receber qualquer coisa. É preciso detalhar o pedido com papel, tarefa, objetivo e detalhes.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Requisitos e Backlog — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('chegar ao balcão da lanchonete e dizer só "quero comida".', true, 1),
  ('pedir um lanche informando papel, tarefa, objetivo e detalhes.', false, 2),
  ('entregar um requisito desejável antes de um essencial.', false, 3),
  ('empilhar tarefas no backlog sem nenhuma classificação.', false, 4),
  ('validar a lista de requisitos com o cliente no final.', false, 5)
) AS o(text, is_correct, order_index);

-- Q13 | drag_and_drop | super difícil | Backlog | Exercícios 3 | s1: registro, s2: concluídos, s3: repositório, s4: bruto
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'O backlog é o {{s1}} acumulado de tarefas, demandas ou pedidos que ainda não foram {{s2}}. Ele funciona como um {{s3}} de requisitos e pode conter itens em estado {{s4}} ou já detalhados e refinados.', 'O backlog é o registro acumulado do que ainda não foi concluído: um repositório de requisitos, com itens em estado bruto ou já refinados.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Requisitos e Backlog — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('validados', 1), ('cronograma', 2), ('repositório', 3), ('concluídos', 4), ('bruto', 5), ('registro', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'registro', 1), ('s2', 'concluídos', 2), ('s3', 'repositório', 3), ('s4', 'bruto', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q14 | multiple_answer | difícil | O que são requisitos | Exercícios 2 | corretas: A, C, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma fintech documenta os requisitos de um aplicativo de pagamentos. Segundo o material, o que os requisitos estabelecem em um projeto? Assinale todas as corretas.', 'Os requisitos estabelecem o caminho do projeto, as funcionalidades esperadas, os padrões de qualidade e desempenho, os detalhes técnicos e o que deve estar presente ou não no resultado.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Requisitos e Backlog — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('As funcionalidades esperadas do produto.', true, 1),
  ('O salário de cada integrante da equipe.', false, 2),
  ('Os padrões de qualidade e de desempenho.', true, 3),
  ('A marca do computador usado pela equipe.', false, 4),
  ('O que deve estar ou não no resultado final.', true, 5)
) AS o(text, is_correct, order_index);

-- Q15 | drag_and_drop | média | O que são requisitos | Exercícios 1 | s1: ideia, s2: concreto, s3: mensurável, s4: controle
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Os requisitos transformam uma {{s1}} em algo {{s2}}, {{s3}} e possível de ser desenvolvido com clareza e {{s4}}.', 'Segundo o material, os requisitos transformam uma ideia em algo concreto, mensurável e possível de ser desenvolvido com clareza e controle.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Requisitos e Backlog — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('mensurável', 1), ('concreto', 2), ('controle', 3), ('genérico', 4), ('premissa', 5), ('ideia', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'ideia', 1), ('s2', 'concreto', 2), ('s3', 'mensurável', 3), ('s4', 'controle', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- 8. Conferência: aborta se alguma questão ficou fora das listas ou alguma lista ficou vazia
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM questions q
    JOIN topics t ON t.id = q.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 4
      AND NOT EXISTS (
        SELECT 1 FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
        WHERE qq.question_id = q.id AND z.kind = 'exercise'
      )
  ) THEN
    RAISE EXCEPTION 'Há questão da aula 4 de Tecnologia da Informação fora das listas de exercícios';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM quizzes z
    JOIN topics t ON t.id = z.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 4 AND z.kind = 'exercise'
      AND NOT EXISTS (SELECT 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  ) THEN
    RAISE EXCEPTION 'Há lista de exercícios da aula 4 de Tecnologia da Informação sem questões';
  END IF;
END $$;

-- =====================================================================
-- AULA 5 — Metodologias de Gestão de Projetos (TI-Sprint 2-Aula 05.pdf)
-- =====================================================================

-- 1. Disciplina
INSERT INTO subjects (name, short_label)
SELECT 'Tecnologia da Informação', 'TI'
WHERE NOT EXISTS (SELECT 1 FROM subjects WHERE name = 'Tecnologia da Informação');

-- 2. Assunto
INSERT INTO topics (subject_id, number, name, description)
SELECT s.id, 5, 'Metodologias de Gestão de Projetos', 'A diferença entre método e metodologia, o contraste entre Cascata e Scrum e as características que definem as metodologias ágeis.'
FROM subjects s
WHERE s.name = 'Tecnologia da Informação'
ON CONFLICT DO NOTHING;

-- 3. Trava: aborta se a aula não existir ou já existir com outro nome
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM topics t JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 5 AND t.name = 'Metodologias de Gestão de Projetos'
  ) THEN
    RAISE EXCEPTION 'A aula 5 de Tecnologia da Informação não existe ou já está cadastrada com outro nome';
  END IF;
END $$;

-- 4. Subassuntos
INSERT INTO subtopics (topic_id, name, summary, order_index)
SELECT t.id, v.name, v.summary, v.order_index
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Método e metodologia', 'O método é um passo a passo específico, como uma receita de bolo. A metodologia é o guarda-chuva que organiza vários métodos e práticas, como um livro de receitas.', 1),
  ('Cascata (Waterfall)', 'Na Cascata as atividades são executadas em sequência: uma tarefa só inicia quando a anterior termina. É um modelo rígido, previsível e pouco flexível a mudanças.', 2),
  ('Scrum (Ágil)', 'No Scrum o projeto é feito em pequenas partes, e o cliente dá retorno regularmente sobre o que está sendo desenvolvido. É um modelo flexível, incremental e interativo.', 3),
  ('Características das metodologias ágeis', 'As metodologias ágeis são práticas e valores para gerenciar projetos de forma adaptável, flexível e colaborativa, em contraposição às tradicionais, mais rígidas e lineares.', 4),
  ('IA: corrente de pensamento', 'Ao pedir ajuda à IA para escolher a metodologia do projeto, vale obrigá-la a pensar passo a passo e comparar as respostas de ferramentas diferentes.', 5)
) AS v(name, summary, order_index)
WHERE s.name = 'Tecnologia da Informação' AND t.number = 5
ON CONFLICT DO NOTHING;

-- 5. Pontos-chave
INSERT INTO subtopic_key_points (subtopic_id, text, order_index)
SELECT st.id, v.text, v.order_index
FROM subtopics st
JOIN topics t ON t.id = st.topic_id
JOIN subjects s ON s.id = t.subject_id
JOIN (VALUES
  ('Método e metodologia', 'Método: conjunto estruturado de práticas, técnicas e processos que guiam como planejar, executar e encerrar um projeto.', 1),
  ('Método e metodologia', 'Metodologia: conjunto estruturado de métodos, processos, regras, técnicas e ferramentas que orientam a condução de projetos de forma padronizada.', 2),
  ('Método e metodologia', 'O método ensina como fazer uma tarefa; a metodologia ensina como organizar e aplicar vários métodos.', 3),
  ('Método e metodologia', 'Benefícios do método: reduz erros, organiza o trabalho e aumenta a previsibilidade dos resultados.', 4),
  ('Método e metodologia', 'Exemplos citados: Waterfall, Project Model Canvas, ZOPP, Lean, Extreme Programming, PERT, Scrum e Kanban.', 5),
  ('Cascata (Waterfall)', 'As atividades são sequenciais, como em uma linha de produção de um carro.', 1),
  ('Cascata (Waterfall)', 'Alterações de requisitos após o início são complexas e muitas vezes exigem reiniciar etapas anteriores.', 2),
  ('Cascata (Waterfall)', 'Cada fase é concluída uma única vez e em sequência.', 3),
  ('Cascata (Waterfall)', 'Características: fases bem definidas, resistência a mudanças, foco no produto final planejado, preditividade e testes sólidos.', 4),
  ('Cascata (Waterfall)', 'Há hierarquia, comando e reporte, e o cliente está presente em fases específicas.', 5),
  ('Scrum (Ágil)', 'O projeto é desenvolvido de forma segmentada e incremental, com ajustes contínuos.', 1),
  ('Scrum (Ágil)', 'Requisitos podem ser alterados a qualquer momento, inclusive após o início do projeto.', 2),
  ('Scrum (Ágil)', 'O desenvolvimento é interativo e pode repetir etapas quando necessário.', 3),
  ('Scrum (Ágil)', 'Características: fases empíricas, flexibilidade, adaptabilidade, desenvolvimento enxuto e foco no MVP (produto mínimo viável).', 4),
  ('Scrum (Ágil)', 'O cliente está presente o tempo todo e a correção acontece em tempo real.', 5),
  ('Características das metodologias ágeis', 'Ciclos curtos: projeto dividido em sprints de poucas semanas, com entregas de incrementos funcionais.', 1),
  ('Características das metodologias ágeis', 'Foco no valor: priorização contínua das funcionalidades que geram maior valor ao cliente.', 2),
  ('Características das metodologias ágeis', 'Flexibilidade: planejamento dinâmico e adaptável às mudanças de mercado e às necessidades do negócio.', 3),
  ('Características das metodologias ágeis', 'Comunicação frequente e cultura de colaboração: diálogo constante e transparente, com equipe auto-organizada e orientada a soluções.', 4),
  ('Características das metodologias ágeis', 'Melhoria contínua: avaliação e otimização frequente dos processos para elevar a qualidade do produto.', 5),
  ('IA: corrente de pensamento', 'Chain-of-Thought (corrente de pensamento): técnica de prompt que obriga a IA a pensar passo a passo.', 1),
  ('IA: corrente de pensamento', 'Usar IAs diferentes e comparar as respostas ajuda a avaliar a qualidade do resultado.', 2)
) AS v(subtopic_name, text, order_index) ON v.subtopic_name = st.name
WHERE s.name = 'Tecnologia da Informação' AND t.number = 5
ON CONFLICT DO NOTHING;

-- 6. Listas de exercícios
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT v.title, 'exercise', t.subject_id, t.id, NULL, v.difficulty::difficulty_level
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Metodologias de Gestão de Projetos — Exercícios 1: Fundamentos', 'easy'),
  ('Metodologias de Gestão de Projetos — Exercícios 2: Aplicação', 'medium'),
  ('Metodologias de Gestão de Projetos — Exercícios 3: Desafio', 'hard')
) AS v(title, difficulty)
WHERE s.name = 'Tecnologia da Informação' AND t.number = 5
  AND NOT EXISTS (SELECT 1 FROM quizzes z WHERE z.title = v.title);

-- 7. Questões

-- Q1 | multiple_choice | fácil | Método e metodologia | Exercícios 1 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Na analogia do material, a receita de um bolo de chocolate representa:', 'A receita é o método: um passo a passo específico que garante que uma tarefa seja executada corretamente. O livro de receitas completo é a metodologia.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 5
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologias de Gestão de Projetos — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('a metodologia, que reúne várias receitas e técnicas.', false, 1),
  ('o método, um passo a passo específico de uma tarefa.', true, 2),
  ('o MVP, a menor versão do produto que já tem valor.', false, 3),
  ('a sprint, um ciclo curto com entrega incremental.', false, 4),
  ('o backlog, a lista de itens que aguardam execução.', false, 5)
) AS o(text, is_correct, order_index);

-- Q2 | drag_and_drop | média | Método e metodologia | Exercícios 1 | s1: Método, s2: Metodologia, s3: guarda-chuva
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', '{{s1}} é como uma receita de bolo: ensina como fazer uma tarefa. {{s2}} é como um livro de receitas completo: reúne vários métodos, técnicas e boas práticas, funcionando como um {{s3}}.', 'O método é um caminho específico; a metodologia é o "guarda-chuva" que organiza vários métodos e práticas para diferentes situações.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 5
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologias de Gestão de Projetos — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('cronograma', 1), ('Sprint', 2), ('Método', 3), ('guarda-chuva', 4), ('Metodologia', 5)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'Método', 1), ('s2', 'Metodologia', 2), ('s3', 'guarda-chuva', 3))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q3 | multiple_choice | difícil | Cascata (Waterfall) | Exercícios 2 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma montadora planeja a linha de produção de um novo carro: cada etapa só começa quando a anterior termina, e mudar o projeto depois do início exigiria refazer etapas. Qual abordagem descreve esse cenário?', 'Na Cascata as atividades são executadas sequencialmente e uma tarefa só inicia quando a anterior termina. A linha de produção de um carro é o exemplo do material.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 5
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologias de Gestão de Projetos — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Scrum, pois o trabalho é segmentado e incremental.', false, 1),
  ('Ágil, pois os requisitos mudam a qualquer momento.', false, 2),
  ('MVP, pois a entrega é o produto mínimo viável.', false, 3),
  ('Empírica, pois se baseia em observar e adaptar.', false, 4),
  ('Cascata, pois as etapas são lineares e sequenciais.', true, 5)
) AS o(text, is_correct, order_index);

-- Q4 | multiple_answer | difícil | Scrum (Ágil) | Exercícios 2 | corretas: A, C, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma startup de mobilidade urbana adota o Scrum para desenvolver seu aplicativo. Que características do modelo ela deve esperar? Assinale todas as corretas.', 'O Scrum é segmentado e incremental, permite alterar requisitos a qualquer momento e pode repetir etapas. Fases únicas em sequência e cliente em fases específicas são da Cascata.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 5
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologias de Gestão de Projetos — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Desenvolvimento segmentado e incremental.', true, 1),
  ('Cada fase concluída uma única vez, em ordem.', false, 2),
  ('Requisitos alteráveis mesmo após o início.', true, 3),
  ('Cliente presente só em fases específicas.', false, 4),
  ('Possibilidade de repetir etapas se preciso.', true, 5)
) AS o(text, is_correct, order_index);

-- Q5 | single_choice | difícil | Cascata (Waterfall) | Exercícios 2 | b1: Cascata, b2: uma única vez, b3: Scrum, b4: MVP
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'No modelo {{b1}}, alterar requisitos após o início do projeto é complexo e pode exigir reiniciar etapas, pois cada fase é concluída {{b2}}. No modelo {{b3}}, o foco está no {{b4}} e o cliente está presente o tempo todo.', 'A Cascata é rígida: cada fase é concluída uma única vez e em sequência. O Scrum é flexível, tem foco no MVP (produto mínimo viável) e mantém o cliente presente o tempo todo.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 5
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologias de Gestão de Projetos — Exercícios 2: Aplicação'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'Scrum', false, 1), ('b1', 'Cascata', true, 2), ('b1', 'Ágil', false, 3),
  ('b2', 'uma única vez', true, 1), ('b2', 'várias vezes', false, 2), ('b2', 'em paralelo', false, 3),
  ('b3', 'Cascata', false, 1), ('b3', 'Waterfall', false, 2), ('b3', 'Scrum', true, 3),
  ('b4', 'produto final planejado', false, 1), ('b4', 'MVP', true, 2), ('b4', 'comando e reporte', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q6 | multiple_choice | média | Características das metodologias ágeis | Exercícios 1 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma equipe ágil divide o projeto em sprints de poucas semanas, e cada uma termina com a entrega de um incremento que já funciona. Que característica das metodologias ágeis esse modo de trabalhar descreve?', 'Ciclos curtos: o projeto é dividido em sprints de poucas semanas, com entregas de incrementos funcionais.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 5
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologias de Gestão de Projetos — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Ciclos curtos, com entregas de incrementos funcionais.', true, 1),
  ('Foco no valor, com priorização do que vale mais.', false, 2),
  ('Melhoria contínua, com otimização dos processos.', false, 3),
  ('Comunicação frequente, com diálogo transparente.', false, 4),
  ('Cultura de colaboração, com uma equipe auto-organizada.', false, 5)
) AS o(text, is_correct, order_index);

-- Q7 | drag_and_drop | difícil | Cascata (Waterfall) | Exercícios 2 | s1: em fases específicas, s2: resistência, s3: o tempo todo, s4: em tempo real
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Compare os dois modelos. Na Cascata, o cliente está presente {{s1}} e há {{s2}} a mudanças. No modelo ágil, o cliente está presente {{s3}} e a correção acontece {{s4}}.', 'Na Cascata o cliente participa de fases específicas e há resistência a mudanças. No ágil o cliente está presente o tempo todo e a correção é feita em tempo real.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 5
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologias de Gestão de Projetos — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('em fases específicas', 1), ('apenas na entrega', 2), ('em tempo real', 3), ('o tempo todo', 4), ('resistência', 5), ('indiferença', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'em fases específicas', 1), ('s2', 'resistência', 2), ('s3', 'o tempo todo', 3), ('s4', 'em tempo real', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q8 | multiple_choice | super difícil | Scrum (Ágil) | Exercícios 3 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Em uma dinâmica, o cliente descreve a tela de um aplicativo durante 5 minutos e o desenvolvedor a desenha sozinho, sem falar com ele. Em outra, os dois conversam a cada 2 minutos para corrigir o desenho. A que modelos as dinâmicas correspondem, nessa ordem?', 'Sem interação durante a construção, o trabalho segue em sequência, como na Cascata. Com correções em intervalos curtos, o cliente dá retorno regular, como no Scrum.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 5
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologias de Gestão de Projetos — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Ágil e Cascata, pois a primeira tem mais correções.', false, 1),
  ('Cascata e Cascata, pois as duas têm etapas definidas.', false, 2),
  ('Ágil e Ágil, pois as duas entregam uma tela de app.', false, 3),
  ('Cascata e Ágil, pois só a segunda tem retorno regular.', true, 4),
  ('Método e metodologia, pois a segunda inclui a primeira.', false, 5)
) AS o(text, is_correct, order_index);

-- Q9 | multiple_answer | super difícil | Método e metodologia | Exercícios 3 | corretas: B, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Um coordenador explica à equipe a diferença entre método e metodologia antes de escolher como conduzir os projetos da área. Segundo o material, o que é correto? Assinale todas as corretas.', 'A metodologia é o guarda-chuva que organiza vários métodos e orienta a condução de projetos de forma padronizada. O método é o passo a passo de uma tarefa, como a receita de bolo.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 5
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologias de Gestão de Projetos — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('O método organiza várias metodologias diferentes.', false, 1),
  ('A metodologia é o guarda-chuva de vários métodos.', true, 2),
  ('O método é como um livro de receitas completo.', false, 3),
  ('A metodologia orienta projetos de forma padronizada.', true, 4),
  ('A metodologia é o passo a passo de uma só tarefa.', false, 5)
) AS o(text, is_correct, order_index);

-- Q10 | multiple_choice | fácil | Características das metodologias ágeis | Exercícios 1 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'As metodologias ágeis se contrapõem às metodologias tradicionais porque estas geralmente são:', 'As metodologias ágeis gerenciam projetos de forma adaptável, flexível e colaborativa, em contraposição às tradicionais, que geralmente são mais rígidas e lineares.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 5
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologias de Gestão de Projetos — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('mais adaptáveis e abertas.', false, 1),
  ('mais curtas e incrementais.', false, 2),
  ('mais rígidas e lineares.', true, 3),
  ('mais flexíveis e empíricas.', false, 4),
  ('mais enxutas e autônomas.', false, 5)
) AS o(text, is_correct, order_index);

-- Q11 | single_choice | super difícil | Características das metodologias ágeis | Exercícios 3 | b1: foco no valor, b2: cliente, b3: melhoria contínua, b4: transparente
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Nas metodologias ágeis, o {{b1}} é a priorização contínua das funcionalidades que geram maior valor ao {{b2}}; a {{b3}} é a avaliação e otimização frequente dos processos; e a comunicação frequente é um diálogo constante e {{b4}} entre equipe, clientes e partes interessadas.', 'Foco no valor prioriza o que gera mais valor ao cliente; melhoria contínua otimiza os processos para elevar a qualidade; a comunicação frequente é um diálogo constante e transparente.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 5
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologias de Gestão de Projetos — Exercícios 3: Desafio'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'ciclo curto', false, 1), ('b1', 'foco no valor', true, 2), ('b1', 'comando e reporte', false, 3),
  ('b2', 'cliente', true, 1), ('b2', 'gerente', false, 2), ('b2', 'desenvolvedor', false, 3),
  ('b3', 'flexibilidade', false, 1), ('b3', 'cultura de colaboração', false, 2), ('b3', 'melhoria contínua', true, 3),
  ('b4', 'formal', false, 1), ('b4', 'transparente', true, 2), ('b4', 'esporádico', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q12 | drag_and_drop | super difícil | Características das metodologias ágeis | Exercícios 3 | s1: ciclos curtos, s2: flexibilidade, s3: cultura de colaboração, s4: melhoria contínua
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Associe cada descrição à característica ágil. Sprints de poucas semanas: {{s1}}. Planejamento dinâmico e adaptável às mudanças de mercado: {{s2}}. Trabalho em equipe auto-organizado e orientado a soluções: {{s3}}. Avaliação e otimização frequente dos processos: {{s4}}.', 'Sprints curtas são os ciclos curtos; o planejamento dinâmico é a flexibilidade; a equipe auto-organizada é a cultura de colaboração; otimizar os processos é a melhoria contínua.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 5
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologias de Gestão de Projetos — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('hierarquia', 1), ('ciclos curtos', 2), ('flexibilidade', 3), ('melhoria contínua', 4), ('preditividade', 5), ('cultura de colaboração', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'ciclos curtos', 1), ('s2', 'flexibilidade', 2), ('s3', 'cultura de colaboração', 3), ('s4', 'melhoria contínua', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q13 | multiple_choice | difícil | IA: corrente de pensamento | Exercícios 2 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um grupo pede a uma IA que escolha a metodologia do projeto e exige que ela explique o raciocínio etapa por etapa antes de concluir. Como se chama essa técnica de prompt?', 'Chain-of-Thought, ou corrente de pensamento, é a técnica de obrigar a IA a pensar passo a passo antes de chegar à resposta.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 5
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologias de Gestão de Projetos — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Minimum Viable Product, o produto mínimo viável.', false, 1),
  ('Chain-of-Thought, a corrente de pensamento.', true, 2),
  ('Work Breakdown Structure, a estrutura analítica.', false, 3),
  ('Large Language Model, o modelo de linguagem.', false, 4),
  ('Project Model Canvas, o quadro do projeto.', false, 5)
) AS o(text, is_correct, order_index);

-- Q14 | multiple_answer | super difícil | Cascata (Waterfall) | Exercícios 3 | corretas: A, B, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Um órgão público exige de seu fornecedor um projeto com fases bem definidas e alta previsibilidade. Quais são características da Cascata segundo o material? Assinale todas as corretas.', 'A Cascata tem hierarquia, comando e reporte, foco no produto final planejado, preditividade e testes sólidos. Fases empíricas e foco no MVP são do modelo ágil.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 5
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologias de Gestão de Projetos — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Hierarquia, comando e reporte.', true, 1),
  ('Foco no produto final planejado.', true, 2),
  ('Fases empíricas e adaptáveis.', false, 3),
  ('Foco no produto mínimo viável.', false, 4),
  ('Testes sólidos e preditividade.', true, 5)
) AS o(text, is_correct, order_index);

-- Q15 | drag_and_drop | fácil | Método e metodologia | Exercícios 1 | s1: previsível, s2: ordem, s3: imprevisível
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Quem segue um método obtém um resultado {{s1}}, pois usa os ingredientes corretos, a quantidade certa e a {{s2}} das etapas. Quem trabalha sem método obtém um resultado {{s3}}.', 'Seguir a receita, com ingredientes, quantidades, ordem das etapas e tempo adequados, leva a um resultado previsível. Sem receita, as etapas ficam desorganizadas e o resultado é imprevisível.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 5
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologias de Gestão de Projetos — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('incremental', 1), ('prioridade', 2), ('imprevisível', 3), ('ordem', 4), ('previsível', 5)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'previsível', 1), ('s2', 'ordem', 2), ('s3', 'imprevisível', 3))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- 8. Conferência: aborta se alguma questão ficou fora das listas ou alguma lista ficou vazia
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM questions q
    JOIN topics t ON t.id = q.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 5
      AND NOT EXISTS (
        SELECT 1 FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
        WHERE qq.question_id = q.id AND z.kind = 'exercise'
      )
  ) THEN
    RAISE EXCEPTION 'Há questão da aula 5 de Tecnologia da Informação fora das listas de exercícios';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM quizzes z
    JOIN topics t ON t.id = z.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 5 AND z.kind = 'exercise'
      AND NOT EXISTS (SELECT 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  ) THEN
    RAISE EXCEPTION 'Há lista de exercícios da aula 5 de Tecnologia da Informação sem questões';
  END IF;
END $$;

-- =====================================================================
-- AULA 6 — Metodologia Ágil: Scrum (TI-Sprint 2-Aula 06.pdf)
-- =====================================================================

-- 1. Disciplina
INSERT INTO subjects (name, short_label)
SELECT 'Tecnologia da Informação', 'TI'
WHERE NOT EXISTS (SELECT 1 FROM subjects WHERE name = 'Tecnologia da Informação');

-- 2. Assunto
INSERT INTO topics (subject_id, number, name, description)
SELECT s.id, 6, 'Metodologia Ágil: Scrum', 'A origem e a ideia central do Scrum, os papéis de Product Owner, Scrum Master, time e cliente, e as boas práticas do framework.'
FROM subjects s
WHERE s.name = 'Tecnologia da Informação'
ON CONFLICT DO NOTHING;

-- 3. Trava: aborta se a aula não existir ou já existir com outro nome
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM topics t JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 6 AND t.name = 'Metodologia Ágil: Scrum'
  ) THEN
    RAISE EXCEPTION 'A aula 6 de Tecnologia da Informação não existe ou já está cadastrada com outro nome';
  END IF;
END $$;

-- 4. Subassuntos
INSERT INTO subtopics (topic_id, name, summary, order_index)
SELECT t.id, v.name, v.summary, v.order_index
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Cascata ou Scrum: depende', 'Nenhuma metodologia é a melhor em todos os casos. A escolha depende das características do projeto e das entregas a serem realizadas.', 1),
  ('Origem e ideia central do Scrum', 'O Scrum foi co-criado por Jeff Sutherland e é um dos frameworks ágeis mais difundidos. Sua ideia central é inspecionar e adaptar em intervalos regulares.', 2),
  ('Product Owner', 'O Product Owner (PO) é o dono do produto: fala com o cliente, conhece profundamente o negócio e decide o que deve ser feito e por quê.', 3),
  ('Scrum Master', 'O Scrum Master é o facilitador do projeto: fala com a equipe, decide como o trabalho será feito e garante que o processo funcione.', 4),
  ('Time e cliente', 'O time é autônomo, multifuncional e pequeno, e o cliente participa como parceiro. Todos devem saber o que acontece no projeto.', 5),
  ('Boas práticas do Scrum', 'As boas práticas do Scrum combinam inspeção e adaptação, transparência, equipes pequenas e autônomas e respeito ao tempo.', 6)
) AS v(name, summary, order_index)
WHERE s.name = 'Tecnologia da Informação' AND t.number = 6
ON CONFLICT DO NOTHING;

-- 5. Pontos-chave
INSERT INTO subtopic_key_points (subtopic_id, text, order_index)
SELECT st.id, v.text, v.order_index
FROM subtopics st
JOIN topics t ON t.id = st.topic_id
JOIN subjects s ON s.id = t.subject_id
JOIN (VALUES
  ('Cascata ou Scrum: depende', 'Cascata: as atividades são executadas sequencialmente e uma tarefa só inicia quando a anterior termina.', 1),
  ('Cascata ou Scrum: depende', 'Scrum: o projeto é feito em pequenas partes, com retorno regular do cliente sobre o que está sendo desenvolvido.', 2),
  ('Cascata ou Scrum: depende', 'Qual usar? Nada é óbvio: depende das características e das entregas do projeto.', 3),
  ('Origem e ideia central do Scrum', 'Jeff Sutherland é co-criador do Scrum e coautor do Manifesto Ágil (2001).', 1),
  ('Origem e ideia central do Scrum', 'Junto com Ken Schwaber, ele mantém o Scrum Guide, a referência oficial do framework.', 2),
  ('Origem e ideia central do Scrum', 'Ideia simples: verificar em intervalos regulares se o caminho está certo e se é aquilo que as pessoas realmente querem (inspeção e adaptação).', 3),
  ('Origem e ideia central do Scrum', 'Hesitação significa morte: saiba onde está, avalie as alternativas, tome uma decisão e siga em frente.', 4),
  ('Product Owner', 'O PO fala com o cliente e transforma a visão em backlog.', 1),
  ('Product Owner', 'Decide "o que" deverá ser feito e por quê.', 2),
  ('Product Owner', 'Deve ter a habilidade de encontrar o valor nas atividades para priorizar.', 3),
  ('Product Owner', 'Controla o backlog e a sua priorização.', 4),
  ('Scrum Master', 'O Scrum Master fala com a equipe e decide "como" será feito.', 1),
  ('Scrum Master', 'É o dono do fluxo e do ritmo de trabalho.', 2),
  ('Scrum Master', 'Elimina obstáculos.', 3),
  ('Scrum Master', 'Treina e integra a equipe no Scrum e garante que o processo funcione.', 4),
  ('Time e cliente', 'Time: autônomo e multifuncional; menor é melhor; a culpa é idiota; transcendência.', 1),
  ('Time e cliente', 'Cliente: participa como um parceiro.', 2),
  ('Time e cliente', 'Todos os integrantes devem saber o que os outros estão fazendo e o que está acontecendo no projeto.', 3),
  ('Time e cliente', 'O progresso deve ficar claro para todos: tudo deve ficar às claras.', 4),
  ('Boas práticas do Scrum', 'Inspeção e adaptação; fracasse rápido para corrigir o problema o quanto antes.', 1),
  ('Boas práticas do Scrum', 'Equipes excelentes são multifuncionais, autônomas e capacitadas, com um propósito transcendente.', 2),
  ('Boas práticas do Scrum', 'Menor é melhor; culpar é idiotice; o tempo é finito e deve ser tratado como tal.', 3),
  ('Boas práticas do Scrum', 'Transparência: todo mundo sabe de tudo, com comunicação o tempo todo.', 4),
  ('Boas práticas do Scrum', 'Uma reunião por dia (daily) e planejar apenas o necessário.', 5)
) AS v(subtopic_name, text, order_index) ON v.subtopic_name = st.name
WHERE s.name = 'Tecnologia da Informação' AND t.number = 6
ON CONFLICT DO NOTHING;

-- 6. Listas de exercícios
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT v.title, 'exercise', t.subject_id, t.id, NULL, v.difficulty::difficulty_level
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Metodologia Ágil: Scrum — Exercícios 1: Fundamentos', 'easy'),
  ('Metodologia Ágil: Scrum — Exercícios 2: Aplicação', 'medium'),
  ('Metodologia Ágil: Scrum — Exercícios 3: Desafio', 'hard')
) AS v(title, difficulty)
WHERE s.name = 'Tecnologia da Informação' AND t.number = 6
  AND NOT EXISTS (SELECT 1 FROM quizzes z WHERE z.title = v.title);

-- 7. Questões

-- Q1 | multiple_choice | fácil | Product Owner | Exercícios 1 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'No Scrum, quem decide "o que" deverá ser feito e por quê?', 'O Product Owner fala com o cliente, transforma a visão em backlog, decide "o que" deverá ser feito e por quê e controla o backlog e sua priorização.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 6
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologia Ágil: Scrum — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('O Product Owner, que controla o backlog e a priorização.', true, 1),
  ('O Scrum Master, que é o dono do fluxo e do ritmo.', false, 2),
  ('O time, que é autônomo, multifuncional e pequeno.', false, 3),
  ('O cliente, que participa do projeto como um parceiro.', false, 4),
  ('O patrocinador, que aprova o orçamento do projeto.', false, 5)
) AS o(text, is_correct, order_index);

-- Q2 | drag_and_drop | média | Product Owner | Exercícios 1 | s1: Product Owner, s2: o que, s3: Scrum Master, s4: como
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'O {{s1}} fala com o cliente e decide {{s2}} deverá ser feito. O {{s3}} fala com a equipe e decide {{s4}} será feito.', 'O Product Owner fala com o cliente e decide "o que" será feito e por quê; o Scrum Master fala com a equipe e decide "como" será feito.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 6
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologia Ágil: Scrum — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('Scrum Master', 1), ('Product Owner', 2), ('como', 3), ('quando', 4), ('Cliente', 5), ('o que', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'Product Owner', 1), ('s2', 'o que', 2), ('s3', 'Scrum Master', 3), ('s4', 'como', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q3 | multiple_choice | difícil | Scrum Master | Exercícios 2 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Em um squad, dois desenvolvedores estão parados há dois dias porque dependem de um acesso que outra área não libera. Pelas funções do Scrum, quem deve agir para resolver essa situação?', 'Eliminar obstáculos é função do Scrum Master, que é o dono do fluxo e do ritmo de trabalho e garante que o processo funcione.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 6
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologia Ágil: Scrum — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('O Product Owner, pois ele controla o backlog.', false, 1),
  ('O cliente, pois ele participa como parceiro.', false, 2),
  ('O time, pois ele é autônomo e multifuncional.', false, 3),
  ('O Scrum Master, pois ele elimina obstáculos.', true, 4),
  ('O Product Owner, pois ele fala com o cliente.', false, 5)
) AS o(text, is_correct, order_index);

-- Q4 | multiple_answer | difícil | Scrum Master | Exercícios 2 | corretas: A, C, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma empresa contrata um Scrum Master para um squad recém-formado. Quais são atribuições desse papel segundo o material? Assinale todas as corretas.', 'O Scrum Master treina e integra a equipe no Scrum, garante que o processo funcione e é o dono do fluxo e do ritmo. Backlog e priorização são do Product Owner.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 6
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologia Ágil: Scrum — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Treinar e integrar a equipe no Scrum.', true, 1),
  ('Transformar a visão do cliente em backlog.', false, 2),
  ('Garantir que o processo funcione bem.', true, 3),
  ('Ser o dono do fluxo e ritmo de trabalho.', true, 4),
  ('Controlar a priorização de todo o backlog.', false, 5)
) AS o(text, is_correct, order_index);

-- Q5 | single_choice | difícil | Origem e ideia central do Scrum | Exercícios 2 | b1: Manifesto Ágil, b2: 2001, b3: Ken Schwaber, b4: Scrum Guide
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Jeff Sutherland é co-criador do Scrum e coautor do {{b1}}, de {{b2}}. Junto com {{b3}}, ele mantém o {{b4}}, a referência oficial do framework.', 'Jeff Sutherland é coautor do Manifesto Ágil (2001) e, com Ken Schwaber, mantém o Scrum Guide, a referência oficial do Scrum.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 6
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologia Ágil: Scrum — Exercícios 2: Aplicação'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'Manifesto Ágil', true, 1), ('b1', 'PMBOK', false, 2), ('b1', 'Gartner Group', false, 3),
  ('b2', '1941', false, 1), ('b2', '2001', true, 2), ('b2', '2007', false, 3),
  ('b3', 'Fibonacci', false, 1), ('b3', 'Márcio d’Ávila', false, 2), ('b3', 'Ken Schwaber', true, 3),
  ('b4', 'Scrum Inc.', false, 1), ('b4', 'Scrum Guide', true, 2), ('b4', 'Product Backlog', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q6 | multiple_choice | média | Origem e ideia central do Scrum | Exercícios 1 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Qual é a ideia simples que está por trás do Scrum, segundo o material?', 'A ideia do Scrum é verificar em intervalos regulares se está indo no caminho certo e se é aquilo que as pessoas realmente querem: inspeção e adaptação.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 6
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologia Ágil: Scrum — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Planejar todo o projeto em detalhe antes de executar.', false, 1),
  ('Verificar em intervalos regulares se o caminho está certo.', true, 2),
  ('Concluir cada fase uma única vez, seguindo a sequência.', false, 3),
  ('Reunir toda a equipe apenas na entrega final ao cliente.', false, 4),
  ('Manter o cliente presente só em algumas fases do projeto.', false, 5)
) AS o(text, is_correct, order_index);

-- Q7 | drag_and_drop | fácil | Time e cliente | Exercícios 1 | s1: Product Owner, s2: Scrum Master, s3: Time, s4: Cliente
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Associe cada característica ao integrante do squad. Fala com o cliente: {{s1}}. Fala com a equipe: {{s2}}. É autônomo e multifuncional: {{s3}}. Participa como um parceiro: {{s4}}.', 'O Product Owner fala com o cliente, o Scrum Master fala com a equipe, o time é autônomo e multifuncional e o cliente participa como um parceiro.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 6
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologia Ágil: Scrum — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('Arquiteto', 1), ('Patrocinador', 2), ('Cliente', 3), ('Time', 4), ('Scrum Master', 5), ('Product Owner', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'Product Owner', 1), ('s2', 'Scrum Master', 2), ('s3', 'Time', 3), ('s4', 'Cliente', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q8 | multiple_choice | difícil | Boas práticas do Scrum | Exercícios 2 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um squad descobre, logo na primeira semana, que a tela de pagamento não atende ao que o cliente quer, e a corrige de imediato. Qual boa prática do Scrum essa situação ilustra?', 'Fracasse rápido para que possa corrigir o problema o quanto antes: descobrir o erro cedo, pela inspeção e adaptação, evita desperdício.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 6
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologia Ágil: Scrum — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Planeje apenas o necessário para o momento atual.', false, 1),
  ('Menor é melhor na hora de formar as equipes.', false, 2),
  ('O tempo é finito e deve ser tratado como tal.', false, 3),
  ('Uma reunião por dia para alinhar toda a equipe.', false, 4),
  ('Fracasse rápido para corrigir o quanto antes.', true, 5)
) AS o(text, is_correct, order_index);

-- Q9 | multiple_answer | super difícil | Boas práticas do Scrum | Exercícios 3 | corretas: B, C, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Um gestor quer alinhar seu squad às boas práticas do Scrum. Quais atitudes estão de acordo com elas? Assinale todas as corretas.', 'As boas práticas pedem transparência (todo mundo sabe de tudo), uma reunião por dia e inspeção e adaptação. Culpar é idiotice, e deve-se planejar apenas o necessário.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 6
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologia Ágil: Scrum — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Procurar o culpado sempre que algo falhar.', false, 1),
  ('Manter todos informados sobre tudo no projeto.', true, 2),
  ('Fazer uma reunião por dia, a chamada daily.', true, 3),
  ('Planejar o projeto inteiro em detalhe no início.', false, 4),
  ('Inspecionar e adaptar o trabalho com frequência.', true, 5)
) AS o(text, is_correct, order_index);

-- Q10 | multiple_choice | fácil | Time e cliente | Exercícios 1 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Segundo o material, como deve ser o time em um squad Scrum?', 'O time é autônomo e multifuncional, e menor é melhor. A culpa é idiota: o foco está em resolver, não em apontar culpados.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 6
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologia Ágil: Scrum — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Grande e especializado em apenas uma função.', false, 1),
  ('Hierárquico, com comando e reportes formais.', false, 2),
  ('Pequeno, autônomo, multifuncional e sem culpados.', true, 3),
  ('Temporário, presente só em fases específicas.', false, 4),
  ('Externo, contratado apenas para executar os testes.', false, 5)
) AS o(text, is_correct, order_index);

-- Q11 | single_choice | super difícil | Product Owner | Exercícios 3 | b1: visão, b2: negócio, b3: valor, b4: priorizar
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'O Product Owner transforma a {{b1}} em backlog e conhece profundamente o {{b2}}. Ele precisa ter a habilidade de encontrar o {{b3}} nas atividades para {{b4}}.', 'O PO transforma a visão em backlog, conhece profundamente o negócio e deve ter a habilidade de encontrar o valor nas atividades para priorizar.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 6
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologia Ágil: Scrum — Exercícios 3: Desafio'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'visão', true, 1), ('b1', 'equipe', false, 2), ('b1', 'reunião', false, 3),
  ('b2', 'código', false, 1), ('b2', 'negócio', true, 2), ('b2', 'fluxo', false, 3),
  ('b3', 'erro', false, 1), ('b3', 'prazo', false, 2), ('b3', 'valor', true, 3),
  ('b4', 'priorizar', true, 1), ('b4', 'programar', false, 2), ('b4', 'documentar', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q12 | drag_and_drop | super difícil | Boas práticas do Scrum | Exercícios 3 | s1: Inspeção, s2: Fracasse, s3: Menor, s4: tempo, s5: necessário
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Complete as boas práticas do Scrum. {{s1}} e adaptação. {{s2}} rápido para corrigir o problema o quanto antes. {{s3}} é melhor. O {{s4}} é finito: trate-o como tal. Planeje apenas o {{s5}}.', 'As boas práticas incluem inspeção e adaptação, fracassar rápido para corrigir cedo, equipes menores, respeito ao tempo finito e planejar apenas o necessário.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 6
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologia Ágil: Scrum — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('tempo', 1), ('necessário', 2), ('Maior', 3), ('Fracasse', 4), ('Inspeção', 5), ('Hierarquia', 6), ('Menor', 7)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'Inspeção', 1), ('s2', 'Fracasse', 2), ('s3', 'Menor', 3), ('s4', 'tempo', 4), ('s5', 'necessário', 5))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q13 | multiple_choice | difícil | Cascata ou Scrum: depende | Exercícios 2 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um gerente precisa escolher entre Cascata e Scrum para um novo projeto e pergunta qual das duas deve usar. Segundo o material, qual é a resposta correta?', 'Nada é óbvio: depende. A escolha da metodologia depende das características do projeto e das entregas a serem realizadas.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 6
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologia Ágil: Scrum — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Depende das características e das entregas do projeto.', true, 1),
  ('Scrum, pois o modelo ágil é sempre superior à Cascata.', false, 2),
  ('Cascata, pois a previsibilidade sempre reduz os custos.', false, 3),
  ('As duas ao mesmo tempo, em todas as fases do projeto.', false, 4),
  ('Nenhuma, pois projetos pequenos dispensam metodologia.', false, 5)
) AS o(text, is_correct, order_index);

-- Q14 | multiple_answer | super difícil | Time e cliente | Exercícios 3 | corretas: A, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Um squad discute como os integrantes devem se relacionar durante o projeto. Segundo o material, o que vale para o time Scrum? Assinale todas as corretas.', 'Todos os integrantes devem saber o que os outros estão fazendo e o progresso deve ficar claro para todos. O cliente participa como parceiro, e menor é melhor.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 6
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologia Ágil: Scrum — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Todos devem saber o que os outros estão fazendo.', true, 1),
  ('O progresso deve ser visível só ao Scrum Master.', false, 2),
  ('O cliente fica de fora e só recebe a entrega final.', false, 3),
  ('O progresso do projeto deve ficar claro para todos.', true, 4),
  ('As equipes maiores são melhores que as menores.', false, 5)
) AS o(text, is_correct, order_index);

-- Q15 | drag_and_drop | super difícil | Origem e ideia central do Scrum | Exercícios 3 | s1: Hesitação, s2: alternativas, s3: decisão
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Complete a frase citada no material: "{{s1}} significa morte: saiba onde está, avalie as {{s2}}, tome uma {{s3}} e siga em frente."', 'A frase é "Hesitação significa morte: saiba onde está, avalie as alternativas, tome uma decisão e siga em frente", ligada aos pilares do Scrum.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 6
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Metodologia Ágil: Scrum — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('reuniões', 1), ('Transparência', 2), ('decisão', 3), ('alternativas', 4), ('Hesitação', 5)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'Hesitação', 1), ('s2', 'alternativas', 2), ('s3', 'decisão', 3))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- 8. Conferência: aborta se alguma questão ficou fora das listas ou alguma lista ficou vazia
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM questions q
    JOIN topics t ON t.id = q.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 6
      AND NOT EXISTS (
        SELECT 1 FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
        WHERE qq.question_id = q.id AND z.kind = 'exercise'
      )
  ) THEN
    RAISE EXCEPTION 'Há questão da aula 6 de Tecnologia da Informação fora das listas de exercícios';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM quizzes z
    JOIN topics t ON t.id = z.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 6 AND z.kind = 'exercise'
      AND NOT EXISTS (SELECT 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  ) THEN
    RAISE EXCEPTION 'Há lista de exercícios da aula 6 de Tecnologia da Informação sem questões';
  END IF;
END $$;

-- =====================================================================
-- AULA 7 — Priorização, Estimativa e Backlog no Scrum (TI-Sprint 2-Aula 07.pdf)
-- =====================================================================

-- 1. Disciplina
INSERT INTO subjects (name, short_label)
SELECT 'Tecnologia da Informação', 'TI'
WHERE NOT EXISTS (SELECT 1 FROM subjects WHERE name = 'Tecnologia da Informação');

-- 2. Assunto
INSERT INTO topics (subject_id, number, name, description)
SELECT s.id, 7, 'Priorização, Estimativa e Backlog no Scrum', 'Como priorizar e estimar requisitos com tamanhos relativos, Fibonacci e Planning Poker, montar o Product e o Sprint Backlog e acompanhar a sprint com o Burndown.'
FROM subjects s
WHERE s.name = 'Tecnologia da Informação'
ON CONFLICT DO NOTHING;

-- 3. Trava: aborta se a aula não existir ou já existir com outro nome
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM topics t JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 7 AND t.name = 'Priorização, Estimativa e Backlog no Scrum'
  ) THEN
    RAISE EXCEPTION 'A aula 7 de Tecnologia da Informação não existe ou já está cadastrada com outro nome';
  END IF;
END $$;

-- 4. Subassuntos
INSERT INTO subtopics (topic_id, name, summary, order_index)
SELECT t.id, v.name, v.summary, v.order_index
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Valores ágeis, daily e priorização', 'A aula retoma os quatro valores ágeis, a reunião diária e a responsabilidade do Product Owner de alinhar as prioridades com o cliente.', 1),
  ('Estimativa por tamanho relativo', 'No Scrum, estimar não é dizer quantos dias uma tarefa vai levar, e sim quão grande ela é em comparação com as outras, como nos tamanhos de roupa.', 2),
  ('Fibonacci e Planning Poker', 'A sequência de Fibonacci traduz a percepção de esforço da equipe, e o Planning Poker é a técnica colaborativa que leva o time a um consenso sobre a estimativa.', 3),
  ('Product Backlog e Sprint Backlog', 'Com os requisitos estimados e priorizados, o grupo define em qual sprint cada um será entregue e quem responde por ele. O Sprint Backlog é o que será feito em cada sprint.', 4),
  ('Burndown e medição de produtividade', 'O Burndown mostra o trabalho que ainda falta em relação ao tempo restante. Comparar a linha real com a linha ideal revela se a equipe está no ritmo para concluir a sprint.', 5)
) AS v(name, summary, order_index)
WHERE s.name = 'Tecnologia da Informação' AND t.number = 7
ON CONFLICT DO NOTHING;

-- 5. Pontos-chave
INSERT INTO subtopic_key_points (subtopic_id, text, order_index)
SELECT st.id, v.text, v.order_index
FROM subtopics st
JOIN topics t ON t.id = st.topic_id
JOIN subjects s ON s.id = t.subject_id
JOIN (VALUES
  ('Valores ágeis, daily e priorização', 'Os 4 valores ágeis: indivíduos e interações, software em funcionamento, responder às mudanças e colaboração com o cliente.', 1),
  ('Valores ágeis, daily e priorização', 'Daily: máximo de 15 minutos, com foco na comunicação, em entender a atividade de todos e em eliminar barreiras.', 2),
  ('Valores ágeis, daily e priorização', 'É responsabilidade do PO alinhar as prioridades com o cliente.', 3),
  ('Estimativa por tamanho relativo', 'Estimar no Scrum é comparar o tamanho de uma tarefa com o das outras, não calcular quantos dias ela leva.', 1),
  ('Estimativa por tamanho relativo', 'PP é algo muito pequeno e simples; P é um pouco maior, mas ainda fácil; M já exige mais esforço.', 2),
  ('Estimativa por tamanho relativo', 'G é grande, com complexidade considerável; GG é muito grande e talvez precise até ser dividido.', 3),
  ('Fibonacci e Planning Poker', 'Fibonacci: cada número é a soma dos dois anteriores (1, 1, 2, 3, 5, 8, 13, 21…), um crescimento que não é linear.', 1),
  ('Fibonacci e Planning Poker', 'Um item de 13 pontos é claramente mais complexo que um de 8; a distância entre 3 e 5 é bem menor e mais fácil de comparar.', 2),
  ('Fibonacci e Planning Poker', 'Equivalência com tamanho de roupa: PP = 3, P = 5, M = 8, G = 13, GG = 21.', 3),
  ('Fibonacci e Planning Poker', 'Planning Poker: cada membro estima individualmente com cartas e todos as mostram ao mesmo tempo, para evitar influência mútua.', 4),
  ('Fibonacci e Planning Poker', 'Se houver diferença significativa, o grupo discute o motivo e repete o processo até alcançar um consenso.', 5),
  ('Product Backlog e Sprint Backlog', 'Cada integrante estima individualmente; depois o grupo alinha os tamanhos e, se necessário, faz um Planning Poker.', 1),
  ('Product Backlog e Sprint Backlog', 'Depois de estimar, o grupo determina a prioridade e em qual sprint cada requisito será entregue.', 2),
  ('Product Backlog e Sprint Backlog', 'Cada requisito tem um único responsável, o "pai", que valida e garante que ele está 100% pronto para entrega.', 3),
  ('Product Backlog e Sprint Backlog', 'Sprint Backlog: definição do que será feito em cada sprint; as informações da planilha devem estar no Trello.', 4),
  ('Burndown e medição de produtividade', 'Os três gráficos mais usados no Scrum são o Burndown, o Burnup e o Gráfico de Fluxo Cumulativo (CFD).', 1),
  ('Burndown e medição de produtividade', 'O Burndown não foi criado pelos métodos ágeis, mas é amplamente utilizado neles.', 2),
  ('Burndown e medição de produtividade', 'Ele mostra a quantidade de trabalho que ainda precisa ser feito em relação ao tempo restante para a entrega.', 3),
  ('Burndown e medição de produtividade', 'A linha ideal representa o ritmo esperado de trabalho; a linha real mostra o progresso da equipe.', 4),
  ('Burndown e medição de produtividade', 'O Burndown deve estar sempre visível ao time, para facilitar o acompanhamento coletivo e decisões rápidas.', 5)
) AS v(subtopic_name, text, order_index) ON v.subtopic_name = st.name
WHERE s.name = 'Tecnologia da Informação' AND t.number = 7
ON CONFLICT DO NOTHING;

-- 6. Listas de exercícios
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT v.title, 'exercise', t.subject_id, t.id, NULL, v.difficulty::difficulty_level
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Priorização, Estimativa e Backlog no Scrum — Exercícios 1: Fundamentos', 'easy'),
  ('Priorização, Estimativa e Backlog no Scrum — Exercícios 2: Aplicação', 'medium'),
  ('Priorização, Estimativa e Backlog no Scrum — Exercícios 3: Desafio', 'hard')
) AS v(title, difficulty)
WHERE s.name = 'Tecnologia da Informação' AND t.number = 7
  AND NOT EXISTS (SELECT 1 FROM quizzes z WHERE z.title = v.title);

-- 7. Questões

-- Q1 | multiple_choice | fácil | Estimativa por tamanho relativo | Exercícios 1 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'No Scrum, estimar uma tarefa significa avaliar:', 'No Scrum não se pensa em "quantos dias vai levar", mas em quão grande é a tarefa em comparação com outras, como nos tamanhos de roupa.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 7
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Priorização, Estimativa e Backlog no Scrum — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('quantos dias corridos ela vai levar para ficar pronta.', false, 1),
  ('quanto ela vai custar em horas de cada integrante.', false, 2),
  ('qual integrante do time tem mais chance de concluí-la.', false, 3),
  ('em que sprint o cliente deseja receber essa entrega.', false, 4),
  ('quão grande ela é em comparação com as outras tarefas.', true, 5)
) AS o(text, is_correct, order_index);

-- Q2 | drag_and_drop | média | Fibonacci e Planning Poker | Exercícios 1 | s1: 3, s2: 5, s3: 8, s4: 13, s5: 21
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Na equivalência entre tamanho de roupa e pontos de Fibonacci usada no material: PP = {{s1}}, P = {{s2}}, M = {{s3}}, G = {{s4}} e GG = {{s5}}.', 'O material associa PP a 3 pontos, P a 5, M a 8, G a 13 e GG a 21, seguindo a sequência de Fibonacci.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 7
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Priorização, Estimativa e Backlog no Scrum — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('8', 1), ('2', 2), ('13', 3), ('5', 4), ('34', 5), ('21', 6), ('3', 7)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', '3', 1), ('s2', '5', 2), ('s3', '8', 3), ('s4', '13', 4), ('s5', '21', 5))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q3 | multiple_choice | média | Fibonacci e Planning Poker | Exercícios 1 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Em uma rodada de Planning Poker, por que todos os membros do time mostram suas cartas ao mesmo tempo?', 'Cada membro faz sua estimativa individual e todos mostram as cartas ao mesmo tempo para evitar influência mútua.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 7
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Priorização, Estimativa e Backlog no Scrum — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Para que a reunião termine em até quinze minutos.', false, 1),
  ('Para que o Scrum Master escolha a maior estimativa.', false, 2),
  ('Para evitar que um integrante influencie o outro.', true, 3),
  ('Para que o cliente aprove o valor de cada tarefa.', false, 4),
  ('Para que a soma das cartas defina o prazo final.', false, 5)
) AS o(text, is_correct, order_index);

-- Q4 | multiple_answer | difícil | Fibonacci e Planning Poker | Exercícios 2 | corretas: A, B, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Um squad estima o requisito "login com biometria" em um Planning Poker: três pessoas mostram a carta 5 e uma mostra a carta 21. Segundo a técnica, o que deve acontecer? Assinale todas as corretas.', 'Havendo diferença significativa, o grupo discute o motivo e repete o processo até o consenso. O objetivo é que todos entendam a tarefa da mesma forma, não tirar média.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 7
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Priorização, Estimativa e Backlog no Scrum — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('O grupo discute o motivo da discrepância.', true, 1),
  ('A rodada se repete até o time ter consenso.', true, 2),
  ('Vale a média aritmética das quatro cartas.', false, 3),
  ('Todos devem entender a tarefa do mesmo jeito.', true, 4),
  ('A carta mais alta é adotada sem discussão.', false, 5)
) AS o(text, is_correct, order_index);

-- Q5 | single_choice | difícil | Burndown e medição de produtividade | Exercícios 2 | b1: ideal, b2: real, b3: ainda precisa ser feito, b4: restante
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'No gráfico de Burndown, a linha {{b1}} é a reta de referência que representa o ritmo esperado, e a linha {{b2}} mostra o progresso da equipe. O gráfico mostra a quantidade de trabalho que {{b3}} em relação ao tempo {{b4}} para a entrega.', 'A linha ideal é o ritmo esperado e a linha real é o progresso da equipe. O Burndown mostra o trabalho que ainda precisa ser feito em relação ao tempo restante.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 7
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Priorização, Estimativa e Backlog no Scrum — Exercícios 2: Aplicação'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'real', false, 1), ('b1', 'ideal', true, 2), ('b1', 'média', false, 3),
  ('b2', 'real', true, 1), ('b2', 'ideal', false, 2), ('b2', 'base', false, 3),
  ('b3', 'já foi concluído', false, 1), ('b3', 'foi cancelado', false, 2), ('b3', 'ainda precisa ser feito', true, 3),
  ('b4', 'decorrido', false, 1), ('b4', 'restante', true, 2), ('b4', 'planejado', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q6 | multiple_choice | super difícil | Burndown e medição de produtividade | Exercícios 3 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'No Burndown de um projeto, no dia 5 a meta era ter 300 pontos faltantes, mas a equipe está com 323. No dia 18 a meta era ter 144 pontos faltantes, e a equipe está com 105. Como interpretar os dois momentos?', 'O Burndown mostra o trabalho restante. No dia 5 faltam 323 − 300 = 23 pontos a mais que a meta (atraso); no dia 18 faltam 144 − 105 = 39 a menos (equipe adiantada).'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 7
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Priorização, Estimativa e Backlog no Scrum — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Dia 5: atrasada em 23 pontos; dia 18: adiantada em 39.', true, 1),
  ('Dia 5: adiantada em 23 pontos; dia 18: atrasada em 39.', false, 2),
  ('Dia 5: atrasada em 23 pontos; dia 18: atrasada em 39.', false, 3),
  ('Dia 5: adiantada em 23 pontos; dia 18: adiantada em 39.', false, 4),
  ('Dia 5: atrasada em 39 pontos; dia 18: adiantada em 23.', false, 5)
) AS o(text, is_correct, order_index);

-- Q7 | drag_and_drop | super difícil | Fibonacci e Planning Poker | Exercícios 3 | s1: cada um estima individualmente, s2: todos mostram as cartas juntos, s3: o grupo discute as diferenças, s4: a rodada se repete até o consenso
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Ordene os passos de uma rodada de Planning Poker: {{s1}} → {{s2}} → {{s3}} → {{s4}}.', 'Cada membro estima individualmente, todos mostram as cartas ao mesmo tempo, o grupo discute as discrepâncias e o processo se repete até o consenso.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 7
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Priorização, Estimativa e Backlog no Scrum — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('o PO define o valor final', 1), ('calcula-se a média das cartas', 2), ('todos mostram as cartas juntos', 3), ('cada um estima individualmente', 4), ('o grupo discute as diferenças', 5), ('a rodada se repete até o consenso', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'cada um estima individualmente', 1), ('s2', 'todos mostram as cartas juntos', 2), ('s3', 'o grupo discute as diferenças', 3), ('s4', 'a rodada se repete até o consenso', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q8 | multiple_choice | difícil | Product Backlog e Sprint Backlog | Exercícios 2 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Na planilha de backlog de um grupo, o requisito "tela de cadastro" aparece com três responsáveis. Segundo o material, qual é o ajuste correto?', 'Cada requisito tem um "pai": um único responsável, que valida e se certifica de que o requisito está 100% ok para a entrega. Os demais integrantes podem ajudar na elaboração.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 7
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Priorização, Estimativa e Backlog no Scrum — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Manter os três, pois todos ajudaram a elaborar.', false, 1),
  ('Definir um só, que valida e garante a entrega.', true, 2),
  ('Remover todos, pois o requisito é do time todo.', false, 3),
  ('Passar ao cliente, que é o dono do requisito.', false, 4),
  ('Atribuir ao Scrum Master, que elimina barreiras.', false, 5)
) AS o(text, is_correct, order_index);

-- Q9 | multiple_answer | super difícil | Burndown e medição de produtividade | Exercícios 3 | corretas: C, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Um Scrum Master apresenta o gráfico de Burndown a um squad recém-formado. Segundo o material, o que vale para esse gráfico? Assinale todas as corretas.', 'O Burndown não foi criado pelos métodos ágeis e mostra o trabalho restante, com a linha ideal como referência. Deve ficar sempre visível e indica se a sprint termina no prazo.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 7
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Priorização, Estimativa e Backlog no Scrum — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Foi criado pelos métodos ágeis para o Scrum.', false, 1),
  ('Mostra só o trabalho que já foi concluído.', false, 2),
  ('Deve ficar sempre visível para todo o time.', true, 3),
  ('Dispensa a linha ideal como reta de referência.', false, 4),
  ('Permite ver se a sprint termina dentro do prazo.', true, 5)
) AS o(text, is_correct, order_index);

-- Q10 | multiple_choice | fácil | Valores ágeis, daily e priorização | Exercícios 1 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Segundo o material, de quem é a responsabilidade de alinhar as prioridades com o cliente?', 'É responsabilidade do Product Owner alinhar as prioridades com o cliente: ele faz e controla o backlog e prioriza as atividades.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 7
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Priorização, Estimativa e Backlog no Scrum — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Do Scrum Master, que decide como será feito.', false, 1),
  ('Do time, que é autônomo e multifuncional.', false, 2),
  ('Do patrocinador, que aprova o orçamento.', false, 3),
  ('Do Product Owner, que controla o backlog.', true, 4),
  ('Do arquiteto, que desenha a solução técnica.', false, 5)
) AS o(text, is_correct, order_index);

-- Q11 | single_choice | super difícil | Fibonacci e Planning Poker | Exercícios 3 | b1: soma, b2: não linear, b3: claramente mais complexo, b4: menor e mais fácil de comparar
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Na sequência de Fibonacci, cada número é a {{b1}} dos dois anteriores, o que representa um crescimento {{b2}}. Por isso, um item de 13 pontos é {{b3}} que um de 8, enquanto a distância entre 3 e 5 pontos é {{b4}}.', 'Cada número de Fibonacci é a soma dos dois anteriores, um crescimento não linear. Assim, 13 é claramente mais complexo que 8, e a distância entre 3 e 5 é menor e mais fácil de comparar.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 7
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Priorização, Estimativa e Backlog no Scrum — Exercícios 3: Desafio'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'soma', true, 1), ('b1', 'média', false, 2), ('b1', 'diferença', false, 3),
  ('b2', 'linear', false, 1), ('b2', 'não linear', true, 2), ('b2', 'constante', false, 3),
  ('b3', 'apenas um pouco maior', false, 1), ('b3', 'exatamente o dobro', false, 2), ('b3', 'claramente mais complexo', true, 3),
  ('b4', 'maior e mais difícil de comparar', false, 1), ('b4', 'menor e mais fácil de comparar', true, 2), ('b4', 'igual à distância entre 8 e 13', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q12 | drag_and_drop | fácil | Valores ágeis, daily e priorização | Exercícios 1 | s1: 15, s2: comunicação, s3: todos, s4: barreiras
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'A daily do Scrum dura no máximo {{s1}} minutos, tem foco na {{s2}}, serve para entender a atividade de {{s3}} e para eliminar {{s4}}.', 'A daily tem no máximo 15 minutos, com foco na comunicação, em entender a atividade de todos e em eliminar barreiras.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 7
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Priorização, Estimativa e Backlog no Scrum — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('barreiras', 1), ('todos', 2), ('documentação', 3), ('30', 4), ('15', 5), ('comunicação', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', '15', 1), ('s2', 'comunicação', 2), ('s3', 'todos', 3), ('s4', 'barreiras', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q13 | multiple_choice | difícil | Estimativa por tamanho relativo | Exercícios 2 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um requisito de um sistema de reservas foi estimado como GG, o equivalente a 21 pontos. Segundo o material, o que esse tamanho sugere?', 'GG é algo muito grande, que talvez precise até ser dividido. A estimativa compara tamanhos, não informa quantos dias a tarefa leva.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 7
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Priorização, Estimativa e Backlog no Scrum — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Que ele é simples e pode ser feito por uma pessoa.', false, 1),
  ('Que ele é muito grande e talvez deva ser dividido.', true, 2),
  ('Que ele exige mais esforço, mas ainda é mediano.', false, 3),
  ('Que ele levará exatamente 21 dias para ficar pronto.', false, 4),
  ('Que ele deve ser excluído do backlog do produto.', false, 5)
) AS o(text, is_correct, order_index);

-- Q14 | multiple_answer | difícil | Valores ágeis, daily e priorização | Exercícios 2 | corretas: A, C, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma equipe revisa os fundamentos antes de iniciar a sprint. Quais são valores da metodologia ágil citados no material? Assinale todas as corretas.', 'Os quatro valores ágeis são indivíduos e interações, software em funcionamento, responder às mudanças e colaboração com o cliente.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 7
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Priorização, Estimativa e Backlog no Scrum — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Indivíduos e interações.', true, 1),
  ('Comando e hierarquia fixa.', false, 2),
  ('Software em funcionamento.', true, 3),
  ('Colaboração com o cliente.', true, 4),
  ('Resistência a mudanças.', false, 5)
) AS o(text, is_correct, order_index);

-- Q15 | drag_and_drop | super difícil | Product Backlog e Sprint Backlog | Exercícios 3 | s1: estimar, s2: prioridade, s3: sprint, s4: responsável, s5: Trello
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Para montar o backlog do projeto, o grupo deve primeiro {{s1}} o tamanho dos requisitos; depois determinar a {{s2}} de cada um; em seguida definir em qual {{s3}} cada requisito será entregue e quem é o seu {{s4}}; por fim, levar as informações da planilha para o {{s5}}.', 'O grupo estima os requisitos, determina a prioridade, define a sprint de entrega e o responsável por cada um e registra todas as informações da planilha no Trello.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 7
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Priorização, Estimativa e Backlog no Scrum — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('sprint', 1), ('prioridade', 2), ('Trello', 3), ('estimar', 4), ('cliente', 5), ('responsável', 6), ('Burnup', 7)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'estimar', 1), ('s2', 'prioridade', 2), ('s3', 'sprint', 3), ('s4', 'responsável', 4), ('s5', 'Trello', 5))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- 8. Conferência: aborta se alguma questão ficou fora das listas ou alguma lista ficou vazia
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM questions q
    JOIN topics t ON t.id = q.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 7
      AND NOT EXISTS (
        SELECT 1 FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
        WHERE qq.question_id = q.id AND z.kind = 'exercise'
      )
  ) THEN
    RAISE EXCEPTION 'Há questão da aula 7 de Tecnologia da Informação fora das listas de exercícios';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM quizzes z
    JOIN topics t ON t.id = z.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 7 AND z.kind = 'exercise'
      AND NOT EXISTS (SELECT 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  ) THEN
    RAISE EXCEPTION 'Há lista de exercícios da aula 7 de Tecnologia da Informação sem questões';
  END IF;
END $$;

-- =====================================================================
-- AULA 8 — Infraestrutura e Diagrama de Solução Técnica (TI-Sprint 2-Aula 08.pdf)
-- =====================================================================

-- 1. Disciplina
INSERT INTO subjects (name, short_label)
SELECT 'Tecnologia da Informação', 'TI'
WHERE NOT EXISTS (SELECT 1 FROM subjects WHERE name = 'Tecnologia da Informação');

-- 2. Assunto
INSERT INTO topics (subject_id, number, name, description)
SELECT s.id, 8, 'Infraestrutura e Diagrama de Solução Técnica', 'A evolução da infraestrutura de TI do mainframe à nuvem, os modelos on-premises, IaaS, PaaS e SaaS, o backup e o diagrama de solução técnica.'
FROM subjects s
WHERE s.name = 'Tecnologia da Informação'
ON CONFLICT DO NOTHING;

-- 3. Trava: aborta se a aula não existir ou já existir com outro nome
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM topics t JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 8 AND t.name = 'Infraestrutura e Diagrama de Solução Técnica'
  ) THEN
    RAISE EXCEPTION 'A aula 8 de Tecnologia da Informação não existe ou já está cadastrada com outro nome';
  END IF;
END $$;

-- 4. Subassuntos
INSERT INTO subtopics (topic_id, name, summary, order_index)
SELECT t.id, v.name, v.summary, v.order_index
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Documentação viva e responsáveis', 'A documentação do projeto é viva e cresce a cada sprint. Prioridade quem escolhe é o PO, e cada tarefa tem um único responsável.', 1),
  ('Infraestrutura de TI: do mainframe à nuvem', 'A infraestrutura de TI reúne conectividade, hardware e software. Ela evoluiu dos mainframes centralizados para servidores convencionais, virtualizados e, por fim, para a nuvem.', 2),
  ('Virtualização', 'Virtualizar é dividir um servidor físico em vários servidores virtuais, independentes e isolados, por meio de um software específico. Nem sempre é a melhor opção: depende do negócio.', 3),
  ('On-premises, IaaS, PaaS e SaaS', 'No on-premises o servidor fica dentro da empresa. Na nuvem, cada modelo transfere mais responsabilidades ao fornecedor: infraestrutura, plataforma ou o software pronto.', 4),
  ('Backup', 'Backup é a cópia de segurança dos dados para outro ambiente, para restaurá-los em caso de perda dos originais. Recuperar e testar o processo é tão importante quanto copiar.', 5),
  ('Arquitetura de TI e diagrama de solução', 'A arquitetura de TI planeja a alocação dos ativos tecnológicos conforme o negócio. O diagrama de solução é o mapa de alto nível que mostra esses recursos e suas conexões.', 6)
) AS v(name, summary, order_index)
WHERE s.name = 'Tecnologia da Informação' AND t.number = 8
ON CONFLICT DO NOTHING;

-- 5. Pontos-chave
INSERT INTO subtopic_key_points (subtopic_id, text, order_index)
SELECT st.id, v.text, v.order_index
FROM subtopics st
JOIN topics t ON t.id = st.topic_id
JOIN subjects s ON s.id = t.subject_id
JOIN (VALUES
  ('Documentação viva e responsáveis', 'A prioridade é escolhida pelo PO, em ordem: 01, 02, 03, 04, 05.', 1),
  ('Documentação viva e responsáveis', 'O responsável é apenas um: quando a tarefa é dividida sem clareza, ninguém faz, pois cada um acha que o outro vai fazer.', 2),
  ('Documentação viva e responsáveis', 'A documentação é viva: reúne contexto, objetivo, justificativa, escopo, premissa, restrição e metodologia utilizada.', 3),
  ('Documentação viva e responsáveis', 'Também entram a planilha de backlog e o Trello, os diagramas de negócio e de solução técnica, a matriz de riscos e as referências.', 4),
  ('Infraestrutura de TI: do mainframe à nuvem', 'A infraestrutura de TI é formada por conectividade, hardware e software.', 1),
  ('Infraestrutura de TI: do mainframe à nuvem', 'Até 1980 os ambientes eram dominados por mainframes, com processamento centralizado.', 2),
  ('Infraestrutura de TI: do mainframe à nuvem', 'Os usuários trabalhavam com terminais passivos, ou "burros", apenas para entrada e saída de informações.', 3),
  ('Infraestrutura de TI: do mainframe à nuvem', 'Servidores convencionais são computadores com processadores, memória, portas de comunicação, softwares e sistemas de armazenamento.', 4),
  ('Infraestrutura de TI: do mainframe à nuvem', 'Evolução: servidores convencionais, servidores virtualizados, venda de espaços em data center (IaaS) e computação na nuvem (PaaS, SaaS).', 5),
  ('Virtualização', 'Virtualização: processo de dividir um servidor físico em vários servidores virtuais, independentes e isolados, por meio de um software específico.', 1),
  ('Virtualização', 'Modelo convencional: momentos de pico e de ociosidade, capacidade limitada, hardwares dedicados e baixa eficiência de balanceamento.', 2),
  ('Virtualização', 'Modelo virtualizado: hospedagem local ou remota, balanceamento ativo na carga e máxima eficiência, com uma máquina para vários serviços.', 3),
  ('Virtualização', 'O modelo virtualizado tem capacidade de crescimento com velocidade.', 4),
  ('Virtualização', 'Virtualizar é sempre bom? Depende: o profissional de TI avalia os impactos de cada modelo no contexto do negócio.', 5),
  ('On-premises, IaaS, PaaS e SaaS', 'On-premises: o servidor fica dentro da empresa, que precisa de espaço físico adequado, segurança e equipe de TI para manutenção.', 1),
  ('On-premises, IaaS, PaaS e SaaS', 'IaaS (infraestrutura como serviço): recursos de computação totalmente configuráveis, com servidores, armazenamento e processamento dimensionados conforme a demanda.', 2),
  ('On-premises, IaaS, PaaS e SaaS', 'PaaS (plataforma como serviço): plataformas para desenvolver e implantar soluções sem gerenciar a infraestrutura. Ex.: Docker, hospedagem de sites.', 3),
  ('On-premises, IaaS, PaaS e SaaS', 'SaaS (software como serviço): soluções prontas, sem preocupação com manutenção, atualizações ou licenças. Ex.: Conta Azul, Salesforce, Trello, RD Station.', 4),
  ('On-premises, IaaS, PaaS e SaaS', 'Analogia da festa: fazer em casa (on-premises), alugar o salão (IaaS), contratar o buffet (PaaS) e ir a um parque de diversões (SaaS).', 5),
  ('Backup', 'Backup: cópia de segurança dos dados de um dispositivo ou sistema para outro ambiente, para restauração em caso de perda dos originais.', 1),
  ('Backup', 'Pode ser de arquivos ou "imagens", local ou em nuvem, em discos ou outras mídias, full ou incremental, e deve ser periódico.', 2),
  ('Backup', 'A recuperação dos dados e os testes do processo são fundamentais.', 3),
  ('Arquitetura de TI e diagrama de solução', 'Arquitetura de TI: responsabilidade da área de TI, que analisa as necessidades do negócio e a infraestrutura para planejar a alocação e a distribuição dos ativos tecnológicos.', 1),
  ('Arquitetura de TI e diagrama de solução', 'Diagrama: desenho, mapa ou plano de alto nível que representa os recursos tecnológicos e de informação de uma organização ou solução.', 2),
  ('Arquitetura de TI e diagrama de solução', 'Objetivos do diagrama: fornecer uma visão geral, facilitar o entendimento e a organização dos recursos e mostrar a conexão entre os elementos.', 3),
  ('Arquitetura de TI e diagrama de solução', 'O diagrama também permite a identificação de problemas e oportunidades.', 4),
  ('Arquitetura de TI e diagrama de solução', 'Um bom diagrama mostra onde a solução começa, onde termina e como os componentes se conectam, com clareza para o técnico que vai instalar.', 5)
) AS v(subtopic_name, text, order_index) ON v.subtopic_name = st.name
WHERE s.name = 'Tecnologia da Informação' AND t.number = 8
ON CONFLICT DO NOTHING;

-- 6. Listas de exercícios
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT v.title, 'exercise', t.subject_id, t.id, NULL, v.difficulty::difficulty_level
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Infraestrutura e Diagrama de Solução Técnica — Exercícios 1: Fundamentos', 'easy'),
  ('Infraestrutura e Diagrama de Solução Técnica — Exercícios 2: Aplicação', 'medium'),
  ('Infraestrutura e Diagrama de Solução Técnica — Exercícios 3: Desafio', 'hard')
) AS v(title, difficulty)
WHERE s.name = 'Tecnologia da Informação' AND t.number = 8
  AND NOT EXISTS (SELECT 1 FROM quizzes z WHERE z.title = v.title);

-- 7. Questões

-- Q1 | multiple_choice | fácil | Virtualização | Exercícios 1 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'O que é a virtualização de servidores?', 'Virtualização é o processo de dividir um servidor físico em vários servidores virtuais, independentes e isolados, por meio de um software específico.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 8
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Infraestrutura e Diagrama de Solução Técnica — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Manter o servidor dentro da empresa, com equipe própria.', false, 1),
  ('Copiar os dados para outro ambiente, por segurança.', false, 2),
  ('Usar terminais passivos ligados a um mainframe central.', false, 3),
  ('Dividir um servidor físico em vários servidores virtuais.', true, 4),
  ('Contratar um software pronto, sem cuidar de licenças.', false, 5)
) AS o(text, is_correct, order_index);

-- Q2 | drag_and_drop | fácil | On-premises, IaaS, PaaS e SaaS | Exercícios 1 | s1: On-premises, s2: IaaS, s3: PaaS, s4: SaaS
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Na analogia da festa de aniversário, cada opção equivale a um modelo. Fazer tudo na própria casa: {{s1}}. Alugar apenas o salão: {{s2}}. Contratar o buffet com a comida pronta: {{s3}}. Ir a um parque de diversões com pacote completo: {{s4}}.', 'Em casa você gerencia tudo (on-premises); no salão alugado o espaço é do fornecedor (IaaS); no buffet a festa é preparada e servida (PaaS); no parque tudo vem pronto (SaaS).'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 8
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Infraestrutura e Diagrama de Solução Técnica — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('SaaS', 1), ('Mainframe', 2), ('PaaS', 3), ('On-premises', 4), ('IaaS', 5), ('Backup', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'On-premises', 1), ('s2', 'IaaS', 2), ('s3', 'PaaS', 3), ('s4', 'SaaS', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q3 | multiple_choice | média | On-premises, IaaS, PaaS e SaaS | Exercícios 1 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma pequena empresa quer controlar suas finanças com uma solução pronta, acessada pela internet, sem se preocupar com manutenção, atualizações ou compra de licenças. Qual modelo atende a esse cenário?', 'SaaS (software como serviço) oferece soluções prontas voltadas aos processos de negócio: o usuário não se preocupa com manutenção, atualizações ou aquisição de licenças.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 8
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Infraestrutura e Diagrama de Solução Técnica — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('SaaS, pois entrega o software pronto como serviço.', true, 1),
  ('PaaS, pois entrega uma plataforma para desenvolver.', false, 2),
  ('IaaS, pois entrega os servidores para configurar.', false, 3),
  ('On-premises, pois mantém o servidor na empresa.', false, 4),
  ('Mainframe, pois centraliza todo o processamento.', false, 5)
) AS o(text, is_correct, order_index);

-- Q4 | multiple_answer | difícil | Virtualização | Exercícios 2 | corretas: B, C, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma empresa migra seus servidores do modelo convencional para o virtualizado. Que características do modelo virtualizado o material aponta? Assinale todas as corretas.', 'O modelo virtualizado tem balanceamento ativo, máxima eficiência (uma máquina, vários serviços) e crescimento com velocidade. Hardware dedicado e capacidade limitada são do convencional.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 8
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Infraestrutura e Diagrama de Solução Técnica — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Hardwares dedicados para cada serviço.', false, 1),
  ('Balanceamento ativo da carga de trabalho.', true, 2),
  ('Uma única máquina para vários serviços.', true, 3),
  ('Capacidade limitada de processamento.', false, 4),
  ('Capacidade de crescer com velocidade.', true, 5)
) AS o(text, is_correct, order_index);

-- Q5 | single_choice | difícil | On-premises, IaaS, PaaS e SaaS | Exercícios 2 | b1: on-premises, b2: IaaS, b3: PaaS, b4: infraestrutura
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'No modelo {{b1}}, o servidor fica dentro da empresa, que precisa de espaço físico, segurança e equipe de TI. No {{b2}}, contratam-se recursos de computação totalmente configuráveis. No {{b3}}, há uma plataforma para desenvolver e implantar soluções sem gerenciar a {{b4}}.', 'On-premises mantém o servidor na empresa; IaaS oferece infraestrutura configurável sob demanda; PaaS oferece a plataforma de desenvolvimento sem a gestão da infraestrutura.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 8
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Infraestrutura e Diagrama de Solução Técnica — Exercícios 2: Aplicação'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'SaaS', false, 1), ('b1', 'on-premises', true, 2), ('b1', 'PaaS', false, 3),
  ('b2', 'IaaS', true, 1), ('b2', 'SaaS', false, 2), ('b2', 'mainframe', false, 3),
  ('b3', 'IaaS', false, 1), ('b3', 'on-premises', false, 2), ('b3', 'PaaS', true, 3),
  ('b4', 'aplicação', false, 1), ('b4', 'infraestrutura', true, 2), ('b4', 'equipe', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q6 | multiple_choice | super difícil | On-premises, IaaS, PaaS e SaaS | Exercícios 3 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma software house quer desenvolver e implantar sua aplicação sem administrar servidores, e vai escolher um provedor para isso. Que modelo é esse e que cuidado o material recomenda na escolha?', 'PaaS oferece plataformas para desenvolvimento e implantação sem gerenciar a infraestrutura. É importante contar com provedores que tenham alta disponibilidade e segurança.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 8
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Infraestrutura e Diagrama de Solução Técnica — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('IaaS; dimensionar o espaço físico dentro da empresa.', false, 1),
  ('SaaS; adquirir as licenças antes de usar o serviço.', false, 2),
  ('PaaS; exigir alta disponibilidade e segurança.', true, 3),
  ('On-premises; contratar mais terminais passivos.', false, 4),
  ('PaaS; manter equipe própria para os servidores.', false, 5)
) AS o(text, is_correct, order_index);

-- Q7 | drag_and_drop | difícil | Infraestrutura de TI: do mainframe à nuvem | Exercícios 2 | s1: servidores convencionais, s2: servidores virtualizados, s3: venda de espaços em data center, s4: computação na nuvem
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Depois da era dos mainframes, a infraestrutura de TI evoluiu nesta ordem: {{s1}} → {{s2}} → {{s3}} → {{s4}}.', 'A evolução parte dos servidores convencionais, passa pelos virtualizados e pela venda de espaços em data center (IaaS) e chega à computação na nuvem (PaaS e SaaS).'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 8
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Infraestrutura e Diagrama de Solução Técnica — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('diagrama de solução', 1), ('venda de espaços em data center', 2), ('servidores convencionais', 3), ('servidores virtualizados', 4), ('backup incremental', 5), ('computação na nuvem', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'servidores convencionais', 1), ('s2', 'servidores virtualizados', 2), ('s3', 'venda de espaços em data center', 3), ('s4', 'computação na nuvem', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q8 | multiple_choice | média | Backup | Exercícios 1 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma empresa faz backup de seus sistemas toda noite, mas nunca tentou restaurar os dados copiados. O que o material diz sobre essa prática?', 'O backup existe para que os dados possam ser restaurados em caso de perda. Por isso a recuperação dos dados e os testes do processo são fundamentais.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 8
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Infraestrutura e Diagrama de Solução Técnica — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('É suficiente, pois o backup periódico já garante tudo.', false, 1),
  ('É indiferente, pois o backup em nuvem nunca falha.', false, 2),
  ('É correta, pois testar o backup desgasta os discos.', false, 3),
  ('É opcional, pois só o backup full precisa de teste.', false, 4),
  ('É falha, pois recuperar e testar são fundamentais.', true, 5)
) AS o(text, is_correct, order_index);

-- Q9 | multiple_answer | super difícil | Arquitetura de TI e diagrama de solução | Exercícios 3 | corretas: A, C, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Um grupo prepara o diagrama de solução técnica de seu projeto. Segundo o material, quais são objetivos de um diagrama? Assinale todas as corretas.', 'O diagrama fornece uma visão geral, facilita o entendimento e a organização dos recursos, mostra a conexão entre os elementos e permite identificar problemas e oportunidades.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 8
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Infraestrutura e Diagrama de Solução Técnica — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Fornecer uma visão geral dos recursos da solução.', true, 1),
  ('Substituir toda a documentação do projeto.', false, 2),
  ('Mostrar a conexão que existe entre os elementos.', true, 3),
  ('Detalhar o código-fonte de cada tela do sistema.', false, 4),
  ('Permitir identificar problemas e oportunidades.', true, 5)
) AS o(text, is_correct, order_index);

-- Q10 | multiple_choice | fácil | Infraestrutura de TI: do mainframe à nuvem | Exercícios 1 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Segundo o material, como eram os ambientes de TI das empresas até 1980?', 'Até 1980 os ambientes eram dominados por mainframes: o processamento era centralizado e os usuários usavam terminais passivos, só para entrada e saída de informações.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 8
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Infraestrutura e Diagrama de Solução Técnica — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Dominados pela nuvem, com software como serviço.', false, 1),
  ('Dominados por mainframes, com terminais passivos.', true, 2),
  ('Dominados por servidores virtuais e isolados.', false, 3),
  ('Dominados por notebooks, com dados distribuídos.', false, 4),
  ('Dominados por plataformas de desenvolvimento.', false, 5)
) AS o(text, is_correct, order_index);

-- Q11 | single_choice | super difícil | Backup | Exercícios 3 | b1: cópia de segurança, b2: outro ambiente, b3: restaurados, b4: incremental
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Backup é a {{b1}} dos dados de um dispositivo ou sistema para {{b2}}, para que eles possam ser {{b3}} em caso de perda dos originais. Ele pode ser full ou {{b4}}.', 'Backup é a cópia de segurança dos dados para outro ambiente, feita para que possam ser restaurados em caso de perda. Pode ser full ou incremental.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 8
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Infraestrutura e Diagrama de Solução Técnica — Exercícios 3: Desafio'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'virtualização', false, 1), ('b1', 'cópia de segurança', true, 2), ('b1', 'exclusão', false, 3),
  ('b2', 'o mesmo disco', false, 1), ('b2', 'o terminal passivo', false, 2), ('b2', 'outro ambiente', true, 3),
  ('b3', 'restaurados', true, 1), ('b3', 'vendidos', false, 2), ('b3', 'virtualizados', false, 3),
  ('b4', 'convencional', false, 1), ('b4', 'incremental', true, 2), ('b4', 'passivo', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q12 | drag_and_drop | super difícil | On-premises, IaaS, PaaS e SaaS | Exercícios 3 | s1: SaaS, s2: PaaS, s3: IaaS, s4: On-premises
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Classifique cada caso. Conta Azul, Salesforce e Trello: {{s1}}. Docker e hospedagem de sites: {{s2}}. Servidores, armazenamento e processamento dimensionados conforme a demanda: {{s3}}. Servidor instalado dentro da empresa, com equipe de TI para manutenção: {{s4}}.', 'Soluções prontas de negócio são SaaS; plataformas de desenvolvimento e implantação são PaaS; recursos de computação configuráveis são IaaS; servidor na própria empresa é on-premises.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 8
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Infraestrutura e Diagrama de Solução Técnica — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('Backup full', 1), ('IaaS', 2), ('Mainframe', 3), ('PaaS', 4), ('On-premises', 5), ('SaaS', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'SaaS', 1), ('s2', 'PaaS', 2), ('s3', 'IaaS', 3), ('s4', 'On-premises', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q13 | multiple_choice | difícil | Documentação viva e responsáveis | Exercícios 2 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'No Trello de um projeto, a tarefa "configurar o servidor" tem quatro responsáveis e ninguém a executa. Que dica do material explica o problema?', 'Responsável é apenas um: "cachorro que tem dois donos morre de fome". Sem divisão clara, ninguém faz o trabalho, pois cada um acha que o outro vai fazer.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 8
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Infraestrutura e Diagrama de Solução Técnica — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Responsável é só um: tarefa de todos fica sem dono.', true, 1),
  ('Prioridade quem escolhe é o PO, em ordem de 01 a 05.', false, 2),
  ('Documentação é viva e deve mudar junto com o projeto.', false, 3),
  ('Menor é melhor: o time deve ter menos integrantes.', false, 4),
  ('Planeje apenas o necessário para a sprint em curso.', false, 5)
) AS o(text, is_correct, order_index);

-- Q14 | multiple_answer | super difícil | Arquitetura de TI e diagrama de solução | Exercícios 3 | corretas: A, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma rede de lojas vai reorganizar seus servidores e sistemas. Sobre a arquitetura de TI, o que o material afirma? Assinale todas as corretas.', 'A arquitetura de TI é responsabilidade da área de TI, que analisa as necessidades do negócio e a infraestrutura para planejar a alocação e a distribuição dos ativos tecnológicos.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 8
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Infraestrutura e Diagrama de Solução Técnica — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('É uma responsabilidade da área de TI.', true, 1),
  ('Ignora as necessidades do negócio.', false, 2),
  ('Trata apenas da compra de softwares.', false, 3),
  ('Planeja a alocação dos ativos de TI.', true, 4),
  ('Dispensa a análise da infraestrutura.', false, 5)
) AS o(text, is_correct, order_index);

-- Q15 | drag_and_drop | difícil | Virtualização | Exercícios 2 | s1: ociosidade, s2: dedicados, s3: ativo, s4: eficiência
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'No modelo convencional há momentos de pico e de {{s1}}, com hardwares {{s2}}. No modelo virtualizado há balanceamento {{s3}} da carga e máxima {{s4}}: uma máquina, vários serviços.', 'O convencional alterna pico e ociosidade e usa hardwares dedicados. O virtualizado faz balanceamento ativo na carga e no processamento, com máxima eficiência.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Tecnologia da Informação' AND t.number = 8
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Infraestrutura e Diagrama de Solução Técnica — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('dedicados', 1), ('passivo', 2), ('ativo', 3), ('isolamento', 4), ('ociosidade', 5), ('eficiência', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'ociosidade', 1), ('s2', 'dedicados', 2), ('s3', 'ativo', 3), ('s4', 'eficiência', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- 8. Conferência: aborta se alguma questão ficou fora das listas ou alguma lista ficou vazia
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM questions q
    JOIN topics t ON t.id = q.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 8
      AND NOT EXISTS (
        SELECT 1 FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
        WHERE qq.question_id = q.id AND z.kind = 'exercise'
      )
  ) THEN
    RAISE EXCEPTION 'Há questão da aula 8 de Tecnologia da Informação fora das listas de exercícios';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM quizzes z
    JOIN topics t ON t.id = z.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Tecnologia da Informação' AND t.number = 8 AND z.kind = 'exercise'
      AND NOT EXISTS (SELECT 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  ) THEN
    RAISE EXCEPTION 'Há lista de exercícios da aula 8 de Tecnologia da Informação sem questões';
  END IF;
END $$;

COMMIT;
