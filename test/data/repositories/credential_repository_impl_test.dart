import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:macos_layover_email/core/errors/failures.dart';
import 'package:macos_layover_email/data/datasources/credential_data_source.dart';
import 'package:macos_layover_email/data/repositories/credential_repository_impl.dart';
import 'package:macos_layover_email/domain/entities/credentials.dart';

class MockCredentialDataSource extends Mock implements CredentialDataSource {}

void main() {
  late CredentialRepositoryImpl sut;
  late MockCredentialDataSource mockDataSource;

  const tCredentials = Credentials(email: 'test@gmail.com', password: 'pass');
  final tMap = {'email': 'test@gmail.com', 'password': 'pass'};

  setUp(() {
    mockDataSource = MockCredentialDataSource();
    sut = CredentialRepositoryImpl(mockDataSource);
  });

  group('loadCredentials', () {
    test('returns Credentials when data source returns a map', () async {
      when(() => mockDataSource.loadCredentials())
          .thenAnswer((_) async => tMap);

      final result = await sut.loadCredentials();

      expect(result, isA<Credentials>());
      expect(result?.email, tCredentials.email);
      expect(result?.password, tCredentials.password);
    });

    test('returns null when data source returns null', () async {
      when(() => mockDataSource.loadCredentials()).thenAnswer((_) async => null);

      final result = await sut.loadCredentials();

      expect(result, isNull);
    });

    test('throws StorageFailure on data source exception', () async {
      when(() => mockDataSource.loadCredentials())
          .thenThrow(Exception('keychain error'));

      expect(sut.loadCredentials(), throwsA(isA<StorageFailure>()));
    });
  });

  group('saveCredentials', () {
    test('delegates email and password to data source', () async {
      when(() => mockDataSource.saveCredentials(any(), any()))
          .thenAnswer((_) async {});

      await sut.saveCredentials(tCredentials);

      verify(() => mockDataSource.saveCredentials('test@gmail.com', 'pass'))
          .called(1);
    });

    test('throws StorageFailure on data source exception', () async {
      when(() => mockDataSource.saveCredentials(any(), any()))
          .thenThrow(Exception('keychain error'));

      expect(
          sut.saveCredentials(tCredentials), throwsA(isA<StorageFailure>()));
    });
  });

  group('clearCredentials', () {
    test('delegates to data source', () async {
      when(() => mockDataSource.clearCredentials()).thenAnswer((_) async {});

      await sut.clearCredentials();

      verify(() => mockDataSource.clearCredentials()).called(1);
    });

    test('throws StorageFailure on data source exception', () async {
      when(() => mockDataSource.clearCredentials())
          .thenThrow(Exception('keychain error'));

      expect(sut.clearCredentials(), throwsA(isA<StorageFailure>()));
    });
  });
}
