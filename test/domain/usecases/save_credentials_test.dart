import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:macos_layover_email/domain/entities/credentials.dart';
import 'package:macos_layover_email/domain/repositories/credential_repository.dart';
import 'package:macos_layover_email/domain/usecases/save_credentials.dart';

class MockCredentialRepository extends Mock implements CredentialRepository {}

void main() {
  late SaveCredentials sut;
  late MockCredentialRepository mockRepository;

  const tCredentials = Credentials(email: 'test@gmail.com', password: 'pass');

  setUpAll(() {
    registerFallbackValue(tCredentials);
  });

  setUp(() {
    mockRepository = MockCredentialRepository();
    sut = SaveCredentials(mockRepository);
  });

  test('delegates to repository with given credentials', () async {
    when(() => mockRepository.saveCredentials(any()))
        .thenAnswer((_) async {});

    await sut(tCredentials);

    verify(() => mockRepository.saveCredentials(tCredentials)).called(1);
  });

  test('propagates repository failures', () async {
    when(() => mockRepository.saveCredentials(any()))
        .thenAnswer((_) => Future.error(Exception('storage error')));

    await expectLater(sut(tCredentials), throwsA(isA<Exception>()));
  });
}
