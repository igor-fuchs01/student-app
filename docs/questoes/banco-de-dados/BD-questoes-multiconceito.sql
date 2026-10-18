-- Banco de Dados — questões multiconceito. Reescreve 20 questões já cadastradas no estilo das
-- atividades da disciplina: cada questão cobra vários conceitos ao mesmo tempo (autorelacionamento
-- com WHERE, LIKE e ORDER BY, três tabelas na mesma junção, diagnóstico de erro 1452 e 1142,
-- CREATE TABLE e ALTER TABLE com várias constraints, regra de negócio para modelagem) e recompõe
-- os dois simulados da disciplina com elas.
-- Rode BD-questoes.sql, BD-questoes-autorelacionamento.sql e BD-simulado.sql antes deste.
-- As questões são reescritas no lugar: mantêm id, tipo, lista de exercícios e a quantidade de
-- alternativas, lacunas, opções, termos e slots, e só os textos, as respostas certas e as
-- explicações mudam. As respostas já enviadas continuam com a correção gravada em review_status.
-- Cada questão é localizada pelo início do seu enunciado atual, dentro da disciplina Banco de
-- Dados; cada simulado, pelo nível (medium e hard), pois os títulos foram alterados no banco.
-- Distribuição das 20 reescritas: 9 multiple_choice, 2 multiple_answer, 2 single_choice e
-- 7 drag_and_drop.
-- Simulados: o de nível médio passa a ter 20 questões, 15 delas reescritas, e duração de
-- 50 minutos; o difícil passa a ter 30, 20 delas reescritas, e mantém os 60 minutos.
-- Uma única transação: se qualquer comando falhar, nada é gravado.

BEGIN;

-- 1. Questões usadas pelo script: reescritas (r01 a r20, com o formato atual esperado) e
-- mantidas (m01 a m12, que só entram nos simulados)
CREATE TEMP TABLE bd_multiconceito ON COMMIT DROP AS
SELECT v.key, v.statement_start, v.shape, NULL::integer AS question_id
FROM (VALUES
  ('r01', 'Em um sistema de cadastro de uma loja, a equipe de banco de dados quer', 'multiple_choice o5'),
  ('r02', 'Em modelagem de banco de dados, o que caracteriza um autorelacionamento?', 'multiple_choice o5'),
  ('r03', 'Uma faculdade tem as tabelas curso (idCurso, nomeCurso) e aluno', 'multiple_choice o5'),
  ('r04', 'Uma clínica cria a tabela paciente', 'multiple_choice o5'),
  ('r05', 'Uma loja virtual tem a tabela produto com milhões de registros', 'multiple_choice o5'),
  ('r06', 'A faculdade tem aluno (ra, nomeAluno, fkEmpresa, fkCurso)', 'multiple_choice o5'),
  ('r07', 'Na tabela funcionario (idFunc, nome, fkGerente), a coluna fkGerente guarda', 'multiple_choice o5'),
  ('r08', 'Na tabela funcionario (idFunc, nome, fkSupervisor), em que fkSupervisor referencia idFunc, por que', 'multiple_choice o5'),
  ('r09', 'Um administrador abriu o prompt como administrador', 'multiple_choice o5'),
  ('r10', 'Sobre a inserção de dados na tabela funcionario', 'multiple_answer o5'),
  ('r11', 'Após executar CREATE USER', 'multiple_answer o5'),
  ('r12', 'Na consulta de autorelacionamento sobre funcionario', 'single_choice b3,4,3'),
  ('r13', 'Para conceder somente leitura e atualização ao usuário app', 'single_choice b3,3,3,4'),
  ('r14', 'Ordene as etapas para criar o usuário app', 'drag_and_drop t6s4'),
  ('r15', 'Para adicionar a regra de status na tabela sensor', 'drag_and_drop t4s2'),
  ('r16', 'Na tabela pedido: a coluna status', 'drag_and_drop t6s4'),
  ('r17', 'Na relação 1:N entre aluno e telefone', 'drag_and_drop t6s4'),
  ('r18', 'Para listar apenas os alunos que têm curso correspondente', 'drag_and_drop t7s4'),
  ('r19', 'Em funcionario, {{s1}} é a chave primária', 'drag_and_drop t7s4'),
  ('r20', 'Ao encerrar o acesso do usuário app ao schema projeto', 'drag_and_drop t6s3'),
  ('m01', 'Uma loja tem cliente (idCliente, nome) e pedido (idPedido, fkCliente). Qual consulta lista apenas', NULL),
  ('m02', 'Considere aluno (ra, nomeAluno, fkCurso), curso (idCurso, nomeCurso) e a consulta', NULL),
  ('m03', 'Com cliente (idCliente, nome) e pedido (idPedido, fkCliente), qual consulta, no estilo dos slides', NULL),
  ('m04', 'Em um sistema que cadastra alunos de várias faculdades', NULL),
  ('m05', 'Sobre o autorelacionamento na tabela funcionario', NULL),
  ('m06', 'Uma empresa tem departamento (idDepto, nomeDepto) e funcionario', NULL),
  ('m07', 'Para retornar apenas os registros sem correspondência dos dois lados', NULL),
  ('m08', 'Com departamento (idDepto, nomeDepto) e funcionario (idFunc, nome, fkDepto): para listar', NULL),
  ('m09', 'Na tabela funcionario (idFunc, nome, fkSupervisor), qual consulta lista os funcionários que não supervisionam', NULL),
  ('m10', 'A tabela funcionario (idFunc, nome, fkSupervisor) tem as linhas (1, Ana, NULL), (2, Bruno, 1), (3, Carla, 1) e (4, Diego, 2). O que retorna', NULL),
  ('m11', 'A tabela funcionario (idFunc, nome, fkSupervisor), em que fkSupervisor é chave estrangeira para idFunc, tem as linhas', NULL),
  ('m12', 'A tabela categoria (idCategoria, nome, fkCategoriaPai)', NULL)
) AS v(key, statement_start, shape);

-- 2. Trava: aborta, dizendo quais, se alguma questão não foi encontrada (ou o script já rodou),
-- está duplicada ou tem outro formato; e se não houver exatamente um simulado de cada nível
DO $$
DECLARE
  problems text;
BEGIN
  SELECT string_agg(format('%s (%s questão(ões) com o enunciado "%s...")', c.key, c.found, c.statement_start), E'\n  ' ORDER BY c.key)
  INTO problems
  FROM (
    SELECT m.key, m.statement_start, COUNT(q.id) AS found
    FROM bd_multiconceito m
    LEFT JOIN (
      questions q
      JOIN topics t ON t.id = q.topic_id
      JOIN subjects s ON s.id = t.subject_id AND s.name = 'Banco de Dados'
    ) ON left(COALESCE(q.prompt, q.template), length(m.statement_start)) = m.statement_start
    GROUP BY m.key, m.statement_start
  ) AS c
  WHERE c.found <> 1;

  IF problems IS NOT NULL THEN
    RAISE EXCEPTION E'Questões não encontradas ou duplicadas (o script já rodou?):\n  %', problems;
  END IF;

  UPDATE bd_multiconceito m
  SET question_id = q.id
  FROM questions q
  JOIN topics t ON t.id = q.topic_id
  JOIN subjects s ON s.id = t.subject_id
  WHERE s.name = 'Banco de Dados'
    AND left(COALESCE(q.prompt, q.template), length(m.statement_start)) = m.statement_start;

  SELECT string_agg(format('%s (esperado "%s", encontrado "%s")', c.key, c.shape, c.actual), E'\n  ' ORDER BY c.key)
  INTO problems
  FROM (
    SELECT m.key, m.shape,
      q.type || ' ' || CASE
        WHEN q.type IN ('multiple_choice', 'multiple_answer') THEN
          'o' || (SELECT COUNT(*) FROM question_options o WHERE o.question_id = q.id)
        WHEN q.type = 'drag_and_drop' THEN
          't' || (SELECT COUNT(*) FROM question_terms tm WHERE tm.question_id = q.id)
          || 's' || (SELECT COUNT(*) FROM question_slots sl WHERE sl.question_id = q.id)
        ELSE
          'b' || (
            SELECT string_agg(
              (SELECT COUNT(*) FROM question_blank_options bo WHERE bo.blank_id = b.id)::text, ','
              ORDER BY b.order_index)
            FROM question_blanks b WHERE b.question_id = q.id
          )
      END AS actual
    FROM bd_multiconceito m
    JOIN questions q ON q.id = m.question_id
    WHERE m.shape IS NOT NULL
  ) AS c
  WHERE c.actual IS DISTINCT FROM c.shape;

  IF problems IS NOT NULL THEN
    RAISE EXCEPTION E'Questões com formato diferente do esperado:\n  %', problems;
  END IF;

  IF EXISTS (
    SELECT 1
    FROM (VALUES ('medium'), ('hard')) AS v(difficulty)
    WHERE (
      SELECT COUNT(*) FROM quizzes z JOIN subjects s ON s.id = z.subject_id
      WHERE s.name = 'Banco de Dados' AND z.kind = 'exam' AND z.difficulty = v.difficulty::difficulty_level
    ) <> 1
  ) THEN
    RAISE EXCEPTION 'Banco de Dados deveria ter exatamente um simulado de cada nível (medium e hard)';
  END IF;
END $$;

-- 3. Questões reescritas

-- r01 | multiple_choice | CHECK no autorelacionamento com ALTER TABLE | correta: C
UPDATE questions SET
  prompt = 'A tabela aluno (ra INT PRIMARY KEY, nome VARCHAR(45), fkMonitor INT) tem fkMonitor como chave estrangeira para ra: cada aluno pode ter outro aluno como monitor. Qual comando cria uma regra que impede um aluno de ser cadastrado como monitor de si mesmo?',
  explanation = 'A regra é uma constraint CHECK criada com ALTER TABLE ... ADD CONSTRAINT na própria tabela aluno, com a condição ra <> fkMonitor. UPDATE altera dados, não a estrutura, e não existe tabela monitor: o monitor também é um aluno.'
WHERE id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r01');

UPDATE question_options o SET text = v.text, is_correct = v.is_correct
FROM (VALUES
  (1, 'ALTER TABLE aluno ADD CONSTRAINT chkMonitor CHECK (ra = fkMonitor);', false),
  (2, 'UPDATE aluno ADD CONSTRAINT chkMonitor CHECK (ra <> fkMonitor);', false),
  (3, 'ALTER TABLE aluno ADD CONSTRAINT chkMonitor CHECK (ra <> fkMonitor);', true),
  (4, 'ALTER TABLE aluno ADD CONSTRAINT chkMonitor UNIQUE (ra, fkMonitor);', false),
  (5, 'ALTER TABLE monitor ADD CONSTRAINT chkMonitor CHECK (ra <> fkMonitor);', false)
) AS v(order_index, text, is_correct)
WHERE o.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r01')
  AND o.order_index = v.order_index;

-- r02 | multiple_choice | regra de negócio para modelagem com autorelacionamento | correta: B
UPDATE questions SET
  prompt = 'Uma rede de hotéis cadastra todos os seus hotéis em um sistema. Cada filial pertence a no máximo uma matriz, a matriz também é um hotel da rede e uma matriz pode ter várias filiais. Qual modelagem lógica atende a essa regra de negócio?',
  explanation = 'A matriz também é um hotel, então é um autorelacionamento: fkMatriz fica em hotel, no lado N (a filial), e referencia idHotel. Ela aceita NULL, pois a própria matriz não tem matriz.'
WHERE id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r02');

UPDATE question_options o SET text = v.text, is_correct = v.is_correct
FROM (VALUES
  (1, 'Tabelas hotel e matriz, com fkHotel em matriz referenciando o idHotel', false),
  (2, 'Tabela hotel com fkMatriz referenciando o idHotel da própria tabela, aceitando NULL', true),
  (3, 'Tabela hotel com fkMatriz referenciando o idHotel da própria tabela, como NOT NULL', false),
  (4, 'Tabela hotel com chave primária composta pelas colunas idHotel e fkMatriz', false),
  (5, 'Tabela hotel com fkFilial referenciando o idHotel, pois a matriz guarda a filial', false)
) AS v(order_index, text, is_correct)
WHERE o.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r02')
  AND o.order_index = v.order_index;

-- r03 | multiple_choice | JOIN com colunas de mesmo nome, LIKE e ORDER BY | correta: D
UPDATE questions SET
  prompt = 'As tabelas curso (idCurso, nome) e aluno (ra, nome, fkCurso) têm, cada uma, uma coluna nome. Qual consulta exibe o nome do aluno e o nome do curso, somente dos alunos cujo nome começa com M, em ordem alfabética pelo nome do curso?',
  explanation = 'Como as duas tabelas têm a coluna nome, ela precisa do prefixo da tabela; sem ele, o MySQL acusa coluna ambígua. LIKE ''M%'' pega os nomes que começam com M, e o WHERE vem antes do ORDER BY.'
WHERE id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r03');

UPDATE question_options o SET text = v.text, is_correct = v.is_correct
FROM (VALUES
  (1, 'SELECT nome, nome FROM aluno JOIN curso ON fkCurso = idCurso WHERE nome LIKE ''M%'' ORDER BY nome;', false),
  (2, 'SELECT aluno.nome, curso.nome FROM aluno JOIN curso ON fkCurso = idCurso WHERE aluno.nome LIKE ''%M'' ORDER BY curso.nome;', false),
  (3, 'SELECT aluno.nome, curso.nome FROM aluno JOIN curso ON fkCurso = idCurso ORDER BY curso.nome WHERE aluno.nome LIKE ''M%'';', false),
  (4, 'SELECT aluno.nome, curso.nome FROM aluno JOIN curso ON fkCurso = idCurso WHERE aluno.nome LIKE ''M%'' ORDER BY curso.nome;', true),
  (5, 'SELECT aluno.nome, curso.nome FROM aluno JOIN curso ON fkCurso = idCurso WHERE curso.nome LIKE ''M%'' ORDER BY aluno.nome;', false)
) AS v(order_index, text, is_correct)
WHERE o.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r03')
  AND o.order_index = v.order_index;

-- r04 | multiple_choice | CREATE TABLE com auto_increment, UNIQUE, NOT NULL e autorelacionamento | correta: A
UPDATE questions SET
  prompt = 'Uma clínica precisa da tabela paciente: idPaciente é a chave primária, com auto_increment começando em 100; email não pode se repetir nem ficar vazio; e fkResponsavel, opcional, aponta para outro paciente, que é o responsável. Qual comando cria a tabela corretamente?',
  explanation = 'O valor inicial do auto_increment vai depois do parêntese, na tabela; email leva UNIQUE e NOT NULL; e fkResponsavel aceita NULL e é a FOREIGN KEY que referencia o idPaciente da própria tabela.'
WHERE id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r04');

UPDATE question_options o SET text = v.text, is_correct = v.is_correct
FROM (VALUES
  (1, 'CREATE TABLE paciente (idPaciente INT PRIMARY KEY AUTO_INCREMENT, email VARCHAR(80) UNIQUE NOT NULL, fkResponsavel INT, FOREIGN KEY (fkResponsavel) REFERENCES paciente(idPaciente)) AUTO_INCREMENT = 100;', true),
  (2, 'CREATE TABLE paciente (idPaciente INT PRIMARY KEY AUTO_INCREMENT, email VARCHAR(80) UNIQUE NOT NULL, fkResponsavel INT NOT NULL, FOREIGN KEY (fkResponsavel) REFERENCES paciente(idPaciente)) AUTO_INCREMENT = 100;', false),
  (3, 'CREATE TABLE paciente (idPaciente INT AUTO_INCREMENT = 100, email VARCHAR(80) UNIQUE NOT NULL, fkResponsavel INT, FOREIGN KEY (fkResponsavel) REFERENCES paciente(idPaciente), PRIMARY KEY (idPaciente, fkResponsavel));', false),
  (4, 'CREATE TABLE paciente (idPaciente INT PRIMARY KEY AUTO_INCREMENT, email VARCHAR(80) NOT NULL, fkResponsavel INT, FOREIGN KEY (fkResponsavel) REFERENCES paciente(idPaciente)) AUTO_INCREMENT = 100;', false),
  (5, 'CREATE TABLE paciente (idPaciente INT PRIMARY KEY AUTO_INCREMENT, email VARCHAR(80) UNIQUE NOT NULL, fkResponsavel INT, FOREIGN KEY (idPaciente) REFERENCES paciente(fkResponsavel)) AUTO_INCREMENT = 100;', false)
) AS v(order_index, text, is_correct)
WHERE o.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r04')
  AND o.order_index = v.order_index;

-- r05 | multiple_choice | autorelacionamento com LIKE e ORDER BY DESC | correta: E
UPDATE questions SET
  prompt = 'A tabela hotel (idHotel, nome, cep, fkMatriz) tem fkMatriz referenciando idHotel. Qual consulta exibe o nome de cada filial e o nome da sua matriz, somente das matrizes cujo nome começa com Ibis, em ordem decrescente pelo nome da filial?',
  explanation = 'A filial guarda a chave estrangeira, então a junção é filial.fkMatriz = matriz.idHotel. O filtro é sobre o nome da matriz e a ordenação decrescente é sobre o nome da filial; sem apelidos, a mesma tabela não pode aparecer duas vezes.'
WHERE id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r05');

UPDATE question_options o SET text = v.text, is_correct = v.is_correct
FROM (VALUES
  (1, 'SELECT filial.nome, matriz.nome FROM hotel AS filial JOIN hotel AS matriz ON matriz.fkMatriz = filial.idHotel WHERE matriz.nome LIKE ''Ibis%'' ORDER BY filial.nome DESC;', false),
  (2, 'SELECT filial.nome, matriz.nome FROM hotel AS filial JOIN hotel AS matriz ON filial.fkMatriz = matriz.idHotel WHERE filial.nome LIKE ''Ibis%'' ORDER BY filial.nome DESC;', false),
  (3, 'SELECT nome, nome FROM hotel JOIN hotel ON fkMatriz = idHotel WHERE nome LIKE ''Ibis%'' ORDER BY nome DESC;', false),
  (4, 'SELECT filial.nome, matriz.nome FROM hotel AS filial JOIN hotel AS matriz ON filial.fkMatriz = matriz.idHotel WHERE matriz.nome LIKE ''Ibis%'' ORDER BY matriz.nome DESC;', false),
  (5, 'SELECT filial.nome, matriz.nome FROM hotel AS filial JOIN hotel AS matriz ON filial.fkMatriz = matriz.idHotel WHERE matriz.nome LIKE ''Ibis%'' ORDER BY filial.nome DESC;', true)
) AS v(order_index, text, is_correct)
WHERE o.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r05')
  AND o.order_index = v.order_index;

-- r06 | multiple_choice | três tabelas com JOIN e LEFT JOIN e ORDER BY | correta: B
UPDATE questions SET
  prompt = 'Existem aluno (ra, nome, fkEmpresa, fkCurso), empresa (idEmpresa, nome) e curso (idCurso, nome). Todo aluno tem curso, mas nem todo aluno trabalha em uma empresa. Qual consulta lista todos os alunos com o nome do curso e, quando houver, o nome da empresa, em ordem alfabética pelo nome do aluno?',
  explanation = 'Todo aluno tem curso, então o JOIN com curso não perde ninguém; já a empresa é opcional e precisa de LEFT JOIN, senão os alunos sem empresa somem. As colunas nome levam o prefixo da tabela.'
WHERE id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r06');

UPDATE question_options o SET text = v.text, is_correct = v.is_correct
FROM (VALUES
  (1, 'SELECT aluno.nome, curso.nome, empresa.nome FROM aluno LEFT JOIN curso ON fkCurso = idCurso JOIN empresa ON fkEmpresa = idEmpresa ORDER BY aluno.nome;', false),
  (2, 'SELECT aluno.nome, curso.nome, empresa.nome FROM aluno JOIN curso ON fkCurso = idCurso LEFT JOIN empresa ON fkEmpresa = idEmpresa ORDER BY aluno.nome;', true),
  (3, 'SELECT aluno.nome, curso.nome, empresa.nome FROM aluno JOIN curso ON fkCurso = idCurso RIGHT JOIN empresa ON fkEmpresa = idEmpresa ORDER BY aluno.nome;', false),
  (4, 'SELECT aluno.nome, curso.nome, empresa.nome FROM aluno JOIN curso ON fkCurso = idCurso LEFT JOIN empresa ON fkCurso = idEmpresa ORDER BY aluno.nome;', false),
  (5, 'SELECT nome, nome, nome FROM aluno JOIN curso ON fkCurso = idCurso LEFT JOIN empresa ON fkEmpresa = idEmpresa ORDER BY nome;', false)
) AS v(order_index, text, is_correct)
WHERE o.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r06')
  AND o.order_index = v.order_index;

-- r07 | multiple_choice | resultado de autorelacionamento com LIKE e ORDER BY DESC | correta: C
UPDATE questions SET
  prompt = 'A tabela funcionario (idFunc, nome, fkGerente) tem as linhas (1, Marta, NULL), (2, Lucas, 1), (3, Bia, 1) e (4, Caio, 2). O que retorna a consulta SELECT f.nome, g.nome FROM funcionario f JOIN funcionario g ON f.fkGerente = g.idFunc WHERE g.nome LIKE ''M%'' ORDER BY f.nome DESC;?',
  explanation = 'Só Lucas e Bia têm gerente com nome começando por M (Marta); Caio é gerenciado por Lucas e Marta não tem gerente. Em ordem decrescente de f.nome, Lucas vem antes de Bia.'
WHERE id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r07');

UPDATE question_options o SET text = v.text, is_correct = v.is_correct
FROM (VALUES
  (1, '(Bia, Marta) e (Lucas, Marta), nessa ordem', false),
  (2, '(Marta, Lucas) e (Marta, Bia), nessa ordem', false),
  (3, '(Lucas, Marta) e (Bia, Marta), nessa ordem', true),
  (4, '(Lucas, Marta), (Caio, Lucas) e (Bia, Marta), nessa ordem', false),
  (5, '(Marta, NULL), (Lucas, Marta) e (Bia, Marta), nessa ordem', false)
) AS v(order_index, text, is_correct)
WHERE o.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r07')
  AND o.order_index = v.order_index;

-- r08 | multiple_choice | diagnóstico do erro 1452 no autorelacionamento | correta: D
UPDATE questions SET
  prompt = 'A tabela hotel (idHotel INT PRIMARY KEY, nome VARCHAR(45), fkMatriz INT), com fkMatriz referenciando idHotel, está vazia. O comando INSERT INTO hotel VALUES (2, ''Ibis Centro'', 1), (1, ''Accor'', NULL); falha com Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails. Qual ajuste resolve o erro, mantendo os dois hotéis e o vínculo da filial com a matriz?',
  explanation = 'A chave estrangeira é conferida linha a linha: a Ibis Centro aponta para o idHotel 1, que ainda não existe. Inserindo a matriz antes, a referência já existe quando a filial entra.'
WHERE id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r08');

UPDATE question_options o SET text = v.text, is_correct = v.is_correct
FROM (VALUES
  (1, 'Trocar o fkMatriz da Ibis Centro por 2, para ela referenciar a si mesma', false),
  (2, 'Executar TRUNCATE TABLE hotel e repetir exatamente o mesmo INSERT', false),
  (3, 'Declarar fkMatriz como NOT NULL e repetir exatamente o mesmo INSERT', false),
  (4, 'Inserir primeiro (1, ''Accor'', NULL) e só depois (2, ''Ibis Centro'', 1)', true),
  (5, 'Inserir os dois hotéis com fkMatriz NULL e não alterar mais nenhum dado', false)
) AS v(order_index, text, is_correct)
WHERE o.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r08')
  AND o.order_index = v.order_index;

-- r09 | multiple_choice | diagnóstico do erro 1142 e GRANT | correta: E
UPDATE questions SET
  prompt = 'O usuário ''app''@''localhost'' recebeu GRANT SELECT, UPDATE ON projeto.* e, ao executar DELETE FROM pedido WHERE idPedido = 7;, recebeu Error Code: 1142. DELETE command denied to user ''app''@''localhost'' for table ''pedido''. Ele deve passar a excluir registros, sem ganhar nenhuma outra permissão. O que o administrador executa, logado como root?',
  explanation = 'O erro 1142 indica falta de permissão: basta conceder só o DELETE com GRANT ... TO e aplicar com FLUSH PRIVILEGES. ALL daria permissões a mais, REVOKE retira permissões e o usuário já existe.'
WHERE id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r09');

UPDATE question_options o SET text = v.text, is_correct = v.is_correct
FROM (VALUES
  (1, 'GRANT ALL ON projeto.* TO ''app''@''localhost''; FLUSH PRIVILEGES;', false),
  (2, 'GRANT DELETE ON projeto.* FROM ''app''@''localhost''; FLUSH PRIVILEGES;', false),
  (3, 'REVOKE DELETE ON projeto.* FROM ''app''@''localhost''; FLUSH PRIVILEGES;', false),
  (4, 'CREATE USER ''app''@''localhost'' IDENTIFIED BY ''lobo595''; FLUSH PRIVILEGES;', false),
  (5, 'GRANT DELETE ON projeto.* TO ''app''@''localhost''; FLUSH PRIVILEGES;', true)
) AS v(order_index, text, is_correct)
WHERE o.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r09')
  AND o.order_index = v.order_index;

-- r10 | multiple_answer | INSERTs contra DEFAULT, CHECK, NOT NULL e chave estrangeira | corretas: A, C, E
UPDATE questions SET
  prompt = 'A tabela hotel foi criada com CREATE TABLE hotel (idHotel INT PRIMARY KEY, nome VARCHAR(45) NOT NULL, estrelas INT DEFAULT 3, fkMatriz INT, CONSTRAINT chkEstrelas CHECK (estrelas <= 5), FOREIGN KEY (fkMatriz) REFERENCES hotel(idHotel)); e já tem a linha (1, ''Accor'', 4, NULL). Assinale todas as corretas.',
  explanation = 'DEFAULT preenche estrelas com 3 quando a coluna não é informada, e fkMatriz aceita NULL ou um idHotel existente. Estrelas 6 viola o CHECK, o idHotel 9 não existe e nome é NOT NULL, então esses INSERTs são rejeitados.'
WHERE id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r10');

UPDATE question_options o SET text = v.text, is_correct = v.is_correct
FROM (VALUES
  (1, 'INSERT INTO hotel (idHotel, nome, fkMatriz) VALUES (2, ''Ibis'', 1); é aceito, com estrelas 3', true),
  (2, 'INSERT INTO hotel VALUES (3, ''Ibis Sul'', 6, 1); é aceito, pois a matriz 1 existe', false),
  (3, 'INSERT INTO hotel VALUES (4, ''Ibis Norte'', 5, 9); é rejeitado pela chave estrangeira', true),
  (4, 'INSERT INTO hotel (idHotel, estrelas, fkMatriz) VALUES (5, 4, 1); é aceito, com nome vazio', false),
  (5, 'INSERT INTO hotel VALUES (6, ''Novotel'', 5, NULL); é aceito como uma nova matriz', true)
) AS v(order_index, text, is_correct)
WHERE o.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r10')
  AND o.order_index = v.order_index;

-- r11 | multiple_answer | CREATE USER, GRANT, REVOKE e erro 1142 em sequência | corretas: A, C, E
UPDATE questions SET
  prompt = 'Logado como root, o administrador executou: CREATE USER ''app''@''localhost'' IDENTIFIED BY ''lobo595''; GRANT ALL ON projeto.* TO ''app''@''localhost''; REVOKE DELETE, DROP ON projeto.* FROM ''app''@''localhost''; FLUSH PRIVILEGES; Assinale todas as corretas sobre o usuário app.',
  explanation = 'O REVOKE retira só DELETE e DROP do ALL concedido antes, e o que foi retirado é negado com o erro 1142. O login dele é mysql -u app -p, e um novo GRANT DELETE devolve a exclusão.'
WHERE id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r11');

UPDATE question_options o SET text = v.text, is_correct = v.is_correct
FROM (VALUES
  (1, 'Ele consegue executar SELECT e UPDATE nas tabelas do schema projeto', true),
  (2, 'Ele consegue apagar registros com DELETE, pois recebeu ALL antes do REVOKE', false),
  (3, 'Um DROP TABLE executado por ele é negado com o Error Code: 1142', true),
  (4, 'Ele acessa o MySQL com mysql -u root -p, informando a senha lobo595', false),
  (5, 'Para voltar a apagar registros, o root executa GRANT DELETE ON projeto.* TO ele', true)
) AS v(order_index, text, is_correct)
WHERE o.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r11')
  AND o.order_index = v.order_index;

-- r12 | single_choice | autorelacionamento com LEFT JOIN e ORDER BY | b1: LEFT JOIN, b2: matriz.idHotel, b3: matriz.nome
UPDATE questions SET
  template = 'Para listar cada hotel com o nome da sua matriz, incluindo os hotéis que não têm matriz, em ordem alfabética pelo nome da matriz: SELECT filial.nome, matriz.nome FROM hotel AS filial {{b1}} hotel AS matriz ON filial.fkMatriz = {{b2}} ORDER BY {{b3}};',
  explanation = 'O LEFT JOIN mantém os hotéis sem matriz, a chave estrangeira da filial é comparada com a chave primária da matriz e a ordenação usa matriz.nome; só nome seria ambíguo, pois a tabela aparece duas vezes.'
WHERE id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r12');

UPDATE question_blank_options bo SET text = v.text, is_correct = v.is_correct
FROM question_blanks b, (VALUES
  ('b1', 1, 'JOIN', false), ('b1', 2, 'RIGHT JOIN', false), ('b1', 3, 'LEFT JOIN', true),
  ('b2', 1, 'filial.idHotel', false), ('b2', 2, 'matriz.idHotel', true), ('b2', 3, 'matriz.fkMatriz', false), ('b2', 4, 'filial.fkMatriz', false),
  ('b3', 1, 'matriz.nome', true), ('b3', 2, 'filial.nome', false), ('b3', 3, 'nome', false)
) AS v(blank_key, order_index, text, is_correct)
WHERE b.id = bo.blank_id
  AND b.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r12')
  AND b.blank_key = v.blank_key AND bo.order_index = v.order_index;

-- r13 | single_choice | REVOKE, GRANT e FLUSH PRIVILEGES em sequência | b1: REVOKE, b2: FROM, b3: GRANT, b4: FLUSH PRIVILEGES
UPDATE questions SET
  template = 'O usuário app tem ALL no schema projeto e deve ficar só com leitura. Logado como root, o administrador executa {{b1}} ALL ON projeto.* {{b2}} ''app''@''localhost''; depois {{b3}} SELECT ON projeto.* TO ''app''@''localhost''; e, por fim, {{b4}};',
  explanation = 'REVOKE ... FROM retira todas as permissões, GRANT SELECT ... TO devolve só a leitura e FLUSH PRIVILEGES aplica as mudanças.'
WHERE id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r13');

UPDATE question_blank_options bo SET text = v.text, is_correct = v.is_correct
FROM question_blanks b, (VALUES
  ('b1', 1, 'GRANT', false), ('b1', 2, 'REVOKE', true), ('b1', 3, 'DROP', false),
  ('b2', 1, 'TO', false), ('b2', 2, 'FROM', true), ('b2', 3, 'BY', false),
  ('b3', 1, 'GRANT', true), ('b3', 2, 'REVOKE', false), ('b3', 3, 'CREATE', false),
  ('b4', 1, 'COMMIT', false), ('b4', 2, 'FLUSH PRIVILEGES', true), ('b4', 3, 'SHOW DATABASES', false), ('b4', 4, 'EXIT', false)
) AS v(blank_key, order_index, text, is_correct)
WHERE b.id = bo.blank_id
  AND b.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r13')
  AND b.blank_key = v.blank_key AND bo.order_index = v.order_index;

-- r14 | drag_and_drop | ordem dos INSERTs no autorelacionamento e UPDATE da chave estrangeira |
-- s1: INSERT Accor, s2: INSERT Ibis, s3: INSERT Ibis Sul (2), s4: UPDATE fkMatriz
UPDATE questions SET
  template = 'A tabela hotel (idHotel, nome, fkMatriz) está vazia, e fkMatriz referencia idHotel. Ordene os comandos para cadastrar a matriz Accor (1), a filial Ibis (2), ligada à Accor, e a Ibis Sul (3), ligada à Ibis, sem erro de chave estrangeira, e depois fazer a Ibis Sul responder direto à Accor: 1º {{s1}}; 2º {{s2}}; 3º {{s3}}; 4º {{s4}}.',
  explanation = 'Quem é referenciado entra antes: Accor, depois Ibis (aponta para 1) e Ibis Sul (aponta para 2). Para mudar a matriz da Ibis Sul, altera-se o fkMatriz dela com UPDATE, e não o idHotel.'
WHERE id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r14');

UPDATE question_terms tm SET text = v.text
FROM (VALUES
  (1, 'INSERT INTO hotel VALUES (3, ''Ibis Sul'', 2)'),
  (2, 'UPDATE hotel SET idHotel = 1 WHERE fkMatriz = 3'),
  (3, 'INSERT INTO hotel VALUES (1, ''Accor'', NULL)'),
  (4, 'INSERT INTO hotel VALUES (3, ''Ibis Sul'', 1)'),
  (5, 'UPDATE hotel SET fkMatriz = 1 WHERE idHotel = 3'),
  (6, 'INSERT INTO hotel VALUES (2, ''Ibis'', 1)')
) AS v(order_index, text)
WHERE tm.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r14')
  AND tm.order_index = v.order_index;

UPDATE question_slots sl SET correct_term_id = tm.id
FROM (VALUES
  ('s1', 'INSERT INTO hotel VALUES (1, ''Accor'', NULL)'),
  ('s2', 'INSERT INTO hotel VALUES (2, ''Ibis'', 1)'),
  ('s3', 'INSERT INTO hotel VALUES (3, ''Ibis Sul'', 2)'),
  ('s4', 'UPDATE hotel SET fkMatriz = 1 WHERE idHotel = 3')
) AS v(slot_key, term_text)
JOIN question_terms tm ON tm.text = v.term_text
WHERE sl.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r14')
  AND tm.question_id = sl.question_id AND sl.slot_key = v.slot_key;

-- r15 | drag_and_drop | CHECK criado sobre dados que já violam a regra | s1: a linha já viola, s2: UPDATE fkDuble NULL
UPDATE questions SET
  template = 'A tabela ator (idAtor, nome, fkDuble), com fkDuble referenciando idAtor, já tem a linha (5, ''Rafa'', 5). O comando ALTER TABLE ator ADD CONSTRAINT chkDuble CHECK (idAtor <> fkDuble); falha porque {{s1}}. Para conseguir criar a regra sem apagar o ator, antes executa-se {{s2}}.',
  explanation = 'Ao criar um CHECK, o banco confere as linhas que já existem, e Rafa é dublê de si mesmo. Com fkDuble nulo a condição não é violada, e a constraint pode ser criada.'
WHERE id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r15');

UPDATE question_terms tm SET text = v.text
FROM (VALUES
  (1, 'a tabela ator ainda não tem chave primária'),
  (2, 'UPDATE ator SET fkDuble = NULL WHERE idAtor = 5'),
  (3, 'ALTER TABLE ator DROP CONSTRAINT chkDuble'),
  (4, 'a linha (5, Rafa, 5) já viola a condição')
) AS v(order_index, text)
WHERE tm.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r15')
  AND tm.order_index = v.order_index;

UPDATE question_slots sl SET correct_term_id = tm.id
FROM (VALUES
  ('s1', 'a linha (5, Rafa, 5) já viola a condição'),
  ('s2', 'UPDATE ator SET fkDuble = NULL WHERE idAtor = 5')
) AS v(slot_key, term_text)
JOIN question_terms tm ON tm.text = v.term_text
WHERE sl.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r15')
  AND tm.question_id = sl.question_id AND sl.slot_key = v.slot_key;

-- r16 | drag_and_drop | CREATE TABLE com PRIMARY KEY, DEFAULT, CHECK e autorelacionamento |
-- s1: PRIMARY KEY, s2: DEFAULT, s3: CHECK, s4: FOREIGN KEY
UPDATE questions SET
  template = 'No cadastro de atores e dublês, o idAtor é gerado automaticamente, o tipo vale ''corpo'' quando não é informado e só aceita ''corpo'' ou ''acao'', e o dublê é outro ator: CREATE TABLE ator (idAtor INT {{s1}} AUTO_INCREMENT, nome VARCHAR(45) NOT NULL, tipo VARCHAR(10) {{s2}} ''corpo'', fkDuble INT, CONSTRAINT chkTipo {{s3}} (tipo IN (''corpo'', ''acao'')), {{s4}} (fkDuble) REFERENCES ator(idAtor));',
  explanation = 'PRIMARY KEY identifica o ator, DEFAULT dá o valor padrão do tipo, CHECK limita os valores aceitos e FOREIGN KEY liga fkDuble ao idAtor da própria tabela.'
WHERE id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r16');

UPDATE question_terms tm SET text = v.text
FROM (VALUES
  (1, 'UNIQUE'), (2, 'CHECK'), (3, 'PRIMARY KEY'), (4, 'INDEX'), (5, 'FOREIGN KEY'), (6, 'DEFAULT')
) AS v(order_index, text)
WHERE tm.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r16')
  AND tm.order_index = v.order_index;

UPDATE question_slots sl SET correct_term_id = tm.id
FROM (VALUES
  ('s1', 'PRIMARY KEY'), ('s2', 'DEFAULT'), ('s3', 'CHECK'), ('s4', 'FOREIGN KEY')
) AS v(slot_key, term_text)
JOIN question_terms tm ON tm.text = v.term_text
WHERE sl.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r16')
  AND tm.question_id = sl.question_id AND sl.slot_key = v.slot_key;

-- r17 | drag_and_drop | chave estrangeira no autorelacionamento e no 1:N | s1: fkMatriz, s2: hotel, s3: fkHotel, s4: quarto
UPDATE questions SET
  template = 'Na rede de hotéis, cada filial tem no máximo uma matriz, que também é um hotel, e cada hotel tem vários quartos. A chave estrangeira da matriz, {{s1}}, fica na tabela {{s2}} e referencia idHotel; a dos quartos, {{s3}}, fica na tabela {{s4}}.',
  explanation = 'A chave estrangeira fica no lado N: fkMatriz em hotel, pois a matriz é um hotel com várias filiais (autorelacionamento), e fkHotel em quarto, pois um hotel tem vários quartos.'
WHERE id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r17');

UPDATE question_terms tm SET text = v.text
FROM (VALUES
  (1, 'quarto'), (2, 'fkQuarto'), (3, 'fkMatriz'), (4, 'matriz'), (5, 'hotel'), (6, 'fkHotel')
) AS v(order_index, text)
WHERE tm.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r17')
  AND tm.order_index = v.order_index;

UPDATE question_slots sl SET correct_term_id = tm.id
FROM (VALUES
  ('s1', 'fkMatriz'), ('s2', 'hotel'), ('s3', 'fkHotel'), ('s4', 'quarto')
) AS v(slot_key, term_text)
JOIN question_terms tm ON tm.text = v.term_text
WHERE sl.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r17')
  AND tm.question_id = sl.question_id AND sl.slot_key = v.slot_key;

-- r18 | drag_and_drop | autorelacionamento com LIKE e ORDER BY DESC | s1: JOIN, s2: ator.fkDuble, s3: duble.nome, s4: DESC
UPDATE questions SET
  template = 'Para exibir o nome de cada ator e o do seu dublê, somente dos atores cujo nome começa com A, em ordem decrescente pelo nome do dublê: SELECT ator.nome, duble.nome FROM ator AS ator {{s1}} ator AS duble ON {{s2}} = duble.idAtor WHERE ator.nome LIKE ''A%'' ORDER BY {{s3}} {{s4}};',
  explanation = 'O ator guarda a chave estrangeira do seu dublê, então a junção é ator.fkDuble = duble.idAtor. A ordenação é pelo nome do dublê, e DESC a deixa decrescente.'
WHERE id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r18');

UPDATE question_terms tm SET text = v.text
FROM (VALUES
  (1, 'ASC'), (2, 'ator.nome'), (3, 'JOIN'), (4, 'duble.fkDuble'), (5, 'DESC'), (6, 'ator.fkDuble'), (7, 'duble.nome')
) AS v(order_index, text)
WHERE tm.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r18')
  AND tm.order_index = v.order_index;

UPDATE question_slots sl SET correct_term_id = tm.id
FROM (VALUES
  ('s1', 'JOIN'), ('s2', 'ator.fkDuble'), ('s3', 'duble.nome'), ('s4', 'DESC')
) AS v(slot_key, term_text)
JOIN question_terms tm ON tm.text = v.term_text
WHERE sl.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r18')
  AND tm.question_id = sl.question_id AND sl.slot_key = v.slot_key;

-- r19 | drag_and_drop | autorelacionamento e terceira tabela na mesma consulta |
-- s1: filial.fkMatriz, s2: matriz.idHotel, s3: quarto.fkHotel, s4: filial.idHotel
UPDATE questions SET
  template = 'Para exibir cada filial, a sua matriz e os quartos da filial, com a chave estrangeira à esquerda de cada igualdade: SELECT * FROM hotel AS filial JOIN hotel AS matriz ON {{s1}} = {{s2}} JOIN quarto ON {{s3}} = {{s4}};',
  explanation = 'A filial aponta para a matriz por filial.fkMatriz = matriz.idHotel. Os quartos pedidos são os da filial, então quarto.fkHotel é comparado com filial.idHotel, e não com o idHotel da matriz.'
WHERE id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r19');

UPDATE question_terms tm SET text = v.text
FROM (VALUES
  (1, 'matriz.fkMatriz'), (2, 'quarto.fkHotel'), (3, 'filial.idHotel'), (4, 'quarto.idQuarto'),
  (5, 'filial.fkMatriz'), (6, 'matriz.idHotel'), (7, 'quarto.fkMatriz')
) AS v(order_index, text)
WHERE tm.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r19')
  AND tm.order_index = v.order_index;

UPDATE question_slots sl SET correct_term_id = tm.id
FROM (VALUES
  ('s1', 'filial.fkMatriz'), ('s2', 'matriz.idHotel'), ('s3', 'quarto.fkHotel'), ('s4', 'filial.idHotel')
) AS v(slot_key, term_text)
JOIN question_terms tm ON tm.text = v.term_text
WHERE sl.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r19')
  AND tm.question_id = sl.question_id AND sl.slot_key = v.slot_key;

-- r20 | drag_and_drop | diagnóstico do erro 1142 e ordem do GRANT | s1: mysql -u root -p, s2: GRANT ... TO, s3: FLUSH PRIVILEGES
UPDATE questions SET
  template = 'Logado como app, um estagiário recebeu Error Code: 1142. UPDATE command denied to user ''app''@''localhost'' for table ''sensor''. Ordene o que o administrador faz para liberar apenas o UPDATE no schema projeto: 1º {{s1}}; 2º {{s2}}; 3º {{s3}}.',
  explanation = 'Só o administrador concede permissões, então ele entra com mysql -u root -p, concede o UPDATE com GRANT ... TO e aplica a mudança com FLUSH PRIVILEGES.'
WHERE id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r20');

UPDATE question_terms tm SET text = v.text
FROM (VALUES
  (1, 'mysql -u app -p'),
  (2, 'GRANT UPDATE ON projeto.* FROM ''app''@''localhost'''),
  (3, 'FLUSH PRIVILEGES'),
  (4, 'mysql -u root -p'),
  (5, 'REVOKE UPDATE ON projeto.* FROM ''app''@''localhost'''),
  (6, 'GRANT UPDATE ON projeto.* TO ''app''@''localhost''')
) AS v(order_index, text)
WHERE tm.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r20')
  AND tm.order_index = v.order_index;

UPDATE question_slots sl SET correct_term_id = tm.id
FROM (VALUES
  ('s1', 'mysql -u root -p'),
  ('s2', 'GRANT UPDATE ON projeto.* TO ''app''@''localhost'''),
  ('s3', 'FLUSH PRIVILEGES')
) AS v(slot_key, term_text)
JOIN question_terms tm ON tm.text = v.term_text
WHERE sl.question_id = (SELECT question_id FROM bd_multiconceito WHERE key = 'r20')
  AND tm.question_id = sl.question_id AND sl.slot_key = v.slot_key;

-- 4. Simulados: substitui as questões de cada um pela nova seleção, na ordem abaixo
CREATE TEMP TABLE bd_multiconceito_simulados ON COMMIT DROP AS
SELECT z.id AS quiz_id, m.question_id, v.order_index
FROM (VALUES
  ('medium', 1, 'r01'), ('medium', 2, 'r04'), ('medium', 3, 'r16'), ('medium', 4, 'r15'),
  ('medium', 5, 'r10'), ('medium', 6, 'r14'), ('medium', 7, 'r09'), ('medium', 8, 'r13'),
  ('medium', 9, 'r03'), ('medium', 10, 'm02'), ('medium', 11, 'r06'), ('medium', 12, 'm01'),
  ('medium', 13, 'm03'), ('medium', 14, 'm04'), ('medium', 15, 'r17'), ('medium', 16, 'r02'),
  ('medium', 17, 'r07'), ('medium', 18, 'm05'), ('medium', 19, 'r12'), ('medium', 20, 'r05'),
  ('hard', 1, 'r01'), ('hard', 2, 'r04'), ('hard', 3, 'r16'), ('hard', 4, 'r15'),
  ('hard', 5, 'r10'), ('hard', 6, 'r14'), ('hard', 7, 'r08'), ('hard', 8, 'r09'),
  ('hard', 9, 'r13'), ('hard', 10, 'r20'), ('hard', 11, 'r11'), ('hard', 12, 'r03'),
  ('hard', 13, 'r06'), ('hard', 14, 'm01'), ('hard', 15, 'm06'), ('hard', 16, 'm03'),
  ('hard', 17, 'm07'), ('hard', 18, 'm08'), ('hard', 19, 'm04'), ('hard', 20, 'r17'),
  ('hard', 21, 'r02'), ('hard', 22, 'r05'), ('hard', 23, 'r07'), ('hard', 24, 'r18'),
  ('hard', 25, 'r19'), ('hard', 26, 'r12'), ('hard', 27, 'm09'), ('hard', 28, 'm10'),
  ('hard', 29, 'm11'), ('hard', 30, 'm12')
) AS v(difficulty, order_index, key)
JOIN bd_multiconceito m ON m.key = v.key
JOIN quizzes z ON z.kind = 'exam' AND z.difficulty = v.difficulty::difficulty_level
JOIN subjects s ON s.id = z.subject_id AND s.name = 'Banco de Dados';

DELETE FROM quiz_questions qq
WHERE qq.quiz_id IN (SELECT DISTINCT quiz_id FROM bd_multiconceito_simulados);

INSERT INTO quiz_questions (quiz_id, question_id, order_index)
SELECT quiz_id, question_id, order_index
FROM bd_multiconceito_simulados;

UPDATE quizzes z SET duration_minutes = 50
FROM subjects s
WHERE s.id = z.subject_id AND s.name = 'Banco de Dados'
  AND z.kind = 'exam' AND z.difficulty = 'medium';

-- 5. Conferência: aborta se alguma questão reescrita ficou com o enunciado antigo, com
-- quantidade errada de respostas certas ou com lacuna/slot fora do template, ou se algum
-- simulado não ficou com a quantidade esperada de questões
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM bd_multiconceito m JOIN questions q ON q.id = m.question_id
    WHERE m.shape IS NOT NULL
      AND left(COALESCE(q.prompt, q.template), length(m.statement_start)) = m.statement_start
  ) THEN
    RAISE EXCEPTION 'Há questão que não foi reescrita';
  END IF;

  IF EXISTS (
    SELECT 1 FROM bd_multiconceito m JOIN questions q ON q.id = m.question_id
    WHERE m.shape IS NOT NULL AND q.type IN ('multiple_choice', 'multiple_answer')
      AND (SELECT COUNT(*) FROM question_options o WHERE o.question_id = q.id AND o.is_correct)
        NOT BETWEEN CASE q.type WHEN 'multiple_choice' THEN 1 ELSE 2 END
            AND CASE q.type WHEN 'multiple_choice' THEN 1 ELSE 3 END
  ) THEN
    RAISE EXCEPTION 'Há questão de múltipla escolha com quantidade errada de alternativas corretas';
  END IF;

  IF EXISTS (
    SELECT 1 FROM bd_multiconceito m JOIN question_blanks b ON b.question_id = m.question_id
    WHERE m.shape IS NOT NULL
      AND (SELECT COUNT(*) FROM question_blank_options bo WHERE bo.blank_id = b.id AND bo.is_correct) <> 1
  ) THEN
    RAISE EXCEPTION 'Há lacuna sem exatamente uma opção correta';
  END IF;

  IF EXISTS (
    SELECT 1 FROM bd_multiconceito m JOIN questions q ON q.id = m.question_id
    WHERE m.shape IS NOT NULL AND q.type IN ('single_choice', 'drag_and_drop')
      AND (
        (length(q.template) - length(replace(q.template, '{{', ''))) / 2
          <> (SELECT COUNT(*) FROM question_blanks b WHERE b.question_id = q.id)
           + (SELECT COUNT(*) FROM question_slots sl WHERE sl.question_id = q.id)
        OR EXISTS (
          SELECT 1 FROM question_blanks b
          WHERE b.question_id = q.id AND position('{{' || b.blank_key || '}}' IN q.template) = 0
        )
        OR EXISTS (
          SELECT 1 FROM question_slots sl
          WHERE sl.question_id = q.id AND position('{{' || sl.slot_key || '}}' IN q.template) = 0
        )
      )
  ) THEN
    RAISE EXCEPTION 'Há template com lacuna ou slot que não corresponde às chaves cadastradas';
  END IF;

  IF EXISTS (
    SELECT 1 FROM bd_multiconceito m JOIN question_slots sl ON sl.question_id = m.question_id
    WHERE m.shape IS NOT NULL
    GROUP BY sl.question_id
    HAVING COUNT(DISTINCT sl.correct_term_id) <> COUNT(*)
  ) THEN
    RAISE EXCEPTION 'Há questão de arrastar com dois slots apontando para o mesmo termo';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM (VALUES ('medium', 20), ('hard', 30)) AS v(difficulty, expected)
    JOIN quizzes z ON z.kind = 'exam' AND z.difficulty = v.difficulty::difficulty_level
    JOIN subjects s ON s.id = z.subject_id AND s.name = 'Banco de Dados'
    WHERE (SELECT COUNT(*) FROM quiz_questions qq WHERE qq.quiz_id = z.id) <> v.expected
  ) THEN
    RAISE EXCEPTION 'Há simulado de Banco de Dados com quantidade de questões diferente da esperada';
  END IF;
END $$;

COMMIT;
