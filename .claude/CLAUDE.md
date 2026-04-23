# SABER — CLAUDE.md

## What This Is

SABER is a personal relationship CRM built on the principles of Ryan Serhant's
Sphere of Influence framework. It tracks people, detects when relationships are
drifting, and surfaces contextual prompts to reach out — not as a sales tool,
but as a personal tool to maintain meaningful relationships.

Brian's default is to spend time with family or keep to himself. SABER's job
is to tap him on the shoulder at the right moment and make reaching out feel
effortless, not obligatory.

---

## Tech Stack

### Backend
- Ruby on Rails 8 — API mode only (no views, no asset pipeline)
- PostgreSQL 16
- Sidekiq — background jobs
- Devise — authentication, single user, registration disabled after setup
- rack-cors — CORS for local React dev
- RSpec + FactoryBot + Shoulda Matchers + Webmock — testing

### Frontend (separate app in /client)
- Vite + React 19 + TypeScript
- Tailwind CSS v4
- shadcn/ui (Radix UI primitives)
- React Router v7 — file-based routing
- TanStack Query v5 — server state, caching, optimistic updates
- Vitest + React Testing Library + MSW v2 + Playwright — testing

### Deployment
- Fly.io — Rails API + PostgreSQL (primary)
- TBD — React frontend (evaluating Vercel, Fly.io, Cloudflare Pages)
- GCP (Cloud Run + Cloud SQL) — documented as secondary option for portfolio signal
- HTTPS enforced on both services
- Environment variables for all secrets, never in codebase

---

## Coding Standards

See detailed guidelines in:
- [`.claude/security.md`](.claude/security.md) — SQL injection prevention
- [`.claude/performance.md`](.claude/performance.md) — N+1 query prevention

---

## Design System

Primary: Sapphire `#0F52BA`
Secondary: Light grey `#F4F5F6`
Accent: Orange `#F47C20`
Sapphire dark: `#0A3D8F`
Sapphire subtle: `#EAF0FB`
Orange light: `#FEF0E6`
Orange dark: `#C45F0A`
Border: `rgba(0,0,0,0.09)`

Typography: System sans-serif, 13–16px, weights 400 and 500 only.
Corner radius: 8px components, 12px cards.
No gradients, no drop shadows, no decorative effects.

---

## Data Model

### persons
| column | type | notes |
|---|---|---|
| id | bigint PK | |
| name | string | required |
| ring | enum | board_of_advisors, network, community, audience, stranger |
| notes | text | standing context, life events, personality |
| needs | text | what they need + what they can offer |
| soi_score | integer | 5–20, computed from 5 dimensions |
| score_source | enum | computed, manual |
| cadence_days | integer | derived from soi_score |
| cadence_override_days | integer | nullable, manual override |
| last_contacted_at | datetime | nullable |
| relationship_tags | string[] | parent, spouse_partner, former_client, colleague, mentor, founder |
| cultural_tags | string[] | lunar_new_year, diwali, eid, hanukkah, kwanzaa |
| created_at / updated_at | datetime | |

### contact_methods
| column | type | notes |
|---|---|---|
| id | bigint PK | |
| person_id | bigint FK | |
| method_type | enum | linkedin, email, phone, twitter, instagram, other |
| value | string | handle, address, or number |

At least one contact method required per person. No specific type required.

### important_dates
| column | type | notes |
|---|---|---|
| id | bigint PK | |
| person_id | bigint FK | |
| name | string | Birthday, Home anniversary, etc. |
| month | integer | |
| day | integer | |

### interactions
| column | type | notes |
|---|---|---|
| id | bigint PK | |
| person_id | bigint FK | |
| interaction_type | enum | coffee, lunch, text, call, email, event, other |
| occurred_at | date | |
| notes | text | nullable |
| created_at | datetime | |

POST interaction updates person.last_contacted_at and dismisses active Reminder.

### reminders
| column | type | notes |
|---|---|---|
| id | bigint PK | |
| person_id | bigint FK | |
| reason | string | generated prompt text |
| due_at | date | |
| snoozed_until | date | nullable |
| dismissed_at | datetime | nullable — nil means active |
| created_at | datetime | |

---

## SOI Score Logic

Computed from 5 dimensions, each scored 1–4 (range: 5–20):

1. Importance to professional/networking goals — manual input
2. Ring — board_of_advisors=4, network=3, community=2, audience=1, stranger=1
3. Value exchange (bidirectional) — manual input
4. Interaction frequency last 6 months — computed from interactions table
5. Alignment with current objectives — manual input

Score → cadence mapping:
- 5–8 → 180 days
- 9–12 → 90 days
- 13–16 → 30 days
- 17–20 → 14 days

score_source is `computed` by default. User can override score manually — sets
score_source to `manual`. UI surfaces which contacts have been manually scored.

---

## Smart Snooze Logic

Snooze duration derived from ring (proportional to cadence):
- board_of_advisors → 3 days
- network → 7 days
- community → 14 days
- audience → 30 days

User can override snooze duration inline when tapping "Remind me later."
One tap accepts the smart default. Selector appears for custom window.

---

## Prompt Generation

Rule-based string templates. No LLM in this layer.

Priority order for prompt selection:
1. Upcoming important date within 14 days → date-specific template
2. Cultural tag event within 14 days → cultural event template
3. Relationship tag holiday within 14 days → e.g. Mother's Day from `parent` tag
4. `needs` field populated → needs-based template
5. `notes` field populated → context-based template
6. No context available → random low-pressure fallback
   (coffee, boba, lunch, board games, tennis — rotated, not repeated)

Prompt is editable inline on the dashboard card before acting on it.

---

## API Contract

### Auth
```
POST   /api/auth/sign_in
DELETE /api/auth/sign_out
GET    /api/auth/me
```

### Dashboard
```
GET    /api/dashboard/reconnect     # overdue, sorted by neglect + score
GET    /api/dashboard/upcoming      # events in next 30 days
```

### Contacts
```
GET    /api/contacts                # list — filterable by ring, upcoming_events, needs_reconnection
POST   /api/contacts                # create
GET    /api/contacts/:id            # detail
PATCH  /api/contacts/:id            # update
DELETE /api/contacts/:id            # soft delete
```

### Contact Methods
```
POST   /api/contacts/:id/contact_methods
DELETE /api/contacts/:id/contact_methods/:method_id
```

### Important Dates
```
POST   /api/contacts/:id/important_dates
DELETE /api/contacts/:id/important_dates/:date_id
```

### Interactions
```
GET    /api/contacts/:id/interactions
POST   /api/contacts/:id/interactions    # also updates last_contacted_at + dismisses reminder
```

### Reminders
```
GET    /api/reminders                    # active reminders
PATCH  /api/reminders/:id/dismiss
PATCH  /api/reminders/:id/snooze         # body: { days: N } — defaults to smart snooze
```

---

## Sidekiq Jobs

### DriftDetectionJob
- Runs daily at a fixed time (configurable via schedule)
- For each person: compare last_contacted_at against effective cadence
- If overdue and no active Reminder exists → create Reminder with generated prompt
- Idempotent — never creates duplicate active reminders for same person

---

## Milestone Roadmap

### M1 — Rails API foundation ← FIRST DEMOABLE CHECKPOINT
- Rails 8 API mode scaffold
- PostgreSQL schema — all 5 tables
- Models with validations and associations
- Devise — single user, registration disabled after setup
- rack-cors for local React dev
- Seeds — one real contact for testing
- RSpec + FactoryBot setup

### M2 — Core API endpoints
- Contacts CRUD
- Contact methods POST/DELETE
- Important dates POST/DELETE
- SOI score computation on contact save
- Cadence calculation from score
- Request specs

### M3 — Dashboard API ← SECOND DEMOABLE CHECKPOINT (drift detection story)
- DriftDetectionJob — daily, Sidekiq
- Smart snooze on Reminder model
- GET /api/dashboard/reconnect
- GET /api/dashboard/upcoming
- Rule-based prompt generation
- Reminder dismiss + snooze endpoints
- Unit specs for score, cadence, prompt, snooze

### M4 — Interactions API
- Interactions CRUD per contact
- POST updates last_contacted_at + dismisses Reminder
- Interaction side effect specs

### M5 — React frontend foundation
- Vite + React 19 + TypeScript scaffold in /client
- Tailwind v4 + shadcn/ui
- React Router v7 file-based routes
- TanStack Query v5 + API client
- AppLayout + Sidebar (collapse/expand + localStorage)
- Login screen + protected routes

### M6 — Dashboard UI ← LIGHTNING TALK TARGET
- DashboardPage + StatCards
- ReconnectCard + PromptEditor
- LogInteractionInline + optimistic card removal
- TagList +N more expand/collapse
- Remind me later — smart snooze with override
- Component tests

### M7 — Contact List UI
- ContactListPage + search + filter chips + sort
- ContactTable + ContactRow
- Default sort: most neglected
- Filter/sort tests

### M8 — Contact Detail UI
- ContactDetailPage — two column layout
- ContactProfile + SOIScoreBar with override
- ImportantDatesList with urgency badges
- InteractionTimeline + InteractionEntry
- SOIScoreBar tests

### M9 — Add / Edit Contact UI
- ContactFormPage — add + edit modes
- ContactMethodEditor — dynamic, validates one present
- RingSelector + TagSelector
- ImportantDatesEditor
- Form component tests

### M10 — Deployment
- Fly.io — Rails API + PostgreSQL
- TBD — React frontend (evaluating Vercel, Fly.io, Cloudflare Pages)
- HTTPS enforced, env vars configured
- Devise registration disabled
- Fly.io volume snapshots enabled
- GCP deployment documented as secondary option
- Playwright E2E happy paths
- Smoke test end-to-end in production

### M11 — SF Ruby lightning talk prep
- 10–15 realistic seed contacts across all rings
- Verify all prompt fallback cases
- Dashboard demo flow locked
- Cultural event demo (Lunar New Year)
- Snooze override demo
- README written for public repo

---

## Key Design Decisions and Rationale

**Why Rails API mode, not full Rails?**
No views needed. API mode is tighter, faster, forces clean separation from React.

**Why separate services, not Vite inside Rails?**
Industry standard in 2026. Rails + React as separate deployments is what
interviewers expect and what most companies run.

**Why REST, not GraphQL?**
Single client, fixed views, small entity set. GraphQL's flexibility adds
complexity without solving a real problem. GraphQL is a deferred option for
ARCHER which has heterogeneous asset classes and variable query shapes.

**Why rule-based prompts, not LLM?**
Deterministic, fast, no dependencies, no latency, no cost. Ship first, experiment
with LLMs after the core loop is proven.

**Why smart snooze, not fixed?**
Snooze duration proportional to cadence keeps the system coherent. Snoozing a
board of advisors contact for a month defeats the purpose.

**Why Fly.io over GCP for primary deployment?**
30 minute setup vs 2–4 hours. $0–5/month vs $20–40/month. GCP documented as
secondary option for portfolio signal, not primary deployment target.

---

## What's Deferred

- LLM prompt generation — rule-based ships first
- Mobile responsive layout — desktop first, responsive pass post-M10
- Multiple users — single user by design
- Email/push notifications — in-app only for now
- GraphQL — not justified for SABER (single client, fixed views, REST is correct)
