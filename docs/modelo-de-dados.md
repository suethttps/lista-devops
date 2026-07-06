# Modelo de dados

A aplicação tem **uma única tabela**: `tarefas`. É onde toda a lista de
tarefas é armazenada.

## Tabela `tarefas`

Definida na migration
[`db/migrate/20260706113535_create_tarefas.rb`](../db/migrate/20260706113535_create_tarefas.rb)
e refletida em [`db/schema.rb`](../db/schema.rb).

| Coluna | Tipo | Nulo? | Padrão | Descrição |
|--------|------|-------|--------|-----------|
| `id` | bigint | não | (auto) | chave primária |
| `titulo` | string | **não** | — | título da tarefa (obrigatório) |
| `descricao` | text | sim | — | descrição livre |
| `concluida` | boolean | **não** | `false` | se a tarefa foi concluída |
| `created_at` | datetime | não | (auto) | data de criação |
| `updated_at` | datetime | não | (auto) | data da última atualização |

## Model `Tarefa`

Arquivo: [`app/models/tarefa.rb`](../app/models/tarefa.rb)

```ruby
class Tarefa < ApplicationRecord
  validates :titulo, presence: true

  scope :pendentes, -> { where(concluida: false) }
  scope :concluidas, -> { where(concluida: true) }
end
```

### Validações

- `titulo` é **obrigatório** (`presence: true`). Uma tarefa sem título não é
  salva e o formulário exibe o erro.

### Scopes

Consultas nomeadas para filtrar tarefas:

- `Tarefa.pendentes` → tarefas com `concluida = false`
- `Tarefa.concluidas` → tarefas com `concluida = true`

> Observação: os scopes já existem no model, mas ainda não são usados nas
> views/controller (a `index` lista `Tarefa.all`). Ficam prontos para filtrar
> a listagem quando necessário.

## Migrations e schema

- Criar/atualizar o banco a partir das migrations:
  ```bash
  bin/rails db:prepare      # cria o banco (se necessário) e roda migrations
  ```
- O arquivo `db/schema.rb` é **gerado automaticamente** — não edite à mão.
  Para mudar a estrutura, crie uma nova migration:
  ```bash
  bin/rails generate migration NomeDaMudanca
  bin/rails db:migrate
  ```
