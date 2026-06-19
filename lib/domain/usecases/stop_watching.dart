import '../repositories/email_repository.dart';

/// Stops the IMAP watch and closes the underlying connection.
class StopWatching {
  const StopWatching(this._repository);

  final EmailRepository _repository;

  Future<void> call() => _repository.stopWatching();
}
