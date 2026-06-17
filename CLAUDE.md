# macos_layover_email

## What this app does
macOS background agent that watches Gmail (IMAP IDLE) and displays a floating overlay banner on new email. Banner animates left-to-right: waving pink flag + email subject. Works with no windows open.

## Stack
- Flutter 3.44.1 / Dart 3.12.1 — system install at `/Users/macboo/development/flutter`
- macOS only. Bundle ID: `com.faizan.macosLayoverEmail`. Min macOS: 10.15
- Do NOT use FVM

## Architecture
- No Dock icon — `LSUIElement = true` in `Info.plist`
- Overlay window — `window_manager` package sets `NSWindowLevel` above all windows
- Email — Gmail IMAP IDLE (port 993 SSL), credentials in macOS Keychain via `flutter_secure_storage`
- Sandbox stays ON — entitlements grant `network.client` + keychain

## Credentials policy
- Gmail app password → Keychain only, never in code or `.env`
- GitHub token → `~/.claude/mcp.json` only, never committed
- `.env` / `google-services.json` are gitignored

## What NOT to do
- Never `print` or `debugPrint` email subjects, sender addresses, or any credential value — privacy risk even in debug builds
- Never disable the macOS sandbox (`com.apple.security.app-sandbox`) — entitlements already grant what's needed
- Never store credentials in `SharedPreferences`, local files, or `UserDefaults` — Keychain only
- Never commit with `--no-verify` to skip hooks
- Never hardcode IMAP host, port, or any account value — use constants or config, not inline strings scattered across files
- Never push a build artifact (`build/`, `.app`, `.ipa`) to git

## Rules
- Update `PROGRESS.md` after every completed task
- Run `CHECKLIST.md` pre-push and pre-run checks before every push or `flutter run`
- Keep `CLAUDE.md` for permanent facts only — put task history in `PROGRESS.md`

@PROGRESS.md
