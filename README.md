# Lista de Tarefas

Aplicação **Ruby on Rails 8** com um CRUD de tarefas e banco **PostgreSQL**.

O deploy é feito via **pipeline (GitHub Actions) + GitOps com ArgoCD** — sem Kamal.
A infraestrutura e os manifests Kubernetes ficam no repositório **`lista-k8s`**.

- Model: `Tarefa` (`titulo`, `descricao`, `concluida`)
- CRUD completo (scaffold): listar, criar, ver, editar e excluir
- Rota raiz (`/`) aponta para a lista de tarefas
- Healthcheck em `/up` (usado pelas probes do Kubernetes)

> 📚 Documentação técnica detalhada (arquitetura, estrutura, modelo de dados e
> rotas) em [`docs/`](docs/README.md).

## Requisitos

- Ruby 3.4.9 (veja `.ruby-version`)
- Docker + Docker Compose (para subir o banco local e buildar a imagem)

## Desenvolvimento local

### 1. Instalar dependências

```bash
bundle install
```

### 2. Subir o PostgreSQL local (Docker)

O banco de desenvolvimento roda em um container via `docker-compose.yml`:

```bash
docker compose up -d      # sobe o Postgres em background
docker compose ps         # confere se o container está "healthy"/rodando
```

O container expõe o Postgres em `localhost:5432` com as credenciais padrão:

| Variável | Valor padrão |
|----------|--------------|
| `DB_HOST` | `localhost` |
| `DB_PORT` | `5432` |
| `DB_USER` | `postgres` |
| `DB_PASSWORD` | `postgres` |
| Banco (dev) | `lista_development` |
| Banco (test) | `lista_test` |

Essas variáveis já são os defaults em `config/database.yml`, então **não é
necessário configurar nada** para rodar localmente. Se precisar apontar para
outro Postgres (porta ou credenciais diferentes), copie `.env.example` para
`.env` e sobrescreva os valores.

### 3. Criar o banco e rodar as migrations

```bash
bin/rails db:prepare      # cria o banco (se não existir) e roda as migrations
```

### 4. Iniciar o servidor

```bash
bin/rails server
```

Acesse http://localhost:3000

### Rodar os testes

```bash
bin/rails db:prepare RAILS_ENV=test   # prepara o banco de teste (lista_test)
bin/rails test
```

### Parar o banco

```bash
docker compose down       # para o banco e mantém os dados
docker compose down -v    # para o banco e APAGA os dados (volume pg_data)
```

## Deploy (pipeline + GitOps)

O deploy é automático. Todo `git push` na branch `main` dispara o workflow
`.github/workflows/ci-cd.yml`, que:

1. roda o smoke test da aplicação;
2. builda a imagem Docker e publica no Docker Hub (`usuario/lista:latest` e `:SHA`);
3. atualiza a tag da imagem no repositório GitOps (`lista-k8s`) via `kustomize`.

O **ArgoCD** detecta o commit no `lista-k8s` e aplica no cluster Kubernetes.

### Secrets necessários (Settings → Secrets and variables → Actions)

| Secret | Descrição |
|--------|-----------|
| `DOCKERHUB_USERNAME` | usuário do Docker Hub |
| `DOCKERHUB_TOKEN` | Access Token do Docker Hub |
| `GITOPS_REPO` | `SEU_USUARIO/lista-k8s` |
| `GITOPS_TOKEN` | PAT do GitHub com push no `lista-k8s` |

### Provisionar a AWS e o cluster

Toda a infraestrutura (EC2 + k3s + ArgoCD) e os manifests Kubernetes, junto com
o **passo a passo completo**, estão no repositório **`lista-k8s`** (Terraform
incluído — você não precisa criar nada do zero na AWS). Veja o `README.md` de lá.

## Imagem Docker

O `Dockerfile` (gerado pelo Rails 8) builda a imagem de produção: expõe a porta
80 via Thruster e roda `db:prepare` no entrypoint (migrations automáticas).
É essa imagem que a pipeline publica e o Kubernetes executa.

```bash
# build local (opcional)
docker build -t lista .
```
