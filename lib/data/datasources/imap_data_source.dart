import 'dart:async';

import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/foundation.dart';

import '../../core/errors/failures.dart';
import '../models/email_model.dart';

abstract class ImapDataSource {
  Stream<EmailModel> watchNewEmails(String email, String password);
  Future<void> stopWatching();
}

class ImapDataSourceImpl implements ImapDataSource {
  MailClient? _mailClient;
  StreamController<EmailModel>? _controller;

  @override
  Stream<EmailModel> watchNewEmails(String email, String password) {
    _controller = StreamController<EmailModel>.broadcast();
    _connect(email, password);
    return _controller!.stream;
  }

  Future<void> _connect(String email, String password) async {
    try {
      final account = MailAccount.fromManualSettings(
        name: 'Gmail',
        email: email,
        password: password,
        incomingHost: 'imap.gmail.com',
        outgoingHost: 'smtp.gmail.com',
      );

      _mailClient = MailClient(account, isLogEnabled: false);

      _mailClient!.eventBus.on<MailLoadEvent>().listen((event) {
        _controller?.add(EmailModel.fromMimeMessage(event.message));
      });

      await _mailClient!.connect();
      // Uses IMAP IDLE when supported (Gmail does); polls every minute otherwise.
      await _mailClient!.startPolling(const Duration(minutes: 1));
    } catch (e) {
      debugPrint('ImapDataSource: connection error — $e');
      _controller?.addError(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<void> stopWatching() async {
    await _mailClient?.stopPolling();
    await _mailClient?.disconnect();
    _mailClient = null;
    await _controller?.close();
    _controller = null;
  }
}
