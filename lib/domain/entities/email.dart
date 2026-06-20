import 'package:equatable/equatable.dart';

class Email extends Equatable {
  const Email({
    required this.subject,
    required this.senderName,
    required this.from,
    required this.body,
    required this.receivedAt,
  });

  /// Email subject line.
  final String subject;

  /// Sender display name (e.g. "John Smith"); falls back to the address.
  final String senderName;

  /// Sender email address.
  final String from;

  /// Plain-text message body (whitespace-collapsed, may be truncated for display).
  final String body;

  final DateTime receivedAt;

  @override
  List<Object> get props => [subject, senderName, from, body, receivedAt];
}
