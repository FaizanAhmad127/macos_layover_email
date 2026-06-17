import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import 'injection/injection_container.dart';
import 'presentation/cubits/credentials/credentials_cubit.dart';
import 'presentation/cubits/email_monitor/email_monitor_cubit.dart';
import 'presentation/cubits/email_monitor/email_monitor_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.hide();

  initDependencies();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<EmailMonitorCubit>()..start(),
        ),
        BlocProvider(
          create: (_) => sl<CredentialsCubit>()..load(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BlocListener<EmailMonitorCubit, EmailMonitorState>(
          listener: (context, state) {
            switch (state) {
              case EmailMonitorNewEmail(:final email):
                debugPrint('New email: "${email.subject}" from ${email.from}');
                // TODO: show banner overlay
              case EmailMonitorCredentialsMissing():
                debugPrint('No credentials stored — set them via CredentialsCubit.save()');
              case EmailMonitorError(:final message):
                debugPrint('IMAP error: $message');
              default:
                break;
            }
          },
          child: const SizedBox.shrink(),
        ),
      ),
    );
  }
}
