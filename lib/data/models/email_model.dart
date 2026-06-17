import 'package:enough_mail/enough_mail.dart';

import '../../domain/entities/email.dart';

class EmailModel extends Email {
  const EmailModel({
    required super.subject,
    required super.from,
    required super.receivedAt,
  });

  factory EmailModel.fromMimeMessage(MimeMessage message) {
    return EmailModel(
      subject: message.decodeSubject() ?? '(no subject)',
      from: message.fromEmail ?? '',
      receivedAt: message.decodeDate() ?? DateTime.now(),
    );
  }
}
