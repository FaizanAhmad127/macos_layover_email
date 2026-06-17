import '../../domain/entities/credentials.dart';

class CredentialsModel extends Credentials {
  const CredentialsModel({required super.email, required super.password});

  factory CredentialsModel.fromMap(Map<String, String> map) {
    return CredentialsModel(email: map['email']!, password: map['password']!);
  }

  Map<String, String> toMap() => {'email': email, 'password': password};
}
