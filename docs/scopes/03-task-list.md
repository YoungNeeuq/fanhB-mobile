# FanhB iOS — Implementation Task List

> Phases align with `brainStorm.md §11`. Sizes: S ≤ 1d, M 2–3d, L 1 wk, XL 2 wk. Estimates assume 1–2 iOS engineers + 1 designer.

Legend: 🆕 new module · 🔁 iteration · 🧪 testable golden path · 🚨 security-sensitive · ⏱ realtime-critical · 🧩 platform extension

---

## Phase 0 — Foundation (Weeks 1–2)

| # | Task | Size | Notes | Status |
|---|---|---|---|---|
| 0.1 | Xcode workspace + SPM package skeleton per §2 of architecture | M | | ✅ done 2026-05-13 |
| 0.2 | App target, Widget extension target, Notification Service extension target | M | 🧩 | ✅ done 2026-05-13 |
| 0.3 | Bundle ids, entitlements, App Group, capabilities | M | 🚨 | ✅ done 2026-05-13 |
| 0.4 | Fastlane Match for code signing | M | 🚨 | ⬜ todo |
| 0.5 | CI on GitHub Actions: build → test → TestFlight | L | | ⬜ todo |
| 0.6 | Sentry + PostHog SDK integration with build-time DSN injection | S | | ⬜ todo |
| 0.7 | `DesignSystem` package: colors, typography, haptic library, common controls | M | | ✅ skeleton done 2026-05-13 |
| 0.8 | `Networking` package: APIClient, interceptors, token store, RFC7807 mapping | M | | ✅ skeleton done 2026-05-13 |
| 0.9 | `Realtime` package skeleton with state machine + reconnect | M | ⏱ | ✅ done 2026-05-13 |
| 0.10 | `Persistence` package: Core Data stack in App Group container | M | | ✅ skeleton done 2026-05-13 |
| 0.11 | DI container (Factory) + bindings | S | | ✅ `AppContainer` wired (Factory lib not yet added — MO-P0-023) |
| 0.12 | OpenAPI codegen pipeline → typed endpoints | M | requires backend swagger | ⬜ blocked (MO-P0-026) |
| 0.13 | Stub `APIClient` and `WSClient` for previews + tests | S | | ⬜ todo (MO-P0-029) |

**Exit criteria:** an empty app launches, hits `/_ops/health` from staging, shows a "hello couple" screen, ships to TestFlight from main.

---

## Phase 1 — MVP iOS (Months 1–3)

### Onboarding (S-01, S-02, S-09)
| # | Task | Size |
|---|---|---|
| 1.1 | Splash with animated logo + deep-link router | M |
| 1.2 | Onboarding carousel (3 slides) | S |
| 1.3 | Drawing tutorial — interactive 3-step coach mark | M |

### Auth (S-03, S-04) 🚨
| # | Task | Size |
|---|---|---|
| 1.4 | Sign in with Apple (mandatory) 🧪 | M |
| 1.5 | Google Sign-In | S |
| 1.6 | Email + password + OTP | M |
| 1.7 | Keychain token store, refresh flow with single-flight | M |

### Profile (S-05)
| # | Task | Size |
|---|---|---|
| 1.8 | Create profile UI (name, color, avatar) | M |
| 1.9 | Avatar upload via presigned URL | S |

### Couple Connection (S-06, S-07, S-08)
| # | Task | Size |
|---|---|---|
| 1.10 | 6-char code entry + share sheet | S |
| 1.11 | QR scan (AVFoundation) | M |
| 1.12 | Waiting screen with WS subscription | M |
| 1.13 | Couple welcome + anniversary picker | S |

### Canvas — Draw (S-11) ⏱
| # | Task | Size |
|---|---|---|
| 1.14 | Metal canvas view (UIViewRepresentable host) | L |
| 1.15 | `perfect-freehand` smoothing port to Swift | L |
| 1.16 | Stroke recorder (seq + ts) | M |
| 1.17 | Tool picker bottom sheet (S-14): pen, eraser, undo, clear | M |
| 1.18 | Color palette (S-15): HSB picker + favorites | M |
| 1.19 | Undo / Redo (30 step) | M |
| 1.20 | Draft save to Core Data | S |
| 1.21 | Render-to-PNG (preview + full) + R2 upload | M |
| 1.22 | Finalize drawing flow | S |

### Realtime Sync ⏱
| # | Task | Size |
|---|---|---|
| 1.23 | WSClient connect with ticket | M |
| 1.24 | Send `canvas:stroke` batched at 16ms | M |
| 1.25 | Receive partner strokes → overlay layer | M |
| 1.26 | Partner cursor as heart icon | S |
| 1.27 | Reconnect + missed-stroke gap fill via REST | M |
| 1.28 | Load test: 30-minute drawing session over flaky network 🧪 | M |

### Canvas — View Received (S-12)
| # | Task | Size |
|---|---|---|
| 1.29 | Fullscreen view of received drawing + reply CTA | S |

### Nudge (S-17, S-18)
| # | Task | Size |
|---|---|---|
| 1.30 | Send nudge sheet with vibration choice | M |
| 1.31 | Receive nudge fullscreen cover + CHHaptic | M |
| 1.32 | Reusable haptic pattern library (gentle / normal / strong) | S |

### Home (S-10)
| # | Task | Size |
|---|---|---|
| 1.33 | Home screen: latest drawing preview, partner online, quick-draw button | M |

### Memory Vault — basic (S-20, S-21)
| # | Task | Size |
|---|---|---|
| 1.34 | Timeline list with day buckets | M |
| 1.35 | Memory detail screen | S |

### Settings (S-30, S-32, S-33)
| # | Task | Size |
|---|---|---|
| 1.36 | General settings (language, theme) | S |
| 1.37 | Nudge settings (DND window, vibration default) | S |
| 1.38 | Privacy: Face ID lock + hide-preview 🚨 | M |

### Push & Notification Service Extension 🧩 🚨
| # | Task | Size |
|---|---|---|
| 1.39 | APNs registration + token upload | S |
| 1.40 | NotificationServiceExtension to strip content when "hide preview" is on 🧪 | M |
| 1.41 | Silent push handler refreshes widget timeline | S |

### Widgets — MVP 🧩
| # | Task | Size |
|---|---|---|
| 1.42 | App Group store: write latest drawing + days-together | S |
| 1.43 | Small widget (2×2) — drawing + sender + time | M |
| 1.44 | Medium widget (4×2) — drawing + days-together + presence dot | M |
| 1.45 | Widget deep-link to canvas reply | S |

### Cross-cutting MVP
| # | Task | Size |
|---|---|---|
| 1.46 | EN + VI string catalog | M |
| 1.47 | VoiceOver labels on every interactive element | M |
| 1.48 | Telemetry events: onboarding funnel + first-drawing-sent | S |
| 1.49 | XCUITest: onboarding → couple connect → send drawing → receive push 🧪 | L |

**Phase 1 exit criteria:**
- 2 real devices, 2 different Apple IDs, can: install from TestFlight → onboard → pair → exchange drawings + nudges → see widget update.
- Crash-free sessions ≥ 99% in TestFlight.
- p95 stroke render → partner display < 200ms on Wi-Fi (measured via Sentry timing breadcrumbs).

---

## Phase 2 — Growth (Months 4–6)

### Canvas — Co-draw + Templates (S-13, S-16) ⏱
| # | Task | Size |
|---|---|---|
| 2.1 | Layered co-draw: partner strokes on separate `CALayer` | L |
| 2.2 | Conflict / replay handling | M |
| 2.3 | Canvas templates picker (S-16) with background overlays | M |

### Reactions (S-19)
| # | Task | Size |
|---|---|---|
| 2.4 | Hand-drawn emoji panel (custom asset set) | M |
| 2.5 | Reaction send + receive with optimistic UI | S |

### Memory Vault — extensions (S-22, S-24)
| # | Task | Size |
|---|---|---|
| 2.6 | Themed Albums (manual tags) screen | M |
| 2.7 | Add note to memory inline editor | S |
| 2.8 | Drawing journey playback (variable speed) ⏱ | L |

### Profile & Relationship (S-26, S-27, S-28, S-29)
| # | Task | Size |
|---|---|---|
| 2.9 | Couple profile screen | M |
| 2.10 | Personal profile + stats | M |
| 2.11 | Milestones list with badges | M |
| 2.12 | Edit relationship (nicknames, anniversary, photo) | S |
| 2.13 | Streak detail with visual evolution | M |

### Live Activity (iOS 16+) 🧩 ⏱
| # | Task | Size |
|---|---|---|
| 2.14 | ActivityKit attributes + view definitions | M |
| 2.15 | Start activity on `canvas:drawing-start` | M |
| 2.16 | Update activity via remote push 🧪 | M |
| 2.17 | End activity on finalize | S |

### Widgets — Large + Lock Screen 🧩
| # | Task | Size |
|---|---|---|
| 2.18 | Large widget (4×4) — 4-drawing collage | M |
| 2.19 | Lock screen rectangular widget — days-together | S |
| 2.20 | Lock screen circular widget — thumbnail | S |
| 2.21 | Widget Settings screen (S-31) | M |

### Nudge — scheduling
| # | Task | Size |
|---|---|---|
| 2.27 | Scheduled nudge UI (date/time picker) | S |
| 2.28 | Cancel scheduled nudge | S |

### Settings — Canvas (P2 slice)
| # | Task | Size |
|---|---|---|
| 2.29 | Canvas personalization (background, texture, sound) | M |

### Account
| # | Task | Size |
|---|---|---|
| 2.30 | Account screen | M |
| 2.31 | Disconnect flow with cool-off explanation | M |

**Phase 2 exit criteria:**
- Live Activity visible on Dynamic Island when partner draws.
- Streak rendering matches backend state across DST boundary tests.

---

## Phase 3 — Delight (Months 7–9)

### Interactive Widget (iOS 17+) 🧩
| # | Task | Size |
|---|---|---|
| 3.1 | `AppIntent` for "Send Heart" | M |
| 3.2 | Interactive 4×2 widget with tap-to-heart | L |
| 3.3 | Battery-aware refresh policy | S |

### Challenges
| # | Task | Size |
|---|---|---|
| 3.4 | Challenges hub | M |
| 3.5 | Submit drawing as challenge response | S |
| 3.6 | Compare results screen (side-by-side) | M |
| 3.7 | Custom challenges flow | M |

### Memory Vault — Smart Albums & Export (S-23, S-25)
| # | Task | Size |
|---|---|---|
| 3.8 | Smart albums shelf on memory home | M |
| 3.9 | On This Day / Most Loved / Our Journey screens | M |
| 3.10 | Slideshow player with music | M |
| 3.11 | Export PNG with watermark toggle | S |
| 3.12 | Export PDF (kick off server job, poll, share when ready) | M |
| 3.13 | Export Video Reel | M |
| 3.14 | Share to IG / TikTok Story with frame overlay | M |

### Heartbeat Nudge
| # | Task | Size |
|---|---|---|
| 3.15 | Custom CHHaptic envelope (heartbeat pattern) | M |
| 3.16 | Heartbeat nudge send + receive | S |

### Stealth Canvas
| # | Task | Size |
|---|---|---|
| 3.17 | Mode toggle in tool picker; suppress presence + Live Activity | M |

### Advanced Brushes
| # | Task | Size |
|---|---|---|
| 3.18 | Apple Pencil pressure → stroke width | M |
| 3.19 | Soft Brush + Chalk + Highlighter textures (Metal shaders) | L |
| 3.20 | Tremor correction filter | M |
| 3.21 | Fill Bucket (flood fill in Metal compute shader) | L |
| 3.22 | Hand-drawn stickers panel | M |

### Stats
| # | Task | Size |
|---|---|---|
| 3.23 | Love Language stats screen | M |
| 3.24 | Mood color tracker screen | M |

### Account
| # | Task | Size |
|---|---|---|
| 3.25 | Delete account flow (S-35) with export option 🚨 | M |

**Phase 3 exit criteria:**
- Interactive widget shipped on iOS 17 device test matrix (mini, Pro, Pro Max).
- Love Book PDF and Video Reel exports work end-to-end and reach the share sheet within app timeouts.

---

## Phase 4 — Scale (Months 10–12)

| # | Task | Size |
|---|---|---|
| 4.1 | Sticker pack store with IAP consumables 🚨 | L |
| 4.2 | Couple Book Print fulfillment flow | XL |
| 4.3 | Apple Watch app: presence + send Nudge | L |
| 4.4 | Spotify OAuth + album-art insert into canvas | L |
| 4.5 | Group canvas (n>2) — schema migration screens | XL |
| 4.6 | App Clip for invite link preview | M |
| 4.7 | iPad layout pass | L |
| 4.8 | Localization expansion (FR, JA, ZH, ES) | L |

---

## Cross-Phase Non-Functional Work

| Category | Tasks |
|---|---|
| Performance | Frame-time budget on Metal canvas: 60fps on iPhone 12+; measure with Instruments each phase exit |
| Memory | Drawing buffer cap, automatic spill to disk |
| Battery | Test 60-minute drawing session; expect ≤ 12% drain on iPhone 13 |
| Accessibility | VoiceOver review per phase, Dynamic Type up to AX5, high-contrast palette |
| Localization | EN + VI MVP; ICU plurals; right-to-left audit before global expansion |
| Privacy | App Privacy questionnaire kept current per release; data deletion request flow tested per phase |
| Release | TestFlight cohort per phase; staged App Store rollout for risky releases |

---

## Critical Path (MVP)

```
1.1 Splash ─► 1.4 Apple Sign-In ─► 1.8 Profile ─► 1.10–1.13 Couple connect
   └► 1.14–1.22 Canvas + WSClient (1.23–1.27) ─► 1.34 Timeline
        └► 1.30/1.31 Nudge ─► 1.39 Push ─► 1.42–1.45 Widget
```

Everything else (theming polish, settings depth, telemetry, tests) can run in parallel branches.

---

## Headcount Notes

- **MVP (P1):** 2 iOS engineers (1 senior on canvas/realtime; 1 mid on flows + widgets) + designer (part-time).
- **P2:** add 1 engineer to deliver Live Activity and co-draw in parallel.
- **P3:** keep 3 iOS engineers; add a brush/Metal specialist for one quarter.
- **P4:** add Watch + iPad capable engineer; localization vendor.
