import 'package:equatable/equatable.dart';

class Credentials extends Equatable {
  const Credentials({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}
