# Estrutura do projeto — onde está cada coisa

Este documento aponta **onde** cada peça vive no repositório. Os arquivos
marcados com ⭐ são os que fazem a lista de tarefas funcionar.

```
lista/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   └── tarefas_controller.rb        ⭐ ações do CRUD (index, create, ...)
│   ├── models/
│   │   ├── application_record.rb
│   │   └── tarefa.rb                     ⭐ model Tarefa (validação + scopes)
│   ├── views/
│   │   ├── layouts/
│   │   │   └── application.html.erb      layout base (envolve todas as páginas)
│   │   └── tarefas/                      ⭐ telas da lista de tarefas
│   │       ├── index.html.erb            lista de tarefas ("/")
│   │       ├── show.html.erb             detalhe de uma tarefa
│   │       ├── new.html.erb              tela de criação
│   │       ├── edit.html.erb             tela de edição
│   │       ├── _form.html.erb            formulário reutilizado por new/edit
│   │       ├── _tarefa.html.erb          partial que exibe uma tarefa
│   │       ├── index.json.jbuilder       resposta JSON da listagem
│   │       ├── show.json.jbuilder        resposta JSON do detalhe
│   │       └── _tarefa.json.jbuilder     serialização JSON de uma tarefa
│   ├── helpers/                          helpers de view
│   └── javascript/                       Stimulus controllers (Hotwire)
│
├── config/
│   ├── routes.rb                         ⭐ mapa de rotas (resources :tarefas)
│   ├── database.yml                      ⭐ conexão com o PostgreSQL
│   ├── application.rb                    configuração geral do app
│   ├── puma.rb                           servidor web
│   └── environments/                     configs por ambiente (dev/test/prod)
│
├── db/
│   ├── migrate/
│   │   └── 20260706113535_create_tarefas.rb  ⭐ cria a tabela tarefas
│   ├── schema.rb                         ⭐ estado atual do schema do banco
│   └── seeds.rb                          dados iniciais (vazio por enquanto)
│
├── docker-compose.yml                    PostgreSQL para desenvolvimento local
├── Dockerfile                            imagem de produção (build da pipeline)
├── .github/workflows/ci-cd.yml           pipeline CI/CD (build + GitOps)
├── Gemfile / Gemfile.lock                dependências Ruby
└── README.md                             como rodar e como fazer deploy
```

## Como as peças se conectam

```
              config/routes.rb
                    │  (mapeia URL → ação)
                    ▼
   app/controllers/tarefas_controller.rb
                    │  (usa o model p/ ler/gravar)
                    ▼
        app/models/tarefa.rb
                    │  (mapeia p/ a tabela)
                    ▼
        tabela "tarefas" no PostgreSQL
        (definida por db/migrate/*_create_tarefas.rb
         e refletida em db/schema.rb)

   O controller então renderiza uma view de app/views/tarefas/
   e devolve HTML (ou JSON) para o navegador.
```

## Ambientes e banco

- **Desenvolvimento/Teste**: banco PostgreSQL local via `docker-compose.yml`
  (`localhost:5432`, usuário/senha `postgres`). Configurado em
  `config/database.yml`.
- **Produção**: banco definido por variáveis de ambiente (`DB_HOST`,
  `LISTA_DATABASE_PASSWORD`) — veja o bloco `production:` em
  `config/database.yml`. Os manifests Kubernetes ficam no repositório
  `lista-k8s`.
