# FanhB iOS — Application Architecture

> Target shape: modular Swift Package monorepo, MVVM + Coordinator at feature level, a single Metal-backed canvas surface, and an App-Group-shared layer that the main app, widget extension, notification service extension, and (later) watch app all read from.

---

## 1. Layered Architecture

```
┌──────────────────────────────────────────────────────────┐
│                     Presentation                          │
│   SwiftUI Views · UIKit Canvas Host · Widgets · Watch     │
├──────────────────────────────────────────────────────────┤
│                     Feature Modules                       │
│   Auth · Couple · Canvas · Nudge · Memory · Settings ...  │
│   (each = one Swift Package: View + ViewModel + Reducer)  │
├──────────────────────────────────────────────────────────┤
│                       Domain Layer                        │
│   Entities · Use Cases · DTO mappers · Errors             │
├──────────────────────────────────────────────────────────┤
│                       Data Layer                          │
│   APIClient · WSClient · CoreDataStore · KeychainStore    │
│   FirebaseAuth · PushService · AppGroup                   │
├──────────────────────────────────────────────────────────┤
│                      Platform Layer                       │
│   URLSession · ActivityKit · WidgetKit · CHHapticEngine   │
│   Metal · PencilKit · AVFoundation · UserNotifications    │
└──────────────────────────────────────────────────────────┘
```

Direction of dependency is downward only. Domain never imports SwiftUI or URLSession; feature modules never reach into Platform directly.

---

## 2. Module Topology (Swift Packages)

```
FanhB.xcworkspace
├── App                        (iOS application target)
├── WidgetExtension            (WidgetKit target)
├── NotificationServiceExt     (Mutable content / preview hiding)
├── Watch                      (Phase 4)
└── Packages/
    ├── Core/
    │   ├── DesignSystem        (colors, typography, components, haptics)
    │   ├── Foundation          (logger, result+error helpers, date utils)
    │   ├── Networking          (APIClient, interceptors, retry)
    │   ├── Realtime            (WSClient, reconnect, stroke codec)
    │   ├── Persistence         (CoreData stack, migrations)
    │   ├── AppGroupStore       (read/write to shared container)
    │   ├── Push                (UNUserNotificationCenter wrapper)
    │   ├── Analytics           (event sink interface + PostHog impl)
    │   └── DependencyContainer (Factory bindings)
    ├── Domain/
    │   ├── DomainAuth          (entities + use cases)
    │   ├── DomainCouple
    │   ├── DomainCanvas        (Stroke, Drawing, Tool, Color)
    │   ├── DomainNudge
    │   ├── DomainMemory
    │   └── DomainGamification
    └── Features/
        ├── FeatureAuth         (screens S-03/04 + flow)
        ├── FeatureOnboarding   (S-01/02/09)
        ├── FeatureCouple       (S-06/07/08 + Couple/Edit S-26/29)
        ├── FeatureCanvas       (S-11/12/13/14/15/16)
        ├── FeatureNudge        (S-17/18/19)
        ├── FeatureMemory       (S-20–S-25)
        ├── FeatureProfile      (S-27/28)
        ├── FeatureChallenges   (P3)
        ├── FeatureSettings     (S-30–S-35)
        └── FeatureWidgetConfig (drives Widget Extension UI)
```

Each `Feature*` package depends only on its corresponding `Domain*` plus `Core/*`. Cross-feature navigation is mediated by **Coordinators** living in `App`.

---

## 3. State Management Pattern

**Recommendation: MVVM + Coordinator + `@Observable`.**

Per screen:
- `View` (SwiftUI) — pure render of `@Bindable ViewModel`.
- `ViewModel` (`@Observable` class) — owns view state, exposes async intents, calls use cases.
- `Coordinator` — owns navigation (`NavigationPath`, sheet presentation, deep links).
- `UseCase` — single-purpose domain function (e.g., `SendNudgeUseCase`).
- `Repository` — data-layer protocol implemented by an `APIClient`-backed type.

Why not TCA: team familiarity + Swift 5.10's Observation framework already gives us reactive view models without reducer boilerplate. TCA remains acceptable if the team prefers it; the rest of the architecture works unchanged.

---

## 4. The Canvas Subsystem (deep dive)

The canvas is the product. It gets its own architecture inside `DomainCanvas` + `FeatureCanvas`.

```
┌─────────────────────────────────────────────────────────────┐
│  CanvasView (UIViewRepresentable wrapping CanvasMetalView)  │
└─────────────────────────────────────────────────────────────┘
                       │ touchesBegan/Moved/Ended  ▲
                       ▼                            │
              ┌────────────────────┐                │ render frame
              │ StrokeInputBuffer  │                │
              │  · pressure        │                │
              │  · perfect-freehand│                │
              │    smoothing       │                │
              └─────────┬──────────┘                │
                        │ smoothed points           │
                        ▼                           │
              ┌────────────────────┐         ┌──────┴──────────┐
              │ StrokeRecorder     │ ──────► │ MetalRenderer   │
              │ · accumulates seq  │         │ · per-stroke    │
              │ · ts since start   │         │   triangle mesh │
              └─────────┬──────────┘         └─────────────────┘
                        │ batch every 16ms
                        ▼
              ┌────────────────────┐
              │ RealtimeOutbound   │
              │ (Combine subject)  │
              └─────────┬──────────┘
                        │ canvas:stroke
                        ▼
                 WSClient ─► Backend ─► partner
                        ▲
                        │ canvas:stroke (partner)
                        ▼
              ┌────────────────────┐
              │ RealtimeInbound    │ ──► StrokeRenderer (overlay layer)
              └────────────────────┘
                        │
                        ▼
              ┌────────────────────┐
              │ DrawingPersister   │ ──► POST /drawings + R2 PUT (preview + full snapshot)
              └────────────────────┘
```

Key decisions:
- **Smoothing algorithm**: port `perfect-freehand` to Swift (or use `getStroke` JS via JavaScriptCore — no, too costly; port it).
- **Wire format**: same JSON as backend (§5 of architecture).
- **Local-first rendering**: stroke appears at finger speed; WS broadcast is best-effort.
- **Snapshot**: on `drawingEnd`, render current canvas to a PNG (preview 512px, full 2048px) and PUT to R2 via presigned URL.
- **Memory**: bounded to 5 MB stroke buffer per drawing; spill to disk if exceeded (rare).
- **Replay**: same renderer can play strokes back at variable speed using stored timestamps.

---

## 5. Networking Layer

```
APIClient (actor)
 ├── URLSession (default config)
 ├── Interceptors
 │    ├── AuthTokenInterceptor (Keychain-backed, refresh-on-401)
 │    ├── TraceparentInterceptor (W3C trace context for OTel)
 │    └── IdempotencyKeyInterceptor (writes get a UUID v7)
 ├── Decoder: JSONDecoder with ISO8601 + custom strategies
 └── Endpoint definitions (typed via OpenAPI codegen)
```

Auth flow on 401: the `AuthTokenInterceptor` serializes a single refresh through an `actor`-guarded mutex; concurrent requests await the in-flight refresh.

WebSocket: separate `WSClient` actor with state machine `disconnected → connecting → connected → reconnecting`. Exponential backoff (250ms → 8s, jittered). Heartbeat ping/pong every 25s.

---

## 6. Persistence Strategy

| Store | Use |
|---|---|
| **Keychain** | Access + refresh JWT, Firebase id token cache |
| **Core Data** (App Group) | `Drawing` (cached), `Stroke` (journey), `Nudge` (outbox), `DraftDrawing`, `LocalProfile`, `LocalCouple`, `Tag` |
| **UserDefaults** (App Group) | Couple-level cached counters (days together, streak), widget preferences |
| **R2 (remote)** | Full drawing PNGs + preview thumbs; only signed URLs reach the device |
| **In-memory** | Live socket state, current canvas strokes (pre-finalize) |

Migrations: Core Data lightweight migrations preferred; major version bumps add a migration plan + xcunittest fixture.

---

## 7. Background & Push Architecture

```
APNs ─► AppDelegate.didReceiveRemoteNotification (silent)
            │
            ├── content-available:1 ⇒ download new drawing preview to App Group
            │   ⇒ WidgetCenter.reloadAllTimelines()
            ├── alert ⇒ user-facing notification (with NotificationServiceExt → strip content if hide-preview is on)
            └── live-activity-update ⇒ ActivityKit.activity.update(...)
```

- **Background Modes**: `remote-notification`, `background-fetch` (legacy), `audio` only if music-played reel preview is in-app.
- **NotificationServiceExtension**: rewrites the alert body when "Hide preview" is enabled, leaving notification content as "New from {name}".
- **App Group**: shared container so the widget and notification extension can read the latest drawing thumbnail without a network call.

---

## 8. Dependency Injection

`Factory` package, registrations split per module:

```swift
extension Container {
    var apiClient: Factory<APIClient> { self { APIClient.live } }
    var wsClient: Factory<WSClient> { self { WSClient.live }.shared }
    var canvasStore: Factory<CanvasStore> { self { CanvasStore.live }.shared }
    // ...
}
```

In tests, `Container.shared.apiClient.register { APIClient.mock }`.

---

## 9. Concurrency Model

- Swift Concurrency (`async/await`, actors) end-to-end.
- View models are `@MainActor`.
- Domain use cases are `nonisolated` and inject dependencies; they don't pin to a queue.
- `WSClient` is an `actor`; outbound stroke flush is a `Task` with cooperative cancellation.
- `Sendable` enforced (Swift 6 strict concurrency) for all DTOs and domain models.

---

## 10. Error & Telemetry

- Domain errors typed (`enum NudgeError`, `enum CanvasError`).
- Network errors mapped from RFC7807 problem+json into typed cases.
- All thrown errors at the View layer route through a `ErrorPresenter` that decides toast vs. modal vs. silent log.
- Sentry captures all unhandled errors, scrubbed for PII.
- PostHog records funnel events: `onboarding_complete`, `couple_connected`, `first_drawing_sent`, `streak_reached_7`.
- Crash-free session target: ≥ 99.5%.

---

## 11. Security

- Tokens only in Keychain (`kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`).
- TLS pinning to API host (rotated quarterly; ship 2 valid pins).
- Jailbreak detection deliberately **not** implemented (false-positive risk > value).
- Face ID / Touch ID gate via `LAContext` with PIN fallback.
- "Hide drawing in preview" honored by NotificationServiceExtension and Live Activity content.
- App Transport Security strict; no cleartext exceptions.

---

## 12. Build & Release

- **Xcode 16+**, Swift 5.10/6.
- **SPM** primary; Tuist optional if generation speed becomes an issue.
- **Signing**: Fastlane Match.
- **Distribution**: TestFlight per merge to `main` → manual promote to App Store.
- **Feature flags**: pulled at app launch from `/v1/feature-flags`, cached in Keychain.
- **Versioning**: marketing version semver; build number from CI run number.
- **Crash reporting**: Sentry; symbol upload on every TestFlight build.

---

## 13. Testing Strategy

| Layer | Framework | Coverage target |
|---|---|---|
| Domain (use cases) | XCTest, no UI | 90%+ |
| ViewModel | XCTest with mock repos | 80%+ |
| Canvas math (smoothing, encode/decode) | XCTest with golden fixtures | 100% on the codec |
| SwiftUI views | ViewInspector snapshots | smoke level only |
| End-to-end golden paths | XCUITest + a stubbed `APIClient` | onboarding, send drawing, receive nudge |
| Live integration | Hand-run against staging before each TestFlight | release gate |

---

## 14. Why these choices over alternatives

| Alternative | Why we passed |
|---|---|
| React Native / Flutter | Custom canvas + Live Activity + interactive widgets all demand native iOS APIs. Cross-platform reduces velocity here, not increases. |
| PencilKit only | Insufficient control for partner-cursor overlay and stroke-replay timing. Use it for the tutorial only. |
| Firebase Firestore for realtime | Operationally simple, but stroke fan-out latency and cost at scale are worse than a dedicated Socket.io gateway. |
| TCA | Excellent, but team learning curve is real. We can adopt later inside `FeatureCanvas` if the state machine grows unwieldy. |
| Realm | Core Data is sufficient and removes a 3rd-party dep on a critical path. |
