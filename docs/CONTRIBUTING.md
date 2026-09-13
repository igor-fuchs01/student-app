# Como contribuir

Guia passo a passo para quem nunca abriu um Pull Request (PR). Se você já sabe fazer isso, pode pular direto para a seção [Padrões do projeto](#padrões-do-projeto).

## 0. O que você vai precisar

- Uma conta no [GitHub](https://github.com).
- [Git](https://git-scm.com/downloads) instalado.
- [Node.js](https://nodejs.org/) 18 ou superior (inclui o `npm`).
- Um editor de código, como o [VS Code](https://code.visualstudio.com/).

Para conferir se o Git e o Node estão instalados, abra o terminal e rode:

```bash
git --version
node --version
npm --version
```

Se algum comando não for reconhecido, instale a ferramenta correspondente antes de continuar.

## 1. Faça um fork do repositório

Um **fork** é uma cópia do repositório na sua própria conta do GitHub, onde você pode fazer alterações livremente.

1. Acesse o repositório: https://github.com/igor-fuchs01/student-app
2. Clique no botão **Fork** (canto superior direito da página).
3. Confirme a criação do fork na sua conta.

Você agora tem uma cópia em `https://github.com/SEU-USUARIO/student-app`.

## 2. Clone o seu fork

Clonar significa baixar o repositório para o seu computador. No terminal, na pasta onde você guarda seus projetos:

```bash
git clone https://github.com/SEU-USUARIO/student-app.git
cd student-app
```

Troque `SEU-USUARIO` pelo seu usuário do GitHub.

## 3. Configure o repositório original como "upstream"

Isso permite trazer atualizações do projeto original para o seu fork depois:

```bash
git remote add upstream https://github.com/igor-fuchs01/student-app.git
```

Para conferir se deu certo:

```bash
git remote -v
```

Você deve ver `origin` (seu fork) e `upstream` (o repositório original).

## 4. Instale as dependências

```bash
npm install
```

## 5. Crie uma branch para a sua alteração

Nunca trabalhe diretamente na branch `main`. Crie uma branch com um nome descritivo:

```bash
git checkout -b minha-alteracao
```

Exemplos de nomes: `fix-login-erro`, `feat-pagina-simulados`, `docs-atualiza-readme`.

## 6. Faça sua alteração

- Rode a aplicação para ver o que está mudando:

  ```bash
  npm run mock   # usa dados de teste no navegador, sem precisar de backend
  ```

- Siga os padrões do projeto (veja a seção [Padrões do projeto](#padrões-do-projeto) abaixo) antes de escrever código.
- Faça alterações pequenas e focadas em uma única coisa por vez.

## 7. Confira se está tudo certo

Antes de enviar sua alteração, rode:

```bash
npm run lint    # verifica o estilo do código
npm run build   # garante que o projeto compila sem erros
```

Corrija qualquer erro apontado antes de continuar.

## 8. Salve suas alterações (commit)

```bash
git add .
git commit -m "feat: descreve o que foi feito"
```

Use o padrão [Conventional Commits](https://www.conventionalcommits.org/pt-br/v1.0.0/) no prefixo da mensagem:

- `feat:` para uma funcionalidade nova
- `fix:` para correção de bug
- `docs:` para alterações em documentação
- `refactor:` para refatoração sem mudar comportamento
- `chore:` para configuração, dependências, build

## 9. Envie a alteração para o seu fork

```bash
git push origin minha-alteracao
```

## 10. Abra o Pull Request (PR)

1. Acesse o seu fork no GitHub (`https://github.com/SEU-USUARIO/student-app`).
2. O GitHub geralmente mostra um botão **Compare & pull request** assim que você faz o push — clique nele. Se não aparecer, vá na aba **Pull requests** → **New pull request**.
3. Confira se a comparação está correta: base `igor-fuchs01/student-app` (branch `main`) ← compare `SEU-USUARIO/student-app` (sua branch).
4. Escreva um título curto e uma descrição explicando **o que** foi feito e **por quê**.
5. Clique em **Create pull request**.

Pronto! Seu PR foi enviado e ficará visível para revisão.

## 11. Responda a comentários e ajuste se necessário

Quem revisar pode pedir ajustes. Para atualizar o PR, basta fazer novos commits na mesma branch e repetir o `git push origin minha-alteracao` — o PR é atualizado automaticamente, sem precisar abrir um novo.

## 12. Depois que o PR for aceito

Atualize sua branch `main` local com as mudanças do projeto original:

```bash
git checkout main
git fetch upstream
git merge upstream/main
git push origin main
```

## Padrões do projeto

Antes de contribuir, dê uma olhada em [`.claude/CLAUDE.md`](../.claude/CLAUDE.md), que define as convenções do projeto (stack, arquitetura, estilo de código, idioma). Os pontos mais importantes:

- Código, nomes de variáveis/componentes e mensagens de commit: **inglês**.
- Textos exibidos ao aluno (UI) e dados de exemplo/mock: **português**.
- Reaproveite componentes e serviços existentes antes de criar novos.
- Mudanças pequenas e focadas — evite misturar assuntos diferentes em um mesmo PR.
- A documentação completa do produto está em [`docs/README.md`](README.md).

## Dúvidas?

Se travar em qualquer etapa, abra uma [issue](https://github.com/igor-fuchs01/student-app/issues) descrevendo o problema.
