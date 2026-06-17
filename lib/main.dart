import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import 'injection/injection_container.dart';
import 'presentation/cubits/credentials/credentials_cubit.dart';
import 'presentation/cubits/email_monitor/email_monitor_cubit.dart';
import 'presentation/cubits/email_monitor/email_monitor_state.dart';
import 'presentation/widgets/banner_controller.dart';
import 'presentation/widgets/email_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Use primary display logical width so banner spans the full screen
  final display =
      WidgetsBinding.instance.platformDispatcher.displays.firstOrNull;
  final screenWidth = display != null
      ? display.size.width / display.devicePixelRatio
      : 1920.0;

  await windowManager.waitUntilReadyToShow(
    WindowOptions(
      size: Size(screenWidth, 80),
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
      // Window stays hidden until first email arrives
    },
  );

  initDependencies();

  final bannerController = BannerController();
  runApp(App(bannerController: bannerController));
}

class App extends StatelessWidget {
  const App({super.key, required this.bannerController});

  final BannerController bannerController;

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
          child: BlocListener<EmailMonitorCubit, EmailMonitorState>(
            listener: (context, state) {
              switch (state) {
                case EmailMonitorNewEmail(:final email):
                  bannerController.show(email.subject);
                case EmailMonitorCredentialsMissing():
                  // TODO: show settings UI
                  break;
                case EmailMonitorError(:final message):
                  debugPrint('IMAP error: $message');
                default:
                  break;
              }
            },
            child: EmailBanner(controller: bannerController),
          ),
        ),
      ),
    );
  }
}
