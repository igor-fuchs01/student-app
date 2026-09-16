# Roadmap e Critérios de Aceite

---

## Fases de implementação

### Fase 1 — Fundação
arquitetura · autenticação · layout · navegação · disciplinas · assuntos · API/mocks · modelagem de dados

### Fase 2 — Motor de questões
múltipla escolha · seleção única · múltiplas alternativas · dissertativa · drag and drop · navegação · respostas

### Fase 3 — Simulados
criação de tentativa · cronômetro · persistência · envio · correção · resultados

### Fase 4 — Desempenho
histórico · gráficos · desempenho por assunto · questões erradas · evolução

### Fase 5 — Recomendações
identificação de dificuldades · recomendações · plano de estudo · modo Semana de Provas

### Fase 6 — Gamificação
streak · metas · badges · ranking de consistência

### Fase 7 — Evolução futura *(fora do MVP)*
painel administrativo · upload de PDFs · processamento automático · OCR · geração automática de questões · IA como tutor · base de conhecimento

---

## Critérios de aceite do MVP

Use como checklist de verificação durante o polimento.

### Autenticação
- ☐ login
- ☐ sessão persistente
- ☐ logout
- ☐ acesso somente às próprias informações

### Conteúdo
- ☐ visualizar disciplinas
- ☐ visualizar assuntos
- ☐ visualizar materiais
- ☐ encontrar questões relacionadas aos assuntos

### Simulados
- ☐ visualizar simulados
- ☐ iniciar simulado
- ☐ escolher cronômetro
- ☐ responder diferentes tipos de questão
- ☐ navegar entre questões
- ☐ marcar questões para revisão
- ☐ retornar a questões anteriores
- ☐ revisar antes do envio
- ☐ enviar

### Persistência
- ☐ respostas preservadas após refresh
- ☐ tentativa recuperável
- ☐ tolerância a interrupção temporária da conexão

### Resultado
- ☐ visualizar resultado
- ☐ visualizar erros
- ☐ visualizar gabarito / explicações
- ☐ visualizar desempenho por assunto
- ☐ visualizar histórico

### Recomendações
- ☐ identificar assuntos de maior dificuldade
- ☐ apresentar recomendações
- ☐ sugerir questões ou revisão

### Gamificação
- ☐ registrar dias de estudo
- ☐ calcular streak
- ☐ registrar questões
- ☐ registrar simulados
- ☐ apresentar ranking por esforço
- ☐ **não expor desempenho acadêmico privado de outros alunos**

---

## Regra fundamental de desenvolvimento

> **Não implementar funcionalidades complexas apenas porque foram mencionadas como possibilidades futuras.**

O objetivo do MVP é entregar uma plataforma **simples, confiável e funcional**.

Ordem de prioridade do produto:

```text
conteúdo → questões → simulados → desempenho → recomendação
```

Toda decisão técnica considera, nesta ordem:

1. simplicidade;
2. segurança;
3. manutenção;
4. experiência do aluno;
5. possibilidade de evolução futura.

Quando houver duas soluções possíveis, prefira a mais simples que não prejudique a evolução do sistema.

