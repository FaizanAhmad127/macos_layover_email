/// Classifies IMAP error messages.
///
/// Returns `true` when the message indicates the server rejected the
/// credentials (e.g. Gmail's `[AUTHENTICATIONFAILED] Invalid credentials`),
/// as opposed to a transient network/connection failure. Used to decide
/// whether to reopen the Settings window so the user can correct them.
bool isAuthFailure(String message) {
  final m = message.toLowerCase();
  return m.contains('authenticationfailed') || m.contains('invalid credentials');
}

/// Returns `true` when the error means the stored credentials can't be
/// read/used and the user should re-enter them — i.e. Gmail rejected them
/// (auth failure) OR the macOS Keychain refused access. The latter can happen
/// after the app binary is re-signed (e.g. a rebuild), which invalidates the
/// item's access control. Distinguished from transient network errors so the
/// app can reopen Settings instead of silently failing.
bool isCredentialError(String message) {
  final m = message.toLowerCase();
  return isAuthFailure(message) ||
      m.contains('-25308') || // errSecInteractionNotAllowed
      m.contains('-34018') || // errSecMissingEntitlement
      m.contains('interaction is not allowed') ||
      m.contains('keychain') ||
      (m.contains('platformexception') && m.contains('security'));
}
