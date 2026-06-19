import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:macos_layover_email/domain/entities/credentials.dart';
import 'package:macos_layover_email/domain/repositories/email_repository.dart';
import 'package:macos_layover_email/domain/usecases/verify_credentials.dart';

class MockEmailRepository extends Mock implements EmailRepository {}

void main() {
  late VerifyCredentials sut;
  late MockEmailRepository mockRepository;

  const tCredentials = Credentials(email: 'test@gmail.com', password: 'pass');

  setUpAll(() {
    registerFallbackValue(tCredentials);
  });

  setUp(() {
    mockRepository = MockEmailRepository();
    sut = VerifyCredentials(mockRepository);
  });

  test('delegates to repository with given credentials', () async {
    when(() => mockRepository.verifyCredentials(any()))
        .thenAnswer((_) async {});

    await sut(tCredentials);

    verify(() => mockRepository.verifyCredentials(tCredentials)).called(1);
  });

  test('propagates exception from repository', () async {
    when(() => mockRepository.verifyCredentials(any()))
        .thenThrow(Exception('auth failed'));

    expect(() => sut(tCredentials), throwsA(isA<Exception>()));
  });
}
