import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:macos_layover_email/domain/repositories/credential_repository.dart';
import 'package:macos_layover_email/domain/usecases/clear_credentials.dart';

class MockCredentialRepository extends Mock implements CredentialRepository {}

void main() {
  late ClearCredentials sut;
  late MockCredentialRepository mockRepository;

  setUp(() {
    mockRepository = MockCredentialRepository();
    sut = ClearCredentials(mockRepository);
  });

  test('delegates to repository', () async {
    when(() => mockRepository.clearCredentials()).thenAnswer((_) async {});

    await sut();

    verify(() => mockRepository.clearCredentials()).called(1);
  });

  test('propagates repository failures', () async {
    when(() => mockRepository.clearCredentials())
        .thenAnswer((_) => Future.error(Exception('storage error')));

    await expectLater(sut(), throwsA(isA<Exception>()));
  });
}
