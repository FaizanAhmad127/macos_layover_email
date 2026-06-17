import 'dart:async';

class BannerController {
  final _subject = StreamController<String>.broadcast();

  Stream<String> get stream => _subject.stream;

  void show(String subject) => _subject.add(subject);

  void dispose() => _subject.close();
}
