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

## Tests — 46/46 passing ✅
- `test/domain/usecases/` — 9/9: LoadCredentials, SaveCredentials, ClearCredentials, WatchNewEmails
- `test/data/repositories/` — 10/10: CredentialRepositoryImpl, EmailRepositoryImpl
- `test/presentation/cubits/` — 14/14: EmailMonitorCubit, CredentialsCubit
- `test/presentation/widgets/` — 5/5: BannerController (inc. settingsOpen guard)
- `test/presentation/screens/` — 8/8: SettingsScreen widget tests
- Going forward: tests written before each commit for every new feature

## Current state
**Feature-complete v1.** Background agent monitors Gmail via IMAP IDLE. On new email: dark banner slides in from left (full-width, 80px, waving 🚩 flag + subject), auto-dismisses after 5s. Menu bar ✉️ icon → Settings (or auto-opens on first launch). Settings window (420×320): enter Gmail address + app password → saved to Keychain. Clear button wipes credentials. Window switches between banner mode and settings mode via window_manager resize.

## Packages
- `window_manager ^0.3.9` — overlay window management
- `flutter_secure_storage ^9.2.4` — Keychain credential storage
- `enough_mail ^2.1.7` — IMAP IDLE
- `flutter_bloc ^8.1` + `equatable ^2.0.5` — state management
- `get_it ^7.6` — DI
- `tray_manager ^0.5.3` — macOS menu bar icon

## Build & run — working ✅
- Builds, signs, and launches on macOS (`flutter run -d macos`)
- Code signing: DEVELOPMENT_TEAM = NDUP44J95M set on all Runner configs
- Entitlements: removed `keychain-access-groups` (not needed — flutter_secure_storage uses default keychain via accountName; the group required a provisioning profile and blocked debug builds). Added `network.server` to DebugProfile only (Dart VM service / hot reload).
- `Failed to foreground app; open returned 1` on launch is EXPECTED — benign LSUIElement background-app message, not an error.

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

## Still needs a live smoke test (with real Gmail app password)
- Keychain save/load round-trip — re-test Save after the -34018 fix
- IMAP IDLE connection to Gmail
- Actual banner slide-in on a real incoming email
- Tray ✉️ menu (Settings / Quit)

## Next / Polish
- Replace ✉️ emoji tray title with a proper PNG template image for native menu bar look
- Add error recovery UI: banner or tray tooltip when IMAP reconnect fails repeatedly
- Consider queuing emails that arrive while settings is open (currently suppressed)
