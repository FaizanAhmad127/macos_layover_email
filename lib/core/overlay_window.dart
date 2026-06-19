import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Native bridge for showing/hiding the banner window as a passive overlay.
///
/// Unlike `windowManager.show()` (which activates the app and switches the user
/// out of another app's full-screen Space), the native side uses
/// `orderFrontRegardless()` — drawing the window into the current Space without
/// activating the app, so the banner floats over full-screen apps.
class OverlayWindow {
  static const _channel =
      MethodChannel('com.faizan.macosLayoverEmail/overlay');

  static Future<void> show() => _invoke('showOverlay');
  static Future<void> hide() => _invoke('hideOverlay');

  static Future<void> _invoke(String method) async {
    try {
      await _channel.invokeMethod<void>(method);
    } on MissingPluginException {
      // No native handler (e.g. under flutter test) — safe to ignore.
    } catch (e) {
      debugPrint('[OverlayWindow] $method failed: $e');
    }
  }
}
