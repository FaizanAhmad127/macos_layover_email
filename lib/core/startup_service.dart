import 'package:launch_at_startup/launch_at_startup.dart';

/// Controls whether the app launches automatically at macOS login.
/// Abstracted so the UI can be unit-tested without the platform channel.
abstract class StartupService {
  Future<bool> isEnabled();
  Future<void> enable();
  Future<void> disable();
}

class LaunchAtStartupService implements StartupService {
  @override
  Future<bool> isEnabled() => launchAtStartup.isEnabled();

  @override
  Future<void> enable() => launchAtStartup.enable();

  @override
  Future<void> disable() => launchAtStartup.disable();
}
