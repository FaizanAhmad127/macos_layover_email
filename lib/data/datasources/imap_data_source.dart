import 'dart:async';

import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/foundation.dart';

import '../../core/errors/failures.dart';
import '../models/email_model.dart';

abstract class ImapDataSource {
  Stream<EmailModel> watchNewEmails(String email, String password);
  Future<void> stopWatching();
  Future<void> verifyCredentials(String email, String password);
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
    MailClient? client;
    try {
      final account = MailAccount.fromManualSettings(
        name: 'Gmail',
        email: email,
        password: password,
        incomingHost: 'imap.gmail.com',
        outgoingHost: 'smtp.gmail.com',
      );

      client = MailClient(account, isLogEnabled: false);
      _mailClient = client;

      _mailClient!.eventBus.on<MailLoadEvent>().listen((event) async {
        var message = event.message;
        // IDLE events arrive headers-only; fetch the full message so the body
        // text part is available. Fall back to the headers-only message if the
        // fetch fails so the banner still fires with subject/sender.
        try {
          message = await _mailClient!.fetchMessageContents(message);
        } catch (_) {}
        _controller?.add(EmailModel.fromMimeMessage(message));
      });

      await _mailClient!.connect();
      // Must select a mailbox before IDLE/polling — otherwise enough_mail
      // throws `idleStart(): no mailbox selected` and no new-mail events fire.
      await _mailClient!.selectInbox();
      // Uses IMAP IDLE when supported (Gmail does); polls every minute otherwise.
      await _mailClient!.startPolling(const Duration(minutes: 1));
    } catch (e) {
      debugPrint('ImapDataSource: connection error — $e');
      // Explicitly disconnect the failed client to close the socket cleanly and
      // prevent SIGURG from a dangling SSL socket on macOS (exit code 144).
      try {
        await client?.disconnect();
      } catch (_) {}
      _mailClient = null;
      _controller?.addError(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<void> verifyCredentials(String email, String password) async {
    final account = MailAccount.fromManualSettings(
      name: 'Gmail',
      email: email,
      password: password,
      incomingHost: 'imap.gmail.com',
      outgoingHost: 'smtp.gmail.com',
    );
    final client = MailClient(account, isLogEnabled: false);
    try {
      await client.connect();
      await client.selectInbox();
    } finally {
      await client.disconnect();
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
