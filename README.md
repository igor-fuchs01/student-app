<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:2E9EF7,100:7F5AF0&height=190&section=header&text=Student%20App%20%F0%9F%8E%93&fontSize=48&fontColor=ffffff&animation=fadeIn&fontAlignY=36" alt="Student App" width="100%" />

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=22&pause=1000&color=2E9EF7&center=true&vCenter=true&width=560&lines=Bem-vindo%28a%29+ao+Student+App+%F0%9F%8E%93;Pratique+com+simulados+de+verdade+%F0%9F%93%9D;Descubra+o+que+ainda+precisa+estudar+%F0%9F%93%9A;Const%C3%A2ncia+vale+mais+que+nota+%F0%9F%94%A5" alt="Typing SVG" />

**Estude para as provas sabendo exatamente o que revisar.**

[![CI](https://github.com/igor-fuchs01/student-app/actions/workflows/ci.yml/badge.svg)](https://github.com/igor-fuchs01/student-app/actions/workflows/ci.yml)
[![Licença](https://img.shields.io/badge/licen%C3%A7a-GPL--3.0-2E9EF7)](LICENSE)

</div>

## 🤔 A ideia

Tirar "7" numa prova não diz o que você errou. No Student App, depois de cada simulado, a pergunta
não é *"quanto eu tirei?"*, e sim ***"o que ainda preciso estudar?"***

```mermaid
flowchart LR
    A[📚 Material] --> B[📝 Simulado] --> C[📊 Resultado] --> D[🎯 O que revisar] --> A
```

## ✨ O que dá para fazer

- 📘 **Disciplinas** com o seu nível de preparo em cada uma.
- 📝 **Simulados** com cronômetro e 6 tipos de questão.
- 📊 **Resultado comentado**, com a explicação de cada erro.
- 🔥 **Ranking de constância**: premia quem estuda todo dia, nunca mostra notas.

> [!NOTE]
> O projeto está no **MVP** (primeira versão, só com o essencial).

## 🚀 Como rodar

Precisa ter instalado o [Node.js](https://nodejs.org/) (LTS) e o [Git](https://git-scm.com/).

```bash
git clone https://github.com/igor-fuchs01/student-app.git
cd student-app
npm install
npm run mock
```

Abra **http://localhost:5173** e entre com `igor@email.com` / `123456`.

> O `npm run mock` usa dados de exemplo, então não precisa de backend nem banco de dados.

## 📖 Quer saber mais?

| | |
|---|---|
| 🧭 [Primeiros passos](docs/PRIMEIROS-PASSOS.md) | Comandos, pastas, tecnologias, banco de dados, erros comuns e glossário. |
| 🤝 [Como contribuir](docs/CONTRIBUTING.md) | Do fork ao Pull Request, passo a passo. |
| 📚 [Documentação do produto](docs/README.md) | Regras de negócio, arquitetura e contratos de API. |

<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:7F5AF0,100:2E9EF7&height=110&section=footer" alt="" width="100%" />

</div>
