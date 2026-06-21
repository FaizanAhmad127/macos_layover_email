/// Gmail IMAP/SMTP connection settings. Centralized per CLAUDE.md: never
/// hardcode the IMAP host, port, or account values inline. Not instantiable.
abstract final class ImapConfig {
  static const String accountName = 'Gmail';
  static const String incomingHost = 'imap.gmail.com';
  static const String outgoingHost = 'smtp.gmail.com';

  /// IDLE-capable servers (Gmail) use push; this is the fallback poll cadence.
  static const Duration pollInterval = Duration(minutes: 1);
}
