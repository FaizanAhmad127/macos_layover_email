import 'package:flutter_test/flutter_test.dart';
import 'package:macos_layover_email/presentation/widgets/banner_controller.dart';

void main() {
  late BannerController sut;

  setUp(() => sut = BannerController());
  tearDown(() => sut.dispose());

  test('show emits subject on stream', () async {
    expectLater(sut.stream, emits('Hello from test'));
    sut.show('Hello from test');
  });

  test('multiple listeners receive the same subject (broadcast)', () async {
    final received1 = <String>[];
    final received2 = <String>[];

    sut.stream.listen(received1.add);
    sut.stream.listen(received2.add);

    sut.show('First');
    sut.show('Second');

    await Future<void>.delayed(Duration.zero);

    expect(received1, ['First', 'Second']);
    expect(received2, ['First', 'Second']);
  });

  test('stream emits subjects in order', () async {
    final subjects = ['Alpha', 'Beta', 'Gamma'];
    expectLater(sut.stream, emitsInOrder(subjects));
    for (final s in subjects) {
      sut.show(s);
    }
  });
}
