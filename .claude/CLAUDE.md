# SABER — Personal relationship CRM with drift detection and outreach prompting

SABER tracks the people in your life, detects when relationships are drifting
based on a per-person cadence, and surfaces contextual prompts to reach out.
It is a personal tool for maintaining meaningful relationships — not a sales
tool, not a pipeline, not a marketing system.

The architecture and design decisions are locked in the design doc.
Support the build, do not redesign it.

---

## PROJECT CONTEXT

```
Track → Detect Drift → Prompt Outreach → Log Interaction
```

Each stage maps to a concrete system component:

| Stage | Component |
|---|---|
| Track | Person + ContactMethod + ImportantDate records |
| Detect Drift | DriftDetectionJob (Sidekiq, daily) |
| Prompt Outreach | Rule-based PromptGenerator + Reminder records |
| Log Interaction | Interaction POST → updates last_connected_at + dismisses Reminder |

### Storage layers

Five tables: `persons`, `contact_methods`, `important_dates`,
`interactions`, `reminders`

- `persons` — core record. Holds ring, connection score, cadence, last_connected_at
- `contact_methods` — polymorphic contact info, at least one required per person
- `important_dates` — month/day pairs for birthdays, anniversaries, etc.
- `interactions` — append-only. POST is the only write path that updates last_connected_at
- `reminders` — dismissed_at nil = active. Never hard-deleted

### Locked Architectural Principles

- **Drift detection is the differentiator.** The system computes relationship
  health — it doesn't just store data. DriftDetectionJob is the core of what
  elevates SABER beyond a CRUD app.
- **Effective cadence computed in one place.** cadence_override_days takes
  precedence over cadence_days. No caller computes this inline.
- **last_connected_at is the single source of truth.** Interaction POST is
  the only write path that updates it. Nothing else touches it.
- **Reminders are dismissed, never deleted.** dismissed_at.nil? = active.
  Append-only audit trail.
- **Rule-based prompt generation only.** No LLM in core logic. Deterministic,
  fast, no dependencies.
- **connection score computation lives in a service object, not the model.** Models
  are persistence only.
- **Single user.** Devise with registration disabled after setup. No
  multi-tenancy, no roles.
- **REST, not GraphQL.** Single client, fixed views, small entity set.
  GraphQL adds complexity without solving a real problem here.
- **Rails API mode.** No views, no asset pipeline. Forces clean separation
  from the React frontend.

### Stack

**Backend**
- Ruby on Rails 8 — API mode only
- PostgreSQL 16
- Sidekiq — background jobs (DriftDetectionJob)
- Devise — authentication, single user, registration disabled after setup
- rack-cors — CORS for local React dev
- RSpec + FactoryBot + Shoulda Matchers + Webmock — testing

**Frontend** (separate app in /client)
- Vite + React 19 + TypeScript
- Tailwind CSS v4
- shadcn/ui (Radix UI primitives)
- React Router v7 — file-based routing
- TanStack Query v5 — server state, caching, optimistic updates
- Vitest + React Testing Library + MSW v2 + Playwright — testing

**Deployment**
- Fly.io — Rails API + PostgreSQL (primary)
- Vercel — React frontend
- HTTPS enforced on both services

### Conventions

- Enums are string-backed. No integer enums.
- ActiveRecord is persistence only. Business logic lives in service objects.
- Effective cadence: `cadence_override_days || cadence_days`. Computed once,
  in one place, never inline by callers.
- connection score range: 5–20. Score → cadence mapping lives in a single
  authoritative location (service or constant), never duplicated.
- Reminder active check: `dismissed_at.nil?`. No scope that diverges from this.
- Interaction POST has two side effects: update last_connected_at on person,
  dismiss active reminder. Both happen in the same service call.
- DriftDetectionJob is idempotent. Never creates a duplicate active reminder
  for the same person.
- API routes namespaced under `/api/`. No unnamespaced routes.

### What SABER is NOT

- Not a sales pipeline
- Not lead tracking
- Not marketing automation
- Not a budgeting or financial tool
- Not multi-user
- Not LLM-dependent — prompt generation is rule-based, AI is not in the loop

---

## RUBY & RAILS STANDARDS

Generated code follows Sandi Metz and Russ Olsen idioms on the first
pass. Standards below are non-negotiable.

### Sandi Metz (POODR + 99 Bottles)

**SOLID:**
- Single Responsibility: one sentence, no "and"
- Tell, don't ask: send messages, don't pull state
- Depend on abstractions: inject collaborators
- Open/closed: extend through new objects

**Sizing:**
- Methods do one thing. Five-line ceiling.
- Classes are small. Ten-method ceiling.
- Conditional returning different types = two responsibilities.

**Naming:**
- Domain language describing *what*, not *how*
- No `Manager`, `Helper`, `Util`
- `?` for predicates, `!` for unsafe/mutating

**Dependency injection:**
```ruby
def initialize(detector: DriftDetector.new,
               notifier: ReminderNotifier.new)
  @detector = detector
  @notifier = notifier
end
```

**Conditionals:**
- Polymorphism over case-on-type
- Null objects over repeated nil checks
- Guard clauses, not nested ifs

**Tests:**
- Test public interface only
- Outgoing commands → mocks, outgoing queries → stubs, incoming
  messages → assert return values
- No private method tests

### Russ Olsen (Eloquent Ruby + Design Patterns in Ruby)

**Idiomatic Ruby:**
- Iterators over manual loops
- `tap` for side effects, `then` for transformations
- Blocks/procs/lambdas before classes
- `Struct` and `Data.define` for value objects
- Modules for mixins and namespacing

**Patterns (lighter than GoF):**
- Strategy = block or callable
- Template Method = `super` + hook methods
- Observer = ActiveSupport::Notifications
- Decorator = SimpleDelegator

**Convention over configuration:**
- Lean on Rails defaults
- Don't introduce abstractions Rails already provides

**DRY but not too dry:**
- Method extraction: cheap, do it
- Class extraction: Rule of Three (extract on third occurrence)

### Project specifics

- String-backed enums everywhere. `enum :ring, { inner_circle: "inner_circle", ... }, validate: true`
- ActiveRecord is persistence only. No business logic in models beyond
  validations, associations, and simple scopes.
- RSpec + FactoryBot + Shoulda Matchers + Webmock. No other test dependencies.
- Shoulda Matchers for validation and association specs — one-liners only,
  no prose assertions for what Shoulda covers.
- Webmock stubs all external HTTP in test. No live calls in specs.
- Sidekiq jobs: single responsibility. One job does one thing.
  Side-effect coordination (update person + dismiss reminder) lives in
  a service object called by the job, not in the job itself.
- Service objects: plain Ruby objects, no ActiveJob inheritance unless
  the class is literally a job. Callable via `.call` or `#call`.
- Factories are minimal. Traits for variations. No factory that creates
  associated records unless the association is required for validity.

### Idiom naming in code comments

When Sandi or Olsen patterns apply, name them as one-line code
comments at the top of the relevant method or class.

```ruby
# Single Responsibility — only detects drift
class DriftDetector
```

```ruby
# Tell, don't ask
contact.interaction_logged!
```

```ruby
# Strategy as callable (Olsen)
def initialize(cadence_rule: ->(person) { CadenceCalculator.call(person) })
```

If no idiom applies, skip the comment.

---

## CURRENT PHASE

### Phase 1 — Backend Foundation (M1–M4)

- **M1.0 — Rename + scaffold audit** ← ACTIVE
  - Rename project from ASSASSIN → SABER (all occurrences)
  - Audit scaffold against M1 requirements
  - Surface gaps, confirm next step before proceeding

- M1.1 — Schema + models
  - All 5 migrations
  - Models with validations, associations, string-backed enums

- M1.2 — Devise + seeds + RSpec setup
  - Single user, registration disabled
  - One realistic seed contact
  - RSpec + FactoryBot baseline

- M2 — Core API endpoints
  - Contacts CRUD, contact methods, important dates
  - connection score computation on save
  - Cadence derivation from score
  - Request specs

- M3 — Dashboard API + drift detection ← second demoable checkpoint
  - DriftDetectionJob (Sidekiq, daily, idempotent)
  - Rule-based PromptGenerator
  - GET /api/dashboard/reconnect + /upcoming
  - Reminder dismiss + snooze endpoints
  - Unit specs: score, cadence, prompt, snooze

- M4 — Interactions API
  - Interactions CRUD
  - POST side effects: last_connected_at + reminder dismissal
  - Side effect specs

### Phase 2 — Frontend (M5–M9)

- M5 — React scaffold (Vite + React 19 + TS, TanStack Query, AppLayout, auth)
- M6 — Dashboard UI ← lightning talk target
- M7 — Contact List UI
- M8 — Contact Detail UI
- M9 — Add / Edit Contact UI

### Phase 3 — Ship (M10–M11)

- M10 — Deployment (Fly.io + Vercel, HTTPS, Playwright E2E)
- M11 — Lightning talk prep (seed data, demo flow locked, README)

When a sub-phase is active, that is the active scope. Do not propose
work from a later sub-phase unless asked.
