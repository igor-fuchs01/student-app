# Sistemas Operacionais — questões da Sprint 3

Aula **Cliente/Servidor, Diagrama de Solução, Redes e SSH**: 45 questões sobre as aulas 08 (servidores e clientes), 09 (diagrama de solução),
10 (introdução a redes) e 12 (conexão SSH) de Introdução a Sistemas Operacionais. O foco são
**cenários práticos e comparação**: 37 das 45 questões partem de uma situação concreta
(comando e saída, linha de `ssh`, regra de redirecionamento, máquina e porta do diagrama, caso
LogiFast).

- Conteúdo de base: [`SO-transcricao-material.md`](SO-transcricao-material.md).
- Script de cadastro: [`SO-questoes-sprint3.sql`](SO-questoes-sprint3.sql).
- Simulado "SO - Sprint 3": [`SO-simulado-sprint3.sql`](SO-simulado-sprint3.sql) (30 questões, 60 minutos, nível médio).
- Os comandos Linux e as saídas mostradas nos enunciados foram conferidos no terminal (`ping -c 2`,
  `ip a`, `ssh -G`, `man ssh`, `curl`), inclusive o efeito do travessão "–p" e do `-P` maiúsculo no
  `ssh`. Os IPs dos enunciados são privados.

## Resumo

| Lista | Dificuldade | Questões | Tipos |
|---|---|---|---|
| Exercícios 1: Fundamentos | 9 fácil, 6 média | Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15 | 6 multiple_choice, 4 drag_and_drop, 2 single_choice, 3 multiple_answer |
| Exercícios 2: Aplicação | 15 difícil | Q16, Q17, Q18, Q19, Q20, Q21, Q22, Q23, Q24, Q25, Q26, Q27, Q28, Q29, Q30 | 6 multiple_choice, 3 multiple_answer, 4 drag_and_drop, 2 single_choice |
| Exercícios 3: Desafio | 15 super difícil | Q31, Q32, Q33, Q34, Q35, Q36, Q37, Q38, Q39, Q40, Q41, Q42, Q43, Q44, Q45 | 6 multiple_choice, 3 multiple_answer, 2 single_choice, 4 drag_and_drop |

| Subassunto | Questões | Total |
|---|---|---|
| Arquitetura cliente/servidor e servidores | Q1, Q6, Q11, Q15, Q19, Q23, Q30, Q35, Q43 | 9 |
| Diagrama de solução do projeto | Q2, Q9, Q14, Q20, Q26, Q29, Q38, Q44 | 8 |
| Endereçamento IP, DNS e DHCP | Q3, Q8, Q13, Q16, Q21, Q31, Q37, Q42 | 8 |
| Portas e comandos de rede | Q4, Q10, Q18, Q25, Q27, Q34, Q39 | 7 |
| SSH e shell remoto | Q5, Q28, Q41, Q45 | 4 |
| Redirecionamento de portas e comando ssh | Q7, Q12, Q17, Q22, Q24, Q32, Q33, Q36, Q40 | 9 |

Cenário prático: Q2, Q3, Q4, Q7, Q10, Q11, Q12, Q13, Q14, Q16, Q17, Q18, Q19, Q20, Q22, Q23, Q24, Q25, Q26, Q27, Q28, Q29, Q30, Q31, Q32, Q33, Q34, Q35, Q36, Q38, Q39, Q40, Q41, Q42, Q43, Q44, Q45.

Simulado (ordem de exibição): Q2, Q16, Q31, Q3, Q17, Q32, Q4, Q19, Q33, Q7, Q20, Q34, Q11, Q22, Q35, Q12, Q24, Q36, Q13, Q25, Q38, Q14, Q26, Q40, Q27, Q41, Q29, Q42, Q30, Q45.

## Exercícios 1: Fundamentos

### Q1 · multiple_choice · fácil

- Subassunto: Arquitetura cliente/servidor e servidores
- Cenário prático: não

**Enunciado**

```text
Na analogia da aula, o cliente faz o pedido ao garçom, que o leva à cozinha e traz o prato de volta. No acesso a um site, o que corresponde à cozinha?
```

**Alternativas**

```text
A) O navegador do usuário
B) A rede que leva o pedido
C) O servidor web (web server)
D) O cabo de rede do cliente
E) O teclado de quem digita
```

**Gabarito:** correta: C

**Explicação:** O cliente pede, a rede leva o pedido como o garçom e o servidor web prepara e devolve a resposta, como a cozinha. O navegador é o cliente.

### Q2 · drag_and_drop · fácil

- Subassunto: Diagrama de solução do projeto
- Cenário prático: sim

**Enunciado (slots)**

```text
Ordene as etapas do diagrama de solução do projeto, do sensor até a dashboard: 1ª {{s1}}; 2ª {{s2}}; 3ª {{s3}}; 4ª {{s4}}; 5ª {{s5}}; 6ª {{s6}}.
```

**Termos para arrastar**

```text
- Armazenamento de dados
- Visualização no Serial Plotter
- Seleção de dados no BD
- Captura de dados
- Visualização de dados
- Inserção de dados no BD
- Guarda em cache
- Transformação em gráficos
```

**Gabarito:** s1: Captura de dados, s2: Inserção de dados no BD, s3: Armazenamento de dados, s4: Seleção de dados no BD, s5: Transformação em gráficos, s6: Visualização de dados

**Explicação:** O Arduino captura, o Node insere no MySQL, que armazena; depois o Node seleciona os dados, o HTML/CSS/JS os transforma em gráficos e o cliente os visualiza. Serial Plotter e cache eram o cenário antigo, sem armazenamento.

### Q3 · multiple_choice · fácil

- Subassunto: Endereçamento IP, DNS e DHCP
- Cenário prático: sim

**Enunciado**

```text
Um funcionário da LogiFast digita intranet.logifast.local no navegador. Antes de acessar o servidor, o computador precisa descobrir o IP que corresponde a esse nome. Qual serviço faz essa tradução?
```

**Alternativas**

```text
A) DHCP
B) DNS
C) SSH
D) FTP
E) RDP
```

**Gabarito:** correta: B

**Explicação:** O DNS funciona como um apelido para o IP: recebe o nome e devolve o endereço. O DHCP entrega IPs aos dispositivos, mas não traduz nomes.

### Q4 · single_choice · fácil

- Subassunto: Portas e comandos de rede
- Cenário prático: sim

**Enunciado (lacunas)**

```text
A LogiFast vai liberar no servidor só as portas necessárias. O site interno usa HTTPS na porta {{b1}}, o banco MySQL escuta na porta {{b2}} e o acesso remoto por SSH usa a porta {{b3}}.
```

**Opções de cada lacuna**

```text
b1: 80 | 443 | 8080
b2: 5432 | 1433 | 3306
b3: 22 | 23 | 21
```

**Gabarito:** b1: 443, b2: 3306, b3: 22

**Explicação:** HTTPS usa a 443 (HTTP usa 80 ou 8080), o MySQL usa a 3306 (5432 é PostgreSQL e 1433, SQL Server) e o SSH usa a 22 (23 é Telnet e 21, FTP).

### Q5 · multiple_answer · fácil

- Subassunto: SSH e shell remoto
- Cenário prático: não

**Enunciado**

```text
Sobre o SSH (Secure Shell), assinale todas as corretas.
```

**Alternativas**

```text
A) É um protocolo que define a comunicação segura entre máquinas
B) É um software de servidor web que hospeda páginas na porta 80
C) Seus pilares são autenticação, criptografia e integridade
D) Dispensa servidor: as duas máquinas atuam só como clientes
E) Usa três tipos de chave: do usuário, do host e de sessão
```

**Gabarito:** corretas: A, C, E

**Explicação:** SSH é um protocolo de comunicação segura, baseado em cliente/servidor, com os pilares autenticação, criptografia e integridade e as chaves do usuário, do host e de sessão. Servidor web é outra coisa.

### Q6 · multiple_choice · fácil

- Subassunto: Arquitetura cliente/servidor e servidores
- Cenário prático: não

**Enunciado**

```text
Qual alternativa lista as características de um servidor apresentadas na aula?
```

**Alternativas**

```text
A) Escalabilidade, manutenção, centralização e segurança
B) Processamento, armazenamento, sobrecarga e complexidade
C) HTTP, HTTPS, hospedagem de sites e várias requisições
D) Autenticação, criptografia, integridade e disponibilidade
E) Processamento, armazenamento, conectividade e disponibilidade
```

**Gabarito:** correta: E

**Explicação:** As características do servidor são processamento de dados, armazenamento, conectividade de rede, confiabilidade e disponibilidade. As outras listas misturam vantagens e desafios da arquitetura, o servidor web e os pilares do SSH.

### Q7 · drag_and_drop · fácil

- Subassunto: Redirecionamento de portas e comando ssh
- Cenário prático: sim

**Enunciado (slots)**

```text
Complete a tabela de redirecionamento de portas do VirtualBox para acessar a VM a partir do host. Regra SSH: porta do hospedeiro {{s1}} e porta do convidado {{s2}}. Regra Conexão MySQL: porta do hospedeiro {{s3}} e porta do convidado {{s4}}.
```

**Termos para arrastar**

```text
- 3306
- 22
- 5432
- 2222
- 23
- 3307
```

**Gabarito:** s1: 2222, s2: 22, s3: 3307, s4: 3306

**Explicação:** O hospedeiro é o computador físico e o convidado é a VM: quem chega na 2222 do host vai para a 22 (SSH) da VM, e quem chega na 3307 do host vai para a 3306 (MySQL) da VM.

### Q8 · multiple_choice · fácil

- Subassunto: Endereçamento IP, DNS e DHCP
- Cenário prático: não

**Enunciado**

```text
Comparando IPv4 e IPv6, qual alternativa está correta?
```

**Alternativas**

```text
A) IPv4: 32 bits, 4 grupos de 8 bits, decimal; IPv6: 128 bits, 8 grupos de 16 bits, hexadecimal
B) IPv4: 32 bits, 4 grupos de 16 bits, decimal; IPv6: 128 bits, 8 grupos de 16 bits, hexadecimal
C) IPv4: 32 bits, 4 grupos de 8 bits, decimal; IPv6: 64 bits, 8 grupos de 8 bits, hexadecimal
D) IPv4: 32 bits, 4 grupos de 8 bits, hexadecimal; IPv6: 128 bits, 8 grupos de 16 bits, decimal
E) IPv4: 64 bits, 4 grupos de 16 bits, decimal; IPv6: 128 bits, 16 grupos de 8 bits, hexadecimal
```

**Gabarito:** correta: A

**Explicação:** O IPv4 tem 32 bits divididos em 4 octetos, escritos em decimal; o IPv6 tem 128 bits divididos em 8 grupos de 16 bits, escritos em hexadecimal.

### Q9 · drag_and_drop · fácil

- Subassunto: Diagrama de solução do projeto
- Cenário prático: não

**Enunciado (slots)**

```text
Associe cada etapa do diagrama de solução à tecnologia usada: captura de dados {{s1}}; inserção e seleção no BD {{s2}}; armazenamento {{s3}}; transformação em gráficos {{s4}}.
```

**Termos para arrastar**

```text
- MySQL
- Serial Plotter
- HTML, CSS e JS
- Arduino
- Navegador do cliente
- Node.js
```

**Gabarito:** s1: Arduino, s2: Node.js, s3: MySQL, s4: HTML, CSS e JS

**Explicação:** O Arduino lê o sensor, o Node.js faz o INSERT e o SELECT, o MySQL guarda os dados e o HTML, CSS e JS montam os gráficos que o navegador do cliente exibe.

### Q10 · drag_and_drop · média

- Subassunto: Portas e comandos de rede
- Cenário prático: sim

**Enunciado (slots)**

```text
Um técnico usa Windows na mesa e Linux na VM do servidor. Associe cada comando do Windows ao equivalente no Linux: ipconfig {{s1}}; tracert {{s2}}; nslookup {{s3}}; ping {{s4}}.
```

**Termos para arrastar**

```text
- dig
- curl
- ping
- ip
- whois
- traceroute
```

**Gabarito:** s1: ip, s2: traceroute, s3: dig, s4: ping

**Explicação:** ipconfig e ip mostram a configuração de rede, tracert e traceroute mostram a rota, nslookup e dig consultam o DNS, e ping tem o mesmo nome nos dois. curl transfere dados e whois consulta registros de domínio.

### Q11 · multiple_choice · média

- Subassunto: Arquitetura cliente/servidor e servidores
- Cenário prático: sim

**Enunciado**

```text
Uma loja virtual concentra estoque e pedidos num único servidor. Na Black Friday, os acessos triplicam, as páginas demoram a carregar e algumas compras falham. Qual desafio da arquitetura cliente/servidor ficou evidente e qual vantagem ajuda a resolvê-lo?
```

**Alternativas**

```text
A) Complexidade; resolve-se com a centralização dos dados
B) Segurança; resolve-se com a facilidade de manutenção
C) Disponibilidade; resolve-se tirando o servidor da rede
D) Sobrecarga do servidor; resolve-se com escalabilidade
E) Sobrecarga dos clientes; resolve-se trocando os navegadores
```

**Gabarito:** correta: D

**Explicação:** Com alta demanda o servidor fica sobrecarregado e o desempenho cai. A escalabilidade permite adicionar servidores conforme a demanda aumenta.

### Q12 · multiple_answer · média

- Subassunto: Redirecionamento de portas e comando ssh
- Cenário prático: sim

**Enunciado**

```text
Um aluno quer acessar, do terminal do seu host, a própria VM, com o usuário sptech e o redirecionamento SSH 2222 → 22. Assinale todas as linhas que abrem o shell da VM.
```

**Alternativas**

```text
A) ssh sptech@127.0.0.1 -P 2222
B) ssh sptech@127.0.0.1 -p 2222
C) ssh sptech@127.0.0.1 –p 2222
D) ssh -p 2222 sptech@127.0.0.1
E) ssh sptech@127.0.0.1 -p 22
```

**Gabarito:** corretas: B, D

**Explicação:** A porta vai com -p minúsculo e hífen comum, antes ou depois do destino. -P maiúsculo é outra opção, o travessão copiado do slide não é entendido como opção, e as duas tentam a porta 22 do host, que não é a da VM.

### Q13 · single_choice · média

- Subassunto: Endereçamento IP, DNS e DHCP
- Cenário prático: sim

**Enunciado (lacunas)**

```text
A LogiFast vai ligar em rede 80 computadores de escritório e um servidor de banco de dados. Os computadores dos funcionários devem receber IP por {{b1}}, porque isso {{b2}}. O servidor de banco deve usar {{b3}}, porque os outros computadores precisam encontrá-lo sempre no mesmo endereço.
```

**Opções de cada lacuna**

```text
b1: DHCP | DNS | IP fixo
b2: evita conflitos de IP e facilita o gerenciamento | traduz o nome do computador em IP | deixa a rede mais rápida que o IP fixo
b3: IP fixo | DHCP | DNS
```

**Gabarito:** b1: DHCP, b2: evita conflitos de IP e facilita o gerenciamento, b3: IP fixo

**Explicação:** Em redes grandes que não precisam de IP fixo, o DHCP distribui os endereços sem conflito e facilita o gerenciamento. Servidores e serviços que não podem mudar de endereço usam IP fixo.

### Q14 · multiple_choice · média

- Subassunto: Diagrama de solução do projeto
- Cenário prático: sim

**Enunciado**

```text
Na arquitetura implementada do projeto, onde roda cada API e em qual porta?
```

**Alternativas**

```text
A) Data Acquino na VM Linux, porta 3333; Web Data Viz na máquina de captura, porta 3300
B) As duas na VM Linux, nas portas 3300 e 3306, junto com o MySQL
C) Data Acquino na máquina de captura do cliente, porta 3300; Web Data Viz na VM Linux, porta 3333
D) Data Acquino no navegador do cliente, porta 3300; Web Data Viz no Arduino, porta 3333
E) Data Acquino na máquina de captura do cliente, porta 3333; Web Data Viz na VM Linux, porta 3300
```

**Gabarito:** correta: C

**Explicação:** A máquina de captura, instalada no cliente, roda o Arduino e a API Data Acquino na 3300. O servidor de BD e APP (VM Linux) roda o MySQL e a API Web Data Viz na 3333.

### Q15 · multiple_answer · média

- Subassunto: Arquitetura cliente/servidor e servidores
- Cenário prático: não

**Enunciado**

```text
Sobre servidor e servidor web, assinale todas as corretas.
```

**Alternativas**

```text
A) Servidor web é um software que hospeda sites e conversa com navegadores por HTTP/HTTPS
B) Servidor web e servidor físico são a mesma coisa, só com nomes diferentes
C) Uma VM pode ser servidor de banco de dados e também ser configurada como servidor web
D) HTTPS (Hypertext Transfer Protocol Secure) é a versão segura do HTTP
E) O servidor web só consegue atender uma requisição de cliente por vez
```

**Gabarito:** corretas: A, C, D

**Explicação:** O servidor (físico ou virtual) é o ambiente que fornece recursos, e o servidor web é o software que hospeda sites via HTTP/HTTPS; a mesma máquina pode ter vários papéis. O servidor web processa várias requisições ao mesmo tempo.

## Exercícios 2: Aplicação

### Q16 · multiple_choice · difícil

- Subassunto: Endereçamento IP, DNS e DHCP
- Cenário prático: sim

**Enunciado**

```text
Um técnico testa o servidor de pedidos pelo terminal Linux. O comando ping -c 2 pedidos.logifast.local devolve «ping: pedidos.logifast.local: Name or service not known». Logo depois, ping -c 2 192.168.0.20, o IP desse servidor, devolve «2 packets transmitted, 2 received, 0% packet loss». Qual é o diagnóstico?
```

**Alternativas**

```text
A) Falha de conectividade: o servidor de pedidos está desligado
B) Falha de resolução de nome (DNS): o servidor responde pelo IP
C) Falha de DHCP: o computador do técnico ficou sem endereço IP
D) Falha de porta: o SSH do servidor de pedidos está fechado
E) Falha de MAC: o getmac do técnico mostraria o problema
```

**Gabarito:** correta: B

**Explicação:** O servidor responde pelo IP, então há conectividade; o que falhou foi a tradução do nome em IP, que é papel do DNS.

### Q17 · multiple_answer · difícil

- Subassunto: Redirecionamento de portas e comando ssh
- Cenário prático: sim

**Enunciado**

```text
A colega Bia deixou a VM ligada em modo headless, com o redirecionamento SSH 2222 → 22. O host da Bia tem o IP 192.168.0.15 na rede da sala, e a VM dela usa internamente o IP 10.0.2.15. Do seu notebook, assinale todas as linhas que acessam a VM da Bia.
```

**Alternativas**

```text
A) ssh sptech@127.0.0.1 -p 2222
B) ssh sptech@192.168.0.15 -p 2222
C) ssh sptech@10.0.2.15 -p 2222
D) ssh -p 2222 sptech@192.168.0.15
E) ssh sptech@192.168.0.15 -p 22
```

**Gabarito:** corretas: B, D

**Explicação:** Para a VM de um colega usa-se o IP do host dele com a porta redirecionada, 2222. 127.0.0.1 é a sua própria máquina, o IP interno da VM não é alcançado de fora, e a porta 22 do host da Bia não é a da VM.

### Q18 · drag_and_drop · difícil

- Subassunto: Portas e comandos de rede
- Cenário prático: sim

**Enunciado (slots)**

```text
O time de infraestrutura monta a lista de portas que serão liberadas para cada serviço. Associe: SSH {{s1}}; Telnet {{s2}}; RDP (área de trabalho remota) {{s3}}; PostgreSQL {{s4}}; SQL Server {{s5}}.
```

**Termos para arrastar**

```text
- 3306
- 23
- 1433
- 22
- 25
- 5432
- 3389
```

**Gabarito:** s1: 22, s2: 23, s3: 3389, s4: 5432, s5: 1433

**Explicação:** SSH usa 22 e Telnet 23; o RDP usa 3389; PostgreSQL usa 5432 e SQL Server 1433. 3306 é do MySQL e 25, do SMTP.

### Q19 · multiple_choice · difícil

- Subassunto: Arquitetura cliente/servidor e servidores
- Cenário prático: sim

**Enunciado**

```text
Uma empresa tem uma VM Linux num servidor físico. Na VM rodam o MySQL e o Node.js com o web-data-viz, que entrega as páginas aos navegadores na porta 3333. Qual afirmação classifica corretamente as partes?
```

**Alternativas**

```text
A) A VM é o servidor web, e o Node.js é o servidor físico da empresa
B) O servidor físico é o servidor web, pois tem o processador e o disco
C) O MySQL é o servidor web, pois é ele que guarda os dados exibidos
D) O Node.js é o servidor web (software); a VM é um servidor com vários papéis
E) Só existe servidor web se o site usar HTTPS na porta 443
```

**Gabarito:** correta: D

**Explicação:** Servidor web é o software que hospeda o site e responde aos navegadores, aqui o Node.js com o web-data-viz. A VM é um servidor (virtual) que acumula os papéis de banco e de aplicação.

### Q20 · single_choice · difícil

- Subassunto: Diagrama de solução do projeto
- Cenário prático: sim

**Enunciado (lacunas)**

```text
Hoje o grupo mostra a temperatura do LM35 só no Serial Plotter do Arduino. Quando o Arduino é desligado, os dados {{b1}}, porque ficam só em {{b2}}. Para guardá-los de forma permanente, o Node.js faz {{b3}} no MySQL, e para montar a dashboard outro processo Node.js faz {{b4}}.
```

**Opções de cada lacuna**

```text
b1: se perdem | continuam no MySQL | vão para a VM
b2: cache | MySQL | disco da VM
b3: INSERT | SELECT | DELETE
b4: SELECT | INSERT | UPDATE
```

**Gabarito:** b1: se perdem, b2: cache, b3: INSERT, b4: SELECT

**Explicação:** Sem banco, os dados ficam em cache e não são armazenados de forma permanente. A inserção no BD usa INSERT e a seleção, que alimenta os gráficos, usa SELECT.

### Q21 · multiple_choice · difícil

- Subassunto: Endereçamento IP, DNS e DHCP
- Cenário prático: não

**Enunciado**

```text
Um IPv4 tem 32 bits. Quantos endereços diferentes ele permite?
```

**Alternativas**

```text
A) 2^32 = 4.294.967.296, cerca de 4,3 bilhões
B) 2^32 = 4.294.967, cerca de 4,3 milhões
C) 4 × 8 = 32 endereços em cada rede
D) 2^16 = 65.536, um para cada porta
E) 2^128, cerca de 340 undecilhões
```

**Gabarito:** correta: A

**Explicação:** Cada bit dobra as combinações: 32 bits dão 2^32 = 4.294.967.296 endereços. 2^128 é o total do IPv6.

### Q22 · drag_and_drop · difícil

- Subassunto: Redirecionamento de portas e comando ssh
- Cenário prático: sim

**Enunciado (slots)**

```text
Ordene os passos para acessar a sua VM Lubuntu pelo terminal do host, sem abrir a interface gráfica da VM: 1º {{s1}}; 2º {{s2}}; 3º {{s3}}; 4º {{s4}}.
```

**Termos para arrastar**

```text
- Executar ssh sptech@127.0.0.1 -p 2222
- Criar a regra SSH: hospedeiro 22, convidado 2222
- Digitar a senha do usuário sptech
- Criar a regra SSH: hospedeiro 2222, convidado 22
- Executar ssh sptech@127.0.0.1 -p 22
- Iniciar a VM em modo headless
```

**Gabarito:** s1: Criar a regra SSH: hospedeiro 2222, convidado 22, s2: Iniciar a VM em modo headless, s3: Executar ssh sptech@127.0.0.1 -p 2222, s4: Digitar a senha do usuário sptech

**Explicação:** Primeiro se cria o redirecionamento (2222 do host para 22 da VM), depois a VM é iniciada em headless e o ssh é executado no host com -p 2222, pedindo a senha do sptech. A regra invertida e a porta 22 não chegam à VM.

### Q23 · multiple_answer · difícil

- Subassunto: Arquitetura cliente/servidor e servidores
- Cenário prático: sim

**Enunciado**

```text
Uma escola passou a guardar as notas num servidor, acessado pelos computadores dos alunos. Assinale todas as que descrevem corretamente uma vantagem ou um desafio dessa escolha.
```

**Alternativas**

```text
A) Atualizar o sistema só no servidor, sem mexer nos computadores dos alunos, é facilidade de manutenção
B) Se o servidor cair, nenhum aluno vê as notas: é um desafio de disponibilidade
C) Centralizar as notas elimina a necessidade de proteger os dados que trafegam na rede
D) Adicionar outro servidor quando a escola crescer é um exemplo de escalabilidade
E) Cada aluno passa a ter sua própria cópia das notas, e isso é a centralização
```

**Gabarito:** corretas: A, B, D

**Explicação:** Manutenção no servidor, risco de indisponibilidade e escalar com mais servidores estão no material. Centralizar não elimina o desafio de segurança, e centralizar é justamente ter os dados num lugar só.

### Q24 · multiple_choice · difícil

- Subassunto: Redirecionamento de portas e comando ssh
- Cenário prático: sim

**Enunciado**

```text
Um aluno criou no VirtualBox a regra «SSH | TCP | porta do hospedeiro 22 | porta do convidado 2222» e executou ssh sptech@127.0.0.1 -p 2222 no host. O que acontece?
```

**Alternativas**

```text
A) Conecta normalmente, pois a ordem das portas na regra não importa
B) Conecta na VM, mas entra como root em vez de sptech
C) Falha só porque faltou a regra do MySQL, de 3307 para 3306
D) Funciona se o aluno trocar a opção para -P 2222, maiúsculo
E) Falha: as portas estão invertidas; o certo é hospedeiro 2222 e convidado 22
```

**Gabarito:** correta: E

**Explicação:** O ssh bate na 2222 do host, mas a regra só redireciona a 22 do host, e para a 2222 da VM, onde o SSH não escuta. O SSH da VM está na 22, então a regra certa é 2222 no hospedeiro e 22 no convidado.

### Q25 · single_choice · difícil

- Subassunto: Portas e comandos de rede
- Cenário prático: sim

**Enunciado (lacunas)**

```text
No Windows, para ver o endereço MAC da placa de rede, o técnico usa {{b1}}; para ver o endereço IPv4, a máscara de sub-rede e o gateway padrão, usa {{b2}}; e para ver a rota com a estatística de perda de pacotes em cada salto, usa {{b3}}.
```

**Opções de cada lacuna**

```text
b1: getmac | hostname | netstat
b2: ipconfig | getmac | nslookup
b3: pathping | tracert | ping
```

**Gabarito:** b1: getmac, b2: ipconfig, b3: pathping

**Explicação:** getmac mostra o MAC, ipconfig mostra a configuração IP do adaptador, e pathping combina ping e tracert com o relatório de perda e latência por salto.

### Q26 · drag_and_drop · difícil

- Subassunto: Diagrama de solução do projeto
- Cenário prático: sim

**Enunciado (slots)**

```text
Complete a arquitetura implementada do projeto. A captura de dados roda em {{s1}}; o armazenamento e a seleção rodam em {{s2}}; a dashboard é vista em {{s3}}. A API Data Acquino usa a porta {{s4}} e a API Web Data Viz, a porta {{s5}}.
```

**Termos para arrastar**

```text
- 3333
- Servidor de BD e APP (VM Linux)
- 3306
- Cliente (navegador)
- Máquina de captura no cliente
- 3300
- Servidor DNS
```

**Gabarito:** s1: Máquina de captura no cliente, s2: Servidor de BD e APP (VM Linux), s3: Cliente (navegador), s4: 3300, s5: 3333

**Explicação:** A captura (Arduino e Data Acquino, porta 3300) fica na máquina instalada no cliente; MySQL e Web Data Viz (porta 3333) ficam na VM Linux; o cliente vê a dashboard no navegador. 3306 é a porta do MySQL.

### Q27 · multiple_choice · difícil

- Subassunto: Portas e comandos de rede
- Cenário prático: sim

**Enunciado**

```text
No mesmo servidor 192.168.11.2 rodam um site em HTTP e o MySQL. Como o sistema operacional entrega cada conexão ao serviço certo?
```

**Alternativas**

```text
A) Por portas físicas diferentes da placa de rede, uma por serviço
B) Pelo DNS, que dá um nome diferente para cada serviço
C) Pela porta lógica, gerenciada pelo SO: :80 vai ao site e :3306 ao MySQL
D) Pelo DHCP, que entrega um IP diferente para cada serviço
E) Pelo MAC, pois cada serviço tem o seu endereço físico
```

**Gabarito:** correta: C

**Explicação:** Porta é um ponto virtual, baseado em software e gerenciado pelo SO, associado a um serviço: o endereço completo é IP mais porta, como 192.168.11.2:80.

### Q28 · multiple_answer · difícil

- Subassunto: SSH e shell remoto
- Cenário prático: sim

**Enunciado**

```text
A empresa vai mover o servidor de BD e APP para a cloud (TO BE), e o DBA vai administrá-lo do notebook dele por um shell remoto com SSH. Assinale todas as corretas.
```

**Alternativas**

```text
A) O DBA precisa saber o IP e a porta de destino do servidor
B) Com o SSH, a senha e os comandos trafegam criptografados
C) O SSH dispensa autenticação, pois a cloud já é segura
D) O notebook do DBA é o servidor SSH e a cloud é o cliente
E) A integridade garante que os dados não foram alterados no caminho
```

**Gabarito:** corretas: A, B, E

**Explicação:** Para o shell remoto é preciso o IP e a porta de destino, e o SSH protege a conexão com autenticação, criptografia e integridade. Quem pede a conexão (o notebook do DBA) é o cliente; a máquina na cloud é o servidor.

### Q29 · multiple_choice · difícil

- Subassunto: Diagrama de solução do projeto
- Cenário prático: sim

**Enunciado**

```text
A dashboard abre normalmente na porta 3333, mas os gráficos pararam de ser atualizados às 10h. No MySQL da VM, a última linha da tabela de leituras foi inserida às 10h. Em qual parte do diagrama está a falha mais provável?
```

**Alternativas**

```text
A) Na transformação em gráficos, feita em HTML, CSS e JS
B) Na captura ou na inserção: o Arduino ou a API Data Acquino parou
C) No armazenamento: o MySQL apagou as linhas inseridas depois das 10h
D) Na seleção: a API Web Data Viz deixou de fazer o SELECT
E) Na visualização: o navegador do cliente ficou sem cache
```

**Gabarito:** correta: B

**Explicação:** Se nada novo chega ao MySQL, o problema está antes do armazenamento: na captura (Arduino) ou na inserção (API Data Acquino, porta 3300). O site e a seleção continuam mostrando o que existe no banco.

### Q30 · drag_and_drop · difícil

- Subassunto: Arquitetura cliente/servidor e servidores
- Cenário prático: sim

**Enunciado (slots)**

```text
Associe cada situação à vantagem ou ao desafio da arquitetura cliente/servidor: o sistema ganha um segundo servidor para atender mais usuários {{s1}}; a correção do sistema é instalada só no servidor {{s2}}; um ataque tenta roubar os dados que trafegam entre cliente e servidor {{s3}}; com muitos acessos ao mesmo tempo, o servidor fica lento {{s4}}.
```

**Termos para arrastar**

```text
- Segurança
- Centralização de dados
- Sobrecarga dos servidores
- Escalabilidade
- Complexidade
- Facilidade de manutenção
```

**Gabarito:** s1: Escalabilidade, s2: Facilidade de manutenção, s3: Segurança, s4: Sobrecarga dos servidores

**Explicação:** Adicionar servidores conforme a demanda é escalabilidade; atualizar no servidor sem afetar os clientes é facilidade de manutenção; proteger os dados transmitidos é segurança; e a lentidão por alta demanda é sobrecarga.

## Exercícios 3: Desafio

### Q31 · multiple_choice · super difícil

- Subassunto: Endereçamento IP, DNS e DHCP
- Cenário prático: sim

**Enunciado**

```text
O professor rodou tracert moodle.sptech.school em dois momentos. Na primeira vez, o nome resolveu para um IP na AWS em Virgínia (EUA), com saltos acima de 100 ms; na segunda, para um IP de um datacenter da Microsoft em São Paulo, com saltos de 2 a 9 ms. O que explica a diferença?
```

**Alternativas**

```text
A) O DNS devolveu IPs diferentes para o mesmo nome, e a distância física aparece na latência
B) O DHCP trocou o IP do servidor do Moodle entre a primeira e a segunda medição
C) O tracert mede a velocidade do computador do aluno, e não o caminho até o destino
D) A porta 443 é mais rápida que a porta 80, e o HTTPS só foi usado na segunda vez
E) A primeira medição usou IPv6 e a segunda IPv4, que tem menos saltos até o destino
```

**Gabarito:** correta: A

**Explicação:** O nome é traduzido pelo DNS, que pode apontar para servidores diferentes; o tracert mostra cada salto com sua latência, e um destino fora do país tem tempos bem maiores.

### Q32 · multiple_answer · super difícil

- Subassunto: Redirecionamento de portas e comando ssh
- Cenário prático: sim

**Enunciado**

```text
O seu host tem o IP 192.168.0.10 e o do colega Caio, 192.168.0.22. As duas VMs têm as regras SSH 2222 → 22 e MySQL 3307 → 3306 e o usuário sptech. Assinale todas as corretas.
```

**Alternativas**

```text
A) ssh sptech@127.0.0.1 -p 2222, rodado no seu host, abre o shell da sua VM
B) ssh sptech@192.168.0.22 -p 2222, rodado no seu host, abre o shell da VM do Caio
C) ssh sptech@192.168.0.22 -p 3307, rodado no seu host, abre o shell da VM do Caio
D) ssh sptech@127.0.0.1 –p 2222, com travessão, conecta na sua VM pela porta 2222
E) ssh sptech@192.168.0.10 -p 2222, rodado no host do Caio, abre o shell da sua VM
```

**Gabarito:** corretas: A, B, E

**Explicação:** 127.0.0.1 é a própria máquina, e para a VM de outra pessoa usa-se o IP do host dela, sempre com a porta 2222. A 3307 leva ao MySQL, não ao SSH, e o travessão não é lido como opção, então o ssh tenta a porta 22.

### Q33 · single_choice · super difícil

- Subassunto: Redirecionamento de portas e comando ssh
- Cenário prático: sim

**Enunciado (lacunas)**

```text
O aluno copiou do slide a linha ssh sptech@127.0.0.1 –p 2222, com travessão, e recebeu «ssh: connect to host 127.0.0.1 port {{b1}}: Connection refused». Isso acontece porque o travessão {{b2}}. O comando certo usa {{b3}}.
```

**Opções de cada lacuna**

```text
b1: 22 | 2222 | 3306
b2: não é lido como opção, e o ssh usa a porta padrão | inverte as portas da regra de redirecionamento | só funciona com o P maiúsculo
b3: -p 2222, com hífen comum e p minúsculo | -P 2222, com hífen comum e P maiúsculo | –p 22, com travessão e a porta da VM
```

**Gabarito:** b1: 22, b2: não é lido como opção, e o ssh usa a porta padrão, b3: -p 2222, com hífen comum e p minúsculo

**Explicação:** O ssh só reconhece opções que começam com o hífen comum; com o travessão, «–p 2222» vira texto comum e a conexão vai para a porta padrão, 22, onde nada atende no host. -P maiúsculo é outra opção do ssh.

### Q34 · drag_and_drop · super difícil

- Subassunto: Portas e comandos de rede
- Cenário prático: sim

**Enunciado (slots)**

```text
Associe cada saída, obtida no terminal Linux da LogiFast, ao diagnóstico: «ping: erp.logifast.local: Name or service not known» {{s1}}; «2 packets transmitted, 0 received, 100% packet loss» ao pingar 192.168.0.30 {{s2}}; «64 bytes from 192.168.0.30: icmp_seq=1 ttl=64 time=0.412 ms» {{s3}}; «curl: (7) Failed to connect to 192.168.0.30 port 3333: Could not connect to server», com o ping no mesmo IP respondendo {{s4}}.
```

**Termos para arrastar**

```text
- O host responde, mas nada atende nessa porta
- Conflito de IP causado pelo DHCP
- Falha de DNS: o nome não foi resolvido
- MAC errado na placa de rede
- Conectividade ok com o host
- Falha de conectividade: o host não respondeu
```

**Gabarito:** s1: Falha de DNS: o nome não foi resolvido, s2: Falha de conectividade: o host não respondeu, s3: Conectividade ok com o host, s4: O host responde, mas nada atende nessa porta

**Explicação:** Name or service not known é falha na resolução do nome; 100% de perda é falta de resposta do host; a resposta do ping mostra conectividade; e, se o host responde mas a porta 3333 recusa, falta o serviço associado a essa porta.

### Q35 · multiple_choice · super difícil

- Subassunto: Arquitetura cliente/servidor e servidores
- Cenário prático: sim

**Enunciado**

```text
Um estagiário anotou sobre o servidor do projeto: (I) a VM Linux é um servidor virtual; (II) o Node.js com o web-data-viz é o servidor web; (III) o MySQL também é um servidor web, pois serve dados; (IV) a mesma VM cumpre mais de um papel. Quais anotações estão corretas?
```

**Alternativas**

```text
A) Apenas I e II
B) Apenas I, II e IV
C) Apenas II e III
D) Apenas III e IV
E) Todas as quatro
```

**Gabarito:** correta: B

**Explicação:** A VM é um servidor virtual que acumula os papéis de banco e de aplicação, e o servidor web é o software que entrega as páginas por HTTP. O MySQL fornece dados, mas não é servidor web.

### Q36 · drag_and_drop · super difícil

- Subassunto: Redirecionamento de portas e comando ssh
- Cenário prático: sim

**Enunciado (slots)**

```text
No host, um cliente MySQL vai acessar o banco da VM pela regra Conexão MySQL, e o terminal vai abrir o shell da mesma VM. Complete: o cliente MySQL usa o endereço {{s1}} e a porta {{s2}}; dentro da VM, o MySQL escuta na porta {{s3}}; e o ssh no host usa -p {{s4}}.
```

**Termos para arrastar**

```text
- 3306
- 10.0.2.15
- 2222
- 22
- 127.0.0.1
- 3307
- 5432
```

**Gabarito:** s1: 127.0.0.1, s2: 3307, s3: 3306, s4: 2222

**Explicação:** Do host, a VM é alcançada pelo próprio host (127.0.0.1) nas portas redirecionadas: 3307 leva à 3306 do MySQL na VM e 2222 leva à 22 do SSH. O IP interno da VM não é usado.

### Q37 · multiple_choice · super difícil

- Subassunto: Endereçamento IP, DNS e DHCP
- Cenário prático: não

**Enunciado**

```text
O endereço 192.168.0.228 é escrito em decimal, mas armazenado em binário. Qual é a representação binária correta?
```

**Alternativas**

```text
A) 11000000.10101000.00000000.11100010
B) 11000000.10100100.00000000.11100100
C) 11000001.10101000.00000000.11100100
D) 11000000.10101000.00000000.11100100
E) 1100000010101000.0000000011100100
```

**Gabarito:** correta: D

**Explicação:** Cada octeto vira 8 bits: 192 = 11000000, 168 = 10101000, 0 = 00000000 e 228 = 11100100. A última alternativa junta os bits em 2 grupos de 16, o que não é o formato do IPv4.

### Q38 · single_choice · super difícil

- Subassunto: Diagrama de solução do projeto
- Cenário prático: sim

**Enunciado (lacunas)**

```text
No AS IS, a captura roda no notebook (host) e o MySQL roda na VM Lubuntu do mesmo notebook, com a regra Conexão MySQL 3307 → 3306. A API Data Acquino, no host, se conecta ao banco em 127.0.0.1 na porta {{b1}}; dentro da VM, o MySQL escuta na porta {{b2}}; e a API Web Data Viz, que entrega a dashboard, escuta na porta {{b3}}.
```

**Opções de cada lacuna**

```text
b1: 3307 | 3306 | 3300
b2: 3306 | 3307 | 3333
b3: 3333 | 3300 | 443
```

**Gabarito:** b1: 3307, b2: 3306, b3: 3333

**Explicação:** Quem está no host chega ao MySQL da VM pela porta redirecionada do hospedeiro, 3307, que leva à 3306 do convidado. A Data Acquino usa a 3300 e a Web Data Viz, a 3333.

### Q39 · multiple_answer · super difícil

- Subassunto: Portas e comandos de rede
- Cenário prático: sim

**Enunciado**

```text
Num servidor Linux, um técnico precisa descobrir o IP de logifast.com.br, ver a rota até ele e conferir o IP da própria máquina. Assinale todas as escolhas corretas.
```

**Alternativas**

```text
A) host logifast.com.br ou dig logifast.com.br, para o IP do domínio
B) traceroute logifast.com.br, para a rota até o destino
C) ipconfig, para o IP da própria máquina no Linux
D) ip a, para o IP da própria máquina
E) getmac, para o IP da própria máquina
```

**Gabarito:** corretas: A, B, D

**Explicação:** No Linux, host e dig consultam o DNS, traceroute mostra a rota e ip a lista os endereços da máquina. ipconfig é do Windows, e getmac mostra o MAC, não o IP.

### Q40 · drag_and_drop · super difícil

- Subassunto: Redirecionamento de portas e comando ssh
- Cenário prático: sim

**Enunciado (slots)**

```text
O seu host tem o IP 192.168.0.10 e a sua VM tem o redirecionamento 2222 → 22; o host do colega, 192.168.0.22, tem a mesma regra. Associe cada linha executada no seu host ao resultado: ssh sptech@127.0.0.1 -p 2222 {{s1}}; ssh sptech@192.168.0.22 -p 2222 {{s2}}; ssh sptech@127.0.0.1 –p 2222, com travessão {{s3}}; ssh sptech@10.0.2.15 -p 2222 {{s4}}.
```

**Termos para arrastar**

```text
- Abre o MySQL da VM do colega
- Abre o shell da sua VM
- Tenta a porta 22 do seu host
- Abre o shell do host do colega
- Não chega à VM: é o IP interno dela
- Abre o shell da VM do colega
```

**Gabarito:** s1: Abre o shell da sua VM, s2: Abre o shell da VM do colega, s3: Tenta a porta 22 do seu host, s4: Não chega à VM: é o IP interno dela

**Explicação:** 127.0.0.1 com 2222 leva à sua VM, e o IP do host do colega com 2222 leva à VM dele. O travessão não é lido como opção, então o ssh tenta a 22 do seu host, e o IP interno da VM não é o endereço usado para acessá-la de fora.

### Q41 · multiple_choice · super difícil

- Subassunto: SSH e shell remoto
- Cenário prático: sim

**Enunciado**

```text
Na rede da sala, um atacante (I) tenta ler os pacotes de uma sessão SSH, (II) tenta alterar um comando no caminho e (III) tenta entrar no servidor com um usuário que não é dele. Qual pilar do SSH protege cada caso?
```

**Alternativas**

```text
A) I autenticação, II criptografia e III integridade
B) I integridade, II autenticação e III criptografia
C) I criptografia, II integridade e III autenticação
D) I criptografia, II autenticação e III integridade
E) I integridade, II criptografia e III autenticação
```

**Gabarito:** correta: C

**Explicação:** A criptografia garante a privacidade do que trafega, a integridade garante que os dados não foram alterados, e a autenticação confirma quem está se conectando.

### Q42 · multiple_choice · super difícil

- Subassunto: Endereçamento IP, DNS e DHCP
- Cenário prático: sim

**Enunciado**

```text
A LogiFast configurou IP fixo, à mão, em todos os 120 computadores. Após uma troca de máquinas, dois computadores ficaram com 192.168.0.50 e um deles perdeu a rede. Já o servidor de pedidos, que estava no DHCP, mudou de IP ao reiniciar e ninguém mais achou o sistema. Qual configuração resolve os dois problemas?
```

**Alternativas**

```text
A) IP fixo em todos, revisando a planilha de endereços à mão
B) DHCP em todos, inclusive no servidor de pedidos
C) DNS nos computadores e DHCP no servidor de pedidos
D) IP fixo nos computadores e DHCP no servidor de pedidos
E) DHCP nos computadores e IP fixo no servidor de pedidos
```

**Gabarito:** correta: E

**Explicação:** O DHCP evita conflitos de IP e facilita o gerenciamento dos computadores; o servidor, que não pode mudar de endereço, deve ter IP fixo.

### Q43 · multiple_answer · super difícil

- Subassunto: Arquitetura cliente/servidor e servidores
- Cenário prático: sim

**Enunciado**

```text
A LogiFast troca as planilhas copiadas por pendrive entre as mesas por um sistema cliente/servidor. Assinale todas as corretas.
```

**Alternativas**

```text
A) A mudança elimina o desafio de segurança, pois os dados ficam num lugar só
B) Os dados ficam centralizados no servidor, sem cópias desatualizadas nas mesas
C) Os computadores dos funcionários passam a ser clientes que fazem solicitações
D) Cada cliente precisa receber a atualização do sistema, o que dificulta a manutenção
E) Se o servidor ficar indisponível, ninguém acessa os dados: o risco se concentra
```

**Gabarito:** corretas: B, C, E

**Explicação:** Centralizar os dados acaba com as cópias desatualizadas, e os computadores viram clientes do servidor; em troca, a disponibilidade do servidor vira um ponto crítico. A segurança continua sendo um desafio, e a manutenção fica mais fácil, feita no servidor.

### Q44 · drag_and_drop · super difícil

- Subassunto: Diagrama de solução do projeto
- Cenário prático: sim

**Enunciado (slots)**

```text
No diagrama TO BE da aula de SSH, associe cada número ao que ele representa: (1) {{s1}}; (2) {{s2}}; (3) {{s3}}; (4) {{s4}}.
```

**Termos para arrastar**

```text
- Servidor de BD e APP, na cloud
- Servidor DNS da empresa
- Máquina Dev/BDA com shell remoto
- Captura, instalada no cliente
- Serial Plotter do Arduino
- Cliente que acessa pelo navegador
```

**Gabarito:** s1: Captura, instalada no cliente, s2: Servidor de BD e APP, na cloud, s3: Cliente que acessa pelo navegador, s4: Máquina Dev/BDA com shell remoto

**Explicação:** No TO BE, a captura (1) fica no cliente, o servidor de BD e APP (2) vai para a cloud, o cliente (3) acessa pelo navegador e a máquina Dev/BDA (4) administra o servidor por shell remoto.

### Q45 · multiple_choice · super difícil

- Subassunto: SSH e shell remoto
- Cenário prático: sim

**Enunciado**

```text
No desafio da aula, três colegas acessam por SSH a mesma VM do projeto, com os escopos front-end, back-end e admin. O admin executa reboot enquanto os outros dois ainda estão conectados. O que acontece?
```

**Alternativas**

```text
A) As sessões SSH dos três caem, pois a VM reinicia; é preciso reconectar quando ela voltar
B) Nada muda para os outros dois, pois cada sessão SSH roda numa VM separada
C) Só o admin é desconectado, pois o reboot vale apenas para quem o executou
D) A VM volta com interface gráfica, e o modo headless deixa de funcionar
E) O host de quem criou a regra 2222 → 22 é reiniciado junto com a VM
```

**Gabarito:** correta: A

**Explicação:** Os três shells remotos estão no mesmo servidor, a VM; o reboot reinicia a máquina inteira e derruba todas as sessões, que precisam ser abertas de novo pelo ssh.
