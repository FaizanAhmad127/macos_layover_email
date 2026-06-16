import 'dart:async';
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/foundation.dart';

class ImapService {
  MailClient? _mailClient;
  final _controller = StreamController<String>.broadcast();

  Stream<String> get onNewEmail => _controller.stream;

  Future<void> start(String email, String password) async {
    final account = MailAccount.fromManualSettings(
      name: 'Gmail',
      email: email,
      password: password,
      incomingHost: 'imap.gmail.com',
      outgoingHost: 'smtp.gmail.com',
    );

    _mailClient = MailClient(account, isLogEnabled: false);

    _mailClient!.eventBus.on<MailLoadEvent>().listen((event) {
      final subject = event.message.decodeSubject() ?? '(no subject)';
      debugPrint('ImapService: new email — $subject');
      _controller.add(subject);
    });

    await _mailClient!.connect();

    // startPolling uses IMAP IDLE when the server supports it (Gmail does).
    // Falls back to polling every minute if IDLE is unavailable.
    await _mailClient!.startPolling(const Duration(minutes: 1));
  }

  Future<void> stop() async {
    await _mailClient?.stopPolling();
    await _mailClient?.disconnect();
    _mailClient = null;
  }

  void dispose() {
    stop();
    _controller.close();
  }
}
