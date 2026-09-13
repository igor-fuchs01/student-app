# Student App

Plataforma web educacional para ajudar estudantes a se prepararem para provas e avaliações: materiais de estudo, questões, simulados, acompanhamento de desempenho e recomendações de estudo personalizadas.

> 📄 Documentação completa do produto: [`docs/README.md`](docs/README.md)
> 🤝 Quer contribuir? Veja o guia passo a passo: [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md)

## Como rodar

Pré-requisitos: [Node.js](https://nodejs.org/) 18+ e npm.

```bash
npm install
npm run mock   # dados mockados no navegador (.env.mock) — sem backend
npm run dev    # servidor de desenvolvimento (.env.development → VITE_API_BASE_URL)
npm run build  # build de produção
npm run lint   # ESLint
```

Login de demonstração (dados mockados, via `npm run mock`): matrícula `20231234` (ou e-mail `marina@aluno.ifpr.edu.br`) com senha `123456`.

## Stack

React + TypeScript (strict) + Vite, React Router, TanStack Query, Zustand e styled-components. Detalhes de arquitetura, modelo de dados e contratos de API em [`docs/03-arquitetura-tecnica.md`](docs/03-arquitetura-tecnica.md).
