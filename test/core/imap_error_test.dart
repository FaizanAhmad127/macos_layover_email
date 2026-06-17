import 'package:flutter_test/flutter_test.dart';
import 'package:macos_layover_email/core/imap_error.dart';

void main() {
  group('isAuthFailure', () {
    test('true for Gmail AUTHENTICATIONFAILED message', () {
      expect(
        isAuthFailure(
            'MailException: null:  [AUTHENTICATIONFAILED] Invalid credentials (Failure)'),
        isTrue,
      );
    });

    test('true regardless of case', () {
      expect(isAuthFailure('authenticationfailed'), isTrue);
      expect(isAuthFailure('Invalid Credentials'), isTrue);
    });

    test('true when only "invalid credentials" is present', () {
      expect(isAuthFailure('Login failed: invalid credentials'), isTrue);
    });

    test('false for transient network/connection errors', () {
      expect(isAuthFailure('SocketException: Connection refused'), isFalse);
      expect(isAuthFailure('Connection closed before handshake'), isFalse);
      expect(isAuthFailure('Operation timed out'), isFalse);
    });

    test('false for empty message', () {
      expect(isAuthFailure(''), isFalse);
    });
  });

  group('isCredentialError', () {
    test('true for auth failures (superset of isAuthFailure)', () {
      expect(isCredentialError('[AUTHENTICATIONFAILED] Invalid credentials'),
          isTrue);
    });

    test('true for Keychain -25308 interaction-not-allowed', () {
      expect(
        isCredentialError(
            'PlatformException(Unexpected security result code, Code: -25308, Message: User interaction is not allowed., -25308, null)'),
        isTrue,
      );
    });

    test('true for Keychain -34018 missing-entitlement', () {
      expect(isCredentialError('Code: -34018 entitlement not present'), isTrue);
    });

    test('false for transient network errors', () {
      expect(isCredentialError('SocketException: Connection refused'), isFalse);
      expect(isCredentialError('Operation timed out'), isFalse);
    });
  });
}
