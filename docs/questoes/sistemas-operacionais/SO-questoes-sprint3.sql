-- Sistemas Operacionais — conteúdo da Sprint 3 (aulas 08, 09, 10 e 12 do prof. Marcio Santana):
-- arquitetura cliente/servidor, diagrama de solução, introdução a redes e conexão SSH. Cadastra a
-- aula, os subassuntos com pontos-chave, as 3 listas de exercícios e as 45 questões; o simulado é
-- criado por SO-simulado-sprint3.sql.
-- Aula: "Cliente/Servidor, Diagrama de Solução, Redes e SSH".
-- Questões, gabaritos e explicações: SO-questoes-sprint3.md.
-- O número da aula não é fixo: o script usa o próximo número livre da disciplina e o mostra
-- em um NOTICE. A aula é localizada pelo nome, que é único dentro da disciplina.
-- Distribuição: 18 multiple_choice, 9 multiple_answer, 6 single_choice e 12 drag_and_drop;
-- 9 fáceis e 6 médias (Exercícios 1), 15 difíceis (Exercícios 2) e 15 super difíceis (Exercícios 3);
-- 37 questões de cenário prático.
-- Uma única transação: se qualquer comando falhar, nada é gravado.

BEGIN;

-- 1. Disciplina
INSERT INTO subjects (name, short_label)
SELECT 'Sistemas Operacionais', 'SO'
WHERE NOT EXISTS (SELECT 1 FROM subjects WHERE name = 'Sistemas Operacionais');

-- 2. Trava: aborta se a aula ou alguma das listas já estiver cadastrada
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM topics t JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  ) THEN
    RAISE EXCEPTION 'A aula "Cliente/Servidor, Diagrama de Solução, Redes e SSH" de Sistemas Operacionais já está cadastrada';
  END IF;

  IF EXISTS (
    SELECT 1 FROM quizzes WHERE title IN ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos', 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação', 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio')
  ) THEN
    RAISE EXCEPTION 'Já existe uma lista de exercícios com o título de uma das listas desta aula';
  END IF;
END $$;

-- 3. Assunto, com o próximo número de aula livre da disciplina
INSERT INTO topics (subject_id, number, name, description)
SELECT s.id,
  (SELECT COALESCE(MAX(t.number), 0) + 1 FROM topics t WHERE t.subject_id = s.id),
  'Cliente/Servidor, Diagrama de Solução, Redes e SSH',
  'Arquitetura cliente/servidor, diagrama de solução do projeto, fundamentos de redes (IP, DNS, DHCP, portas e comandos) e acesso remoto por SSH com redirecionamento de portas.'
FROM subjects s
WHERE s.name = 'Sistemas Operacionais';

DO $$
DECLARE
  lesson integer;
BEGIN
  SELECT t.number INTO lesson
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH';
  RAISE NOTICE 'Aula cadastrada com o número %', lesson;
END $$;

-- 4. Subassuntos
INSERT INTO subtopics (topic_id, name, summary, order_index)
SELECT t.id, v.name, v.summary, v.order_index
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Arquitetura cliente/servidor e servidores', 'Na arquitetura cliente/servidor, o cliente solicita recursos e o servidor os fornece, pela rede. Servidor é o ambiente físico ou virtual que fornece serviços; servidor web é o software que hospeda sites via HTTP/HTTPS.', 1),
  ('Diagrama de solução do projeto', 'O diagrama de solução mostra o caminho do dado do sensor até a dashboard em 6 etapas e em quais máquinas cada parte roda.', 2),
  ('Endereçamento IP, DNS e DHCP', 'O IP identifica cada dispositivo como um CEP; o DNS traduz nomes em IPs; o DHCP entrega IPs automaticamente.', 3),
  ('Portas e comandos de rede', 'Porta é um ponto virtual, gerenciado pelo SO, que liga cada conexão a um serviço. Windows e Linux têm comandos equivalentes para testar a rede.', 4),
  ('SSH e shell remoto', 'SSH é o protocolo de comunicação segura usado para abrir um shell remoto em outra máquina, como o servidor na cloud.', 5),
  ('Redirecionamento de portas e comando ssh', 'Para acessar a VM, o virtualizador redireciona uma porta do hospedeiro para uma porta do convidado, e o ssh informa a porta com -p.', 6)
) AS v(name, summary, order_index)
WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH';

-- 5. Pontos-chave
INSERT INTO subtopic_key_points (subtopic_id, text, order_index)
SELECT st.id, v.text, v.order_index
FROM subtopics st
JOIN topics t ON t.id = st.topic_id
JOIN subjects s ON s.id = t.subject_id
JOIN (VALUES
  ('Arquitetura cliente/servidor e servidores', 'O cliente envia uma solicitação, o servidor a processa e devolve uma resposta, como o garçom que leva o pedido à cozinha.', 1),
  ('Arquitetura cliente/servidor e servidores', 'Vantagens: escalabilidade, facilidade de manutenção e centralização de dados e recursos.', 2),
  ('Arquitetura cliente/servidor e servidores', 'Desafios: segurança, disponibilidade, sobrecarga dos servidores e complexidade.', 3),
  ('Arquitetura cliente/servidor e servidores', 'Características de um servidor: processamento, armazenamento, conectividade de rede, confiabilidade e disponibilidade.', 4),
  ('Arquitetura cliente/servidor e servidores', 'Um servidor físico ou virtual pode ser configurado com a função de servidor web: a mesma máquina tem vários papéis.', 5),
  ('Diagrama de solução do projeto', 'Etapas: captura, inserção no BD, armazenamento, seleção no BD, transformação em gráficos e visualização.', 1),
  ('Diagrama de solução do projeto', 'Tecnologias: Arduino captura, Node.js insere e seleciona, MySQL armazena e HTML/CSS/JS monta os gráficos.', 2),
  ('Diagrama de solução do projeto', 'A máquina de captura fica instalada no cliente e roda a API Data Acquino, na porta 3300.', 3),
  ('Diagrama de solução do projeto', 'O servidor de BD e APP é uma VM Linux com o MySQL e a API Web Data Viz, na porta 3333.', 4),
  ('Diagrama de solução do projeto', 'Só com o Arduino e o Serial Plotter, os dados ficam em cache e não são armazenados de forma permanente.', 5),
  ('Endereçamento IP, DNS e DHCP', 'DNS traduz o nome (URL) em IP; DHCP entrega o IP automaticamente aos dispositivos.', 1),
  ('Endereçamento IP, DNS e DHCP', 'IPv4: 32 bits em 4 grupos de 8 bits, escritos em decimal; 2^32 = 4.294.967.296 endereços.', 2),
  ('Endereçamento IP, DNS e DHCP', 'IPv6: 128 bits em 8 grupos de 16 bits, escritos em hexadecimal; 2^128 endereços.', 3),
  ('Endereçamento IP, DNS e DHCP', 'IP fixo: para servidores e serviços que não podem mudar de endereço; DHCP evita conflitos e facilita o gerenciamento.', 4),
  ('Portas e comandos de rede', 'Portas: 21 FTP, 22 SSH, 23 Telnet, 25 SMTP, 80/8080 HTTP, 443 HTTPS, 1433 SQL Server, 3306 MySQL, 3389 RDP, 5432 PostgreSQL.', 1),
  ('Portas e comandos de rede', 'Portas dinâmicas vão de 49152 a 65535.', 2),
  ('Portas e comandos de rede', 'Equivalentes: ipconfig e ip, tracert e traceroute, nslookup e dig ou host.', 3),
  ('Portas e comandos de rede', 'pathping junta ping e tracert com estatística de perda; getmac mostra o MAC, não o IP.', 4),
  ('SSH e shell remoto', 'Pilares do SSH: autenticação, criptografia e integridade.', 1),
  ('SSH e shell remoto', 'O SSH segue a arquitetura cliente/servidor.', 2),
  ('SSH e shell remoto', 'Tipos de chave: do usuário, do host e de sessão.', 3),
  ('SSH e shell remoto', 'Para um shell remoto é preciso saber o IP e a porta de destino.', 4),
  ('Redirecionamento de portas e comando ssh', 'Regra SSH: porta 2222 do hospedeiro para a 22 do convidado; regra MySQL: 3307 do hospedeiro para a 3306 do convidado.', 1),
  ('Redirecionamento de portas e comando ssh', 'VM local: ssh sptech@127.0.0.1 -p 2222.', 2),
  ('Redirecionamento de portas e comando ssh', 'VM de um colega: ssh sptech@<ip_do_host_do_colega> -p 2222, com o IP do host, não o interno da VM.', 3),
  ('Redirecionamento de portas e comando ssh', 'A opção é -p minúsculo com hífen comum; o travessão copiado do slide não funciona.', 4),
  ('Redirecionamento de portas e comando ssh', 'Com o redirecionamento criado, a VM pode ser iniciada em modo headless e acessada pelo terminal do host.', 5)
) AS v(subtopic_name, text, order_index) ON v.subtopic_name = st.name
WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH';

-- 6. Listas de exercícios
INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
SELECT v.title, 'exercise', t.subject_id, t.id, NULL, v.difficulty::difficulty_level
FROM topics t JOIN subjects s ON s.id = t.subject_id
CROSS JOIN (VALUES
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos', 'easy'),
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação', 'medium'),
  ('Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio', 'hard')
) AS v(title, difficulty)
WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH';

-- 7. Questões: cada uma é um comando, com o comentário "número | tipo | dificuldade | subassunto |
-- lista | resposta". O CTE "l" põe a questão no fim da sua lista.

-- Q1 | multiple_choice | fácil | Arquitetura cliente/servidor e servidores | Exercícios 1 | correta: C
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Na analogia da aula, o cliente faz o pedido ao garçom, que o leva à cozinha e traz o prato de volta. No acesso a um site, o que corresponde à cozinha?',
    'O cliente pede, a rede leva o pedido como o garçom e o servidor web prepara e devolve a resposta, como a cozinha. O navegador é o cliente.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('O navegador do usuário', false, 1),
  ('A rede que leva o pedido', false, 2),
  ('O servidor web (web server)', true, 3),
  ('O cabo de rede do cliente', false, 4),
  ('O teclado de quem digita', false, 5)
) AS o(text, is_correct, order_index);

-- Q2 | drag_and_drop | fácil | Diagrama de solução do projeto | Exercícios 1 | s1: Captura de dados, s2: Inserção de dados no BD, s3: Armazenamento de dados, s4: Seleção de dados no BD, s5: Transformação em gráficos, s6: Visualização de dados | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'Ordene as etapas do diagrama de solução do projeto, do sensor até a dashboard: 1ª {{s1}}; 2ª {{s2}}; 3ª {{s3}}; 4ª {{s4}}; 5ª {{s5}}; 6ª {{s6}}.',
    'O Arduino captura, o Node insere no MySQL, que armazena; depois o Node seleciona os dados, o HTML/CSS/JS os transforma em gráficos e o cliente os visualiza. Serial Plotter e cache eram o cenário antigo, sem armazenamento.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('Armazenamento de dados', 1),
    ('Visualização no Serial Plotter', 2),
    ('Seleção de dados no BD', 3),
    ('Captura de dados', 4),
    ('Visualização de dados', 5),
    ('Inserção de dados no BD', 6),
    ('Guarda em cache', 7),
    ('Transformação em gráficos', 8)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'Captura de dados', 1),
  ('s2', 'Inserção de dados no BD', 2),
  ('s3', 'Armazenamento de dados', 3),
  ('s4', 'Seleção de dados no BD', 4),
  ('s5', 'Transformação em gráficos', 5),
  ('s6', 'Visualização de dados', 6)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q3 | multiple_choice | fácil | Endereçamento IP, DNS e DHCP | Exercícios 1 | correta: B | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Um funcionário da LogiFast digita intranet.logifast.local no navegador. Antes de acessar o servidor, o computador precisa descobrir o IP que corresponde a esse nome. Qual serviço faz essa tradução?',
    'O DNS funciona como um apelido para o IP: recebe o nome e devolve o endereço. O DHCP entrega IPs aos dispositivos, mas não traduz nomes.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('DHCP', false, 1),
  ('DNS', true, 2),
  ('SSH', false, 3),
  ('FTP', false, 4),
  ('RDP', false, 5)
) AS o(text, is_correct, order_index);

-- Q4 | single_choice | fácil | Portas e comandos de rede | Exercícios 1 | b1: 443, b2: 3306, b3: 22 | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice',
    'A LogiFast vai liberar no servidor só as portas necessárias. O site interno usa HTTPS na porta {{b1}}, o banco MySQL escuta na porta {{b2}} e o acesso remoto por SSH usa a porta {{b3}}.',
    'HTTPS usa a 443 (HTTP usa 80 ou 8080), o MySQL usa a 3306 (5432 é PostgreSQL e 1433, SQL Server) e o SSH usa a 22 (23 é Telnet e 21, FTP).'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', '80', false, 1),
  ('b1', '443', true, 2),
  ('b1', '8080', false, 3),
  ('b2', '5432', false, 1),
  ('b2', '1433', false, 2),
  ('b2', '3306', true, 3),
  ('b3', '22', true, 1),
  ('b3', '23', false, 2),
  ('b3', '21', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q5 | multiple_answer | fácil | SSH e shell remoto | Exercícios 1 | corretas: A, C, E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer',
    'Sobre o SSH (Secure Shell), assinale todas as corretas.',
    'SSH é um protocolo de comunicação segura, baseado em cliente/servidor, com os pilares autenticação, criptografia e integridade e as chaves do usuário, do host e de sessão. Servidor web é outra coisa.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('É um protocolo que define a comunicação segura entre máquinas', true, 1),
  ('É um software de servidor web que hospeda páginas na porta 80', false, 2),
  ('Seus pilares são autenticação, criptografia e integridade', true, 3),
  ('Dispensa servidor: as duas máquinas atuam só como clientes', false, 4),
  ('Usa três tipos de chave: do usuário, do host e de sessão', true, 5)
) AS o(text, is_correct, order_index);

-- Q6 | multiple_choice | fácil | Arquitetura cliente/servidor e servidores | Exercícios 1 | correta: E
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Qual alternativa lista as características de um servidor apresentadas na aula?',
    'As características do servidor são processamento de dados, armazenamento, conectividade de rede, confiabilidade e disponibilidade. As outras listas misturam vantagens e desafios da arquitetura, o servidor web e os pilares do SSH.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Escalabilidade, manutenção, centralização e segurança', false, 1),
  ('Processamento, armazenamento, sobrecarga e complexidade', false, 2),
  ('HTTP, HTTPS, hospedagem de sites e várias requisições', false, 3),
  ('Autenticação, criptografia, integridade e disponibilidade', false, 4),
  ('Processamento, armazenamento, conectividade e disponibilidade', true, 5)
) AS o(text, is_correct, order_index);

-- Q7 | drag_and_drop | fácil | Redirecionamento de portas e comando ssh | Exercícios 1 | s1: 2222, s2: 22, s3: 3307, s4: 3306 | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'Complete a tabela de redirecionamento de portas do VirtualBox para acessar a VM a partir do host. Regra SSH: porta do hospedeiro {{s1}} e porta do convidado {{s2}}. Regra Conexão MySQL: porta do hospedeiro {{s3}} e porta do convidado {{s4}}.',
    'O hospedeiro é o computador físico e o convidado é a VM: quem chega na 2222 do host vai para a 22 (SSH) da VM, e quem chega na 3307 do host vai para a 3306 (MySQL) da VM.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('3306', 1),
    ('22', 2),
    ('5432', 3),
    ('2222', 4),
    ('23', 5),
    ('3307', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', '2222', 1),
  ('s2', '22', 2),
  ('s3', '3307', 3),
  ('s4', '3306', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q8 | multiple_choice | fácil | Endereçamento IP, DNS e DHCP | Exercícios 1 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Comparando IPv4 e IPv6, qual alternativa está correta?',
    'O IPv4 tem 32 bits divididos em 4 octetos, escritos em decimal; o IPv6 tem 128 bits divididos em 8 grupos de 16 bits, escritos em hexadecimal.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('IPv4: 32 bits, 4 grupos de 8 bits, decimal; IPv6: 128 bits, 8 grupos de 16 bits, hexadecimal', true, 1),
  ('IPv4: 32 bits, 4 grupos de 16 bits, decimal; IPv6: 128 bits, 8 grupos de 16 bits, hexadecimal', false, 2),
  ('IPv4: 32 bits, 4 grupos de 8 bits, decimal; IPv6: 64 bits, 8 grupos de 8 bits, hexadecimal', false, 3),
  ('IPv4: 32 bits, 4 grupos de 8 bits, hexadecimal; IPv6: 128 bits, 8 grupos de 16 bits, decimal', false, 4),
  ('IPv4: 64 bits, 4 grupos de 16 bits, decimal; IPv6: 128 bits, 16 grupos de 8 bits, hexadecimal', false, 5)
) AS o(text, is_correct, order_index);

-- Q9 | drag_and_drop | fácil | Diagrama de solução do projeto | Exercícios 1 | s1: Arduino, s2: Node.js, s3: MySQL, s4: HTML, CSS e JS
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'Associe cada etapa do diagrama de solução à tecnologia usada: captura de dados {{s1}}; inserção e seleção no BD {{s2}}; armazenamento {{s3}}; transformação em gráficos {{s4}}.',
    'O Arduino lê o sensor, o Node.js faz o INSERT e o SELECT, o MySQL guarda os dados e o HTML, CSS e JS montam os gráficos que o navegador do cliente exibe.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('MySQL', 1),
    ('Serial Plotter', 2),
    ('HTML, CSS e JS', 3),
    ('Arduino', 4),
    ('Navegador do cliente', 5),
    ('Node.js', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'Arduino', 1),
  ('s2', 'Node.js', 2),
  ('s3', 'MySQL', 3),
  ('s4', 'HTML, CSS e JS', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q10 | drag_and_drop | média | Portas e comandos de rede | Exercícios 1 | s1: ip, s2: traceroute, s3: dig, s4: ping | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'Um técnico usa Windows na mesa e Linux na VM do servidor. Associe cada comando do Windows ao equivalente no Linux: ipconfig {{s1}}; tracert {{s2}}; nslookup {{s3}}; ping {{s4}}.',
    'ipconfig e ip mostram a configuração de rede, tracert e traceroute mostram a rota, nslookup e dig consultam o DNS, e ping tem o mesmo nome nos dois. curl transfere dados e whois consulta registros de domínio.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('dig', 1),
    ('curl', 2),
    ('ping', 3),
    ('ip', 4),
    ('whois', 5),
    ('traceroute', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'ip', 1),
  ('s2', 'traceroute', 2),
  ('s3', 'dig', 3),
  ('s4', 'ping', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q11 | multiple_choice | média | Arquitetura cliente/servidor e servidores | Exercícios 1 | correta: D | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Uma loja virtual concentra estoque e pedidos num único servidor. Na Black Friday, os acessos triplicam, as páginas demoram a carregar e algumas compras falham. Qual desafio da arquitetura cliente/servidor ficou evidente e qual vantagem ajuda a resolvê-lo?',
    'Com alta demanda o servidor fica sobrecarregado e o desempenho cai. A escalabilidade permite adicionar servidores conforme a demanda aumenta.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Complexidade; resolve-se com a centralização dos dados', false, 1),
  ('Segurança; resolve-se com a facilidade de manutenção', false, 2),
  ('Disponibilidade; resolve-se tirando o servidor da rede', false, 3),
  ('Sobrecarga do servidor; resolve-se com escalabilidade', true, 4),
  ('Sobrecarga dos clientes; resolve-se trocando os navegadores', false, 5)
) AS o(text, is_correct, order_index);

-- Q12 | multiple_answer | média | Redirecionamento de portas e comando ssh | Exercícios 1 | corretas: B, D | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer',
    'Um aluno quer acessar, do terminal do seu host, a própria VM, com o usuário sptech e o redirecionamento SSH 2222 → 22. Assinale todas as linhas que abrem o shell da VM.',
    'A porta vai com -p minúsculo e hífen comum, antes ou depois do destino. -P maiúsculo é outra opção, o travessão copiado do slide não é entendido como opção, e as duas tentam a porta 22 do host, que não é a da VM.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('ssh sptech@127.0.0.1 -P 2222', false, 1),
  ('ssh sptech@127.0.0.1 -p 2222', true, 2),
  ('ssh sptech@127.0.0.1 –p 2222', false, 3),
  ('ssh -p 2222 sptech@127.0.0.1', true, 4),
  ('ssh sptech@127.0.0.1 -p 22', false, 5)
) AS o(text, is_correct, order_index);

-- Q13 | single_choice | média | Endereçamento IP, DNS e DHCP | Exercícios 1 | b1: DHCP, b2: evita conflitos de IP e facilita o gerenciamento, b3: IP fixo | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice',
    'A LogiFast vai ligar em rede 80 computadores de escritório e um servidor de banco de dados. Os computadores dos funcionários devem receber IP por {{b1}}, porque isso {{b2}}. O servidor de banco deve usar {{b3}}, porque os outros computadores precisam encontrá-lo sempre no mesmo endereço.',
    'Em redes grandes que não precisam de IP fixo, o DHCP distribui os endereços sem conflito e facilita o gerenciamento. Servidores e serviços que não podem mudar de endereço usam IP fixo.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'DHCP', true, 1),
  ('b1', 'DNS', false, 2),
  ('b1', 'IP fixo', false, 3),
  ('b2', 'evita conflitos de IP e facilita o gerenciamento', true, 1),
  ('b2', 'traduz o nome do computador em IP', false, 2),
  ('b2', 'deixa a rede mais rápida que o IP fixo', false, 3),
  ('b3', 'IP fixo', true, 1),
  ('b3', 'DHCP', false, 2),
  ('b3', 'DNS', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q14 | multiple_choice | média | Diagrama de solução do projeto | Exercícios 1 | correta: C | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Na arquitetura implementada do projeto, onde roda cada API e em qual porta?',
    'A máquina de captura, instalada no cliente, roda o Arduino e a API Data Acquino na 3300. O servidor de BD e APP (VM Linux) roda o MySQL e a API Web Data Viz na 3333.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Data Acquino na VM Linux, porta 3333; Web Data Viz na máquina de captura, porta 3300', false, 1),
  ('As duas na VM Linux, nas portas 3300 e 3306, junto com o MySQL', false, 2),
  ('Data Acquino na máquina de captura do cliente, porta 3300; Web Data Viz na VM Linux, porta 3333', true, 3),
  ('Data Acquino no navegador do cliente, porta 3300; Web Data Viz no Arduino, porta 3333', false, 4),
  ('Data Acquino na máquina de captura do cliente, porta 3333; Web Data Viz na VM Linux, porta 3300', false, 5)
) AS o(text, is_correct, order_index);

-- Q15 | multiple_answer | média | Arquitetura cliente/servidor e servidores | Exercícios 1 | corretas: A, C, D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer',
    'Sobre servidor e servidor web, assinale todas as corretas.',
    'O servidor (físico ou virtual) é o ambiente que fornece recursos, e o servidor web é o software que hospeda sites via HTTP/HTTPS; a mesma máquina pode ter vários papéis. O servidor web processa várias requisições ao mesmo tempo.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 1: Fundamentos'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Servidor web é um software que hospeda sites e conversa com navegadores por HTTP/HTTPS', true, 1),
  ('Servidor web e servidor físico são a mesma coisa, só com nomes diferentes', false, 2),
  ('Uma VM pode ser servidor de banco de dados e também ser configurada como servidor web', true, 3),
  ('HTTPS (Hypertext Transfer Protocol Secure) é a versão segura do HTTP', true, 4),
  ('O servidor web só consegue atender uma requisição de cliente por vez', false, 5)
) AS o(text, is_correct, order_index);

-- Q16 | multiple_choice | difícil | Endereçamento IP, DNS e DHCP | Exercícios 2 | correta: B | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Um técnico testa o servidor de pedidos pelo terminal Linux. O comando ping -c 2 pedidos.logifast.local devolve «ping: pedidos.logifast.local: Name or service not known». Logo depois, ping -c 2 192.168.0.20, o IP desse servidor, devolve «2 packets transmitted, 2 received, 0% packet loss». Qual é o diagnóstico?',
    'O servidor responde pelo IP, então há conectividade; o que falhou foi a tradução do nome em IP, que é papel do DNS.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Falha de conectividade: o servidor de pedidos está desligado', false, 1),
  ('Falha de resolução de nome (DNS): o servidor responde pelo IP', true, 2),
  ('Falha de DHCP: o computador do técnico ficou sem endereço IP', false, 3),
  ('Falha de porta: o SSH do servidor de pedidos está fechado', false, 4),
  ('Falha de MAC: o getmac do técnico mostraria o problema', false, 5)
) AS o(text, is_correct, order_index);

-- Q17 | multiple_answer | difícil | Redirecionamento de portas e comando ssh | Exercícios 2 | corretas: B, D | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer',
    'A colega Bia deixou a VM ligada em modo headless, com o redirecionamento SSH 2222 → 22. O host da Bia tem o IP 192.168.0.15 na rede da sala, e a VM dela usa internamente o IP 10.0.2.15. Do seu notebook, assinale todas as linhas que acessam a VM da Bia.',
    'Para a VM de um colega usa-se o IP do host dele com a porta redirecionada, 2222. 127.0.0.1 é a sua própria máquina, o IP interno da VM não é alcançado de fora, e a porta 22 do host da Bia não é a da VM.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('ssh sptech@127.0.0.1 -p 2222', false, 1),
  ('ssh sptech@192.168.0.15 -p 2222', true, 2),
  ('ssh sptech@10.0.2.15 -p 2222', false, 3),
  ('ssh -p 2222 sptech@192.168.0.15', true, 4),
  ('ssh sptech@192.168.0.15 -p 22', false, 5)
) AS o(text, is_correct, order_index);

-- Q18 | drag_and_drop | difícil | Portas e comandos de rede | Exercícios 2 | s1: 22, s2: 23, s3: 3389, s4: 5432, s5: 1433 | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'O time de infraestrutura monta a lista de portas que serão liberadas para cada serviço. Associe: SSH {{s1}}; Telnet {{s2}}; RDP (área de trabalho remota) {{s3}}; PostgreSQL {{s4}}; SQL Server {{s5}}.',
    'SSH usa 22 e Telnet 23; o RDP usa 3389; PostgreSQL usa 5432 e SQL Server 1433. 3306 é do MySQL e 25, do SMTP.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('3306', 1),
    ('23', 2),
    ('1433', 3),
    ('22', 4),
    ('25', 5),
    ('5432', 6),
    ('3389', 7)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', '22', 1),
  ('s2', '23', 2),
  ('s3', '3389', 3),
  ('s4', '5432', 4),
  ('s5', '1433', 5)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q19 | multiple_choice | difícil | Arquitetura cliente/servidor e servidores | Exercícios 2 | correta: D | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Uma empresa tem uma VM Linux num servidor físico. Na VM rodam o MySQL e o Node.js com o web-data-viz, que entrega as páginas aos navegadores na porta 3333. Qual afirmação classifica corretamente as partes?',
    'Servidor web é o software que hospeda o site e responde aos navegadores, aqui o Node.js com o web-data-viz. A VM é um servidor (virtual) que acumula os papéis de banco e de aplicação.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A VM é o servidor web, e o Node.js é o servidor físico da empresa', false, 1),
  ('O servidor físico é o servidor web, pois tem o processador e o disco', false, 2),
  ('O MySQL é o servidor web, pois é ele que guarda os dados exibidos', false, 3),
  ('O Node.js é o servidor web (software); a VM é um servidor com vários papéis', true, 4),
  ('Só existe servidor web se o site usar HTTPS na porta 443', false, 5)
) AS o(text, is_correct, order_index);

-- Q20 | single_choice | difícil | Diagrama de solução do projeto | Exercícios 2 | b1: se perdem, b2: cache, b3: INSERT, b4: SELECT | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice',
    'Hoje o grupo mostra a temperatura do LM35 só no Serial Plotter do Arduino. Quando o Arduino é desligado, os dados {{b1}}, porque ficam só em {{b2}}. Para guardá-los de forma permanente, o Node.js faz {{b3}} no MySQL, e para montar a dashboard outro processo Node.js faz {{b4}}.',
    'Sem banco, os dados ficam em cache e não são armazenados de forma permanente. A inserção no BD usa INSERT e a seleção, que alimenta os gráficos, usa SELECT.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3), ('b4', 4)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'se perdem', true, 1),
  ('b1', 'continuam no MySQL', false, 2),
  ('b1', 'vão para a VM', false, 3),
  ('b2', 'cache', true, 1),
  ('b2', 'MySQL', false, 2),
  ('b2', 'disco da VM', false, 3),
  ('b3', 'INSERT', true, 1),
  ('b3', 'SELECT', false, 2),
  ('b3', 'DELETE', false, 3),
  ('b4', 'SELECT', true, 1),
  ('b4', 'INSERT', false, 2),
  ('b4', 'UPDATE', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q21 | multiple_choice | difícil | Endereçamento IP, DNS e DHCP | Exercícios 2 | correta: A
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Um IPv4 tem 32 bits. Quantos endereços diferentes ele permite?',
    'Cada bit dobra as combinações: 32 bits dão 2^32 = 4.294.967.296 endereços. 2^128 é o total do IPv6.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('2^32 = 4.294.967.296, cerca de 4,3 bilhões', true, 1),
  ('2^32 = 4.294.967, cerca de 4,3 milhões', false, 2),
  ('4 × 8 = 32 endereços em cada rede', false, 3),
  ('2^16 = 65.536, um para cada porta', false, 4),
  ('2^128, cerca de 340 undecilhões', false, 5)
) AS o(text, is_correct, order_index);

-- Q22 | drag_and_drop | difícil | Redirecionamento de portas e comando ssh | Exercícios 2 | s1: Criar a regra SSH: hospedeiro 2222, convidado 22, s2: Iniciar a VM em modo headless, s3: Executar ssh sptech@127.0.0.1 -p 2222, s4: Digitar a senha do usuário sptech | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'Ordene os passos para acessar a sua VM Lubuntu pelo terminal do host, sem abrir a interface gráfica da VM: 1º {{s1}}; 2º {{s2}}; 3º {{s3}}; 4º {{s4}}.',
    'Primeiro se cria o redirecionamento (2222 do host para 22 da VM), depois a VM é iniciada em headless e o ssh é executado no host com -p 2222, pedindo a senha do sptech. A regra invertida e a porta 22 não chegam à VM.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('Executar ssh sptech@127.0.0.1 -p 2222', 1),
    ('Criar a regra SSH: hospedeiro 22, convidado 2222', 2),
    ('Digitar a senha do usuário sptech', 3),
    ('Criar a regra SSH: hospedeiro 2222, convidado 22', 4),
    ('Executar ssh sptech@127.0.0.1 -p 22', 5),
    ('Iniciar a VM em modo headless', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'Criar a regra SSH: hospedeiro 2222, convidado 22', 1),
  ('s2', 'Iniciar a VM em modo headless', 2),
  ('s3', 'Executar ssh sptech@127.0.0.1 -p 2222', 3),
  ('s4', 'Digitar a senha do usuário sptech', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q23 | multiple_answer | difícil | Arquitetura cliente/servidor e servidores | Exercícios 2 | corretas: A, B, D | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer',
    'Uma escola passou a guardar as notas num servidor, acessado pelos computadores dos alunos. Assinale todas as que descrevem corretamente uma vantagem ou um desafio dessa escolha.',
    'Manutenção no servidor, risco de indisponibilidade e escalar com mais servidores estão no material. Centralizar não elimina o desafio de segurança, e centralizar é justamente ter os dados num lugar só.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Atualizar o sistema só no servidor, sem mexer nos computadores dos alunos, é facilidade de manutenção', true, 1),
  ('Se o servidor cair, nenhum aluno vê as notas: é um desafio de disponibilidade', true, 2),
  ('Centralizar as notas elimina a necessidade de proteger os dados que trafegam na rede', false, 3),
  ('Adicionar outro servidor quando a escola crescer é um exemplo de escalabilidade', true, 4),
  ('Cada aluno passa a ter sua própria cópia das notas, e isso é a centralização', false, 5)
) AS o(text, is_correct, order_index);

-- Q24 | multiple_choice | difícil | Redirecionamento de portas e comando ssh | Exercícios 2 | correta: E | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Um aluno criou no VirtualBox a regra «SSH | TCP | porta do hospedeiro 22 | porta do convidado 2222» e executou ssh sptech@127.0.0.1 -p 2222 no host. O que acontece?',
    'O ssh bate na 2222 do host, mas a regra só redireciona a 22 do host, e para a 2222 da VM, onde o SSH não escuta. O SSH da VM está na 22, então a regra certa é 2222 no hospedeiro e 22 no convidado.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Conecta normalmente, pois a ordem das portas na regra não importa', false, 1),
  ('Conecta na VM, mas entra como root em vez de sptech', false, 2),
  ('Falha só porque faltou a regra do MySQL, de 3307 para 3306', false, 3),
  ('Funciona se o aluno trocar a opção para -P 2222, maiúsculo', false, 4),
  ('Falha: as portas estão invertidas; o certo é hospedeiro 2222 e convidado 22', true, 5)
) AS o(text, is_correct, order_index);

-- Q25 | single_choice | difícil | Portas e comandos de rede | Exercícios 2 | b1: getmac, b2: ipconfig, b3: pathping | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice',
    'No Windows, para ver o endereço MAC da placa de rede, o técnico usa {{b1}}; para ver o endereço IPv4, a máscara de sub-rede e o gateway padrão, usa {{b2}}; e para ver a rota com a estatística de perda de pacotes em cada salto, usa {{b3}}.',
    'getmac mostra o MAC, ipconfig mostra a configuração IP do adaptador, e pathping combina ping e tracert com o relatório de perda e latência por salto.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', 'getmac', true, 1),
  ('b1', 'hostname', false, 2),
  ('b1', 'netstat', false, 3),
  ('b2', 'ipconfig', true, 1),
  ('b2', 'getmac', false, 2),
  ('b2', 'nslookup', false, 3),
  ('b3', 'pathping', true, 1),
  ('b3', 'tracert', false, 2),
  ('b3', 'ping', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q26 | drag_and_drop | difícil | Diagrama de solução do projeto | Exercícios 2 | s1: Máquina de captura no cliente, s2: Servidor de BD e APP (VM Linux), s3: Cliente (navegador), s4: 3300, s5: 3333 | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'Complete a arquitetura implementada do projeto. A captura de dados roda em {{s1}}; o armazenamento e a seleção rodam em {{s2}}; a dashboard é vista em {{s3}}. A API Data Acquino usa a porta {{s4}} e a API Web Data Viz, a porta {{s5}}.',
    'A captura (Arduino e Data Acquino, porta 3300) fica na máquina instalada no cliente; MySQL e Web Data Viz (porta 3333) ficam na VM Linux; o cliente vê a dashboard no navegador. 3306 é a porta do MySQL.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('3333', 1),
    ('Servidor de BD e APP (VM Linux)', 2),
    ('3306', 3),
    ('Cliente (navegador)', 4),
    ('Máquina de captura no cliente', 5),
    ('3300', 6),
    ('Servidor DNS', 7)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'Máquina de captura no cliente', 1),
  ('s2', 'Servidor de BD e APP (VM Linux)', 2),
  ('s3', 'Cliente (navegador)', 3),
  ('s4', '3300', 4),
  ('s5', '3333', 5)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q27 | multiple_choice | difícil | Portas e comandos de rede | Exercícios 2 | correta: C | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'No mesmo servidor 192.168.11.2 rodam um site em HTTP e o MySQL. Como o sistema operacional entrega cada conexão ao serviço certo?',
    'Porta é um ponto virtual, baseado em software e gerenciado pelo SO, associado a um serviço: o endereço completo é IP mais porta, como 192.168.11.2:80.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Por portas físicas diferentes da placa de rede, uma por serviço', false, 1),
  ('Pelo DNS, que dá um nome diferente para cada serviço', false, 2),
  ('Pela porta lógica, gerenciada pelo SO: :80 vai ao site e :3306 ao MySQL', true, 3),
  ('Pelo DHCP, que entrega um IP diferente para cada serviço', false, 4),
  ('Pelo MAC, pois cada serviço tem o seu endereço físico', false, 5)
) AS o(text, is_correct, order_index);

-- Q28 | multiple_answer | difícil | SSH e shell remoto | Exercícios 2 | corretas: A, B, E | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer',
    'A empresa vai mover o servidor de BD e APP para a cloud (TO BE), e o DBA vai administrá-lo do notebook dele por um shell remoto com SSH. Assinale todas as corretas.',
    'Para o shell remoto é preciso o IP e a porta de destino, e o SSH protege a conexão com autenticação, criptografia e integridade. Quem pede a conexão (o notebook do DBA) é o cliente; a máquina na cloud é o servidor.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('O DBA precisa saber o IP e a porta de destino do servidor', true, 1),
  ('Com o SSH, a senha e os comandos trafegam criptografados', true, 2),
  ('O SSH dispensa autenticação, pois a cloud já é segura', false, 3),
  ('O notebook do DBA é o servidor SSH e a cloud é o cliente', false, 4),
  ('A integridade garante que os dados não foram alterados no caminho', true, 5)
) AS o(text, is_correct, order_index);

-- Q29 | multiple_choice | difícil | Diagrama de solução do projeto | Exercícios 2 | correta: B | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'A dashboard abre normalmente na porta 3333, mas os gráficos pararam de ser atualizados às 10h. No MySQL da VM, a última linha da tabela de leituras foi inserida às 10h. Em qual parte do diagrama está a falha mais provável?',
    'Se nada novo chega ao MySQL, o problema está antes do armazenamento: na captura (Arduino) ou na inserção (API Data Acquino, porta 3300). O site e a seleção continuam mostrando o que existe no banco.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Na transformação em gráficos, feita em HTML, CSS e JS', false, 1),
  ('Na captura ou na inserção: o Arduino ou a API Data Acquino parou', true, 2),
  ('No armazenamento: o MySQL apagou as linhas inseridas depois das 10h', false, 3),
  ('Na seleção: a API Web Data Viz deixou de fazer o SELECT', false, 4),
  ('Na visualização: o navegador do cliente ficou sem cache', false, 5)
) AS o(text, is_correct, order_index);

-- Q30 | drag_and_drop | difícil | Arquitetura cliente/servidor e servidores | Exercícios 2 | s1: Escalabilidade, s2: Facilidade de manutenção, s3: Segurança, s4: Sobrecarga dos servidores | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'Associe cada situação à vantagem ou ao desafio da arquitetura cliente/servidor: o sistema ganha um segundo servidor para atender mais usuários {{s1}}; a correção do sistema é instalada só no servidor {{s2}}; um ataque tenta roubar os dados que trafegam entre cliente e servidor {{s3}}; com muitos acessos ao mesmo tempo, o servidor fica lento {{s4}}.',
    'Adicionar servidores conforme a demanda é escalabilidade; atualizar no servidor sem afetar os clientes é facilidade de manutenção; proteger os dados transmitidos é segurança; e a lentidão por alta demanda é sobrecarga.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 2: Aplicação'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('Segurança', 1),
    ('Centralização de dados', 2),
    ('Sobrecarga dos servidores', 3),
    ('Escalabilidade', 4),
    ('Complexidade', 5),
    ('Facilidade de manutenção', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'Escalabilidade', 1),
  ('s2', 'Facilidade de manutenção', 2),
  ('s3', 'Segurança', 3),
  ('s4', 'Sobrecarga dos servidores', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q31 | multiple_choice | super difícil | Endereçamento IP, DNS e DHCP | Exercícios 3 | correta: A | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'O professor rodou tracert moodle.sptech.school em dois momentos. Na primeira vez, o nome resolveu para um IP na AWS em Virgínia (EUA), com saltos acima de 100 ms; na segunda, para um IP de um datacenter da Microsoft em São Paulo, com saltos de 2 a 9 ms. O que explica a diferença?',
    'O nome é traduzido pelo DNS, que pode apontar para servidores diferentes; o tracert mostra cada salto com sua latência, e um destino fora do país tem tempos bem maiores.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('O DNS devolveu IPs diferentes para o mesmo nome, e a distância física aparece na latência', true, 1),
  ('O DHCP trocou o IP do servidor do Moodle entre a primeira e a segunda medição', false, 2),
  ('O tracert mede a velocidade do computador do aluno, e não o caminho até o destino', false, 3),
  ('A porta 443 é mais rápida que a porta 80, e o HTTPS só foi usado na segunda vez', false, 4),
  ('A primeira medição usou IPv6 e a segunda IPv4, que tem menos saltos até o destino', false, 5)
) AS o(text, is_correct, order_index);

-- Q32 | multiple_answer | super difícil | Redirecionamento de portas e comando ssh | Exercícios 3 | corretas: A, B, E | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer',
    'O seu host tem o IP 192.168.0.10 e o do colega Caio, 192.168.0.22. As duas VMs têm as regras SSH 2222 → 22 e MySQL 3307 → 3306 e o usuário sptech. Assinale todas as corretas.',
    '127.0.0.1 é a própria máquina, e para a VM de outra pessoa usa-se o IP do host dela, sempre com a porta 2222. A 3307 leva ao MySQL, não ao SSH, e o travessão não é lido como opção, então o ssh tenta a porta 22.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('ssh sptech@127.0.0.1 -p 2222, rodado no seu host, abre o shell da sua VM', true, 1),
  ('ssh sptech@192.168.0.22 -p 2222, rodado no seu host, abre o shell da VM do Caio', true, 2),
  ('ssh sptech@192.168.0.22 -p 3307, rodado no seu host, abre o shell da VM do Caio', false, 3),
  ('ssh sptech@127.0.0.1 –p 2222, com travessão, conecta na sua VM pela porta 2222', false, 4),
  ('ssh sptech@192.168.0.10 -p 2222, rodado no host do Caio, abre o shell da sua VM', true, 5)
) AS o(text, is_correct, order_index);

-- Q33 | single_choice | super difícil | Redirecionamento de portas e comando ssh | Exercícios 3 | b1: 22, b2: não é lido como opção, e o ssh usa a porta padrão, b3: -p 2222, com hífen comum e p minúsculo | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice',
    'O aluno copiou do slide a linha ssh sptech@127.0.0.1 –p 2222, com travessão, e recebeu «ssh: connect to host 127.0.0.1 port {{b1}}: Connection refused». Isso acontece porque o travessão {{b2}}. O comando certo usa {{b3}}.',
    'O ssh só reconhece opções que começam com o hífen comum; com o travessão, «–p 2222» vira texto comum e a conexão vai para a porta padrão, 22, onde nada atende no host. -P maiúsculo é outra opção do ssh.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', '22', true, 1),
  ('b1', '2222', false, 2),
  ('b1', '3306', false, 3),
  ('b2', 'não é lido como opção, e o ssh usa a porta padrão', true, 1),
  ('b2', 'inverte as portas da regra de redirecionamento', false, 2),
  ('b2', 'só funciona com o P maiúsculo', false, 3),
  ('b3', '-p 2222, com hífen comum e p minúsculo', true, 1),
  ('b3', '-P 2222, com hífen comum e P maiúsculo', false, 2),
  ('b3', '–p 22, com travessão e a porta da VM', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q34 | drag_and_drop | super difícil | Portas e comandos de rede | Exercícios 3 | s1: Falha de DNS: o nome não foi resolvido, s2: Falha de conectividade: o host não respondeu, s3: Conectividade ok com o host, s4: O host responde, mas nada atende nessa porta | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'Associe cada saída, obtida no terminal Linux da LogiFast, ao diagnóstico: «ping: erp.logifast.local: Name or service not known» {{s1}}; «2 packets transmitted, 0 received, 100% packet loss» ao pingar 192.168.0.30 {{s2}}; «64 bytes from 192.168.0.30: icmp_seq=1 ttl=64 time=0.412 ms» {{s3}}; «curl: (7) Failed to connect to 192.168.0.30 port 3333: Could not connect to server», com o ping no mesmo IP respondendo {{s4}}.',
    'Name or service not known é falha na resolução do nome; 100% de perda é falta de resposta do host; a resposta do ping mostra conectividade; e, se o host responde mas a porta 3333 recusa, falta o serviço associado a essa porta.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('O host responde, mas nada atende nessa porta', 1),
    ('Conflito de IP causado pelo DHCP', 2),
    ('Falha de DNS: o nome não foi resolvido', 3),
    ('MAC errado na placa de rede', 4),
    ('Conectividade ok com o host', 5),
    ('Falha de conectividade: o host não respondeu', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'Falha de DNS: o nome não foi resolvido', 1),
  ('s2', 'Falha de conectividade: o host não respondeu', 2),
  ('s3', 'Conectividade ok com o host', 3),
  ('s4', 'O host responde, mas nada atende nessa porta', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q35 | multiple_choice | super difícil | Arquitetura cliente/servidor e servidores | Exercícios 3 | correta: B | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Um estagiário anotou sobre o servidor do projeto: (I) a VM Linux é um servidor virtual; (II) o Node.js com o web-data-viz é o servidor web; (III) o MySQL também é um servidor web, pois serve dados; (IV) a mesma VM cumpre mais de um papel. Quais anotações estão corretas?',
    'A VM é um servidor virtual que acumula os papéis de banco e de aplicação, e o servidor web é o software que entrega as páginas por HTTP. O MySQL fornece dados, mas não é servidor web.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('Apenas I e II', false, 1),
  ('Apenas I, II e IV', true, 2),
  ('Apenas II e III', false, 3),
  ('Apenas III e IV', false, 4),
  ('Todas as quatro', false, 5)
) AS o(text, is_correct, order_index);

-- Q36 | drag_and_drop | super difícil | Redirecionamento de portas e comando ssh | Exercícios 3 | s1: 127.0.0.1, s2: 3307, s3: 3306, s4: 2222 | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'No host, um cliente MySQL vai acessar o banco da VM pela regra Conexão MySQL, e o terminal vai abrir o shell da mesma VM. Complete: o cliente MySQL usa o endereço {{s1}} e a porta {{s2}}; dentro da VM, o MySQL escuta na porta {{s3}}; e o ssh no host usa -p {{s4}}.',
    'Do host, a VM é alcançada pelo próprio host (127.0.0.1) nas portas redirecionadas: 3307 leva à 3306 do MySQL na VM e 2222 leva à 22 do SSH. O IP interno da VM não é usado.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('3306', 1),
    ('10.0.2.15', 2),
    ('2222', 3),
    ('22', 4),
    ('127.0.0.1', 5),
    ('3307', 6),
    ('5432', 7)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', '127.0.0.1', 1),
  ('s2', '3307', 2),
  ('s3', '3306', 3),
  ('s4', '2222', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q37 | multiple_choice | super difícil | Endereçamento IP, DNS e DHCP | Exercícios 3 | correta: D
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'O endereço 192.168.0.228 é escrito em decimal, mas armazenado em binário. Qual é a representação binária correta?',
    'Cada octeto vira 8 bits: 192 = 11000000, 168 = 10101000, 0 = 00000000 e 228 = 11100100. A última alternativa junta os bits em 2 grupos de 16, o que não é o formato do IPv4.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('11000000.10101000.00000000.11100010', false, 1),
  ('11000000.10100100.00000000.11100100', false, 2),
  ('11000001.10101000.00000000.11100100', false, 3),
  ('11000000.10101000.00000000.11100100', true, 4),
  ('1100000010101000.0000000011100100', false, 5)
) AS o(text, is_correct, order_index);

-- Q38 | single_choice | super difícil | Diagrama de solução do projeto | Exercícios 3 | b1: 3307, b2: 3306, b3: 3333 | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'single_choice',
    'No AS IS, a captura roda no notebook (host) e o MySQL roda na VM Lubuntu do mesmo notebook, com a regra Conexão MySQL 3307 → 3306. A API Data Acquino, no host, se conecta ao banco em 127.0.0.1 na porta {{b1}}; dentro da VM, o MySQL escuta na porta {{b2}}; e a API Web Data Viz, que entrega a dashboard, escuta na porta {{b3}}.',
    'Quem está no host chega ao MySQL da VM pela porta redirecionada do hospedeiro, 3307, que leva à 3306 do convidado. A Data Acquino usa a 3300 e a Web Data Viz, a 3333.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio'
), b AS (
  INSERT INTO question_blanks (question_id, blank_key, order_index)
  SELECT q.id, v.blank_key, v.order_index
  FROM q CROSS JOIN (VALUES ('b1', 1), ('b2', 2), ('b3', 3)) AS v(blank_key, order_index)
  RETURNING id, blank_key
)
INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
SELECT b.id, o.text, o.is_correct, o.order_index
FROM b JOIN (VALUES
  ('b1', '3307', true, 1),
  ('b1', '3306', false, 2),
  ('b1', '3300', false, 3),
  ('b2', '3306', true, 1),
  ('b2', '3307', false, 2),
  ('b2', '3333', false, 3),
  ('b3', '3333', true, 1),
  ('b3', '3300', false, 2),
  ('b3', '443', false, 3)
) AS o(blank_key, text, is_correct, order_index) ON o.blank_key = b.blank_key;

-- Q39 | multiple_answer | super difícil | Portas e comandos de rede | Exercícios 3 | corretas: A, B, D | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer',
    'Num servidor Linux, um técnico precisa descobrir o IP de logifast.com.br, ver a rota até ele e conferir o IP da própria máquina. Assinale todas as escolhas corretas.',
    'No Linux, host e dig consultam o DNS, traceroute mostra a rota e ip a lista os endereços da máquina. ipconfig é do Windows, e getmac mostra o MAC, não o IP.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('host logifast.com.br ou dig logifast.com.br, para o IP do domínio', true, 1),
  ('traceroute logifast.com.br, para a rota até o destino', true, 2),
  ('ipconfig, para o IP da própria máquina no Linux', false, 3),
  ('ip a, para o IP da própria máquina', true, 4),
  ('getmac, para o IP da própria máquina', false, 5)
) AS o(text, is_correct, order_index);

-- Q40 | drag_and_drop | super difícil | Redirecionamento de portas e comando ssh | Exercícios 3 | s1: Abre o shell da sua VM, s2: Abre o shell da VM do colega, s3: Tenta a porta 22 do seu host, s4: Não chega à VM: é o IP interno dela | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'O seu host tem o IP 192.168.0.10 e a sua VM tem o redirecionamento 2222 → 22; o host do colega, 192.168.0.22, tem a mesma regra. Associe cada linha executada no seu host ao resultado: ssh sptech@127.0.0.1 -p 2222 {{s1}}; ssh sptech@192.168.0.22 -p 2222 {{s2}}; ssh sptech@127.0.0.1 –p 2222, com travessão {{s3}}; ssh sptech@10.0.2.15 -p 2222 {{s4}}.',
    '127.0.0.1 com 2222 leva à sua VM, e o IP do host do colega com 2222 leva à VM dele. O travessão não é lido como opção, então o ssh tenta a 22 do seu host, e o IP interno da VM não é o endereço usado para acessá-la de fora.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('Abre o MySQL da VM do colega', 1),
    ('Abre o shell da sua VM', 2),
    ('Tenta a porta 22 do seu host', 3),
    ('Abre o shell do host do colega', 4),
    ('Não chega à VM: é o IP interno dela', 5),
    ('Abre o shell da VM do colega', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'Abre o shell da sua VM', 1),
  ('s2', 'Abre o shell da VM do colega', 2),
  ('s3', 'Tenta a porta 22 do seu host', 3),
  ('s4', 'Não chega à VM: é o IP interno dela', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q41 | multiple_choice | super difícil | SSH e shell remoto | Exercícios 3 | correta: C | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'Na rede da sala, um atacante (I) tenta ler os pacotes de uma sessão SSH, (II) tenta alterar um comando no caminho e (III) tenta entrar no servidor com um usuário que não é dele. Qual pilar do SSH protege cada caso?',
    'A criptografia garante a privacidade do que trafega, a integridade garante que os dados não foram alterados, e a autenticação confirma quem está se conectando.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('I autenticação, II criptografia e III integridade', false, 1),
  ('I integridade, II autenticação e III criptografia', false, 2),
  ('I criptografia, II integridade e III autenticação', true, 3),
  ('I criptografia, II autenticação e III integridade', false, 4),
  ('I integridade, II criptografia e III autenticação', false, 5)
) AS o(text, is_correct, order_index);

-- Q42 | multiple_choice | super difícil | Endereçamento IP, DNS e DHCP | Exercícios 3 | correta: E | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'A LogiFast configurou IP fixo, à mão, em todos os 120 computadores. Após uma troca de máquinas, dois computadores ficaram com 192.168.0.50 e um deles perdeu a rede. Já o servidor de pedidos, que estava no DHCP, mudou de IP ao reiniciar e ninguém mais achou o sistema. Qual configuração resolve os dois problemas?',
    'O DHCP evita conflitos de IP e facilita o gerenciamento dos computadores; o servidor, que não pode mudar de endereço, deve ter IP fixo.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('IP fixo em todos, revisando a planilha de endereços à mão', false, 1),
  ('DHCP em todos, inclusive no servidor de pedidos', false, 2),
  ('DNS nos computadores e DHCP no servidor de pedidos', false, 3),
  ('IP fixo nos computadores e DHCP no servidor de pedidos', false, 4),
  ('DHCP nos computadores e IP fixo no servidor de pedidos', true, 5)
) AS o(text, is_correct, order_index);

-- Q43 | multiple_answer | super difícil | Arquitetura cliente/servidor e servidores | Exercícios 3 | corretas: B, C, E | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_answer',
    'A LogiFast troca as planilhas copiadas por pendrive entre as mesas por um sistema cliente/servidor. Assinale todas as corretas.',
    'Centralizar os dados acaba com as cópias desatualizadas, e os computadores viram clientes do servidor; em troca, a disponibilidade do servidor vira um ponto crítico. A segurança continua sendo um desafio, e a manutenção fica mais fácil, feita no servidor.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('A mudança elimina o desafio de segurança, pois os dados ficam num lugar só', false, 1),
  ('Os dados ficam centralizados no servidor, sem cópias desatualizadas nas mesas', true, 2),
  ('Os computadores dos funcionários passam a ser clientes que fazem solicitações', true, 3),
  ('Cada cliente precisa receber a atualização do sistema, o que dificulta a manutenção', false, 4),
  ('Se o servidor ficar indisponível, ninguém acessa os dados: o risco se concentra', true, 5)
) AS o(text, is_correct, order_index);

-- Q44 | drag_and_drop | super difícil | Diagrama de solução do projeto | Exercícios 3 | s1: Captura, instalada no cliente, s2: Servidor de BD e APP, na cloud, s3: Cliente que acessa pelo navegador, s4: Máquina Dev/BDA com shell remoto | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, template, explanation)
  SELECT t.id, 'drag_and_drop',
    'No diagrama TO BE da aula de SSH, associe cada número ao que ele representa: (1) {{s1}}; (2) {{s2}}; (3) {{s3}}; (4) {{s4}}.',
    'No TO BE, a captura (1) fica no cliente, o servidor de BD e APP (2) vai para a cloud, o cliente (3) acessa pelo navegador e a máquina Dev/BDA (4) administra o servidor por shell remoto.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio'
), tm AS (
  INSERT INTO question_terms (question_id, text, order_index)
  SELECT q.id, v.text, v.order_index
  FROM q CROSS JOIN (VALUES
    ('Servidor de BD e APP, na cloud', 1),
    ('Servidor DNS da empresa', 2),
    ('Máquina Dev/BDA com shell remoto', 3),
    ('Captura, instalada no cliente', 4),
    ('Serial Plotter do Arduino', 5),
    ('Cliente que acessa pelo navegador', 6)
  ) AS v(text, order_index)
  RETURNING id, text
)
INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
SELECT q.id, v.slot_key, tm.id, v.order_index
FROM q CROSS JOIN (VALUES
  ('s1', 'Captura, instalada no cliente', 1),
  ('s2', 'Servidor de BD e APP, na cloud', 2),
  ('s3', 'Cliente que acessa pelo navegador', 3),
  ('s4', 'Máquina Dev/BDA com shell remoto', 4)
) AS v(slot_key, term_text, order_index)
JOIN tm ON tm.text = v.term_text;

-- Q45 | multiple_choice | super difícil | SSH e shell remoto | Exercícios 3 | correta: A | cenário prático
WITH q AS (
  INSERT INTO questions (topic_id, type, prompt, explanation)
  SELECT t.id, 'multiple_choice',
    'No desafio da aula, três colegas acessam por SSH a mesma VM do projeto, com os escopos front-end, back-end e admin. O admin executa reboot enquanto os outros dois ainda estão conectados. O que acontece?',
    'Os três shells remotos estão no mesmo servidor, a VM; o reboot reinicia a máquina inteira e derruba todas as sessões, que precisam ser abertas de novo pelo ssh.'
  FROM topics t JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  RETURNING id
), l AS (
  INSERT INTO quiz_questions (quiz_id, question_id, order_index)
  SELECT z.id, q.id,
    (SELECT COALESCE(MAX(qq.order_index), 0) + 1 FROM quiz_questions qq WHERE qq.quiz_id = z.id)
  FROM q JOIN quizzes z
    ON z.kind = 'exercise' AND z.title = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH — Exercícios 3: Desafio'
)
INSERT INTO question_options (question_id, text, is_correct, order_index)
SELECT q.id, o.text, o.is_correct, o.order_index
FROM q CROSS JOIN (VALUES
  ('As sessões SSH dos três caem, pois a VM reinicia; é preciso reconectar quando ela voltar', true, 1),
  ('Nada muda para os outros dois, pois cada sessão SSH roda numa VM separada', false, 2),
  ('Só o admin é desconectado, pois o reboot vale apenas para quem o executou', false, 3),
  ('A VM volta com interface gráfica, e o modo headless deixa de funcionar', false, 4),
  ('O host de quem criou a regra 2222 → 22 é reiniciado junto com a VM', false, 5)
) AS o(text, is_correct, order_index);

-- 8. Conferência: aborta se a aula não ficou com 45 questões, 3 listas de 15 e nenhuma questão fora delas
DO $$
BEGIN
  IF (
    SELECT count(*) FROM questions q
    JOIN topics t ON t.id = q.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
  ) <> 45 THEN
    RAISE EXCEPTION 'A aula deveria ter 45 questões';
  END IF;

  IF (
    SELECT count(*) FROM (
      SELECT z.id
      FROM quizzes z
      JOIN topics t ON t.id = z.topic_id
      JOIN subjects s ON s.id = t.subject_id
      JOIN quiz_questions qq ON qq.quiz_id = z.id
      WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH' AND z.kind = 'exercise'
      GROUP BY z.id
      HAVING count(*) = 15
    ) AS full_lists
  ) <> 3 THEN
    RAISE EXCEPTION 'A aula deveria ter 3 listas de exercícios com 15 questões cada';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM questions q
    JOIN topics t ON t.id = q.topic_id
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = 'Sistemas Operacionais' AND t.name = 'Cliente/Servidor, Diagrama de Solução, Redes e SSH'
      AND NOT EXISTS (
        SELECT 1 FROM quiz_questions qq JOIN quizzes z ON z.id = qq.quiz_id
        WHERE qq.question_id = q.id AND z.kind = 'exercise'
      )
  ) THEN
    RAISE EXCEPTION 'Há questão da aula fora das listas de exercícios';
  END IF;
END $$;

COMMIT;
