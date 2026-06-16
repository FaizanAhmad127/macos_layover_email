# Progress

## Completed
- Flutter project initialized (Flutter 3.44.1, macOS only)
- Entitlements: network client + keychain (Debug + Release)
- Info.plist: LSUIElement = true (no Dock icon, background agent)
- .gitignore: secrets + macOS build artifacts excluded
- VS Code: format-on-save, Dart formatter, removed FVM SDK path
- Git repo initialized, initial commit on `main`
- GitHub MCP configured in ~/.claude/mcp.json

## Current state
Basic project scaffold only. No Flutter code written yet.

## Next
1. Add packages: `window_manager`, `flutter_secure_storage`, `enough_mail`
2. IMAP IDLE listener (background isolate)
3. Overlay banner widget (pink waving flag + subject, slide-in animation)
4. Wire email arrival → banner trigger
5. Settings UI for Gmail credentials (saved to Keychain)
