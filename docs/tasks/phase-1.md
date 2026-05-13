# Mobile — Phase 1 — MVP (Day-Sized Tasks)

> Target: months 1–3.

## Onboarding (S-01, S-02, S-09)

- [ ] **MO-P1-001** — Splash view with animated logo (Lottie or SwiftUI)
- [ ] **MO-P1-002** — Deep-link router (URL → coordinator)
- [ ] **MO-P1-003** — Onboarding carousel layout
- [ ] **MO-P1-004** — Carousel content (3 slides) + skip CTA
- [ ] **MO-P1-005** — Drawing tutorial UI shell (3 steps)
- [ ] **MO-P1-006** — Tutorial step 1: pen + clear
- [ ] **MO-P1-007** — Tutorial step 2: color picker
- [ ] **MO-P1-008** — Tutorial step 3: send a nudge

## Auth (S-03, S-04) 🚨

- [ ] **MO-P1-009** — Login/Sign Up landing screen
- [ ] **MO-P1-010** — Sign in with Apple integration (mandatory)
- [ ] **MO-P1-011** — Google Sign-In integration
- [ ] **MO-P1-012** — Email + password form with validation
- [ ] **MO-P1-013** — OTP entry screen with auto-fill from SMS / email
- [ ] **MO-P1-014** — Resend cooldown timer
- [ ] **MO-P1-015** — Token store (Keychain, `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`)
- [ ] **MO-P1-016** — Refresh-on-401 interceptor with single-flight actor
- [ ] **MO-P1-017** — Logout flow + clear local state
- [ ] **MO-P1-018** — Auth flow XCUITest 🧪

## Profile (S-05)

- [ ] **MO-P1-019** — Create profile form (name + color)
- [ ] **MO-P1-020** — Avatar picker (camera + photo library + initials)
- [ ] **MO-P1-021** — Avatar upload via presigned URL
- [ ] **MO-P1-022** — Avatar finalize call

## Couple Connection (S-06, S-07, S-08)

- [ ] **MO-P1-023** — Connect-with-partner screen layout
- [ ] **MO-P1-024** — 6-char invite code entry with paste support
- [ ] **MO-P1-025** — Share invite link via share sheet
- [ ] **MO-P1-026** — QR scanner (AVCaptureSession + AVMetadataMachineReadableCodeObject)
- [ ] **MO-P1-027** — QR generator (display own code)
- [ ] **MO-P1-028** — Waiting-for-partner animated screen
- [ ] **MO-P1-029** — WS subscription for couple-connected event
- [ ] **MO-P1-030** — Couple welcome celebration screen
- [ ] **MO-P1-031** — Anniversary date picker
- [ ] **MO-P1-032** — Universal link handler: `https://fanhb.app/invite/:code`

## Canvas — Engine (S-11) ⏱

- [ ] **MO-P1-033** — `CanvasMetalView` UIView with `CAMetalLayer`
- [ ] **MO-P1-034** — Touch handler `touchesBegan/Moved/Ended`
- [ ] **MO-P1-035** — Port `perfect-freehand` smoothing to Swift (part 1: math)
- [ ] **MO-P1-036** — Port `perfect-freehand` smoothing (part 2: stroke outline builder)
- [ ] **MO-P1-037** — Stroke mesh tessellator (triangles for Metal)
- [ ] **MO-P1-038** — Metal shaders: stroke fill + alpha blending
- [ ] **MO-P1-039** — `StrokeRecorder` accumulates seq + ts + points
- [ ] **MO-P1-040** — Per-stroke layer rendering
- [ ] **MO-P1-041** — Pinch zoom + two-finger pan
- [ ] **MO-P1-042** — Frame budget: profile 60fps on iPhone 12 with Instruments
- [ ] **MO-P1-043** — `UIViewRepresentable` host for `CanvasMetalView`

## Canvas — Tools & Color (S-14, S-15)

- [ ] **MO-P1-044** — Tool picker bottom sheet UI
- [ ] **MO-P1-045** — Pen tool config (size + opacity)
- [ ] **MO-P1-046** — Eraser tool
- [ ] **MO-P1-047** — Stroke size slider
- [ ] **MO-P1-048** — Opacity slider
- [ ] **MO-P1-049** — HSB color picker UI
- [ ] **MO-P1-050** — Favorites palette + save color action
- [ ] **MO-P1-051** — Couple colors palette default

## Canvas — Editing

- [ ] **MO-P1-052** — Undo stack (up to 30) in `StrokeRecorder`
- [ ] **MO-P1-053** — Redo stack
- [ ] **MO-P1-054** — Clear canvas with confirmation
- [ ] **MO-P1-055** — Save draft to Core Data
- [ ] **MO-P1-056** — Resume draft on canvas open

## Canvas — Send Flow

- [ ] **MO-P1-057** — Render canvas to PNG (preview 512px)
- [ ] **MO-P1-058** — Render canvas to PNG (full 2048px)
- [ ] **MO-P1-059** — Call `POST /drawings` and receive presigned URLs
- [ ] **MO-P1-060** — Upload preview to R2 via signed PUT
- [ ] **MO-P1-061** — Upload full to R2 via signed PUT
- [ ] **MO-P1-062** — Call `POST /drawings/:id/finalize`
- [ ] **MO-P1-063** — Optimistic UI: show drawing as sent immediately

## Realtime Sync ⏱

- [ ] **MO-P1-064** — Fetch WS ticket from REST
- [ ] **MO-P1-065** — `URLSessionWebSocketTask` connect + auth
- [ ] **MO-P1-066** — Reconnect state machine + exponential backoff
- [ ] **MO-P1-067** — Heartbeat ping/pong loop
- [ ] **MO-P1-068** — `room:join` emit on canvas open
- [ ] **MO-P1-069** — `canvas:stroke` outbound batched every 16ms
- [ ] **MO-P1-070** — `canvas:stroke` inbound → overlay layer renderer
- [ ] **MO-P1-071** — Partner cursor heart icon overlay
- [ ] **MO-P1-072** — `canvas:cursor` outbound throttled to 30Hz
- [ ] **MO-P1-073** — Gap detection + `GET /drawings/:id/strokes?from_seq=` fill
- [ ] **MO-P1-074** — End-to-end test against staging on flaky network 🧪

## Canvas — Receive (S-12)

- [ ] **MO-P1-075** — View-received-drawing fullscreen layout
- [ ] **MO-P1-076** — Reply CTA → opens canvas in draw mode

## Nudge (S-17, S-18)

- [ ] **MO-P1-077** — Send nudge sheet UI
- [ ] **MO-P1-078** — Vibration choice (gentle / normal / strong)
- [ ] **MO-P1-079** — Quick-draw mini canvas inside nudge sheet
- [ ] **MO-P1-080** — `POST /nudges` call
- [ ] **MO-P1-081** — Receive nudge fullscreen cover
- [ ] **MO-P1-082** — `CHHapticEngine` patterns: gentle / normal / strong
- [ ] **MO-P1-083** — Quick-reply CTA from receive view

## Home (S-10)

- [ ] **MO-P1-084** — Home screen layout (preview + presence + CTA)
- [ ] **MO-P1-085** — Partner online indicator from WS presence
- [ ] **MO-P1-086** — Quick-draw button → canvas

## Memory Vault MVP (S-20, S-21)

- [ ] **MO-P1-087** — Timeline list with day section headers
- [ ] **MO-P1-088** — Paginated load with cursor
- [ ] **MO-P1-089** — Memory detail screen
- [ ] **MO-P1-090** — Image loader with on-disk cache

## Settings (S-30, S-32, S-33)

- [ ] **MO-P1-091** — General settings Form (language + theme + accent)
- [ ] **MO-P1-092** — Nudge settings Form (DND window + default vibration)
- [ ] **MO-P1-093** — Privacy: Face ID app lock via `LAContext` 🚨
- [ ] **MO-P1-094** — Privacy: hide-preview toggle

## Push & Notification Service Extension 🧩 🚨

- [ ] **MO-P1-095** — APNs registration + token upload to backend
- [ ] **MO-P1-096** — Notification permission prompt with proper copy
- [ ] **MO-P1-097** — Foreground notification presentation
- [ ] **MO-P1-098** — Tap → deep link to drawing
- [ ] **MO-P1-099** — NotificationServiceExtension: strip content when hide-preview is on 🧪
- [ ] **MO-P1-100** — Silent push handler → cache preview + reload widget timeline

## Widgets — MVP 🧩

- [ ] **MO-P1-101** — App Group store: write latest drawing thumb + days-together
- [ ] **MO-P1-102** — Widget bundle + intent definitions
- [ ] **MO-P1-103** — Small widget (2×2): drawing + name + time
- [ ] **MO-P1-104** — Medium widget (4×2): drawing + days + presence dot
- [ ] **MO-P1-105** — Widget timeline provider reads App Group
- [ ] **MO-P1-106** — Widget deep-link `widgetURL` to canvas

## Cross-cutting

- [ ] **MO-P1-107** — EN + VI string catalog populated
- [ ] **MO-P1-108** — VoiceOver labels pass (onboarding + canvas + nudge)
- [ ] **MO-P1-109** — Telemetry events: onboarding funnel
- [ ] **MO-P1-110** — Telemetry events: first-drawing-sent + couple-connected
- [ ] **MO-P1-111** — Crash-free target check on TestFlight build (Sentry)

## Golden-Path Tests

- [ ] **MO-P1-112** — XCUITest: onboarding → pair → home (with stubbed API) 🧪
- [ ] **MO-P1-113** — XCUITest: draw → send → receive on partner build 🧪

**Exit:** 2 devices + 2 Apple IDs run the golden path end-to-end on TestFlight; widget refreshes after new drawing arrives.
