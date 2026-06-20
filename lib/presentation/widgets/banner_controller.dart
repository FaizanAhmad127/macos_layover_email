import 'dart:async';

/// The payload pushed to the [EmailBanner] for each new email.
typedef BannerEvent = ({
  String subject,
  String name,
  String from,
  String body,
});

/// Bridges the email-monitor state to the [EmailBanner]. Carries the sender
/// name, sender address, subject, and body so the banner can show them all.
class BannerController {
  final _events = StreamController<BannerEvent>.broadcast();

  Stream<BannerEvent> get stream => _events.stream;

  // Set true while the settings window is open to suppress banner pop-ups.
  bool settingsOpen = false;

  /// Screen dimensions used by [EmailBanner] to compute window travel positions.
  /// Must be set by main.dart before the first email arrives.
  double screenWidth = 0;
  double screenHeight = 0;

  void show({
    required String subject,
    required String name,
    required String from,
    required String body,
  }) {
    if (!settingsOpen) {
      _events.add((subject: subject, name: name, from: from, body: body));
    }
  }

  void dispose() => _events.close();
}
