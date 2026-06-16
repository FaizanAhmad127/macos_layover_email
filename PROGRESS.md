# Progress

## Completed
- Flutter project initialized (Flutter 3.44.1, macOS only)
- Entitlements: network client + keychain (Debug + Release)
- Info.plist: LSUIElement = true (no Dock icon, background agent)
- .gitignore: secrets + macOS build artifacts excluded
- VS Code: format-on-save, Dart formatter, removed FVM SDK path
- Git repo initialized, initial commit on `main`
- GitHub MCP configured in ~/.claude/mcp.json
- Packages added: `window_manager ^0.3.9`, `flutter_secure_storage ^9.2.4`, `enough_mail ^2.1.7`
- `MainFlutterWindow.swift` updated for window_manager (hiddenWindowAtLaunch)
- `lib/services/credential_service.dart` — Keychain read/write via flutter_secure_storage
- `lib/services/imap_service.dart` — Gmail IMAP using MailClient.fromManualSettings + MailLoadEvent
- `lib/main.dart` — background agent: hides window, loads credentials, starts IMAP listener

## Current state
App is a background agent that connects to Gmail via IMAP IDLE on launch (if credentials exist).
New email subjects are emitted on a stream. No banner UI yet — subject printed to debug console.
No credential entry UI yet — credentials must be seeded manually via CredentialService.save().

## Next
1. Overlay banner widget (pink waving flag + subject text, slide-in left→right animation)
2. Wire `_imap.onNewEmail` → show banner window via window_manager
3. Settings UI for Gmail credentials entry (email + app password → saved to Keychain)
