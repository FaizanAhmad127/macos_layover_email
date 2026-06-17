import 'package:equatable/equatable.dart';

class Email extends Equatable {
  const Email({
    required this.subject,
    required this.from,
    required this.receivedAt,
  });

  final String subject;
  final String from;
  final DateTime receivedAt;

  @override
  List<Object> get props => [subject, from, receivedAt];
}
