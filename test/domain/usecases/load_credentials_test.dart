import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:macos_layover_email/domain/entities/credentials.dart';
import 'package:macos_layover_email/domain/repositories/credential_repository.dart';
import 'package:macos_layover_email/domain/usecases/load_credentials.dart';

class MockCredentialRepository extends Mock implements CredentialRepository {}

void main() {
  late LoadCredentials sut;
  late MockCredentialRepository mockRepository;

  const tCredentials = Credentials(email: 'test@gmail.com', password: 'pass');

  setUp(() {
    mockRepository = MockCredentialRepository();
    sut = LoadCredentials(mockRepository);
  });

  test('returns credentials when they exist', () async {
    when(() => mockRepository.loadCredentials())
        .thenAnswer((_) async => tCredentials);

    final result = await sut();

    expect(result, equals(tCredentials));
    verify(() => mockRepository.loadCredentials()).called(1);
  });

  test('returns null when no credentials are stored', () async {
    when(() => mockRepository.loadCredentials()).thenAnswer((_) async => null);

    final result = await sut();

    expect(result, isNull);
  });

  test('propagates repository failures', () async {
    when(() => mockRepository.loadCredentials())
        .thenAnswer((_) => Future.error(Exception('storage error')));

    await expectLater(sut(), throwsA(isA<Exception>()));
  });
}
