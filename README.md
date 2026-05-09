# Personal Relationship Manager: Rails 8 API + React 19

A personal tool for tending the relationships that matter. Records the people you know, your interactions with them, the life events that shape those relationships, and how long it has been since you last connected.

---

## Tech Stack

### Backend
| | |
|---|---|
| **Runtime** | Ruby on Rails 8 — API mode |
| **Database** | PostgreSQL 16 |
| **Background jobs** | Sidekiq |
| **Auth** | Devise — single user, registration disabled after setup |
| **CORS** | rack-cors |
| **Testing** | RSpec, FactoryBot, Shoulda Matchers, WebMock |

### Frontend (`/client`)
| | |
|---|---|
| **Framework** | Vite + React 19 + TypeScript |
| **Styling** | Tailwind CSS v4 + shadcn/ui (Radix UI) |
| **Routing** | React Router v7 — file-based |
| **Server state** | TanStack Query v5 |
| **Testing** | Vitest, React Testing Library, MSW v2, Playwright |

### Deployment
| | |
|---|---|
| **API** | Fly.io |
| **Frontend** | TBD — evaluating Vercel, Fly.io, Cloudflare Pages |
| **Alt (documented)** | GCP — Cloud Run + Cloud SQL |

---

## Architecture

Rails API and React frontend are deployed as separate services — the industry standard for teams running heterogeneous clients or independent release cadences. Rails runs in API-only mode with no views or asset pipeline. The React app talks to it over REST.

**Why REST over GraphQL?** Single client, fixed views, small entity set. GraphQL's flexibility solves a problem this project doesn't have.

**Why rule-based prompts over LLM?** Deterministic, fast, zero external dependencies, zero latency, zero cost. The core loop ships first; LLM experimentation comes after it's proven.

**Why Fly.io over GCP as primary?** 30-minute setup vs 2–4 hours. $0–5/month vs $20–40/month. GCP is documented as a secondary deployment option for portfolio signal.

---

## Data Model

Five tables: `persons`, `contact_methods`, `important_dates`, `interactions`, `reminders`.

Each person has a connection score (5–20) computed across five dimensions — ring (how close), interaction frequency, reciprocity (mutual support), personal importance, and shared values. The score sets a connection cadence (14–180 days). A daily Sidekiq job notices when a relationship has gone quiet and creates a reminder with rule-based prompt text — a small, contextual nudge to reconnect.

---

## Running Locally

**Prerequisites:** Ruby 3.4+, PostgreSQL 16, Redis

```bash
git clone git@github.com:bstruong/saber.git
cd saber
bundle install
rails db:create db:migrate db:seed
bin/dev
```

API available at `http://localhost:3000`.

Frontend (separate):
```bash
cd client
npm install
npm run dev
```

UI available at `http://localhost:5173`.

---

## Status

| Milestone | Description | Status |
|---|---|---|
| M1 | Rails API foundation — schema, models, auth, testing setup | Done |
| M2 | Core API endpoints — people CRUD, connection score, cadence | Done |
| M3 | Dashboard API — drift detection, reminders, prompt generation | Done |
| M4 | Interactions API — append-only with side-effect coordination | Done |
| [M5](https://github.com/bstruong/saber/milestone/1) | React frontend foundation | **Active** |
| [M6](https://github.com/bstruong/saber/milestone/2) | Dashboard UI | Planned |
| [M7](https://github.com/bstruong/saber/milestone/3) | Contact List UI | Planned |
| [M8](https://github.com/bstruong/saber/milestone/4) | Contact Detail UI | Planned |
| [M9](https://github.com/bstruong/saber/milestone/5) | Add/Edit Contact UI | Planned |
| [M10](https://github.com/bstruong/saber/milestone/6) | Production deployment — Fly.io + frontend | Planned |
| [M11](https://github.com/bstruong/saber/milestone/7) | Lightning talk prep | Planned |

Active work, design decisions, and open mockup questions are tracked in [issues](https://github.com/bstruong/saber/issues) (grouped by milestone) and the [SABER project board](https://github.com/users/bstruong/projects/1). Cross-project view: [Personal Workboard](https://github.com/users/bstruong/projects/3).
