# Sistemas Operacionais — transcrição do material da Sprint 3

Base de conteúdo das questões da Sprint 3 de Introdução a Sistemas Operacionais
([`SO-questoes-sprint3.md`](SO-questoes-sprint3.md)). Reúne, por aula, o que os slides do
prof. Marcio Santana trazem, o que fica fora das questões e as pegadinhas usadas nas alternativas
erradas. Os slides de regras da sala, plano de aula e chamada foram ignorados. A aula 11 não faz
parte do material.

| Material | Tipo | Uso nas questões |
|---|---|---|
| Aula 08 — Servidores e Clientes | Slides | Conteúdo |
| Aula 09 — Diagrama de solução (Abstração) | Slides só com imagens | Conteúdo |
| Aula 10 — Introdução a redes | Slides | Conteúdo e saídas de comando |
| Aula 12 — Conexão SSH | Slides | Conteúdo e comandos `ssh` |

## 1. Aula 08 — Servidores e Clientes

### 1.1 Perguntas de abertura

Como é, tecnicamente, o processo para acessar um site como o YouTube? Quais são os elementos
principais? O que seria um servidor? Como é a interação entre cliente e servidor? Quais exemplos de
clientes e servidores usamos no dia a dia?

### 1.2 Analogia do restaurante

**Cliente → garçom → cozinha**: o cliente faz o pedido ao garçom, que o leva à cozinha e traz o
prato de volta. Na web: **cliente → rede → web server**. O servidor web "é como um garçom da
internet: você faz o pedido (acessa um site) e ele traz a informação certa para você".

### 1.3 Arquitetura cliente/servidor

- Modelo de computação que distribui as tarefas entre os dispositivos que **solicitam** recursos
  (**clientes**) e os que **fornecem** esses recursos (**servidores**).
- A comunicação geralmente ocorre por meio de uma **rede**, como a internet.
- O cliente envia uma **solicitação** ao servidor, que a **processa** e envia uma **resposta** de
  volta ao cliente.

| Vantagens | Desafios |
|---|---|
| **Escalabilidade**: adicionar clientes e servidores conforme a demanda aumenta | **Segurança**: proteger os dados transmitidos e os servidores contra ataques |
| **Facilidade de manutenção**: atualizar o servidor sem afetar diretamente os clientes | **Disponibilidade**: o servidor precisa estar acessível quando o cliente precisa |
| **Centralização de dados e recursos**: facilita o controle e a gestão | **Sobrecarga**: com alta demanda, o servidor fica sobrecarregado e o desempenho cai |
| | **Complexidade**: implementar e gerir é complexo em sistemas grandes e distribuídos |

O slide cita que 83% das companhias que sofreram ataques hackers no Brasil pagaram resgates em
2023, como exemplo do desafio de segurança.

### 1.4 O que é um servidor

- Características: **processamento de dados**, **armazenamento**, **conectividade de rede** e
  **confiabilidade e disponibilidade**.
- **Servidor (físico/lógico)**: ambiente que fornece serviços, recursos ou dados para outros
  computadores (clientes) em uma rede. Pode ser uma máquina física ou virtual.
- **Servidor web (lógico)**: **software** específico de servidor, projetado para hospedar sites e
  páginas web. Usa **HTTP** (Hypertext Transfer Protocol) e **HTTPS** (Hypertext Transfer Protocol
  Secure) para se comunicar com os navegadores; processa várias requisições simultaneamente,
  mantendo os sites acessíveis mesmo com tráfego intenso.
- Um servidor físico ou virtual **pode ser configurado com a função de servidor web**: o mesmo
  servidor pode ter vários papéis. Fluxo do slide: cliente → servidor físico ou virtual → servidor
  web.
- Perguntas do slide: "O que ele está servindo?" e "quem está servindo o site?" (a máquina e o
  software são coisas diferentes).
- A atividade prática da aula termina com a "arquitetura implementada" do projeto (detalhada na
  aula 09).

## 2. Aula 09 — Diagrama de solução (Abstração)

### 2.1 Ponto de partida: só o Arduino

- Antes, apenas o Arduino fazia a **captura** e a **visualização** dos dados.
- Os dados **não eram armazenados de forma permanente**: ficavam só em cache.
- O código em `void loop()` faz o papel de captura de dados.
- O **Serial Plotter** e o **Serial Monitor** fazem o papel de visualização.

### 2.2 Armazenamento permanente

- Em vez de manter em cache, os dados passam a ser armazenados de forma permanente, o que permite
  fazer tratamentos de dados.
- **Inserção no BD**: além de capturar, é preciso inserir no banco (`INSERT`), validar as
  credenciais de acesso e criar um fluxo contínuo de inserção.
- **Seleção no BD**: para visualizar, é preciso selecionar os dados (`SELECT`), validar as
  credenciais de acesso e criar um fluxo contínuo de seleção.
- **Transformação em gráficos**: os dados de uma tabela viram os gráficos que o cliente acessa; é
  preciso uma forma de transformá-los (frontend).

### 2.3 As 6 etapas e as tecnologias

| Etapa | O que faz | Tecnologia |
|---|---|---|
| 1. Captura de dados | Lê o sensor (LM35) | Arduino |
| 2. Inserção de dados no BD | `INSERT` com credenciais, em fluxo contínuo | Node.js |
| 3. Armazenamento de dados | Guarda os dados de forma permanente | MySQL |
| 4. Seleção de dados no BD | `SELECT` com credenciais, em fluxo contínuo | Node.js |
| 5. Transformação dos dados em gráficos | Monta os gráficos (frontend) | HTML, CSS e JS |
| 6. Visualização de dados | O cliente vê a dashboard | Navegador do cliente |

No exercício do barril (sensor LM35 → notebook com Arduino e Node → notebook com MySQL e Node numa
VM → cliente), a resolução preenche as caixas numeradas assim: 1º Captura de Dados; 2º e 3º
Visualização de Dados e Inserção de Dados no BD; 4º e 5º Armazenamento de Dados e Transformação dos
Dados em Gráficos; 6º Visualização da Dashboard. As questões usam a sequência de 6 etapas da
tabela acima, que é a do diagrama completo.

### 2.4 Arquitetura implementada

| Máquina | O que roda | Etapas |
|---|---|---|
| Máquina (servidor) de captura, **instalada no CLIENTE** | Arduino e Node.js (API Data Acquino, **porta 3300**) | Captura e inserção no BD |
| **Servidor de BD e APP (VM Linux)** | MySQL e Node.js (API Web Data Viz, **porta 3333**) | Armazenamento, seleção e transformação em gráficos |
| **CLIENTE** | Navegador (Chrome, Edge, Opera) | Visualização |

- O Node da máquina de captura envia os dados para o MySQL da VM; o Node da VM lê o MySQL e
  entrega o site ao navegador do cliente.
- Desafio: Equipe 1 integra a máquina de captura com o servidor (VM) de BD; Equipe 2 instala o
  site na VM; depois, integrar toda a solução.

## 3. Aula 10 — Introdução a redes

### 3.1 Caso LogiFast

A transportadora LogiFast tinha computadores que funcionavam bem sozinhos (entregas, pedidos,
relatórios), mas não "conversavam" entre si: um cliente perguntou pela encomenda e o atendente não
achou a informação, que estava em outro computador. Problemas: informações duplicadas, dados
desatualizados, funcionários andando de mesa em mesa com pendrive e retrabalho constante. "Temos
computadores… mas não temos conexão entre eles." Perguntas: como um computador encontra outro, como
a informação chega ao destino certo e por que às vezes funciona e às vezes não.

### 3.2 Endereçamento: IP = CEP e DNS

- Como o pacote dos Correios chega pelo CEP ao prédio e depois ao 11º andar, o dado chega a um
  dispositivo pelo **endereço IP**: **IP = CEP**.
- Ninguém decora o CEP de cada lugar: o **DNS** (Domain Name System) funciona como um "apelido"
  para o IP. Ao digitar `youtube.com`, o navegador consulta o DNS e é redirecionado para o IP do
  dispositivo que transmite a aplicação.
- Fluxo: você → navegador → pedido do nome ao **servidor DNS** → o DNS devolve o **IP** → o
  navegador acessa o **servidor web** nesse IP.
- O servidor DNS em uso aparece em `ipconfig /all` (ex.: `Servidores DNS: 8.8.8.8, 8.8.4.4,
  1.1.1.1`), junto com o endereço físico (MAC) e `DHCP Habilitado`.
- `tracert 8.8.8.8` mostra os saltos até `dns.google`: o primeiro salto (10.18.6.1) é o
  modem/roteador local, depois o provedor, a rede do provedor, o backbone e o destino, cada um com
  3 tempos de resposta em ms ("com no máximo 30 saltos").
- `tracert moodle.sptech.school` em dois momentos: uma vez o nome resolveu para um balanceador na
  AWS em Virgínia (EUA), com saltos acima de 100 ms; outra vez para um datacenter da Microsoft em
  São Paulo, com saltos de 2 a 9 ms. A distância física aparece na latência.

### 3.3 Estrutura do IP

| | IPv4 | IPv6 |
|---|---|---|
| Tamanho | 32 bits | 128 bits |
| Grupos | 4 grupos de 8 bits (octetos) | 8 grupos de 16 bits |
| Escrita | Decimal, separada por ponto | Hexadecimal, separada por dois-pontos |
| Exemplo | `192.168.0.228` | `fe80:0db8:c427:0000:f3d0:c427:5825:5bf4` |
| Endereços | 2^32 = 4.294.967.296 | 2^128 ≈ 340 undecilhões |

- O IP é escrito em decimal (ou hexadecimal), mas é armazenado e manipulado em binário:
  `192.168.0.228` = `11000000.10101000.00000000.11100100`.
- 2^128 = 340.282.366.920.938.463.463.374.607.431.768.211.456. Exemplo abreviado de IPv6 visto no
  slide: `fe80::637b:ef0d:cdd:20be%20`.

### 3.4 IP fixo × DHCP

| | IP fixo | DHCP |
|---|---|---|
| O que é | IP configurado diretamente no host | Protocolo (Dynamic Host Configuration Protocol) que entrega o IP automaticamente |
| Gerenciamento | Difícil | Fácil |
| Conflitos de IP | Podem acontecer | Não acontecem |
| Quando usar | Servidores e serviços que não podem mudar de IP | Grandes redes que não precisam de IP fixo |

### 3.5 Portas

- Porta é um **ponto virtual** onde começam e terminam as conexões de rede. É baseada em
  **software** e gerenciada pelo SO; cada porta está associada a um processo ou serviço.
- As portas separam os tipos de tráfego (e-mail numa porta, páginas web em outra). Endereço completo
  = IP + porta: `192.168.11.2:80`.

| Porta | Serviço |
|---|---|
| 21 | FTP |
| 22 | SSH |
| 23 | Telnet |
| 25 | SMTP |
| 80 / 8080 | HTTP |
| 443 | HTTPS |
| 1433 | SQL Server |
| 3306 | MySQL |
| 3389 | RDP |
| 5432 | PostgreSQL |

- **Portas dinâmicas: 49152 a 65535**, usadas por aplicativos personalizados sem conflitar com os
  processos existentes. No diagrama do slide, o MySQL local está em `127.0.0.1:3306`, os sites em
  `:443` e as conexões de saída do computador usam portas altas (`10.18.6.78:62099`).
- A tabela de redirecionamento do VirtualBox (aula 12) mostra o protocolo **TCP** nas regras.

### 3.6 Comandos de rede no Windows

| Comando | Para quê |
|---|---|
| `ipconfig` | Configuração IP: adaptadores, endereço IPv4, máscara de sub-rede, gateway padrão (`/all` mostra DNS, MAC e DHCP) |
| `ping` | Testa a conexão e o tempo de resposta: envia pacotes e, se tudo estiver ok, recebe de volta |
| `tracert` | Rota até o destino: cada salto com latência e IP |
| `pathping` | Combina `ping` e `tracert` e mostra um relatório estatístico de perda de pacotes e latência |
| `getmac` | Endereço **MAC** do dispositivo (padrão IEEE 802) |
| `hostname` | Nome do host |
| `nslookup` | Registros de DNS de um domínio, host ou IP; tem modo interativo e não interativo |
| `netstat` | Conexões ativas, protocolos TCP/UDP, IPs e portas, estatísticas |
| `systeminfo` | Informações completas do PC |

### 3.7 Comandos de rede no Linux (VM Lubuntu)

| Comando | Para quê |
|---|---|
| `ip` | Manipula o roteamento e configura parâmetros de rede (`ip a` lista os endereços) |
| `traceroute` | Rota dos pacotes até o host |
| `tracepath` | Rastreia o caminho e obtém a MTU (unidade máxima de transmissão) |
| `ping` | Verifica a conectividade com o servidor (no Linux, `-c` limita a quantidade de pacotes) |
| `dig` | Informações do servidor de nomes DNS |
| `host` | Imprime o IP de um domínio |
| `hostname` | Imprime e altera o nome do host |
| `curl` | Transfere dados pela rede, em vários protocolos |
| `whois` | Informações de domínios registrados, IPs e servidores de nomes |
| `ifplugstatus`, `iftop`, `ethtool`, `bmon`, `iperf`, `speedtest-cli` | Link, banda, configuração Ethernet e velocidade |
| `tcpdump` | Captura e analisa pacotes |
| `nmcli` | Solução de problemas de conexões de rede |
| `nmap` | Auditoria de segurança da rede |

Equivalências: `tracert` ↔ `traceroute`, `ipconfig` ↔ `ip`, `nslookup` ↔ `dig`/`host`; `ping` e
`hostname` têm o mesmo nome nos dois.

## 4. Aula 12 — Conexão SSH

### 4.1 AS IS × TO BE

- **AS IS**: servidor de captura (1) e servidor de BD e APP (2, VM Linux) no mesmo notebook; o
  cliente (3) acessa pelo navegador.
- **TO BE**: captura (1) instalada no cliente, servidor de BD e APP (2) em outra máquina e, na
  empresa, na **cloud**; o cliente (3) separado.
- Na empresa, a **máquina Dev/BDA (4)** acessa o servidor por um **shell remoto**: é preciso saber
  o **IP e a porta de destino**. Host local × remoto.

### 4.2 SSH (Secure Shell)

- **Protocolo** que define como conduzir a comunicação segura entre máquinas na internet.
- Três pilares: **autenticação**, **criptografia** (privacidade) e **integridade**.
- O método de conexão é baseado na arquitetura **cliente/servidor**.
- Tipos de chave: **chave do usuário** (user key), **chave do host** (host key) e **chave de
  sessão** (session key).

### 4.3 Redirecionamento de portas no virtualizador

Para acessar a VM remotamente, faz-se o redirecionamento de portas na camada do virtualizador:

| Nome | Protocolo | Porta do hospedeiro | Porta do convidado |
|---|---|---|---|
| Conexão MySQL | TCP | 3307 | 3306 |
| SSH | TCP | 2222 | 22 |

O hospedeiro (host) é o computador físico; o convidado (guest) é a VM. Quem chega na porta 2222 do
host é levado à porta 22 (SSH) da VM, e quem chega na 3307 do host, à 3306 (MySQL) da VM.

### 4.4 Comandos

- VM **local**, do terminal do seu host: `ssh sptech@127.0.0.1 -p 2222`.
- VM **remota** (no computador de um colega): troca-se pelo **IP da máquina host dele**:
  `ssh sptech@<ip_host_remoto> -p 2222`.
- No slide, o comando aparece com um travessão (`–p`). Copiado assim, o `ssh` não entende como
  opção: trata `–p 2222` como comando remoto e tenta a porta 22. O certo é o hífen comum, `-p`
  minúsculo (`-P` maiúsculo é outra opção no OpenSSH e também não muda a porta).
- **Início headless**: com o redirecionamento criado, inicia-se a VM sem abrir a interface gráfica
  (Iniciar → Início Headless) e o acesso é feito pelo terminal do host.

### 4.5 Prática e desafio

Um servidor de projeto (VM) acessado por SSH por três shells, cada um com um escopo:

| Escopo | Tarefas |
|---|---|
| Front-end | Criar `Desktop/frontend`, clonar o repositório web-data-viz e instalar as dependências |
| Back-end | Criar `Desktop/backend` e o arquivo `log.txt`; iniciar o web-data-viz e acessar pelo navegador da VM (lembrar do redirecionamento de porta) |
| Admin | Criar `Desktop/admin`, excluir `frontend` e `backend` e reiniciar a máquina (`reboot`) |

O acesso é feito ao usuário `sptech` da VM Lubuntu do colega, a partir do SO host da sua máquina.

## 5. O que não deve ser cobrado

- Sub-redes, CIDR, cálculo de máscara, classes de IP e modelo OSI. Máscara de sub-rede e gateway
  padrão só no nível de "aparecem na saída do `ipconfig`".
- Diferenças entre TCP e UDP além de "o protocolo das regras é TCP" e "o `netstat` mostra
  conexões TCP e UDP".
- Geração e troca de chaves SSH (`ssh-keygen`, `authorized_keys`), configuração do servidor SSH e
  opções do `ssh` além de `-p`.
- Detalhes dos comandos `ifplugstatus`, `iftop`, `ethtool`, `bmon`, `iperf`, `speedtest-cli`,
  `tcpdump` e `nmap` além da descrição de uma linha.
- Os IPs reais dos slides (provedores, Amazon, Microsoft) e a geolocalização de IPs.
- Os gráficos de evolução da internet IPv4/IPv6 (CAIDA).
- Conteúdo da aula 11, que não está no material.

## 6. Pegadinhas (para alternativas erradas)

- Servidor (máquina física ou virtual que fornece recursos) × servidor web (software, lógico, que
  hospeda sites via HTTP/HTTPS). Um mesmo servidor pode ter vários papéis (ex.: a VM é servidor de
  BD e de aplicação).
- Cliente/servidor: o cliente pede e o servidor responde; centralizar facilita a manutenção, mas
  concentra o risco (disponibilidade e sobrecarga).
- DNS traduz nome → IP; quem entrega o IP automaticamente é o DHCP. Os dois são confundidos.
- IPv4: 32 bits, 4 grupos de 8 bits, decimal. IPv6: 128 bits, 8 grupos de 16 bits, hexadecimal.
  Erros comuns: "IPv6 tem 64 bits", "IPv4 tem 4 grupos de 16 bits", "IPv6 é decimal".
- 2^32 = 4.294.967.296 (cerca de 4,3 bilhões), não 4,3 milhões nem 2^16.
- IP fixo é para servidores e serviços que não podem mudar de endereço; DHCP evita conflitos e
  facilita o gerenciamento. Inverter vantagens e desvantagens é o erro típico.
- Porta é lógica (software, gerenciada pelo SO), não física. Confusões: 22 × 23 (SSH × Telnet),
  80 × 443 (HTTP × HTTPS), 3306 × 5432 × 1433 (MySQL × PostgreSQL × SQL Server), 3389 (RDP), 21 ×
  25 (FTP × SMTP). Portas dinâmicas vão de 49152 a 65535.
- Windows × Linux: `tracert` × `traceroute`, `ipconfig` × `ip`, `nslookup` × `dig`/`host`.
  `pathping` é ping + tracert com estatística de perda. `getmac` mostra o MAC, não o IP.
  `hostname` mostra o nome, não o IP.
- "Name or service not known" é falha de resolução de nome (DNS); "100% packet loss" com o IP é
  falha de conectividade. Se o `ping` no IP funciona e no nome não, o problema é DNS.
- `ssh`: a porta vai com `-p` minúsculo e hífen comum (o travessão "–p" do slide não funciona
  copiado; `-P` maiúsculo não é porta). `127.0.0.1` é a própria máquina; para a VM de um colega
  usa-se o IP do **host** dele, não o IP interno da VM. O usuário vem antes do `@`.
- Redirecionamento: 2222 é a porta do hospedeiro e 22 a do convidado (VM); 3307 no hospedeiro e
  3306 no convidado para o MySQL. Inverter as duas é o erro mais comum.
- Diagrama de solução: a ordem é captura → inserção → armazenamento → seleção → transformação em
  gráficos → visualização. A captura (Arduino + Node, API Data Acquino, porta 3300) fica na máquina
  instalada no cliente; BD e app (MySQL + Node, API Web Data Viz, porta 3333) ficam na VM Linux.
  Inserção usa `INSERT`, seleção usa `SELECT`. Sem banco, os dados ficam só em cache.
