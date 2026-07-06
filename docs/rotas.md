# Rotas

As rotas são definidas em [`config/routes.rb`](../config/routes.rb):

```ruby
Rails.application.routes.draw do
  resources :tarefas
  get "up" => "rails/health#show", as: :rails_health_check
  root "tarefas#index"
end
```

`resources :tarefas` gera automaticamente as 7 rotas REST do CRUD.

## Rotas de tarefas (CRUD)

Todas atendidas pelo [`TarefasController`](../app/controllers/tarefas_controller.rb).

| Método HTTP | Caminho | Ação | O que faz | View / resposta |
|-------------|---------|------|-----------|-----------------|
| `GET` | `/tarefas` | `index` | Lista todas as tarefas (`Tarefa.all`) | `index.html.erb` / `index.json.jbuilder` |
| `GET` | `/tarefas/new` | `new` | Formulário de nova tarefa | `new.html.erb` |
| `POST` | `/tarefas` | `create` | Cria a tarefa; se válida, redireciona para o detalhe | redirect / `show` (201) |
| `GET` | `/tarefas/:id` | `show` | Exibe uma tarefa | `show.html.erb` / `show.json.jbuilder` |
| `GET` | `/tarefas/:id/edit` | `edit` | Formulário de edição | `edit.html.erb` |
| `PATCH`/`PUT` | `/tarefas/:id` | `update` | Atualiza a tarefa; se válida, redireciona para o detalhe | redirect / `show` (200) |
| `DELETE` | `/tarefas/:id` | `destroy` | Exclui a tarefa e volta para a lista | redirect / no content (204) |

### Parâmetros aceitos

O controller só permite estes campos (strong parameters, método
`tarefa_params`):

- `titulo`
- `descricao`
- `concluida`

### Formatos

Cada ação responde tanto **HTML** (páginas web) quanto **JSON** (API), via
`respond_to`. Para obter JSON, use a extensão `.json` ou o header `Accept`:

```bash
curl http://localhost:3000/tarefas.json
curl http://localhost:3000/tarefas/1.json
```

## Outras rotas

| Método | Caminho | Destino | Descrição |
|--------|---------|---------|-----------|
| `GET` | `/` | `tarefas#index` | Raiz do site → lista de tarefas |
| `GET` | `/up` | `rails/health#show` | Healthcheck: 200 se o app sobe sem erros. Usado pelas probes do Kubernetes |

## Ver as rotas no terminal

```bash
bin/rails routes            # todas as rotas
bin/rails routes -c tarefas # só as do controller de tarefas
```
