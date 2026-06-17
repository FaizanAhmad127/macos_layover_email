import 'package:equatable/equatable.dart';

import '../../../domain/entities/credentials.dart';

sealed class CredentialsState extends Equatable {
  const CredentialsState();

  @override
  List<Object> get props => [];
}

final class CredentialsInitial extends CredentialsState {
  const CredentialsInitial();
}

final class CredentialsLoaded extends CredentialsState {
  const CredentialsLoaded(this.credentials);

  final Credentials credentials;

  @override
  List<Object> get props => [credentials];
}

final class CredentialsMissing extends CredentialsState {
  const CredentialsMissing();
}

final class CredentialsSaved extends CredentialsState {
  const CredentialsSaved();
}

final class CredentialsCleared extends CredentialsState {
  const CredentialsCleared();
}

final class CredentialsError extends CredentialsState {
  const CredentialsError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
