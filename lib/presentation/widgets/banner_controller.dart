import 'dart:async';

class BannerController {
  final _subject = StreamController<String>.broadcast();

  Stream<String> get stream => _subject.stream;

  // Set true while settings window is open to suppress banner pop-ups
  bool settingsOpen = false;

  void show(String subject) {
    if (!settingsOpen) _subject.add(subject);
  }

  void dispose() => _subject.close();
}
