-- Arquitetura Computacional: aulas 1, 2, 3, 4 — assuntos, subassuntos, pontos-chave,
-- questões e listas de exercícios. Gerado a partir de temp/prompt-questoes.txt e dos PDFs
-- ARQ-SP1-AULA1.pdf, ARQ-SP1-AULA2.pdf, ARQ-SP2-AULA1.pdf, ARQ-SP2-AULA2.pdf.
-- Uma única transação: se qualquer comando falhar, nada é gravado.
-- Não rode duas vezes: as questões seriam duplicadas.

BEGIN;

-- =====================================================================
-- AULA 1 — Características Técnicas de um Sistema Computacional (ARQ-SP1-AULA1.pdf)
-- =====================================================================

-- 1. Disciplina
INSERT INTO subjects (name, short_label)
SELECT 'Arquitetura Computacional', 'ARQ'
WHERE NOT EXISTS (SELECT 1 FROM subjects WHERE name = 'Arquitetura Computacional');

-- 2. Assunto
INSERT INTO topics (subject_id, number, name, description)
SELECT s.id, 1, 'Características Técnicas de um Sistema Computacional', 'Do bit ao boot: por que o computador usa binário e hexadecimal, a arquitetura de von Neumann, o firmware e o clock.'
FROM subjects s
WHERE s.name = 'Arquitetura Computacional'
ON CONFLICT DO NOTHING;

-- 3. Trava: aborta se a aula não existir ou já existir com outro nome
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM topics t JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Arquitetura Computacional' AND t.number = 1 AND t.name = 'Características Técnicas de um Sistema Computacional'
  ) THEN
    RAISE EXCEPTION 'A aula 1 de Arquitetura Computacional não existe ou já está cadastrada com outro nome';
  END IF;
END $$;

-- 4. Subassuntos
INSERT INTO subtopics (topic_id, name, summary, order_index)
SELECT t.id, v.name, v.summary, v.order_index
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Por que base 2: margem de ruído', 'O hardware usa binário porque dois níveis de tensão são fáceis de distinguir mesmo com ruído. A escolha troca economia de símbolos por confiabilidade.', 1),
  ('Octal e hexadecimal: bases para o humano', 'Octal e hexadecimal não existem para a máquina, e sim para o humano ler binário. Como 8 e 16 são potências de 2, cada dígito equivale a um bloco fixo de bits.', 2),
  ('Von Neumann e o programa armazenado', 'Instrução e dado ficam na mesma memória, no mesmo formato binário, e a máquina os distingue pelo contexto de leitura. É isso que torna o computador programável.', 3),
  ('Firmware e o processo de boot', 'A RAM é volátil, então a primeira instrução vem de um chip não volátil, apontado pelo reset vector. O firmware testa o hardware, carrega o bootloader e entrega o controle.', 4),
  ('Clock, desempenho e núcleos', 'O clock é o sinal de sincronismo que diz quando um valor é válido; ele coordena, mas não acelera nada sozinho. O desempenho depende também do IPC e da arquitetura.', 5),
  ('Soquete e espaço de endereçamento', 'O soquete define quais processadores encaixam na placa-mãe. A quantidade de bits do endereço define quanta memória pode ser endereçada.', 6)
) AS v(name, summary, order_index)
WHERE s.name = 'Arquitetura Computacional' AND t.number = 1
ON CONFLICT DO NOTHING;

-- 5. Pontos-chave
INSERT INTO subtopic_key_points (subtopic_id, text, order_index)
SELECT st.id, v.text, v.order_index
FROM subtopics st
JOIN topics t ON t.id = st.topic_id
JOIN subjects s ON s.id = t.subject_id
JOIN (VALUES
  ('Por que base 2: margem de ruído', 'O transistor é uma chave: com tensão (3,3 V) é 1, sem tensão (0 V) é 0, separados por um limiar.', 1),
  ('Por que base 2: margem de ruído', 'Base 10 no hardware exigiria dez níveis de tensão: 3,3 V ÷ 10 = 0,33 V de margem por dígito.', 2),
  ('Por que base 2: margem de ruído', 'Ruído térmico, queda no barramento, tolerância da fonte, temperatura e interferência somam décimos de volt e causariam corrupção silenciosa.', 3),
  ('Por que base 2: margem de ruído', 'Com dois níveis a margem é 3,3 V ÷ 2 = 1,65 V, cinco vezes mais folga.', 4),
  ('Por que base 2: margem de ruído', 'O custo é usar mais dígitos: 156 tem 3 símbolos em decimal e 8 em binário (10011100).', 5),
  ('Octal e hexadecimal: bases para o humano', '8 = 2³ e 16 = 2⁴: cada dígito corresponde a um bloco fixo de 3 ou 4 bits, sem fazer conta.', 1),
  ('Octal e hexadecimal: bases para o humano', '10 não é potência de 2: converter binário para decimal exige divisão e multiplicação.', 2),
  ('Octal e hexadecimal: bases para o humano', '1 byte = 8 bits = 2 dígitos hexadecimais exatos; em octal sobra bit (8 ÷ 3 = 2,67).', 3),
  ('Octal e hexadecimal: bases para o humano', 'chmod 755: cada dígito octal são os 3 bits rwx (7 = rwx para o dono, 5 = r-x para grupo e outros).', 4),
  ('Octal e hexadecimal: bases para o humano', 'Endereço de memória, endereço MAC, cor em CSS e IPv6 usam hexadecimal porque representam blocos de bits.', 5),
  ('Von Neumann e o programa armazenado', 'O bit não sabe o que é: 01001000 pode ser o número 72, o caractere H, uma instrução ou um tom de cinza.', 1),
  ('Von Neumann e o programa armazenado', 'Cinco partes: memória, unidade de controle, ULA, entrada e saída, com um barramento único entre memória e CPU.', 2),
  ('Von Neumann e o programa armazenado', 'Ciclo da CPU: buscar, decodificar, executar e escrever, repetido bilhões de vezes por segundo.', 3),
  ('Von Neumann e o programa armazenado', 'Consequências: um programa pode gravar onde outro mora (buffer overflow, injeção de código) e a CPU espera a memória (gargalo de von Neumann).', 4),
  ('Von Neumann e o programa armazenado', 'Harvard separa memória de instrução e de dados com barramentos próprios; é rígida, mais cara e usada no Arduino.', 5),
  ('Firmware e o processo de boot', 'Reset vector: endereço fixo de fábrica, gravado no silício, onde a CPU busca a primeira instrução.', 1),
  ('Firmware e o processo de boot', 'Firmware é software gravado em hardware não volátil; BIOS e UEFI são implementações de firmware.', 2),
  ('Firmware e o processo de boot', 'Etapas: POST, inicialização, procura do dispositivo de boot, carga do bootloader para a RAM e entrega do controle.', 3),
  ('Firmware e o processo de boot', 'BIOS: 16 bits em modo real, MBR (disco até 2 TB), boot no setor 0 do disco e nenhuma verificação.', 4),
  ('Firmware e o processo de boot', 'UEFI: 32 ou 64 bits, GPT, partição EFI formatada em FAT e Secure Boot com assinatura digital.', 5),
  ('Clock, desempenho e núcleos', 'Cada borda do clock é uma permissão de avanço: 3 GHz são 3 bilhões de oportunidades por segundo.', 1),
  ('Clock, desempenho e núcleos', 'Desempenho ≈ clock × IPC × arquitetura; IPC são as instruções concluídas por ciclo.', 2),
  ('Clock, desempenho e núcleos', 'Muro térmico: dobrar o clock quadruplica o calor, e a corrida dos MHz parou por volta de 2005.', 3),
  ('Clock, desempenho e núcleos', 'Núcleo físico é um ciclo de von Neumann completo; o núcleo lógico (SMT/Hyper-Threading) rende de 15% a 30%.', 4),
  ('Clock, desempenho e núcleos', 'Turbo Boost e Precision Boost elevam a frequência enquanto temperatura e consumo permitirem: a frequência da caixa é teto.', 5),
  ('Soquete e espaço de endereçamento', 'Soquete é o contrato físico e elétrico entre CPU e placa-mãe: Intel usa LGA; AMD usa AM4 (PGA) e AM5 (LGA).', 1),
  ('Soquete e espaço de endereçamento', 'Soquete errado não é incompatibilidade de software: é peça que não entra.', 2),
  ('Soquete e espaço de endereçamento', 'Endereço de 32 bits: 2³² = 4.294.967.296 endereços, com um byte em cada, ou seja, 4 GiB.', 3),
  ('Soquete e espaço de endereçamento', 'Por isso o Windows de 32 bits nunca enxergou mais que 4 GB de RAM.', 4)
) AS v(subtopic_name, text, order_index) ON v.subtopic_name = st.name
WHERE s.name = 'Arquitetura Computacional' AND t.number = 1
ON CONFLICT DO NOTHING;

-- 6. Listas de exercícios
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT v.title, 'exercise', t.subject_id, t.id, NULL, v.difficulty::difficulty_level
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Características Técnicas de um Sistema Computacional — Exercícios 1: Fundamentos', 'easy'),
  ('Características Técnicas de um Sistema Computacional — Exercícios 2: Aplicação', 'medium'),
  ('Características Técnicas de um Sistema Computacional — Exercícios 3: Desafio', 'hard')
) AS v(title, difficulty)
WHERE s.name = 'Arquitetura Computacional' AND t.number = 1
  AND NOT EXISTS (SELECT 1 FROM quizzes z WHERE z.title = v.title);

-- 7. Questões

-- Q1 | multiple_choice | difícil | Por que base 2: margem de ruído | Exercícios 2 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma startup de hardware propõe um processador que representa os dígitos de 0 a 9 diretamente em níveis de tensão, com alimentação de 3,3 V. Qual é o principal problema dessa proposta?', 'Dez símbolos exigem dez níveis de tensão distinguíveis: 3,3 V ÷ 10 = 0,33 V por dígito. Os ruídos somados chegam a décimos de volt, e um 4 viraria 5 sem ninguém saber.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Características Técnicas de um Sistema Computacional — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Cada dígito teria 1,65 V de margem, o que deixaria o chip lento demais para uso real.', false, 1),
  ('A base 10 exigiria um transistor por dígito, o que elevaria demais o custo do chip.', false, 2),
  ('Sobrariam só 0,33 V por dígito, margem que o ruído somado facilmente ultrapassa.', true, 3),
  ('A base 10 não é potência de 2, e a memória ficaria sem nenhum endereço válido.', false, 4),
  ('Os dez níveis gastariam dez vezes mais energia, e o chip bateria no muro térmico.', false, 5)
) AS o(text, is_correct, order_index);

-- Q2 | essay_blanks | fácil | Von Neumann e o programa armazenado | Exercícios 1 | b1: armazenado, b2: memória
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, template)
  SELECT t.id, 'essay_blanks', 'Complete a frase sobre a arquitetura de von Neumann.', 'Na ideia de programa {{b1}}, instrução e dado ficam na mesma {{b2}}, no mesmo formato binário.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Características Técnicas de um Sistema Computacional — Exercícios 1: Fundamentos'
)
INSERT INTO question_blanks (question_id, blank_key, reference_answer, order_index)
SELECT q.id, v.blank_key, v.reference_answer, v.order_index
FROM q CROSS JOIN (VALUES ('b1', 'armazenado', 1), ('b2', 'memória', 2)) AS v(blank_key, reference_answer, order_index);

-- Q3 | multiple_answer | super difícil | Firmware e o processo de boot | Exercícios 3 | corretas: A, C, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'A equipe de infraestrutura de uma empresa vai preparar um servidor com disco de 8 TB e exige que o carregador de boot seja verificado por assinatura digital. Assinale todas as corretas sobre a escolha do firmware.', 'O UEFI usa GPT, guarda o boot em uma partição EFI em FAT e oferece Secure Boot. O BIOS usa MBR (disco até 2 TB), boot no setor 0 e nenhuma verificação.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Características Técnicas de um Sistema Computacional — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('O UEFI atende à exigência, pois o Secure Boot verifica a assinatura digital.', true, 1),
  ('O BIOS atende ao disco, pois o particionamento MBR suporta discos de até 8 TB.', false, 2),
  ('Com UEFI, o disco usa o particionamento GPT, que suporta discos muito maiores.', true, 3),
  ('No UEFI, o boot fica no setor 0 do disco, sem depender de nenhuma partição.', false, 4),
  ('O BIOS não faz nenhuma verificação do que carrega e não atende à exigência.', true, 5)
) AS o(text, is_correct, order_index);

-- Q4 | multiple_choice | fácil | Octal e hexadecimal: bases para o humano | Exercícios 1 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Por que endereços de memória são escritos em hexadecimal, e não em decimal?', 'Como 16 = 2⁴, cada dígito hexadecimal corresponde a exatamente 4 bits: a conversão vira recorte, não conta. Octal e hexadecimal existem para o humano, não para a máquina.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Características Técnicas de um Sistema Computacional — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Porque 16 é potência de 2, e cada dígito hexa equivale a um bloco fixo de 4 bits.', true, 1),
  ('Porque a CPU faz as contas em base 16 e só depois converte o valor para binário.', false, 2),
  ('Porque cada dígito hexa equivale a um byte inteiro, sem sobrar nenhum bit.', false, 3),
  ('Porque o hexadecimal ocupa menos espaço na memória do que o valor em binário.', false, 4),
  ('Porque o decimal não consegue representar valores acima de 4.294.967.296.', false, 5)
) AS o(text, is_correct, order_index);

-- Q5 | single_choice | difícil | Firmware e o processo de boot | Exercícios 2 | b1: reset vector, b2: não volátil, b3: firmware, b4: bootloader
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Ao ligar o computador, a CPU busca a primeira instrução no {{b1}}, um endereço fixo de fábrica. Nesse endereço há um chip {{b2}} com o {{b3}}, que executa o POST e, depois de achar o dispositivo de boot, carrega o {{b4}} do disco para a RAM.', 'A RAM acorda vazia, então a CPU lê o reset vector, onde está o firmware em um chip não volátil. Ele testa o hardware (POST), procura o dispositivo de boot e carrega o bootloader para a RAM.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Características Técnicas de um Sistema Computacional — Exercícios 2: Aplicação'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'setor 0 do disco', false, 1), ('b1', 'reset vector', true, 2), ('b1', 'bootloader', false, 3),
  ('b2', 'volátil', false, 1), ('b2', 'de memória RAM', false, 2), ('b2', 'não volátil', true, 3),
  ('b3', 'firmware', true, 1), ('b3', 'sistema operacional', false, 2), ('b3', 'bootloader', false, 3),
  ('b4', 'firmware', false, 1), ('b4', 'bootloader', true, 2), ('b4', 'reset vector', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q6 | multiple_choice | super difícil | Clock, desempenho e núcleos | Exercícios 3 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Uma loja anuncia dois processadores: o modelo X, de dez anos atrás, com 4,2 GHz, e o modelo Y, atual, com 3,8 GHz. Um cliente conclui que o X é o mais rápido. Qual análise está correta?', 'Desempenho ≈ clock × IPC × arquitetura. O clock só autoriza o avanço, e um chip atual de 3,8 GHz conclui mais instruções por ciclo do que um de 4,2 GHz de dez anos atrás.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Características Técnicas de um Sistema Computacional — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('O cliente acerta, pois o clock mede as instruções concluídas a cada segundo.', false, 1),
  ('O cliente acerta, pois a frequência da caixa é uma garantia de desempenho.', false, 2),
  ('O cliente erra, pois cada núcleo lógico do modelo Y dobra o desempenho.', false, 3),
  ('O cliente erra, pois acima de 4 GHz o muro térmico impede o chip de operar.', false, 4),
  ('O cliente erra, pois o desempenho depende também do IPC e da arquitetura.', true, 5)
) AS o(text, is_correct, order_index);

-- Q7 | drag_and_drop | média | Von Neumann e o programa armazenado | Exercícios 1 | s1: busca, s2: decodifica, s3: executa, s4: escreve
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'A cada instrução, a CPU repete quatro etapas: primeiro ela {{s1}} a instrução no endereço apontado, depois {{s2}} qual operação é aquela, em seguida {{s3}} a operação na ULA e, por fim, {{s4}} o resultado.', 'O ciclo de von Neumann é buscar, decodificar, executar e escrever, repetido bilhões de vezes por segundo até o computador ser desligado.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Características Técnicas de um Sistema Computacional — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('executa', 1), ('compila', 2), ('busca', 3), ('escreve', 4), ('inicializa', 5), ('decodifica', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'busca', 1), ('s2', 'decodifica', 2), ('s3', 'executa', 3), ('s4', 'escreve', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q8 | multiple_answer | difícil | Von Neumann e o programa armazenado | Exercícios 2 | corretas: A, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'A equipe de segurança de um banco analisa um ataque de buffer overflow em um servidor. Assinale todas as corretas sobre a relação entre esse ataque e a arquitetura de von Neumann.', 'Instrução e dado moram na mesma memória e no mesmo formato, então um programa pode gravar bytes onde outro mora. Isso é consequência direta da arquitetura, não defeito de implementação.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Características Técnicas de um Sistema Computacional — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Ele é possível porque instrução e dado são indistinguíveis na memória.', true, 1),
  ('Ele decorre de um defeito de implementação, e não da arquitetura.', false, 2),
  ('Ele só ocorre porque CPU e memória disputam o mesmo barramento.', false, 3),
  ('Um programa pode gravar bytes onde outro programa está armazenado.', true, 4),
  ('A máquina distingue instrução de dado pelo conteúdo dos bits lidos.', false, 5)
) AS o(text, is_correct, order_index);

-- Q9 | multiple_choice | fácil | Por que base 2: margem de ruído | Exercícios 1 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Por que os computadores usam a base 2?', 'Base 2 não é elegância matemática, é margem de ruído: com dois níveis sobram 1,65 V de folga, e a máquina lê sem errar mesmo com componentes baratos e imperfeitos.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Características Técnicas de um Sistema Computacional — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Porque a base 2 gasta menos símbolos que a base 10 em um mesmo número.', false, 1),
  ('Porque dois níveis de tensão dão margem de ruído para ler sem errar.', true, 2),
  ('Porque a base 2 é a mais elegante matematicamente entre todas as bases.', false, 3),
  ('Porque o transistor tem dez níveis de tensão, mas só dois são baratos.', false, 4),
  ('Porque a base 2 é a mais fácil de ler e de ditar para um ser humano.', false, 5)
) AS o(text, is_correct, order_index);

-- Q10 | essay_blanks | média | Octal e hexadecimal: bases para o humano | Exercícios 1 | b1: humano, b2: bits
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, template)
  SELECT t.id, 'essay_blanks', 'Complete a frase sobre as bases octal e hexadecimal.', 'Octal e hexadecimal não existem para a máquina, e sim para o {{b1}}; cada dígito hexadecimal corresponde a um bloco fixo de quatro {{b2}}.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Características Técnicas de um Sistema Computacional — Exercícios 1: Fundamentos'
)
INSERT INTO question_blanks (question_id, blank_key, reference_answer, order_index)
SELECT q.id, v.blank_key, v.reference_answer, v.order_index
FROM q CROSS JOIN (VALUES ('b1', 'humano', 1), ('b2', 'bits', 2)) AS v(blank_key, reference_answer, order_index);

-- Q11 | multiple_choice | super difícil | Von Neumann e o programa armazenado | Exercícios 3 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um engenheiro projeta o microcontrolador de um sensor industrial cujo programa nunca muda em operação e que deve buscar instrução e dado ao mesmo tempo. Qual arquitetura e qual justificativa estão corretas?', 'Harvard separa memória de instrução e de dados, cada uma com seu barramento, e busca os dois ao mesmo tempo. Em troca é rígida e mais cara; é o que há dentro do Arduino.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Características Técnicas de um Sistema Computacional — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Von Neumann, pois o barramento único busca instrução e dado ao mesmo tempo.', false, 1),
  ('Von Neumann, pois ela impede que o programa seja alterado em execução.', false, 2),
  ('Harvard, pois ela guarda instrução e dado na mesma memória e barateia o chip.', false, 3),
  ('Harvard, pois as memórias separadas têm barramentos próprios, sem gargalo.', true, 4),
  ('Harvard, pois ela é flexível e deixa o programa se reescrever em operação.', false, 5)
) AS o(text, is_correct, order_index);

-- Q12 | drag_and_drop | super difícil | Firmware e o processo de boot | Exercícios 3 | s1: 16 bits, modo real, s2: MBR, s3: setor 0 do disco, s4: GPT, s5: partição EFI em FAT, s6: Secure Boot
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Em um PC com BIOS, a CPU inicia em {{s1}}, o disco usa particionamento {{s2}} e o boot fica no {{s3}}. Em um PC com UEFI, o particionamento é {{s4}}, o boot fica na {{s5}} e a verificação é feita pelo {{s6}}.', 'O BIOS roda em 16 bits (modo real), usa MBR, busca o boot no setor 0 e não verifica nada. O UEFI roda em 32 ou 64 bits, usa GPT, guarda o boot na partição EFI em FAT e tem Secure Boot.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Características Técnicas de um Sistema Computacional — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('GPT', 1), ('setor 0 do disco', 2), ('reset vector', 3), ('Secure Boot', 4), ('16 bits, modo real', 5), ('partição EFI em FAT', 6), ('POST', 7), ('MBR', 8)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', '16 bits, modo real', 1), ('s2', 'MBR', 2), ('s3', 'setor 0 do disco', 3), ('s4', 'GPT', 4), ('s5', 'partição EFI em FAT', 5), ('s6', 'Secure Boot', 6))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q13 | multiple_choice | difícil | Soquete e espaço de endereçamento | Exercícios 2 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'O suporte de uma empresa recebe a reclamação de que estações com Windows de 32 bits e 8 GB de RAM instalados aproveitam só parte da memória. Qual é a explicação?', 'Com 32 bits de endereço existem 2³² = 4.294.967.296 endereços; com um byte em cada, são 4 GiB. Por isso o Windows de 32 bits nunca enxergou mais que 4 GB de RAM.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Características Técnicas de um Sistema Computacional — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Endereços de 32 bits dão 2³² posições de um byte, o que limita a RAM a 4 GiB.', true, 1),
  ('Endereços de 32 bits dão 32 posições de um gigabyte, mas só 4 ficam livres.', false, 2),
  ('O soquete da placa-mãe é um contrato elétrico que limita a RAM a 4 GiB.', false, 3),
  ('O firmware BIOS só enxerga discos de até 2 TB, o que limita a RAM a 4 GiB.', false, 4),
  ('O clock de um chip de 32 bits não sincroniza módulos com mais de 4 GiB.', false, 5)
) AS o(text, is_correct, order_index);

-- Q14 | single_choice | super difícil | Clock, desempenho e núcleos | Exercícios 3 | b1: 8, b2: ociosos, b3: 15% a 30%, b4: temperatura e consumo
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Um processador anunciado como "8 núcleos / 16 threads" tem {{b1}} núcleos físicos. Os núcleos lógicos vêm do SMT, que aproveita ciclos que ficariam {{b2}} e traz um ganho típico de {{b3}}. Já o Turbo Boost eleva a frequência enquanto {{b4}} permitirem.', '"8 núcleos / 16 threads" são 8 núcleos de verdade e 16 filas: o SMT aproveita ciclos ociosos e rende de 15% a 30%, sem dobrar o desempenho. O Turbo Boost depende de temperatura e consumo.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Características Técnicas de um Sistema Computacional — Exercícios 3: Desafio'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', '16', false, 1), ('b1', '8', true, 2), ('b1', '24', false, 3),
  ('b2', 'ociosos', true, 1), ('b2', 'duplicados', false, 2), ('b2', 'travados', false, 3),
  ('b3', '50% a 100%', false, 1), ('b3', '5% a 10%', false, 2), ('b3', '15% a 30%', true, 3),
  ('b4', 'soquete e placa-mãe', false, 1), ('b4', 'temperatura e consumo', true, 2), ('b4', 'IPC e pipeline', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q15 | multiple_answer | difícil | Soquete e espaço de endereçamento | Exercícios 2 | corretas: B, D, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Um técnico vai trocar o processador de um computador por um modelo mais novo, de outra geração. Assinale todas as corretas.', 'O soquete é o contrato físico e elétrico entre CPU e placa-mãe, e soquete errado é peça que não entra. A frequência da caixa é teto, e dobrar o clock quadruplica o calor.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 1
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Características Técnicas de um Sistema Computacional — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Um soquete incompatível é resolvido com uma atualização de software.', false, 1),
  ('O soquete define quais processadores encaixam naquela placa-mãe.', true, 2),
  ('Dobrar o clock do processador dobraria também o calor que ele gera.', false, 3),
  ('A frequência anunciada na caixa do processador é teto, não garantia.', true, 4),
  ('Trocar de processador quase sempre significa trocar de placa-mãe.', true, 5)
) AS o(text, is_correct, order_index);

-- 8. Conferência: aborta se alguma questão ficou fora das listas ou alguma lista ficou vazia
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM questions q
    JOIN topics t ON t.id = q.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Arquitetura Computacional' AND t.number = 1
      AND NOT EXISTS (
        SELECT 1 FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
        WHERE qq.question_id = q.id AND z.kind = 'exercise'
      )
  ) THEN
    RAISE EXCEPTION 'Há questão da aula 1 de Arquitetura Computacional fora das listas de exercícios';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM quizzes z
    JOIN topics t ON t.id = z.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Arquitetura Computacional' AND t.number = 1 AND z.kind = 'exercise'
      AND NOT EXISTS (SELECT 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  ) THEN
    RAISE EXCEPTION 'Há lista de exercícios da aula 1 de Arquitetura Computacional sem questões';
  END IF;
END $$;

-- =====================================================================
-- AULA 2 — Sistemas de Numeração na Computação (ARQ-SP1-AULA2.pdf)
-- =====================================================================

-- 1. Disciplina
INSERT INTO subjects (name, short_label)
SELECT 'Arquitetura Computacional', 'ARQ'
WHERE NOT EXISTS (SELECT 1 FROM subjects WHERE name = 'Arquitetura Computacional');

-- 2. Assunto
INSERT INTO topics (subject_id, number, name, description)
SELECT s.id, 2, 'Sistemas de Numeração na Computação', 'As bases decimal, binária, octal e hexadecimal e os métodos de conversão entre elas.'
FROM subjects s
WHERE s.name = 'Arquitetura Computacional'
ON CONFLICT DO NOTHING;

-- 3. Trava: aborta se a aula não existir ou já existir com outro nome
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM topics t JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Arquitetura Computacional' AND t.number = 2 AND t.name = 'Sistemas de Numeração na Computação'
  ) THEN
    RAISE EXCEPTION 'A aula 2 de Arquitetura Computacional não existe ou já está cadastrada com outro nome';
  END IF;
END $$;

-- 4. Subassuntos
INSERT INTO subtopics (topic_id, name, summary, order_index)
SELECT t.id, v.name, v.summary, v.order_index
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Sistemas de numeração e notação posicional', 'Um sistema de numeração é um conjunto de regras e símbolos para representar números, e a base define quantos símbolos ele usa. Nos sistemas posicionais, o valor do algarismo depende da posição.', 1),
  ('Sistema binário', 'Usa apenas os algarismos 0 e 1, em posições que valem potências de 2. Converte-se de decimal por divisões sucessivas por 2 e para decimal somando as potências dos bits ligados.', 2),
  ('Sistema octal', 'Usa oito algarismos, de 0 a 7, e cada dígito equivale a um grupo de três bits.', 3),
  ('Sistema hexadecimal', 'Usa dezesseis algarismos, de 0 a 9 e de A a F, e cada dígito equivale a um grupo de quatro bits.', 4),
  ('Conversões diretas entre as bases', 'Como octal e hexadecimal agrupam bits, a conversão entre eles e o binário é direta, sem passar pelo decimal.', 5)
) AS v(name, summary, order_index)
WHERE s.name = 'Arquitetura Computacional' AND t.number = 2
ON CONFLICT DO NOTHING;

-- 5. Pontos-chave
INSERT INTO subtopic_key_points (subtopic_id, text, order_index)
SELECT st.id, v.text, v.order_index
FROM subtopics st
JOIN topics t ON t.id = st.topic_id
JOIN subjects s ON s.id = t.subject_id
JOIN (VALUES
  ('Sistemas de numeração e notação posicional', 'A base determina quantos símbolos diferentes o sistema usa: 10 no decimal, 2 no binário, 8 no octal e 16 no hexadecimal.', 1),
  ('Sistemas de numeração e notação posicional', 'Em um sistema posicional, cada algarismo muda de valor conforme a posição que ocupa no número.', 2),
  ('Sistemas de numeração e notação posicional', '594 em decimal = 5 x 10² + 9 x 10¹ + 4 x 10⁰.', 3),
  ('Sistemas de numeração e notação posicional', 'Binário, octal e hexadecimal são usados em circuitos digitais, automação e ambientes computacionais.', 4),
  ('Sistema binário', 'O binário tem apenas dois algarismos: 0 e 1.', 1),
  ('Sistema binário', 'Cada posição vale uma potência de 2 (1, 2, 4, 8, 16, 32, 64, 128...), da menos significativa, à direita, para a mais significativa.', 2),
  ('Sistema binário', 'Decimal para binário: divide-se sucessivamente por 2 e leem-se os restos do último para o primeiro.', 3),
  ('Sistema binário', 'Binário para decimal: somam-se as potências de 2 das posições com bit 1; 101 = 4 + 1 = 5.', 4),
  ('Sistema octal', 'O octal usa os algarismos de 0 a 7; 8 e 9 são dígitos inválidos nessa base.', 1),
  ('Sistema octal', 'O decimal 8 é escrito como 10 em octal.', 2),
  ('Sistema octal', 'Octal para decimal: 144 = 1 x 8² + 4 x 8¹ + 4 x 8⁰ = 64 + 32 + 4 = 100.', 3),
  ('Sistema octal', 'Cada dígito octal equivale a 3 bits: 34 em octal = 011 100 em binário.', 4),
  ('Sistema hexadecimal', 'As letras valem: A = 10, B = 11, C = 12, D = 13, E = 14 e F = 15.', 1),
  ('Sistema hexadecimal', 'Hexadecimal para decimal: 3F = 3 x 16 + 15 = 63.', 2),
  ('Sistema hexadecimal', 'Cada dígito hexadecimal equivale a 4 bits: C13 = 1100 0001 0011.', 3),
  ('Sistema hexadecimal', 'Decimal para hexadecimal: divisões sucessivas por 16 (1000 = 3E8) ou passando pelo binário.', 4),
  ('Conversões diretas entre as bases', 'Binário para octal: agrupam-se 3 bits da direita para a esquerda; 110010 = 62.', 1),
  ('Conversões diretas entre as bases', 'Binário para hexadecimal: agrupam-se 4 bits da direita para a esquerda; 10011000 = 98.', 2),
  ('Conversões diretas entre as bases', 'O mesmo valor tem várias escritas: 1020 em decimal = 1111111100 em binário = 1774 em octal = 3FC em hexadecimal.', 3),
  ('Conversões diretas entre as bases', 'Em operações, o resultado pode ser pedido em qualquer base: BA + CA em hexadecimal = 184, que é 388 em decimal.', 4)
) AS v(subtopic_name, text, order_index) ON v.subtopic_name = st.name
WHERE s.name = 'Arquitetura Computacional' AND t.number = 2
ON CONFLICT DO NOTHING;

-- 6. Listas de exercícios
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT v.title, 'exercise', t.subject_id, t.id, NULL, v.difficulty::difficulty_level
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Sistemas de Numeração na Computação — Exercícios 1: Fundamentos', 'easy'),
  ('Sistemas de Numeração na Computação — Exercícios 2: Aplicação', 'medium'),
  ('Sistemas de Numeração na Computação — Exercícios 3: Desafio', 'hard')
) AS v(title, difficulty)
WHERE s.name = 'Arquitetura Computacional' AND t.number = 2
  AND NOT EXISTS (SELECT 1 FROM quizzes z WHERE z.title = v.title);

-- 7. Questões

-- Q1 | multiple_choice | fácil | Sistemas de numeração e notação posicional | Exercícios 1 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Em um sistema de numeração, o que a base determina?', 'Cada sistema de numeração possui uma base, que determina quantos símbolos diferentes ele usa: 10 no decimal, 2 no binário, 8 no octal e 16 no hexadecimal.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Sistemas de Numeração na Computação — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A posição que cada algarismo deve ocupar dentro do número.', false, 1),
  ('A quantidade de símbolos diferentes que o sistema utiliza.', true, 2),
  ('A quantidade máxima de algarismos que um número pode ter.', false, 3),
  ('O maior valor que o sistema consegue representar no total.', false, 4),
  ('A quantidade de bits que cada algarismo ocupa na memória.', false, 5)
) AS o(text, is_correct, order_index);

-- Q2 | multiple_choice | difícil | Sistema binário | Exercícios 2 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um técnico de redes precisa ajustar manualmente uma chave de 8 posições com o valor decimal 215. Qual sequência binária ele deve usar?', '215 = 128 + 64 + 16 + 4 + 2 + 1, o que liga os bits de 2⁷, 2⁶, 2⁴, 2², 2¹ e 2⁰: 11010111.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Sistemas de Numeração na Computação — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('11001111', false, 1),
  ('11011011', false, 2),
  ('10110111', false, 3),
  ('11010111', true, 4),
  ('11100111', false, 5)
) AS o(text, is_correct, order_index);

-- Q3 | drag_and_drop | média | Sistema hexadecimal | Exercícios 1 | s1: 10, s2: 12, s3: 14, s4: 15
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'No sistema hexadecimal, as letras representam valores acima de 9: A vale {{s1}}, C vale {{s2}}, E vale {{s3}} e F vale {{s4}}.', 'O hexadecimal tem dezesseis algarismos: de 0 a 9 e as letras de A a F, que valem de 10 a 15. Logo A = 10, C = 12, E = 14 e F = 15.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Sistemas de Numeração na Computação — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('14', 1), ('11', 2), ('10', 3), ('16', 4), ('15', 5), ('12', 6), ('13', 7)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', '10', 1), ('s2', '12', 2), ('s3', '14', 3), ('s4', '15', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q4 | multiple_answer | difícil | Sistema octal | Exercícios 2 | corretas: A, C, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Um sistema legado de uma empresa exporta códigos em octal. Assinale todas as corretas sobre o sistema octal.', 'O octal só tem os algarismos de 0 a 7, e cada dígito equivale a 3 bits. Assim, 144 = 1 x 64 + 4 x 8 + 4 = 100, 34 = 011 100 e o decimal 8 é escrito como 10.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Sistemas de Numeração na Computação — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('O código 15874 é inválido, pois 8 não é um algarismo do octal.', true, 1),
  ('Cada dígito octal corresponde a um grupo de exatamente 4 bits.', false, 2),
  ('O octal 144 equivale ao decimal 100, pois 64 + 32 + 4 = 100.', true, 3),
  ('O octal 34 equivale ao binário 011100, com 3 bits por dígito.', true, 4),
  ('O decimal 8 é escrito em octal como 8, e o decimal 9, como 11.', false, 5)
) AS o(text, is_correct, order_index);

-- Q5 | essay_blanks | fácil | Sistema hexadecimal | Exercícios 1 | b1: binário, b2: hexadecimal
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, template)
  SELECT t.id, 'essay_blanks', 'Complete a frase com os nomes dos sistemas de numeração.', 'O sistema de base 2 é chamado de {{b1}}, e o de base 16, de {{b2}}.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Sistemas de Numeração na Computação — Exercícios 1: Fundamentos'
)
INSERT INTO question_blanks (question_id, blank_key, reference_answer, order_index)
SELECT q.id, v.blank_key, v.reference_answer, v.order_index
FROM q CROSS JOIN (VALUES ('b1', 'binário', 1), ('b2', 'hexadecimal', 2)) AS v(blank_key, reference_answer, order_index);

-- Q6 | multiple_choice | super difícil | Conversões diretas entre as bases | Exercícios 3 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um programador soma dois registradores que guardam os valores hexadecimais BA e CA. Qual alternativa apresenta o resultado correto?', 'BA = 11 x 16 + 10 = 186 e CA = 12 x 16 + 10 = 202. A soma é 388, que em hexadecimal é 184 (1 x 256 + 8 x 16 + 4).'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Sistemas de Numeração na Computação — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('184 em hexadecimal, que equivale a 388 em decimal.', true, 1),
  ('184 em hexadecimal, que equivale a 398 em decimal.', false, 2),
  ('174 em hexadecimal, que equivale a 372 em decimal.', false, 3),
  ('194 em hexadecimal, que equivale a 404 em decimal.', false, 4),
  ('284 em hexadecimal, que equivale a 644 em decimal.', false, 5)
) AS o(text, is_correct, order_index);

-- Q7 | single_choice | difícil | Sistema hexadecimal | Exercícios 2 | b1: 4, b2: 1100, b3: 0001, b4: 0011
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Para converter o hexadecimal C13 em binário, cada dígito vira um grupo de {{b1}} bits: C vira {{b2}}, 1 vira {{b3}} e 3 vira {{b4}}.', 'O hexadecimal é um sistema de 4 bits por dígito: C (12) = 1100, 1 = 0001 e 3 = 0011. Juntando os grupos, C13 = 110000010011.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Sistemas de Numeração na Computação — Exercícios 2: Aplicação'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', '3', false, 1), ('b1', '4', true, 2), ('b1', '8', false, 3),
  ('b2', '1010', false, 1), ('b2', '1101', false, 2), ('b2', '1100', true, 3),
  ('b3', '0001', true, 1), ('b3', '0010', false, 2), ('b3', '1000', false, 3),
  ('b4', '0101', false, 1), ('b4', '0011', true, 2), ('b4', '0110', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q8 | multiple_choice | média | Sistema octal | Exercícios 1 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'O registro de um equipamento antigo mostra a quantidade de falhas como 153 em octal. Quantas falhas ocorreram, em decimal?', '153 em octal = 1 x 8² + 5 x 8¹ + 3 x 8⁰ = 64 + 40 + 3 = 107.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Sistemas de Numeração na Computação — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('339', false, 1),
  ('115', false, 2),
  ('99', false, 3),
  ('123', false, 4),
  ('107', true, 5)
) AS o(text, is_correct, order_index);

-- Q9 | multiple_answer | super difícil | Conversões diretas entre as bases | Exercícios 3 | corretas: B, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Um analista recebe de um contador o valor binário 1111101000. Assinale todas as corretas sobre esse valor.', '1111101000 = 512 + 256 + 128 + 64 + 32 + 8 = 1000. Agrupando 4 bits da direita para a esquerda (0011 1110 1000) obtém-se 3E8, sem passar pelo decimal; para o octal, os grupos são de 3 bits.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Sistemas de Numeração na Computação — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Em decimal, o valor é 1024, pois o bit mais à esquerda vale 2 elevado a 10.', false, 1),
  ('Em hexadecimal, o valor é 3E8, agrupando 4 bits da direita para a esquerda.', true, 2),
  ('Em octal, o valor é 1750, agrupando 4 bits da direita para a esquerda.', false, 3),
  ('Para chegar ao hexadecimal, é preciso converter antes o valor em decimal.', false, 4),
  ('Em decimal, o valor é 1000, e dividi-lo sucessivamente por 16 também dá 3E8.', true, 5)
) AS o(text, is_correct, order_index);

-- Q10 | multiple_choice | fácil | Sistema binário | Exercícios 1 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Qual é o valor em decimal do número binário 10001?', '10001 = 1 x 2⁴ + 1 x 2⁰ = 16 + 1 = 17.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Sistemas de Numeração na Computação — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('9', false, 1),
  ('16', false, 2),
  ('17', true, 3),
  ('18', false, 4),
  ('33', false, 5)
) AS o(text, is_correct, order_index);

-- Q11 | drag_and_drop | super difícil | Conversões diretas entre as bases | Exercícios 3 | s1: 1111111100, s2: 1774, s3: 3FC, s4: 511, s5: 1FF
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'O decimal 1020 equivale a {{s1}} em binário, a {{s2}} em octal e a {{s3}} em hexadecimal. Já o octal 777 equivale a {{s4}} em decimal e a {{s5}} em hexadecimal.', '1020 = 1111111100 em binário; agrupando de 3 em 3 bits obtém-se 1774 e de 4 em 4, 3FC. Já o octal 777 é 111111111 em binário, ou seja, 511 em decimal e 1FF em hexadecimal.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Sistemas de Numeração na Computação — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('1FF', 1), ('1777', 2), ('3FC', 3), ('512', 4), ('1111111100', 5), ('511', 6), ('3FF', 7), ('1774', 8)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', '1111111100', 1), ('s2', '1774', 2), ('s3', '3FC', 3), ('s4', '511', 4), ('s5', '1FF', 5))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q12 | essay_blanks | difícil | Sistema binário | Exercícios 2 | b1: restos, b2: último
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, template)
  SELECT t.id, 'essay_blanks', 'Complete a frase sobre a conversão de decimal para binário.', 'No método das divisões sucessivas, divide-se o número decimal por dois, e o binário é formado pelos {{b1}} das divisões, lidos do {{b2}} para o primeiro.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Sistemas de Numeração na Computação — Exercícios 2: Aplicação'
)
INSERT INTO question_blanks (question_id, blank_key, reference_answer, order_index)
SELECT q.id, v.blank_key, v.reference_answer, v.order_index
FROM q CROSS JOIN (VALUES ('b1', 'restos', 1), ('b2', 'último', 2)) AS v(blank_key, reference_answer, order_index);

-- Q13 | multiple_choice | super difícil | Conversões diretas entre as bases | Exercícios 3 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um gerenciador de memória tem 1024 blocos, dos quais 205 estão ocupados. Como o sistema exibe a quantidade de blocos livres em hexadecimal e em octal?', '1024 - 205 = 819. Em hexadecimal, 819 = 3 x 256 + 3 x 16 + 3 = 333; em octal, 819 = 1 x 512 + 4 x 64 + 6 x 8 + 3 = 1463.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Sistemas de Numeração na Computação — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('333 em hexadecimal e 1436 em octal.', false, 1),
  ('333 em hexadecimal e 1463 em octal.', true, 2),
  ('313 em hexadecimal e 1463 em octal.', false, 3),
  ('33B em hexadecimal e 1473 em octal.', false, 4),
  ('323 em hexadecimal e 1443 em octal.', false, 5)
) AS o(text, is_correct, order_index);

-- Q14 | single_choice | difícil | Sistema octal | Exercícios 2 | b1: 3 em 3, b2: direita, b3: 656
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Para converter o binário 110101110 em octal, os bits são agrupados de {{b1}}, começando pela {{b2}}. Os grupos 110, 101 e 110 resultam no octal {{b3}}.', 'Cada dígito octal equivale a 3 bits, agrupados da direita para a esquerda: 110 = 6, 101 = 5 e 110 = 6, ou seja, 656.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Sistemas de Numeração na Computação — Exercícios 2: Aplicação'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', '3 em 3', true, 1), ('b1', '4 em 4', false, 2), ('b1', '2 em 2', false, 3),
  ('b2', 'esquerda', false, 1), ('b2', 'direita', true, 2), ('b2', 'posição do meio', false, 3),
  ('b3', '566', false, 1), ('b3', '1AE', false, 2), ('b3', '656', true, 3), ('b3', '430', false, 4)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q15 | multiple_answer | super difícil | Sistemas de numeração e notação posicional | Exercícios 3 | corretas: A, C, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma equipe de desenvolvimento revisa a documentação de um conversor de bases. Assinale todas as corretas.', 'Em sistemas posicionais, o valor depende da posição: o 5 de 594 vale 5 x 10². O bit mais à direita é o menos significativo, cada dígito octal vale 3 bits, 3F = 63 e 1001 1000 = 98.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 2
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Sistemas de Numeração na Computação — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('No decimal 594, o algarismo 5 vale 500 por causa da posição que ocupa.', true, 1),
  ('No binário, o bit mais à direita é o mais significativo do número.', false, 2),
  ('O hexadecimal 3F equivale ao decimal 63, pois 3 x 16 + 15 = 63.', true, 3),
  ('O octal 10000 tem 5 bits em binário, pois cada dígito vale 1 bit.', false, 4),
  ('O binário 10011000 equivale ao hexadecimal 98, em grupos de 4 bits.', true, 5)
) AS o(text, is_correct, order_index);

-- 8. Conferência: aborta se alguma questão ficou fora das listas ou alguma lista ficou vazia
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM questions q
    JOIN topics t ON t.id = q.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Arquitetura Computacional' AND t.number = 2
      AND NOT EXISTS (
        SELECT 1 FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
        WHERE qq.question_id = q.id AND z.kind = 'exercise'
      )
  ) THEN
    RAISE EXCEPTION 'Há questão da aula 2 de Arquitetura Computacional fora das listas de exercícios';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM quizzes z
    JOIN topics t ON t.id = z.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Arquitetura Computacional' AND t.number = 2 AND z.kind = 'exercise'
      AND NOT EXISTS (SELECT 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  ) THEN
    RAISE EXCEPTION 'Há lista de exercícios da aula 2 de Arquitetura Computacional sem questões';
  END IF;
END $$;

-- =====================================================================
-- AULA 3 — Aquisição de Dados com API (ARQ-SP2-AULA1.pdf)
-- =====================================================================

-- 1. Disciplina
INSERT INTO subjects (name, short_label)
SELECT 'Arquitetura Computacional', 'ARQ'
WHERE NOT EXISTS (SELECT 1 FROM subjects WHERE name = 'Arquitetura Computacional');

-- 2. Assunto
INSERT INTO topics (subject_id, number, name, description)
SELECT s.id, 3, 'Aquisição de Dados com API', 'O conceito de API como contrato entre sistemas e a anatomia da dat-acqu-ino, que lê o Arduino pela porta serial e publica os dados na web.'
FROM subjects s
WHERE s.name = 'Arquitetura Computacional'
ON CONFLICT DO NOTHING;

-- 3. Trava: aborta se a aula não existir ou já existir com outro nome
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM topics t JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Arquitetura Computacional' AND t.number = 3 AND t.name = 'Aquisição de Dados com API'
  ) THEN
    RAISE EXCEPTION 'A aula 3 de Arquitetura Computacional não existe ou já está cadastrada com outro nome';
  END IF;
END $$;

-- 4. Subassuntos
INSERT INTO subtopics (topic_id, name, summary, order_index)
SELECT t.id, v.name, v.summary, v.order_index
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('API: contrato e abstração', 'API é um contrato entre duas aplicações: define o que pode ser pedido e em que formato. Quem usa a API não precisa saber como ela faz o trabalho.', 1),
  ('Por que o Arduino não fala com o banco', 'A API fica entre o Arduino e o banco por segurança, flexibilidade e escalabilidade. Além disso, o Arduino não teria recursos para falar com o banco sozinho.', 2),
  ('O formato dos dados na serial', 'A API espera uma linha no formato digital;analogico, terminada em quebra de linha. Fora desse formato, os gráficos ficam vazios sem nenhuma mensagem de erro.', 3),
  ('Anatomia da dat-acqu-ino', 'A API cabe no main.js: a função serial() lê o Arduino e enche dois arrays, e a função servidor() os entrega pela web. Três constantes decidem o comportamento.', 4),
  ('Endpoints e consumo dos dados', 'Endpoint é cada endereço que a API aceita atender. A dat-acqu-ino tem dois, que devolvem as leituras em JSON para qualquer programa que saiba abrir um endereço web.', 5),
  ('Ambiente, erros e processos', 'A API roda com Node.js, e o npm baixa suas bibliotecas. Cada sintoma de erro aponta para uma camada diferente, e um processo travado é encerrado pelo PID.', 6)
) AS v(name, summary, order_index)
WHERE s.name = 'Arquitetura Computacional' AND t.number = 3
ON CONFLICT DO NOTHING;

-- 5. Pontos-chave
INSERT INTO subtopic_key_points (subtopic_id, text, order_index)
SELECT st.id, v.text, v.order_index
FROM subtopics st
JOIN topics t ON t.id = st.topic_id
JOIN subjects s ON s.id = t.subject_id
JOIN (VALUES
  ('API: contrato e abstração', 'API (Application Programming Interface) define o que pode ser pedido, o formato do pedido e o formato da resposta.', 1),
  ('API: contrato e abstração', 'Na analogia do restaurante, o cliente é a página de gráficos, o garçom é a dat-acqu-ino e o cozinheiro é a leitura vinda do Arduino.', 2),
  ('API: contrato e abstração', 'Sair do formato combinado não é quase certo: é erro.', 3),
  ('API: contrato e abstração', 'API é abstração: esconde o detalhe de quem está acima, agora entre sistemas inteiros.', 4),
  ('Por que o Arduino não fala com o banco', 'Caminho do dado: sensor, Arduino, porta serial e API, que tem duas saídas: banco de dados e navegador.', 1),
  ('Por que o Arduino não fala com o banco', 'Segurança: com a API, as credenciais do banco não ficam no código gravado na placa.', 2),
  ('Por que o Arduino não fala com o banco', 'Desacoplamento: trocar o sensor muda só o sketch; trocar o banco muda só a API.', 3),
  ('Por que o Arduino não fala com o banco', 'Escalabilidade: uma única API recebe os dados de vários sensores e organiza a gravação.', 4),
  ('Por que o Arduino não fala com o banco', 'O Arduino Uno tem 2 KB de memória de trabalho e nenhum sistema operacional.', 5),
  ('O formato dos dados na serial', 'Formato esperado: dois valores separados por ponto e vírgula e seguidos de quebra de linha, como 1;33.56.', 1),
  ('O formato dos dados na serial', 'O primeiro valor é o do sensor digital, não um identificador; o segundo é o do sensor analógico.', 2),
  ('O formato dos dados na serial', 'O último valor deve ser enviado com Serial.println, que fecha a linha.', 3),
  ('O formato dos dados na serial', 'Texto decorativo, unidade grudada no número ou decimal com vírgula quebram a leitura silenciosamente.', 4),
  ('O formato dos dados na serial', 'Pela serial trafega texto: Serial.println(33.56) envia cinco caracteres, cada um com seu código ASCII.', 5),
  ('Anatomia da dat-acqu-ino', 'main.js é a API, index.html é a página de gráficos e package.json lista as bibliotecas e o comando de início.', 1),
  ('Anatomia da dat-acqu-ino', 'Bibliotecas: serialport lê a porta USB, express serve os dados pela web e mysql2 acessa o banco.', 2),
  ('Anatomia da dat-acqu-ino', 'SERIAL_BAUD_RATE (9600) deve ser igual ao Serial.begin do sketch; SERVIDOR_PORTA é 3300.', 3),
  ('Anatomia da dat-acqu-ino', 'A API acha o Arduino sozinha, comparando vendorId e productId; placas clone podem não ser reconhecidas.', 4),
  ('Anatomia da dat-acqu-ino', 'ReadlineParser espera a quebra de linha, split separa os valores e parseInt e parseFloat os convertem em número.', 5),
  ('Endpoints e consumo dos dados', 'Os dois endpoints são /sensores/analogico e /sensores/digital, em http://localhost:3300.', 1),
  ('Endpoints e consumo dos dados', 'A resposta vem em JSON: uma lista de valores que cresce a cada leitura.', 2),
  ('Endpoints e consumo dos dados', 'Qualquer outro endereço, como /sensores/temperatura, dá erro.', 3),
  ('Endpoints e consumo dos dados', 'O index.html usa fetch e setInterval para buscar os dados de tempos em tempos, sem saber que existe um Arduino.', 4),
  ('Endpoints e consumo dos dados', 'As leituras ficam em arrays na memória: parar a API apaga o histórico.', 5),
  ('Ambiente, erros e processos', 'Node.js executa JavaScript fora do navegador; npm install baixa as bibliotecas e npm start executa node main.js.', 1),
  ('Ambiente, erros e processos', 'Não clone o projeto em pasta sincronizada com a nuvem, como o OneDrive.', 2),
  ('Ambiente, erros e processos', 'A porta serial aceita um programa por vez: feche o Monitor Serial antes de iniciar a API.', 3),
  ('Ambiente, erros e processos', 'Gráficos vazios sem erro: a linha crua no terminal mostra se o problema está no sketch.', 4),
  ('Ambiente, erros e processos', 'Processo travado: descubra o PID (netstat -ano | findstr 3300 ou ps -e | grep node) e encerre-o (taskkill /PID <pid> /F ou kill -9 <pid>).', 5)
) AS v(subtopic_name, text, order_index) ON v.subtopic_name = st.name
WHERE s.name = 'Arquitetura Computacional' AND t.number = 3
ON CONFLICT DO NOTHING;

-- 6. Listas de exercícios
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT v.title, 'exercise', t.subject_id, t.id, NULL, v.difficulty::difficulty_level
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Aquisição de Dados com API — Exercícios 1: Fundamentos', 'easy'),
  ('Aquisição de Dados com API — Exercícios 2: Aplicação', 'medium'),
  ('Aquisição de Dados com API — Exercícios 3: Desafio', 'hard')
) AS v(title, difficulty)
WHERE s.name = 'Arquitetura Computacional' AND t.number = 3
  AND NOT EXISTS (SELECT 1 FROM quizzes z WHERE z.title = v.title);

-- 7. Questões

-- Q1 | multiple_choice | média | API: contrato e abstração | Exercícios 1 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Na analogia do restaurante usada para explicar o que é uma API, qual é o papel da dat-acqu-ino no projeto?', 'A API é o garçom: recebe o pedido em um formato padrão e devolve a resposta. O cliente é a página de gráficos, e o cozinheiro é a leitura vinda do Arduino.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados com API — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('O cliente, pois é ela que sabe o que quer e pede os gráficos.', false, 1),
  ('O cozinheiro, pois é ela que mede a temperatura no sensor.', false, 2),
  ('O cardápio, pois é ela que guarda as leituras para sempre.', false, 3),
  ('O garçom, pois recebe o pedido em formato padrão e o atende.', true, 4),
  ('A cozinha, pois todo o seu funcionamento fica à vista de todos.', false, 5)
) AS o(text, is_correct, order_index);

-- Q2 | multiple_answer | difícil | Por que o Arduino não fala com o banco | Exercícios 2 | corretas: A, C, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Um grupo propõe que o Arduino grave a temperatura diretamente no banco de dados, sem passar por uma API. Assinale todas as corretas sobre os problemas dessa proposta.', 'A API evita que as credenciais fiquem no hardware e atende vários sensores em um lugar só. Além disso, o Arduino Uno tem 2 KB de memória de trabalho e nenhum sistema operacional.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados com API — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('As credenciais do banco ficariam no código da placa, que qualquer um pode pegar e ler.', true, 1),
  ('A placa gravaria mais rápido que a API, o que sobrecarregaria a página de gráficos.', false, 2),
  ('Com dez sensores, seriam dez cópias da credencial e dez conexões simultâneas.', true, 3),
  ('O Arduino Uno tem memória de sobra, mas não tem porta serial para falar com o banco.', false, 4),
  ('O Arduino Uno tem só 2 KB de memória de trabalho, sem folga para o protocolo do banco.', true, 5)
) AS o(text, is_correct, order_index);

-- Q3 | drag_and_drop | fácil | Por que o Arduino não fala com o banco | Exercícios 1 | s1: sensor, s2: Arduino, s3: API, s4: navegador
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Nesta aula, o dado percorre o caminho: {{s1}} → {{s2}} → porta serial → {{s3}} → {{s4}}, onde os gráficos são desenhados.', 'O sensor produz o valor, o Arduino o envia pela porta serial, a API o lê e o publica, e o navegador busca os dados na API para desenhar os gráficos.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados com API — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('API', 1), ('Monitor Serial', 2), ('sensor', 3), ('navegador', 4), ('Arduino', 5), ('Chart.js', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'sensor', 1), ('s2', 'Arduino', 2), ('s3', 'API', 3), ('s4', 'navegador', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q4 | multiple_choice | super difícil | O formato dos dados na serial | Exercícios 3 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um grupo usa apenas um sensor de temperatura, e o loop do sketch termina com Serial.print(1); Serial.print(";"); Serial.print(temperatura);. O terminal da API não exibe nenhuma leitura. Qual é a causa?', 'O ReadlineParser acumula os caracteres e só entrega o dado ao encontrar a quebra de linha que o Serial.println coloca no fim. Com print no último valor, a linha nunca termina.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados com API — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('O valor fixo 1 na primeira posição é lido como identificador e descartado.', false, 1),
  ('Falta a quebra de linha do println, e o parser nunca vê a linha terminar.', true, 2),
  ('O separador deveria ser uma vírgula, e por isso o split não separa nada.', false, 3),
  ('O valor da temperatura tem casas decimais, e o parseInt o descarta.', false, 4),
  ('O sketch deveria enviar o valor analógico antes do valor digital.', false, 5)
) AS o(text, is_correct, order_index);

-- Q5 | single_choice | difícil | Anatomia da dat-acqu-ino | Exercícios 2 | b1: split(';'), b2: texto, b3: parseInt, b4: parseFloat
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'Na dat-acqu-ino, a linha "1;33.56" passa primeiro por {{b1}}, que a divide em duas partes ainda no formato de {{b2}}. Depois, {{b3}} converte a primeira parte no valor do sensor digital, e {{b4}} converte a segunda no valor do sensor analógico.', 'O split('';'') corta a linha no ponto e vírgula e devolve duas partes que ainda são texto. O parseInt converte a posição 0 (digital) em inteiro, e o parseFloat converte a posição 1 (analógico) em número com decimais.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados com API — Exercícios 2: Aplicação'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'parseInt', false, 1), ('b1', 'split('';'')', true, 2), ('b1', 'response.json', false, 3),
  ('b2', 'número inteiro', false, 1), ('b2', 'JSON', false, 2), ('b2', 'texto', true, 3),
  ('b3', 'parseInt', true, 1), ('b3', 'parseFloat', false, 2), ('b3', 'split('';'')', false, 3),
  ('b4', 'parseInt', false, 1), ('b4', 'parseFloat', true, 2), ('b4', 'response.json', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q6 | multiple_choice | fácil | Endpoints e consumo dos dados | Exercícios 1 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'O que é um endpoint?', 'Endpoint é cada endereço que a API aceita atender. Se a API é o cardápio, cada endpoint é um prato: tem nome exato e devolve uma coisa específica.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados com API — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('É a biblioteca que lê os dados que chegam pela porta USB.', false, 1),
  ('É o número único que o sistema dá a cada processo.', false, 2),
  ('É a velocidade da comunicação serial, em bits por segundo.', false, 3),
  ('É o formato de texto em que a API devolve as leituras.', false, 4),
  ('É cada endereço que a API aceita atender, com nome exato.', true, 5)
) AS o(text, is_correct, order_index);

-- Q7 | multiple_answer | super difícil | Anatomia da dat-acqu-ino | Exercícios 3 | corretas: B, C, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Um grupo executa npm start e a API informa que o Arduino não foi encontrado em nenhuma porta serial, embora a IDE do Arduino enxergue a placa e o Monitor Serial mostre os dados. Assinale todas as corretas.', 'A API procura sozinha a porta cujo vendorId e productId batem com os do Arduino original. Clones usam outro chip USB, com outro vendorId, e a correção é feita no código.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados com API — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('O grupo deve informar o nome da porta, como COM6, em uma constante da API.', false, 1),
  ('A hipótese mais provável é uma placa clone, com vendorId diferente do procurado.', true, 2),
  ('A API localiza a placa comparando o vendorId e o productId das portas seriais.', true, 3),
  ('A mensagem indica que outro programa já está usando a porta serial da placa.', false, 4),
  ('A correção para esse caso é pequena, mas precisa ser feita no código da API.', true, 5)
) AS o(text, is_correct, order_index);

-- Q8 | essay_blanks | difícil | O formato dos dados na serial | Exercícios 2 | b1: caracteres, b2: ASCII, b3: número
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, template)
  SELECT t.id, 'essay_blanks', 'Complete a frase sobre o que trafega pela porta serial.', 'O Arduino não envia o número 33.56, e sim cinco {{b1}}, cada um com seu código {{b2}}; por isso a API precisa converter o texto de volta para {{b3}}.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados com API — Exercícios 2: Aplicação'
)
INSERT INTO question_blanks (question_id, blank_key, reference_answer, order_index)
SELECT q.id, v.blank_key, v.reference_answer, v.order_index
FROM q CROSS JOIN (VALUES ('b1', 'caracteres', 1), ('b2', 'ASCII', 2), ('b3', 'número', 3)) AS v(blank_key, reference_answer, order_index);

-- Q9 | multiple_choice | média | Ambiente, erros e processos | Exercícios 1 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'O que o comando npm start faz no projeto dat-acqu-ino?', 'O npm start não é mágica: ele executa o que está escrito em scripts.start no package.json, ou seja, node main.js. Quem baixa as bibliotecas é o npm install.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados com API — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Executa o que está em scripts.start no package.json: node main.js.', true, 1),
  ('Baixa as bibliotecas do package.json e cria a pasta node_modules.', false, 2),
  ('Corrige as vulnerabilidades, alterando as versões das bibliotecas.', false, 3),
  ('Abre o arquivo index.html no navegador e desenha os gráficos.', false, 4),
  ('Clona o repositório do projeto e entra na pasta que foi criada.', false, 5)
) AS o(text, is_correct, order_index);

-- Q10 | single_choice | super difícil | Ambiente, erros e processos | Exercícios 3 | b1: netstat -ano | findstr 3300, b2: taskkill /PID <pid> /F, b3: ps -e | grep node, b4: kill -9 <pid>
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'A API ficou rodando escondida depois que o terminal foi fechado na marra. No Windows, {{b1}} mostra o PID de quem ocupa a porta 3300, e {{b2}} encerra o processo. No Linux, {{b3}} localiza o processo, e {{b4}} o encerra imediatamente.', 'No Windows, netstat -ano | findstr 3300 revela o PID e taskkill /PID <pid> /F força o encerramento. No Linux, ps -e lista todos os processos (o -a pode esconder o servidor) e kill -9 envia o sinal SIGKILL.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados com API — Exercícios 3: Desafio'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'taskkill /PID 3300 /F', false, 1), ('b1', 'netstat -ano | findstr 3300', true, 2), ('b1', 'ps -e | grep 3300', false, 3),
  ('b2', 'taskkill /PID <pid> /F', true, 1), ('b2', 'kill -9 <pid>', false, 2), ('b2', 'netstat -ano', false, 3),
  ('b3', 'ps -a | grep node', false, 1), ('b3', 'Get-Process node', false, 2), ('b3', 'ps -e | grep node', true, 3),
  ('b4', 'taskkill /PID <pid> /F', false, 1), ('b4', 'kill -9 <pid>', true, 2), ('b4', 'Ctrl + C', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q11 | essay_blanks | fácil | API: contrato e abstração | Exercícios 1 | b1: contrato, b2: formato
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, template)
  SELECT t.id, 'essay_blanks', 'Complete a frase sobre o conceito de API.', 'Uma API é um {{b1}} entre duas aplicações: define o que pode ser pedido e em que {{b2}} o pedido deve chegar.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados com API — Exercícios 1: Fundamentos'
)
INSERT INTO question_blanks (question_id, blank_key, reference_answer, order_index)
SELECT q.id, v.blank_key, v.reference_answer, v.order_index
FROM q CROSS JOIN (VALUES ('b1', 'contrato', 1), ('b2', 'formato', 2)) AS v(blank_key, reference_answer, order_index);

-- Q12 | multiple_choice | difícil | O formato dos dados na serial | Exercícios 2 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'A estufa de uma empresa agrícola usa a dat-acqu-ino, e o sketch envia a linha 1;24,7. Que valor do sensor analógico a API armazena?', 'O parseFloat lê até encontrar algo que não é número: para na vírgula e devolve 24. Não há erro nem aviso, só um valor errado.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados com API — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('24.7, pois o parseFloat aceita vírgula ou ponto como decimal.', false, 1),
  ('247, pois o parseFloat ignora a vírgula e junta os dígitos.', false, 2),
  ('24, pois o parseFloat para na vírgula e não avisa do erro.', true, 3),
  ('1, pois a vírgula faz o split trocar a ordem dos valores.', false, 4),
  ('Nenhum, pois a API recusa a linha e mostra uma mensagem.', false, 5)
) AS o(text, is_correct, order_index);

-- Q13 | multiple_answer | super difícil | Endpoints e consumo dos dados | Exercícios 3 | corretas: A, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma empresa quer que um painel próprio consuma as leituras publicadas pela dat-acqu-ino. Assinale todas as corretas.', 'A API tem dois endpoints, /sensores/analogico e /sensores/digital, que devolvem uma lista em JSON; qualquer outro endereço dá erro. Quem consome não precisa saber de onde o dado veio, e as leituras vivem só em memória.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados com API — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('O painel pode buscar os dados em http://localhost:3300/sensores/analogico.', true, 1),
  ('O painel precisa conhecer o Arduino e a porta serial para ler as leituras.', false, 2),
  ('O endereço /sensores/temperatura devolve as leituras em graus Celsius.', false, 3),
  ('A resposta chega em JSON, como uma lista que cresce a cada nova leitura.', true, 4),
  ('Depois de reiniciar a API, a lista devolvida mantém as leituras antigas.', false, 5)
) AS o(text, is_correct, order_index);

-- Q14 | multiple_choice | super difícil | Ambiente, erros e processos | Exercícios 3 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Ao rodar npm start, um grupo recebe a mensagem "Error: listen EADDRINUSE: address already in use :::3300". O que aconteceu e como resolver?', 'A porta 3300 é onde a API escuta, e uma porta só aceita um programa por vez. A mensagem indica que uma execução anterior não morreu: descobre-se o PID e encerra-se o processo.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados com API — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('O Monitor Serial segura a porta da placa; basta fechá-lo e rodar de novo.', false, 1),
  ('Uma execução anterior da API segue viva; é preciso encerrá-la pelo PID.', true, 2),
  ('O npm install não foi executado; é preciso instalar as bibliotecas.', false, 3),
  ('A porta 3300 pertence ao MySQL; é preciso trocar a porta do banco.', false, 4),
  ('O baud rate da API difere do sketch; é preciso igualar os dois lados.', false, 5)
) AS o(text, is_correct, order_index);

-- Q15 | drag_and_drop | difícil | Ambiente, erros e processos | Exercícios 2 | s1: Monitor Serial aberto, s2: falta do npm install, s3: formato errado no sketch, s4: Node não instalado
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Diagnóstico pelo sintoma: "Access denied" ao abrir a porta indica {{s1}}; "Cannot find module ''serialport''" indica {{s2}}; gráficos vazios sem nenhum erro indicam {{s3}}; e "''npm'' não é reconhecido" indica {{s4}}.', 'Cada sintoma aponta para uma camada: acesso negado é outro programa usando a porta (quase sempre o Monitor Serial), módulo não encontrado é falta do npm install, gráfico vazio sem erro é formato errado e comando não reconhecido é Node ausente.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 3
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados com API — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('formato errado no sketch', 1), ('placa clone', 2), ('Node não instalado', 3), ('Monitor Serial aberto', 4), ('cabo só de carga', 5), ('falta do npm install', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'Monitor Serial aberto', 1), ('s2', 'falta do npm install', 2), ('s3', 'formato errado no sketch', 3), ('s4', 'Node não instalado', 4))
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
    WHERE s.name = 'Arquitetura Computacional' AND t.number = 3
      AND NOT EXISTS (
        SELECT 1 FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
        WHERE qq.question_id = q.id AND z.kind = 'exercise'
      )
  ) THEN
    RAISE EXCEPTION 'Há questão da aula 3 de Arquitetura Computacional fora das listas de exercícios';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM quizzes z
    JOIN topics t ON t.id = z.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Arquitetura Computacional' AND t.number = 3 AND z.kind = 'exercise'
      AND NOT EXISTS (SELECT 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  ) THEN
    RAISE EXCEPTION 'Há lista de exercícios da aula 3 de Arquitetura Computacional sem questões';
  END IF;
END $$;

-- =====================================================================
-- AULA 4 — Aquisição de Dados: Gravando no Banco (ARQ-SP2-AULA2.pdf)
-- =====================================================================

-- 1. Disciplina
INSERT INTO subjects (name, short_label)
SELECT 'Arquitetura Computacional', 'ARQ'
WHERE NOT EXISTS (SELECT 1 FROM subjects WHERE name = 'Arquitetura Computacional');

-- 2. Assunto
INSERT INTO topics (subject_id, number, name, description)
SELECT s.id, 4, 'Aquisição de Dados: Gravando no Banco', 'A persistência das leituras do sensor: criação da tabela, conexão por pool, INSERT com consulta preparada e ativação da gravação na API.'
FROM subjects s
WHERE s.name = 'Arquitetura Computacional'
ON CONFLICT DO NOTHING;

-- 3. Trava: aborta se a aula não existir ou já existir com outro nome
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM topics t JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Arquitetura Computacional' AND t.number = 4 AND t.name = 'Aquisição de Dados: Gravando no Banco'
  ) THEN
    RAISE EXCEPTION 'A aula 4 de Arquitetura Computacional não existe ou já está cadastrada com outro nome';
  END IF;
END $$;

-- 4. Subassuntos
INSERT INTO subtopics (topic_id, name, summary, order_index)
SELECT t.id, v.name, v.summary, v.order_index
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Persistência e o quarto papel', 'O banco de dados cumpre o papel de armazenamento que faltava ao projeto. Persistir é fazer o dado sobreviver ao fim do programa que o criou.', 1),
  ('Criando a tabela medida', 'A API não cria a tabela: ela precisa existir antes, com os nomes exatos que o INSERT do código usa.', 2),
  ('Conexão com o banco e pool', 'A API guarda cinco dados de acesso e usa um pool, conjunto de conexões abertas e reaproveitadas. O pool só abre a conexão de verdade quando há uma consulta.', 3),
  ('O INSERT e a consulta preparada', 'A cada leitura, a API executa um INSERT em que comando e valores viajam separados. Essa consulta preparada é a proteção padrão contra injeção de SQL.', 4),
  ('Ligando a gravação', 'A gravação é ativada em três alterações, nesta ordem: tabela, credenciais e chave. O terminal confirma cada gravação com uma segunda linha.', 5)
) AS v(name, summary, order_index)
WHERE s.name = 'Arquitetura Computacional' AND t.number = 4
ON CONFLICT DO NOTHING;

-- 5. Pontos-chave
INSERT INTO subtopic_key_points (subtopic_id, text, order_index)
SELECT st.id, v.text, v.order_index
FROM subtopics st
JOIN topics t ON t.id = st.topic_id
JOIN subjects s ON s.id = t.subject_id
JOIN (VALUES
  ('Persistência e o quarto papel', 'Os quatro papéis: entrada (sensor), processamento (conversão no Arduino e na API), saída (gráficos) e armazenamento (banco de dados).', 1),
  ('Persistência e o quarto papel', 'Arrays ficam na memória, que é volátil: morrem junto com o processo.', 2),
  ('Persistência e o quarto papel', 'Persistência exige gravar em um meio não volátil, como um arquivo, um banco de dados ou um disco.', 3),
  ('Persistência e o quarto papel', 'O banco é preferido ao arquivo de texto porque permite perguntar com uma consulta e organiza gravações simultâneas.', 4),
  ('Criando a tabela medida', 'O INSERT dita o contrato: tabela medida, com as colunas sensor_analogico e sensor_digital.', 1),
  ('Criando a tabela medida', 'sensor_analogico é DECIMAL(6,2): seis dígitos no total, dois deles depois da vírgula; sensor_digital é INT.', 2),
  ('Criando a tabela medida', 'A coluna id é INT PRIMARY KEY AUTO_INCREMENT: o banco numera sozinho.', 3),
  ('Criando a tabela medida', 'A coluna momento (DATETIME DEFAULT CURRENT_TIMESTAMP) é preenchida pelo banco, não pela API.', 4),
  ('Criando a tabela medida', 'DESCRIBE medida confere se as quatro colunas foram criadas.', 5),
  ('Conexão com o banco e pool', 'Os cinco dados de acesso são host, user, password, database e port.', 1),
  ('Conexão com o banco e pool', 'A porta 3300 é a da API; a porta 3306 é a do MySQL.', 2),
  ('Conexão com o banco e pool', 'Abrir conexão é caro, e o sensor lê sem parar: o pool empresta uma conexão já aberta e a recebe de volta.', 3),
  ('Conexão com o banco e pool', 'createPool não conecta: por isso a API subia sem erro com credenciais de exemplo.', 4),
  ('O INSERT e a consulta preparada', 'O bloco do INSERT roda uma vez por leitura do sensor, se HABILITAR_OPERACAO_INSERIR for true.', 1),
  ('O INSERT e a consulta preparada', 'Os pontos de interrogação ficam no lugar dos valores, que seguem em uma lista separada.', 2),
  ('O INSERT e a consulta preparada', 'Nunca concatene dado dentro de comando SQL: o banco poderia executar o dado.', 3),
  ('O INSERT e a consulta preparada', 'O await faz o programa esperar a confirmação da gravação antes de seguir.', 4),
  ('O INSERT e a consulta preparada', 'São gravados os números convertidos por parseFloat e parseInt, não o texto que chegou pela serial.', 5),
  ('Ligando a gravação', 'Ordem: confirmar a tabela primeiro, preencher as credenciais depois e virar a chave por último.', 1),
  ('Ligando a gravação', 'A chave é a linha 11 do main.js: const HABILITAR_OPERACAO_INSERIR = true.', 2),
  ('Ligando a gravação', 'Duas linhas no terminal por leitura (o dado cru e "valores inseridos no banco") indicam gravação acontecendo.', 3),
  ('Ligando a gravação', 'Só o dado cru no terminal indica que nada foi gravado, provavelmente com a chave ainda em false.', 4)
) AS v(subtopic_name, text, order_index) ON v.subtopic_name = st.name
WHERE s.name = 'Arquitetura Computacional' AND t.number = 4
ON CONFLICT DO NOTHING;

-- 6. Listas de exercícios
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT v.title, 'exercise', t.subject_id, t.id, NULL, v.difficulty::difficulty_level
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Aquisição de Dados: Gravando no Banco — Exercícios 1: Fundamentos', 'easy'),
  ('Aquisição de Dados: Gravando no Banco — Exercícios 2: Aplicação', 'medium'),
  ('Aquisição de Dados: Gravando no Banco — Exercícios 3: Desafio', 'hard')
) AS v(title, difficulty)
WHERE s.name = 'Arquitetura Computacional' AND t.number = 4
  AND NOT EXISTS (SELECT 1 FROM quizzes z WHERE z.title = v.title);

-- 7. Questões

-- Q1 | multiple_answer | difícil | Persistência e o quarto papel | Exercícios 2 | corretas: A, C, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma equipe discute onde guardar as leituras de um sensor de temperatura. Assinale todas as corretas.', 'A memória é volátil, e isso não é defeito da API: é a diferença entre guardar e persistir. Um arquivo de texto também persistiria, mas o banco permite perguntar com uma consulta e organiza gravações simultâneas.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados: Gravando no Banco — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Arrays vivem na memória, que é volátil, e somem quando o processo morre.', true, 1),
  ('Um arquivo de texto não mantém os dados depois que o programa termina.', false, 2),
  ('Em um banco de dados, a média de ontem é obtida com uma única consulta.', true, 3),
  ('Dois programas gravando ao mesmo tempo podem corromper um arquivo de texto.', true, 4),
  ('A perda dos dados ao reiniciar a API é um defeito do código da própria API.', false, 5)
) AS o(text, is_correct, order_index);

-- Q2 | multiple_choice | fácil | Persistência e o quarto papel | Exercícios 1 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'O que é persistência?', 'Persistência é a capacidade de um dado sobreviver ao fim do programa que o criou. Exige gravar em um meio não volátil: um arquivo, um banco de dados, um disco.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados: Gravando no Banco — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A capacidade de um dado sobreviver ao fim do programa que o criou.', true, 1),
  ('A capacidade de um dado ser exibido em gráficos em tempo real.', false, 2),
  ('A capacidade de um programa guardar valores em arrays na memória.', false, 3),
  ('A capacidade de um banco de reaproveitar conexões já abertas.', false, 4),
  ('A capacidade de uma API de atender vários sensores de uma vez.', false, 5)
) AS o(text, is_correct, order_index);

-- Q3 | essay_blanks | super difícil | O INSERT e a consulta preparada | Exercícios 3 | b1: interrogação, b2: preparada, b3: injeção
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, template)
  SELECT t.id, 'essay_blanks', 'Complete a frase sobre o INSERT executado pela dat-acqu-ino.', 'No INSERT, os valores são representados por pontos de {{b1}} e enviados em uma lista separada. Essa técnica se chama consulta {{b2}} e protege contra a {{b3}} de SQL.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados: Gravando no Banco — Exercícios 3: Desafio'
)
INSERT INTO question_blanks (question_id, blank_key, reference_answer, order_index)
SELECT q.id, v.blank_key, v.reference_answer, v.order_index
FROM q CROSS JOIN (VALUES ('b1', 'interrogação', 1), ('b2', 'preparada', 2), ('b3', 'injeção', 3)) AS v(blank_key, reference_answer, order_index);

-- Q4 | single_choice | média | Conexão com o banco e pool | Exercícios 1 | b1: 3300, b2: 3306, b3: host, b4: database
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'A API escuta na porta {{b1}}, enquanto o MySQL escuta na porta {{b2}}. Nos dados de acesso, o campo {{b3}} indica onde o banco está, e o campo {{b4}} indica qual banco usar dentro do servidor.', 'São dois serviços distintos: a API escuta na 3300 e o MySQL, na 3306. O campo host diz onde o banco está, e database diz qual banco usar dentro do servidor.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados: Gravando no Banco — Exercícios 1: Fundamentos'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', '3306', false, 1), ('b1', '9600', false, 2), ('b1', '3300', true, 3),
  ('b2', '3306', true, 1), ('b2', '3300', false, 2), ('b2', '9600', false, 3),
  ('b3', 'user', false, 1), ('b3', 'host', true, 2), ('b3', 'port', false, 3),
  ('b4', 'password', false, 1), ('b4', 'host', false, 2), ('b4', 'database', true, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q5 | multiple_choice | super difícil | O INSERT e a consulta preparada | Exercícios 3 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um desenvolvedor sugere montar o INSERT concatenando o valor lido do sensor dentro do texto do comando SQL, por ser mais simples. Por que essa ideia deve ser rejeitada?', 'Quando comando e dado viajam juntos como texto, o banco precisa adivinhar onde termina um e começa o outro e pode executar o dado. Na consulta preparada, os valores são sempre tratados como valores.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados: Gravando no Banco — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Porque o banco recusa comandos montados em uma única string de texto.', false, 1),
  ('Porque a concatenação é mais lenta e atrasa a próxima leitura do sensor.', false, 2),
  ('Porque o banco poderia interpretar parte do dado como se fosse comando.', true, 3),
  ('Porque o valor concatenado seria gravado como texto na coluna numérica.', false, 4),
  ('Porque o pool de conexões só aceita comandos que não tenham valores.', false, 5)
) AS o(text, is_correct, order_index);

-- Q6 | multiple_choice | difícil | Criando a tabela medida | Exercícios 2 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Um grupo criou a tabela com o nome medidas, preencheu as credenciais e ligou a gravação. O que acontece?', 'O nome não é sugestão, é contrato: o INSERT do main.js procura a tabela medida, no singular. A API não cria a tabela, e qualquer diferença de nome faz o INSERT falhar.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados: Gravando no Banco — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A API cria sozinha a tabela medida, pois prepara o banco ao iniciar.', false, 1),
  ('A gravação funciona, pois o MySQL trata singular e plural como iguais.', false, 2),
  ('A gravação funciona, mas a coluna momento deixa de ser preenchida.', false, 3),
  ('O INSERT falha só no sensor digital, cuja coluna não é encontrada.', false, 4),
  ('O INSERT falha, pois o código procura exatamente a tabela medida.', true, 5)
) AS o(text, is_correct, order_index);

-- Q7 | drag_and_drop | fácil | Persistência e o quarto papel | Exercícios 1 | s1: o sensor lendo o mundo, s2: a conversão no Arduino e na API, s3: os gráficos no navegador, s4: o banco de dados
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Os quatro papéis de um computador no projeto: a entrada é {{s1}}, o processamento é {{s2}}, a saída são {{s3}} e o armazenamento é {{s4}}.', 'Entrada é o sensor lendo o mundo, processamento é a conversão no Arduino e na API, saída são os gráficos no navegador e armazenamento é o banco de dados, o papel que faltava.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados: Gravando no Banco — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('os gráficos no navegador', 1), ('o Monitor Serial', 2), ('o banco de dados', 3), ('o sensor lendo o mundo', 4), ('o arquivo package.json', 5), ('a conversão no Arduino e na API', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'o sensor lendo o mundo', 1), ('s2', 'a conversão no Arduino e na API', 2), ('s3', 'os gráficos no navegador', 3), ('s4', 'o banco de dados', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q8 | multiple_answer | super difícil | Conexão com o banco e pool | Exercícios 3 | corretas: B, D, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Na aula anterior, a API subia sem erro mesmo com credenciais de exemplo no createPool. Assinale todas as corretas sobre esse comportamento.', 'O createPool não conecta: só prepara a estrutura e guarda os dados de acesso. A conexão é aberta na primeira consulta, e por isso a credencial errada só vira erro quando a gravação é ligada.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados: Gravando no Banco — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('O createPool testa a conexão ao iniciar, mas ignora as falhas de senha.', false, 1),
  ('O createPool apenas prepara a estrutura e guarda os dados de acesso.', true, 2),
  ('O pool abre uma conexão nova a cada leitura e a fecha logo em seguida.', false, 3),
  ('A conexão de verdade só é aberta quando alguém executa uma consulta.', true, 4),
  ('Com a gravação ligada, a credencial errada vira erro na primeira leitura.', true, 5)
) AS o(text, is_correct, order_index);

-- Q9 | essay_blanks | difícil | Criando a tabela medida | Exercícios 2 | b1: momento, b2: DECIMAL
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, template)
  SELECT t.id, 'essay_blanks', 'Complete a frase sobre a tabela usada pela dat-acqu-ino.', 'A coluna {{b1}} não aparece no INSERT, pois o banco a preenche sozinho com a data e a hora, e a coluna sensor_analogico usa o tipo {{b2}}, e não INT, para guardar as casas decimais.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados: Gravando no Banco — Exercícios 2: Aplicação'
)
INSERT INTO question_blanks (question_id, blank_key, reference_answer, order_index)
SELECT q.id, v.blank_key, v.reference_answer, v.order_index
FROM q CROSS JOIN (VALUES ('b1', 'momento', 1), ('b2', 'DECIMAL', 2)) AS v(blank_key, reference_answer, order_index);

-- Q10 | multiple_choice | super difícil | Ligando a gravação | Exercícios 3 | correta: B
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Depois de ligar a gravação, o terminal de um grupo mostra apenas linhas como 1;24.80, sem a linha "valores inseridos no banco". Qual é o diagnóstico mais provável?', 'Com a gravação ativa, o terminal mostra duas linhas por leitura. Se só o dado cru aparece, a leitura chega mas o bloco do INSERT é pulado: a constante HABILITAR_OPERACAO_INSERIR da linha 11 ainda está em false.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados: Gravando no Banco — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('O sketch envia o dado fora do formato digital;analogico.', false, 1),
  ('A leitura chega, mas a linha 11 ainda está com o valor false.', true, 2),
  ('A tabela medida não existe, e a API ignora a falha em silêncio.', false, 3),
  ('O Monitor Serial está aberto e bloqueia a gravação no banco.', false, 4),
  ('As credenciais estão erradas, e o pool descarta a consulta.', false, 5)
) AS o(text, is_correct, order_index);

-- Q11 | drag_and_drop | difícil | Ligando a gravação | Exercícios 2 | s1: confirmar que a tabela existe, s2: preencher as credenciais, s3: mudar a constante para true, s4: rodar npm start e observar
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop', 'Para ligar a gravação na ordem certa: primeiro {{s1}}, depois {{s2}}, em seguida {{s3}} e, por fim, {{s4}}.', 'Tabela primeiro, credenciais depois, chave por último: ligar o interruptor antes de preencher as credenciais só garante um erro a cada leitura no terminal.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados: Gravando no Banco — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('mudar a constante para true', 1), ('abrir o Monitor Serial', 2), ('confirmar que a tabela existe', 3), ('rodar npm start e observar', 4), ('rodar npm audit fix', 5), ('preencher as credenciais', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES ('s1', 'confirmar que a tabela existe', 1), ('s2', 'preencher as credenciais', 2), ('s3', 'mudar a constante para true', 3), ('s4', 'rodar npm start e observar', 4))
  AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q12 | multiple_choice | fácil | Criando a tabela medida | Exercícios 1 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Qual comando SQL confere se a tabela medida foi criada com as quatro colunas esperadas?', 'DESCRIBE medida mostra as colunas da tabela e seus tipos: devem aparecer id, sensor_analogico, sensor_digital e momento.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados: Gravando no Banco — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('USE medida;', false, 1),
  ('SELECT medida;', false, 2),
  ('CREATE medida;', false, 3),
  ('DESCRIBE medida;', true, 4),
  ('INSERT medida;', false, 5)
) AS o(text, is_correct, order_index);

-- Q13 | single_choice | super difícil | O INSERT e a consulta preparada | Exercícios 3 | b1: uma vez por leitura, b2: await, b3: os números convertidos, b4: 30
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice', 'O bloco do INSERT é executado {{b1}}. O comando usa {{b2}} para aguardar a confirmação do banco, e os valores gravados são {{b3}}. Com delay(2000) no sketch, são cerca de {{b4}} gravações por minuto.', 'O INSERT fica dentro do bloco que processa cada linha recebida, então roda uma vez por leitura: com delay de 2 segundos, cerca de 30 por minuto. O await espera a confirmação, e o que vai para o banco são os números do parseFloat e do parseInt.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados: Gravando no Banco — Exercícios 3: Desafio'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'uma vez ao iniciar a API', false, 1), ('b1', 'uma vez por leitura', true, 2), ('b1', 'uma vez por minuto', false, 3),
  ('b2', 'split', false, 1), ('b2', 'setInterval', false, 2), ('b2', 'await', true, 3),
  ('b3', 'os números convertidos', true, 1), ('b3', 'o texto vindo da serial', false, 2), ('b3', 'os códigos ASCII', false, 3),
  ('b4', '60', false, 1), ('b4', '120', false, 2), ('b4', '30', true, 3), ('b4', '2', false, 4)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q14 | multiple_choice | média | Conexão com o banco e pool | Exercícios 1 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice', 'Por que a dat-acqu-ino usa um pool de conexões, em vez de abrir uma conexão a cada leitura do sensor?', 'Abrir uma conexão envolve negociação de rede, autenticação e alocação de recursos. O pool mantém conexões abertas e reaproveitadas: a API pega uma emprestada, usa e devolve.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados: Gravando no Banco — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Porque abrir conexão é caro, e o pool reaproveita as já abertas.', true, 1),
  ('Porque o MySQL só aceita uma única conexão por dia de cada API.', false, 2),
  ('Porque o pool dispensa usuário e senha no acesso ao banco.', false, 3),
  ('Porque o pool grava as leituras em memória antes do banco.', false, 4),
  ('Porque cada conexão nova apagaria as leituras já gravadas.', false, 5)
) AS o(text, is_correct, order_index);

-- Q15 | multiple_answer | difícil | Criando a tabela medida | Exercícios 2 | corretas: A, B, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer', 'Uma equipe revisa o script de criação da tabela medida. Assinale todas as corretas.', 'O banco numera o id e preenche o momento sozinho, e a tabela precisa existir antes, pois a API não a cria. DECIMAL(6,2) guarda seis dígitos, dois depois da vírgula; um INT truncaria 24.80 para 24.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Arquitetura Computacional' AND t.number = 4
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Aquisição de Dados: Gravando no Banco — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A coluna id é numerada pelo próprio banco, com AUTO_INCREMENT.', true, 1),
  ('Se sensor_analogico fosse INT, o valor 24.80 seria truncado para 24.', true, 2),
  ('A API cria a tabela sozinha, caso ela ainda não exista no banco.', false, 3),
  ('A coluna momento precisa ser enviada pela API em cada INSERT.', false, 4),
  ('DECIMAL(6,2) guarda seis dígitos no total, dois deles decimais.', true, 5)
) AS o(text, is_correct, order_index);

-- 8. Conferência: aborta se alguma questão ficou fora das listas ou alguma lista ficou vazia
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM questions q
    JOIN topics t ON t.id = q.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Arquitetura Computacional' AND t.number = 4
      AND NOT EXISTS (
        SELECT 1 FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
        WHERE qq.question_id = q.id AND z.kind = 'exercise'
      )
  ) THEN
    RAISE EXCEPTION 'Há questão da aula 4 de Arquitetura Computacional fora das listas de exercícios';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM quizzes z
    JOIN topics t ON t.id = z.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Arquitetura Computacional' AND t.number = 4 AND z.kind = 'exercise'
      AND NOT EXISTS (SELECT 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  ) THEN
    RAISE EXCEPTION 'Há lista de exercícios da aula 4 de Arquitetura Computacional sem questões';
  END IF;
END $$;

COMMIT;
