# macos_layover_email

A macOS **background agent** that watches your Gmail inbox over IMAP IDLE and, when
a new email arrives, shows a floating banner — a waving 🚩 pink flag followed by
the email subject — that travels **left→right across the middle of the screen**
and parks at the right edge until you dismiss it with the ✕ button. It works with
no app windows open and shows above all other apps.

- No Dock icon (runs as a menu-bar / background agent via `LSUIElement`)
- Credentials stored only in the macOS **Keychain** (never on disk or in git)
- macOS only

> **This repo is meant to be cloned and run per-person.** Each user builds it
> with their own free Apple ID and enters their own Gmail credentials — nothing
> sensitive is shared. Follow the steps below.

---

## 1. Prerequisites

| Requirement | Version / Notes |
|---|---|
| Flutter | **3.44.1** (stable) — system install. **Do NOT use FVM.** |
| Dart | 3.12.1 (bundled with the Flutter above) |
| macOS | 10.15 (Catalina) or newer |
| Xcode | Required for code signing (free Apple ID works) |
| Apple Developer account | A **free** Apple ID is enough for local/dev signing |

Verify Flutter:
```bash
flutter --version   # should report 3.44.1
```

---

## 2. First-time setup

```bash
git clone <repo-url>
cd macos_layover_email
flutter pub get
```

### 2a. Set YOUR Apple Development Team (required)

The Keychain entitlement means the app **must be signed with a development
certificate** — ad-hoc signing won't work. The committed project contains the
original author's Team ID, so **each developer must switch it to their own**:

**Easiest way (Xcode):**
1. `open macos/Runner.xcworkspace`
2. Select the **Runner** target → **Signing & Capabilities** tab.
3. Tick **Automatically manage signing** and pick **your** Team from the dropdown
   (sign in with your Apple ID under Xcode ▸ Settings ▸ Accounts if needed).
4. Xcode generates a provisioning profile for you automatically.

The Keychain access group is declared as
`$(AppIdentifierPrefix)$(PRODUCT_BUNDLE_IDENTIFIER)`, so it auto-resolves to
*your* team prefix — no manual edit needed there.

> If two people build on the same Apple ID, the bundle id
> `com.faizan.macosLayoverEmail` is fine. If you hit a signing conflict, change
> `PRODUCT_BUNDLE_IDENTIFIER` to something unique (e.g. `com.<you>.macosLayoverEmail`).

---

## 3. Get a Gmail App Password

The app authenticates with Gmail using an **App Password**, not your normal
account password.

1. **Enable 2-Step Verification** on your Google account (required for App Passwords):
   https://myaccount.google.com/security
2. Generate an App Password: https://myaccount.google.com/apppasswords
   - Google shows it as four groups, e.g. `abcd efgh ijkl mnop`.
   - **Enter it as 16 characters with NO spaces** → `abcdefghijklmnop`.
     (Spaces are the #1 cause of `AUTHENTICATIONFAILED`.)

### Do I need to "enable IMAP"?
For **personal `@gmail.com` accounts, IMAP is always on** — Google removed the
enable/disable toggle in early 2025. If you open Gmail ▸ Settings ▸
*Forwarding and POP/IMAP* and the IMAP section has no on/off switch (only
behavior options like Auto-Expunge), that's expected — IMAP is already enabled.
For **Google Workspace** accounts, an admin may need to allow IMAP org-wide.

---

## 4. Run the app

This is a background agent that **hides its window** when idle. Run the built app
standalone (not under `flutter run`) for normal use:

```bash
# Build a debug app bundle
flutter build macos --debug

# Launch it (detached — survives independently)
open build/macos/Build/Products/Debug/macos_layover_email.app
```

> **First build only:** if `flutter build` fails with a provisioning error, generate
> the profile once via Xcode (open the workspace and build with Cmd+B), **or** run:
> ```bash
> xcodebuild -workspace macos/Runner.xcworkspace -scheme Runner \
>   -configuration Debug -allowProvisioningUpdates build
> ```
> After the profile exists, `flutter build macos --debug` works on its own.

**On first launch** (no credentials saved) a **Settings window** opens
automatically. Enter your Gmail address + App Password (use the 👁 toggle to check
it), leave **"Start automatically at login"** ticked, and click **Save**. The
window disappears and the agent connects to Gmail.

Look for the **✉️ icon in your menu bar** — click it for **Settings** or **Quit**
at any time.

### Confirm it works
Once connected, **send yourself a test email**. Within a few seconds a banner
travels **left→right across the middle of your screen** — a waving 🚩 flag + the
subject — and parks at the right edge. It stays there until you click the **✕** to
dismiss it. That's the full pipeline working. (IMAP IDLE notifies on *newly
arriving* mail, not existing unread messages.)

### Start at login
There's a **"Start automatically at login"** checkbox in Settings (on by default).
It registers the app via macOS SMAppService — no manual Login Items step needed.
You can verify/toggle it later in System Settings ▸ General ▸ Login Items.

### Developing with hot reload
`flutter run -d macos` works for active development, but note: while attached to
the debugger, rapid window resizes can drop the VM-service connection
("Lost connection to device"). For testing real behavior, prefer the standalone
`open` method above.

---

## 5. How it works

Clean Architecture + Bloc/Cubit, dependency-injected with GetIt:

```
lib/
├── core/            Failure types, IMAP error classification, StartupService
├── domain/          Entities (Email, Credentials), repo interfaces, use cases
├── data/            Models, IMAP + Keychain data sources, repo implementations
├── presentation/
│   ├── cubits/      EmailMonitorCubit, CredentialsCubit (sealed states)
│   ├── screens/     SettingsScreen
│   └── widgets/     EmailBanner, BannerController
└── main.dart        Window setup, tray menu, state wiring
```

- **Email** — `enough_mail` IMAP IDLE to `imap.gmail.com:993` (SSL).
- **Overlay** — `window_manager` keeps one always-on-top window that switches
  between *banner mode* (full-width strip, vertically centered, transparent; the
  content travels left→right and parks at the right with a ✕ close button; the
  window is interactive while a banner shows, click-through and hidden when idle)
  and *settings mode* (420×470, centered, interactive).
- **Credentials** — `flutter_secure_storage` → macOS Keychain.
- **Tray** — `tray_manager` for the menu-bar ✉️ icon.
- **Login at startup** — `launch_at_startup` (macOS SMAppService), wrapped by
  `StartupService` and toggled from the Settings checkbox.

---

## 6. Tests

```bash
flutter test          # 66 tests
flutter analyze       # should report no issues
```

See `CHECKLIST.md` for the pre-push / pre-run checklist. Every new use case,
cubit, repository, or widget ships with tests.

---

## 7. Troubleshooting

| Symptom | Cause & fix |
|---|---|
| `AUTHENTICATIONFAILED — Invalid credentials` | App Password entered with spaces (remove them), wrong account, revoked password, or 2FA not enabled. Personal Gmail does **not** need IMAP enabled manually. |
| `-34018 — A required entitlement isn't present` | App isn't signed with a development cert. Set your Team in Xcode (see §2a) and rebuild. |
| Build: *"entitlements require signing with a development certificate"* | Same as above — select your Team; first build needs `-allowProvisioningUpdates` (see §4). |
| App quits right after Save / when banner hides | Fixed in code (`AppDelegate.applicationShouldTerminateAfterLastWindowClosed = false`). Make sure you're on the latest build. |
| `-25308 — User interaction is not allowed` after rebuilding | Keychain items can become unreadable when the app binary is re-signed (dev rebuilds). The app now auto-reopens Settings — just **re-enter your credentials once** on the new build. End users who install once never hit this. |
| `Failed to foreground app; open returned 1` | Harmless — expected for a Dock-less `LSUIElement` background app. |
| No banner appears on new mail | Confirm the agent is connected (no Settings error), and that the email is genuinely *new* (IMAP IDLE notifies on arrival, not for existing unread mail). |

---

## 8. Security notes

- Gmail App Password lives **only** in the macOS Keychain — never in code, `.env`,
  or git.
- `.env` and `google-services.json` are gitignored.
- The app sandbox stays **ON**; entitlements grant only `network.client` (+
  `network.server` in debug for the Dart VM service) and Keychain access.
