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

## Tests — 33/33 passing ✅
- `test/domain/usecases/` — 9/9: LoadCredentials, SaveCredentials, ClearCredentials, WatchNewEmails
- `test/data/repositories/` — 10/10: CredentialRepositoryImpl, EmailRepositoryImpl
- `test/presentation/cubits/` — 14/14: EmailMonitorCubit, CredentialsCubit
- Going forward: tests written before each commit for every new feature

## Current state
Background agent with full clean architecture and passing test suite. EmailMonitorCubit starts on launch, connects to Gmail IMAP IDLE, emits EmailMonitorNewEmail state when mail arrives. Debug prints subject to console. No banner UI yet.

## Next

### 1. Overlay banner widget
- Separate floating `NSWindow` opened via `window_manager` at `NSWindowLevel.floating + 1` (above everything)
- Position: top-right of primary screen, full width, ~80px tall
- Content (left→right): animated waving pink flag (emoji `🚩` with a subtle rotation loop) + email subject in white bold text on a dark semi-transparent background
- Animation: window slides in from the left edge of the screen (off-screen → on-screen) over ~400ms using a `CurvedAnimation`
- Auto-dismiss: stays visible for 5 seconds, then slides back out to the left and the window is hidden
- Widget lives at `lib/presentation/widgets/email_banner.dart`

### 2. Wire EmailMonitorNewEmail → banner
- In `main.dart` `BlocListener`, on `EmailMonitorNewEmail` state: call a `BannerController` (or direct `window_manager` call) to show the banner window and pass the subject string
- The banner window is created once at startup (hidden), shown/hidden on demand — do not create a new window per email

### 3. Settings UI for credentials
- Triggered by a menu bar icon or a keyboard shortcut (TBD — decide before implementing)
- Form: two fields — Gmail address + App Password (obscured)
- On save: calls `CredentialsCubit.save()` → stored in Keychain; on success show a brief confirmation
- On clear: calls `CredentialsCubit.clear()`, `EmailMonitorCubit.restart()` re-connects
- Widget lives at `lib/presentation/screens/settings_screen.dart`
