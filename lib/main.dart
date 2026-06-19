import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import 'core/imap_error.dart';
import 'core/overlay_window.dart';
import 'injection/injection_container.dart';
import 'presentation/cubits/email_monitor/email_monitor_cubit.dart';
import 'presentation/cubits/email_monitor/email_monitor_state.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/widgets/banner_controller.dart';
import 'presentation/widgets/email_banner.dart';

const double _pillWidth = 420;
const double _pillHeight = 90;
const double _settingsWidth = 420;
const double _settingsHeight = 380;
late final double _screenWidth;
late final double _screenHeight;
late final BannerController _bannerController;

Offset get _bannerHiddenPosition =>
    Offset(-_pillWidth, (_screenHeight - _pillHeight) / 2);

// 'settings' | 'banner'
final _windowMode = ValueNotifier<(String, String?)>(('settings', null));

Future<void> _showSettings({String? error}) async {
  _bannerController.settingsOpen = true;
  await windowManager.setIgnoreMouseEvents(false);
  await windowManager.setSize(const Size(_settingsWidth, _settingsHeight));
  _windowMode.value = ('settings', error);
  await windowManager.center();
  await windowManager.show();
  await windowManager.focus();
}

Future<void> _hideToBanner() async {
  debugPrint('[Main] _hideToBanner: switching UI to banner mode');
  _windowMode.value = ('banner', null);
  _bannerController.settingsOpen = false;
  try {
    await OverlayWindow.hide();
    await windowManager.setSize(const Size(_pillWidth, _pillHeight));
    await windowManager.setPosition(_bannerHiddenPosition);
    await windowManager.setIgnoreMouseEvents(true);
  } catch (e, st) {
    debugPrint('[Main] _hideToBanner ERROR: $e\n$st');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  final display =
      WidgetsBinding.instance.platformDispatcher.displays.firstOrNull;
  final dpr = display?.devicePixelRatio ?? 1.0;
  _screenWidth = display != null ? display.size.width / dpr : 1920.0;
  _screenHeight = display != null ? display.size.height / dpr : 1080.0;

  await windowManager.waitUntilReadyToShow(
    WindowOptions(
      size: const Size(_settingsWidth, _settingsHeight),
      backgroundColor: Colors.transparent,
      // No taskbar/Dock entry — background agent. DOCK ICON: set to false (and
      // switch AppDelegate to .regular) to show a Dock icon; full-screen
      // overlay will then stop working.
      skipTaskbar: true,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false,
      alwaysOnTop: false,
    ),
    () async {
      await windowManager.setPreventClose(true);
      await windowManager.setHasShadow(false);
      await windowManager.setVisibleOnAllWorkspaces(
        true,
        visibleOnFullScreen: true,
      );
      await windowManager.setIgnoreMouseEvents(false);
      await windowManager.center();
      await windowManager.show();
      await windowManager.focus();
    },
  );

  initDependencies();
  _bannerController = BannerController()
    ..screenWidth = _screenWidth
    ..screenHeight = _screenHeight;

  runApp(App(bannerController: _bannerController, windowMode: _windowMode));
}

class App extends StatelessWidget {
  const App({
    super.key,
    required this.bannerController,
    required this.windowMode,
  });

  final BannerController bannerController;
  final ValueNotifier<(String, String?)> windowMode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EmailMonitorCubit>()..start(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Material(
          color: Colors.transparent,
          child: BlocListener<EmailMonitorCubit, EmailMonitorState>(
            listener: (ctx, state) {
              switch (state) {
                case EmailMonitorNewEmail(:final email):
                  debugPrint('New email received — showing banner');
                  bannerController.show(
                    subject: email.subject,
                    from: email.from,
                  );
                case EmailMonitorCredentialsMissing():
                  _showSettings();
                case EmailMonitorListening():
                  _hideToBanner();
                case EmailMonitorError(:final message):
                  // While the settings screen is open it shows the error via
                  // its own listener; only reopen settings from banner mode.
                  if (_windowMode.value.$1 != 'settings') {
                    _showSettings(error: _friendlyError(message));
                  }
                default:
                  break;
              }
            },
            child: ValueListenableBuilder<(String, String?)>(
              valueListenable: windowMode,
              builder: (ctx, state, _) {
                final (mode, error) = state;
                return switch (mode) {
                  'settings' => SettingsScreen(errorMessage: error),
                  _ => EmailBanner(controller: bannerController),
                };
              },
            ),
          ),
        ),
      ),
    );
  }

  String _friendlyError(String message) {
    if (isAuthFailure(message)) {
      return 'Wrong credentials. Enter your Gmail address '
          'and a 16-character App Password — not your '
          'regular Gmail password. You can create one at '
          'myaccount.google.com → Security → App Passwords.';
    } else if (isCredentialError(message)) {
      return "Couldn't access saved credentials. "
          'Please enter them again to reconnect.';
    }
    return 'Could not connect to Gmail. '
        'Check your internet connection and credentials, '
        'then tap Connect to reconnect.';
  }
}
