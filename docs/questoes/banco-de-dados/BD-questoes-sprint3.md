# Banco de Dados — questões da Sprint 3

Aula **Funções, GROUP BY, Subqueries, Views e Relacionamento N:M**: 45 questões sobre o material da Sprint 3 (funções do MySQL, nulos e condicionais,
agregação, GROUP BY e HAVING, views e relacionamento N:M) e sobre o conteúdo complementar de
subqueries. O foco é a **comparação de queries**: 38 das 45 questões mostram duas ou mais
consultas (ou expressões) e cobram a diferença entre elas.

- Conteúdo de base: [`BD-transcricao-material.md`](BD-transcricao-material.md).
- Script de cadastro: [`BD-questoes-sprint3.sql`](BD-questoes-sprint3.sql).
- Simulado "BD - Sprint 3": [`BD-simulado-sprint3.sql`](BD-simulado-sprint3.sql) (30 questões, 60 minutos, nível médio).
- Sintaxe de MySQL 8. Todas as queries das questões foram executadas no MySQL 8.4, com
  `ONLY_FULL_GROUP_BY` ativo como no Workbench, e os gabaritos e mensagens de erro saíram dessa
  execução.

## Resumo

| Lista | Dificuldade | Questões | Tipos |
|---|---|---|---|
| Exercícios 1: Fundamentos | 9 fácil, 6 média | Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15 | 6 multiple_choice, 2 single_choice, 4 drag_and_drop, 3 multiple_answer |
| Exercícios 2: Aplicação | 15 difícil | Q16, Q17, Q18, Q19, Q20, Q21, Q22, Q23, Q24, Q25, Q26, Q27, Q28, Q29, Q30 | 6 multiple_choice, 3 multiple_answer, 2 single_choice, 4 drag_and_drop |
| Exercícios 3: Desafio | 15 super difícil | Q31, Q32, Q33, Q34, Q35, Q36, Q37, Q38, Q39, Q40, Q41, Q42, Q43, Q44, Q45 | 6 multiple_choice, 3 multiple_answer, 4 drag_and_drop, 2 single_choice |

| Subassunto | Questões | Total |
|---|---|---|
| Funções numéricas, de texto e de data | Q1, Q3, Q25, Q30, Q38 | 5 |
| Tratamento de nulos e condicionais | Q2, Q8, Q14, Q19, Q28, Q34, Q44 | 7 |
| Agregação, GROUP BY e HAVING | Q4, Q10, Q11, Q16, Q17, Q23, Q33, Q40, Q43 | 9 |
| Subqueries e comparação com JOIN | Q15, Q18, Q22, Q24, Q29, Q31, Q32, Q37, Q39, Q45 | 10 |
| Views | Q5, Q9, Q12, Q20, Q26, Q35, Q42 | 7 |
| Relacionamento N:M e tabela associativa | Q6, Q7, Q13, Q21, Q27, Q36, Q41 | 7 |

Comparação de queries: Q1, Q2, Q4, Q8, Q10, Q11, Q13, Q15, Q16, Q17, Q18, Q19, Q20, Q21, Q22, Q23, Q24, Q25, Q26, Q27, Q28, Q29, Q30, Q31, Q32, Q33, Q34, Q35, Q36, Q37, Q38, Q39, Q40, Q41, Q42, Q43, Q44, Q45.

Simulado (ordem de exibição): Q1, Q16, Q31, Q2, Q17, Q32, Q4, Q18, Q33, Q8, Q20, Q34, Q10, Q21, Q35, Q11, Q22, Q36, Q13, Q23, Q37, Q15, Q24, Q39, Q27, Q41, Q28, Q42, Q29, Q43.

## Exercícios 1: Fundamentos

### Q1 · multiple_choice · fácil

- Subassunto: Funções numéricas, de texto e de data
- Comparação de queries: sim

**Enunciado**

```text
Um relatório de ajuste de estoque precisa tratar valores negativos. Query A: SELECT CEIL(-4.7), FLOOR(-4.7); Query B: SELECT ROUND(-4.7), TRUNCATE(-4.7, 0); Quais valores cada query devolve, na ordem das colunas?
```

**Alternativas**

```text
A) A: -5 e -4; B: -5 e -4
B) A: -4 e -5; B: -4 e -5
C) A: -4 e -5; B: -5 e -4
D) A: -5 e -4; B: -4 e -5
E) A: -4 e -4; B: -5 e -5
```

**Gabarito:** correta: C

**Explicação:** CEIL sobe em direção ao mais infinito (-4) e FLOOR desce em direção ao menos infinito (-5). ROUND vai para o inteiro mais próximo (-5) e TRUNCATE só corta as casas, andando em direção ao zero (-4).

### Q2 · single_choice · fácil

- Subassunto: Tratamento de nulos e condicionais
- Comparação de queries: sim

**Enunciado (lacunas)**

```text
A tabela item do banco vendas_funcoes tem 20 linhas, e só 11 delas têm desconto preenchido (as outras 9 são NULL). SELECT COUNT(*) FROM item; devolve {{b1}}, SELECT COUNT(desconto) FROM item; devolve {{b2}} e AVG(IFNULL(desconto, 0)) divide a soma dos descontos por {{b3}}.
```

**Opções de cada lacuna**

```text
b1: 20 | 11 | 9
b2: 20 | 11 | 9
b3: 11 | 20 | 9
```

**Gabarito:** b1: 20, b2: 11, b3: 20

**Explicação:** COUNT(*) conta todas as linhas, e COUNT(coluna) ignora os nulos. Com IFNULL(desconto, 0) os nulos viram 0 e entram na conta, então a média passa a usar as 20 linhas.

### Q3 · drag_and_drop · fácil

- Subassunto: Funções numéricas, de texto e de data
- Comparação de queries: não

**Enunciado (slots)**

```text
Associe cada expressão ao valor que ela devolve no MySQL: ROUND(7333.338888, 2) devolve {{s1}}; TRUNCATE(7333.338888, 2) devolve {{s2}}; CEIL(4.1) devolve {{s3}}; MOD(11, 5) devolve {{s4}}.
```

**Termos para arrastar**

```text
- 4
- 7333.34
- 1
- 7333.3
- 5
- 7333.33
```

**Gabarito:** s1: 7333.34, s2: 7333.33, s3: 5, s4: 1

**Explicação:** ROUND arredonda olhando a terceira casa (8, então sobe) e TRUNCATE só corta. CEIL sempre sobe para o próximo inteiro, mesmo com 4.1, e MOD devolve o resto da divisão de 11 por 5.

### Q4 · multiple_choice · fácil

- Subassunto: Agregação, GROUP BY e HAVING
- Comparação de queries: sim

**Enunciado**

```text
Na tabela venda (idVenda, dataHora, vendedor), Ana Souza tem 5 vendas, Bruno Lima 3, Carla Mendes 2 e Diego Rocha 2. Qual query lista os vendedores com mais de duas vendas?
```

**Alternativas**

```text
A) SELECT vendedor, COUNT(*) FROM venda GROUP BY vendedor HAVING COUNT(*) > 2;
B) SELECT vendedor, COUNT(*) FROM venda WHERE COUNT(*) > 2 GROUP BY vendedor;
C) SELECT vendedor, COUNT(*) FROM venda GROUP BY vendedor HAVING vendedor > 2;
D) SELECT vendedor, COUNT(*) FROM venda WHERE idVenda > 2 GROUP BY vendedor;
E) SELECT vendedor, COUNT(*) FROM venda HAVING COUNT(*) > 2;
```

**Gabarito:** correta: A

**Explicação:** A contagem só existe depois do GROUP BY, então o filtro de grupo vai no HAVING. COUNT(*) no WHERE dá o erro 1111, e sem GROUP BY o MySQL 8 recusa misturar vendedor com COUNT(*).

### Q5 · multiple_answer · fácil

- Subassunto: Views
- Comparação de queries: não

**Enunciado**

```text
Uma equipe vai criar views para o relatório de aeroportos. Sobre views no MySQL, assinale todas as corretas.
```

**Alternativas**

```text
A) A view guarda o SELECT e funciona como tabela virtual, sem copiar os dados
B) Uma view com GROUP BY aceita UPDATE e DELETE como uma tabela comum
C) Ao criar uma view, o recomendado é usar sempre CREATE OR REPLACE VIEW
D) Colunas com o mesmo nome no SELECT da view precisam receber um alias
E) DROP VIEW apaga a view e também as linhas das tabelas usadas nela
```

**Gabarito:** corretas: A, D

**Explicação:** A view é uma consulta salva usada como tabela virtual e não aceita nomes de coluna repetidos, por isso o alias. UPDATE e DELETE só valem para views sem GROUP BY, o material proíbe REPLACE na criação e DROP VIEW não mexe nas tabelas.

### Q6 · multiple_choice · fácil

- Subassunto: Relacionamento N:M e tabela associativa
- Comparação de queries: não

**Enunciado**

```text
Uma escola de idiomas mudou a regra: um aluno pode se matricular em vários cursos e um curso pode receber vários alunos. Como fica o modelo lógico?
```

**Alternativas**

```text
A) fk_curso na tabela aluno, como no relacionamento 1:N de antes
B) fk_aluno na tabela curso, apontando para o aluno mais recente
C) fk_curso em aluno e fk_aluno em curso, uma chave em cada lado
D) fk_curso em aluno guardando vários ids juntos, como '1,2'
E) Tabela matricula com fk_ra e fk_curso formando a chave primária
```

**Gabarito:** correta: E

**Explicação:** Qualquer FK única limita um dos lados a um só vínculo, e guardar '1,2' mistura valores. A tabela associativa tem uma linha por vínculo, e as duas FKs formam a PK composta.

### Q7 · drag_and_drop · fácil

- Subassunto: Relacionamento N:M e tabela associativa
- Comparação de queries: não

**Enunciado (slots)**

```text
No modelo aluno (ra, nome), curso (id_curso, nome) e matricula, João começou Espanhol em 2026-02-01 no nível A2. O nome de João fica em {{s1}}, o nome do curso fica em {{s2}}, a data de início e o nível ficam em {{s3}} e a chave primária de matricula é {{s4}}.
```

**Termos para arrastar**

```text
- curso
- (fk_ra)
- matricula
- aluno
- (data_inicio, nivel)
- (fk_ra, fk_curso)
```

**Gabarito:** s1: aluno, s2: curso, s3: matricula, s4: (fk_ra, fk_curso)

**Explicação:** Dados do aluno ficam em aluno e dados do curso em curso. Data de início e nível descrevem o vínculo, então ficam em matricula, cuja PK é composta pelas duas FKs.

### Q8 · multiple_choice · fácil

- Subassunto: Tratamento de nulos e condicionais
- Comparação de queries: sim

**Enunciado**

```text
O produto 10 (nome 'Fone Bluetooth') está sem categoria (NULL). Query A: SELECT CONCAT(nome, ' - ', categoria) FROM produto WHERE idProduto = 10; Query B: SELECT CONCAT(nome, ' - ', IFNULL(categoria, 'Sem categoria')) FROM produto WHERE idProduto = 10; O que cada query devolve?
```

**Alternativas**

```text
A) A: 'Fone Bluetooth - '; B: 'Fone Bluetooth - Sem categoria'
B) A: NULL (o texto inteiro); B: 'Fone Bluetooth - Sem categoria'
C) A: 'Fone Bluetooth - NULL'; B: 'Fone Bluetooth - Sem categoria'
D) A: NULL; B: NULL, pois IFNULL não funciona dentro de CONCAT
E) A: erro de tipo; B: 'Fone Bluetooth - Sem categoria'
```

**Gabarito:** correta: B

**Explicação:** Se qualquer argumento do CONCAT for NULL, o resultado inteiro é NULL. Tratando o nulo antes com IFNULL, B monta o texto normalmente.

### Q9 · single_choice · fácil

- Subassunto: Views
- Comparação de queries: não

**Enunciado (lacunas)**

```text
Para criar a view do exercício sem correr o risco de sobrepor outra: {{b1}} vw_cidade AS SELECT c.id AS id_cidade, e.sigla AS sigla_estado, c.nome AS nome_cidade FROM cidade c JOIN estado e ON e.id = c.id_estado; Para consultar as cidades de São Paulo: SELECT nome_cidade FROM {{b2}} WHERE sigla_estado = 'SP'; Para apagar a view no fim: {{b3}} vw_cidade;
```

**Opções de cada lacuna**

```text
b1: CREATE VIEW | CREATE OR REPLACE VIEW | ALTER VIEW
b2: cidade | vw_cidade | VIEW vw_cidade
b3: DELETE FROM | TRUNCATE TABLE | DROP VIEW
```

**Gabarito:** b1: CREATE VIEW, b2: vw_cidade, b3: DROP VIEW

**Explicação:** Na criação, o material pede CREATE VIEW sem REPLACE, para não sobrepor uma view existente. A view é consultada pelo nome, como uma tabela, e removida com DROP VIEW.

### Q10 · multiple_choice · média

- Subassunto: Agregação, GROUP BY e HAVING
- Comparação de queries: sim

**Enunciado**

```text
A coluna categoria de produto tem os valores Periféricos (3 produtos), Monitores (2), Computadores (2), Acessórios (2) e NULL (1). Query A: SELECT COUNT(DISTINCT categoria) FROM produto; Query B: SELECT categoria FROM produto GROUP BY categoria; Qual valor A devolve e quantas linhas B devolve?
```

**Alternativas**

```text
A) A devolve 5 e B devolve 5 linhas
B) A devolve 4 e B devolve 4 linhas
C) A devolve 9 e B devolve 5 linhas
D) A devolve 4 e B devolve 5 linhas
E) A devolve 5 e B devolve 4 linhas
```

**Gabarito:** correta: D

**Explicação:** COUNT(DISTINCT categoria) não conta o nulo, então dá 4. Já o GROUP BY não descarta nulos: o NULL forma um grupo próprio, e B devolve 5 linhas.

### Q11 · multiple_answer · média

- Subassunto: Agregação, GROUP BY e HAVING
- Comparação de queries: sim

**Enunciado**

```text
A query base SELECT categoria, COUNT(*) AS qtd FROM produto WHERE preco > 100 GROUP BY categoria HAVING COUNT(*) >= 2; devolve Periféricos (3), Monitores (2) e Computadores (2). Acessórios tem um produto de 29.90 e outro de 159.90. Assinale todas as queries que devolvem exatamente o mesmo resultado.
```

**Alternativas**

```text
A) SELECT categoria, COUNT(*) AS qtd FROM produto GROUP BY categoria HAVING COUNT(*) >= 2;
B) SELECT categoria, COUNT(*) AS qtd FROM produto WHERE preco > 100 GROUP BY categoria HAVING qtd >= 2;
C) SELECT categoria, COUNT(*) AS qtd FROM produto WHERE preco > 100 AND COUNT(*) >= 2 GROUP BY categoria;
D) SELECT categoria, COUNT(idProduto) AS qtd FROM produto WHERE preco > 100 GROUP BY categoria HAVING COUNT(idProduto) >= 2;
E) SELECT categoria, COUNT(*) AS qtd FROM produto WHERE preco > 100 GROUP BY categoria HAVING COUNT(*) > 2;
```

**Gabarito:** corretas: B, D

**Explicação:** O MySQL aceita o apelido qtd no HAVING, e COUNT(idProduto) conta o mesmo que COUNT(*) porque a PK nunca é nula. Sem o WHERE, Acessórios entra com 2; COUNT(*) no WHERE dá o erro 1111; e > 2 deixa só Periféricos.

### Q12 · drag_and_drop · média

- Subassunto: Views
- Comparação de queries: não

**Enunciado (slots)**

```text
Existem a tabela categoria (id, nome) e a view vw_qtd_categoria AS SELECT categoria, COUNT(*) AS qtd FROM produto GROUP BY categoria. Associe cada comando ao que acontece: SELECT * FROM vw_qtd_categoria WHERE qtd >= 2; {{s1}}. UPDATE vw_qtd_categoria SET qtd = 0; {{s2}}. CREATE VIEW vw_nomes AS SELECT p.nome, c.nome FROM produto p JOIN categoria c ON c.nome = p.categoria; {{s3}}. DROP VIEW vw_qtd_categoria; {{s4}}.
```

**Termos para arrastar**

```text
- Erro: nome de coluna repetido na view
- Zera a quantidade de produtos de todas as categorias
- Lista as categorias com 2 ou mais produtos
- Apaga a view e as linhas de produto
- Remove só a view; produto continua igual
- Erro: a view com GROUP BY não é atualizável
```

**Gabarito:** s1: Lista as categorias com 2 ou mais produtos, s2: Erro: a view com GROUP BY não é atualizável, s3: Erro: nome de coluna repetido na view, s4: Remove só a view; produto continua igual

**Explicação:** A view pode ser consultada com WHERE como uma tabela, mas, por ter GROUP BY, não aceita UPDATE. Duas colunas nome sem alias dão erro, e DROP VIEW remove só o objeto view.

### Q13 · drag_and_drop · média

- Subassunto: Relacionamento N:M e tabela associativa
- Comparação de queries: sim

**Enunciado (slots)**

```text
Com aluno (1000 Maria, 1001 João, 1002 Ana) e matricula (fk_ra, fk_curso) com as linhas (1000, 1), (1000, 2), (1001, 1) e (1001, 2), associe cada query ao número que ela devolve: SELECT COUNT(*) FROM matricula; devolve {{s1}}. SELECT COUNT(DISTINCT fk_ra) FROM matricula; devolve {{s2}}. SELECT COUNT(*) FROM aluno a LEFT JOIN matricula m ON m.fk_ra = a.ra; devolve {{s3}}. SELECT COUNT(*) FROM aluno a LEFT JOIN matricula m ON m.fk_ra = a.ra WHERE m.fk_ra IS NULL; devolve {{s4}}.
```

**Termos para arrastar**

```text
- 3
- 4
- 1
- 5
- 2
- 0
```

**Gabarito:** s1: 4, s2: 2, s3: 5, s4: 1

**Explicação:** Há 4 matrículas de 2 alunos diferentes. O LEFT JOIN mantém Ana, que não tem matrícula, como uma linha extra (4 + 1 = 5), e o filtro IS NULL deixa só ela.

### Q14 · multiple_answer · média

- Subassunto: Tratamento de nulos e condicionais
- Comparação de queries: não

**Enunciado**

```text
Um relatório trata descontos nulos e divisões por zero. Sobre IFNULL, COALESCE e NULLIF no MySQL, assinale todas as corretas.
```

**Alternativas**

```text
A) IFNULL(desconto, 0, 5) é válido e testa os argumentos em ordem
B) COALESCE(NULL, NULL, 'terceiro') devolve 'terceiro'
C) NULLIF(desconto, 0) devolve NULL quando o desconto é 0
D) NULL = NULL devolve 1, então WHERE desconto = NULL acha os nulos
E) 100 / NULLIF(0, 0) devolve NULL em vez de dividir por zero
```

**Gabarito:** corretas: B, C, E

**Explicação:** IFNULL aceita só 2 argumentos e COALESCE devolve o primeiro não nulo de vários. NULLIF(a, b) dá NULL quando a = b, o que evita a divisão por zero, e NULL = NULL dá NULL, por isso se usa IS NULL.

### Q15 · multiple_choice · média

- Subassunto: Subqueries e comparação com JOIN
- Comparação de queries: sim

**Enunciado**

```text
O preço médio da tabela produto é 1200.68. Qual query lista o nome e o preço dos produtos mais caros que essa média, sem digitar o valor na mão?
```

**Alternativas**

```text
A) SELECT nome, preco FROM produto WHERE preco > AVG(preco);
B) SELECT nome, preco FROM produto WHERE preco > (SELECT preco FROM produto);
C) SELECT nome, preco FROM produto WHERE preco > (SELECT AVG(preco) FROM produto);
D) SELECT nome, preco FROM produto GROUP BY idProduto HAVING preco > AVG(preco);
E) SELECT nome, preco FROM produto HAVING preco > AVG(preco);
```

**Gabarito:** correta: C

**Explicação:** A subquery escalar calcula a média uma vez e o WHERE compara cada preço com ela. AVG direto no WHERE dá o erro 1111, a subquery sem AVG devolve várias linhas (erro 1242) e agrupar por produto compara cada preço com ele mesmo.

## Exercícios 2: Aplicação

### Q16 · multiple_choice · difícil

- Subassunto: Agregação, GROUP BY e HAVING
- Comparação de queries: sim

**Enunciado**

```text
Um dashboard mostra o ticket médio por dia: faturamento do dia dividido pelo número de vendas do dia. Os dados são venda (idVenda, dataHora): (1, '2026-10-02 09:00'), (2, '2026-10-02 15:00') e (3, '2026-10-03 10:00'); e item (fkVenda, valor): (1, 100), (1, 50), (2, 30) e (3, 80). Qual query devolve o ticket médio correto de cada dia?
```

**Alternativas**

```text
A) SELECT DATE(v.dataHora) AS dia, AVG(i.valor) AS ticket FROM venda v JOIN item i ON i.fkVenda = v.idVenda GROUP BY DATE(v.dataHora);
B) SELECT DATE(v.dataHora) AS dia, SUM(i.valor) / COUNT(DISTINCT v.idVenda) AS ticket FROM venda v JOIN item i ON i.fkVenda = v.idVenda GROUP BY DATE(v.dataHora);
C) SELECT DATE(v.dataHora) AS dia, SUM(i.valor) / COUNT(*) AS ticket FROM venda v JOIN item i ON i.fkVenda = v.idVenda GROUP BY DATE(v.dataHora);
D) SELECT DATE(v.dataHora) AS dia, SUM(i.valor) / COUNT(DISTINCT v.idVenda) AS ticket FROM venda v JOIN item i ON i.fkVenda = v.idVenda GROUP BY v.dataHora;
E) SELECT DATE(v.dataHora) AS dia, SUM(i.valor) / (SELECT COUNT(*) FROM venda) AS ticket FROM venda v JOIN item i ON i.fkVenda = v.idVenda GROUP BY DATE(v.dataHora);
```

**Gabarito:** correta: B

**Explicação:** Depois do JOIN há uma linha por item, então o divisor precisa ser COUNT(DISTINCT v.idVenda): 180 / 2 = 90 no dia 02 e 80 no dia 03. AVG e COUNT(*) dividem por itens (60), agrupar por dataHora separa cada venda e a subquery divide pelo total de vendas de todos os dias.

### Q17 · multiple_answer · difícil

- Subassunto: Agregação, GROUP BY e HAVING
- Comparação de queries: sim

**Enunciado**

```text
Em vendas_funcoes, Ana Souza tem as vendas 1, 3, 5, 7 e 12; Bruno Lima, 2, 6 e 10; Carla Mendes, 4 e 8; Diego Rocha, 9 e 11. As vendas 1, 2, 4, 5, 7, 8, 9 e 12 têm 2 itens cada e as demais, 1. Assinale todas as queries que devolvem só Ana Souza e Bruno Lima (mais de duas vendas).
```

**Alternativas**

```text
A) SELECT vendedor FROM venda GROUP BY vendedor HAVING COUNT(*) > 2;
B) SELECT vendedor FROM venda GROUP BY vendedor HAVING COUNT(*) >= 3;
C) SELECT vendedor FROM venda WHERE COUNT(*) > 2 GROUP BY vendedor;
D) SELECT v.vendedor FROM venda v JOIN item i ON i.fkVenda = v.idVenda GROUP BY v.vendedor HAVING COUNT(*) > 2;
E) SELECT v.vendedor FROM venda v JOIN item i ON i.fkVenda = v.idVenda GROUP BY v.vendedor HAVING COUNT(DISTINCT v.idVenda) > 2;
```

**Gabarito:** corretas: A, B, E

**Explicação:** Sem JOIN, cada linha é uma venda e > 2 equivale a >= 3, enquanto C dá o erro 1111. Com o JOIN, cada venda vira uma linha por item, então COUNT(*) passa a contar itens (Carla e Diego somam 4 e 3) e só COUNT(DISTINCT v.idVenda) volta a contar vendas.

### Q18 · single_choice · difícil

- Subassunto: Subqueries e comparação com JOIN
- Comparação de queries: sim

**Enunciado (lacunas)**

```text
produto tem os ids 1 (Mouse), 2 (Teclado), 3 (Monitor) e 4 (Webcam), e destaque (fkProduto) tem as linhas 1, 3 e NULL. A query SELECT nome FROM produto WHERE idProduto NOT IN (SELECT fkProduto FROM destaque); devolve {{b1}}. Já SELECT nome FROM produto p WHERE NOT EXISTS (SELECT 1 FROM destaque d WHERE d.fkProduto = p.idProduto); devolve {{b2}}. Para a versão com NOT IN dar o mesmo resultado, basta acrescentar {{b3}} na subquery.
```

**Opções de cada lacuna**

```text
b1: nenhuma linha | Teclado e Webcam | Teclado, Webcam e uma linha NULL
b2: nenhuma linha | Teclado e Webcam | Mouse e Monitor
b3: DISTINCT | WHERE fkProduto IS NOT NULL | LIMIT 1 | ORDER BY fkProduto
```

**Gabarito:** b1: nenhuma linha, b2: Teclado e Webcam, b3: WHERE fkProduto IS NOT NULL

**Explicação:** NOT IN compara com cada valor da lista, e idProduto <> NULL é desconhecido, então nenhuma linha passa. NOT EXISTS só verifica se existe linha correspondente e ignora o NULL; filtrar IS NOT NULL na subquery corrige o NOT IN.

### Q19 · drag_and_drop · difícil

- Subassunto: Tratamento de nulos e condicionais
- Comparação de queries: sim

**Enunciado (slots)**

```text
A tabela item tem 5 linhas com os descontos NULL, 0, 10, NULL e 20. Associe cada query ao valor devolvido: SELECT COUNT(*) FROM item; devolve {{s1}}. SELECT COUNT(desconto) FROM item; devolve {{s2}}. SELECT AVG(desconto) FROM item; devolve {{s3}}. SELECT AVG(IFNULL(desconto, 0)) FROM item; devolve {{s4}}.
```

**Termos para arrastar**

```text
- 10.0000
- 5
- 7.5000
- 3
- 6.0000
- 2
```

**Gabarito:** s1: 5, s2: 3, s3: 10.0000, s4: 6.0000

**Explicação:** COUNT(*) conta as 5 linhas e COUNT(desconto) só as 3 não nulas. AVG(desconto) divide 30 por 3 (10), e com IFNULL os nulos viram 0 e a soma 30 é dividida por 5 (6).

### Q20 · multiple_choice · difícil

- Subassunto: Views
- Comparação de queries: sim

**Enunciado**

```text
Existe a view vw_aeroporto AS SELECT e.sigla AS sigla_estado, a.sigla AS sigla_aeroporto FROM aeroporto a JOIN cidade c ON c.id = a.id_cidade JOIN estado e ON e.id = c.id_estado. Query A: SELECT sigla_aeroporto FROM vw_aeroporto WHERE sigla_estado = 'PE'; Query B: SELECT a.sigla FROM aeroporto a JOIN cidade c ON c.id = a.id_cidade JOIN estado e ON e.id = c.id_estado WHERE e.sigla = 'PE'; Hoje as duas devolvem REC. Depois do INSERT de um aeroporto novo em Recife, o que acontece?
```

**Alternativas**

```text
A) Só B mostra o aeroporto novo, pois a view guarda uma cópia dos dados
B) A dá erro, pois não é permitido filtrar uma view com WHERE
C) Só A mostra o aeroporto novo, e só depois de um ALTER VIEW
D) As duas mostram REC e o novo, pois a view guarda a consulta
E) A mostra o aeroporto novo duas vezes, pois repete o JOIN de B
```

**Gabarito:** correta: D

**Explicação:** A view é uma consulta salva usada como tabela virtual: a cada SELECT ela roda o JOIN de novo sobre os dados atuais. Por isso A e B são equivalentes e as duas enxergam o INSERT.

### Q21 · multiple_choice · difícil

- Subassunto: Relacionamento N:M e tabela associativa
- Comparação de queries: sim

**Enunciado**

```text
curso tem Espanhol (1), Inglês (2) e Francês (3). matricula tem 3 alunos em Espanhol, 2 em Inglês e nenhum em Francês. Qual query mostra quantos alunos cada curso tem, com Francês aparecendo com 0?
```

**Alternativas**

```text
A) SELECT c.nome, COUNT(m.fk_ra) FROM curso c LEFT JOIN matricula m ON m.fk_curso = c.id_curso GROUP BY c.id_curso, c.nome;
B) SELECT c.nome, COUNT(*) FROM curso c LEFT JOIN matricula m ON m.fk_curso = c.id_curso GROUP BY c.id_curso, c.nome;
C) SELECT c.nome, COUNT(*) FROM curso c JOIN matricula m ON m.fk_curso = c.id_curso GROUP BY c.id_curso, c.nome;
D) SELECT c.nome, COUNT(m.fk_ra) FROM matricula m LEFT JOIN curso c ON c.id_curso = m.fk_curso GROUP BY c.id_curso, c.nome;
E) SELECT c.nome, COUNT(DISTINCT c.id_curso) FROM curso c LEFT JOIN matricula m ON m.fk_curso = c.id_curso GROUP BY c.id_curso, c.nome;
```

**Gabarito:** correta: A

**Explicação:** O LEFT JOIN a partir de curso mantém Francês com uma linha de colunas NULL, e COUNT(m.fk_ra) ignora esse NULL e dá 0. COUNT(*) conta essa linha e mostra 1, e o JOIN e o LEFT JOIN a partir de matricula nem trazem Francês.

### Q22 · multiple_answer · difícil

- Subassunto: Subqueries e comparação com JOIN
- Comparação de queries: sim

**Enunciado**

```text
produto tem 1 (Mouse), 2 (Teclado) e 3 (Monitor), e item (fkVenda, fkProduto) tem (1, 1), (2, 1) e (2, 3). A query SELECT nome FROM produto WHERE idProduto IN (SELECT fkProduto FROM item); devolve Mouse e Monitor. Assinale todas as queries equivalentes a ela.
```

**Alternativas**

```text
A) SELECT p.nome FROM produto p JOIN item i ON i.fkProduto = p.idProduto;
B) SELECT nome FROM produto p WHERE EXISTS (SELECT 1 FROM item i WHERE i.fkProduto = p.idProduto);
C) SELECT nome FROM produto WHERE idProduto NOT IN (SELECT fkProduto FROM item);
D) SELECT p.nome FROM produto p LEFT JOIN item i ON i.fkProduto = p.idProduto WHERE i.fkProduto IS NULL;
E) SELECT DISTINCT p.nome FROM produto p JOIN item i ON i.fkProduto = p.idProduto;
```

**Gabarito:** corretas: B, E

**Explicação:** EXISTS correlacionado devolve cada produto uma vez, como o IN, e o JOIN só fica equivalente com DISTINCT, pois sem ele repete o Mouse, vendido duas vezes. NOT IN e LEFT JOIN ... IS NULL fazem o contrário e devolvem o Teclado.

### Q23 · drag_and_drop · difícil

- Subassunto: Agregação, GROUP BY e HAVING
- Comparação de queries: sim

**Enunciado (slots)**

```text
Com o banco vendas_funcoes no MySQL 8, associe cada query ao resultado: SELECT vendedor, COUNT(*) FROM venda WHERE COUNT(*) > 2 GROUP BY vendedor; {{s1}}. SELECT categoria, nome, COUNT(*) FROM produto GROUP BY categoria; {{s2}}. SELECT vendedor, COUNT(*) FROM venda GROUP BY vendedor HAVING COUNT(*) > 2; {{s3}}. SELECT categoria, COUNT(*) FROM produto WHERE preco > 100 GROUP BY categoria HAVING COUNT(*) >= 2; {{s4}}.
```

**Termos para arrastar**

```text
- Ana Souza (5) e Bruno Lima (3)
- Todas as categorias, com um nome qualquer
- Erro 1055: nome não está no GROUP BY
- Periféricos, Monitores e Computadores
- Os quatro vendedores, com a contagem de vendas
- Erro 1111: uso inválido de função de grupo
```

**Gabarito:** s1: Erro 1111: uso inválido de função de grupo, s2: Erro 1055: nome não está no GROUP BY, s3: Ana Souza (5) e Bruno Lima (3), s4: Periféricos, Monitores e Computadores

**Explicação:** Agregação no WHERE dá o erro 1111, porque o WHERE roda antes do GROUP BY, e coluna solta fora do GROUP BY dá o erro 1055 no MySQL 8. O HAVING filtra os grupos depois de formados, e o WHERE pode descartar linhas antes de agrupar.

### Q24 · multiple_choice · difícil

- Subassunto: Subqueries e comparação com JOIN
- Comparação de queries: sim

**Enunciado**

```text
A tabela item tem 20 linhas de 12 vendas diferentes, e a soma da coluna quantidade é 37. Query A: SELECT AVG(total) FROM (SELECT fkVenda, SUM(quantidade) AS total FROM item GROUP BY fkVenda); Query B: SELECT AVG(total) FROM (SELECT fkVenda, SUM(quantidade) AS total FROM item GROUP BY fkVenda) AS t; O que acontece no MySQL?
```

**Alternativas**

```text
A) As duas devolvem 3.0833, a média de peças por venda
B) As duas devolvem 1.8500, a média de peças por item
C) A devolve 3.0833 e B dá erro, pois AS não vale no FROM
D) A dá erro de alias e B devolve 1.8500, a média por item
E) A dá erro, pois falta o alias, e B devolve 3.0833
```

**Gabarito:** correta: E

**Explicação:** No MySQL, toda subquery no FROM (tabela derivada) precisa de alias, senão dá o erro 1248. Com o alias, a média é feita sobre os 12 totais por venda: 37 / 12 = 3.0833.

### Q25 · single_choice · difícil

- Subassunto: Funções numéricas, de texto e de data
- Comparação de queries: sim

**Enunciado (lacunas)**

```text
Para o vendedor 'Carla Mendes', SUBSTRING(vendedor, 1, LOCATE(' ', vendedor) - 1) devolve {{b1}} e SUBSTRING(vendedor, LOCATE(' ', vendedor)) devolve {{b2}}. Se o vendedor fosse só 'Mariana', sem espaço, LOCATE(' ', vendedor) devolveria {{b3}} e a primeira expressão devolveria {{b4}}.
```

**Opções de cada lacuna**

```text
b1: 'Carla' | 'Carla ' (com o espaço) | 'Carl'
b2: 'Mendes' | ' Mendes' (com o espaço) | 'Carla Mendes'
b3: 0 | NULL | -1
b4: um texto vazio ('') | 'Mariana' | NULL
```

**Gabarito:** b1: 'Carla', b2: ' Mendes' (com o espaço), b3: 0, b4: um texto vazio ('')

**Explicação:** LOCATE acha o espaço na posição 6: cortar até a posição 5 dá 'Carla', e começar na 6 inclui o espaço. Sem espaço, LOCATE devolve 0, e SUBSTRING com tamanho -1 devolve texto vazio, não o nome inteiro.

### Q26 · drag_and_drop · difícil

- Subassunto: Views
- Comparação de queries: sim

**Enunciado (slots)**

```text
Considere vw_monitor AS SELECT idProduto, nome, preco FROM produto WHERE categoria = 'Monitores' e vw_qtd_categoria AS SELECT categoria, COUNT(*) AS qtd FROM produto GROUP BY categoria. Associe cada comando ao resultado: UPDATE vw_monitor SET preco = 809.10 WHERE idProduto = 3; {{s1}}. DELETE FROM vw_qtd_categoria WHERE categoria = 'Acessórios'; {{s2}}. CREATE VIEW vw_monitor AS SELECT idProduto, nome FROM produto; {{s3}}. ALTER VIEW vw_monitor AS SELECT idProduto, nome, preco, categoria FROM produto WHERE categoria = 'Monitores'; {{s4}}.
```

**Termos para arrastar**

```text
- Erro 1050: a view já existe
- Muda só a view; produto fica igual
- Muda o preço do produto 3 na tabela produto
- Redefine a view, que passa a ter 4 colunas
- Apaga os produtos de Acessórios da tabela
- Erro 1288: a view não é atualizável
```

**Gabarito:** s1: Muda o preço do produto 3 na tabela produto, s2: Erro 1288: a view não é atualizável, s3: Erro 1050: a view já existe, s4: Redefine a view, que passa a ter 4 colunas

**Explicação:** Sem GROUP BY, a view repassa o UPDATE para a tabela de origem; com GROUP BY, UPDATE e DELETE dão o erro 1288. CREATE VIEW falha se a view já existe, e ALTER VIEW é o comando para redefinir o SELECT.

### Q27 · multiple_choice · difícil

- Subassunto: Relacionamento N:M e tabela associativa
- Comparação de queries: sim

**Enunciado**

```text
A tabela matricula (fk_ra, fk_curso) tem as linhas (1000, 1), (1000, 2), (1001, 1), (1001, 3) e (1002, 2), em que 1 é Espanhol, 2 é Inglês e 3 é Francês. Qual query lista o ra dos alunos matriculados em Espanhol e também em Inglês?
```

**Alternativas**

```text
A) SELECT fk_ra FROM matricula WHERE fk_curso = 1 AND fk_curso = 2;
B) SELECT DISTINCT fk_ra FROM matricula WHERE fk_curso IN (1, 2);
C) SELECT fk_ra FROM matricula WHERE fk_curso IN (1, 2) GROUP BY fk_ra HAVING COUNT(*) = 2;
D) SELECT fk_ra FROM matricula GROUP BY fk_ra HAVING COUNT(*) = 2;
E) SELECT fk_ra FROM matricula WHERE fk_curso = 1 OR fk_curso = 2 GROUP BY fk_ra HAVING COUNT(*) >= 1;
```

**Gabarito:** correta: C

**Explicação:** Cada matrícula é uma linha, então nenhuma linha tem fk_curso 1 e 2 ao mesmo tempo, e A vem vazia. Filtrar os dois cursos e exigir 2 linhas por aluno devolve só 1000; sem o WHERE, 1001 também entra por ter Espanhol e Francês.

### Q28 · multiple_choice · difícil

- Subassunto: Tratamento de nulos e condicionais
- Comparação de queries: sim

**Enunciado**

```text
Os preços dos 10 produtos de vendas_funcoes são 29.90, 129.90, 159.90, 199.90, 239.90, 349.90, 899.00, 1599.90, 2899.50 e 5499.00. Query A: SELECT nome, CASE WHEN preco < 200 THEN 'Barato' WHEN preco < 1000 THEN 'Médio' ELSE 'Caro' END AS faixa FROM produto; Query B: SELECT nome, CASE WHEN preco < 1000 THEN 'Médio' WHEN preco < 200 THEN 'Barato' ELSE 'Caro' END AS faixa FROM produto; Quantos produtos ficam na faixa 'Barato' em cada query?
```

**Alternativas**

```text
A) A: 4 e B: 4, pois a ordem dos WHEN não muda o resultado
B) A: 4 e B: 0, pois o CASE para no primeiro WHEN verdadeiro
C) A: 3 e B: 0, pois 199.90 arredonda para 200 e vira Médio
D) A: 4 e B: 7, pois B testa os dois WHEN e fica com o último
E) A: 0 e B: 4, pois o CASE testa os WHEN de baixo para cima
```

**Gabarito:** correta: B

**Explicação:** O CASE testa as condições na ordem e para na primeira verdadeira. Em B, todo preço abaixo de 200 também é menor que 1000, então cai em 'Médio' antes de chegar ao WHEN de 'Barato'.

### Q29 · multiple_answer · difícil

- Subassunto: Subqueries e comparação com JOIN
- Comparação de queries: sim

**Enunciado**

```text
produto tem Fone (100, Áudio), Caixa de som (1000, Áudio), Webcam (300, Vídeo), Câmera (420, Vídeo) e Cabo (50, Cabos), e o preço médio geral é 374. Assinale todas as queries que listam só as categorias cujo preço médio é maior que o preço médio geral.
```

**Alternativas**

```text
A) SELECT categoria FROM produto GROUP BY categoria HAVING AVG(preco) > (SELECT AVG(preco) FROM produto);
B) SELECT categoria FROM produto WHERE preco > (SELECT AVG(preco) FROM produto) GROUP BY categoria;
C) SELECT categoria FROM (SELECT categoria, AVG(preco) AS media FROM produto GROUP BY categoria) AS t WHERE media > (SELECT AVG(preco) FROM produto);
D) SELECT categoria FROM produto GROUP BY categoria HAVING AVG(preco) > AVG(preco);
E) SELECT categoria FROM produto GROUP BY categoria HAVING preco > (SELECT AVG(preco) FROM produto);
```

**Gabarito:** corretas: A, C

**Explicação:** Só Áudio tem média (550) acima de 374: A compara a média do grupo com a subquery no HAVING e C faz o mesmo sobre a tabela derivada. B filtra produtos e traz também Vídeo (Câmera de 420), D compara o grupo com ele mesmo e E dá erro, pois preco não está no GROUP BY.

### Q30 · drag_and_drop · difícil

- Subassunto: Funções numéricas, de texto e de data
- Comparação de queries: sim

**Enunciado (slots)**

```text
A venda 4 foi em 2026-10-03, um sábado, e a sessão usa SET lc_time_names = 'pt_BR'. Associe cada expressão ao valor: WEEKDAY('2026-10-03') devolve {{s1}}; DAYOFWEEK('2026-10-03') devolve {{s2}}; DAYNAME('2026-10-03') devolve {{s3}}; DATEDIFF('2026-10-31', '2026-10-03') devolve {{s4}}.
```

**Termos para arrastar**

```text
- 7
- sábado
- -28
- 5
- 28
- 6
```

**Gabarito:** s1: 5, s2: 7, s3: sábado, s4: 28

**Explicação:** WEEKDAY começa em 0 na segunda (sábado é 5) e DAYOFWEEK começa em 1 no domingo (sábado é 7). DATEDIFF é positivo quando a primeira data é a maior: 28 dias.

## Exercícios 3: Desafio

### Q31 · multiple_choice · super difícil

- Subassunto: Subqueries e comparação com JOIN
- Comparação de queries: sim

**Enunciado**

```text
aluno tem Maria (1000), João (1001), Ana (1002) e Bia (1003), e monitoria (fk_ra) tem as linhas 1000 e NULL. Query A: SELECT nome FROM aluno WHERE ra IN (SELECT fk_ra FROM monitoria); Query B: SELECT nome FROM aluno WHERE ra NOT IN (SELECT fk_ra FROM monitoria); Query C: SELECT nome FROM aluno a WHERE NOT EXISTS (SELECT 1 FROM monitoria mo WHERE mo.fk_ra = a.ra); Query D: SELECT a.nome FROM aluno a LEFT JOIN monitoria mo ON mo.fk_ra = a.ra WHERE mo.fk_ra IS NULL; Quantas linhas cada query devolve?
```

**Alternativas**

```text
A) A: 1, B: 3, C: 3 e D: 3
B) A: 2, B: 0, C: 3 e D: 3
C) A: 1, B: 0, C: 3 e D: 4
D) A: 1, B: 3, C: 3 e D: 4
E) A: 1, B: 0, C: 3 e D: 3
```

**Gabarito:** correta: E

**Explicação:** O NULL não atrapalha o IN, que acha a Maria, mas derruba o NOT IN: ra <> NULL é desconhecido e nenhuma linha passa. NOT EXISTS e LEFT JOIN ... IS NULL ignoram o NULL e devolvem João, Ana e Bia.

### Q32 · multiple_answer · super difícil

- Subassunto: Subqueries e comparação com JOIN
- Comparação de queries: sim

**Enunciado**

```text
Em vendas_funcoes, os maiores preços por categoria são Periféricos 349.90 (Teclado), Monitores 1599.90 (Monitor 27 pol), Computadores 5499.00 (Notebook) e Acessórios 159.90 (Mochila), e o Fone Bluetooth, sem categoria, custa 199.90. Assinale todas as queries que listam categoria, nome e preço só do produto mais caro de cada categoria, sem o Fone.
```

**Alternativas**

```text
A) SELECT categoria, nome, MAX(preco) FROM produto GROUP BY categoria;
B) SELECT p.categoria, p.nome, p.preco FROM produto p WHERE p.preco = (SELECT MAX(p2.preco) FROM produto p2 WHERE p2.categoria = p.categoria);
C) SELECT p.categoria, p.nome, p.preco FROM produto p WHERE p.preco = (SELECT MAX(preco) FROM produto);
D) SELECT p.categoria, p.nome, p.preco FROM produto p JOIN (SELECT categoria, MAX(preco) AS maior FROM produto GROUP BY categoria) AS t ON t.categoria = p.categoria AND t.maior = p.preco;
E) SELECT p.categoria, p.nome, p.preco FROM produto p WHERE p.preco IN (SELECT MAX(preco) FROM produto GROUP BY categoria);
```

**Gabarito:** corretas: B, D

**Explicação:** A subquery correlacionada calcula o máximo da categoria de cada linha e a tabela derivada faz o mesmo com JOIN; nas duas, a comparação com categoria NULL falha e o Fone sai. A dá o erro 1055, C traz só o Notebook e E traz o Fone, porque 199.90 é o máximo do grupo NULL e o IN não olha a categoria.

### Q33 · multiple_choice · super difícil

- Subassunto: Agregação, GROUP BY e HAVING
- Comparação de queries: sim

**Enunciado**

```text
Em vendas_funcoes, Periféricos tem os preços 129.90, 349.90 e 239.90; Monitores, 899.00 e 1599.90; Computadores, 5499.00 e 2899.50; Acessórios, 29.90 e 159.90; e o Fone, sem categoria, custa 199.90. Query A: SELECT categoria, COUNT(*) FROM produto WHERE preco > 100 GROUP BY categoria; Query B: SELECT categoria, COUNT(*) FROM produto GROUP BY categoria HAVING MIN(preco) > 100; Quantas linhas cada uma devolve e onde aparece Acessórios?
```

**Alternativas**

```text
A) A: 5 linhas e B: 4; Acessórios só aparece em A, com 1
B) A: 4 linhas e B: 4; Acessórios não aparece em nenhuma
C) A: 5 linhas e B: 5; Acessórios aparece nas duas, com 1
D) A: 4 linhas e B: 5; Acessórios só aparece em B, com 2
E) A: 5 linhas e B: 4; Acessórios só aparece em B, com 2
```

**Gabarito:** correta: A

**Explicação:** O WHERE descarta só o cabo de 29.90 antes de agrupar, então Acessórios fica com 1 (a mochila) e o grupo NULL também entra. O HAVING olha o grupo inteiro: o menor preço de Acessórios é 29.90, então o grupo sai de B.

### Q34 · drag_and_drop · super difícil

- Subassunto: Tratamento de nulos e condicionais
- Comparação de queries: sim

**Enunciado (slots)**

```text
A venda 7 tem os itens Mochila (preço 159.90, quantidade 3, desconto 0), Fone (199.90, quantidade 2, desconto 15) e Mouse (129.90, quantidade 2, desconto NULL). Com FROM item i JOIN produto p, associe cada expressão ao valor: ROUND(SUM(p.preco * i.quantidade * (1 - i.desconto / 100)), 2) dá {{s1}}; ROUND(SUM(p.preco * i.quantidade * (1 - IFNULL(i.desconto, 0) / 100)), 2) dá {{s2}}; ROUND(SUM(p.preco * i.quantidade), 2) dá {{s3}}; FLOOR(SUM(p.preco * i.quantidade * (1 - IFNULL(i.desconto, 0) / 100))) dá {{s4}}.
```

**Termos para arrastar**

```text
- 1079.33
- NULL
- 819.53
- 1080
- 1139.30
- 1079
```

**Gabarito:** s1: 819.53, s2: 1079.33, s3: 1139.30, s4: 1079

**Explicação:** Sem IFNULL, a conta do Mouse vira NULL e o SUM a ignora, sobrando 479.70 + 339.83. Com IFNULL o Mouse entra com 259.80; sem desconto nenhum o total é 1139.30, e FLOOR leva 1079.33 para 1079.

### Q35 · multiple_choice · super difícil

- Subassunto: Views
- Comparação de queries: sim

**Enunciado**

```text
A view vw_aeroporto já existe e alimenta outro relatório. Um desenvolvedor quer redefini-la e tem duas opções. Comando A: CREATE VIEW vw_aeroporto AS SELECT e.sigla AS sigla_estado, a.sigla AS sigla_aeroporto, a.nome AS nome_aeroporto FROM aeroporto a JOIN cidade c ON c.id = a.id_cidade JOIN estado e ON e.id = c.id_estado; Comando B: o mesmo, mas com CREATE OR REPLACE VIEW. O que acontece com cada um?
```

**Alternativas**

```text
A) Os dois substituem a view antiga, pois CREATE VIEW também sobrepõe
B) A substitui a view antiga e B dá erro, pois REPLACE exige um DROP antes
C) A dá erro, pois a view já existe; B a substitui sem aviso e muda o relatório
D) Os dois dão erro, pois só ALTER VIEW pode mexer em uma view que já existe
E) B cria uma segunda view com o mesmo nome, e o outro relatório fica igual
```

**Gabarito:** correta: C

**Explicação:** CREATE VIEW falha com o erro 1050 quando o nome já existe, o que protege a view antiga. CREATE OR REPLACE sobrepõe sem perguntar, e é por isso que o material manda nunca usar REPLACE na criação.

### Q36 · multiple_answer · super difícil

- Subassunto: Relacionamento N:M e tabela associativa
- Comparação de queries: sim

**Enunciado**

```text
curso tem Espanhol (1), Inglês (2) e Francês (3), e matricula (fk_ra, fk_curso) tem (1000, 1), (1000, 2), (1001, 1) e (1002, 1); ninguém faz Francês. Assinale todas as queries que listam só os cursos com pelo menos um aluno matriculado.
```

**Alternativas**

```text
A) SELECT c.nome FROM curso c JOIN matricula m ON m.fk_curso = c.id_curso GROUP BY c.id_curso, c.nome HAVING COUNT(*) >= 1;
B) SELECT c.nome FROM curso c LEFT JOIN matricula m ON m.fk_curso = c.id_curso GROUP BY c.id_curso, c.nome HAVING COUNT(*) >= 1;
C) SELECT c.nome FROM curso c WHERE EXISTS (SELECT 1 FROM matricula m WHERE m.fk_curso = c.id_curso);
D) SELECT c.nome FROM curso c WHERE c.id_curso IN (SELECT fk_curso FROM matricula);
E) SELECT c.nome FROM curso c WHERE (SELECT COUNT(*) FROM matricula) >= 1;
```

**Gabarito:** corretas: A, C, D

**Explicação:** JOIN com GROUP BY, EXISTS correlacionado e IN chegam a Espanhol e Inglês. No LEFT JOIN, Francês vem com uma linha de NULLs que o COUNT(*) conta como 1, e em E a subquery não é correlacionada: conta a tabela toda e libera todos os cursos.

### Q37 · drag_and_drop · super difícil

- Subassunto: Subqueries e comparação com JOIN
- Comparação de queries: sim

**Enunciado (slots)**

```text
produto tem 1 Mouse (100), 2 Teclado (300), 3 Monitor (900) e 4 Cabo (20), e item (fkVenda, fkProduto) tem (1, 1), (1, 4), (2, 3), (3, 1) e (3, 2). Associe cada query ao número de linhas que ela devolve: SELECT nome FROM produto WHERE preco > (SELECT AVG(preco) FROM produto); {{s1}}. SELECT nome FROM produto p WHERE NOT EXISTS (SELECT 1 FROM item i WHERE i.fkProduto = p.idProduto); {{s2}}. SELECT fkVenda FROM item GROUP BY fkVenda HAVING COUNT(*) > (SELECT COUNT(*) FROM item) / 3; {{s3}}. SELECT p.nome FROM produto p JOIN item i ON i.fkProduto = p.idProduto; {{s4}}.
```

**Termos para arrastar**

```text
- 4
- 1
- 5
- 0
- 3
- 2
```

**Gabarito:** s1: 1, s2: 0, s3: 2, s4: 5

**Explicação:** A média é 330 e só o Monitor passa, e todo produto aparece em item, então NOT EXISTS não devolve nada. 5 / 3 dá 1.67 e só as vendas 1 e 3 têm 2 itens, enquanto o JOIN repete o Mouse e devolve 5 linhas.

### Q38 · multiple_choice · super difícil

- Subassunto: Funções numéricas, de texto e de data
- Comparação de queries: sim

**Enunciado**

```text
Com SET lc_time_names = 'pt_BR', um relatório formata a data '2026-10-03 16:30:00'. Query A: SELECT DATE_FORMAT('2026-10-03 16:30:00', '%d/%m/%Y %H:%i'); Query B: SELECT DATE_FORMAT('2026-10-03 16:30:00', '%d/%M/%Y %H:%m'); O que cada uma devolve?
```

**Alternativas**

```text
A) A: 03/10/2026 16:30; B: 03/10/2026 16:30, pois a caixa não importa
B) A: 03/10/2026 16:30; B: 03/outubro/2026 16:10
C) A: 03/10/2026 16:30; B: 03/outubro/2026 16:30
D) A: 03/10/2026 16:10; B: 03/outubro/2026 16:30
E) A: 03/10/2026 16:30; B: erro, pois %M não existe
```

**Gabarito:** correta: B

**Explicação:** %m é o mês com dois dígitos e %i são os minutos. Em B, %M pede o nome do mês (outubro), e %m no lugar dos minutos mostra o mês de novo, 10.

### Q39 · single_choice · super difícil

- Subassunto: Subqueries e comparação com JOIN
- Comparação de queries: sim

**Enunciado (lacunas)**

```text
venda tem (1, Ana), (2, Bruno) e (3, Ana), e item (fkVenda, quantidade) tem (1, 2), (1, 3) e (2, 1); a venda 3 não tem itens. Query A: SELECT v.vendedor, SUM(i.quantidade) FROM venda v JOIN item i ON i.fkVenda = v.idVenda GROUP BY v.vendedor; devolve {{b1}}. Query B: SELECT v.vendedor, (SELECT SUM(i.quantidade) FROM item i WHERE i.fkVenda = v.idVenda) AS pecas FROM venda v; devolve {{b2}}, e a venda 3 aparece com pecas igual a {{b3}}. Para B mostrar 0 nesse caso, a subquery deve ficar dentro de {{b4}}.
```

**Opções de cada lacuna**

```text
b1: 2 linhas: Ana 5 e Bruno 1 | 3 linhas: Ana 5, Bruno 1 e Ana 0 | 2 linhas: Ana 6 e Bruno 1
b2: 2 linhas, uma por vendedor | 3 linhas, uma por venda | 3 linhas, uma por item
b3: NULL | 0 | 5
b4: IFNULL(..., 0) | NULLIF(..., 0) | COUNT(...)
```

**Gabarito:** b1: 2 linhas: Ana 5 e Bruno 1, b2: 3 linhas, uma por venda, b3: NULL, b4: IFNULL(..., 0)

**Explicação:** O JOIN descarta a venda 3 e o GROUP BY junta as vendas da Ana. A subquery no SELECT roda para cada venda e, sem itens, o SUM devolve NULL, que o IFNULL troca por 0.

### Q40 · drag_and_drop · super difícil

- Subassunto: Agregação, GROUP BY e HAVING
- Comparação de queries: sim

**Enunciado (slots)**

```text
Em venda, Ana Souza vendeu em 28/09, 02/10, 04/10, 09/10 e 21/10; Bruno Lima, em 30/09, 07/10 e 16/10; Carla Mendes, em 03/10 e 10/10; e Diego Rocha, em 14/10 e 19/10, uma venda por dia. Associe cada query ao número de linhas: SELECT vendedor, COUNT(*) FROM venda GROUP BY vendedor; {{s1}}. SELECT MONTH(dataHora), COUNT(*) FROM venda GROUP BY MONTH(dataHora); {{s2}}. SELECT vendedor, MONTH(dataHora), COUNT(*) FROM venda GROUP BY vendedor, MONTH(dataHora); {{s3}}. SELECT DATE(dataHora), COUNT(*) FROM venda GROUP BY DATE(dataHora); {{s4}}.
```

**Termos para arrastar**

```text
- 6
- 12
- 8
- 4
- 2
- 10
```

**Gabarito:** s1: 4, s2: 2, s3: 6, s4: 12

**Explicação:** São 4 vendedores e 2 meses; com as duas colunas, cada combinação existente vira um grupo: Ana e Bruno em setembro e outubro, Carla e Diego só em outubro (6). Como cada venda foi em um dia diferente, DATE gera 12 grupos.

### Q41 · multiple_choice · super difícil

- Subassunto: Relacionamento N:M e tabela associativa
- Comparação de queries: sim

**Enunciado**

```text
Modelo A: matricula (fk_ra, fk_curso, data_inicio, nivel, PRIMARY KEY (fk_ra, fk_curso)). Modelo B: matricula (id INT PRIMARY KEY AUTO_INCREMENT, fk_ra, fk_curso, data_inicio, nivel). Em cada modelo, a secretaria executa duas vezes o INSERT da matrícula do aluno 1000 em Espanhol (curso 1) e depois SELECT COUNT(*) FROM matricula WHERE fk_curso = 1; O que acontece?
```

**Alternativas**

```text
A) Nos dois modelos o segundo INSERT falha e a contagem dá 1
B) Nos dois modelos o segundo INSERT é aceito e a contagem dá 2
C) No modelo A a contagem dá 2; no B, o segundo INSERT falha
D) No A o segundo INSERT falha e a contagem dá 1; no B dá 2
E) No modelo A a contagem dá 0, pois o erro desfaz os dois INSERT
```

**Gabarito:** correta: D

**Explicação:** Com a PK composta, o par (1000, 1) não pode se repetir e o segundo INSERT dá o erro 1062. Com um id artificial como PK, nada impede o vínculo duplicado, e a contagem de alunos do curso fica errada.

### Q42 · multiple_answer · super difícil

- Subassunto: Views
- Comparação de queries: sim

**Enunciado**

```text
Existem vw_vendas_vendedor AS SELECT vendedor, COUNT(*) AS vendas FROM venda GROUP BY vendedor e vw_vendas_ana AS SELECT idVenda, dataHora, vendedor FROM venda WHERE vendedor = 'Ana Souza'. Ana tem 5 vendas e Diego, 2. Assinale todas as corretas.
```

**Alternativas**

```text
A) DELETE FROM vw_vendas_vendedor WHERE vendedor = 'Diego Rocha'; apaga as 2 vendas do Diego
B) SELECT vendedor FROM vw_vendas_vendedor WHERE vendas > 2; devolve o mesmo que agrupar venda com HAVING COUNT(*) > 2
C) UPDATE vw_vendas_ana SET dataHora = '2026-10-02 10:00:00' WHERE idVenda = 3; altera a venda 3 na tabela venda
D) SELECT * FROM vw_vendas_vendedor WHERE COUNT(*) > 2; funciona, pois a view já está agrupada
E) Após o INSERT de mais uma venda da Ana na tabela venda, vw_vendas_vendedor mostra Ana com 6
```

**Gabarito:** corretas: B, C, E

**Explicação:** Para quem consulta a view, vendas é uma coluna comum, então o WHERE nela equivale ao HAVING na tabela, mas COUNT(*) no WHERE ainda dá o erro 1111. A view sem GROUP BY repassa o UPDATE para venda, a com GROUP BY recusa o DELETE (erro 1288), e as duas sempre leem os dados atuais.

### Q43 · multiple_choice · super difícil

- Subassunto: Agregação, GROUP BY e HAVING
- Comparação de queries: sim

**Enunciado**

```text
A tabela item (fkVenda, desconto) tem as linhas (1, NULL), (1, 0), (2, 10), (2, NULL), (3, NULL), (4, 6) e (4, 2). Query A: SELECT fkVenda FROM item GROUP BY fkVenda HAVING AVG(desconto) < 5; Query B: SELECT fkVenda FROM item GROUP BY fkVenda HAVING AVG(IFNULL(desconto, 0)) < 5; Quais vendas cada query devolve?
```

**Alternativas**

```text
A) A: 1 e 4; B: 1, 3 e 4
B) A: 1, 3 e 4; B: 1, 3 e 4
C) A: 1 e 4; B: 1, 2, 3 e 4
D) A: 1, 3 e 4; B: 1 e 4
E) A: 1 e 4; B: 1 e 4
```

**Gabarito:** correta: A

**Explicação:** Em A, a venda 3 tem média NULL, e NULL < 5 não é verdadeiro, enquanto a venda 2 tem média 10. Em B os nulos viram 0: a venda 3 passa com 0 e a venda 2 fica com exatamente 5, que não é menor que 5.

### Q44 · single_choice · super difícil

- Subassunto: Tratamento de nulos e condicionais
- Comparação de queries: sim

**Enunciado (lacunas)**

```text
Um dashboard calcula a taxa de conversão (compras / visitas) da tabela campanha (nome, visitas, cliques, compras), com as linhas ('Instagram', 200, 40, 10), ('Email', 0, 0, 0) e ('Site', NULL, 30, 5). Para o Site, 100 * compras / visitas devolve {{b1}}; COALESCE(visitas, cliques, 0) devolve {{b2}}; e IFNULL(visitas, cliques, 0) {{b3}}. Para o Email, o material recomenda dividir por {{b4}} para não dividir por zero.
```

**Opções de cada lacuna**

```text
b1: NULL | 0 | 500
b2: 30 | 0 | NULL
b3: dá erro, pois IFNULL aceita só 2 argumentos | devolve 30 | devolve 0
b4: NULLIF(visitas, 0) | IFNULL(visitas, 0) | COALESCE(visitas, 0)
```

**Gabarito:** b1: NULL, b2: 30, b3: dá erro, pois IFNULL aceita só 2 argumentos, b4: NULLIF(visitas, 0)

**Explicação:** Conta com NULL dá NULL, e COALESCE devolve o primeiro não nulo da lista (cliques, 30). IFNULL só aceita 2 argumentos, e NULLIF(visitas, 0) troca o zero por NULL, deixando a divisão segura.

### Q45 · drag_and_drop · super difícil

- Subassunto: Subqueries e comparação com JOIN
- Comparação de queries: sim

**Enunciado (slots)**

```text
aluno tem Maria, João, Ana e Bia; Maria e João têm 2 matrículas cada, Ana tem 1 e Bia nenhuma (5 matrículas, 4 alunos). Associe cada pergunta à query que a responde: alunos com pelo menos uma matrícula, sem repetir: {{s1}}; alunos sem matrícula: {{s2}}; alunos com mais matrículas que a média por aluno: {{s3}}; quantidade de matrículas de cada aluno, incluindo 0: {{s4}}.
```

**Termos para arrastar**

```text
- SELECT a.nome FROM aluno a JOIN matricula m ON m.fk_ra = a.ra
- SELECT a.nome, (SELECT COUNT(*) FROM matricula m WHERE m.fk_ra = a.ra) FROM aluno a
- SELECT a.nome FROM aluno a WHERE NOT EXISTS (SELECT 1 FROM matricula m WHERE m.fk_ra = a.ra)
- SELECT a.nome FROM aluno a WHERE a.ra <> (SELECT fk_ra FROM matricula)
- SELECT a.nome FROM aluno a WHERE EXISTS (SELECT 1 FROM matricula m WHERE m.fk_ra = a.ra)
- SELECT a.nome FROM aluno a WHERE (SELECT COUNT(*) FROM matricula m WHERE m.fk_ra = a.ra) > (SELECT COUNT(*) FROM matricula) / (SELECT COUNT(*) FROM aluno)
```

**Gabarito:** s1: SELECT a.nome FROM aluno a WHERE EXISTS (SELECT 1 FROM matricula m WHERE m.fk_ra = a.ra), s2: SELECT a.nome FROM aluno a WHERE NOT EXISTS (SELECT 1 FROM matricula m WHERE m.fk_ra = a.ra), s3: SELECT a.nome FROM aluno a WHERE (SELECT COUNT(*) FROM matricula m WHERE m.fk_ra = a.ra) > (SELECT COUNT(*) FROM matricula) / (SELECT COUNT(*) FROM aluno), s4: SELECT a.nome, (SELECT COUNT(*) FROM matricula m WHERE m.fk_ra = a.ra) FROM aluno a

**Explicação:** EXISTS e NOT EXISTS testam a presença de matrícula sem repetir o aluno, ao contrário do JOIN, que repete Maria e João. A média é 5 / 4 = 1.25, então só Maria e João passam; a subquery no SELECT conta 0 para Bia, e <> com subquery de várias linhas dá o erro 1242.
