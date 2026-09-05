# Automação EAD Canvas

Este projeto consiste em uma automação desenvolvida com **Robot Framework** e **SeleniumLibrary** para plataformas de **ensino a distância (EAD)** baseadas no LMS **Canvas by Instructure**. O projeto explora o fluxo padrão de cursos, módulos e conteúdos do Canvas e serve como referência para qualquer instituição que adote a plataforma.

---

## 🎓 Propósito e Posicionamento

Este repositório é, acima de tudo, um **projeto de estudo em automação de processos robóticos (RPA)**. Ele aplica conceitos de Robot Framework, Selenium WebDriver e boas práticas de segurança no tratamento de credenciais a um caso de uso real e repetitivo: o **fluxo de navegação** no ambiente Canvas.

A proposta é contribuir com a **produtividade** e a **gestão de tempo** de quem estuda: ao eliminar o trabalho mecânico e repetitivo da interface, a automação libera a atenção para o que realmente gera **aprendizado ativo** — ler, assistir, praticar e revisar o conteúdo.

**Uma automação com limites claros e intencionais (human-in-the-loop):** o escopo é propositalmente restrito e supervisionado. O robô não decide nada por conta própria: limita-se a navegar pelos módulos e acionar os controles que a própria plataforma disponibiliza (**Marcar como Concluído** / **Próximo**), sem responder avaliações, gerar conteúdo ou substituir o estudo. A decisão de executar, o acompanhamento da execução e a interrupção a qualquer momento permanecem sempre com o usuário.

> **Disclaimer educacional:** projeto independente, sem vínculo com a Instructure (desenvolvedora do Canvas), com a Microsoft ou com qualquer instituição de ensino. Foi desenvolvido com finalidade exclusiva de estudo e prática de automação (RPA). O uso é de total responsabilidade de quem o executa, que deve respeitar os termos de uso da plataforma e as políticas de integridade acadêmica da sua instituição.

---

## 🎯 O que o projeto faz?

1. **Autenticação Automática e Segura**:
   - Realiza login no portal Canvas institucional (fluxo validado com o **SSO da Microsoft**, adotado por muitas instituições; outros provedores de login podem exigir pequenos ajustes nos seletores).
   - A senha **nunca é armazenada em texto plano**: utiliza criptografia simétrica (Fernet) com semente aleatória gerada em tempo de execução.
   - Identifica se a sessão já está ativa no navegador e pula o login se necessário.

2. **Navegação Automática por Matérias**:
   - Descobre dinamicamente e percorre automaticamente todas as disciplinas disponíveis nos cartões do **Painel de Controle** (Dashboard) do Canvas.

3. **Conclusão Automática de Tópicos e Atividades**:
   - Entra nos módulos de conteúdo das disciplinas (o fluxo padrão de *Modules* do Canvas).
   - Identifica botões e links como **Marcar como Concluído / Feito** e **Próximo** / **Atividade**.
   - Executa cliques via JavaScript para evitar erros de interceptação visual (`ElementClickInterceptedException`) por overlays de suporte da plataforma.
   - Concluído o fluxo da matéria, retorna automaticamente ao Dashboard e abre a próxima.

4. **Limpeza Automática de Screenshots**:
   - Ao final do teste, limpa automaticamente screenshots (`.png`) e HTMLs de diagnóstico gerados pelo Selenium/Robot Framework, conforme configurado no `.env`.

---

## 🛠️ Tecnologias Utilizadas

- **Python** (>= 3.12)
- **uv** (gerenciador rápido de pacotes e ambientes Python)
- **Robot Framework** (framework de automação de testes e tarefas)
- **SeleniumLibrary** (integração do Robot com Selenium Webdriver)
- **Cryptography (Fernet)** (criptografia de credenciais)

---

## 🚀 Como Configurar e Executar

### 1. Pré-requisitos
- [Python 3.12+](https://www.python.org/)
- [uv](https://github.com/astral-sh/uv) instalado na máquina
- Google Chrome instalado

### 2. Instalação das Dependências
No diretório do projeto, execute:
```bash
uv sync
```

### 3. Configuração do `.env`
Crie o seu arquivo `.env` a partir do modelo:
```bash
cp .env.example .env
```

Edite o arquivo `.env` e preencha as variáveis de ambiente:
```env
CANVAS_URL=https://canvas.instituicao.br/
CANVAS_LOGIN=seu_email@instituicao.edu.br

# Valores gerados ao executar: uv run python criptografar_senha.py
CANVAS_SENHA_SEED=
CANVAS_SENHA_CRYPT=

# Apagar screenshots gerados pelo Selenium/Robot ao final da execução (True/False)
APAGAR_SCREENSHOTS=True
```

### 4. Criptografar a Senha
Execute o script interativo para criptografar a sua senha:
```bash
uv run python criptografar_senha.py
```
O script solicitará sua senha e exibirá as chaves `CANVAS_SENHA_SEED` e `CANVAS_SENHA_CRYPT`. Copie e cole essas duas linhas no seu arquivo `.env`.

---

## ⚡ Execução da Automação

Para rodar a automação completa por todas as matérias:

```bash
uv run --env-file .env robot main.robot
```

Ao final da execução, os relatórios em HTML e XML serão gerados no diretório do projeto:
- `log.html`
- `report.html`
- `output.xml`

---

## 📁 Estrutura do Projeto

```text
├── main.robot               # Script principal do Robot Framework (suíte de automação)
├── seguranca.py             # Módulo Python com funções de criptografia/descriptografia
├── criptografar_senha.py    # Utilitário CLI para criptografar a senha institucional
├── .env.example             # Modelo de variáveis de ambiente
├── .env                     # Arquivo local com credenciais e chaves (gitignored)
├── pyproject.toml           # Configuração do projeto e dependências (uv)
├── LICENCE                  # Licença de uso (MIT)
└── README.md                # Documentação do projeto
```

---

## 🤝 Parceria e Créditos

Este projeto é fruto de uma **parceria** com [**arao_negreira**](https://github.com/araodsa), que idealizou o projeto e conduziu a **criação da PoC** (*Proof of Concept*) e o **desenvolvimento da primeira versão do script** (`Automacao_Aulas.robot`). A partir dessa base inicial, o projeto evoluiu até o formato atual.

| Papel | Autor |
| --- | --- |
| Idealização, PoC e primeira versão (`Automacao_Aulas.robot`) | arao_negreira |
| Evolução e manutenção a partir da base inicial | Roberto Schneider |

> 🙏 **Agradecimento especial** ao amigo Arao pelo compartilhamento da base inicial que viabilizou este projeto.

---

## 📄 Licença

Este projeto é **open source**: pode ser **copiado, modificado e distribuído livremente**, de acordo com os termos da licença **MIT**.

Consulte o arquivo [`LICENCE`](./LICENCE) para os detalhes completos.
