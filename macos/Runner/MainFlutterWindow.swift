import Cocoa
import FlutterMacOS
import window_manager

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Transparent overlay window: the banner shows only the flag + text, with no
    // window background/chrome. Requires a non-opaque window with a clear color
    // and a clear backing layer on the Flutter view.
    self.isOpaque = false
    self.backgroundColor = .clear
    self.hasShadow = false
    flutterViewController.view.wantsLayer = true
    flutterViewController.view.layer?.backgroundColor = NSColor.clear.cgColor

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
