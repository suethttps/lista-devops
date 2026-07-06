# Lista de Tarefas

Aplicação **Ruby on Rails 8** com um CRUD de tarefas e banco **PostgreSQL**,
pronta para subir na **AWS** usando **Kamal + Docker**.

- Model: `Tarefa` (`titulo`, `descricao`, `concluida`)
- CRUD completo (scaffold): listar, criar, ver, editar e excluir
- Rota raiz (`/`) aponta para a lista de tarefas
- Healthcheck em `/up`

## Requisitos

- Ruby 3.4.9 (veja `.ruby-version`)
- Docker (para o banco local e para o build da imagem)
- Uma conta no Docker Hub (registry das imagens)
- Uma instância EC2 na AWS com acesso SSH

---

## Desenvolvimento local

```bash
# 1. Instalar dependências
bundle install

# 2. Subir o PostgreSQL local (Docker)
docker compose up -d

# 3. Criar o banco e rodar as migrations
bin/rails db:prepare

# 4. Iniciar o servidor
bin/rails server
```

Acesse http://localhost:3000

Para parar o banco: `docker compose down` (mantém os dados) ou
`docker compose down -v` (apaga os dados).

---

## Deploy na AWS com Kamal

O Kamal builda a imagem Docker, envia para o registry, sobe a aplicação na EC2
e ainda roda o **PostgreSQL como container** na mesma máquina (accessory `db`).
Não é necessário RDS para começar.

### 1. Preparar a instância EC2

- Crie uma EC2 (Ubuntu 22.04+ ou Amazon Linux 2023) — uma `t3.small` já basta.
- Associe um **Elastic IP** (para o IP não mudar em reinícios).
- No **Security Group**, libere as portas de entrada:
  - `22` (SSH) — de preferência só do seu IP
  - `80` (HTTP)
  - `443` (HTTPS, se for usar domínio + SSL)
- Garanta que você consegue acessar via SSH: `ssh ubuntu@SEU_IP`
  (o Kamal instala o Docker na máquina automaticamente no primeiro deploy).

### 2. Ajustar `config/deploy.yml`

Troque os valores de exemplo:

| Campo | O que colocar |
|-------|---------------|
| `image` | `SEU_USUARIO_DOCKERHUB/lista` |
| `registry.username` | seu usuário do Docker Hub |
| `servers.web` | o **Elastic IP** da EC2 |
| `accessories.db.host` | o mesmo **Elastic IP** da EC2 |
| `ssh.user` (opcional) | `ubuntu` na maioria das AMIs (descomente o bloco `ssh:`) |

> A AMI padrão do Ubuntu usa o usuário `ubuntu` (não `root`). Descomente e ajuste
> no `deploy.yml`:
> ```yaml
> ssh:
>   user: ubuntu
> ```

Se tiver um **domínio**, descomente o bloco `proxy:` para SSL automático
(Let's Encrypt) e aponte o DNS do domínio para o Elastic IP.

### 3. Configurar os secrets

Copie o exemplo e preencha:

```bash
cp .env.example .env
```

Edite o `.env`:

```
POSTGRES_PASSWORD=uma-senha-forte-aqui
KAMAL_REGISTRY_PASSWORD=seu-docker-hub-access-token
```

- `POSTGRES_PASSWORD`: senha do banco (usada pelo container do Postgres **e**
  pela aplicação — as duas apontam para o mesmo valor em `.kamal/secrets`).
- `KAMAL_REGISTRY_PASSWORD`: gere um **Access Token** no Docker Hub
  (*Account Settings → Security → New Access Token*).

> O `.env` **não** é versionado. O `RAILS_MASTER_KEY` vem de `config/master.key`
> (também fora do git) — mantenha esse arquivo em local seguro.

### 4. Primeiro deploy

```bash
# Instala Docker na EC2, sobe o Postgres e a aplicação
bin/kamal setup
```

Nos deploys seguintes, basta:

```bash
bin/kamal deploy
```

O comando `setup`/`deploy` roda as migrations automaticamente
(`bin/docker-entrypoint` executa `db:prepare` no boot).

### 5. Acessar

- Sem domínio: `http://SEU_ELASTIC_IP`
- Com domínio + `proxy.ssl`: `https://seu-dominio`

---

## Comandos úteis do Kamal

```bash
bin/kamal deploy         # novo deploy
bin/kamal logs -f        # ver logs da aplicação
bin/kamal console        # rails console no servidor
bin/kamal shell          # bash dentro do container
bin/kamal dbc            # console do banco (psql)
bin/kamal app boot       # reiniciar a aplicação
bin/kamal rollback       # voltar para a versão anterior
```

---

## Como o banco funciona em produção

- O PostgreSQL roda como **accessory** do Kamal (container `lista-db`) na EC2.
- Os dados ficam num volume Docker (`data:/var/lib/postgresql/data`) que
  **sobrevive a redeploys**.
- No primeiro boot, `db/production_init.sql` cria os bancos auxiliares que o
  Rails 8 usa (Solid Cache, Solid Queue e Solid Cable).
- A aplicação encontra o banco pela variável `DB_HOST=lista-db` (rede interna
  do Docker gerenciada pelo Kamal).

> Para produção séria, considere migrar para o **Amazon RDS**: basta apontar
> `DB_HOST` para o endpoint do RDS e remover o accessory `db` do `deploy.yml`.
