# Progress

## Architecture
Clean Architecture with Bloc/Cubit:
- `core/errors/` — Failure hierarchy (NetworkFailure, StorageFailure, CredentialFailure)
- `domain/` — pure Dart: Email + Credentials entities, repository interfaces, 4 use cases
- `data/` — EmailModel/CredentialsModel, ImapDataSource, CredentialDataSource, repository impls
- `presentation/cubits/` — EmailMonitorCubit (sealed states) + CredentialsCubit (sealed states)
- `injection/` — GetIt dependency injection container
SOLID: DI via constructor injection, abstractions for all data sources + repositories, single-responsibility per class

## Completed
- Flutter project initialized (Flutter 3.44.1, macOS only)
- Entitlements: network client + keychain (Debug + Release)
- Info.plist: LSUIElement = true (no Dock icon, background agent)
- .gitignore: secrets + macOS build artifacts excluded
- VS Code: format-on-save, Dart formatter, removed FVM SDK path
- Git repo initialized, initial commit on `main`
- GitHub MCP configured in ~/.claude/mcp.json
- Packages added: `window_manager ^0.3.9`, `flutter_secure_storage ^9.2.4`, `enough_mail ^2.1.7`, `flutter_bloc ^8.1`, `equatable ^2.0.5`, `get_it ^7.6`
- `MainFlutterWindow.swift` updated for window_manager (hiddenWindowAtLaunch)
- Refactored to clean architecture + Bloc/Cubit (deleted old lib/services/)
- `EmailMonitorCubit` — sealed states: Initial, Connecting, Listening, NewEmail, CredentialsMissing, Error
- `CredentialsCubit` — sealed states: Initial, Loaded, Missing, Saved, Cleared, Error
- GetIt DI wires all layers; `main.dart` is now a pure StatelessWidget

## Tests — 65/65 passing ✅
- `test/domain/usecases/` — 9/9: LoadCredentials, SaveCredentials, ClearCredentials, WatchNewEmails
- `test/data/repositories/` — 10/10: CredentialRepositoryImpl, EmailRepositoryImpl
- `test/presentation/cubits/` — 14/14: EmailMonitorCubit, CredentialsCubit
- `test/presentation/widgets/` — 8/8: BannerController (inc. settingsOpen guard) + EmailBanner widget tests
- `test/presentation/screens/` — 8/8: SettingsScreen widget tests
- Going forward: tests written before each commit for every new feature

## Current state
**Feature-complete v1.** Background agent monitors Gmail via IMAP IDLE. On new email: transparent banner (full-width, 120px strip, vertically centered) travels left→right over 20s, shows email icon + sender + subject in a translucent rounded pill (35% black opacity). No auto-dismiss — close button (✕) required. Menu bar ✉️ icon → Settings (or auto-opens on first launch). Settings window (420×470): Gmail address + app password (with show/hide toggle), "Start at login" checkbox, Save/Clear buttons. Window switches between banner mode and settings mode via window_manager resize. Banner appears on all Spaces and over full-screen apps.

## Packages
- `window_manager ^0.3.9` — overlay window management
- `flutter_secure_storage ^9.2.4` — Keychain credential storage
- `enough_mail ^2.1.7` — IMAP IDLE
- `flutter_bloc ^8.1` + `equatable ^2.0.5` — state management
- `get_it ^7.6` — DI
- `tray_manager ^0.5.3` — macOS menu bar icon
- `launch_at_startup ^0.5.1` — macOS SMAppService login item
- `package_info_plus ^9.0.1` — app name for launchAtStartup.setup()

## Build & run — working ✅
- Run standalone (NOT via `flutter run`): `flutter build macos --debug` then open the `.app`
- Code signing: DEVELOPMENT_TEAM = NDUP44J95M, CODE_SIGN_IDENTITY = "Apple Development" on all Runner configs
- `Failed to foreground app; open returned 1` on launch is EXPECTED — benign LSUIElement background-app message.
- After a clean/fresh clone, first build must use:
  `xcodebuild -workspace macos/Runner.xcworkspace -scheme Runner -configuration Debug -allowProvisioningUpdates build`

## Verified live
- App launches, settings window opens (420×320, centered) when no credentials stored
- No RenderFlex overflow
- Signed with Apple Development cert (Team NDUP44J95M); keychain group resolves to `NDUP44J95M.com.faizan.macosLayoverEmail`

## Keychain signing — IMPORTANT
A sandboxed macOS app REQUIRES `keychain-access-groups` to touch the Keychain, and that
entitlement must be signed with a development cert (not ad-hoc). Without it,
flutter_secure_storage throws `-34018 errSecMissingEntitlement` at save time.
- Entitlements declare `$(AppIdentifierPrefix)$(PRODUCT_BUNDLE_IDENTIFIER)`
- Runner configs set `CODE_SIGN_IDENTITY = "Apple Development"` + `DEVELOPMENT_TEAM = NDUP44J95M`
- After a clean / fresh clone, the FIRST build must generate the provisioning profile:
  `xcodebuild -workspace macos/Runner.xcworkspace -scheme Runner -configuration Debug -allowProvisioningUpdates build`
  Then `flutter run -d macos` reuses it. (flutter run alone can't create the profile.)

## END-TO-END VERIFIED LIVE ✅ (2026-06-17)
- Keychain save/load round-trip ✅ (-34018 fixed via dev signing + keychain group)
- IMAP IDLE connect + INBOX select ✅ (single established :993 connection, no idleStart error)
- Real incoming email → banner fires ✅ (log: "New email received — showing banner")
- App stays alive as background agent after banner + after window hide ✅
- Auth-failure UX ✅ (bad creds → Settings reopens with red error, email pre-filled)
- Password show/hide toggle ✅

## Launch at login
- `launch_at_startup` + `package_info_plus`; `StartupService` abstraction (GetIt).
- Settings has a "Start automatically at login (recommended)" checkbox — ON by
  default on first run, reflects real OS state for returning users. Registers via
  macOS SMAppService. This first-run checkbox IS the post-install prompt.
- Keychain items can become unreadable after a rebuild re-signs the binary
  (-25308). App self-recovers: `isCredentialError()` → reopens Settings asking to
  re-enter. One-time re-entry per rebuild; non-issue for install-once end users.

## Run notes
- Run standalone (NOT via flutter run): `flutter build macos --debug` then
  `open build/macos/Build/Products/Debug/macos_layover_email.app`. Under flutter
  run the debugger heartbeat can drop during window resizes ("Lost connection").
- `Resize timed out` and `Failed to foreground app` log lines are benign.
- To watch logs of a standalone run, launch the binary directly:
  `.../macos_layover_email.app/Contents/MacOS/macos_layover_email` (stdout shows flutter: prints).

## Transparency + IMAP latency fix (2026-06-17)
- **Transparent window background**: Fixed with three-pronged approach:
  1. Swift `awakeFromNib` now sets `CAMetalLayer.isOpaque=false` directly on `flutterViewController.view` before Flutter initialises its renderer
  2. New `makeLayersTransparent(_:)` recursive helper walks the entire view/layer tree on every `applyTransparency()` call
  3. `applyTransparency()` now runs BEFORE `super.order()` so the window is non-opaque before macOS composites it (prevents black flash on show)
  4. Dart side: `windowManager.setBackgroundColor(Colors.transparent)` called after `windowManager.show()` in `_onNewEmail` to re-assert transparency after each show
- **IMAP latency**: Changed `startPolling(Duration(minutes: 1))` → `startPolling()` (default = 2 min). enough_mail recognises the default and uses a 5-minute IDLE-restart cycle on IDLE-capable servers (Gmail). Fewer `idleDone/idleStart` round-trips = lower latency when a push notification arrives. Note: residual ~5–20s delay after this change is Gmail's own server-side IMAP IDLE notification latency and cannot be reduced further with IDLE alone.

## 2026-06-18 updates
- **Lottie parrot animation**: Replaced email icon with `parrot.json` on the right of the pill, flipped to face travel direction. 67/67 tests passing.
- **User-friendly errors**: CredentialsCubit + main.dart map all PlatformException/Keychain errors to plain English — no jargon, no "Keychain" word shown to user.
- **Clear error on edit**: Settings clears the error message the moment the user edits any field.
- **Debug logging**: `[IMAP]` / `[CredentialsCubit]` / `[Settings]` / `[Main]` prefixed logs throughout — visible when running via `run.sh` or the binary directly.
- **`run.sh`**: Single script to build and launch correctly every time. Restores signing-critical files, runs xcodebuild with `-allowProvisioningUpdates`, verifies signing, then launches binary with logs in terminal. See CLAUDE.md.

## 2026-06-18 session 2 — fixes applied
- **AppDelegate fix**: `applicationShouldTerminateAfterLastWindowClosed` was returning `true`, killing the app every time the settings window was hidden. Changed to `return false` in `macos/Runner/AppDelegate.swift`. App now stays alive as background agent correctly.
- **`run.sh`**: Build script at repo root — restores signing-critical files, builds via xcodebuild with `-allowProvisioningUpdates`, verifies signing and keychain entitlement, then launches binary with logs streaming to terminal. Flags: `--test`, `--clean`.
- **Debug logging**: `[IMAP]` / `[CredentialsCubit]` / `[Settings]` / `[Main]` prefixed logs throughout all layers.
- **setPreventClose(true)**: Added to `windowManager.waitUntilReadyToShow` setup in `main.dart`.

## Verify-before-save — COMPLETE (2026-06-18)
Credentials are now verified against IMAP before being written to Keychain.

**Flow:**
1. User hits Save → `EmailMonitorCubit.verifyAndSave(email, pass)` → quick IMAP connect/select/disconnect
2. Success → emits `EmailMonitorVerified(email, pass)` → main.dart catches it → calls `credentialsCubit.save()` → `CredentialsSaved` → `_hideToBanner()` + `restart()`
3. Failure → emits `EmailMonitorError` → SettingsScreen shows friendly error, nothing saved to Keychain

**Changes:**
- `lib/data/datasources/imap_data_source.dart` — `verifyCredentials` on abstract + impl (connect → selectInbox → disconnect)
- `lib/domain/repositories/email_repository.dart` + impl — `verifyCredentials` delegation
- `lib/domain/usecases/verify_credentials.dart` — new use case
- `lib/presentation/cubits/email_monitor/email_monitor_state.dart` — `EmailMonitorVerifying` + `EmailMonitorVerified(email, password)`
- `lib/presentation/cubits/email_monitor/email_monitor_cubit.dart` — `verifyAndSave()`, `_friendlyError()` helper
- `lib/injection/injection_container.dart` — `VerifyCredentials` registered + passed to cubit
- `lib/presentation/screens/settings_screen.dart` — Save calls `verifyAndSave`, spinner while verifying, `EmailMonitorCubit` BlocListener for error
- `lib/main.dart` — `EmailMonitorVerified` → `credentialsCubit.save()`; background IMAP errors only open settings when settings is already hidden
- Tests: 73/73 passing (`verify_credentials_test.dart` added, `email_monitor_cubit_test` + `settings_screen_test` updated)

## 2026-06-18 session 3 — no credential storage, running screen
- **No Keychain storage**: credentials are never saved. User must enter them each time the app starts.
- **No auto-login**: `start()` always emits `CredentialsMissing` → settings screen opens on launch.
- **`verifyAndStart()`**: replaces `verifyAndSave` — verifies IMAP then starts monitoring in-memory. Emits `EmailMonitorListening` on success (main.dart hides to banner).
- **`stop()`**: new cubit method — cancels subscription, emits `EmailMonitorStopped` → settings screen reopens.
- **Running screen**: after Connect succeeds, window hides to banner. Tray "Settings" → shows `RunningScreen` ("App is running" + Stop button) while monitoring, or settings form if not.
- **Settings screen**: removed startup checkbox, Clear button, and `CredentialsCubit` dependency. Save → Connect button.
- **`EmailMonitorStopped`** state added; `EmailMonitorVerified`/`EmailMonitorConnecting` removed.
- Tests: 65/65 passing.

## 2026-06-18 session 4 — banner over full-screen apps + dock icon
- **Dock icon vs full-screen overlay = mutually exclusive on macOS.** A `.regular` (Dock-icon) app is BLOCKED by macOS from drawing into another app's full-screen Space; only `.accessory` (no-Dock agent) apps can. Chosen: `.accessory` so the overlay works. Dock-icon code is commented (not deleted) for easy restore.
  - `macos/Runner/AppDelegate.swift` — `applicationWillFinishLaunching` calls `NSApp.setActivationPolicy(.accessory)` (source of truth). Commented `.regular` line restores the Dock icon.
  - `lib/main.dart` — `skipTaskbar: true` (was `false`). Comment documents the toggle.
  - Custom blue mail icon still wired into `AppIcon.appiconset` (all 7 sizes via `sips`) — shows in Finder/switcher; only the Dock icon is suppressed by `.accessory`.
  - Quit paths without Dock: menu-bar ✉️ → Quit, and the settings/running window ✕.
- **Banner over full-screen apps — SOLVED (verified live).** The real fix was the **window type**: a plain `NSWindow` cannot composite into another app's full-screen Space (proven by logs: `policy=1 behavior=273 level=1000` all correct, still failed). Switched `MainFlutterWindow` from `NSWindow` → non-activating **`NSPanel`** (`.nonactivatingPanel` style mask + `hidesOnDeactivate=false` + `canBecomeKey/Main` overridden so settings text input still works). This is what Spotlight/Alfred/menu-bar overlays use. Two supporting pieces were also required:
  - `.accessory` activation policy (regular/Dock apps are blocked from full-screen Spaces);
  - native `orderFrontRegardless()` instead of `windowManager.show()` (the latter calls `NSApp.activate()` and yanks you out of full-screen).
- Earlier red herrings (necessary but not sufficient on their own): `setVisibleOnAllWorkspaces`, `collectionBehavior`, window `level`. Details of the show/hide channel below:
- **Transparency regression fix**: the NSPanel conversion left the Flutter Metal layer drawing an opaque black rounded rectangle behind the banner. Window-level `isOpaque=false`/`backgroundColor=.clear` is NOT enough — added `flutterViewController.backgroundColor = .clear` in `awakeFromNib`. Banner is fully transparent again (text readable via drop shadows). Verified live.
  - `macos/Runner/MainFlutterWindow.swift` — set window `level` to `CGShieldingWindowLevel()-1` and `collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]`; added a `com.faizan.macosLayoverEmail/overlay` MethodChannel with `showOverlay` (`orderFrontRegardless()` — shows without activating) and `hideOverlay` (`orderOut`).
  - `lib/core/overlay_window.dart` — Dart wrapper for the overlay channel (swallows MissingPluginException under test).
  - `lib/presentation/widgets/email_banner.dart` — `_onNewEmail` uses `OverlayWindow.show()`; `_dismiss` uses `OverlayWindow.hide()`.
  - `lib/main.dart` — `_hideToBanner` uses `OverlayWindow.hide()` (orderOut) instead of `windowManager.hide()` (NSApp.hide) so the app isn't hidden before the next banner; `alwaysOnTop: false` (level now owned natively).
- Tests: 65/65 passing (banner test mocks the overlay channel, asserts `showOverlay`/`hideOverlay`).

## 2026-06-18 session 5 — dead-code cleanup
Removed the credential-storage and start-at-login slices, orphaned once credentials went in-memory-only and the login checkbox was dropped.
- **Deleted files**: `credentials_cubit.dart` + `credentials_state.dart` (whole `cubits/credentials/` dir), `load/save/clear_credentials.dart`, `credential_repository.dart` + impl, `credential_data_source.dart`, `credentials_model.dart`, `core/startup_service.dart` — plus their 5 test files.
- **Trimmed**: `failures.dart` now only `Failure` + `NetworkFailure` (removed unused `StorageFailure`, `CredentialFailure`).
- **Packages removed** from pubspec: `flutter_secure_storage`, `launch_at_startup`, `package_info_plus`.
- **DI**: `injection_container.dart` slimmed to EmailMonitorCubit + WatchNewEmails/VerifyCredentials/StopWatching + EmailRepository + ImapDataSource.
- **Leak fix (bonus)**: `stopWatching()` was defined but never called — `EmailMonitorCubit.stop()`/`restart()`/`close()` cancelled the Dart subscription but left the `MailClient` polling. Added `StopWatching` use case + `_teardown()` helper that cancels the subscription AND closes the IMAP connection.
- Entitlements/signing verified intact after `pod install` (network.client present; keychain group retained but unused). Tests: **43/43 passing** (was 65; removed dead-code tests).

## 2026-06-18 session 6 — drop menu-bar tray + RunningScreen
- **Tray removed**: `tray_manager` produced no visible status item on this macOS (emoji title AND PNG icon both invisible). Tried a native `NSStatusItem` (SF Symbol envelope) — worked — but per request the tray is dropped for now. Removed: `tray_manager` package, the native status-item code in `MainFlutterWindow.swift`, the tray channel in `main.dart`, and the `assets/icons/` tray PNGs. The `.regular`/Dock-icon toggle in `AppDelegate.swift` is still the documented way to get a quit/settings entry point back.
- **RunningScreen cascade**: with no tray, `_showSettings()` is never called while monitoring, so `'running'` mode was unreachable. Removed `running_screen.dart` and the orphaned chain it anchored: `EmailMonitorCubit.stop()` (only RunningScreen called it), `EmailMonitorCubit.restart()` (no callers left), `EmailMonitorStopped` state, and `main.dart`'s `_isMonitoring` / `_runningHeight` / `'running'` branch. `_teardown()` + `StopWatching` stay (used by `close()`); added a `close()` teardown test to keep the leak-fix covered.
- **Banner shadow fix**: re-assert `hasShadow = false` in the native `showOverlay` (window_manager's show/resize re-enabled the macOS window shadow → a visible "top shadow").
- ⚠️ UX consequence (accepted for now): no Dock icon + no tray ⇒ once the app hides to banner mode there's no on-screen way to reopen Settings or quit; quit via stopping the run / Activity Monitor, or re-enable the Dock icon.
- Tests: **42/42 passing**.

## 2026-06-20 — richer banner content
Banner now shows five stacked lines (top→bottom): **"Email received"** heading (bold green `#30D158`, macOS built-in **Snell Roundhand** script font — no asset/runtime download needed), sender **name** (12px), sender **email** (8px), **subject** (16px bold), and **message body** (12px, 2 lines, ellipsized; line hidden when empty). Parrot stays on the right.
- **New data captured**: added `senderName` + `body` to `Email` entity + `EmailModel`. `senderName` from `from.first.personalName` (falls back to address); `body` from `decodeTextPlainPart()`, whitespace-collapsed.
- **Body fetch**: `ImapDataSourceImpl` now `fetchMessageContents()` on each `MailLoadEvent` (IDLE delivers headers-only) before emitting — falls back to headers-only message on fetch failure so the banner still fires.
- **Banner plumbing**: `BannerController` event is now `BannerEvent = ({subject, name, from, body})`; `main.dart` passes all four; pill grew `420×90` → `440×170` (constant duplicated in `main.dart` + `email_banner.dart`, must stay in sync).
- Tests: **43/43 passing** (banner/controller/cubit/repo/usecase tests updated for new fields; added empty-body test).

## Next / Polish
- Replace ✉️ emoji tray title with a proper PNG template image for native menu bar look
- Add error recovery UI: banner or tray tooltip when IMAP reconnect fails repeatedly
- Consider queuing emails that arrive while settings is open (currently suppressed)
