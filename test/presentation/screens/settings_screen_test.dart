import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:macos_layover_email/domain/entities/credentials.dart';
import 'package:macos_layover_email/presentation/cubits/email_monitor/email_monitor_cubit.dart';
import 'package:macos_layover_email/presentation/cubits/email_monitor/email_monitor_state.dart';
import 'package:macos_layover_email/presentation/screens/settings_screen.dart';

class MockEmailMonitorCubit extends MockCubit<EmailMonitorState>
    implements EmailMonitorCubit {}

void main() {
  late MockEmailMonitorCubit mockMonitorCubit;

  const tCredentials = Credentials(email: 'test@gmail.com', password: 'pass');

  setUp(() {
    mockMonitorCubit = MockEmailMonitorCubit();
    when(() => mockMonitorCubit.state).thenReturn(const EmailMonitorInitial());
  });

  Widget buildSubject({String? initialEmail, String? errorMessage}) {
    return MaterialApp(
      home: BlocProvider<EmailMonitorCubit>.value(
        value: mockMonitorCubit,
        child: Scaffold(
          body: SettingsScreen(
            initialEmail: initialEmail,
            errorMessage: errorMessage,
          ),
        ),
      ),
    );
  }

  testWidgets('renders email and password fields with Connect button',
      (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Gmail Settings'), findsOneWidget);
    expect(find.text('Gmail address'), findsOneWidget);
    expect(find.text('App password'), findsOneWidget);
    expect(find.text('Connect'), findsOneWidget);
    expect(find.text('Clear'), findsNothing);
    expect(find.text('Start automatically at login (recommended)'),
        findsNothing);
  });

  testWidgets('pre-populates email field when initialEmail is provided',
      (tester) async {
    await tester.pumpWidget(buildSubject(initialEmail: 'test@gmail.com'));

    final emailField = find.widgetWithText(TextField, 'test@gmail.com');
    expect(emailField, findsOneWidget);
  });

  testWidgets('shows validation error when connecting with empty fields',
      (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('Connect'));
    await tester.pump();

    expect(find.text('Email and app password are required.'), findsOneWidget);
  });

  testWidgets(
      'calls emailMonitorCubit.verifyAndStart with entered credentials',
      (tester) async {
    when(() => mockMonitorCubit.verifyAndStart(any(), any()))
        .thenAnswer((_) async {});
    await tester.pumpWidget(buildSubject());

    await tester.enterText(
        find.widgetWithText(TextField, 'you@gmail.com'), 'me@gmail.com');
    await tester.enterText(
        find.widgetWithText(TextField, '16-character app password'), 'mypass');
    await tester.tap(find.text('Connect'));
    await tester.pump();

    verify(() => mockMonitorCubit.verifyAndStart('me@gmail.com', 'mypass'))
        .called(1);
  });

  testWidgets('shows spinner and disables button while verifying',
      (tester) async {
    when(() => mockMonitorCubit.verifyAndStart(any(), any()))
        .thenAnswer((_) async {});
    whenListen(
      mockMonitorCubit,
      Stream.fromIterable([const EmailMonitorVerifying()]),
      initialState: const EmailMonitorInitial(),
    );

    await tester.pumpWidget(buildSubject());
    await tester.enterText(
        find.widgetWithText(TextField, 'you@gmail.com'), 'me@gmail.com');
    await tester.enterText(
        find.widgetWithText(TextField, '16-character app password'), 'mypass');
    await tester.tap(find.text('Connect'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final connectBtn = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(connectBtn.onPressed, isNull);
  });

  testWidgets('shows error when EmailMonitorError arrives during verification',
      (tester) async {
    final ctrl = StreamController<EmailMonitorState>.broadcast();
    whenListen(
      mockMonitorCubit,
      ctrl.stream,
      initialState: const EmailMonitorInitial(),
    );
    when(() => mockMonitorCubit.verifyAndStart(any(), any()))
        .thenAnswer((_) async {
      ctrl.add(const EmailMonitorError('Wrong credentials.'));
    });

    await tester.pumpWidget(buildSubject());
    await tester.enterText(
        find.widgetWithText(TextField, 'you@gmail.com'), 'me@gmail.com');
    await tester.enterText(
        find.widgetWithText(TextField, '16-character app password'), 'mypass');
    await tester.tap(find.text('Connect'));
    await tester.pump();

    expect(find.text('Wrong credentials.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await ctrl.close();
  });

  testWidgets('password field starts obscured with a show toggle',
      (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    expect(find.byIcon(Icons.visibility), findsNothing);

    final field = tester.widget<TextField>(
      find.widgetWithText(TextField, '16-character app password'),
    );
    expect(field.obscureText, isTrue);
  });

  testWidgets('tapping the eye toggle reveals and re-hides the password',
      (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    expect(find.byIcon(Icons.visibility), findsOneWidget);
    var field = tester.widget<TextField>(
      find.widgetWithText(TextField, '16-character app password'),
    );
    expect(field.obscureText, isFalse);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    field = tester.widget<TextField>(
      find.widgetWithText(TextField, '16-character app password'),
    );
    expect(field.obscureText, isTrue);
  });

  testWidgets('email field has no password toggle', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });

  testWidgets('displays errorMessage as an error when provided',
      (tester) async {
    await tester.pumpWidget(buildSubject(
      errorMessage: 'Gmail rejected these credentials.',
    ));

    expect(find.text('Gmail rejected these credentials.'), findsOneWidget);
  });

  testWidgets('clears error message when user edits any field', (tester) async {
    await tester.pumpWidget(buildSubject(
      errorMessage: 'Wrong credentials.',
    ));
    expect(find.text('Wrong credentials.'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextField, 'you@gmail.com'), 'a');
    await tester.pump();

    expect(find.text('Wrong credentials.'), findsNothing);
  });

  // Regression: email field pre-populated when initialEmail provided
  testWidgets('email field shows initialEmail value', (tester) async {
    await tester.pumpWidget(buildSubject(initialEmail: tCredentials.email));

    expect(find.widgetWithText(TextField, tCredentials.email), findsOneWidget);
  });
}
