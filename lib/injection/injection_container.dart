import 'package:get_it/get_it.dart';

import '../data/datasources/imap_data_source.dart';
import '../data/repositories/email_repository_impl.dart';
import '../domain/repositories/email_repository.dart';
import '../domain/usecases/stop_watching.dart';
import '../domain/usecases/verify_credentials.dart';
import '../domain/usecases/watch_new_emails.dart';
import '../presentation/cubits/email_monitor/email_monitor_cubit.dart';

final sl = GetIt.instance;

void initDependencies() {
  // Presentation
  sl.registerFactory(() => EmailMonitorCubit(
        watchNewEmails: sl(),
        verifyCredentials: sl(),
        stopWatching: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => WatchNewEmails(sl()));
  sl.registerLazySingleton(() => VerifyCredentials(sl()));
  sl.registerLazySingleton(() => StopWatching(sl()));

  // Repositories
  sl.registerLazySingleton<EmailRepository>(() => EmailRepositoryImpl(sl()));

  // Data sources
  sl.registerLazySingleton<ImapDataSource>(() => ImapDataSourceImpl());
}
