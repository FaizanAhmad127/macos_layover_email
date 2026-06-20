import 'package:enough_mail/enough_mail.dart';

import '../../domain/entities/email.dart';

class EmailModel extends Email {
  const EmailModel({
    required super.subject,
    required super.senderName,
    required super.from,
    required super.body,
    required super.receivedAt,
  });

  factory EmailModel.fromMimeMessage(MimeMessage message) {
    final fromAddress = message.from?.isNotEmpty ?? false
        ? message.from!.first
        : null;
    final email = fromAddress?.email ?? message.fromEmail ?? '';
    // personalName is the display name; fall back to the address when absent.
    final name = (fromAddress?.personalName?.trim().isNotEmpty ?? false)
        ? fromAddress!.personalName!.trim()
        : email;

    return EmailModel(
      subject: message.decodeSubject() ?? '(no subject)',
      senderName: name,
      from: email,
      body: _decodeBody(message),
      receivedAt: message.decodeDate() ?? DateTime.now(),
    );
  }

  /// Plain-text body with whitespace collapsed to single spaces. Returns an
  /// empty string when the body hasn't been fetched or contains no text part.
  static String _decodeBody(MimeMessage message) {
    final text = message.decodeTextPlainPart() ?? '';
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
