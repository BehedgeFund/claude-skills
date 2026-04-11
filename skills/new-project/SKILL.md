---
name: new-project
description: Create a new Elixir/Phoenix/Ash project from scratch. Runs mix igniter.new with full Ash stack, creates docker-compose with unique PostgreSQL port, configures dev.exs, runs mix setup. Use when starting a brand new project.
---

# Create New Elixir/Phoenix/Ash Project

Creates a new project from scratch with the full stack ready to code.

## What you need from the user

1. **Project name** (snake_case, e.g. `my_app`)
2. **Where to create** (default: `~/Projects/`)
3. **Stack** — which of these to include:
   - Ash + AshPostgres + AshPhoenix (default: yes)
   - AshAuthentication + AshAuthenticationPhoenix (default: yes)
   - Oban (default: yes)
   - Other deps? (ask)

## Procedure

### Step 1: Choose unique ports

Scan `~/Projects/*/docker-compose.yml` for used PostgreSQL ports (pattern: `NNNN:5432`).
Scan `~/Projects/*/config/dev.exs` for used HTTP ports (pattern: `port: 4NNN`).

Pick the next free port for each:
- **DB port**: scan 5432-5500, pick first unused
- **HTTP port**: scan 4000-4100, pick first unused

Report chosen ports to user and confirm.

### Step 2: Create project

```bash
cd ~/Projects
mix igniter.new PROJECT_NAME \
  --install ash,ash_postgres,ash_phoenix,ash_authentication,ash_authentication_phoenix \
  --with phx.new \
  --yes
cd PROJECT_NAME
```

If user wants Oban, also add it after creation:
```bash
mix igniter.install oban --yes
```

### Step 3: Create docker-compose.yml

Create `docker-compose.yml` in project root:

```yaml
services:
  postgres:
    image: postgres:18-alpine
    container_name: PROJECT_NAME_db
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "CHOSEN_DB_PORT:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

Replace `PROJECT_NAME` and `CHOSEN_DB_PORT` with actual values.

### Step 4: Configure dev.exs

Update `config/dev.exs` to use the chosen ports:

**Database config** — find the `Repo` config block and set:
```elixir
port: CHOSEN_DB_PORT,
```

**HTTP config** — find the `Endpoint` config block and set:
```elixir
http: [ip: {127, 0, 0, 1}, port: CHOSEN_HTTP_PORT],
```

### Step 5: Start database and setup

```bash
docker compose up -d
mix setup
```

If `mix setup` fails on DB, check:
- Is docker running? (`docker compose ps`)
- Is port correct? (`docker compose logs postgres`)

### Step 6: Verify

```bash
mix compile --warnings-as-errors
mix test
```

### Step 7: Initialize git

```bash
git init
git add -A
git commit -m "Initial project: PROJECT_NAME with Ash/Phoenix/LiveView stack"
```

If user has a GitHub repo ready:
```bash
git remote add origin https://github.com/USER/REPO.git
git push -u origin main
```

### Step 8: Guide to next step

Tell the user:

```
Project created! Next steps:

1. Run /setup-project to install quality tools, plugins, conventions, and skills
2. Then start coding:
   /prd-generator    — create a PRD from your project plan
   /grill-me         — stress-test the plan
   /implementation-plan — break into tasks
   /autopilot        — start coding
```

## Rules

- ALWAYS scan existing ports before choosing — never hardcode
- Container name MUST be `projectname_db` (no hyphens in docker container names — replace with underscores)
- Never use port 5432 raw — always offset to avoid conflicts
- If `mix igniter.new` is not available, fall back to `mix phx.new` + manual dep installation
- Don't run `/setup-project` automatically — let the user decide when
