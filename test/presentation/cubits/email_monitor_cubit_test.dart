import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:macos_layover_email/domain/entities/credentials.dart';
import 'package:macos_layover_email/domain/entities/email.dart';
import 'package:macos_layover_email/domain/usecases/stop_watching.dart';
import 'package:macos_layover_email/domain/usecases/verify_credentials.dart';
import 'package:macos_layover_email/domain/usecases/watch_new_emails.dart';
import 'package:macos_layover_email/presentation/cubits/email_monitor/email_monitor_cubit.dart';
import 'package:macos_layover_email/presentation/cubits/email_monitor/email_monitor_state.dart';

class MockWatchNewEmails extends Mock implements WatchNewEmails {}

class MockVerifyCredentials extends Mock implements VerifyCredentials {}

class MockStopWatching extends Mock implements StopWatching {}

void main() {
  late MockWatchNewEmails mockWatch;
  late MockVerifyCredentials mockVerify;
  late MockStopWatching mockStop;

  const tCredentials = Credentials(email: 'test@gmail.com', password: 'pass');
  final tEmail = Email(
    subject: 'Hello',
    senderName: 'Sender',
    from: 'sender@example.com',
    body: 'Body text',
    receivedAt: DateTime(2026, 6, 17),
  );

  setUpAll(() {
    registerFallbackValue(tCredentials);
  });

  setUp(() {
    mockWatch = MockWatchNewEmails();
    mockVerify = MockVerifyCredentials();
    mockStop = MockStopWatching();
    when(() => mockStop()).thenAnswer((_) async {});
  });

  EmailMonitorCubit build() => EmailMonitorCubit(
        watchNewEmails: mockWatch,
        verifyCredentials: mockVerify,
        stopWatching: mockStop,
      );

  test('initial state is EmailMonitorInitial', () {
    expect(build().state, const EmailMonitorInitial());
  });

  blocTest<EmailMonitorCubit, EmailMonitorState>(
    'start() emits [CredentialsMissing] — no keychain load',
    build: () => build(),
    act: (c) => c.start(),
    expect: () => [const EmailMonitorCredentialsMissing()],
  );

  blocTest<EmailMonitorCubit, EmailMonitorState>(
    'verifyAndStart emits [Verifying, Listening, NewEmail] on success',
    build: () {
      when(() => mockVerify(any())).thenAnswer((_) async {});
      when(() => mockWatch(any()))
          .thenAnswer((_) => Stream.fromIterable([tEmail]));
      return build();
    },
    act: (c) => c.verifyAndStart('test@gmail.com', 'pass'),
    expect: () => [
      const EmailMonitorVerifying(),
      const EmailMonitorListening(),
      EmailMonitorNewEmail(tEmail),
    ],
  );

  blocTest<EmailMonitorCubit, EmailMonitorState>(
    'verifyAndStart emits [Verifying, Listening, Error] when stream errors',
    build: () {
      when(() => mockVerify(any())).thenAnswer((_) async {});
      when(() => mockWatch(any()))
          .thenAnswer((_) => Stream.error(Exception('IMAP down')));
      return build();
    },
    act: (c) => c.verifyAndStart('test@gmail.com', 'pass'),
    expect: () => [
      const EmailMonitorVerifying(),
      const EmailMonitorListening(),
      isA<EmailMonitorError>(),
    ],
  );

  blocTest<EmailMonitorCubit, EmailMonitorState>(
    'verifyAndStart emits [Verifying, Error] when verify fails',
    build: () {
      when(() => mockVerify(any()))
          .thenThrow(Exception('Invalid credentials'));
      return build();
    },
    act: (c) => c.verifyAndStart('test@gmail.com', 'wrongpass'),
    expect: () => [
      const EmailMonitorVerifying(),
      isA<EmailMonitorError>(),
    ],
  );

  blocTest<EmailMonitorCubit, EmailMonitorState>(
    'verifyAndStart error message is friendly on auth failure',
    build: () {
      when(() => mockVerify(any()))
          .thenThrow(Exception('[AUTHENTICATIONFAILED] Invalid credentials'));
      return build();
    },
    act: (c) => c.verifyAndStart('test@gmail.com', 'wrongpass'),
    expect: () => [
      const EmailMonitorVerifying(),
      isA<EmailMonitorError>().having(
        (s) => s.message,
        'message',
        contains('App Password'),
      ),
    ],
  );

  test('close() tears down the IMAP connection (no MailClient leak)', () async {
    when(() => mockVerify(any())).thenAnswer((_) async {});
    when(() => mockWatch(any())).thenAnswer((_) => const Stream.empty());
    final cubit = build();
    await cubit.verifyAndStart('test@gmail.com', 'pass');
    await cubit.close();
    verify(() => mockStop()).called(greaterThanOrEqualTo(1));
  });
}
