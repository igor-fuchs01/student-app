# Student App

Plataforma web educacional para ajudar estudantes a se prepararem para provas e avaliações: materiais de estudo, questões, simulados, acompanhamento de desempenho e recomendações de estudo personalizadas.

> 📄 Documentação do produto: [`docs/README.md`](docs/README.md)

> 🤝 Quer contribuir? Veja o guia passo a passo: [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md)

## Como rodar

Pré-requisitos: [Node.js](https://nodejs.org/) 20.19+ (ou 22.12+) e npm.

```bash
npm install
npm run mock          # dados mockados no navegador (.env.mock) — sem backend
npm run dev           # servidor de desenvolvimento (.env.development → VITE_API_BASE_URL)
npm run build         # build de produção
npm run lint          # ESLint
npm run format        # formata o código com Prettier
npm run format:check  # verifica a formatação (usado na CI)
```

A CI (`.github/workflows/ci.yml`) roda lint, verificação de formatação e build a cada push e
pull request para `main`.

Login de demonstração (dados mockados, via `npm run mock`): login `senaiigorpereira` com senha `123456`.

## Stack

[![Project Stack](https://skillicons.dev/icons?i=react,ts,styledcomponents)](https://skillicons.dev)
