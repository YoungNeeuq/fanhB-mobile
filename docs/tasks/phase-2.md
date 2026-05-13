# Mobile — Phase 2 — Growth (Day-Sized Tasks)

> Target: months 4–6.

## Canvas — Co-draw (S-13) ⏱

- [ ] **MO-P2-001** — Co-draw mode toggle in tool picker
- [ ] **MO-P2-002** — Layered renderer: own strokes on layer A, partner on layer B
- [ ] **MO-P2-003** — Conflict-safe seq numbering across authors
- [ ] **MO-P2-004** — Replay handling for late-arriving partner strokes
- [ ] **MO-P2-005** — Co-draw acceptance test on 2 devices 🧪

## Canvas — Templates (S-16)

- [ ] **MO-P2-006** — Templates picker UI
- [ ] **MO-P2-007** — Template asset bundle (holidays + moods + seasons)
- [ ] **MO-P2-008** — Apply background as non-erasable bottom layer

## Reactions (S-19)

- [ ] **MO-P2-009** — Hand-drawn emoji asset set (designer dependency)
- [ ] **MO-P2-010** — Reaction panel UI
- [ ] **MO-P2-011** — `POST /drawings/:id/react` + optimistic UI
- [ ] **MO-P2-012** — `DELETE /drawings/:id/react`
- [ ] **MO-P2-013** — Receive-side reaction toast

## Memory Vault — Extensions

- [ ] **MO-P2-014** — Themed Albums (S-22) list
- [ ] **MO-P2-015** — Tag CRUD UI (create / rename / delete)
- [ ] **MO-P2-016** — Attach tags to a memory (multi-select)
- [ ] **MO-P2-017** — Add Note to Memory (S-24) inline editor
- [ ] **MO-P2-018** — Search bar UI (tag + date + author + text)
- [ ] **MO-P2-019** — Search results screen
- [ ] **MO-P2-020** — Drawing journey playback view ⏱
- [ ] **MO-P2-021** — Playback speed control (0.5x / 1x / 2x / 4x)
- [ ] **MO-P2-022** — Playback rendering uses same Metal pipeline as draw

## Profile & Relationship

- [ ] **MO-P2-023** — Couple profile screen (S-26)
- [ ] **MO-P2-024** — Personal profile screen (S-27)
- [ ] **MO-P2-025** — Personal stats display
- [ ] **MO-P2-026** — Milestones screen (S-28) with badge grid
- [ ] **MO-P2-027** — Milestone claim flow with confetti
- [ ] **MO-P2-028** — Edit relationship screen (S-29)
- [ ] **MO-P2-029** — Couple photo picker + upload
- [ ] **MO-P2-030** — Streak detail screen with visual evolution

## Live Activity 🧩 ⏱

- [ ] **MO-P2-031** — ActivityKit attributes + content state types
- [ ] **MO-P2-032** — Lock screen LA view
- [ ] **MO-P2-033** — Dynamic Island leading + trailing views
- [ ] **MO-P2-034** — Dynamic Island expanded view
- [ ] **MO-P2-035** — Start activity on canvas:drawing-start
- [ ] **MO-P2-036** — Update activity from APNs LA push
- [ ] **MO-P2-037** — End activity on finalize
- [ ] **MO-P2-038** — LA acceptance test on iPhone 14 Pro 🧪

## Widgets — Large & Lock Screen 🧩

- [ ] **MO-P2-039** — Large widget (4×4): 4-drawing collage
- [ ] **MO-P2-040** — Lock screen rectangular widget: days-together
- [ ] **MO-P2-041** — Lock screen circular widget: thumb
- [ ] **MO-P2-042** — Widget Settings screen (S-31) UI
- [ ] **MO-P2-043** — Widget config (shape + accent + show-name) writes to App Group

## Subscriptions & Paywall

- [ ] **MO-P2-044** — StoreKit 2 product fetch
- [ ] **MO-P2-045** — Paywall screen design implementation
- [ ] **MO-P2-046** — Purchase flow + receipt to backend
- [ ] **MO-P2-047** — Server verify + entitlement refresh
- [ ] **MO-P2-048** — Restore purchases button + flow
- [ ] **MO-P2-049** — Premium-gated UI lock icons + upsell sheets
- [ ] **MO-P2-050** — Apply gate to scheduled-nudge UI
- [ ] **MO-P2-051** — Apply gate to template-export UI
- [ ] **MO-P2-052** — Subscription tests with StoreKitTest 🧪

## Nudge — Scheduling

- [ ] **MO-P2-053** — Scheduled nudge date/time picker
- [ ] **MO-P2-054** — `POST /nudges/scheduled`
- [ ] **MO-P2-055** — Scheduled list view
- [ ] **MO-P2-056** — Cancel scheduled nudge

## Settings — Canvas

- [ ] **MO-P2-057** — Canvas personalization screen (background + texture + sound)
- [ ] **MO-P2-058** — Background presets bundle
- [ ] **MO-P2-059** — Drawing sound assets (silent / pen / rain / lo-fi)

## Account

- [ ] **MO-P2-060** — Account & subscription screen (S-34)
- [ ] **MO-P2-061** — Disconnect flow with 7-day cool-off explanation
- [ ] **MO-P2-062** — Cancel disconnect during cool-off

**Exit:** Live Activity reliably appears on Dynamic Island; sandbox purchase + restore works; streak detail matches backend.
