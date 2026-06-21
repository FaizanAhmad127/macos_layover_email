import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/imap_error.dart';
import '../../../domain/entities/credentials.dart';
import '../../../domain/usecases/stop_watching.dart';
import '../../../domain/usecases/verify_credentials.dart';
import '../../../domain/usecases/watch_new_emails.dart';
import 'email_monitor_state.dart';

class EmailMonitorCubit extends Cubit<EmailMonitorState> {
  EmailMonitorCubit({
    required WatchNewEmails watchNewEmails,
    required VerifyCredentials verifyCredentials,
    required StopWatching stopWatching,
  })  : _watchNewEmails = watchNewEmails,
        _verifyCredentials = verifyCredentials,
        _stopWatching = stopWatching,
        super(const EmailMonitorInitial());

  final WatchNewEmails _watchNewEmails;
  final VerifyCredentials _verifyCredentials;
  final StopWatching _stopWatching;
  StreamSubscription? _subscription;

  // Called on app startup — no saved credentials, always prompt.
  Future<void> start() async {
    emit(const EmailMonitorCredentialsMissing());
  }

  // Verify credentials against IMAP then start monitoring in-memory (no Keychain).
  Future<void> verifyAndStart(String email, String password) async {
    emit(const EmailMonitorVerifying());
    try {
      final credentials = Credentials(email: email, password: password);
      await _verifyCredentials(credentials);
      emit(const EmailMonitorListening());
      _subscription = _watchNewEmails(credentials).listen(
        (newEmail) => emit(EmailMonitorNewEmail(newEmail)),
        onError: (Object e) => emit(EmailMonitorError(e.toString())),
      );
    } catch (e) {
      debugPrint('[EmailMonitorCubit] verifyAndStart failed: $e');
      emit(EmailMonitorError(_friendlyError(e.toString())));
    }
  }

  // Cancel the Dart subscription AND close the IMAP connection — cancelling the
  // subscription alone leaves the MailClient polling in the background.
  Future<void> _teardown() async {
    await _subscription?.cancel();
    _subscription = null;
    await _stopWatching();
  }

  String _friendlyError(String raw) =>
      isAuthFailure(raw) ? AppStrings.wrongCredentials : AppStrings.connectionFailed;

  @override
  Future<void> close() async {
    await _teardown();
    return super.close();
  }
}
