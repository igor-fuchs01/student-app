# Regras de Negócio

Este documento descreve **como o produto se comporta**.

---

## 1. Estrutura acadêmica

O conteúdo é organizado hierarquicamente:

```text
Disciplina
     └── Assunto
          └── Subassunto
               └── Material
                    └── Questões
```

Essa hierarquia não é decorativa: ela é o que permite calcular desempenho por disciplina, por assunto e por subassunto que por sua vez alimenta o diagnóstico e as recomendações.

Toda questão precisa estar amarrada a pelo menos uma disciplina e um assunto.

---

## 2. Tipos de questão

Cinco tipos são suportados:

### 2.1 Múltipla escolha
Uma alternativa correta entre várias.

### 2.2 Seleção única
Formato de seleção/dropdown, usado em textos para complementar a sequência lógica do texto, podendo ter um ou mais seletores.

### 2.3 Múltiplas alternativas
Mais de uma alternativa correta. A correção precisa definir claramente o acerto parcial.

### 2.4 Dissertativa
Resposta em texto livre podendo ser inserida para complementar a sequência lógica de um texto, podendo ter um ou mais desse componente, ou resposta final para uma pergunta.

- No MVP, **a correção é manual**.
- Correção assistida por IA somente quando a implementação manual estiver finalizada. 

### 2.5 Drag and drop
Cobre quatro usos:

- ordenar elementos;
- associar elementos.

### Regra de qualidade

O sistema deve evitar questões ambíguas ou com múltiplas respostas corretas quando o tipo exige apenas uma.

---

## 3. Simulados

### O que o aluno vê antes de começar

Cada simulado exibe:

- disciplina;
- assuntos abordados;
- quantidade de questões;
- dificuldade estimada;
- duração recomendada;
- quantidade de tentativas permitidas, quando aplicável.

### Cronômetro

Modos suportados:

- **sem limite**;
- **tempo total**.

**O frontend nunca é a única fonte de verdade do cronômetro.** O backend também cumpre o seu papel.

---

## 4. Persistência durante o simulado

Perder respostas é a pior falha possível neste produto. A plataforma deve:

- salvar respostas progressivamente;
- preservar o estado durante refresh;
- recuperar tentativa interrompida;
- lidar com perda temporária de conexão;
- evitar duplicação de respostas;
- **indicar visualmente quando uma resposta ainda não foi sincronizada.**

Essas informação precisam estarão em armazenamento local temporário através de um mecanismo.

---

## 5. Navegação dentro do simulado

O aluno deve conseguir:

- avançar;
- voltar;
- visualizar o número da questão;
- identificar questões respondidas;
- identificar questões não respondidas;
- marcar questões para revisão;
- revisar antes do envio;
- enviar o simulado.

**Antes do envio**, apresentar uma confirmação que mostre: questões respondidas, não respondidas e marcadas para revisão.

---

## 6. Correção

Após o envio, o sistema deve:

- corrigir automaticamente as questões objetivas;
- calcular o desempenho;
- registrar as respostas;
- registrar quais questões foram erradas e quais foram corretas;
- registrar os assuntos relacionados a cada questão;
- registrar a tentativa;
- disponibilizar a revisão.

Para dissertativas, os estados possíveis são:

```text
correct
incorrect
pending_review
```

Uma tentativa com dissertativas pendentes ainda deve mostrar o resultado parcial das objetivas.

---

## 7. Resultado do simulado

A tela de resultado mostra:

- desempenho geral do próprio aluno;
- quantidade de acertos;
- quantidade de erros;
- questões não respondidas;
- desempenho por assunto;
- questões que precisam ser revistas;
- explicações / gabaritos comentados, quando disponíveis.

Nota ou percentual podem aparecer para o próprio aluno quando fizer sentido acadêmico, **mas nunca aparecem no ranking ou para outros alunos.**

O foco da tela é responder: *"O que você aprendeu e o que ainda precisa estudar?"*

---

## 8. Análise de desempenho

O desempenho é calculado por:

- disciplina;
- assunto;
- subassunto;
- tipo de questão;
- dificuldade;
- período.

Exemplo de visualização:

```text
Algoritmos

Operadores Aritméticos      86%
Estrtura condicionais       78%
Operadores Relacionais      54%
```

O sistema deve **identificar automaticamente** os assuntos em que o aluno apresenta maior dificuldade isso é insumo direto para as recomendações.

---

## 9. Sistema de recomendações

A partir do desempenho, o sistema recomenda ações concretas de estudo.

Exemplo:

> Você apresentou dificuldade em Operadores Aritméticos.
>
> 1. Revisar o material correspondente.
> 2. Refazer as questões que errou.
> 3. Realizar 10 novas questões sobre o assunto.
> 4. Depois, realizar um mini-simulado.

### Ordem de prioridade das recomendações

1. assuntos com baixo desempenho;
2. assuntos relevantes para avaliações próximas;
3. conteúdos errados recentemente;
4. conteúdos pouco praticados.

A recomendação deve ser **acionável** algo que o aluno consegue começar a fazer agora.

---

## 10. Histórico

O aluno visualiza:

- quantidade de questões realizadas;
- quantidade de simulados realizados;
- evolução de desempenho;
- assuntos mais estudados;
- assuntos com maior dificuldade;
- questões erradas recentemente;
- evolução por disciplina.

Usar gráficos simples e legíveis. Legibilidade vale mais que sofisticação visual.

---

## 11. Ranking e gamificação

Esta é uma decisão de produto deliberada e **não negociável**.

### A regra

**O ranking nunca é baseado em nota ou desempenho acadêmico.** Ele compara esforço e consistência.

A gamificação existe para incentivar **hábitos de estudo**, não competição por inteligência ou nota.

### Indicadores permitidos no ranking

| Indicador | O que mede |
|-----------|-----------|
| Streak | Dias consecutivos estudando |
| Streak semanal | Semanas consecutivas com atividade |
| Questões realizadas | Quantidade de questões respondidas |
| Simulados concluídos | Quantidade de simulados finalizados |
| Dias estudados | Dias com alguma atividade |

Exemplos de exibição:

```text
🔥 7 dias consecutivos
```

```text
Meta semanal

████████░░ 80%

40 / 50 questões
```

```text
Ranking de consistência

🥇 Ana       🔥 21 dias
🥈 João      🔥 18 dias
🥉 Lucas     🔥 15 dias
4. Maria     🔥 12 dias
5. Pedro     🔥 10 dias
```

### Nunca exibir para outros alunos

- notas;
- percentual de acerto;
- quantidade de erros;
- qualquer desempenho acadêmico privado.

### Elementos de gamificação usados

Gamificação **moderada**: streaks, badges, metas semanais, número de questões, simulados concluídos, dias estudados, pequenas conquistas.
