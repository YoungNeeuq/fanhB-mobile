# FanhB iOS — Feature & Screen List

> Companion to `brainStorm.md` §3–§9. This document re-organizes every screen and feature by priority/phase, assigns owners-of-state, and flags platform integrations (WidgetKit, ActivityKit, StoreKit, PencilKit). Targets **iOS 16+** for Live Activity, **iOS 17+** for interactive widgets.

---

## 1. Tech Stack Decision

| Concern | Choice | Rationale |
|---|---|---|
| Language | **Swift 5.10 / Swift 6 ready** | Strict concurrency where stable |
| UI | **SwiftUI** primary; UIKit where needed (canvas, complex gestures) | Best ROI; UIKit reserved for performance hotspots |
| Canvas Engine | **Custom Metal renderer with `perfect-freehand`-style smoothing** + `PencilKit` for tutorial / fallback | PencilKit alone is rigid for real-time multi-user; Metal gives us fan-out control |
| State | **TCA (The Composable Architecture) 1.x** OR **MVVM + Coordinator + Observation framework** | Recommend **MVVM + `@Observable` + Coordinator** for team familiarity; TCA acceptable if team is experienced |
| Networking | `URLSession` + async/await + a thin `APIClient` layer | No third-party dep needed |
| WebSocket | `URLSessionWebSocketTask` (native) | Avoid Starscream unless reconnect logic gets gnarly |
| Persistence | **Core Data** for drawings/drafts; **Keychain** for tokens; **`UserDefaults` + App Group** for widget-shared state | App Group critical for widget access |
| Push & Live Activity | `UserNotifications` + `ActivityKit` + `WidgetKit` | Native frameworks only |
| Auth | **Firebase Auth iOS SDK** (Apple/Google/email) → exchanged for backend JWT | Matches backend |
| Analytics | **PostHog** or **Mixpanel** (cohort, funnel) | Avoid Firebase Analytics duplication |
| Media | `AVFoundation` for reel export, `PDFKit` for client-side preview only | Heavy generation stays on server |
| DI | **Factory** (Swift Package) | Lightweight, compile-time safe |
| Modularization | **Swift Package Manager** local packages (Tuist optional) | One feature = one package |
| Tests | XCTest + ViewInspector + Quick/Nimble (taste-dependent) + XCUITest for golden paths |  |

---

## 2. Screen Inventory — Reorganized by Phase

> S-codes match `brainStorm.md §3`. Column **State Owner** indicates which feature module/store owns the screen's view state.

### 2.1 Phase 1 — MVP screens (Months 1–3)

| # | S-code | Screen | Stack | State Owner | Notes |
|---|---|---|---|---|---|
| 1 | S-01 | Splash | SwiftUI | `AppBoot` | Animated logo, deep-link routing |
| 2 | S-02 | Onboarding Carousel | SwiftUI | `Onboarding` | 3 slides, skippable |
| 3 | S-03 | Login / Sign Up | SwiftUI | `Auth` | Email + Apple + Google |
| 4 | S-04 | OTP Verification | SwiftUI | `Auth` | Resend cooldown |
| 5 | S-05 | Create Profile | SwiftUI | `Profile` | Name, avatar, accent color |
| 6 | S-06 | Connect with Partner | SwiftUI | `Couple` | 6-char code + QR scan |
| 7 | S-07 | Waiting for Connection | SwiftUI | `Couple` | Listens to WS / poll fallback |
| 8 | S-08 | Couple Welcome | SwiftUI | `Couple` | Confetti, set anniversary |
| 9 | S-09 | Drawing Tutorial | SwiftUI + Canvas UIView | `Onboarding` | Interactive |
| 10 | S-10 | Home | SwiftUI | `Home` | Latest drawing, partner online, quick-draw |
| 11 | S-11 | Canvas — Draw | UIKit (Metal) inside SwiftUI host | `Canvas` | Realtime WS |
| 12 | S-12 | Canvas — View Received | SwiftUI | `Canvas` | Reply CTA |
| 13 | S-14 | Drawing Tool Picker | SwiftUI bottom sheet | `Canvas` | Pen/brush/chalk/highlighter/eraser |
| 14 | S-15 | Color Palette | SwiftUI | `Canvas` | HSB + favorites |
| 15 | S-17 | Send Nudge | SwiftUI | `Nudge` | Vibration choice + optional quick-draw |
| 16 | S-18 | Receive Nudge | SwiftUI fullscreen cover | `Nudge` | Reply button |
| 17 | S-20 | Memory Vault — Home | SwiftUI | `Memory` | Timeline list |
| 18 | S-21 | Memory Detail | SwiftUI | `Memory` | Date/author |
| 19 | S-30 | General Settings | SwiftUI Form | `Settings` | |
| 20 | S-32 | Nudge Settings | SwiftUI Form | `Settings` | DND hours |
| 21 | S-33 | Privacy & Security | SwiftUI Form | `Settings` | Face ID lock, hide preview |

**MVP widget surfaces:** Small (2×2), Medium (4×2) — covered in §3.

### 2.2 Phase 2 — Growth screens (Months 4–6)

| # | S-code | Screen | Notes |
|---|---|---|---|
| 22 | S-13 | Canvas — Co-draw Mode | Split or layered shared canvas |
| 23 | S-16 | Canvas Templates | Pre-made backgrounds |
| 24 | S-19 | Reaction Panel | Hand-drawn emoji set |
| 25 | S-22 | Themed Albums | Manual tag groups |
| 26 | S-24 | Add Note to Memory | Inline editor |
| 27 | S-26 | Couple Profile | Anniversary, days together |
| 28 | S-27 | Personal Profile | Personal stats |
| 29 | S-28 | Milestones & Achievements | Badges list |
| 30 | S-29 | Edit Relationship | Nicknames, anniversary, photo |
| 31 | S-31 | Widget Settings | Configure widgets |
| 32 | S-34 | Account | Account settings |
| 33 | New | Streak Detail | Visual evolution flame → sun |

**Phase 2 platform surfaces:** Live Activity, Lock Screen widget, Large (4×4) widget.

### 2.3 Phase 3 — Delight screens (Months 7–9)

| # | S-code | Screen | Notes |
|---|---|---|---|
| 35 | S-23 | Memory Slideshow | Auto-play with music |
| 36 | S-25 | Export Memory | PNG / PDF / Reel |
| 37 | New | Challenges Hub | Weekly + custom |
| 38 | New | Challenge Compare | Side-by-side |
| 39 | New | Smart Albums (On This Day / Most Loved / Journey) | |
| 40 | New | Love Language Stats | 30-day analysis |
| 41 | New | Mood Color Tracker | Weekly chart |
| 42 | New | Stealth Canvas Mode | Hidden draw |
| 43 | S-35 | Disconnect / Delete Account | Confirmation flow |

**Phase 3 platform surfaces:** Interactive widget (iOS 17+), Heartbeat haptic Nudge.

### 2.4 Phase 4 — Scale screens (Months 10–12)

| # | Surface | Notes |
|---|---|---|
| 44 | Apple Watch app | Send Nudge from wrist |
| 45 | Sticker Pack store | In-app purchases |
| 46 | Couple Book Print flow | Physical fulfillment |
| 47 | Spotify integration screen | Album art into canvas |
| 48 | Group canvas (n>2) | Family canvas |

---

## 3. Widget Surfaces

| Surface | Size | Phase | Content | Interactivity |
|---|---|---|---|---|
| W-S | Small 2×2 | P1 | Latest drawing thumb + sender + time | Tap → open canvas reply |
| W-M | Medium 4×2 | P1 | Drawing + days-together + online dot | Tap → home |
| W-L | Large 4×4 | P2 | 4 most recent drawings collage | Tap → memory vault |
| W-LS | Lock Screen | P2 | Thumb or days-together counter | Tap → home |
| W-I | Interactive 4×2 | P3 (iOS 17+) | Mini canvas; tap to send a heart | `AppIntent` action |
| LA | Live Activity | P2 | Partner drawing preview + avatar | Dynamic Island leading/trailing |

> All widgets read from the **App Group container** (`group.com.fanhb.shared`) via `WidgetKit` `Timeline` provider. Background refresh is triggered by silent push (`content-available`) when a new drawing arrives.

---

## 4. Feature Matrix — Per Phase

### Phase 1 — MVP

| Feature | Detail |
|---|---|
| Auth | Email + Apple + Google sign-in, OTP, refresh |
| Couple pairing | Code + QR scan, anniversary, accent colors |
| Canvas basics | Pen, eraser, color picker, undo (30), clear, save draft |
| Realtime | WebSocket stroke + cursor + drawing-start presence |
| Send / receive drawings | Push notification → fullscreen view |
| Nudge basic | Standard haptic + optional quick-draw |
| Memory timeline | Day-bucketed list |
| Widgets | Small + Medium |
| Settings basics | Theme, language, DND, hide-preview, Face ID lock |

### Phase 2 — Growth

| Feature | Detail |
|---|---|
| Co-draw mode | Two cursors, shared canvas |
| Live Activity | Dynamic Island while partner draws |
| Drawing playback | Stroke-by-stroke time lapse |
| Streak + milestones | Visual evolution, freeze tokens |
| PNG export | Share sheet |
| Reactions | Hand-drawn emoji |
| Themed albums | Manual tags |
| Couple profile | Photo, milestones, anniversary |
| Widget Large + Lock Screen | |

### Phase 3 — Delight

| Feature | Detail |
|---|---|
| Interactive widget | iOS 17+ AppIntent tap-to-heart |
| Couple challenges | Weekly + custom + compare |
| Smart albums | On This Day, Most Loved, Our Journey |
| PDF Love Book / Video Reel export | Server-generated, share sheet |
| Heartbeat nudge | Custom CHHaptic pattern |
| Stealth canvas | Surprise mode (no "drawing…" presence) |
| Advanced brushes | Pressure (Apple Pencil), texture, tremor correction |
| Love language stats + Mood tracker | |

### Phase 4 — Scale

| Feature | Detail |
|---|---|
| Apple Watch app | Nudge + presence only |
| Sticker pack store | IAP consumables |
| Couple Book Print | Physical fulfillment |
| Spotify | OAuth + album art into canvas |
| Group canvas | Beyond couples |

---

## 5. Navigation Map (top level)

```
Root Tab Bar (post-auth)
├── Home (S-10)           ── Canvas (S-11) / View (S-12) / Co-draw (S-13)
├── Memory Vault (S-20)   ── Detail (S-21) / Albums (S-22) / Slideshow (S-23) / Export (S-25)
├── Challenges (P3)       ── Detail / Compare / Custom
└── Profile (S-26)        ── Personal (S-27) / Milestones (S-28) / Settings (S-30...)
```

Modal flows: Nudge send/receive, Drawing tool picker, Color palette, Disconnect.

---

## 6. Cross-Screen Concerns

| Concern | Approach |
|---|---|
| Localization | Strings catalog (`.xcstrings`); EN + VI at launch; ICU plural rules |
| Accessibility | VoiceOver labels on every interactive element; Dynamic Type; high-contrast palette |
| Theming | Semantic colors driven by `couple.accent` and system light/dark |
| Haptics | `CHHapticEngine` for Nudge variants; reusable pattern library |
| Offline | Optimistic UI on drawing send; Core Data outbox; auto-flush on reconnect |
| Deep links | `fanhb://canvas/:drawingId`, `fanhb://memory/:id`, `fanhb://invite/:code` |
| Universal links | `https://fanhb.app/invite/:code` for invite sharing |
| Privacy preview | Notification service extension to strip content when "hide preview" is on |
| App Group sharing | Drawings preview + days-together cached for widget reads |

---

## 7. Hard iOS Platform Capabilities Required

| Capability | When | Phase |
|---|---|---|
| Push notifications + APNs entitlement | P1 | |
| App Group (`group.com.fanhb.shared`) | P1 | |
| WidgetKit extension target | P1 | |
| Sign in with Apple capability | P1 (App Store requirement) | |
| Camera (QR scan) | P1 | |
| Photos add-only (export to camera roll) | P2 | |
| Background Modes: Remote notifications, Background fetch | P1 | |
| ActivityKit (Live Activity) | P2 | |
| Apple Pencil / pressure | P3 | |
| App Clips (optional, invite preview) | P4 | |
| WatchKit extension | P4 | |

---

## 8. Open Mobile Product Questions

1. **Canvas engine**: confirm Metal vs PencilKit-only after a 1-week spike. Brainstorm leans toward custom; we lock that in once perf numbers are in.
2. **TCA vs MVVM**: pick before Phase 1 starts. Document in an ADR.
3. **Guest mode**: brainstorm mentions "guest preview" — is it a true anonymous account or a non-functional teaser? Likely the latter for MVP simplicity.
4. **Co-draw conflict policy**: layered (each author owns a sublayer) or shared (all strokes merge). Recommendation: layered for P2, surface a switch in settings.
