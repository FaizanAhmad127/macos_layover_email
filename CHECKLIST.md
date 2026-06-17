# Checklists

## Pre-push

- [ ] `flutter analyze` — zero errors, zero warnings
- [ ] `flutter test` — all tests pass (currently 33/33)
- [ ] `git diff --cached` — review staged diff, confirm no secrets visible
- [ ] No Gmail address, app password, or token hardcoded anywhere in `lib/`
- [ ] No new files added that should be in `.gitignore` (`.env`, `*.p8`, `*.pem`, `google-services.json`)
- [ ] `PROGRESS.md` updated to reflect what was just completed
- [ ] Tests written for any new use case, cubit, or repository added in this commit

## Pre-run (`flutter run -d macos`)

- [ ] `flutter pub get` — no dependency errors
- [ ] Gmail app password stored in Keychain (enter via Settings UI once built; for now use `flutter_secure_storage` directly in a test harness if needed)
- [ ] Entitlements unchanged — `network.client` + keychain still present in both Debug and Release
- [ ] `LSUIElement = true` still in `Info.plist` (app must not appear in Dock)
- [ ] No leftover `debugPrint` calls that log email content or credentials to console in production paths
- [ ] Build target is macOS, not iOS or simulator
