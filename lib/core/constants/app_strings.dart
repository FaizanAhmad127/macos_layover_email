/// User-facing text for the app, in one place. Not instantiable.
abstract final class AppStrings {
  // ── Banner ──
  static const String bannerHeading = 'Email received';

  // ── Settings ──
  static const String settingsTitle = 'Gmail Settings';
  static const String gmailAddressLabel = 'Gmail address';
  static const String gmailAddressHint = 'you@gmail.com';
  static const String appPasswordLabel = 'App password';
  static const String appPasswordHint = '16-character app password';
  static const String connect = 'Connect';
  static const String quitTooltip = 'Quit app';
  static const String showPassword = 'Show password';
  static const String hidePassword = 'Hide password';
  static const String emptyFieldsError = 'Email and app password are required.';

  // ── Friendly IMAP errors ──
  static const String wrongCredentials =
      'Wrong credentials. Enter your Gmail address and a 16-character App '
      'Password — not your regular Gmail password. You can create one at '
      'myaccount.google.com → Security → App Passwords.';

  /// Shown by the cubit during verify (settings screen is open).
  static const String connectionFailed =
      'Could not connect to Gmail. Check your internet connection and '
      'credentials, then try again.';

  /// Shown by main.dart for background errors (banner mode → reopen settings).
  static const String connectionFailedReconnect =
      'Could not connect to Gmail. Check your internet connection and '
      'credentials, then tap Connect to reconnect.';

  static const String credentialAccessFailed =
      "Couldn't access saved credentials. Please enter them again to reconnect.";
}
