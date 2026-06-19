# macos_layover_email

A macOS background agent that watches your Gmail inbox over IMAP IDLE and shows a
floating overlay banner the moment a new email arrives — no window required, and
it draws over full-screen apps and across all Spaces.

When a new message lands, a transparent banner travels left → right across the
screen showing the sender and subject, with a waving parrot animation. There's no
auto-dismiss; click ✕ to close it.

## Features

- **Push, not poll** — Gmail IMAP IDLE (port 993, SSL) for near-instant notifications
- **Always-on overlay** — appears over other apps' full-screen Spaces (uses a
  non-activating `NSPanel` at screen-saver level, `.accessory` activation policy)
- **No Dock icon** — runs as a lightweight background agent
- **Privacy-first** — credentials are held **in memory only**, re-entered each
  launch; never written to disk, Keychain, or `.env`. Email subjects and senders
  are never logged
- **Verify before start** — credentials are validated against IMAP before
  monitoring begins
- **Clean architecture** — domain / data / presentation layers with Bloc/Cubit
  state management and GetIt dependency injection

## Requirements

- macOS 10.15+
- Flutter 3.44.1 / Dart 3.12.1
- A Gmail **App Password** (not your normal account password) —
  create one at https://myaccount.google.com/apppasswords
  And turn ON 2FA

## Getting started

```bash
flutter pub get
flutter run -d macos
```

On first launch a Settings window opens. Enter your Gmail address and App
Password, then **Connect**. Once verified, the window hides and the app runs in
the background, showing a banner on each new email.

> **First build on a fresh clone** may need to generate a provisioning profile:
> ```bash
> xcodebuild -workspace macos/Runner.xcworkspace -scheme Runner \
>   -configuration Debug -allowProvisioningUpdates build
> ```
> After that, `flutter run -d macos` reuses it.

## Architecture

```
lib/
├── core/            # failures, IMAP error mapping, overlay window channel
├── domain/          # entities, repository interfaces, use cases (pure Dart)
├── data/            # IMAP data source, models, repository implementations
├── presentation/    # EmailMonitorCubit, settings/banner widgets
└── injection/       # GetIt dependency container
```

Credentials never leave memory: the macOS sandbox is kept on (granting only
`network.client`), and there is no persistence layer.

## Tests

```bash
flutter test
```

## License

Personal project — not licensed for redistribution.
