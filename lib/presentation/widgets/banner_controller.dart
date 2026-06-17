import 'dart:async';

/// Bridges the email-monitor state to the [EmailBanner]. Carries both the
/// subject and the sender so the banner can show who the mail is from.
class BannerController {
  final _events = StreamController<({String subject, String from})>.broadcast();

  Stream<({String subject, String from})> get stream => _events.stream;

  // Set true while the settings window is open to suppress banner pop-ups.
  bool settingsOpen = false;

  void show({required String subject, required String from}) {
    if (!settingsOpen) _events.add((subject: subject, from: from));
  }

  void dispose() => _events.close();
}
