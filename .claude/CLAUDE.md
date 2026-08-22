# SABER — Personal relationship CRM with drift detection and outreach prompting

SABER tracks the people in your life, detects when relationships are drifting
based on a per-person cadence, and surfaces contextual prompts to reach out.
It is a personal tool for maintaining meaningful relationships — not a sales
tool, not a pipeline, not a marketing system.

The architecture and design decisions are locked in the design doc.
Support the build, do not redesign it.

Related reference docs in `.claude/`: `performance.md` (N+1 / query
guidelines), `security.md` (SQL injection / parameterization rules). Both
still current as of this audit — not duplicated here.

---

## PROJECT CONTEXT

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

**Confirmed implemented, not just designed.** `DriftDetector` (service),
`DriftDetectionJob` (job), `PromptGenerator`, `Person.needs_reconnection`
scope, and `Reminder` creation all exist and are exercised by
`spec/services/drift_detector_spec.rb` and
`spec/jobs/drift_detection_job_spec.rb`. `DriftDetector#remind` guards on
`person.reminders.active.exists?` before creating — the idempotency
guarantee is real, not aspirational. This is the project's strongest
interview-defensibility hook, and it's real.

### Storage layers

Six tables: `persons`, `contact_methods`, `important_dates`,
`interactions`, `reminders`, `users` (Devise).

- `persons` — core record. Holds ring, connection score, cadence, last_connected_at
- `contact_methods` — polymorphic contact info, at least one required per person
- `important_dates` — month/day pairs for birthdays, anniversaries, etc.
- `interactions` — append-only. POST is the only write path that updates last_connected_at
- `reminders` — dismissed_at nil = active. Never hard-deleted
- `users` — Devise: `database_authenticatable`, `recoverable`, `rememberable`,
  `validatable`. Single user; registrations and passwords routes explicitly
  skipped in `config/routes.rb`.

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
- **Single user, registration disabled after setup.** Currently enforced via
  Devise (`skip: [:registrations, :passwords]` in routes). See AUTHENTICATION
  below — the locked target is Pocket ID OIDC, not yet implemented.
- **REST, not GraphQL.** Single client, fixed views, small entity set.
  GraphQL adds complexity without solving a real problem here.
- **Rails API mode.** No views, no asset pipeline. Forces clean separation
  from the React frontend.

### Stack

**Backend**
- Ruby on Rails 8.1 — API mode only (`config.api_only = true`)
- PostgreSQL 16
- SolidQueue — locked background-job backend. Chosen over Sidekiq: SABER
  is single-user with low job volume (periodic drift detection, not high
  throughput), so Sidekiq's Redis dependency isn't justified at this
  scale, and Rails 8's default SolidQueue setup (already partially
  present in this repo) is less work to finish than a Sidekiq migration
  — plus it drops Redis as a dependency entirely. See KNOWN ISSUES —
  production boot currently still broken while this migration is
  incomplete.
- Devise — current auth implementation. See AUTHENTICATION.
- rack-cors — CORS for local React dev
- RSpec + FactoryBot + Shoulda Matchers + Webmock — testing

**Frontend** (separate app in `/client`, not Vite-inside-Rails)
- Vite + React 19 + TypeScript
- Tailwind CSS v4
- shadcn/ui (Radix UI primitives)
- React Router v7 — file-based routing
- TanStack Query v5 — server state, caching, optimistic updates
- Vitest + React Testing Library + MSW v2 + Playwright — testing
- Auth today: plain email/password form → Devise JSON session endpoints
  (`client/src/auth/hooks.ts`, `client/src/api/users.ts`). No OIDC
  redirect flow exists in the client yet.

**Deployment (documented target, not yet built)**
- Fly.io — Rails API + PostgreSQL (primary, per README)
- Vercel — React frontend (locked over Fly.io/Cloudflare Pages, see M10
  decision below)
- GCP (Cloud Run + Cloud SQL) — documented alternative, portfolio signal only
- Nothing in-repo yet implements any of this: no `fly.toml`, no Vercel
  config. `config/deploy.yml` (Kamal) is present but is unconfigured
  `rails new` scaffold (placeholder IP `192.168.0.1`, placeholder registry
  `localhost:5555`) — it is not wired to any of the above and Kamal isn't
  actually part of the deployment plan. M10 (production deployment) is
  explicitly "Planned," not started.

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

## AUTHENTICATION

**Currently implemented: Devise**, end to end — backend
(`config/initializers/devise.rb`, `User` model, `devise_for :users` in
routes with `registrations`/`passwords` skipped, custom
`Api::SessionsController` returning JSON) and frontend (plain
email/password login, session cookie via `ActionDispatch::Session::CookieStore`
re-added to the API-only middleware stack in `config/application.rb`).

**Locked target: Pocket ID OIDC**, matching ASSASSIN's auth pattern — this
is a made decision, but as of this audit **zero code has changed toward
it**. Confirmed by direct check: no `omniauth`/`oidc`/`pocket_id` gem in
`Gemfile`, no matching entries in `Gemfile.lock`, no routes, no
initializer beyond Devise's default (unused, commented-out) OmniAuth
boilerplate, and no open or closed GitHub issue mentions it. Do not treat
this migration as in progress or partially done anywhere in this repo —
it exists only as a decision outside the codebase until work starts here.

"Registration disabled post-setup, single user" holds under either auth
scheme — currently enforced via Devise's skipped registration routes; will
need re-enforcing under Pocket ID OIDC once that migration starts (e.g. an
allow-listed subject/email rather than a Devise route skip).

---

## KNOWN ISSUES

### Job backend: SolidQueue is the locked target — Sidekiq is being removed (still crashes production boot)

**Reversed from a previous version of this file.** That version had
Sidekiq as the locked backend and treated Solid Queue as unwanted
`rails new` leftover scaffolding to be deleted. That direction is now
wrong — the decision has flipped. Corrected here; do not re-introduce
the old direction.

**New decision: SolidQueue is the target, Sidekiq is what gets removed.**
Reasoning: SABER is single-user with low background-job volume (periodic
drift detection, not high throughput), so Sidekiq's Redis dependency
isn't justified at this scale. The repo's `db/queue_schema.rb` and the
`queue:` block in `config/database.yml` are already partially set up for
SolidQueue — that's Rails 8's default, generated by `rails new` and never
removed — so finishing that setup is less work than finishing a Sidekiq
migration, and it removes Redis as a dependency entirely.

**Current state, reframed against the new target — still broken today,
for the same underlying reasons, now read in the opposite direction:**

- `config/application.rb` sets `config.active_job.queue_adapter =
  :sidekiq` — this is the line that now needs to change, to
  `:solid_queue`.
- `config/environments/production.rb` already sets
  `config.active_job.queue_adapter = :solid_queue` and
  `config.solid_queue.connects_to = { database: { writing: :queue } }` —
  this is now correct *in direction* for the target backend, but it's
  still what crashes production boot today, because:
- **`solid_queue` is not in the Gemfile or Gemfile.lock at all** — only
  `sidekiq` is bundled. `config.solid_queue` is a config namespace
  defined by the solid_queue railtie; with the gem absent, evaluating
  `production.rb` still raises at boot (`NoMethodError` / equivalent)
  regardless of which backend is the intended target.
- `db/queue_schema.rb` (full `solid_queue_*` table set) and the `queue:`
  secondary database in `config/database.yml`
  (`saber_production_queue`) are **not** leftover scaffold to delete —
  they're partial progress toward the new target and should stay.
- `bin/jobs` requires `solid_queue/cli` and calls `SolidQueue::Cli.start`
  — once the gem is actually added, this becomes correct rather than
  broken.
- `config/deploy.yml` (Kamal) sets `SOLID_QUEUE_IN_PUMA: true` — do not
  remove this. Its correctness for the actual run mode (SolidQueue
  supervisor in-process with Puma vs. a separate `bin/jobs` process)
  still needs verifying, not deleting.
- `config/sidekiq.yml` and the `sidekiq` gem are now the leftovers to
  remove, along with any other Sidekiq-specific references.

**Net effect: this app still cannot boot in production as currently
configured** — same failure as before, opposite fix. Documented here per
instruction — not fixed; Brian writes this migration. Remaining work:

1. Add the `solid_queue` gem to the Gemfile
2. Set `config.active_job.queue_adapter = :solid_queue` in
   `config/application.rb` (not just `production.rb`)
3. Remove the `sidekiq` gem and `config/sidekiq.yml`, and any other
   Sidekiq-specific config/references
4. Verify `SOLID_QUEUE_IN_PUMA` in `config/deploy.yml` is actually
   correct for how the app will run SolidQueue's supervisor

This still blocks containerization/deployment (M10) until resolved.

### CLAUDE.md phase tracking had drifted

The previous version of this file said M5 (React scaffold) was ACTIVE.
Actual state, confirmed against README's status table and git log: M1–M6
are Done, M7 (Contact List UI) is Active. Corrected below.

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
- Background jobs (SolidQueue): single responsibility. One job does one
  thing. Side-effect coordination (update person + dismiss reminder)
  lives in a service object called by the job, not in the job itself.
- Service objects: plain Ruby objects, no ActiveJob inheritance unless
  the class is literally a job. Callable via `.call` or `#call`.
- Factories are minimal. Traits for variations. No factory that creates
  associated records unless the association is required for validity.

### Idiom naming in code comments

When Sandi or Olsen patterns apply, name them as one-line code
comments at the top of the relevant method or class. Confirmed in
active use (e.g. `DriftDetector`: `# Single Responsibility — only creates
reminders for drifted people`, `# Strategy as callable - generator
injected for specs`).

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

### Phase 1 — Backend Foundation (M1–M4) — DONE

- M1 — Rename to SABER, schema (5 migrations + Devise), models with
  string-backed enums, Devise (single user), RSpec + FactoryBot baseline
- M2 — People CRUD, contact methods, important dates, connection
  score computation, cadence derivation
- M3 — DriftDetectionJob (SolidQueue, daily, idempotent), rule-based
  PromptGenerator, GET /api/dashboard/{reconnect,upcoming}, reminder
  dismiss + snooze
- M4 — Interactions API (index/show/create + member void),
  InteractionLogger service, append-only with `voided_at` flag, MAX
  semantics on `last_connected_at` (backdated entries never move it
  backward), score/cadence untouched by interactions

### Phase 2 — Frontend (M5–M9)

- M5 — React scaffold (Vite + React 19 + TS, TanStack Query, AppLayout,
  Devise-backed auth shell) — **Done**
- M6 — Dashboard UI (stat cards, reconnect card list, log/snooze actions
  inline) — **Done**
- **M7 — Contact List UI** ← ACTIVE (per README status table and latest
  commit)
- M8 — Contact Detail UI — Planned
- M9 — Add / Edit Contact UI — Planned

### Phase 3 — Ship (M10–M11)

- M10 — Deployment (Fly.io + Vercel, HTTPS, Playwright E2E) — Planned.
  Frontend host decision is locked (Vercel, issue #32 closed); nothing
  else in this phase has started. The solid_queue/Sidekiq conflict above
  blocks this until resolved.
- M11 — Lightning talk prep (seed data, demo flow locked, README) — Planned

When a sub-phase is active, that is the active scope. Do not propose
work from a later sub-phase unless asked.

All design-decision issues for M1–M9 (25 of them) are closed — resolved
decisions are in git history / GitHub issue history, not repeated here.
