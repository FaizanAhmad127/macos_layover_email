# macos_layover_email

## What this app does
A macOS background agent that watches Gmail (IMAP IDLE) and displays a floating overlay banner whenever a new email arrives. The banner animates left-to-right across the screen: a waving pink flag followed by the email subject. Works regardless of whether any other window is open.

## Stack
- Flutter 3.44.1 / Dart 3.12.1 (system install at `/Users/macboo/development/flutter`)
- macOS only (`--platforms=macos`)
- Bundle ID: `com.faizan.macosLayoverEmail`
- Min macOS: 10.15

## Key architecture decisions
- **No Dock icon** — `LSUIElement = true` in `Info.plist`; app runs as a background agent
- **Overlay window** — must use `window_manager` package to set `NSWindowLevel` above all other windows
- **Email** — Gmail only, via IMAP IDLE (port 993 SSL). Credentials stored in macOS Keychain via `flutter_secure_storage`, never in code
- **No sandboxing removal** — sandbox stays on; entitlements grant `network.client` + keychain access

## What's already set up
- Flutter project initialized (`flutter create`)
- Entitlements: network client + keychain (both Debug and Release)
- `.gitignore` covers secrets (`.env`, `google-services.json`) and macOS build artifacts
- VS Code: format-on-save, Dart formatter
- Git repo initialized (initial commit on `main`)
- GitHub MCP configured in `~/.claude/mcp.json` (token stored there, not in repo)

## Credentials policy
- Gmail app password → macOS Keychain only (never in code or `.env`)
- GitHub token → `~/.claude/mcp.json` (never committed)
- Do NOT use FVM — use system Flutter

## Next steps (not yet implemented)
1. Add packages: `window_manager`, `flutter_secure_storage`, `enough_mail` (IMAP)
2. Implement IMAP IDLE listener (background isolate)
3. Build overlay banner widget (pink waving flag + subject text, slide-in animation)
4. Wire up: email arrives → trigger banner on screen
5. Add settings UI (Gmail credentials entry, stored to Keychain)
