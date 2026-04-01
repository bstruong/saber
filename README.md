# Sphere — Relationship Intelligence CRM

A relationship-first CRM built in Ruby on Rails 8.1.

Inspired by Ninja Selling philosophy and Ryan Serhant's 
*Growing Your Sphere of Influence* — designed around relationship 
depth and life events, not deal stages and pipelines.

---

## The Problem

Existing real estate CRMs (Keller Williams Command, Lofty) are built 
for transaction pipelines. They optimize for deal stages, volume 
outreach, and branding.

Sphere is built for sphere-of-influence, referral-based relationship 
management. The data model reflects a fundamentally different 
philosophy — the absence of a deal stage field is a deliberate 
design decision.

---

## Technical Stack

- Ruby 3.4 / Rails 8.1.3
- PostgreSQL
- Hotwire (Turbo Streams + Stimulus) — Rails-native frontend, no React
- Sidekiq — background job processing for cadence recalculation
- Tailwind CSS
- RSpec

---

## Data Model

Four core entities:

**Contact** — relationship stage (acquaintance / friend / advocate), 
sphere category, touch history. No deal stage field — intentional.

**Interaction** — append-only event log. Calls, coffee, dinners, 
board games, housewarmings, handwritten notes, pop-bys. Enums stored 
as strings for DB readability.

**LifeEvent** — birthdays, job changes, new babies, anniversaries, 
relocations. Time-anchored, not recurring — recurrence handled at 
the query layer.

**TouchCadence** — computed next touch date per contact. Updated by 
an `after_create` callback on Interaction for MVP, migrating to a 
Sidekiq background job as the next layer.

String-backed enums throughout — readable directly in the DB, 
easier to debug than integer-mapped enums in a domain this 
relationship-focused.

---

## The Non-Trivial Layer

The cadence recalculation engine is what makes this non-trivial.

A background job that dynamically recalculates next touch dates based 
on relationship stage changes, interaction history, and life event 
proximity.

A contacts table with follow-up reminders is a todo list. A cadence 
engine that stays accurate as relationships evolve over time is a 
real scheduling and state management problem.

---

## MVP — "Who needs my attention today"

Dashboard that surfaces:
- Contacts past their touch frequency threshold
- Upcoming life events in the next 30 days

One Hotwire interaction built correctly: inline touch logging without 
a page reload via Turbo Frame + Turbo Stream. Contact slides off the 
dashboard when cadence is satisfied.

---

## Running Locally

Prerequisites: Ruby 3.3+, PostgreSQL, Redis
```bash
git clone git@github.com:bstruong/assassin.git
cd assassin
bundle install
rails db:create db:migrate
bin/dev
```

---

## Status

Active development. Sprint 1 target: April 2026 SF Ruby Meetup.

Next: Sidekiq cadence recalculation engine.
