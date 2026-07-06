# Visão geral

## O que é

Aplicação web de **lista de tarefas** (to-do list). Permite criar, listar,
visualizar, editar e excluir tarefas — um CRUD completo gerado a partir do
scaffold do Rails.

Cada **tarefa** tem:

- `titulo` — texto obrigatório
- `descricao` — texto livre (opcional)
- `concluida` — booleano (padrão `false`)

## Stack

| Camada | Tecnologia |
|--------|------------|
| Framework | Ruby on Rails 8.1 |
| Linguagem | Ruby 3.4.9 |
| Banco de dados | PostgreSQL 16 |
| Servidor de aplicação | Puma |
| Front-end | Views ERB + Hotwire (Turbo/Stimulus) + Importmap |
| Servidor de produção | Thruster (na frente do Puma, porta 80) |

## O que faz a lista de tarefas funcionar

O núcleo da aplicação são **quatro peças** que trabalham juntas. Toda a
funcionalidade do CRUD vem delas:

1. **Rota** (`config/routes.rb`)
   `resources :tarefas` gera as 7 rotas REST, e `root "tarefas#index"` faz a
   raiz `/` cair na lista. → detalhes em [rotas.md](rotas.md)

2. **Controller** (`app/controllers/tarefas_controller.rb`)
   Recebe as requisições e implementa as ações `index`, `show`, `new`,
   `create`, `edit`, `update`, `destroy`. É quem consulta/salva no banco via
   o model.

3. **Model** (`app/models/tarefa.rb`)
   A classe `Tarefa` (um `ApplicationRecord`) mapeia a tabela `tarefas`.
   Define a validação (`titulo` obrigatório) e os scopes `pendentes` e
   `concluidas`. → detalhes em [modelo-de-dados.md](modelo-de-dados.md)

4. **Views** (`app/views/tarefas/`)
   Templates ERB que renderizam o HTML (lista, formulário, detalhe) e também
   as respostas JSON (via Jbuilder).

Somando: a **tabela `tarefas`** no PostgreSQL é onde os dados vivem de fato.

## Fluxo de uma requisição (ponta a ponta)

Exemplo: usuário abre a página inicial e vê a lista de tarefas.

```
Navegador                Rails                         PostgreSQL
   │                       │                                │
   │  GET /                │                                │
   ├──────────────────────►│                                │
   │            routes.rb: root → tarefas#index             │
   │                       │                                │
   │            TarefasController#index                     │
   │            @tarefas = Tarefa.all ──────────────────────►│
   │                       │      SELECT * FROM tarefas      │
   │                       │◄───────────────────────────────┤
   │            renderiza app/views/tarefas/index.html.erb  │
   │  HTML da lista        │                                │
   │◄──────────────────────┤                                │
```

O mesmo caminho vale para as demais ações — muda apenas a rota, a ação do
controller, a operação no banco (INSERT/UPDATE/DELETE) e a view renderizada.

## Como rodar

Instruções completas de desenvolvimento local (subir o Postgres via Docker,
criar o banco e iniciar o servidor) estão no
[README principal](../README.md#desenvolvimento-local).
