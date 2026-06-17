import 'package:get_it/get_it.dart';

import '../data/datasources/credential_data_source.dart';
import '../data/datasources/imap_data_source.dart';
import '../data/repositories/credential_repository_impl.dart';
import '../data/repositories/email_repository_impl.dart';
import '../domain/repositories/credential_repository.dart';
import '../domain/repositories/email_repository.dart';
import '../domain/usecases/clear_credentials.dart';
import '../domain/usecases/load_credentials.dart';
import '../domain/usecases/save_credentials.dart';
import '../domain/usecases/watch_new_emails.dart';
import '../presentation/cubits/credentials/credentials_cubit.dart';
import '../presentation/cubits/email_monitor/email_monitor_cubit.dart';

final sl = GetIt.instance;

void initDependencies() {
  // Presentation
  sl.registerFactory(() => EmailMonitorCubit(
        loadCredentials: sl(),
        watchNewEmails: sl(),
      ));
  sl.registerFactory(() => CredentialsCubit(
        loadCredentials: sl(),
        saveCredentials: sl(),
        clearCredentials: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => WatchNewEmails(sl()));
  sl.registerLazySingleton(() => LoadCredentials(sl()));
  sl.registerLazySingleton(() => SaveCredentials(sl()));
  sl.registerLazySingleton(() => ClearCredentials(sl()));

  // Repositories
  sl.registerLazySingleton<EmailRepository>(
      () => EmailRepositoryImpl(sl()));
  sl.registerLazySingleton<CredentialRepository>(
      () => CredentialRepositoryImpl(sl()));

  // Data sources
  sl.registerLazySingleton<ImapDataSource>(() => ImapDataSourceImpl());
  sl.registerLazySingleton<CredentialDataSource>(
      () => CredentialDataSourceImpl());
}
