# FanhB Mobile

iOS couples app — shared drawing canvas, nudges, and a memory vault. Built with SwiftUI + Metal, realtime via WebSocket, with WidgetKit and NotificationServiceExtension sharing state over an App Group.

---

## Requirements

| Tool | Version |
|---|---|
| Xcode | 16+ |
| Swift | 5.10 |
| iOS deployment target | 16.0 |
| xcodegen | latest (`brew install xcodegen`) |
| SwiftLint | latest (`brew install swiftlint`) |
| SwiftFormat | latest (`brew install swiftformat`) |

---

## Setup

### 1. First-time configuration

Copy the secret templates and fill in real values:

```bash
cp Config/Secrets.xcconfig.template Config/Secrets.xcconfig
# Edit Config/Secrets.xcconfig — add your Sentry DSN and PostHog key

cp App/Resources/GoogleService-Info.plist.template App/Resources/GoogleService-Info.plist
# Edit GoogleService-Info.plist — paste values from the Firebase Console
```

Set your Apple team ID in `project.yml`:

```yaml
# project.yml → settings.base
DEVELOPMENT_TEAM: "YOUR_10_CHAR_TEAM_ID"
```

### 2. Generate the Xcode project

```bash
xcodegen generate
```

Open `FanhB.xcodeproj` in Xcode. **Never edit `.xcodeproj` directly** — it is generated. Always edit `project.yml` and regenerate.

### 3. Install git hooks

```bash
make setup
```

This installs the pre-commit hook that runs SwiftFormat + SwiftLint before every commit.

---

## Daily development

```bash
make generate    # after editing project.yml or adding files
make lint        # run SwiftLint
make lint-fix    # auto-fix SwiftLint violations
make format      # run SwiftFormat across the repo
```

---

## Project structure

```
fanhB-mobile/
├── project.yml                  ← XcodeGen source of truth
├── App/
│   ├── Sources/                 ← FanhBApp.swift, RootView.swift, AppContainer, Coordinators
│   └── Resources/               ← Assets.xcassets, GoogleService-Info.plist
├── WidgetExtension/             ← WidgetKit timeline provider + views
├── NotificationServiceExt/      ← Strips drawing content when "Hide preview" is on
├── Config/                      ← Debug.xcconfig, Release.xcconfig, Secrets.xcconfig
├── Packages/
│   ├── Core/
│   │   ├── Foundation           → FHBFoundation   (logger, date utils, result helpers)
│   │   ├── DesignSystem         → FHBDesignSystem  (colors, typography, components)
│   │   ├── Networking           → FHBNetworking    (APIClient actor, interceptors)
│   │   ├── Realtime             → FHBRealtime      (WSClient actor, reconnect state machine)
│   │   ├── Persistence          → FHBPersistence   (Core Data stack in App Group)
│   │   ├── AppGroupStore        → FHBAppGroupStore (UserDefaults suite wrapper)
│   │   ├── Push                 → FHBPush          (UNUserNotificationCenter wrapper)
│   │   ├── Analytics            → FHBAnalytics     (event sink + PostHog adapter)
│   │   └── DependencyContainer  → FHBDependencyContainer (Factory registrations)
│   └── Domain/
│       ├── DomainAuth           (User, AuthTokens, AuthRepository)
│       ├── DomainCouple         (Couple, CoupleRepository)
│       ├── DomainCanvas         (Stroke, Drawing, BrushType, CanvasRepository)
│       ├── DomainNudge          (Nudge, NudgeType, NudgeRepository)
│       ├── DomainMemory         (Memory, MemoryAlbum, MemoryRepository)
│       ├── DomainGamification   (Streak, Achievement, GamificationRepository)
│       └── DomainSubscription   (Subscription, SubscriptionPlan, SubscriptionRepository)
└── docs/
    ├── scopes/                  ← architecture + feature + screen-list docs
    └── tasks/                   ← per-phase task checklists (phase-0…4.md)
```

---

## Architecture

Layered dependency hierarchy — **no upward imports**:

```
Presentation (SwiftUI Views, Widgets)
      ↓
Feature Modules (Phase 1+, one SPM package each)
      ↓
Domain Layer (entities, use cases, repository protocols)
      ↓
Data Layer (APIClient, WSClient, Core Data, Keychain)
      ↓
Platform (URLSession, WidgetKit, ActivityKit, Metal)
```

Key patterns:
- **MVVM + Coordinator** — `@Observable` view models on `@MainActor`; Coordinators own `NavigationPath` and deep-link routing in `App/`.
- **Domain use cases** are `nonisolated`; all DTOs and models are `Sendable` (Swift 6 strict concurrency target).
- **Tokens** stored in Keychain only (`kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`).
- **App Group** (`group.com.fanhb.shared`) shared by the app, widget, and notification extension for drawing previews and widget state.

See `docs/scopes/02-app-architecture.md` for the full design.

---

## Key identifiers

| Thing | Value |
|---|---|
| App bundle ID | `com.fanhb.app` |
| Widget bundle ID | `com.fanhb.app.widget` |
| Notification service bundle ID | `com.fanhb.app.notification-service` |
| App Group | `group.com.fanhb.shared` |
| Deep-link scheme | `fanhb://` |
| API base URL | `https://api.fanhb.app` |

---

## Adding a Swift package

1. Create `Packages/<Layer>/<Name>/Package.swift` with at least one `.swift` source file.
2. Add the package to the `packages:` section of `project.yml`.
3. Add it as a dependency under the relevant target(s) in `project.yml`.
4. Run `xcodegen generate`.

Domain packages must not import SwiftUI, UIKit, or URLSession.

---

## CI / CD

| Workflow | Trigger | What it does |
|---|---|---|
| `lint.yml` | Every PR | SwiftLint + `xcodebuild build` |
| `test.yml` | Every PR | `xcodebuild test` |
| `deliver.yml` | Push to `main` | TestFlight upload via Fastlane |

GitHub Actions secrets required: `MATCH_GIT_URL`, `MATCH_PASSWORD`, `ASC_API_KEY_ID`, `ASC_API_KEY_ISSUER_ID`, `ASC_API_KEY_CONTENT`, `SENTRY_DSN`, `POSTHOG_API_KEY`, `TEAM_ID`, `ITC_TEAM_ID`.

Signing is managed by **Fastlane Match** (`fastlane/`).

---

## First TestFlight build (MO-P0-031)

Once secrets are in place:

1. Fill in `Config/Secrets.xcconfig` and `GoogleService-Info.plist` (step 1 above).
2. Set `DEVELOPMENT_TEAM` in `project.yml`.
3. Add the GitHub repo secrets listed above.
4. Run `xcodegen generate`.
5. Push to `main` — `deliver.yml` uploads to TestFlight automatically.

**Exit criteria:** build installs on a real device, `RootView` shows the health-check response from staging, CI gating passes.

---

## Phase status (2026-05-13)

| Phase | Status |
|---|---|
| Phase 0 — Foundation (workspace, packages, CI, tooling) | ~complete (MO-P0-001–030 done; MO-P0-031 manual steps remain) |
| Phase 1 — MVP screens (auth, canvas, nudge, memory, widgets) | not started |
| Phase 2 — Growth (co-draw, Live Activity, streaks, premium) | not started |
| Phase 3 — Delight (challenges, smart albums, interactive widget) | not started |
| Phase 4 — Scale (Watch app, sticker store, group canvas) | not started |

Full checklists in `docs/tasks/`.
