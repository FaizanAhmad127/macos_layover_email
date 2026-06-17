import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/load_credentials.dart';
import '../../../domain/usecases/watch_new_emails.dart';
import 'email_monitor_state.dart';

class EmailMonitorCubit extends Cubit<EmailMonitorState> {
  EmailMonitorCubit({
    required this._loadCredentials,
    required this._watchNewEmails,
  }) : super(const EmailMonitorInitial());

  final LoadCredentials _loadCredentials;
  final WatchNewEmails _watchNewEmails;
  StreamSubscription? _subscription;

  Future<void> start() async {
    emit(const EmailMonitorConnecting());
    try {
      final credentials = await _loadCredentials();
      if (credentials == null) {
        emit(const EmailMonitorCredentialsMissing());
        return;
      }
      emit(const EmailMonitorListening());
      _subscription = _watchNewEmails(credentials).listen(
        (email) => emit(EmailMonitorNewEmail(email)),
        onError: (Object e) => emit(EmailMonitorError(e.toString())),
      );
    } catch (e) {
      emit(EmailMonitorError(e.toString()));
    }
  }

  Future<void> restart() async {
    await _subscription?.cancel();
    _subscription = null;
    await start();
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
