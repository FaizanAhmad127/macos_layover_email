import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:macos_layover_email/domain/entities/credentials.dart';
import 'package:macos_layover_email/domain/usecases/clear_credentials.dart';
import 'package:macos_layover_email/domain/usecases/load_credentials.dart';
import 'package:macos_layover_email/domain/usecases/save_credentials.dart';
import 'package:macos_layover_email/presentation/cubits/credentials/credentials_cubit.dart';
import 'package:macos_layover_email/presentation/cubits/credentials/credentials_state.dart';
import 'package:macos_layover_email/presentation/screens/settings_screen.dart';

class MockLoadCredentials extends Mock implements LoadCredentials {}

class MockSaveCredentials extends Mock implements SaveCredentials {}

class MockClearCredentials extends Mock implements ClearCredentials {}

class MockCredentialsCubit extends MockCubit<CredentialsState>
    implements CredentialsCubit {}

void main() {
  late MockCredentialsCubit mockCubit;

  const tCredentials = Credentials(email: 'test@gmail.com', password: 'pass');

  setUp(() {
    mockCubit = MockCredentialsCubit();
    when(() => mockCubit.state).thenReturn(const CredentialsInitial());
  });

  Widget buildSubject({String? initialEmail, String? errorMessage}) {
    return MaterialApp(
      home: BlocProvider<CredentialsCubit>.value(
        value: mockCubit,
        child: Scaffold(
          body: SettingsScreen(
            initialEmail: initialEmail,
            errorMessage: errorMessage,
          ),
        ),
      ),
    );
  }

  testWidgets('renders email and password fields', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Gmail Settings'), findsOneWidget);
    expect(find.text('Gmail address'), findsOneWidget);
    expect(find.text('App password'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
  });

  testWidgets('pre-populates email field when initialEmail is provided',
      (tester) async {
    await tester.pumpWidget(buildSubject(initialEmail: 'test@gmail.com'));

    final emailField = find.widgetWithText(TextField, 'test@gmail.com');
    expect(emailField, findsOneWidget);
  });

  testWidgets('shows validation error when saving with empty fields',
      (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Email and app password are required.'), findsOneWidget);
  });

  testWidgets('calls cubit.save with entered email and password',
      (tester) async {
    when(() => mockCubit.save(any(), any())).thenAnswer((_) async {});
    await tester.pumpWidget(buildSubject());

    await tester.enterText(
        find.widgetWithText(TextField, 'you@gmail.com'), 'me@gmail.com');
    await tester.enterText(
        find.widgetWithText(TextField, '16-character app password'), 'mypass');
    await tester.tap(find.text('Save'));
    await tester.pump();

    verify(() => mockCubit.save('me@gmail.com', 'mypass')).called(1);
  });

  testWidgets('calls cubit.clear when Clear button tapped', (tester) async {
    when(() => mockCubit.clear()).thenAnswer((_) async {});
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.text('Clear'));
    await tester.pump();

    verify(() => mockCubit.clear()).called(1);
  });

  testWidgets('shows success message on CredentialsSaved state', (tester) async {
    whenListen(
      mockCubit,
      Stream.fromIterable([const CredentialsSaved()]),
      initialState: const CredentialsInitial(),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Saved — connecting to Gmail…'), findsOneWidget);
  });

  testWidgets('shows error message on CredentialsError state', (tester) async {
    whenListen(
      mockCubit,
      Stream.fromIterable([const CredentialsError('Keychain denied')]),
      initialState: const CredentialsInitial(),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Keychain denied'), findsOneWidget);
  });

  testWidgets('displays errorMessage as an error when provided',
      (tester) async {
    await tester.pumpWidget(buildSubject(
      errorMessage: 'Gmail rejected these credentials.',
    ));

    expect(find.text('Gmail rejected these credentials.'), findsOneWidget);
  });

  testWidgets('clears fields on CredentialsCleared state', (tester) async {
    whenListen(
      mockCubit,
      Stream.fromIterable([const CredentialsCleared()]),
      initialState: const CredentialsInitial(),
    );

    await tester.pumpWidget(buildSubject(initialEmail: tCredentials.email));
    await tester.pump();

    expect(find.text('Credentials cleared.'), findsOneWidget);
  });
}
