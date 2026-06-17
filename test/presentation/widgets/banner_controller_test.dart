import 'package:flutter_test/flutter_test.dart';
import 'package:macos_layover_email/presentation/widgets/banner_controller.dart';

void main() {
  late BannerController sut;

  setUp(() => sut = BannerController());
  tearDown(() => sut.dispose());

  test('show emits subject and sender on stream', () async {
    expectLater(
      sut.stream,
      emits((subject: 'Hello', from: 'a@b.com')),
    );
    sut.show(subject: 'Hello', from: 'a@b.com');
  });

  test('multiple listeners receive the same event (broadcast)', () async {
    final r1 = <({String subject, String from})>[];
    final r2 = <({String subject, String from})>[];

    sut.stream.listen(r1.add);
    sut.stream.listen(r2.add);

    sut.show(subject: 'First', from: 'x@y.com');
    sut.show(subject: 'Second', from: 'p@q.com');

    await Future<void>.delayed(Duration.zero);

    expect(r1, [
      (subject: 'First', from: 'x@y.com'),
      (subject: 'Second', from: 'p@q.com'),
    ]);
    expect(r2, r1);
  });

  test('show is suppressed when settingsOpen is true', () async {
    sut.settingsOpen = true;
    final received = <({String subject, String from})>[];
    sut.stream.listen(received.add);

    sut.show(subject: 'Blocked', from: 'x@y.com');
    await Future<void>.delayed(Duration.zero);

    expect(received, isEmpty);
  });

  test('show resumes after settingsOpen is set back to false', () async {
    sut.settingsOpen = true;
    sut.show(subject: 'Blocked', from: 'x@y.com');

    sut.settingsOpen = false;
    expectLater(sut.stream, emits((subject: 'Visible', from: 'z@w.com')));
    sut.show(subject: 'Visible', from: 'z@w.com');
  });
}
