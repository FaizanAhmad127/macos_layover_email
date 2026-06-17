import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  // Background overlay agent: the app hides its only window when idle (banner
  // mode) and after saving credentials. It must NOT quit when that window
  // closes/hides — otherwise the agent dies the moment the banner is dismissed.
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
