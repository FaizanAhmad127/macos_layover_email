import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:macos_layover_email/domain/entities/credentials.dart';
import 'package:macos_layover_email/domain/entities/email.dart';
import 'package:macos_layover_email/domain/repositories/email_repository.dart';
import 'package:macos_layover_email/domain/usecases/watch_new_emails.dart';

class MockEmailRepository extends Mock implements EmailRepository {}

void main() {
  late WatchNewEmails sut;
  late MockEmailRepository mockRepository;

  const tCredentials = Credentials(email: 'test@gmail.com', password: 'pass');
  final tEmail = Email(
    subject: 'Hello',
    from: 'sender@example.com',
    receivedAt: DateTime(2026, 6, 17),
  );

  setUpAll(() {
    registerFallbackValue(tCredentials);
  });

  setUp(() {
    mockRepository = MockEmailRepository();
    sut = WatchNewEmails(mockRepository);
  });

  test('delegates to repository with given credentials', () {
    when(() => mockRepository.watchNewEmails(any()))
        .thenAnswer((_) => Stream.fromIterable([tEmail]));

    final result = sut(tCredentials);

    verify(() => mockRepository.watchNewEmails(tCredentials)).called(1);
    expect(result, emitsInOrder([tEmail]));
  });

  test('propagates errors from repository stream', () {
    when(() => mockRepository.watchNewEmails(any()))
        .thenAnswer((_) => Stream.error(Exception('IMAP error')));

    expect(sut(tCredentials), emitsError(isA<Exception>()));
  });
}
