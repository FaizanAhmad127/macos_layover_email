import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:macos_layover_email/data/datasources/imap_data_source.dart';
import 'package:macos_layover_email/data/models/email_model.dart';
import 'package:macos_layover_email/data/repositories/email_repository_impl.dart';
import 'package:macos_layover_email/domain/entities/credentials.dart';

class MockImapDataSource extends Mock implements ImapDataSource {}

void main() {
  late EmailRepositoryImpl sut;
  late MockImapDataSource mockDataSource;

  const tCredentials = Credentials(email: 'test@gmail.com', password: 'pass');
  final tEmailModel = EmailModel(
    subject: 'Hello',
    from: 'sender@example.com',
    receivedAt: DateTime(2026, 6, 17),
  );

  setUpAll(() {
    registerFallbackValue(tCredentials);
  });

  setUp(() {
    mockDataSource = MockImapDataSource();
    sut = EmailRepositoryImpl(mockDataSource);
  });

  group('watchNewEmails', () {
    test('delegates email and password to data source', () {
      when(() => mockDataSource.watchNewEmails(any(), any()))
          .thenAnswer((_) => Stream.fromIterable([tEmailModel]));

      sut.watchNewEmails(tCredentials);

      verify(() =>
              mockDataSource.watchNewEmails('test@gmail.com', 'pass'))
          .called(1);
    });

    test('emits Email entities from data source stream', () {
      when(() => mockDataSource.watchNewEmails(any(), any()))
          .thenAnswer((_) => Stream.fromIterable([tEmailModel]));

      expect(
        sut.watchNewEmails(tCredentials),
        emitsInOrder([tEmailModel]),
      );
    });
  });

  group('stopWatching', () {
    test('delegates to data source', () async {
      when(() => mockDataSource.stopWatching()).thenAnswer((_) async {});

      await sut.stopWatching();

      verify(() => mockDataSource.stopWatching()).called(1);
    });
  });
}
