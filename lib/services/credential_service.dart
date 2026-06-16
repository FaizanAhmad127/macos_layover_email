import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Credentials {
  final String email;
  final String password;
  const Credentials(this.email, this.password);
}

class CredentialService {
  static const _storage = FlutterSecureStorage(
    mOptions: MacOsOptions(accountName: 'macos_layover_email'),
  );
  static const _keyEmail = 'imap_email';
  static const _keyPassword = 'imap_password';

  static Future<Credentials?> load() async {
    final email = await _storage.read(key: _keyEmail);
    final password = await _storage.read(key: _keyPassword);
    if (email == null || password == null) return null;
    return Credentials(email, password);
  }

  static Future<void> save(String email, String password) async {
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyPassword, value: password);
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
