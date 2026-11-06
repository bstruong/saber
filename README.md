# Ikigai CRM

Solo business CRM for founder prospecting and SOI networking. Capture leads from LinkedIn and YC Work at a Startup, score contacts on a 20-point card, log Hook/Help/Ask interactions, and keep a Sunday connection checklist.

## Tech stack

| Layer | Choice |
|---|---|
| App | Ruby on Rails 8.1 (Hotwire: Turbo + Stimulus) |
| Database | PostgreSQL 16 |
| Auth | Devise (single user, registration disabled) |
| CSS | Tailwind CSS (`tailwindcss-rails`) |
| Jobs | Sidekiq (SolidQueue migration deferred) |
| Testing | RSpec, FactoryBot, Shoulda Matchers, WebMock |

## Architecture

Two lead motions share one contact record:

1. **Prospecting** — manual capture from LinkedIn / Work at a Startup into a first-touch queue
2. **SOI networking** — rings, scorecard cadence, follow-up queue, Sunday checklist

```
Prospect capture → Prospect queue → First outreach → SOI cadence → Log interaction
```

No React client. Server-rendered HTML only.

## Local setup

Postgres defaults (see `config/database.yml`): `127.0.0.1:5433`, user/password `app`/`app`.

```bash
# Start Postgres (Docker Compose plugin optional)
docker run -d --name ikigai-postgres -p 5433:5432 \
  -e POSTGRES_USER=app -e POSTGRES_PASSWORD=app \
  -e POSTGRES_DB=ikigai_development postgres:16

bundle install
bin/rails db:prepare
bin/rails db:seed
bin/dev   # or: bin/rails server
```

Sign in as `owner@ikigai.local` / `password123`.

## Scope notes

Deferred: deals/contracts/income tools, LinkedIn/WAAS APIs, Pocket ID OIDC, production deploy.
