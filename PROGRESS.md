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

## Tests — 36/36 passing ✅
- `test/domain/usecases/` — 9/9: LoadCredentials, SaveCredentials, ClearCredentials, WatchNewEmails
- `test/data/repositories/` — 10/10: CredentialRepositoryImpl, EmailRepositoryImpl
- `test/presentation/cubits/` — 14/14: EmailMonitorCubit, CredentialsCubit
- `test/presentation/widgets/` — 3/3: BannerController
- Going forward: tests written before each commit for every new feature

## Current state
Background agent with overlay banner. On new email, a dark semi-transparent banner slides in from the left across the top of the screen (full width, 80px tall) showing a waving 🚩 flag + email subject. Auto-dismisses after 5 seconds, slides back out. Window is transparent and click-through when banner is not showing.

## Next

### ~~1. Overlay banner widget~~ ✅ Done
### ~~2. Wire EmailMonitorNewEmail → banner~~ ✅ Done

### 3. Settings UI for credentials
- Triggered by a menu bar icon or a keyboard shortcut (TBD — decide before implementing)
- Form: two fields — Gmail address + App Password (obscured)
- On save: calls `CredentialsCubit.save()` → stored in Keychain; on success show a brief confirmation
- On clear: calls `CredentialsCubit.clear()`, `EmailMonitorCubit.restart()` re-connects
- Widget lives at `lib/presentation/screens/settings_screen.dart`
