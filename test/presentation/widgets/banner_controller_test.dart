import 'package:flutter_test/flutter_test.dart';
import 'package:macos_layover_email/presentation/widgets/banner_controller.dart';

void main() {
  late BannerController sut;

  setUp(() => sut = BannerController());
  tearDown(() => sut.dispose());

  test('show emits subject, name, sender, and body on stream', () async {
    expectLater(
      sut.stream,
      emits((subject: 'Hello', name: 'Alice', from: 'a@b.com', body: 'Hi')),
    );
    sut.show(subject: 'Hello', name: 'Alice', from: 'a@b.com', body: 'Hi');
  });

  test('multiple listeners receive the same event (broadcast)', () async {
    final r1 = <BannerEvent>[];
    final r2 = <BannerEvent>[];

    sut.stream.listen(r1.add);
    sut.stream.listen(r2.add);

    sut.show(subject: 'First', name: 'X', from: 'x@y.com', body: 'b1');
    sut.show(subject: 'Second', name: 'P', from: 'p@q.com', body: 'b2');

    await Future<void>.delayed(Duration.zero);

    expect(r1, [
      (subject: 'First', name: 'X', from: 'x@y.com', body: 'b1'),
      (subject: 'Second', name: 'P', from: 'p@q.com', body: 'b2'),
    ]);
    expect(r2, r1);
  });

  test('show is suppressed when settingsOpen is true', () async {
    sut.settingsOpen = true;
    final received = <BannerEvent>[];
    sut.stream.listen(received.add);

    sut.show(subject: 'Blocked', name: 'X', from: 'x@y.com', body: 'b');
    await Future<void>.delayed(Duration.zero);

    expect(received, isEmpty);
  });

  test('show resumes after settingsOpen is set back to false', () async {
    sut.settingsOpen = true;
    sut.show(subject: 'Blocked', name: 'X', from: 'x@y.com', body: 'b');

    sut.settingsOpen = false;
    expectLater(
      sut.stream,
      emits((subject: 'Visible', name: 'Z', from: 'z@w.com', body: 'b')),
    );
    sut.show(subject: 'Visible', name: 'Z', from: 'z@w.com', body: 'b');
  });
}
