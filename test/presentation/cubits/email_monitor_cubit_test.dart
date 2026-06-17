import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:macos_layover_email/domain/entities/credentials.dart';
import 'package:macos_layover_email/domain/entities/email.dart';
import 'package:macos_layover_email/domain/usecases/load_credentials.dart';
import 'package:macos_layover_email/domain/usecases/watch_new_emails.dart';
import 'package:macos_layover_email/presentation/cubits/email_monitor/email_monitor_cubit.dart';
import 'package:macos_layover_email/presentation/cubits/email_monitor/email_monitor_state.dart';

class MockLoadCredentials extends Mock implements LoadCredentials {}

class MockWatchNewEmails extends Mock implements WatchNewEmails {}

void main() {
  late MockLoadCredentials mockLoad;
  late MockWatchNewEmails mockWatch;

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
    mockLoad = MockLoadCredentials();
    mockWatch = MockWatchNewEmails();
  });

  EmailMonitorCubit build() => EmailMonitorCubit(
        loadCredentials: mockLoad,
        watchNewEmails: mockWatch,
      );

  test('initial state is EmailMonitorInitial', () {
    expect(build().state, const EmailMonitorInitial());
  });

  blocTest<EmailMonitorCubit, EmailMonitorState>(
    'emits [Connecting, CredentialsMissing] when no credentials stored',
    build: () {
      when(() => mockLoad()).thenAnswer((_) async => null);
      return build();
    },
    act: (c) => c.start(),
    expect: () => [
      const EmailMonitorConnecting(),
      const EmailMonitorCredentialsMissing(),
    ],
  );

  blocTest<EmailMonitorCubit, EmailMonitorState>(
    'emits [Connecting, Listening, NewEmail] when email arrives',
    build: () {
      when(() => mockLoad()).thenAnswer((_) async => tCredentials);
      when(() => mockWatch(any()))
          .thenAnswer((_) => Stream.fromIterable([tEmail]));
      return build();
    },
    act: (c) => c.start(),
    expect: () => [
      const EmailMonitorConnecting(),
      const EmailMonitorListening(),
      EmailMonitorNewEmail(tEmail),
    ],
  );

  blocTest<EmailMonitorCubit, EmailMonitorState>(
    'emits [Connecting, Listening, Error] when stream errors',
    build: () {
      when(() => mockLoad()).thenAnswer((_) async => tCredentials);
      when(() => mockWatch(any()))
          .thenAnswer((_) => Stream.error(Exception('IMAP down')));
      return build();
    },
    act: (c) => c.start(),
    expect: () => [
      const EmailMonitorConnecting(),
      const EmailMonitorListening(),
      isA<EmailMonitorError>(),
    ],
  );

  blocTest<EmailMonitorCubit, EmailMonitorState>(
    'emits [Connecting, Error] when loadCredentials throws',
    build: () {
      when(() => mockLoad()).thenThrow(Exception('keychain error'));
      return build();
    },
    act: (c) => c.start(),
    expect: () => [
      const EmailMonitorConnecting(),
      isA<EmailMonitorError>(),
    ],
  );

  blocTest<EmailMonitorCubit, EmailMonitorState>(
    'restart cancels previous subscription and starts fresh',
    build: () {
      when(() => mockLoad()).thenAnswer((_) async => null);
      return build();
    },
    act: (c) async {
      await c.start();
      await c.restart();
    },
    expect: () => [
      const EmailMonitorConnecting(),
      const EmailMonitorCredentialsMissing(),
      const EmailMonitorConnecting(),
      const EmailMonitorCredentialsMissing(),
    ],
  );
}
