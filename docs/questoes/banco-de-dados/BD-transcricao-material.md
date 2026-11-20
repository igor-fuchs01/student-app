# Banco de Dados — transcrição do material da Sprint 3

Base de conteúdo das questões da Sprint 3 de Banco de Dados
([`BD-questoes-sprint3.md`](BD-questoes-sprint3.md)). Reúne, por aula, o que o material traz, o
conteúdo complementar de subqueries, o que fica fora das questões e as pegadinhas usadas nas
alternativas erradas.

| Material | Tipo | Uso nas questões |
|---|---|---|
| Funções no MySQL (livro do Moodle, 11 capítulos) | Texto | Conteúdo principal e banco `vendas_funcoes` |
| Material de apoio — Funções Matemáticas | Slides | Conteúdo (reforça o livro) |
| View | Slides | Conteúdo e banco `estado` / `cidade` / `aeroporto` |
| Relacionamento N:M | Slides | Conteúdo e banco `aluno` / `curso` / `matricula` |
| Aula — Dashboards (Pesquisa e Inovação) | Slides | Só cenário: métricas como ticket médio e taxa de conversão |

Todas as queries seguem a sintaxe do MySQL 8, usado no Workbench, com `ONLY_FULL_GROUP_BY` ativo.

## 1. Funções no MySQL (livro)

### 1.1 O que são funções

- Uma função recebe um valor (ou uma coluna inteira), faz algo com ele e devolve um resultado novo.
  Serve para formatar dados, fazer cálculos, análise estatística e relatórios.
- **Função de linha** transforma o valor de cada linha e devolve uma resposta por linha (`ROUND`,
  `UPPER`, `YEAR`, `IFNULL`). **Função de agregação** resume várias linhas em um valor (ou um por
  grupo, com `GROUP BY`): `SUM`, `AVG`, `COUNT`, `MIN`, `MAX`.
- Pode aparecer no `SELECT`, no `WHERE` (`WHERE MONTH(dataHora) = 10`), no `ORDER BY` e no `HAVING`.
- `AS` dá nome à coluna calculada; nome com espaço vai entre aspas simples (`AS 'Média dos Preços'`).
- A função muda só o resultado da consulta, nunca a tabela (para gravar seria preciso um `UPDATE`).
- Funções se aninham e são resolvidas de dentro para fora: `UPPER(LEFT(TRIM(nome), 3))`.

### 1.2 O banco `vendas_funcoes`

Loja de informática: `venda (idVenda, dataHora, vendedor)` 1:N `item (fkVenda, fkProduto,
quantidade, desconto)` N:1 `produto (idProduto, nome, preco, categoria)`, mais `Funcionario
(idFuncionario, nome, salario)`. `item` tem PK composta `(fkVenda, fkProduto)` e o desconto é em %.

| Tabela | Linhas | Destaques |
|---|---|---|
| venda | 12 | Ana Souza 5 vendas, Bruno Lima 3, Carla Mendes 2, Diego Rocha 2; setembro 2 e outubro 10 |
| produto | 10 | Periféricos 3, Monitores 2, Computadores 2, Acessórios 2 e 1 sem categoria (Fone Bluetooth) |
| item | 20 | Só 11 com desconto preenchido; soma de quantidade = 37 |
| Funcionario | 3 | Salários 15000, 5000 e 2000 |

Os dados têm "sujeira" de propósito: o produto 3 tem espaços nas pontas (`'  Monitor 24 pol  '`),
o produto 2 está em maiúsculas, o produto 10 não tem categoria e vários itens têm desconto nulo.

Preços: Mouse Gamer 129.90, TECLADO MECÂNICO 349.90, Monitor 24 pol 899.00, Monitor 27 pol
1599.90, Notebook Pro 15 5499.00, Desktop Office 2899.50, Cabo HDMI 2m 29.90, Mochila Notebook
159.90, Webcam Full HD 239.90 e Fone Bluetooth 199.90 (média geral 1200.68).

### 1.3 Funções numéricas

| Função | O que faz | Exemplo |
|---|---|---|
| `ABS(x)` | Tira o sinal | `ABS(-15.75)` = 15.75 |
| `CEIL(x)` | Sobe para o próximo inteiro | `CEIL(4.1)` = 5 |
| `FLOOR(x)` | Desce para o inteiro anterior | `FLOOR(4.7)` = 4 |
| `ROUND(x, n)` | Arredonda; a partir de 5 sobe | `ROUND(1.305, 2)` = 1.31 |
| `TRUNCATE(x, n)` | Corta as casas (n obrigatório) | `TRUNCATE(123.4567, 2)` = 123.45 |
| `SQRT(x)` | Raiz quadrada | `SQRT(81)` = 9 |
| `POWER(a, b)` | a elevado a b | `POWER(2, 10)` = 1024 |
| `MOD(a, b)` | Resto da divisão (igual a `a % b`) | `MOD(11, 5)` = 1 |

| Valor | CEIL | FLOOR | ROUND | TRUNCATE(v, 0) |
|---|---|---|---|---|
| 4.3 | 5 | 4 | 4 | 4 |
| 4.5 | 5 | 4 | 5 | 4 |
| 4.7 | 5 | 4 | 5 | 4 |
| -4.7 | -4 | -5 | -5 | -4 |

- `TRUNCATE` anda sempre em direção ao zero e só o `ROUND` olha o valor da casa decimal.
- `ROUND(7333.338888, 2)` = 7333.34 e `TRUNCATE(7333.338888, 2)` = 7333.33. Em média de relatório
  usa-se `ROUND`; quando não se pode mostrar mais do que existe (saldo), `TRUNCATE`.
- `MOD(idVenda, 2) = 0` filtra os ids pares.

### 1.4 Funções de texto

- `UPPER` / `LOWER` padronizam a caixa. `TRIM` tira espaços dos dois lados, `LTRIM` da esquerda e
  `RTRIM` da direita. `WHERE nome = 'Monitor 24 pol'` não acha o produto 3; com `TRIM(nome)` acha.
- `LEFT(t, n)` e `RIGHT(t, n)`: primeiros e últimos n caracteres.
- `SUBSTRING(t, pos, tam)`: a posição começa em **1**; sem tamanho vai até o fim; posição negativa
  conta do final (`SUBSTRING('Ana Souza', -5)` = `Souza`).
- `LOCATE(trecho, t)`: posição do trecho, ou **0** se não achar.
- Primeiro nome e sobrenome: `SUBSTRING(vendedor, 1, LOCATE(' ', vendedor) - 1)` e
  `SUBSTRING(vendedor, LOCATE(' ', vendedor) + 1)`.
- `REPLACE(t, de, para)` troca todas as ocorrências. `CONCAT(a, b, ...)` junta textos; números e
  datas viram texto.
- Código de produto: `CONCAT(UPPER(LEFT(TRIM(nome), 3)), '-', idProduto)` dá `MOU-1`, `MON-3`.

### 1.5 Funções de data e hora

- `NOW()`, `CURDATE()` e `CURTIME()`: momento atual, só data, só hora.
- `YEAR`, `MONTH`, `DAY`, `HOUR`, `MINUTE`, `DATE` e `TIME` extraem partes da data.
- `DAYNAME` e `MONTHNAME` saem em inglês; em português com `SET lc_time_names = 'pt_BR'`.
- `WEEKDAY` devolve 0 na segunda até 6 no domingo (sábado = 5). `DAYOFWEEK` começa em 1 no domingo
  (sábado = 7). Fim de semana: `WEEKDAY(dataHora) IN (5, 6)` (vendas 4, 5 e 8).
- `DATEDIFF(d1, d2)` dá dias, positivo quando d1 é maior: `DATEDIFF('2026-10-31', '2026-10-03')` = 28.
  `TIMESTAMPDIFF(unidade, inicio, fim)` aceita `SECOND`, `MINUTE`, `HOUR`, `DAY`, `MONTH`, `YEAR`.
- `DATE_ADD` / `DATE_SUB` com `INTERVAL n unidade`.
- `DATE_FORMAT(d, formato)`: `%d` dia, `%m` mês, `%Y` ano com 4 dígitos, `%H` hora 00–23, `%i`
  minutos, `%s` segundos, `%W` dia da semana e `%M` mês por extenso.
  `DATE_FORMAT(dataHora, '%d/%m/%Y %H:%i')` = `03/10/2026 16:30`.
- Para período, `BETWEEN` permite usar índice; `MONTH(dataHora) = 10` calcula o mês de cada linha.

### 1.6 Tratamento de nulos

- `NULL` é valor desconhecido ou ausente: não é zero nem texto vazio. `NULL = NULL` dá `NULL`;
  teste sempre com `IS NULL` / `IS NOT NULL`. Qualquer conta com `NULL` dá `NULL`.
- `IFNULL(valor, substituto)`: **2 argumentos**. `COALESCE(a, b, c, ...)`: vários, devolve o primeiro
  não nulo (`COALESCE(NULL, NULL, 'terceiro')` = `terceiro`).
- `CONCAT(nome, ' - ', categoria)` dá `NULL` para o produto 10; com `IFNULL(categoria, 'Sem
  categoria')` funciona.
- Agregações ignoram nulos: em `item`, `COUNT(*)` = 20, `COUNT(desconto)` = 11, `AVG(desconto)` =
  5.0000 (11 linhas) e `AVG(IFNULL(desconto, 0))` = 2.7500 (20 linhas). Qual é o certo depende da
  pergunta, mas a escolha é de propósito.
- `NULLIF(a, b)` devolve `NULL` quando `a = b` e `a` quando são diferentes. Uso principal: evitar
  divisão por zero, `100 / NULLIF(0, 0)` = `NULL` e `100 / NULLIF(4, 0)` = 25.0000.

### 1.7 Condicionais

- `CASE WHEN cond THEN valor ... ELSE valor END` testa na ordem e **para na primeira condição
  verdadeira**; `ELSE` cobre o resto. Na faixa de preço (`< 200` Barato, `< 1000` Médio, senão Caro)
  o segundo `WHEN` não precisa de `preco >= 200`.
- Forma simples: `CASE categoria WHEN 'Periféricos' THEN 'PER' ... ELSE 'OUT' END` (o `NULL` cai no
  `ELSE`).
- `IF(cond, a, b)`: decisão simples (`IF(quantidade >= 3, 'Atacado', 'Varejo')`).
- Valor do item: `ROUND(p.preco * i.quantidade * (1 - IFNULL(i.desconto, 0) / 100), 2)`. Trate o
  nulo na primeira vez que a coluna aparecer no cálculo.

### 1.8 Funções de agregação

- `SUM`, `AVG`, `MIN`, `MAX` e `COUNT`. Em `Funcionario`: `SUM(salario)` = 22000.00,
  `AVG(salario)` = 7333.333333, `ROUND(AVG(salario), 2)` = `TRUNCATE(AVG(salario), 2)` = 7333.33.
- `COUNT(*)` conta todas as linhas; `COUNT(coluna)` só as não nulas; `COUNT(DISTINCT coluna)` os
  valores diferentes, sem nulos. Em `produto`: 10, 9 e 4. Em `venda`: 12 vendas e 4 vendedores.
- Todas as agregações, menos `COUNT(*)`, ignoram nulos.
- O `WHERE` roda antes da agregação: `SUM(salario) ... WHERE salario < 10000` = 7000.00.
- Agregação depois de `JOIN` considera cada linha de `item`: produtos vendidos mais vezes pesam mais.
- `SELECT nome, SUM(salario) FROM Funcionario` mistura coluna comum com agregação: erro no MySQL 8.
- `SUM`/`AVG` em texto não dá erro mas não faz sentido; `MIN`, `MAX` e `COUNT` funcionam com texto e
  datas (`MAX(dataHora)` é a venda mais recente).

### 1.9 GROUP BY

- Separa as linhas em grupos, um por valor, e aplica a agregação em cada grupo:
  `SELECT categoria, SUM(preco) FROM produto GROUP BY categoria` dá 5 linhas, inclusive o grupo
  `NULL` (199.90). Para tirar esse grupo, `WHERE categoria IS NOT NULL` antes de agrupar.
- Regra: toda coluna do `SELECT` está no `GROUP BY` ou dentro de uma agregação.
  `SELECT categoria, nome, COUNT(*) ... GROUP BY categoria` dá o **erro 1055** no MySQL 8.
- Várias agregações por grupo, agrupamento por expressão (`GROUP BY MONTH(dataHora)`: 9 → 2, 10 → 10)
  e por várias colunas (`GROUP BY vendedor, MONTH(dataHora)`: 6 combinações).
- `ORDER BY` vem depois do `GROUP BY` e pode usar o apelido. Faturamento por categoria exige juntar
  `item` e `produto` antes de agrupar (Computadores 13897.50, Monitores 7496.70, Periféricos 2328.80,
  Acessórios 938.60, NULL 399.80).

### 1.10 HAVING e ordem de execução

- `WHERE COUNT(*) > 2` dá o **erro 1111** (uso inválido de função de grupo). Filtro de grupo vai no
  `HAVING`: `GROUP BY vendedor HAVING COUNT(*) > 2` devolve Ana Souza (5) e Bruno Lima (3).
- `HAVING AVG(preco) > 500` dá Computadores e Monitores. Faturamento bruto acima de 3000: Ana
  11817.50, Diego 6078.40, Bruno 5946.40 (Carla 1219.10 fica fora).
- `WHERE preco > 100 ... GROUP BY categoria HAVING COUNT(*) >= 2` dá Computadores, Monitores e
  Periféricos; Acessórios sai porque, depois do `WHERE`, sobra só a mochila.

| | WHERE | HAVING |
|---|---|---|
| Filtra | Linhas | Grupos |
| Roda | Antes do GROUP BY | Depois do GROUP BY |
| Aceita agregação | Não | Sim |

- Ordem de execução: `FROM`/`JOIN` → `WHERE` → `GROUP BY` → `HAVING` → `SELECT` → `ORDER BY`/`LIMIT`.
  A ordem de escrita é `SELECT`, `FROM`, `JOIN`, `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`, `LIMIT`.
- Condição sobre coluna comum vai no `WHERE` (filtrar cedo é mais rápido); sobre agregação, no
  `HAVING`.
- O MySQL aceita o apelido no `HAVING` (`HAVING vendas > 2`), mas nas aulas e provas prefira repetir
  a função (`HAVING COUNT(*) > 2`).

### 1.11 Exercícios do livro

Resultados de conferência: ímpares 1, 3, 5, 7, 9, 11; primeiros nomes Ana, Bruno, Carla, Diego;
média de Periféricos 239.90; 37 peças; vendas por vendedor 5, 3, 2, 2; categorias com média > 1000
Computadores (4199.25) e Monitores (1249.45); vendedor com pelo menos 2 vendas no fim de semana
Carla Mendes; faturamento líquido acima de 6000 Ana Souza 11162.60 e Diego Rocha 6078.40.
Dica do livro: quase todo erro vem de um nulo, de um espaço sobrando ou de condição no lugar errado
(`WHERE` no lugar de `HAVING`).

## 2. Material de apoio — Funções Matemáticas (slides)

- Para que servem: formatar e ajustar dados, análise estatística, cálculos e relatórios. Exemplo de
  dashboard de projeto de PI (quantidade de eventos, média por evento, renda, gastos).
- Classificação dos slides: **formatação** (`ABS`, `CEIL`, `FLOOR`, `ROUND`, `TRUNCATE`), **cálculo**
  (`SQRT`, `POWER`, `MOD`, `SUM`) e **estatística** (`AVG`, `MIN`, `MAX`, `COUNT`).
- Exemplos iguais aos do livro (`ROUND(1.3)` = 1, `ROUND(1.5)` = 2, `ROUND(1.305, 2)` = 1.31,
  `TRUNCATE(123.4567, 2)` = 123.45, `SQRT(81)` = 9, `POWER(9, 2)` = 81, `MOD(11, 5)` = 1).
- `GROUP BY` responde "a soma dos produtos de cada categoria" e `HAVING` "os vendedores com mais de
  duas vendas": `GROUP BY coluna HAVING COUNT(colunaZ) > 2`.

## 3. View (slides)

- Comandos SQL por família: DDL (`CREATE`, `ALTER`, `DROP`, `TRUNCATE`, sobre database, table,
  **view**, index, user, role, function, trigger, procedure, event), DML, DQL, DCL e TCL.
- **View**: objeto do banco baseado em um `SELECT`; consulta salva usada como **tabela virtual** em
  outras consultas. Dá segurança, simplifica e padroniza o acesso de quem tem permissão.
- A query da view pode usar `JOIN`, `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`, `UNION`.
- Aceita `UPDATE` e `DELETE` **somente sem função de agrupamento (`GROUP BY`)** e com permissão
  (no MySQL, a recusa é o erro 1288).
- **Não permite nomes de coluna repetidos**: use alias (o MySQL recusa com o erro 1060).
- Sintaxe: `CREATE OR REPLACE VIEW nome AS SELECT ...`, `ALTER VIEW nome AS SELECT ...`,
  `DROP VIEW nome;` e `SELECT colunas FROM nome_da_view`.
- **Importante:** na criação, **nunca** usar `REPLACE`, pois pode sobrepor uma view já existente com
  outra finalidade. `CREATE VIEW` sem `REPLACE` falha (erro 1050) se o nome já existe.
- A view pode ser usada em `JOIN` e com prefixo de database (`db_dados.vw_estado`).
- Exercícios: banco `dados_db` com `Estado`, `Cidade` e `Aeroporto` (carregado de `massa_de_dados.sql`);
  consultar cidade com estado (id da cidade, sigla do estado, nome); aeroportos com sigla do estado;
  criar `vw_cidade` e `vw_aeroporto`; consultar cidades de São Paulo e aeroportos de Pernambuco pela
  view; alterar `vw_aeroporto` incluindo o nome e filtrar siglas que começam com "C"; apagar
  `vw_cidade`.

## 4. Relacionamento N:M (slides)

- 1:N relembrado: se cada aluno faz um só curso, a FK fica no lado N (`aluno.fk_curso`).
- Nova regra: um aluno se matricula em vários cursos e um curso recebe vários alunos (N:M). N e M
  indicam "muitos"; o mínimo vem da regra de negócio (alunos e cursos podem existir sem matrícula).
- Uma FK de curso em aluno e uma de aluno em curso ainda limitam um curso por aluno e um aluno por
  curso.

| Tentativa | Problema |
|---|---|
| `fk_curso` em aluno | Limita cada aluno a um curso |
| `fk_aluno` em curso | Limita cada curso a um aluno |
| Guardar "1,2" em `fk_curso` | Mistura vários valores e impede uma FK por vínculo |
| Duplicar o cadastro do aluno | Repete dados e gera inconsistência nas alterações |

- Solução: **tabela associativa** `matricula` com `fk_ra` e `fk_curso` (PK/FK), que juntas formam a
  **PK composta**: várias FKs de aluno e de curso, desde que o par não se repita.
- Um N:M vira **duas relações 1:N** no modelo lógico (aluno 1 — 0..N matricula 0..N — 1 curso). No
  modelo conceitual o N:M é tratado de outro jeito.
- **Atributos do vínculo** (`data_inicio`, `nivel`) ficam na tabela associativa: João tem Espanhol
  em 2026-02-01 nível A2 e Inglês em 2026-02-19 nível B2.
- Exemplo: alunos 1000 Maria, 1001 João, 1002 Ana; cursos 1 Espanhol, 2 Inglês; matrículas (1000, 1),
  (1000, 2), (1001, 1), (1001, 2): quatro matrículas, dois alunos matriculados, dois cursos. Ana está
  cadastrada mas não tem matrícula.
- O que levar: a cardinalidade nasce da regra de negócio; a tabela associativa guarda uma linha por
  vínculo e seus atributos; duas FKs conectam os cadastros e a chave identifica cada ocorrência.

## 5. Aula — Dashboards (Pesquisa e Inovação)

Usada só como **cenário** para questões de consulta: métricas de dashboard calculadas com SQL, como
**ticket médio** (faturamento ÷ número de vendas do período) e **taxa de conversão** (compras ÷
visitas). A teoria de storytelling e de tipos de gráfico não é cobrada.

## 6. Conteúdo complementar: subqueries

O material não traz subqueries; esta seção é a base das questões desse tema.

- **Subquery** é um `SELECT` dentro de outro comando, entre parênteses.
- **Escalar no `WHERE`**: devolve um único valor.
  `SELECT nome, preco FROM produto WHERE preco > (SELECT AVG(preco) FROM produto);` devolve Monitor
  27 pol, Notebook Pro 15 e Desktop Office. `WHERE preco > AVG(preco)` dá o erro 1111, e se a
  subquery devolver várias linhas onde se espera uma, o erro é 1242.
- **`IN` / `NOT IN`** com subquery: `WHERE idProduto IN (SELECT fkProduto FROM item)`.
  **Pegadinha:** se a subquery do `NOT IN` devolver um `NULL`, nenhuma linha passa, porque
  `x <> NULL` é desconhecido. Correção: `WHERE fkProduto IS NOT NULL` na subquery, ou usar
  `NOT EXISTS`. O `IN` não sofre com o `NULL`.
- **`EXISTS` / `NOT EXISTS`**: testam se a subquery devolve alguma linha.
  `WHERE EXISTS (SELECT 1 FROM item i WHERE i.fkProduto = p.idProduto)`.
- **Subquery no `FROM` (tabela derivada)**: o resultado vira uma tabela temporária e **exige alias**
  no MySQL (sem ele, erro 1248). `SELECT AVG(total) FROM (SELECT fkVenda, SUM(quantidade) AS total
  FROM item GROUP BY fkVenda) AS t;` dá 3.0833 (37 peças ÷ 12 vendas). Serve para agregar uma
  agregação (`AVG(SUM(...))` direto dá o erro 1111).
- **Subquery no `SELECT`**: calcula um valor por linha.
  `SELECT a.nome, (SELECT COUNT(*) FROM matricula m WHERE m.fk_ra = a.ra) FROM aluno a;` mostra 0
  para quem não tem matrícula; com `SUM` o vazio vira `NULL`, tratado com `IFNULL(..., 0)`.
- **Correlacionada**: usa uma coluna da consulta externa e roda para cada linha dela (todas as de
  `EXISTS` acima). Exemplo: o produto mais caro de cada categoria,
  `WHERE p.preco = (SELECT MAX(p2.preco) FROM produto p2 WHERE p2.categoria = p.categoria)`.
- **Subquery × `GROUP BY ... HAVING`**: "categorias com média acima da média geral" é
  `GROUP BY categoria HAVING AVG(preco) > (SELECT AVG(preco) FROM produto)`; filtrar `preco >` média
  no `WHERE` responde outra pergunta (categorias com algum produto acima da média).

### JOIN × subquery

| Pergunta | Com subquery | Com JOIN | Cuidado |
|---|---|---|---|
| Produtos vendidos | `IN (SELECT fkProduto FROM item)` ou `EXISTS` | `JOIN item` + `DISTINCT` | Sem `DISTINCT` o JOIN repete o produto a cada venda |
| Produtos nunca vendidos | `NOT EXISTS` ou `NOT IN` | `LEFT JOIN item ... WHERE i.fkProduto IS NULL` | `NOT IN` falha se a subquery tiver `NULL` |
| Contagem por linha, inclusive 0 | Subquery no `SELECT` com `COUNT(*)` | `LEFT JOIN` + `COUNT(coluna_da_direita)` | `COUNT(*)` no `LEFT JOIN` conta 1 para quem não tem par |
| Média de totais | Tabela derivada com alias | — | Sem alias, erro 1248 |

- `IN`, `EXISTS` e `JOIN` + `DISTINCT` são equivalentes para "existe correspondência"; o `JOIN` puro
  multiplica as linhas.
- `NOT EXISTS` e `LEFT JOIN ... IS NULL` são equivalentes; `NOT IN` só é equivalente quando a
  subquery não devolve `NULL`.

## 7. O que não deve ser cobrado

- Teoria de dashboards, storytelling e escolha de tipos de gráfico (aula de Pesquisa e Inovação).
- Detalhes de configuração do servidor (modo SQL além do `ONLY_FULL_GROUP_BY`, índices, desempenho
  além da dica do `BETWEEN`).
- Valores de `NOW()`, `CURDATE()` e `CURTIME()`, que dependem do momento da execução.
- Comandos DDL que não sejam de view (`TRUNCATE`, `TRIGGER`, `PROCEDURE`, `EVENT`), DCL e TCL, que
  aparecem só no mapa de comandos dos slides de view.
- Subqueries além da seção 6 (`ANY`, `ALL`, CTE com `WITH`, funções de janela).
- Modelo conceitual do N:M (os slides tratam só do modelo lógico).

## 8. Pegadinhas (para alternativas erradas)

- `FLOOR(-4.7)` é -5 e `CEIL(-4.7)` é -4; `TRUNCATE` corta em direção ao zero e não arredonda
  (`TRUNCATE(7333.338888, 2)` = 7333.33 e `ROUND` = 7333.34); `CEIL(4.1)` já é 5.
- `CONCAT` com um argumento `NULL` devolve `NULL`; `IFNULL` aceita 2 argumentos (3 dá o erro 1582)
  e `COALESCE` aceita vários.
- `COUNT(*)` conta todas as linhas, `COUNT(coluna)` ignora nulos e `COUNT(DISTINCT coluna)` não
  repete nem conta nulo; `AVG(coluna)` é diferente de `AVG(IFNULL(coluna, 0))`.
- `NULL = NULL` não é verdadeiro: use `IS NULL`. `NULL < 5` também não, então um grupo com média
  `NULL` sai do `HAVING AVG(...) < 5`.
- `GROUP BY` cria um grupo para o `NULL`, mas `COUNT(DISTINCT)` não conta o nulo.
- Coluna fora do `GROUP BY` e fora de agregação dá o erro 1055 no MySQL 8; agregação sem
  `GROUP BY` com coluna comum também é recusada.
- `WHERE` filtra linhas antes de agrupar e `HAVING` filtra grupos depois; agregação no `WHERE` dá o
  erro 1111. `WHERE preco > 100` e `HAVING MIN(preco) > 100` dão resultados diferentes.
- Depois de um `JOIN` com `item`, `COUNT(*)` conta itens, não vendas: use `COUNT(DISTINCT v.idVenda)`.
- `COUNT(*)` em `LEFT JOIN` conta 1 para quem não tem correspondência; conte uma coluna da tabela da
  direita.
- `CASE` para no primeiro `WHEN` verdadeiro: a ordem das faixas muda o resultado.
- `SUBSTRING` começa na posição 1; `LOCATE` devolve 0 quando não acha, e `SUBSTRING(t, 1, 0 - 1)`
  devolve texto vazio.
- `WEEKDAY` começa em 0 na segunda; `DAYOFWEEK` em 1 no domingo. Em `DATE_FORMAT`, `%m` é mês, `%i`
  são minutos e `%M` é o nome do mês.
- `NULLIF(x, 0)` evita divisão por zero.
- Views: sem nomes de coluna repetidos (use alias); sem `UPDATE`/`DELETE` quando há `GROUP BY`;
  `CREATE OR REPLACE` sobrepõe sem aviso uma view existente; a view guarda a consulta, não os dados,
  então enxerga inserções feitas depois; `DROP VIEW` não apaga as tabelas.
- N:M: as duas FKs formam a PK composta da tabela associativa, e os atributos do vínculo (data de
  início, nível) ficam nela; um id artificial como única PK deixa o mesmo vínculo se repetir; uma
  linha de matrícula nunca tem dois cursos, então "faz Espanhol **e** Inglês" pede `GROUP BY` com
  `HAVING COUNT(*) = 2`, não `fk_curso = 1 AND fk_curso = 2`.
- Subqueries: `NOT IN` com `NULL` na subquery não devolve nada; tabela derivada sem alias dá o erro
  1248; subquery que devolve várias linhas em comparação com `=` ou `<>` dá o erro 1242; subquery
  não correlacionada no `WHERE` vale igual para todas as linhas.
