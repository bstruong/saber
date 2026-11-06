# Ikigai CRM — Solo founder prospecting & SOI networking

Ikigai CRM helps a solo operator capture founders from LinkedIn and YC Work at
a Startup, score the circle of influence, log Hook/Help/Ask interactions, and
keep a Sunday connection checklist. It is **not** a deals/revenue/pipeline tool.

The architecture below is locked. Support the build; do not redesign it.

---

## Architecture

Two equal lead motions share one `Contact` record:

```
Prospect capture → Prospect queue → First outreach → SOI cadence → Log interaction
```

| Motion | Components |
|---|---|
| Prospecting | `ProspectCapture`, `Contact.prospects`, Prospecting Hotwire page |
| SOI networking | Scorecard → `follow_up_frequency` / `next_follow_up_due`, Dashboard due queue, Sunday checklist |
| Log interaction | `InteractionLogger` — only write path for `last_contacted_at` |

### Locked principles

- **Manual prospect capture only.** No LinkedIn/WAAS APIs, scraping, or auto-DM.
- **Prospects** = `source` in `linkedin` / `work_at_a_startup` AND `last_contacted_at` nil.
- **Scorecard computed in one place.** `ScorecardCalculator` owns total score, frequency, and `next_follow_up_due`.
- **`last_contacted_at` single write path.** Only `InteractionLogger` updates it.
- **Models are persistence.** Business logic lives in service objects.
- **String-backed enums only.**
- **Migrations via Rails generators only.** Fill generated migration bodies; do not invent migration files from scratch without `bin/rails generate migration|model`.
- **Single user.** Devise registration/password routes disabled.
- **Hotwire only.** No React / Node client. REST JSON API removed.
- **No money scope.** No deal values, deposits, capacity, or revenue widgets.

### Scorecard → cadence

Dimensions (1–4 each): goal importance, ring level, value exchange, past
interaction frequency, objective alignment. Total 4–20.

| Score | Frequency |
|---|---|
| 17–20 | weekly |
| 13–16 | monthly |
| 9–12 | quarterly |
| 4–8 | semi_annual |

---

## Tech stack

- Ruby on Rails 8.1 — full stack Hotwire (Turbo + Stimulus)
- PostgreSQL 16, UUID PKs on domain tables
- Tailwind CSS (`tailwindcss-rails`)
- Devise HTML sessions
- Sidekiq present; SolidQueue migration still deferred
- RSpec + FactoryBot + Shoulda Matchers + Webmock

---

## Data model

- `contacts` — identity, `profile_url`, `source`, `soi_ring`, scorecard, cadence timestamps, notes
- `interactions` — type + hook/help/ask notes; belongs to contact
- `sunday_checklists` — one row per `week_of` (Monday) with five booleans
- `users` — Devise

---

## Screens

Nav: **Dashboard · Prospecting · Contacts**

1. Prospecting — LinkedIn + WAAS capture panels + prospect queue
2. Dashboard — prospect pulse, SOI due queue, Sunday checklist
3. Contacts — filterable directory + detail (scorecard, log interaction)

---

## Explicitly deferred

- Deals / contracts / projected income / Kanban
- LinkedIn/WAAS automation
- Pocket ID OIDC, Fly/Vercel deploy, SolidQueue gem finish
- Multi-user

---

## Working agreement

Agents may implement domain services, migrations (via generators), views, and
tests for this product. Prefer small reviewable steps when the owner asks for
propose → review rhythm; otherwise complete the requested scope.
