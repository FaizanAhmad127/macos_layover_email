import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationWillFinishLaunching(_ notification: Notification) {
    // Background-agent mode (no Dock icon). This is REQUIRED for the banner to
    // appear over other apps' full-screen windows — macOS blocks .regular
    // (Dock-icon) apps from drawing into another app's full-screen Space.
    // Quit is still available via the menu-bar ✉️ icon and the window's ✕.
    NSApp.setActivationPolicy(.accessory)

    // ── DOCK ICON (disabled) ──────────────────────────────────────────────
    // To show a Dock icon again, comment out the .accessory line above and
    // uncomment the line below. NOTE: with .regular, the banner will NOT
    // appear over full-screen apps. Also flip `skipTaskbar` back to false in
    // lib/main.dart.
    // NSApp.setActivationPolicy(.regular)

    super.applicationWillFinishLaunching(notification)
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
