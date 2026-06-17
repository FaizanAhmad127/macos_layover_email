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
