# SABER — Personal relationship CRM with drift detection and outreach prompting

SABER tracks the people in your life, detects when relationships are drifting
based on a per-person cadence, and surfaces contextual prompts to reach out.
It is a personal tool for maintaining meaningful relationships — not a sales
tool, not a pipeline, not a marketing system.

The architecture and design decisions here are locked. Support the build,
do not redesign it.

---

## Architecture

```
Track → Detect Drift → Prompt Outreach → Log Interaction
```

Each stage maps to a concrete system component:

| Stage | Component |
|---|---|
| Track | Person + ContactMethod + ImportantDate records |
| Detect Drift | DriftDetectionJob (SolidQueue, daily) |
| Prompt Outreach | Rule-based PromptGenerator + Reminder records |
| Log Interaction | Interaction POST → updates last_connected_at + dismisses Reminder |

**Drift detection is implemented and working, not just designed.**
`DriftDetector` (service), `DriftDetectionJob` (job), `PromptGenerator`,
`Person.needs_reconnection` scope, and `Reminder` creation all exist and
are exercised by their own specs. `DriftDetector#remind` guards on
`person.reminders.active.exists?` before creating — the idempotency
guarantee is real, not aspirational. This is the project's strongest
interview-defensibility hook, and it holds up: the system genuinely
computes relationship health, it doesn't just store data.

### Locked Architectural Principles

- **Drift detection is the differentiator.** DriftDetectionJob is the
  core of what elevates this beyond a CRUD app.
- **Effective cadence computed in one place.** `cadence_override_days`
  takes precedence over `cadence_days`. No caller computes this inline.
- **last_connected_at is the single source of truth.** An Interaction
  POST is the only write path that updates it. Nothing else touches it.
- **Reminders are dismissed, never deleted.** `dismissed_at.nil?` =
  active. Append-only audit trail.
- **Rule-based prompt generation only.** No LLM in core logic.
  Deterministic, fast, no dependencies.
- **Connection score computation lives in a service object, not the
  model.** Models are persistence only.
- **Single user, registration disabled after setup.** See Known Issues
  below for current vs. target auth implementation.
- **REST, not GraphQL.** Single client, fixed views, small entity set.
- **Rails API mode.** No views, no asset pipeline. Clean separation from
  the React frontend.

---

## Tech Stack

**Backend**
- Ruby on Rails 8.1 — API mode only
- PostgreSQL 16
- SolidQueue — locked background-job backend (see Known Issues — the
  migration to it is incomplete and currently blocks production boot)
- Devise — current auth implementation (see Known Issues for the locked
  target)
- rack-cors — CORS for local frontend dev
- RSpec + FactoryBot + Shoulda Matchers + Webmock — testing

**Frontend** (separate app in `/client`, not bundled into the backend)
- Vite + React 19 + TypeScript
- Tailwind CSS v4
- shadcn/ui (Radix UI primitives)
- React Router v7 — file-based routing
- TanStack Query v5 — server state, caching, optimistic updates
- Vitest + React Testing Library + MSW v2 + Playwright — testing
- Auth today: plain email/password form against Devise JSON session
  endpoints. No OIDC redirect flow exists in the client yet.

**Deployment target:** Fly.io (API + Postgres) + Vercel (frontend), with
GCP documented as a secondary alternative. See Known Issues — none of
this is built yet.

### Conventions

- Enums are string-backed. No integer enums.
- ActiveRecord is persistence only. Business logic lives in service objects.
- Effective cadence: `cadence_override_days || cadence_days`. Computed
  once, in one place, never inline by callers.
- Connection score range: 5–20. Score → cadence mapping lives in a
  single authoritative location, never duplicated.
- Reminder active check: `dismissed_at.nil?`. No scope that diverges
  from this.
- Interaction POST has two side effects: update `last_connected_at` on
  the person, dismiss the active reminder. Both happen in the same
  service call.
- DriftDetectionJob is idempotent. Never creates a duplicate active
  reminder for the same person.
- API routes namespaced under `/api/`. No unnamespaced routes.

---

## Data Model

Six tables: `persons`, `contact_methods`, `important_dates`,
`interactions`, `reminders`, `users`.

- `persons` — core record. Holds ring, connection score, cadence, `last_connected_at`.
- `contact_methods` — polymorphic contact info, at least one required per person.
- `important_dates` — month/day pairs for birthdays, anniversaries, etc.
- `interactions` — append-only. POST is the only write path that updates `last_connected_at`.
- `reminders` — `dismissed_at` nil = active. Never hard-deleted.
- `users` — Devise-backed. Single user; registration and password-reset
  routes are explicitly disabled.

---

## Current Phase

**Phase 1 — Backend Foundation (M1–M4) — Done.** Schema, models, Devise
auth, People/ContactMethods/ImportantDates CRUD, connection score and
cadence computation, DriftDetectionJob + PromptGenerator + reminder
dismiss/snooze, Interactions API with append-only audit trail.

**Phase 2 — Frontend (M5–M9):**
- M5 — React scaffold — Done
- M6 — Dashboard UI — Done
- **M7 — Contact List UI — Active**
- M8 — Contact Detail UI — Planned
- M9 — Add / Edit Contact UI — Planned

**Phase 3 — Ship (M10–M11) — Planned.** Deployment (M10) and
demo/lightning-talk prep (M11). Neither has started; M10 is additionally
blocked by the job-backend issue below.

When a sub-phase is active, that is the active scope. Do not propose
work from a later sub-phase unless asked.

---

## Known Issues

### Job backend: SolidQueue is the locked target — Sidekiq is being removed

SolidQueue is the target background-job backend, not Sidekiq. Reasoning:
this project is single-user with low background-job volume (periodic
drift detection, not high throughput), so Sidekiq's Redis dependency
isn't justified at this scale. The default Rails 8 SolidQueue setup
(queue schema, secondary queue database) is already partially present in
the repo, so finishing that setup is less work than finishing a Sidekiq
migration — and it drops Redis as a dependency entirely.

**Current state still crashes production boot**, because the migration
is incomplete in both directions at once: production config already
points at `:solid_queue`, but the `solid_queue` gem itself isn't in the
Gemfile yet (only `sidekiq` is bundled), so evaluating the production
environment config raises at boot regardless of which backend is
intended. The existing SolidQueue-shaped schema/database config is
partial progress toward the target and should be kept, not deleted.

Remaining work (not yet done):
1. Add the `solid_queue` gem to the Gemfile
2. Set the SolidQueue adapter application-wide, not just in the
   production environment config
3. Remove the `sidekiq` gem and its config, and any other
   Sidekiq-specific references
4. Verify the Puma-supervisor setting for running SolidQueue's
   supervisor is actually correct for how the app will run it

This blocks containerization/deployment (M10) until resolved.

### Auth: Devise is implemented; Pocket ID OIDC is the locked target, not started

Devise is fully implemented today, end to end — backend session auth and
a frontend email/password login against it. Registration and
password-reset routes are disabled, enforcing the single-user model.

The locked target is migrating to Pocket ID OIDC, matching the auth
pattern of a sibling project. This is a made decision, but as of now
**zero code has changed toward it** — no OIDC/OmniAuth gem, no routes,
no client-side redirect flow. Treat this migration as not started, not
partially done, anywhere in this repo.

"Registration disabled post-setup, single user" needs to hold under
either scheme — currently enforced via Devise's disabled routes; will
need re-enforcing under Pocket ID OIDC (e.g. an allow-listed
subject/email) once that migration starts.

### Deployment gap: platform is decided, nothing is built

Fly.io (API + Postgres) and Vercel (frontend) are the decided deployment
targets — the frontend-hosting decision specifically is locked in over
alternatives. But nothing in the repo implements this yet: no Fly
config, no Vercel config. A Kamal deploy config exists but is
unconfigured placeholder scaffolding, unrelated to the actual deployment
plan. Deployment (M10) is planned, not started, and is additionally
blocked by the job-backend issue above.

---

## What SABER Is NOT

- Not a sales pipeline
- Not lead tracking
- Not marketing automation
- Not a budgeting or financial tool
- Not multi-user
- Not LLM-dependent — prompt generation is rule-based, AI is not in the loop

---

## Working Agreement

These constraints apply to any agent working in this repository.

**Write-first: interview-relevant code belongs to the project owner.**
The owner writes all service objects, migrations, and test assertions
themselves — this is deliberate, to keep those skills sharp rather than
offload them. This applies specifically to the future Pocket ID OIDC
migration too: when that work starts, the strategy/integration code is
the owner's to write.

An agent may draft:
- Config files (Rails config, CI config, linter config, Kamal/Docker manifests)
- Test scaffolding *skeletons* — `describe`/`context` blocks, factory
  structure — but not the assertions inside them
- DB seeds (`db/seeds.rb`) — data, not domain logic
- Boilerplate (Gemfile entries, README updates, directory scaffolding)
- For the OIDC migration specifically: a Devise-removal checklist,
  gem/config scaffolding, and test skeletons — not the auth logic itself

An agent must **never** write, in full or in a form that would just be
accepted as-is:
- Service object bodies (`DriftDetector`, `PromptGenerator`,
  `ConnectionScoreCalculator`, `InteractionLogger`, `UpcomingView`, any
  future OIDC integration code, etc.)
- Migrations
- Test assertions (the `expect(...)` lines — scaffolding around them is fine)

**Rhythm: propose → review → micro-step.** Work in small proposed steps
with an explicit pause between them for review, not large unreviewed
jumps. Don't chain several implementation steps together and present
them as one fait accompli — stop after each step and let the owner look
before continuing.

**`# TODO(owner): implement this` markers.** When a marker like this is
left in code, it means that piece is the owner's to fill in. Never come
back later and autonomously implement what a marker was holding open —
it exists specifically to preserve that implementation path. Leave it
alone unless explicitly asked to fill it in.
