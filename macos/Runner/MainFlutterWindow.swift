import Cocoa
import FlutterMacOS
import window_manager

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Transparent overlay window: the banner shows only the icon + text, with no
    // window background/chrome. Needs a non-opaque window AND a non-opaque
    // Flutter view layer — otherwise the view paints an opaque (black) backing.
    self.isOpaque = false
    self.backgroundColor = .clear
    self.hasShadow = false
    let flutterView = flutterViewController.view
    flutterView.wantsLayer = true
    flutterView.layer?.isOpaque = false
    flutterView.layer?.backgroundColor = NSColor.clear.cgColor

    // Show on every Space and over full-screen apps, not just the current one.
    self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

  // Allow the (title-bar-less) window to receive keyboard focus, so the Settings
  // text fields remain editable.
  override var canBecomeKey: Bool { return true }
  override var canBecomeMain: Bool { return true }

  override public func order(_ place: NSWindow.OrderingMode, relativeTo otherWin: Int) {
    super.order(place, relativeTo: otherWin)
    hiddenWindowAtLaunch()
  }
}
