import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:macos_layover_email/domain/entities/credentials.dart';
import 'package:macos_layover_email/domain/usecases/clear_credentials.dart';
import 'package:macos_layover_email/domain/usecases/load_credentials.dart';
import 'package:macos_layover_email/domain/usecases/save_credentials.dart';
import 'package:macos_layover_email/presentation/cubits/credentials/credentials_cubit.dart';
import 'package:macos_layover_email/presentation/cubits/credentials/credentials_state.dart';

class MockLoadCredentials extends Mock implements LoadCredentials {}

class MockSaveCredentials extends Mock implements SaveCredentials {}

class MockClearCredentials extends Mock implements ClearCredentials {}

void main() {
  late MockLoadCredentials mockLoad;
  late MockSaveCredentials mockSave;
  late MockClearCredentials mockClear;

  const tCredentials = Credentials(email: 'test@gmail.com', password: 'pass');

  setUpAll(() {
    registerFallbackValue(tCredentials);
  });

  setUp(() {
    mockLoad = MockLoadCredentials();
    mockSave = MockSaveCredentials();
    mockClear = MockClearCredentials();
  });

  CredentialsCubit build() => CredentialsCubit(
        loadCredentials: mockLoad,
        saveCredentials: mockSave,
        clearCredentials: mockClear,
      );

  test('initial state is CredentialsInitial', () {
    expect(build().state, const CredentialsInitial());
  });

  group('load', () {
    blocTest<CredentialsCubit, CredentialsState>(
      'emits [Loaded] when credentials exist',
      build: () {
        when(() => mockLoad()).thenAnswer((_) async => tCredentials);
        return build();
      },
      act: (c) => c.load(),
      expect: () => [CredentialsLoaded(tCredentials)],
    );

    blocTest<CredentialsCubit, CredentialsState>(
      'emits [Missing] when no credentials stored',
      build: () {
        when(() => mockLoad()).thenAnswer((_) async => null);
        return build();
      },
      act: (c) => c.load(),
      expect: () => [const CredentialsMissing()],
    );

    blocTest<CredentialsCubit, CredentialsState>(
      'emits [Error] when load throws',
      build: () {
        when(() => mockLoad()).thenThrow(Exception('keychain error'));
        return build();
      },
      act: (c) => c.load(),
      expect: () => [isA<CredentialsError>()],
    );
  });

  group('save', () {
    blocTest<CredentialsCubit, CredentialsState>(
      'emits [Saved] on success',
      build: () {
        when(() => mockSave(any())).thenAnswer((_) async {});
        return build();
      },
      act: (c) => c.save('test@gmail.com', 'pass'),
      expect: () => [const CredentialsSaved()],
      verify: (_) =>
          verify(() => mockSave(tCredentials)).called(1),
    );

    blocTest<CredentialsCubit, CredentialsState>(
      'emits [Error] when save throws',
      build: () {
        when(() => mockSave(any())).thenThrow(Exception('keychain error'));
        return build();
      },
      act: (c) => c.save('test@gmail.com', 'pass'),
      expect: () => [isA<CredentialsError>()],
    );
  });

  group('clear', () {
    blocTest<CredentialsCubit, CredentialsState>(
      'emits [Cleared] on success',
      build: () {
        when(() => mockClear()).thenAnswer((_) async {});
        return build();
      },
      act: (c) => c.clear(),
      expect: () => [const CredentialsCleared()],
    );

    blocTest<CredentialsCubit, CredentialsState>(
      'emits [Error] when clear throws',
      build: () {
        when(() => mockClear()).thenThrow(Exception('keychain error'));
        return build();
      },
      act: (c) => c.clear(),
      expect: () => [isA<CredentialsError>()],
    );
  });
}
