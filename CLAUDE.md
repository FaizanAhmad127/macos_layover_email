# macos_layover_email

## What this app does
macOS background agent that watches Gmail (IMAP IDLE) and displays a floating overlay banner on new email. Banner animates left-to-right: waving pink flag + email subject. Works with no windows open.

## Stack
- Flutter 3.44.1 / Dart 3.12.1 — system install at `/Users/macboo/development/flutter`
- macOS only. Bundle ID: `com.faizan.macosLayoverEmail`. Min macOS: 10.15
- Do NOT use FVM

## Architecture
- No Dock icon — `NSApp.setActivationPolicy(.accessory)` in `AppDelegate.swift` (REQUIRED for the banner to draw over other apps' full-screen Spaces; a `.regular`/Dock app is blocked). Commented `.regular` line restores the Dock icon at the cost of full-screen overlay.
- Overlay window — `MainFlutterWindow` is a non-activating `NSPanel` (`.nonactivatingPanel`, `.screenSaver` level, `.canJoinAllSpaces`); shown via native `orderFrontRegardless()` over a method channel, NOT `windowManager.show()` (which activates the app and exits full-screen)
- Email — Gmail IMAP IDLE (port 993 SSL); credentials held in memory only, entered each launch, NEVER persisted
- Sandbox stays ON — entitlements grant `network.client` (keychain group retained but unused)

## Credentials policy
- Gmail app password → in memory only, re-entered each launch; never written to disk, Keychain, code, or `.env`
- GitHub token → `~/.claude/mcp.json` only, never committed
- `.env` / `google-services.json` are gitignored

## Build & run
- Use `flutter run -d macos` to run the app with live logs in terminal
- First build on a fresh clone may need: `xcodebuild -workspace macos/Runner.xcworkspace -scheme Runner -configuration Debug -allowProvisioningUpdates build`

## Files that must be preserved (pod install can silently reset these)
- `macos/Runner/DebugProfile.entitlements` — must have `keychain-access-groups` + `network.client`
- `macos/Runner/Release.entitlements` — same
- `macos/Runner/Configs/AppInfo.xcconfig` — must have `PRODUCT_BUNDLE_IDENTIFIER = com.faizan.macosLayoverEmail`
- `macos/Runner.xcodeproj/project.pbxproj` — Runner configs must have `CODE_SIGN_IDENTITY = "Apple Development"` + `DEVELOPMENT_TEAM = NDUP44J95M`

## Command restrictions
- Only use Flutter/Dart commands (`flutter`, `dart`) — no `curl`, `grep`, `find`, `cat`, `tail`, `log`, or other shell utilities
- Only read or write files inside this project directory — never access system logs, external paths, or files outside the repo root

## What NOT to do
- Never `print` or `debugPrint` email subjects, sender addresses, or any credential value — privacy risk even in debug builds
- Never disable the macOS sandbox (`com.apple.security.app-sandbox`) — entitlements already grant what's needed
- Never persist credentials anywhere (`SharedPreferences`, local files, `UserDefaults`, Keychain) — in-memory only, re-entered each launch
- Never commit with `--no-verify` to skip hooks
- Never hardcode IMAP host, port, or any account value — use constants or config, not inline strings scattered across files
- Never push a build artifact (`build/`, `.app`, `.ipa`) to git

## Rules
- Update `PROGRESS.md` after every completed task
- Keep `CLAUDE.md` for permanent facts only — put task history in `PROGRESS.md`

@PROGRESS.md
