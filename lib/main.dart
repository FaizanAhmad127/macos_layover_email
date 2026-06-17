import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import 'core/imap_error.dart';
import 'domain/usecases/load_credentials.dart';
import 'injection/injection_container.dart';
import 'presentation/cubits/credentials/credentials_cubit.dart';
import 'presentation/cubits/credentials/credentials_state.dart';
import 'presentation/cubits/email_monitor/email_monitor_cubit.dart';
import 'presentation/cubits/email_monitor/email_monitor_state.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/widgets/banner_controller.dart';
import 'presentation/widgets/email_banner.dart';

// Module-level state shared between main() setup and App widget callbacks
late final double _screenWidth;
late final BannerController _bannerController;

// (isSettingsVisible, initialEmail, errorMessage) — drives the window content
final _settingsState =
    ValueNotifier<(bool, String?, String?)>((false, null, null));

Future<void> _showSettings({String? error}) async {
  // Read the stored email straight from the Keychain so it pre-fills
  // regardless of the CredentialsCubit's current state (Saved/Missing/Loaded).
  String? email;
  try {
    email = (await sl<LoadCredentials>()())?.email;
  } catch (_) {
    email = null;
  }
  _bannerController.settingsOpen = true;
  // Resize the window to settings dimensions BEFORE swapping in the settings
  // widget, so it never lays out at banner size (full-width × 80px).
  await windowManager.setIgnoreMouseEvents(false);
  await windowManager.setSize(const Size(420, 320));
  await windowManager.center();
  _settingsState.value = (true, email, error);
  await windowManager.show();
  await windowManager.focus();
}

Future<void> _hideToBanner() async {
  _settingsState.value = (false, null, null);
  _bannerController.settingsOpen = false;
  await windowManager.hide();
  await windowManager.setSize(Size(_screenWidth, 80));
  await windowManager.setPosition(Offset.zero);
  await windowManager.setIgnoreMouseEvents(true);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  final display =
      WidgetsBinding.instance.platformDispatcher.displays.firstOrNull;
  _screenWidth = display != null
      ? display.size.width / display.devicePixelRatio
      : 1920.0;

  // Configure window for banner mode (initial state)
  await windowManager.waitUntilReadyToShow(
    WindowOptions(
      size: Size(_screenWidth, 80),
      backgroundColor: Colors.transparent,
      skipTaskbar: true,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false,
      alwaysOnTop: true,
    ),
    () async {
      await windowManager.setPosition(Offset.zero);
      await windowManager.setHasShadow(false);
      await windowManager.setIgnoreMouseEvents(true);
    },
  );

  // Menu bar icon — ✉️ emoji; replace with a template PNG for production polish
  await trayManager.setTitle('✉️');
  await trayManager.setContextMenu(Menu(
    items: [
      MenuItem(label: 'Settings', onClick: (_) => _showSettings()),
      MenuItem.separator(),
      MenuItem(label: 'Quit', onClick: (_) => exit(0)),
    ],
  ));

  initDependencies();
  _bannerController = BannerController();

  runApp(App(
    bannerController: _bannerController,
    settingsState: _settingsState,
  ));
}

class App extends StatelessWidget {
  const App({
    super.key,
    required this.bannerController,
    required this.settingsState,
  });

  final BannerController bannerController;
  final ValueNotifier<(bool, String?, String?)> settingsState;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<EmailMonitorCubit>()..start()),
        BlocProvider(create: (_) => sl<CredentialsCubit>()..load()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Material(
          color: Colors.transparent,
          child: MultiBlocListener(
            listeners: [
              BlocListener<EmailMonitorCubit, EmailMonitorState>(
                listener: (ctx, state) {
                  switch (state) {
                    case EmailMonitorNewEmail(:final email):
                      bannerController.show(email.subject);
                    case EmailMonitorCredentialsMissing():
                      _showSettings();
                    case EmailMonitorError(:final message):
                      if (isAuthFailure(message)) {
                        _showSettings(
                          error: 'Gmail rejected these credentials. Use a '
                              '16-character App Password (requires 2-Step '
                              'Verification), entered without spaces.',
                        );
                      } else {
                        debugPrint('IMAP error: $message');
                      }
                    default:
                      break;
                  }
                },
              ),
              BlocListener<CredentialsCubit, CredentialsState>(
                listener: (ctx, state) {
                  switch (state) {
                    case CredentialsSaved():
                      _hideToBanner();
                      ctx.read<EmailMonitorCubit>().restart();
                    case CredentialsCleared():
                      ctx.read<EmailMonitorCubit>().restart();
                      _showSettings();
                    default:
                      break;
                  }
                },
              ),
            ],
            child: ValueListenableBuilder<(bool, String?, String?)>(
              valueListenable: settingsState,
              builder: (ctx, state, _) {
                final (isSettings, email, error) = state;
                return isSettings
                    ? SettingsScreen(initialEmail: email, errorMessage: error)
                    : EmailBanner(controller: bannerController);
              },
            ),
          ),
        ),
      ),
    );
  }
}
