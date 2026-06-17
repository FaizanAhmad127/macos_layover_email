import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class CredentialDataSource {
  Future<Map<String, String>?> loadCredentials();
  Future<void> saveCredentials(String email, String password);
  Future<void> clearCredentials();
}

class CredentialDataSourceImpl implements CredentialDataSource {
  static const _storage = FlutterSecureStorage(
    mOptions: MacOsOptions(accountName: 'macos_layover_email'),
  );
  static const _keyEmail = 'imap_email';
  static const _keyPassword = 'imap_password';

  @override
  Future<Map<String, String>?> loadCredentials() async {
    final email = await _storage.read(key: _keyEmail);
    final password = await _storage.read(key: _keyPassword);
    if (email == null || password == null) return null;
    return {'email': email, 'password': password};
  }

  @override
  Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyPassword, value: password);
  }

  @override
  Future<void> clearCredentials() => _storage.deleteAll();
}
