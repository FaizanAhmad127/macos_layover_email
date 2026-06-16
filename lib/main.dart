import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'services/credential_service.dart';
import 'services/imap_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Hide the default Flutter window — this app runs as a background agent.
  // The overlay banner will be shown in a separate floating window.
  await windowManager.hide();

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _imap = ImapService();

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  Future<void> _startListening() async {
    final creds = await CredentialService.load();
    if (creds == null) {
      debugPrint('App: no credentials stored — banner will not appear');
      return;
    }

    _imap.onNewEmail.listen((subject) {
      debugPrint('App: new email received — "$subject"');
      // TODO: show banner overlay
    });

    await _imap.start(creds.email, creds.password);
  }

  @override
  void dispose() {
    _imap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No visible UI — app lives entirely in the background.
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SizedBox.shrink(),
    );
  }
}
