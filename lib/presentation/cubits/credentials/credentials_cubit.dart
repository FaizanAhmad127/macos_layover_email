import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/credentials.dart';
import '../../../domain/usecases/clear_credentials.dart';
import '../../../domain/usecases/load_credentials.dart';
import '../../../domain/usecases/save_credentials.dart';
import 'credentials_state.dart';

class CredentialsCubit extends Cubit<CredentialsState> {
  CredentialsCubit({
    required this._loadCredentials,
    required this._saveCredentials,
    required this._clearCredentials,
  }) : super(const CredentialsInitial());

  final LoadCredentials _loadCredentials;
  final SaveCredentials _saveCredentials;
  final ClearCredentials _clearCredentials;

  Future<void> load() async {
    try {
      final credentials = await _loadCredentials();
      emit(credentials != null
          ? CredentialsLoaded(credentials)
          : const CredentialsMissing());
    } catch (e) {
      emit(CredentialsError(e.toString()));
    }
  }

  Future<void> save(String email, String password) async {
    try {
      await _saveCredentials(Credentials(email: email, password: password));
      emit(const CredentialsSaved());
    } catch (e) {
      emit(CredentialsError(e.toString()));
    }
  }

  Future<void> clear() async {
    try {
      await _clearCredentials();
      emit(const CredentialsCleared());
    } catch (e) {
      emit(CredentialsError(e.toString()));
    }
  }
}
