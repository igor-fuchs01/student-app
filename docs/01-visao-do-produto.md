# Visão do Produto

## O que é

O **Student App** é uma plataforma web educacional para alunos de qualquer curso, inicialmente análise e desenvolvimento de sistemas, de uma instituição de ensino, com um objetivo específico: **ajudá-los a se preparar para provas e avaliações**.

Na plataforma, o aluno pode:

- estudar conteúdos disponibilizados pela instituição;
- praticar questões;
- realizar simulados;
- acompanhar sua evolução;
- identificar seus pontos de dificuldade;
- receber recomendações do que estudar em seguida.

A fonte principal de conteúdo são **materiais didáticos em PDF** - apostilas, apresentações, textos e materiais fornecidos pelos professores ou pela equipe responsável.

## Princípio central

Este é o ciclo que define o produto. Toda decisão de design ou de engenharia deve reforçá-lo:

```text
Material didático
  → Conteúdo
    → Questões
      → Simulados
        → Respostas
          → Desempenho
            → Identificação de dificuldades
              → Recomendação de estudo
                → Nova prática
```

O ciclo é fechado: a prática alimenta o diagnóstico, e o diagnóstico devolve o aluno à prática, agora direcionada.

## O que o produto NÃO é

**Não é uma coleção de simulados.**

Bancos de questões já existem. O diferencial aqui é a experiência completa de preparação: o aluno não apenas responde, ele descobre o que não sabe e recebe um caminho para resolver isso.

Se uma funcionalidade só serve para "oferecer mais simulados" sem alimentar o ciclo de diagnóstico e recomendação, ela está fora do espírito do produto.

## A pergunta que o produto responde

Depois de um simulado, a tela de resultado não existe para dizer "você tirou 7". Ela existe para responder:

> **"O que você aprendeu e o que ainda precisa estudar?"**

Nota e percentual podem aparecer para o próprio aluno quando fizer sentido academicamente, mas são secundários e nunca são expostos a terceiros.

## Público

Alunos da instituição, exclusivamente.

- Não existe cadastro público / self-signup.
- As contas são previamente provisionadas pela equipe responsável.
