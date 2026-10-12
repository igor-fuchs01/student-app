-- Student App — imports one quiz (simulado or, with "kind": "exercise", an
-- exercise list of one topic) described in JSON straight into the
-- database. It is an operator tool, not part of the API: the app never calls it
-- and it leaves nothing behind that the Data API could reach.
--
-- How to use it: replace the JSON between the $json$ markers below with the
-- quiz to import, then run this whole file — in the Supabase Studio SQL editor
-- (http://127.0.0.1:54323 locally), or with psql:
--
--   psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" \
--     -f supabase/scripts/import-quiz.sql
--
-- The JSON format is documented in docs/07-importacao-de-simulados.md.
--
-- Every quiz belongs to one "subject"; there is no integrated simulado, so
-- "subjectScope" is no longer part of the format (an old payload with
-- "subjectScope": "single" is still accepted, "all" is refused). A question may
-- omit "subject", and any it gives must be the quiz's own.
--
-- An exercise list uses the same format with "kind": "exercise" and its
-- "topic", and no "durationMinutes". Its questions may omit "topic", and any
-- they give must be the list's own:
--
--   { "kind": "exercise", "title": "Normalização — Exercícios 2",
--     "subject": "Banco de Dados", "topic": "Normalização",
--     "difficulty": "easy", "questions": [ ... ] }
--
-- How it works:
--   * everything runs inside one transaction: the whole payload is validated
--     first and, when anything is wrong, every problem is reported at once and
--     no row is written;
--   * subjects and topics are never created here. A question naming one that
--     does not exist is an error, so a typo cannot silently create a duplicate
--     subject beside the real one;
--   * questions are always new rows; the bank is never searched for an
--     equivalent question to reuse;
--   * the validation helpers are created in pg_temp, so they vanish with the
--     session instead of becoming permanent surface in the database, and they
--     are replaced on every run, because the SQL editor reuses its connection;
--   * messages are in English, like the rest of the code: this is developer
--     tooling, not something a student ever reads.

BEGIN;

-- =============================================================================
-- The quiz to import — this is the only part meant to be edited.
--
-- $json$ quoting keeps the JSON exactly as it is: no escaping, not even for the
-- single quotes of words like "d'água".
-- =============================================================================

CREATE TEMP TABLE quiz_import_payload ON COMMIT DROP AS
SELECT $json$
{
  "title": "Arquitetura Computacional — Simulado Sprint 2",
  "subject": "Arquitetura Computacional",
  "durationMinutes": 40,
  "difficulty": "medium",
  "questions": [
    {
      "type": "multiple_choice",
      "topic": "Aquisição de Dados com API",
      "prompt": "Por que se diz que uma API é um contrato, e não apenas um intermediário?",
      "explanation": "A API publica quais pedidos aceita e como cada um deve ser escrito. Fora dessas regras de formato, o pedido não é quase certo: é erro.",
      "options": [
        {
          "text": "Porque ela cobra por cada pedido que as aplicações fazem.",
          "isCorrect": false
        },
        {
          "text": "Porque ela guarda as credenciais das duas aplicações.",
          "isCorrect": false
        },
        {
          "text": "Porque ela define regras fixas de formato para os pedidos.",
          "isCorrect": true
        },
        {
          "text": "Porque ela mostra a quem a usa como o trabalho é feito.",
          "isCorrect": false
        },
        {
          "text": "Porque ela aceita pedidos escritos em qualquer formato.",
          "isCorrect": false
        }
      ]
    },
    {
      "type": "multiple_choice",
      "topic": "Aquisição de Dados com API",
      "prompt": "Um grupo troca o sensor LM35 por um DHT11 no meio do projeto. O que precisa mudar?",
      "explanation": "Isso é desacoplamento: as pontas não se conhecem, conversam com o intermediário. Trocar o sensor muda o sketch; a API e o banco seguem iguais, desde que o formato enviado seja mantido.",
      "options": [
        {
          "text": "Só o sketch do Arduino, desde que o formato enviado seja mantido.",
          "isCorrect": true
        },
        {
          "text": "O sketch e a API, pois a API conhece o modelo do sensor usado.",
          "isCorrect": false
        },
        {
          "text": "A API e o banco, pois o tipo do dado gravado passa a ser outro.",
          "isCorrect": false
        },
        {
          "text": "Só a API, pois é ela que converte a leitura do novo sensor.",
          "isCorrect": false
        },
        {
          "text": "O sketch, a API e a página de gráficos, pois tudo é acoplado.",
          "isCorrect": false
        }
      ]
    },
    {
      "type": "multiple_answer",
      "topic": "Aquisição de Dados com API",
      "prompt": "Assinale todas as corretas sobre a linha 1;33.56 enviada pelo sketch à API.",
      "explanation": "O formato é digital;analogico: o 1 é o valor do sensor digital, não um identificador, e o 33.56 é o do analógico. O ponto e vírgula é obrigatório, e texto ou unidade grudados quebram a leitura.",
      "options": [
        {
          "text": "O 1 é o identificador do sensor que fez a leitura.",
          "isCorrect": false
        },
        {
          "text": "O 33.56 é o valor lido pelo sensor analógico.",
          "isCorrect": true
        },
        {
          "text": "A linha deveria trazer a unidade, como 33.56 C.",
          "isCorrect": false
        },
        {
          "text": "O 1 é o valor do sensor digital, enviado primeiro.",
          "isCorrect": true
        },
        {
          "text": "O ponto e vírgula é opcional com um só sensor.",
          "isCorrect": false
        }
      ]
    },
    {
      "type": "multiple_choice",
      "topic": "Aquisição de Dados com API",
      "prompt": "O sketch de um grupo usa Serial.begin(115200), e a API está com SERIAL_BAUD_RATE = 9600. O que acontece?",
      "explanation": "O baud rate precisa ser exatamente o mesmo dos dois lados; não há negociação automática. Com valores diferentes, o que chega é lixo, como no Monitor Serial mal configurado.",
      "options": [
        {
          "text": "A API negocia a velocidade com a placa e lê normalmente.",
          "isCorrect": false
        },
        {
          "text": "A API não encontra o Arduino em nenhuma porta serial.",
          "isCorrect": false
        },
        {
          "text": "A API recebe os dados, mas só a metade das leituras.",
          "isCorrect": false
        },
        {
          "text": "A API recusa a conexão e avisa que a porta está em uso.",
          "isCorrect": false
        },
        {
          "text": "A API lê lixo, pois os dois lados falam em ritmos distintos.",
          "isCorrect": true
        }
      ]
    },
    {
      "type": "single_choice",
      "topic": "Aquisição de Dados com API",
      "template": "No package.json da dat-acqu-ino, a biblioteca {{b1}} lê a porta USB, a {{b2}} serve os dados pela web e a {{b3}} acessa o banco. Já a Chart.js não é instalada: o arquivo {{b4}} a carrega direto da internet.",
      "explanation": "O package.json declara três bibliotecas: serialport (porta USB), express (endpoints pela web) e mysql2 (banco). A Chart.js é carregada pelo index.html direto da internet.",
      "blanks": [
        {
          "key": "b1",
          "options": [
            {
              "text": "express",
              "isCorrect": false
            },
            {
              "text": "mysql2",
              "isCorrect": false
            },
            {
              "text": "serialport",
              "isCorrect": true
            }
          ]
        },
        {
          "key": "b2",
          "options": [
            {
              "text": "express",
              "isCorrect": true
            },
            {
              "text": "serialport",
              "isCorrect": false
            },
            {
              "text": "mysql2",
              "isCorrect": false
            }
          ]
        },
        {
          "key": "b3",
          "options": [
            {
              "text": "serialport",
              "isCorrect": false
            },
            {
              "text": "mysql2",
              "isCorrect": true
            },
            {
              "text": "express",
              "isCorrect": false
            }
          ]
        },
        {
          "key": "b4",
          "options": [
            {
              "text": "main.js",
              "isCorrect": false
            },
            {
              "text": "index.html",
              "isCorrect": true
            },
            {
              "text": "package.json",
              "isCorrect": false
            }
          ]
        }
      ]
    },
    {
      "type": "multiple_choice",
      "topic": "Aquisição de Dados com API",
      "prompt": "Como testar a API sem abrir a página de gráficos?",
      "explanation": "O app.get atende ao mesmo tipo de pedido que o navegador faz ao abrir um site. Basta digitar o endereço do endpoint na barra de endereços para ver a lista em JSON.",
      "options": [
        {
          "text": "Abrindo o Monitor Serial da IDE com a API rodando.",
          "isCorrect": false
        },
        {
          "text": "Digitando o endereço do endpoint direto no navegador.",
          "isCorrect": true
        },
        {
          "text": "Rodando npm install de novo na pasta do projeto.",
          "isCorrect": false
        },
        {
          "text": "Executando o comando netstat -ano no terminal.",
          "isCorrect": false
        },
        {
          "text": "Trocando a porta 3300 por 3306 no arquivo main.js.",
          "isCorrect": false
        }
      ]
    },
    {
      "type": "drag_and_drop",
      "topic": "Aquisição de Dados com API",
      "template": "O ReadlineParser só entrega a linha ao encontrar a quebra de linha, formada pelos caracteres de controle de códigos ASCII {{s1}} e {{s2}}, nessa ordem. Depois, o {{s3}} corta o texto no ponto e vírgula, e o {{s4}} converte o valor do sensor analógico.",
      "explanation": "A quebra de linha que o Serial.println coloca no fim é formada pelos códigos ASCII 13 e 10. Com a linha completa, o split a corta no ponto e vírgula, e o parseFloat converte a parte analógica em número com decimais.",
      "terms": [
        "parseFloat",
        "49",
        "13",
        "parseInt",
        "split",
        "10",
        "fetch"
      ],
      "slots": [
        {
          "key": "s1",
          "correctTerm": "13"
        },
        {
          "key": "s2",
          "correctTerm": "10"
        },
        {
          "key": "s3",
          "correctTerm": "split"
        },
        {
          "key": "s4",
          "correctTerm": "parseFloat"
        }
      ]
    },
    {
      "type": "multiple_choice",
      "topic": "Aquisição de Dados com API",
      "prompt": "Um aluno clonou o projeto em uma pasta sincronizada com o OneDrive, e o npm start falha dizendo que não encontra o módulo serialport. Qual é a correção?",
      "explanation": "A sincronização com a nuvem trava, duplica e corrompe os arquivos da node_modules. A correção é apagar a pasta, mover o projeto para um diretório local e rodar npm install de novo.",
      "options": [
        {
          "text": "Rodar npm audit fix para reparar as versões das bibliotecas.",
          "isCorrect": false
        },
        {
          "text": "Fechar o Monitor Serial, que impede a leitura dos módulos.",
          "isCorrect": false
        },
        {
          "text": "Reinstalar o Node.js, escolhendo a versão Current do site.",
          "isCorrect": false
        },
        {
          "text": "Mover o projeto para uma pasta local e refazer o npm install.",
          "isCorrect": true
        },
        {
          "text": "Abrir a pasta node_modules e apagar os arquivos duplicados.",
          "isCorrect": false
        }
      ]
    },
    {
      "type": "multiple_answer",
      "topic": "Aquisição de Dados com API",
      "prompt": "Assinale todas as corretas sobre a API rodando com a inserção no banco desligada.",
      "explanation": "Com a inserção desligada, tudo vive em memória: parou a API, perdeu o histórico. O Ctrl+C encerra o processo e devolve a porta serial; fechar a janela não mata necessariamente o processo.",
      "options": [
        {
          "text": "As leituras ficam em arrays que vivem enquanto a API está rodando.",
          "isCorrect": true
        },
        {
          "text": "As credenciais de exemplo impedem a API de subir sem um banco.",
          "isCorrect": false
        },
        {
          "text": "Parar a API com Ctrl+C faz todo o histórico de leituras sumir.",
          "isCorrect": true
        },
        {
          "text": "O Ctrl+C encerra o processo e libera a porta serial da placa.",
          "isCorrect": true
        },
        {
          "text": "Fechar a janela do terminal sempre encerra o processo da API.",
          "isCorrect": false
        }
      ]
    },
    {
      "type": "essay_blanks",
      "topic": "Aquisição de Dados com API",
      "prompt": "Complete a frase sobre programas em execução.",
      "template": "Todo programa em execução é um {{b1}}, e o sistema operacional dá a cada um deles um número único, o {{b2}}.",
      "blanks": [
        {
          "key": "b1",
          "referenceAnswer": "processo"
        },
        {
          "key": "b2",
          "referenceAnswer": "PID"
        }
      ]
    },
    {
      "type": "multiple_choice",
      "topic": "Aquisição de Dados: Gravando no Banco",
      "prompt": "Por que o gráfico recomeça vazio depois que a API é reiniciada?",
      "explanation": "O gráfico é desenhado a partir de arrays criados quando a API inicia. Array é estrutura de memória, e memória é volátil: o processo morre e os arrays somem junto.",
      "options": [
        {
          "text": "Porque ele usa arrays em memória, que morrem junto com o processo.",
          "isCorrect": true
        },
        {
          "text": "Porque o navegador limpa o cache da página a cada novo npm start.",
          "isCorrect": false
        },
        {
          "text": "Porque o Arduino reinicia a contagem das leituras a cada conexão.",
          "isCorrect": false
        },
        {
          "text": "Porque o banco apaga a tabela medida sempre que a API é parada.",
          "isCorrect": false
        },
        {
          "text": "Porque o pool de conexões descarta as leituras ao ser recriado.",
          "isCorrect": false
        }
      ]
    },
    {
      "type": "multiple_choice",
      "topic": "Aquisição de Dados: Gravando no Banco",
      "prompt": "Uma equipe sugere gravar as leituras em um arquivo de texto em vez de usar um banco de dados. Qual avaliação está correta?",
      "explanation": "Um arquivo de texto também persiste, mas para saber a média de ontem seria preciso ler tudo e calcular na mão. O banco guarda de um jeito que permite perguntar com uma consulta.",
      "options": [
        {
          "text": "Não resolve, pois o arquivo também é apagado no fim do processo.",
          "isCorrect": false
        },
        {
          "text": "Resolve tudo, pois o arquivo responde a perguntas com uma consulta.",
          "isCorrect": false
        },
        {
          "text": "Resolve a perda, mas responder a perguntas exigiria varrer o arquivo.",
          "isCorrect": true
        },
        {
          "text": "Resolve tudo, pois o arquivo organiza gravações feitas em paralelo.",
          "isCorrect": false
        },
        {
          "text": "Não resolve, pois a API não consegue gravar texto fora da memória.",
          "isCorrect": false
        }
      ]
    },
    {
      "type": "multiple_choice",
      "topic": "Aquisição de Dados: Gravando no Banco",
      "prompt": "Por que a coluna momento é tão importante na tabela medida?",
      "explanation": "A coluna momento não aparece no INSERT: o banco a preenche com a data e a hora da gravação. Sem ela, haveria uma pilha de números sem saber quando cada um foi medido.",
      "options": [
        {
          "text": "Porque ela identifica cada leitura com um número sequencial.",
          "isCorrect": false
        },
        {
          "text": "Porque ela guarda o valor do sensor com duas casas decimais.",
          "isCorrect": false
        },
        {
          "text": "Porque ela é enviada pela API junto com cada valor medido.",
          "isCorrect": false
        },
        {
          "text": "Porque ela impede que duas leituras iguais sejam gravadas.",
          "isCorrect": false
        },
        {
          "text": "Porque ela registra sozinha a data e a hora de cada leitura.",
          "isCorrect": true
        }
      ]
    },
    {
      "type": "multiple_choice",
      "topic": "Aquisição de Dados: Gravando no Banco",
      "prompt": "Qual é a faixa de valores que cabe em uma coluna do tipo DECIMAL(6,2)?",
      "explanation": "DECIMAL(6,2) significa seis dígitos no total, sendo dois depois da vírgula: cabe de -9999,99 a 9999,99.",
      "options": [
        {
          "text": "De -999999,99 a 999999,99.",
          "isCorrect": false
        },
        {
          "text": "De -9999,99 a 9999,99.",
          "isCorrect": true
        },
        {
          "text": "De -99,9999 a 99,9999.",
          "isCorrect": false
        },
        {
          "text": "De -999,999 a 999,999.",
          "isCorrect": false
        },
        {
          "text": "De -99999,9 a 99999,9.",
          "isCorrect": false
        }
      ]
    },
    {
      "type": "multiple_choice",
      "topic": "Aquisição de Dados: Gravando no Banco",
      "prompt": "Um grupo mudou HABILITAR_OPERACAO_INSERIR para true antes de preencher as credenciais do banco. O que o terminal mostra?",
      "explanation": "Com a gravação ligada, a credencial errada deixa de ser inofensiva e vira erro a cada leitura que chega. Por isso a ordem é tabela, credenciais e, por último, a chave.",
      "options": [
        {
          "text": "Nada, pois a API não sobe com as credenciais de exemplo.",
          "isCorrect": false
        },
        {
          "text": "Só o dado cru, pois o INSERT é pulado em silêncio.",
          "isCorrect": false
        },
        {
          "text": "Duas linhas por leitura, pois o pool ignora a senha.",
          "isCorrect": false
        },
        {
          "text": "Um erro a cada leitura, pois a conexão com o banco falha.",
          "isCorrect": true
        },
        {
          "text": "Um erro só ao iniciar, e depois a gravação se normaliza.",
          "isCorrect": false
        }
      ]
    },
    {
      "type": "multiple_answer",
      "topic": "Aquisição de Dados: Gravando no Banco",
      "prompt": "Assinale todas as corretas sobre o trecho do INSERT no main.js.",
      "explanation": "O if da constante decide se o bloco roda. O comando leva pontos de interrogação, e os valores, já convertidos em número, seguem em uma lista separada. O await espera a confirmação, e a API a imprime no terminal.",
      "options": [
        {
          "text": "Com a constante em false, o bloco inteiro é pulado.",
          "isCorrect": true
        },
        {
          "text": "Os valores seguem em uma lista separada do comando.",
          "isCorrect": true
        },
        {
          "text": "O valor gravado é o texto que chegou pela serial.",
          "isCorrect": false
        },
        {
          "text": "Depois de gravar, a API imprime uma confirmação.",
          "isCorrect": true
        },
        {
          "text": "Sem o await, a API saberia antes se a gravação falhou.",
          "isCorrect": false
        }
      ]
    },
    {
      "type": "single_choice",
      "topic": "Aquisição de Dados: Gravando no Banco",
      "template": "No script da tabela medida, a coluna id é {{b1}} e numerada com {{b2}}; a coluna sensor_digital é do tipo {{b3}}; e a coluna momento tem como valor padrão {{b4}}.",
      "explanation": "O script cria id INT PRIMARY KEY AUTO_INCREMENT, sensor_analogico DECIMAL(6,2), sensor_digital INT e momento DATETIME DEFAULT CURRENT_TIMESTAMP.",
      "blanks": [
        {
          "key": "b1",
          "options": [
            {
              "text": "FOREIGN KEY",
              "isCorrect": false
            },
            {
              "text": "PRIMARY KEY",
              "isCorrect": true
            },
            {
              "text": "UNIQUE",
              "isCorrect": false
            }
          ]
        },
        {
          "key": "b2",
          "options": [
            {
              "text": "AUTO_INCREMENT",
              "isCorrect": true
            },
            {
              "text": "DEFAULT",
              "isCorrect": false
            },
            {
              "text": "DECIMAL",
              "isCorrect": false
            }
          ]
        },
        {
          "key": "b3",
          "options": [
            {
              "text": "DECIMAL(6,2)",
              "isCorrect": false
            },
            {
              "text": "DATETIME",
              "isCorrect": false
            },
            {
              "text": "INT",
              "isCorrect": true
            }
          ]
        },
        {
          "key": "b4",
          "options": [
            {
              "text": "AUTO_INCREMENT",
              "isCorrect": false
            },
            {
              "text": "CURRENT_TIMESTAMP",
              "isCorrect": true
            },
            {
              "text": "NULL",
              "isCorrect": false
            }
          ]
        }
      ]
    },
    {
      "type": "drag_and_drop",
      "topic": "Aquisição de Dados: Gravando no Banco",
      "template": "Nos dados de acesso do pool, {{s1}} é onde o banco está, {{s2}} é quem está acessando, {{s3}} é a senha, {{s4}} é qual banco usar dentro do servidor e {{s5}} é a porta do MySQL.",
      "explanation": "São cinco dados de acesso: host (onde o banco está), user (quem acessa), password (a senha), database (qual banco, dentro do servidor) e port (a porta do MySQL, 3306 por padrão).",
      "terms": [
        "database",
        "path",
        "host",
        "port",
        "baudRate",
        "user",
        "password"
      ],
      "slots": [
        {
          "key": "s1",
          "correctTerm": "host"
        },
        {
          "key": "s2",
          "correctTerm": "user"
        },
        {
          "key": "s3",
          "correctTerm": "password"
        },
        {
          "key": "s4",
          "correctTerm": "database"
        },
        {
          "key": "s5",
          "correctTerm": "port"
        }
      ]
    },
    {
      "type": "multiple_answer",
      "topic": "Aquisição de Dados: Gravando no Banco",
      "prompt": "Assinale todas as corretas sobre a consulta preparada usada no INSERT.",
      "explanation": "Na consulta preparada, o banco recebe primeiro a estrutura do comando e depois os valores, que são sempre tratados como valores. É a proteção padrão contra injeção de SQL.",
      "options": [
        {
          "text": "Ela junta o comando e os valores em uma única string.",
          "isCorrect": false
        },
        {
          "text": "Ela envia a estrutura do comando e depois os valores.",
          "isCorrect": true
        },
        {
          "text": "Ela faz o banco adivinhar onde o comando termina.",
          "isCorrect": false
        },
        {
          "text": "Ela dispensa o uso de usuário e senha no banco.",
          "isCorrect": false
        },
        {
          "text": "Ela trata os valores sempre como valores, não comando.",
          "isCorrect": true
        }
      ]
    },
    {
      "type": "essay_blanks",
      "topic": "Aquisição de Dados: Gravando no Banco",
      "prompt": "Complete a frase sobre memória e armazenamento.",
      "template": "A memória é {{b1}}: o array morre com o processo. Já a {{b2}} é a capacidade de um dado sobreviver ao fim do programa que o criou.",
      "blanks": [
        {
          "key": "b1",
          "referenceAnswer": "volátil"
        },
        {
          "key": "b2",
          "referenceAnswer": "persistência"
        }
      ]
    }
  ]
}
$json$::jsonb AS doc;

-- =============================================================================
-- Validation helpers
-- =============================================================================

-- Problems are collected instead of raised one at a time, so a single run
-- reports everything that is wrong with the payload.
CREATE OR REPLACE FUNCTION pg_temp.text_errors(p_object jsonb, p_key text, p_where text)
RETURNS text[]
LANGUAGE sql
IMMUTABLE
AS $fn$
  SELECT CASE
    WHEN jsonb_typeof(p_object -> p_key) = 'string' AND btrim(p_object ->> p_key) <> ''
      THEN '{}'::text[]
    ELSE ARRAY[format('%s: "%s" must be a non-empty string', p_where, p_key)]
  END
$fn$;

-- p_max_correct NULL means "no upper bound" (multiple_answer).
CREATE OR REPLACE FUNCTION pg_temp.option_errors(p_options jsonb, p_where text, p_min_correct integer, p_max_correct integer)
RETURNS text[]
LANGUAGE sql
IMMUTABLE
AS $fn$
  SELECT CASE
    WHEN jsonb_typeof(p_options) IS DISTINCT FROM 'array' OR jsonb_array_length(p_options) < 2
      THEN ARRAY[format('%s: "options" must be an array with at least 2 options', p_where)]
    ELSE COALESCE((
      SELECT array_agg(message)
      FROM (
        SELECT format('%s: option %s needs a non-empty "text"', p_where, o.ord) AS message
        FROM jsonb_array_elements(p_options) WITH ORDINALITY AS o(value, ord)
        WHERE jsonb_typeof(o.value -> 'text') IS DISTINCT FROM 'string'
           OR btrim(o.value ->> 'text') = ''
        UNION ALL
        SELECT format('%s: option %s needs "isCorrect" set to true or false', p_where, o.ord)
        FROM jsonb_array_elements(p_options) WITH ORDINALITY AS o(value, ord)
        WHERE jsonb_typeof(o.value -> 'isCorrect') IS DISTINCT FROM 'boolean'
        UNION ALL
        SELECT format(
          '%s: expected %s correct option(s), found %s',
          p_where,
          CASE
            WHEN p_max_correct IS NULL THEN format('at least %s', p_min_correct)
            WHEN p_min_correct = p_max_correct THEN p_min_correct::text
            ELSE format('%s to %s', p_min_correct, p_max_correct)
          END,
          counted.correct_count
        )
        FROM (
          SELECT count(*) FILTER (WHERE o.value -> 'isCorrect' = 'true'::jsonb) AS correct_count
          FROM jsonb_array_elements(p_options) AS o(value)
        ) AS counted
        WHERE counted.correct_count < p_min_correct
           OR (p_max_correct IS NOT NULL AND counted.correct_count > p_max_correct)
      ) AS found
    ), '{}')
  END
$fn$;

-- Blanks and slots are both arrays of objects identified by a unique "key",
-- which becomes question_blanks.blank_key / question_slots.slot_key.
CREATE OR REPLACE FUNCTION pg_temp.entry_errors(p_entries jsonb, p_where text, p_label text)
RETURNS text[]
LANGUAGE sql
IMMUTABLE
AS $fn$
  SELECT CASE
    WHEN jsonb_typeof(p_entries) IS DISTINCT FROM 'array' OR jsonb_array_length(p_entries) = 0
      THEN ARRAY[format('%s: "%s" must be a non-empty array', p_where, p_label)]
    ELSE COALESCE((
      SELECT array_agg(message)
      FROM (
        SELECT format('%s: %s %s needs a non-empty "key"', p_where, p_label, e.ord) AS message
        FROM jsonb_array_elements(p_entries) WITH ORDINALITY AS e(value, ord)
        WHERE jsonb_typeof(e.value -> 'key') IS DISTINCT FROM 'string'
           OR btrim(e.value ->> 'key') = ''
        UNION ALL
        SELECT format('%s: "%s" repeats the key %L', p_where, p_label, e.value ->> 'key')
        FROM jsonb_array_elements(p_entries) AS e(value)
        WHERE jsonb_typeof(e.value -> 'key') = 'string'
        GROUP BY e.value ->> 'key'
        HAVING count(*) > 1
      ) AS found
    ), '{}')
  END
$fn$;

-- The {{key}} placeholders of a template and the keys the question declares must
-- match one to one, or the student would see a blank nothing answers.
CREATE OR REPLACE FUNCTION pg_temp.placeholder_errors(p_template text, p_keys text[], p_where text, p_label text)
RETURNS text[]
LANGUAGE sql
IMMUTABLE
AS $fn$
  WITH declared AS (
    SELECT unnest(p_keys) AS key
  ),
  used AS (
    SELECT DISTINCT m[1] AS key
    FROM regexp_matches(COALESCE(p_template, ''), '\{\{([^{}]+)\}\}', 'g') AS m
  )
  SELECT COALESCE((
    SELECT array_agg(message)
    FROM (
      SELECT format('%s: the template has no {{%s}} placeholder for this %s', p_where, d.key, p_label) AS message
      FROM declared d
      WHERE NOT EXISTS (SELECT 1 FROM used u WHERE u.key = d.key)
      UNION ALL
      SELECT format('%s: the template has a {{%s}} placeholder with no matching %s', p_where, u.key, p_label)
      FROM used u
      WHERE NOT EXISTS (SELECT 1 FROM declared d WHERE d.key = u.key)
    ) AS found
  ), '{}')
$fn$;

-- =============================================================================
-- Validation and insertion
-- =============================================================================

DO $do$
DECLARE
  payload        jsonb;
  problems       text[] := '{}';
  entry_problems text[];
  question       jsonb;
  entry          jsonb;
  idx            bigint;
  entry_idx      bigint;
  quiz_title     text;
  quiz_subject   text;
  quiz_kind      text;
  quiz_topic     text;
  subject_name   text;
  topic_name     text;
  q_type         text;
  q_where        text;
  entry_keys     text[];
  term_texts     text[];
  v_subject_id   integer;
  v_topic_id     integer;
  v_quiz_topic_id integer;
  v_quiz_id      integer;
  v_question_id  integer;
  v_blank_id     integer;
BEGIN
  SELECT doc INTO payload FROM quiz_import_payload;

  IF jsonb_typeof(payload) IS DISTINCT FROM 'object' THEN
    RAISE EXCEPTION 'the payload must be a JSON object describing one quiz';
  END IF;

  -- ===========================================================================
  -- 1. Validation — the quiz
  -- ===========================================================================

  problems := problems || pg_temp.text_errors(payload, 'title', 'quiz');
  quiz_title := btrim(COALESCE(payload ->> 'title', ''));
  quiz_subject := payload ->> 'subject';
  quiz_kind := COALESCE(payload ->> 'kind', 'exam');
  quiz_topic := payload ->> 'topic';

  IF quiz_kind NOT IN ('exam', 'exercise') THEN
    problems := problems || 'quiz: "kind" must be "exam" or "exercise"';
  END IF;

  IF quiz_title <> '' AND EXISTS (SELECT 1 FROM quizzes WHERE title = quiz_title) THEN
    problems := problems || format('quiz: a quiz titled %L already exists', quiz_title);
  END IF;

  IF payload ? 'subjectScope' AND payload ->> 'subjectScope' IS DISTINCT FROM 'single' THEN
    problems := problems || 'quiz: integrated quizzes no longer exist; remove "subjectScope" and give the quiz a "subject"';
  END IF;

  IF quiz_subject IS NULL OR btrim(quiz_subject) = '' THEN
    problems := problems || 'quiz: "subject" must be a non-empty string';
  ELSE
    SELECT id INTO v_subject_id FROM subjects WHERE name = quiz_subject;
    IF NOT FOUND THEN
      problems := problems || format('quiz: subject %L was not found', quiz_subject);
    END IF;
  END IF;

  IF payload ->> 'difficulty' IS NULL
     OR payload ->> 'difficulty' NOT IN ('easy', 'medium', 'hard') THEN
    problems := problems || 'quiz: "difficulty" must be "easy", "medium" or "hard"';
  END IF;

  -- An exercise list belongs to one topic of one subject and has no time limit.
  IF quiz_kind = 'exercise' THEN
    IF quiz_topic IS NULL OR btrim(quiz_topic) = '' THEN
      problems := problems || 'quiz: "topic" is required when "kind" is "exercise"';
    ELSIF v_subject_id IS NOT NULL THEN
      SELECT id INTO v_quiz_topic_id FROM topics WHERE subject_id = v_subject_id AND name = quiz_topic;
      IF NOT FOUND THEN
        problems := problems || format('quiz: topic %L of subject %L was not found', quiz_topic, quiz_subject);
      END IF;
    END IF;

    IF payload ? 'durationMinutes' THEN
      problems := problems || 'quiz: "durationMinutes" must be omitted when "kind" is "exercise"';
    END IF;
  ELSE
    IF quiz_topic IS NOT NULL THEN
      problems := problems || 'quiz: "topic" must be omitted unless "kind" is "exercise"';
    END IF;

    IF jsonb_typeof(payload -> 'durationMinutes') IS DISTINCT FROM 'number' THEN
      problems := problems || 'quiz: "durationMinutes" must be a positive whole number';
    ELSIF (payload ->> 'durationMinutes')::numeric <= 0
       OR (payload ->> 'durationMinutes')::numeric % 1 <> 0 THEN
      problems := problems || 'quiz: "durationMinutes" must be a positive whole number';
    END IF;
  END IF;

  IF jsonb_typeof(payload -> 'questions') IS DISTINCT FROM 'array' THEN
    problems := problems || 'quiz: "questions" must be an array';
  ELSIF jsonb_array_length(payload -> 'questions') = 0 THEN
    problems := problems || 'quiz: "questions" must have at least one question';
  END IF;

  -- ===========================================================================
  -- 2. Validation — the questions
  -- ===========================================================================

  FOR idx, question IN
    SELECT q.ord, q.value
    FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(payload -> 'questions') = 'array'
           THEN payload -> 'questions'
           ELSE '[]'::jsonb END
    ) WITH ORDINALITY AS q(value, ord)
  LOOP
    q_where := format('question %s', idx);
    q_type := question ->> 'type';
    -- A question may omit its subject: it is the quiz's subject.
    subject_name := COALESCE(question ->> 'subject', quiz_subject);
    -- In an exercise list a question may omit its topic: it is the list's topic.
    topic_name := COALESCE(question ->> 'topic', CASE WHEN quiz_kind = 'exercise' THEN quiz_topic END);

    IF subject_name IS DISTINCT FROM quiz_subject THEN
      problems := problems || format('%s: every question must be of the quiz''s subject', q_where);
    END IF;

    IF quiz_kind = 'exercise' AND topic_name IS DISTINCT FROM quiz_topic THEN
      problems := problems || format('%s: every question of an exercise list must be of its topic', q_where);
    END IF;

    IF q_type IS NULL
       OR q_type NOT IN ('multiple_choice', 'multiple_answer', 'single_choice',
                         'drag_and_drop', 'essay', 'essay_blanks') THEN
      problems := problems || format(
        '%s: "type" must be one of multiple_choice, multiple_answer, single_choice, drag_and_drop, essay, essay_blanks',
        q_where
      );
      CONTINUE;
    END IF;

    IF topic_name IS NULL OR btrim(topic_name) = '' THEN
      problems := problems || format('%s: "topic" must be a non-empty string', q_where);
    ELSIF subject_name IS NULL OR btrim(subject_name) = '' THEN
      -- The missing subject is already reported for the quiz itself.
      NULL;
    ELSE
      PERFORM 1
      FROM topics t
      JOIN subjects s ON s.id = t.subject_id
      WHERE s.name = subject_name AND t.name = topic_name;

      IF NOT FOUND THEN
        problems := problems || format('%s: topic %L of subject %L was not found', q_where, topic_name, subject_name);
      END IF;
    END IF;

    CASE q_type
      WHEN 'multiple_choice' THEN
        problems := problems
          || pg_temp.text_errors(question, 'prompt', q_where)
          || pg_temp.text_errors(question, 'explanation', q_where)
          || pg_temp.option_errors(question -> 'options', q_where, 1, 1);

      WHEN 'multiple_answer' THEN
        problems := problems
          || pg_temp.text_errors(question, 'prompt', q_where)
          || pg_temp.text_errors(question, 'explanation', q_where)
          || pg_temp.option_errors(question -> 'options', q_where, 1, NULL);

      WHEN 'single_choice' THEN
        entry_problems := pg_temp.entry_errors(question -> 'blanks', q_where, 'blanks');
        problems := problems
          || pg_temp.text_errors(question, 'template', q_where)
          || pg_temp.text_errors(question, 'explanation', q_where)
          || entry_problems;

        IF cardinality(entry_problems) = 0 THEN
          SELECT array_agg(b.value ->> 'key' ORDER BY b.ord) INTO entry_keys
          FROM jsonb_array_elements(question -> 'blanks') WITH ORDINALITY AS b(value, ord);

          problems := problems
            || pg_temp.placeholder_errors(question ->> 'template', entry_keys, q_where, 'blank');

          FOR entry IN SELECT b.value FROM jsonb_array_elements(question -> 'blanks') AS b(value)
          LOOP
            problems := problems || pg_temp.option_errors(
              entry -> 'options',
              format('%s, blank %L', q_where, entry ->> 'key'),
              1, 1
            );
          END LOOP;
        END IF;

      WHEN 'drag_and_drop' THEN
        entry_problems := pg_temp.entry_errors(question -> 'slots', q_where, 'slots');
        problems := problems
          || pg_temp.text_errors(question, 'template', q_where)
          || pg_temp.text_errors(question, 'explanation', q_where)
          || entry_problems;

        term_texts := '{}';

        IF jsonb_typeof(question -> 'terms') IS DISTINCT FROM 'array'
           OR jsonb_array_length(question -> 'terms') < 2 THEN
          problems := problems || format('%s: "terms" must be an array with at least 2 terms', q_where);
        ELSIF EXISTS (
          SELECT 1
          FROM jsonb_array_elements(question -> 'terms') AS t(value)
          WHERE jsonb_typeof(t.value) IS DISTINCT FROM 'string' OR btrim(t.value #>> '{}') = ''
        ) THEN
          problems := problems || format('%s: every term must be a non-empty string', q_where);
        ELSE
          SELECT array_agg(t.value #>> '{}' ORDER BY t.ord) INTO term_texts
          FROM jsonb_array_elements(question -> 'terms') WITH ORDINALITY AS t(value, ord);

          -- The slots point at a term by its text, so two identical terms would
          -- be ambiguous.
          IF cardinality(term_texts) <> (SELECT count(DISTINCT x) FROM unnest(term_texts) AS x) THEN
            problems := problems || format('%s: "terms" repeats a term; each term must be unique', q_where);
          END IF;
        END IF;

        IF cardinality(entry_problems) = 0 THEN
          SELECT array_agg(s.value ->> 'key' ORDER BY s.ord) INTO entry_keys
          FROM jsonb_array_elements(question -> 'slots') WITH ORDINALITY AS s(value, ord);

          problems := problems
            || pg_temp.placeholder_errors(question ->> 'template', entry_keys, q_where, 'slot');

          IF cardinality(term_texts) > 0 THEN
            FOR entry IN SELECT s.value FROM jsonb_array_elements(question -> 'slots') AS s(value)
            LOOP
              IF jsonb_typeof(entry -> 'correctTerm') IS DISTINCT FROM 'string'
                 OR NOT ((entry ->> 'correctTerm') = ANY (term_texts)) THEN
                problems := problems || format('%s: slot %L needs a "correctTerm" listed in "terms"', q_where, entry ->> 'key');
              END IF;
            END LOOP;
          END IF;
        END IF;

      WHEN 'essay' THEN
        problems := problems
          || pg_temp.text_errors(question, 'prompt', q_where)
          || pg_temp.text_errors(question, 'referenceAnswer', q_where);

        IF jsonb_typeof(question -> 'maxLength') IS DISTINCT FROM 'number' THEN
          problems := problems || format('%s: "maxLength" must be a positive whole number', q_where);
        ELSIF (question ->> 'maxLength')::numeric <= 0
           OR (question ->> 'maxLength')::numeric % 1 <> 0 THEN
          problems := problems || format('%s: "maxLength" must be a positive whole number', q_where);
        END IF;

      WHEN 'essay_blanks' THEN
        entry_problems := pg_temp.entry_errors(question -> 'blanks', q_where, 'blanks');
        problems := problems
          || pg_temp.text_errors(question, 'prompt', q_where)
          || pg_temp.text_errors(question, 'template', q_where)
          || entry_problems;

        IF cardinality(entry_problems) = 0 THEN
          SELECT array_agg(b.value ->> 'key' ORDER BY b.ord) INTO entry_keys
          FROM jsonb_array_elements(question -> 'blanks') WITH ORDINALITY AS b(value, ord);

          problems := problems
            || pg_temp.placeholder_errors(question ->> 'template', entry_keys, q_where, 'blank');

          FOR entry IN SELECT b.value FROM jsonb_array_elements(question -> 'blanks') AS b(value)
          LOOP
            problems := problems || pg_temp.text_errors(
              entry, 'referenceAnswer', format('%s, blank %L', q_where, entry ->> 'key')
            );
          END LOOP;
        END IF;
    END CASE;
  END LOOP;

  IF cardinality(problems) > 0 THEN
    RAISE EXCEPTION E'the quiz JSON is invalid:\n  %', array_to_string(problems, E'\n  ');
  END IF;

  -- ===========================================================================
  -- 3. Insert
  -- ===========================================================================

  INSERT INTO quizzes (title, kind, subject_id, topic_id, duration_minutes, difficulty)
  VALUES (
    quiz_title,
    quiz_kind::quiz_kind,
    v_subject_id,
    v_quiz_topic_id,
    CASE WHEN quiz_kind = 'exam' THEN (payload ->> 'durationMinutes')::integer END,
    (payload ->> 'difficulty')::difficulty_level
  )
  RETURNING id INTO v_quiz_id;

  FOR idx, question IN
    SELECT q.ord, q.value
    FROM jsonb_array_elements(payload -> 'questions') WITH ORDINALITY AS q(value, ord)
  LOOP
    q_type := question ->> 'type';
    subject_name := COALESCE(question ->> 'subject', quiz_subject);
    topic_name := COALESCE(question ->> 'topic', CASE WHEN quiz_kind = 'exercise' THEN quiz_topic END);

    SELECT t.id INTO STRICT v_topic_id
    FROM topics t
    JOIN subjects s ON s.id = t.subject_id
    WHERE s.name = subject_name AND t.name = topic_name;

    -- Only the columns the type uses are filled; the CHECK constraints in
    -- the questions migration reject anything else.
    INSERT INTO questions (topic_id, type, prompt, template, explanation, max_length, reference_answer)
    VALUES (
      v_topic_id,
      q_type::question_type,
      CASE WHEN q_type IN ('multiple_choice', 'multiple_answer', 'essay', 'essay_blanks')
           THEN question ->> 'prompt' END,
      CASE WHEN q_type IN ('single_choice', 'drag_and_drop', 'essay_blanks')
           THEN question ->> 'template' END,
      CASE WHEN q_type IN ('multiple_choice', 'multiple_answer', 'single_choice', 'drag_and_drop')
           THEN question ->> 'explanation' END,
      CASE WHEN q_type = 'essay' THEN (question ->> 'maxLength')::integer END,
      CASE WHEN q_type = 'essay' THEN question ->> 'referenceAnswer' END
    )
    RETURNING id INTO v_question_id;

    IF q_type IN ('multiple_choice', 'multiple_answer') THEN
      INSERT INTO question_options (question_id, text, is_correct, order_index)
      SELECT v_question_id, o.value ->> 'text', (o.value ->> 'isCorrect')::boolean, o.ord
      FROM jsonb_array_elements(question -> 'options') WITH ORDINALITY AS o(value, ord);

    ELSIF q_type = 'single_choice' THEN
      FOR entry_idx, entry IN
        SELECT b.ord, b.value
        FROM jsonb_array_elements(question -> 'blanks') WITH ORDINALITY AS b(value, ord)
      LOOP
        INSERT INTO question_blanks (question_id, blank_key, order_index)
        VALUES (v_question_id, entry ->> 'key', entry_idx)
        RETURNING id INTO v_blank_id;

        INSERT INTO question_blank_options (blank_id, text, is_correct, order_index)
        SELECT v_blank_id, o.value ->> 'text', (o.value ->> 'isCorrect')::boolean, o.ord
        FROM jsonb_array_elements(entry -> 'options') WITH ORDINALITY AS o(value, ord);
      END LOOP;

    ELSIF q_type = 'drag_and_drop' THEN
      INSERT INTO question_terms (question_id, text, order_index)
      SELECT v_question_id, t.value #>> '{}', t.ord
      FROM jsonb_array_elements(question -> 'terms') WITH ORDINALITY AS t(value, ord);

      INSERT INTO question_slots (question_id, slot_key, correct_term_id, order_index)
      SELECT v_question_id, s.value ->> 'key', term.id, s.ord
      FROM jsonb_array_elements(question -> 'slots') WITH ORDINALITY AS s(value, ord)
      JOIN question_terms term
        ON term.question_id = v_question_id AND term.text = s.value ->> 'correctTerm';

    ELSIF q_type = 'essay_blanks' THEN
      INSERT INTO question_blanks (question_id, blank_key, reference_answer, order_index)
      SELECT v_question_id, b.value ->> 'key', b.value ->> 'referenceAnswer', b.ord
      FROM jsonb_array_elements(question -> 'blanks') WITH ORDINALITY AS b(value, ord);
    END IF;

    INSERT INTO quiz_questions (quiz_id, question_id, order_index)
    VALUES (v_quiz_id, v_question_id, idx);
  END LOOP;

  RAISE NOTICE 'imported quiz % (id %) with % question(s)',
    quiz_title, v_quiz_id, jsonb_array_length(payload -> 'questions');
END;
$do$;

COMMIT;
