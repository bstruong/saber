# SABER — UI Mockup Specs

> Generated from wireframes designed in Claude.ai prior to implementation.
> Wireframes are saved as HTML files in `docs/design/`.
> Reference those files alongside this spec while building.

---

## Vocabulary Changes

This document was updated after the backend refactor to canonical, non-sales
vocabulary. The changes below were applied wholesale across both `mockups.md`
and the HTML wireframes. Every instance has been swapped.

| Was | Now | Notes |
|---|---|---|
| Contact (entity, singular) | Person | Backend model is `Person` |
| Contacts (entity, plural) | People | Page title, list noun |
| SOI score | Connection score | Range unchanged: 5–20 |
| Board of advisors (ring) | Inner circle | Closest, most strategic relationships |
| Audience (ring) | Acquaintances | Peripheral, low-touch |
| Add contact (button) | Add person | |
| Contacts (page title) | People | |
| `/contacts` | `/people` | Route |
| `/contacts/new` | `/people/new` | Route |
| `/contacts/:id` | `/people/:id` | Route |
| `/contacts/:id/edit` | `/people/:id/edit` | Route |
| `ContactListPage` (component) | `PeopleListPage` | |
| `ContactRow` (component) | `PersonRow` | |
| `ContactTable` (component) | `PeopleTable` | |
| `ContactDetailPage` (component) | `PersonDetailPage` | |
| `ContactProfile` (component) | `PersonProfile` | |
| `ContactFormPage` (component) | `PersonFormPage` | |
| `ContactSearchBar` (component) | `PeopleSearchBar` | |
| `SOIScoreBar` (component) | `ConnectionScoreBar` | |

### What stays as-is (deliberately)

| Term | Reason |
|---|---|
| Contact info (section label) | `ContactMethod` is the backend model — LinkedIn, email, phone, etc. |
| How to reach them (section label) | Section title for contact methods card |
| `ContactMethodEditor` (component) | Manages `ContactMethod` records, not Person entity |
| `ContactMethodRow` (component) | Same as above |

### Other sales-CRM smell — audit results

The full document was reviewed for additional sales-CRM language. Findings:

| Term | Where | Status |
|---|---|---|
| `Former client` → `Past client` | Relationship tag option in Add/Edit Person form | Renamed. Slightly softer framing while keeping the legitimate real-estate meaning Brian needs. |
| `sales pipeline` | Negative framing in Do-Not-Do section of OS doc | No change — used to describe what SABER explicitly is not. |
| `prospecting`, `lead`, `deal`, `account`, `prospect` | Searched, not present | None found in mockups or wireframes. |
| `champion`, `customer`, `outreach` | Searched, not present | None found in user-facing copy. |
| `Sphere of influence`, `circle` | Used throughout | These come from Serhant's framework and are the preferred framing — the opposite of sales-CRM language. |

All sales-CRM vocabulary decisions are resolved. `Former client` was renamed to
`Past client` to soften the framing while preserving the real-estate meaning.

---

## Inventory

| Filename | Description | Milestone |
|---|---|---|
| `dashboard.html` | Dashboard — reconnect cards, stat cards, inline log interaction expanded | M6 |
| `sidebar-states.html` | Sidebar expanded vs collapsed states side by side | Cross-cutting |
| `people-list.html` | People list — search, filter chips, sort, table rows | M7 |
| `person-detail.html` | Person detail — two-column layout, profile, connection score, timeline | M8 |
| `add-edit-person.html` | Add/edit person form — progressive fields, ring selector, tag selector | M9 |
| `index.html` | Navigation index linking all wireframes | Reference |

---

## Cross-Cutting: Sidebar

> Reference: `sidebar-states.html`

### Screen / route
Persistent — renders on every authenticated screen.

### Layout
Two states. Toggle button in same position in both states.

**Expanded (200px):**
- Top section: logo text "SABER" left-aligned, hamburger toggle button right-aligned
- Divider below logo
- Nav items: icon + label, stacked vertically with 4px gap
- Bottom section: separated by divider, "Add person" nav item

**Collapsed (52px):**
- Top section: hamburger toggle button centered
- Divider
- Nav items: icon only, centered
- Bottom section: plus icon only, centered

### Components
- Custom `Sidebar` component — owns expand/collapse state
- No shadcn primitives required at this layer
- Icons: simple SVG glyphs (grid for dashboard, lines for people, plus for add)
- Tooltip (shadcn) — appears on hover over each icon in collapsed state, shows label

### Copy
- Logo: `SABER`
- Nav items: `Dashboard`, `People`, `Add person`
- Collapsed tooltip labels: same as expanded labels

### Interactions
- Click toggle button → expand or collapse sidebar
- Hover over icon in collapsed state → tooltip appears with label
- Click any nav item → navigate to that route
- State persisted to `localStorage` key `saber_sidebar_collapsed`
- On mount: read localStorage, restore last state

### States
- **Expanded** — default on first visit (no localStorage value)
- **Collapsed** — icon rail only, tooltips on hover
- No loading or error states — purely client-side UI

### Open questions
- None. Behavior fully locked.

---

## M6 — Dashboard

> Reference: `dashboard.html`

### Screen / route
`/` (Dashboard)

### Layout
**Page header row:**
- Left: greeting text `Good morning, Brian`
- Right: `+ Add person` button (orange, primary)

**Stat cards row (3 columns, equal width, 10px gap):**
1. Label: `Time to reconnect` / Value: count (orange)
2. Label: `Coming up soon` / Value: count (sapphire)
3. Label: `In your circle` / Value: count (sapphire)

**Section label:**
- Uppercase, muted, small caps: `Reconnect`

**Reconnect card list (stacked, 10px gap):**
Each card is a white rounded card, no left border accent.

**Card — default state (collapsed):**
- Row: avatar (36px circle, initials) | content area
- Content top row: name (bold) | tags row (ring badge + event badge + optional +N more pill)
- Content second row: time-since subtitle (muted, small)
- Content third row: prompt textarea (editable, grey background, full width)
- Content action row: `We connected` button (orange) | `Remind me later` button (ghost)

**Card — expanded state (after tapping "We connected"):**
- Default card content remains visible above
- Expanded section below (separated by divider, slightly off-white background, left-padded to align with content):
  - Label: `How did it go? Anything worth remembering?`
  - Textarea: multi-line, placeholder text
  - Action row: `Save` button (sapphire) | `Cancel` button (ghost)

### Components
- shadcn `Card` — each reconnect card
- shadcn `Button` — `+ Add person` (variant: default, orange), `We connected` (orange), `Remind me later` (ghost), `Save` (sapphire), `Cancel` (ghost)
- shadcn `Textarea` — prompt editor, note input
- Custom `Avatar` — initials circle, color derived from name hash
- Custom `RingBadge` — pill per ring type with correct background
- Custom `EventBadge` — pill for upcoming date, urgency label if within 14 days
- Custom `TagList` — renders ring badge + first event badge + +N more pill, owns expand state
- Custom `StatCards` — three metric cards
- Custom `DashboardPage` — owns fetch, loading, error
- Custom `ReconnectCard` — owns prompt edit + expanded note state
- Custom `PromptEditor` — inline textarea, saves on blur
- Custom `LogInteractionInline` — expanded section, owns note state

### Copy
**Static:**
- Page greeting: `Good morning, [first name]`
- Stat labels: `Time to reconnect`, `Coming up soon`, `In your circle`
- Section label: `Reconnect`
- Action buttons: `We connected`, `Remind me later`, `Save`, `Cancel`
- Expanded section label: `How did it go? Anything worth remembering?`
- Add person button: `+ Add person`

**Dynamic (generated):**
- Time since: `Haven't talked in [N] days` or `[Event] in [N] days · [N] days since you connected`
- Prompt text: generated by rule-based system from notes/needs/upcoming dates. See prompt generation priority order in CLAUDE.md.
- Note textarea placeholder: example of rich note — e.g. `e.g. Grabbed boba at Boba Guys. He just got promoted...`

**Ring badge labels:** `Inner circle`, `Network`, `Community`, `Acquaintances`, `Stranger`

### Interactions
**Prompt editor:**
- Click textarea → editable
- Type to edit generated prompt
- Blur (click away) → saves edited prompt to reminder record

**"We connected" button:**
- Click → card expands inline, note textarea appears
- Does not remove card yet — waits for Save

**Save (after expanding):**
- POST `/api/people/:id/interactions` with note and type
- On success → card removes from list (optimistic with `useOptimistic`)
- On error → card remains, error state shown inline

**Cancel:**
- Click → collapse back to default card state, no API call

**"Remind me later":**
- Click → shows snooze duration selector inline (small, below button)
- Default option pre-selected based on smart snooze (derived from ring)
- Options: smart default (labeled with days) + manual alternatives
- Confirm → PATCH `/api/reminders/:id/snooze`, card removes from list

**+ Add person button:**
- Click → navigate to `/people/new`

**Avatar / card body click:**
- Click anywhere on card body (not buttons) → navigate to `/people/:id`

**+N more pill:**
- Click → expands to show all event badges inline

### States
**Loading:** Skeleton cards in place of real cards. Stat card values show `—`.

**Empty (no overdue people):** Illustration or simple message — `You're all caught up.` Subtext: `Check back tomorrow or add someone new.`

**Error (API failure):** Inline error message below header — `Couldn't load your people. Try refreshing.`

**Card save error:** Inline below Save button — `Something went wrong. Try again.`

### Open questions
- Does the greeting change based on time of day (Good morning / afternoon / evening) or is it always "Good morning"?
- Should the "Coming up soon" stat card link to a filtered view, or is it purely informational?
- What is the exact copy for the empty state?

---

## M7 — People List

> Reference: `people-list.html`

### Screen / route
`/people`

### Layout
**Page header row:**
- Left: `People` page title
- Right: `+ Add person` button (orange)

**Toolbar row:**
- Search input (flex 1, with search icon glyph inside left edge)
- Sort select (right of search, fixed width)

**Filter chips row:**
- Horizontal scrolling pill row: `All` | `Inner circle` | `Network` | `Community` | `Acquaintances` | `Upcoming events` | `Time to reconnect`
- `All` active by default (sapphire background, sapphire border)
- Inactive chips: white background, grey border

**People table:**
- White card, full width, rounded corners
- Table header row: muted uppercase labels — (empty) | `Name` | `Ring` | `Last connected` | `Upcoming` | (empty)
- Grid columns: `36px 2fr 1fr 1fr 1.2fr 80px`
- Person rows: hover state (grey background)
- Row dividers between rows, no divider after last row
- Count label below table: `Showing N of N people`

**Person row contents:**
- Avatar (30px, initials)
- Name (bold, 14px) + contact handle or email or phone (muted, 12px, below name)
- Ring badge pill
- Last connected (date relative, e.g. `94 days ago` — orange/bold if overdue)
- Upcoming event badge or `—` if none
- `View` button (ghost, small)

### Components
- shadcn `Input` — search bar
- shadcn `Button` — `+ Add person` (orange), `View` (ghost, small), filter chips (can use Button variant=outline)
- shadcn `Select` — sort dropdown
- Custom `PeopleListPage` — owns filter, sort, search state
- Custom `PeopleSearchBar` — controlled input, emits query
- Custom `FilterChips` — pill row, active state from parent
- Custom `PeopleTable` — renders rows
- Custom `PersonRow` — single row, navigates on click
- Custom `Avatar` (shared)
- Custom `RingBadge` (shared)
- Custom `EventBadge` (shared)

### Copy
**Static:**
- Page title: `People`
- Add button: `+ Add person`
- Search placeholder: `Search by name, handle, or notes...`
- Sort options: `Sort: Most neglected`, `Sort: Last connected`, `Sort: Name`, `Sort: Ring`
- Filter chips: `All`, `Inner circle`, `Network`, `Community`, `Acquaintances`, `Upcoming events`, `Time to reconnect`
- Table headers: `Name`, `Ring`, `Last connected`, `Upcoming`
- Row action: `View`
- Count: `Showing [N] of [N] people`

**Dynamic:**
- Last connected: `[N] days ago` or `[N] months ago`
- No event: `—`

### Interactions
**Search:**
- Type in search → filters rows client-side by name, handle, notes
- Debounced — 200ms before filtering

**Filter chips:**
- Click chip → sets active filter, deactivates others
- `All` → no filter applied
- Ring filters → show only that ring
- `Upcoming events` → people with important date or cultural event within 30 days
- `Time to reconnect` → people where last_connected_at is past cadence

**Sort select:**
- Change → re-sorts rows in place
- `Most neglected` — days since contact vs cadence, descending
- `Last connected` — last_connected_at ascending
- `Name` — alphabetical
- `Ring` — ring priority order (inner circle first)

**Person row:**
- Click anywhere on row → navigate to `/people/:id`
- Click `View` button → same as row click

**+ Add person:**
- Click → navigate to `/people/new`

### States
**Loading:** Table skeleton — 5 placeholder rows with shimmer.

**Empty (no people):** Message centered in table area — `No people yet.` Button: `Add your first person`.

**Empty (filtered, no results):** `No people match your filters.` Link: `Clear filters`.

**Error:** Inline above table — `Couldn't load people. Try refreshing.`

### Open questions
- Does search hit the API (server-side) or filter client-side? For 38 people client-side is fine. At what count does it need to go server-side?
- Should filter chips be mutually exclusive or can you combine (e.g. Network + Upcoming events)?

---

## M8 — Person Detail

> Reference: `person-detail.html`

### Screen / route
`/people/:id`

### Layout
**Page header:**
- Back button: `← People` (sapphire text link, no border)

**Two-column content grid (280px left | 1fr right, 16px gap):**

**Left column (stacked cards, 16px gap):**

*Card 1 — Profile:*
- Top section: avatar (48px) | name (bold 15px) | time-since subtitle (muted) | `Edit` button (ghost, small, right-aligned)
- Divider
- Section label: `Contact info`
- Field rows: label (90px fixed, muted) | value (right-aligned, link color if clickable)
- Divider
- Section label: `Relationship`
- Ring row: label | ring badge value
- Connection score row: label | progress bar (flex 1) | score number (sapphire bold)
- Score source row: (empty label) | `Computed ·` text + `Override` underline link
- Divider
- Section label: `Cadence`
- Suggested row: label | value (e.g. `Every 30 days`)
- Override row: label | `Set custom cadence` underline link

*Card 2 — Notes:*
- Section label: `Notes`
- Paragraph text (muted, 12px, line-height 1.6)
- Divider
- Section label: `Needs + can offer`
- Paragraph text

*Card 3 — Important dates:*
- Section label: `Important dates`
- Date rows: event name (left) | date + optional urgency badge (right)
- `+ Add date` link below list

**Right column:**

*Card — Interaction timeline:*
- Header row: `Interaction history` title | `We connected` button (orange)
- Timeline: vertical list, each item has dot + vertical line connector
- Most recent dot: filled sapphire circle
- Older dots: hollow circle (grey border)
- Last item: no vertical line below dot
- Each timeline item: date (muted) + type badge (grey pill) top row | note text below

### Components
- shadcn `Card` — all cards
- shadcn `Button` — `Edit` (ghost small), `We connected` (orange), `+ Add date` (link style), `Override` (link style), `Set custom cadence` (link style)
- shadcn `Progress` (or custom bar) — Connection score visualization
- shadcn `Badge` — interaction type badges on timeline
- Custom `PersonDetailPage` — owns all person data, optimistic update after log
- Custom `PersonProfile` — left column card 1
- Custom `ConnectionScoreBar` — bar + number + source + override inline input
- Custom `ImportantDatesList` — dates with urgency badges, add inline
- Custom `InteractionTimeline` — right column card
- Custom `InteractionEntry` — single timeline item
- Custom `EventBadge` (shared)
- Custom `RingBadge` (shared)
- Custom `Avatar` (shared)

### Copy
**Static:**
- Back link: `← People`
- Edit button: `Edit`
- Section labels: `Contact info`, `Relationship`, `Cadence`, `Notes`, `Needs + can offer`, `Important dates`, `Interaction history`
- Field labels: `LinkedIn`, `Email`, `Phone`, `Twitter / X`, `Instagram`, `Ring`, `Connection score`, `Suggested`, `Override`
- Score source: `Computed ·` + `Override` (underlined link). When manually set: `Manual ·` + `Reset to computed` (underlined link).
- Cadence override: `Set custom cadence` (underlined link)
- Add date: `+ Add date`
- We connected button: `We connected`

**Dynamic:**
- Time since: `Haven't talked in [N] days`
- Connection score: integer 5–20
- Score source: `Computed` or `Manual`
- Suggested cadence: `Every [N] days`
- Contact info values: handle or email or phone per method type
- Important dates: name + `[Month] [Day]` + optional urgency badge
- Timeline: date formatted `[Month] [Day], [Year]` + interaction type + notes text

### Interactions
**Edit button:**
- Click → navigate to `/people/:id/edit`

**Contact info links:**
- LinkedIn/Twitter/Instagram handle → opens in new tab if URL, copies to clipboard if just handle
- Email → `mailto:` link
- Phone → `tel:` link

**Override (Connection score):**
- Click `Override` → inline input appears replacing score bar, pre-filled with current score
- Input: number field, 5–20 range
- Confirm → PATCH `/api/people/:id` with manual score, score_source set to `manual`
- Cancel → collapse back to score bar display

**Set custom cadence:**
- Click → inline input appears, number field (days)
- Save → PATCH `/api/people/:id` with cadence_override_days
- Clear override → removes cadence_override_days, reverts to system cadence

**+ Add date:**
- Click → appends inline input row: name text field + month/day field + confirm/cancel
- Confirm → POST `/api/people/:id/important_dates`
- Cancel → removes inline row

**We connected:**
- Same behavior as dashboard card — expands log interaction inline below button
- On save: POST interaction, updates last_connected_at, dismisses active reminder
- Timeline refreshes with new entry at top

**Back link:**
- Click → navigate to `/people` (back to people list)

### States
**Loading:** Left column skeleton cards. Right column placeholder timeline items.

**Empty timeline:** `No interactions logged yet.` Subtext: `Tap 'We connected' after your next catch-up.`

**Empty notes/needs:** Muted placeholder text — `No notes yet.` with an edit link.

**Error:** Inline above content — `Couldn't load person. Try refreshing.`

**Score override active:** Score bar replaced by number input with confirm/cancel.

**Cadence override active:** Suggested cadence row replaced by number input with save/clear/cancel.

### Open questions
- Should interaction type be selectable when logging from Person Detail, or does it default to a type (e.g. `other`) and the user edits after?
- What happens when you click a contact info value that's a raw handle (not a URL)? Copy to clipboard with a toast confirmation?
- Should notes and needs fields be inline-editable on Person Detail, or always go through the Edit form?
- Is there a delete person option? Where does it live — Edit form or Person Detail?

---

## M9 — Add / Edit Person

> Reference: `add-edit-person.html`

### Screen / route
- Add: `/people/new`
- Edit: `/people/:id/edit`

### Layout
**Page header:**
- Back link: `← People`
- Page title: `Add person` or `Edit person`

**Two-column form grid (1fr 1fr, 16px gap):**

**Left column (stacked cards):**

*Card 1 — Basic info:*
- Section label: `Basic info`
- Name field: label + text input, placeholder `Full name`

*Card 2 — How to reach them:*
- Section label: `How to reach them`
- Dynamic list of type+value rows:
  - Each row: type select (100px) | value input (flex 1) | remove button (×, 20px circle)
  - Type options: `LinkedIn`, `Email`, `Phone`, `Twitter / X`, `Instagram`, `Other`
- `+ Add another` link below rows
- Hint text: `Add at least one. Social handle is enough to get started.`

*Card 3 — Ring:*
- Section label: `Ring`
- Pill group: `Inner circle` | `Network` | `Community` | `Acquaintances` | `Stranger`
- Single select — one active at a time
- Active: sapphire background + border + bold text
- Inactive: white + grey border
- Hint text: `Determines suggested outreach cadence. You can change this anytime.`

*Card 4 — Relationship tags:*
- Section label: `Relationship tags`
- Multi-select pill group: `Parent` | `Spouse / partner` | `Past client` | `Colleague` | `Mentor` | `Founder`
- Active: orange-light background + orange border
- Inactive: white + grey border
- Hint text: `Used to surface Father's Day, Mother's Day, and other relevant prompts.`

**Right column (stacked cards):**

*Card 1 — Notes:*
- Section label: `Notes`
- Textarea (4 rows), placeholder: `Who are they? Personality, preferences, how you met, anything worth remembering...`

*Card 2 — Needs + can offer:*
- Section label: `Needs + can offer`
- Textarea (4 rows), placeholder: `What do they need help with? What can they offer you or others in your circle?`

*Card 3 — Important dates:*
- Section label: `Important dates`
- Dynamic list of date rows:
  - Each row: name input (flex 1) | month/day input (110px, format `MM / DD`) | remove button (×)
- `+ Add date` link below rows
- Divider
- Section label: `Cultural celebrations`
- Multi-select pill group: `Lunar New Year` | `Diwali` | `Eid` | `Hanukkah` | `Kwanzaa`
- Active: light blue background + sapphire border
- Inactive: white + grey border
- Hint text: `SABER will surface a reconnect prompt before these dates automatically.`

*Card 4 — Connection score notice:*
- Single row: `Connection score will be computed after saving.`
- Muted text, no input

**Form footer (below right column, right-aligned):**
- `Cancel` button (ghost) | `Save person` button (sapphire, primary)

### Components
- shadcn `Card` — all cards
- shadcn `Input` — name, value fields, date fields
- shadcn `Textarea` — notes, needs
- shadcn `Label` — all field labels
- shadcn `Button` — `Save person` (sapphire), `Cancel` (ghost), `+ Add another` (link), `+ Add date` (link), remove × (ghost small circle)
- shadcn `Select` — contact method type selector per row
- Custom `PersonFormPage` — owns full form state, POST or PATCH on save
- Custom `ContactMethodEditor` — dynamic rows, validates at least one present (manages `ContactMethod` records — name preserved)
- Custom `RingSelector` — pill group, single select
- Custom `TagSelector` — multi-select pill group, used for relationship tags and cultural tags
- Custom `ImportantDatesEditor` — dynamic rows

### Copy
**Static:**
- Back link: `← People`
- Page titles: `Add person` / `Edit person`
- Section labels: `Basic info`, `How to reach them`, `Ring`, `Relationship tags`, `Notes`, `Needs + can offer`, `Important dates`, `Cultural celebrations`
- Field label: `Name`
- Name placeholder: `Full name`
- Value placeholder: `Handle or value`
- Date name placeholder: `e.g. Birthday, Home anniversary`
- Date value placeholder: `MM / DD`
- Add links: `+ Add another`, `+ Add date`
- Hint texts as specified in Layout section above
- Connection score notice: `Connection score will be computed after saving.`
- Buttons: `Cancel`, `Save person`
- Ring options: `Inner circle`, `Network`, `Community`, `Acquaintances`, `Stranger`
- Relationship tags: `Parent`, `Spouse / partner`, `Past client`, `Colleague`, `Mentor`, `Founder`
- Cultural celebrations: `Lunar New Year`, `Diwali`, `Eid`, `Hanukkah`, `Kwanzaa`

**Type select options:** `LinkedIn`, `Email`, `Phone`, `Twitter / X`, `Instagram`, `Other`

### Interactions
**Name field:**
- Standard text input, required for save

**Contact method rows:**
- `+ Add another` → appends a new type+value row, type defaults to next unused type
- Remove × → removes that row. Cannot remove if only one row remains (button disabled or hidden)
- Type select change → updates that row's type, no other effect

**Ring selector:**
- Click pill → selects it, deselects previously selected
- One pill must always be selected — no deselect-to-none

**Relationship tag pills:**
- Click → toggles on/off independently
- Multiple can be active simultaneously
- Click active pill → deactivates it

**Cultural celebration pills:**
- Same behavior as relationship tags — multi-select toggles

**Important dates rows:**
- `+ Add date` → appends name input + date input + remove button
- Remove → removes that row
- Date input: MM / DD format, validated as real date on save

**Cancel:**
- Navigate back to `/people` (add mode) or `/people/:id` (edit mode)
- No confirmation dialog unless form has been touched

**Save person:**
- Validate: name present, at least one contact method with a value
- On validation failure: inline error below the failing field, no submit
- POST `/api/people` (add) or PATCH `/api/people/:id` (edit)
- On success: navigate to `/people/:id` for the saved person
- On API error: inline error below Save button, form remains

**Edit mode pre-population:**
- All existing fields pre-filled on mount
- Contact methods pre-populated with existing rows
- Ring pre-selected
- Tags pre-activated
- Dates pre-populated

### States
**Loading (edit mode):** Form skeleton while person data loads.

**Validation error:** Red border on failing field + error message below (e.g. `At least one contact method is required.`, `Name is required.`)

**Save loading:** Save button shows `Saving...` text, disabled. Cancel remains active.

**Save error:** Inline below Save button — `Something went wrong. Try again.`

**Save success:** Navigate away — no success state visible on this screen.

**Empty date row:** Name and date fields both empty — remove button present, not validated until Save.

### Open questions
- Should `Name` be a single field or split into first/last? Single field is simpler and flexible (handles "Dr. Patricia Chen" or just "James").
- When editing, should removing a contact method that is the last remaining one be blocked with a disabled button, or show an error only on save attempt?
- Is there a confirmation dialog when canceling an edit with unsaved changes?
- Should `Founder` in relationship tags surface any specific prompts, or is it purely a tag for context?
- Cultural celebrations list — is this fixed or should there be a freeform `+ Add custom` option?

---

## Design Decisions to Lock

These questions are not answered by any single mockup. They affect every screen
and should be resolved before M6 implementation begins.

### Typography
- Font stack not specified. System font stack (`-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif`) is implied by the mockups. Confirm or specify a custom font (e.g. Inter).
- Font size scale in use: 11px (labels/hints), 12px (body/secondary), 13px (inputs/prompts), 14px (names), 15px (detail page name), 16px (page titles), 22px (stat values). Confirm these map to Tailwind classes cleanly under v4.

### Spacing scale
- Card padding: 1.25rem (20px)
- Gap between stacked cards: 1rem (16px)
- Gap between sections within a card: 12px
- Gap between field label and input: 5px
- Gap between inline tags: 6–8px
- Confirm these are expressed as Tailwind utilities and not arbitrary values.

### Color usage rules
- Sapphire (`#0F52BA`) — sidebar background, primary action (Save), active states, links, score bar fill, stat values
- Orange (`#F47C20`) — primary CTA (`+ Add person`, `We connected`), time-to-reconnect stat value
- Light grey (`#F4F5F6`) — page background, input backgrounds, table header background
- White — card backgrounds, inactive pill backgrounds
- Orange is never used for destructive actions. Confirm what color destructive actions (delete, remove) use — likely red, not yet designed.

### Empty state philosophy
- Empty states are not designed yet (open question on Dashboard).
- Establish a consistent pattern: illustration vs icon vs text-only.
- Copy tone: warm and low-pressure, consistent with the app's voice.
- Every screen needs an empty state: Dashboard (no overdue people), People List (no people, no filter results), Person Detail timeline (no interactions), Important dates (no dates).

### Error state philosophy
- All errors shown inline, never as modal dialogs.
- API errors shown above or below the triggering action.
- Validation errors shown below the specific field.
- Confirm: is there a global toast/notification system, or purely inline errors?

### Avatar color generation
- Initials circle color is derived from name hash — not designed explicitly.
- Confirm: how many distinct avatar colors? The mockups show sapphire-subtle, orange-light, green-light, purple-light, pink-light (5 colors). The algorithm should produce one of N colors deterministically from the name string.

### Relative time formatting
- `Haven't talked in 94 days` — confirm the threshold at which this switches format: days → weeks → months?
- `Last connected: 94 days ago` in People List — same question.
- Confirm library or hand-rolled: `date-fns` is the standard in 2026, already compatible with Vite.

### Destructive actions
- Delete person is not designed. Confirm: where does it live (Edit form footer? Person Detail overflow menu?) and what confirmation pattern (inline confirmation vs dialog)?
- Remove contact method and remove date row use a × button — confirm these are immediate (no confirmation) given they are reversible before Save.

### Interaction type selection
- When logging from Dashboard or Person Detail, the mockup shows `We connected` with a note but no type selector visible in the collapsed expand state.
- Confirm: is type selected during log (requires a select in the expanded area) or does it default to `other` and the user can edit from the timeline?

### Route structure
- `/` — Dashboard
- `/people` — People list
- `/people/new` — Add person
- `/people/:id` — Person detail
- `/people/:id/edit` — Edit person
- `/login` — Sign in (not designed, Devise-backed)

### Snooze UI
- "Remind me later" snooze selector appears inline below the button.
- The selector itself is not fully designed — confirm: is it a dropdown (shadcn Select), a set of pills, or a popover?
- Options: smart default (labeled `[N] days — recommended`) + fixed alternatives (`3 days`, `1 week`, `2 weeks`, `1 month`).

### Page titles in browser tab
- Not specified in mockups. Confirm pattern: `SABER` vs `Dashboard — SABER` vs `James Chen — SABER`.

