import 'package:equatable/equatable.dart';

import '../../../domain/entities/email.dart';

sealed class EmailMonitorState extends Equatable {
  const EmailMonitorState();

  @override
  List<Object> get props => [];
}

final class EmailMonitorInitial extends EmailMonitorState {
  const EmailMonitorInitial();
}

final class EmailMonitorConnecting extends EmailMonitorState {
  const EmailMonitorConnecting();
}

final class EmailMonitorListening extends EmailMonitorState {
  const EmailMonitorListening();
}

final class EmailMonitorNewEmail extends EmailMonitorState {
  const EmailMonitorNewEmail(this.email);

  final Email email;

  @override
  List<Object> get props => [email];
}

final class EmailMonitorCredentialsMissing extends EmailMonitorState {
  const EmailMonitorCredentialsMissing();
}

final class EmailMonitorError extends EmailMonitorState {
  const EmailMonitorError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
