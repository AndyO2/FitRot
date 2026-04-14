# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

FitRot is an iOS app that blocks distracting apps via Screen Time / Family Controls and grants temporary unlock windows in exchange for either coins (earned) or completing a camera-counted workout (push-ups, squats). Bundle ID `com.WinToday.FitRot`, deployment target iOS 26.2, Swift 5.0, Xcode 26.3.

## Build & Run

- Open `FitRot.xcodeproj` in Xcode and run the `FitRot` scheme. There is no test target and no CLI build script in the repo.
- The project uses a `PBXFileSystemSynchronizedRootGroup` — files dropped into `FitRot/` are picked up automatically, no need to add them to the pbxproj.
- Family Controls / Device Activity **only works on a real device** (not Simulator) and requires the provisioning profile to carry the `com.apple.developer.family-controls` entitlement. Development team in the pbxproj is `AH7UGRBNUY`.
- SPM dependencies (`SuperwallKit`, `Mixpanel`) are resolved via Xcode's package manager; no `Package.resolved` is checked in.

## Architecture: the four-process model

FitRot is *not* a single-binary app. It is one main app plus four appex targets that coordinate through an App Group. Understanding this is essential — code changes often need to be mirrored across processes, and state that looks "global" is actually shared via `UserDefaults(suiteName:)`.

1. **`FitRot/`** — main SwiftUI app. Owns user-facing UI, workout detection, coin ledger, and the "source of truth" writes to shared state.
2. **`FitRotDeviceActivity/`** — `DeviceActivityMonitor` extension. The OS wakes it at `intervalDidEnd` to re-apply shields when an unlock window expires, even if the main app isn't running.
3. **`FitRotShieldConfiguration/`** — `ShieldConfigurationDataSource`. Customizes the blocking screen the OS shows when a user taps a shielded app.
4. **`ShieldActionExtension/`** — `ShieldActionDelegate`. Handles taps on the shield's primary/secondary buttons.
5. **`FitRotReport/`** — `DeviceActivityReportExtension`. Renders the Screen Time usage dashboard inside `ScreenTimeDashboardCard` via a `DeviceActivityReport` SwiftUI view.

**Cross-process contract:** the single App Group `group.com.WinToday.FitRot` and the keys in `FitRot/Shared/AppGroupConstants.swift` are the only sanctioned channel between these processes. When adding new cross-process state, add a key there and use `AppGroupConstants.sharedDefaults` — do **not** reach for `UserDefaults.standard`, since extensions run in their own sandbox and won't see it. `SelectionPersistence` is the canonical read/write path for the user's `FamilyActivitySelection`.

Note: `DeviceActivityMonitorExtension.swift` currently hardcodes the group ID and key strings instead of importing `AppGroupConstants`. If you rename a key in `AppGroupConstants.swift`, grep the extension files for the raw string and update them too.

## Architecture: the lock/unlock state machine

`AppLockService` (`FitRot/Services/AppLockService.swift`) is the coordinator. Three observable properties define the state: `isBlockingEnabled`, `isUnlocked`, `unlockEndTime`. They are always mirrored into App Group defaults so extensions can read them.

Typical unlock flow:
1. User picks apps → `enableBlocking(selection:)` persists the selection and applies `ManagedSettingsStore` shields.
2. User spends coins (`unlock`) or completes a workout (`unlockFromWorkout`) → `scheduleUnlock(minutes:)` clears shields, starts a `DeviceActivitySchedule` bounded by "now" and "now + minutes" (capped at 23:59 today), and sets an in-process `Timer` as a redundant re-block trigger.
3. When the window ends, whichever fires first — the in-process timer (`reblock()`) or the `DeviceActivityMonitor` extension's `intervalDidEnd` — re-applies shields from the persisted selection. Both paths must stay in sync; if you change re-block behavior, change it in both places.
4. `restoreStateOnLaunch()` re-hydrates from defaults on every foreground transition, because extensions may have mutated state while the app was suspended. It's wired to `.onAppear` and `scenePhase == .active` in `FitRotApp`.

The shield → workout handoff uses two extra keys (`unlockRequestPendingKey`, `unlockRequestTimestampKey`) so the shield extension can signal "user wants to earn time": `NavigationCoordinator.checkPendingUnlockRequest()` reads this on foreground and opens the unlock flow (requests older than 5 minutes are ignored).

## Architecture: workout rep counting

The camera counter uses the **Strategy pattern** so different movements can plug in their own algorithms:

- `PoseDetector` (Vision `VNDetectHumanBodyPoseRequest`) emits `DetectedPose` structs with joint positions and pre-computed angles.
- `ExerciseCountingStrategy` protocol — each movement (e.g. `ElbowAngleStrategy` for push-ups, `SquatAngleStrategy` for squats) owns its own phase machine (`idle` → `down` → `up`), smoothing buffer, and debounce logic.
- `ExerciseCounter` (`@Observable`) wraps a strategy and exposes `count`/`phase`/`isComplete` to SwiftUI.

When adding a new movement, implement a new `ExerciseCountingStrategy`, add a case to `MovementType`, and wire it into the view layer via `MovementType.cameraConfig`. `ExerciseCounter.incrementForTesting()` exists under `#if DEBUG` for UI testing without a working camera.

## Architecture: observation & DI

- Everything uses Swift's `@Observable` + `@Environment(Type.self)`, **not** `ObservableObject`/`@StateObject`. The services instantiated in `FitRotApp.body` (`AppLockService`, `CoinManager`, `NavigationCoordinator`, `NotificationManager`, `ScreenTimeAuthManager`, `ThemeService`) are injected via `.environment(_:)` and read downstream via `@Environment(Service.self)`. Keep to this style when adding new services.
- Most SwiftUI files are wrapped in `#if canImport(FamilyControls)` so the project can still type-check on non-iOS platforms; mirror this guard if you add files that touch Family Controls / Device Activity.

## Third-party SDKs

- **SuperwallKit** — paywall, configured in `FitRotApp.init` with a hardcoded `pk_…` key.
- **Mixpanel** — analytics, wrapped by `AnalyticsService` (iOS-only via `#if os(iOS)`). Call `AnalyticsService.shared.track(...)` rather than `Mixpanel.mainInstance()` directly.
