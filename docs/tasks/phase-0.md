# Mobile — Phase 0 — Foundation (Day-Sized Tasks)

> Target: 2 weeks with 1–2 iOS engineers.

## Workspace & Targets

- [x] **MO-P0-001** — Create Xcode workspace + iOS app target (SwiftUI lifecycle)
- [x] **MO-P0-002** — Bundle id + min iOS 16 + dev provisioning profile
- [x] **MO-P0-003** — Add WidgetExtension target 🧩
- [x] **MO-P0-004** — Add NotificationServiceExtension target 🧩
- [x] **MO-P0-005** — Configure App Group `group.com.fanhb.shared` across all targets 🚨

## Swift Package Topology

- [x] **MO-P0-006** — Create `Core/Foundation` package (logger, result helpers, date utils)
- [x] **MO-P0-007** — Create `Core/DesignSystem` package (colors, typography, common components)
- [x] **MO-P0-008** — Create `Core/Networking` package skeleton (APIClient, interceptors)
- [x] **MO-P0-009** — Create `Core/Realtime` package skeleton (WSClient state machine)
- [x] **MO-P0-010** — Create `Core/Persistence` package (Core Data stack in App Group)
- [x] **MO-P0-011** — Create `Core/AppGroupStore` package
- [x] **MO-P0-012** — Create `Core/Push` package
- [x] **MO-P0-013** — Create `Core/Analytics` package (event sink interface)
- [x] **MO-P0-014** — Create `Core/DependencyContainer` package (Factory bindings)
- [x] **MO-P0-015** — Create `Domain*` packages skeleton (Auth, Couple, Canvas, Nudge, Memory, Gamification, Subscription)

## Signing & CI

- [x] **MO-P0-016** — Fastlane Match setup for dev + adhoc + AppStore 🚨 ✅ done 2026-05-13
- [x] **MO-P0-017** — GitHub Actions: lint + build job (xcodebuild) ✅ done 2026-05-13
- [x] **MO-P0-018** — GitHub Actions: unit test job ✅ done 2026-05-13
- [x] **MO-P0-019** — GitHub Actions: TestFlight upload on main merge ✅ done 2026-05-13

## Third-Party SDK Integration

- [x] **MO-P0-020** — Add Sentry SDK with build-time DSN ✅ done 2026-05-13
- [x] **MO-P0-021** — Add PostHog SDK + event-sink adapter ✅ done 2026-05-13
- [x] **MO-P0-022** — Add Firebase Auth SDK ✅ done 2026-05-13
- [x] **MO-P0-023** — Add Factory DI package ✅ done 2026-05-13
- [x] **MO-P0-024** — Add ViewInspector for SwiftUI tests ✅ done 2026-05-13

## Tooling

- [ ] **MO-P0-025** — SwiftFormat + SwiftLint pre-commit hook
- [ ] **MO-P0-026** — OpenAPI client codegen pipeline (consumes spec from BE) (blocked by BE-P0-040)
- [ ] **MO-P0-027** — `APIClient` shape + interceptor pipeline implementation
- [ ] **MO-P0-028** — `WSClient` shape + reconnect state machine implementation
- [ ] **MO-P0-029** — Stub `APIClient` + `WSClient` for SwiftUI previews

## Smoke

- [ ] **MO-P0-030** — Empty `RootView` calls `/_ops/health` and displays the result
- [ ] **MO-P0-031** — Ship first TestFlight build

**Exit:** TestFlight build installs on real device, shows health status from staging, CI gating works.
