import Cocoa
import FlutterMacOS
import window_manager

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Show on every Space and over full-screen apps, not just the current one.
    self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
    applyTransparency()

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

  // Make the window AND the Flutter view's backing layer non-opaque so only the
  // banner content paints — no black/opaque window background. Re-applied on
  // every `order` (i.e. each show) because window_manager / the engine can reset
  // the layer to opaque after our initial setup in awakeFromNib.
  private func applyTransparency() {
    self.isOpaque = false
    self.backgroundColor = .clear
    self.hasShadow = false
    if let view = self.contentViewController?.view {
      view.wantsLayer = true
      view.layer?.isOpaque = false
      view.layer?.backgroundColor = NSColor.clear.cgColor
    }
  }

  // Allow the (title-bar-less) window to receive keyboard focus, so the Settings
  // text fields remain editable.
  override var canBecomeKey: Bool { return true }
  override var canBecomeMain: Bool { return true }

  override public func order(_ place: NSWindow.OrderingMode, relativeTo otherWin: Int) {
    super.order(place, relativeTo: otherWin)
    applyTransparency()
    hiddenWindowAtLaunch()
  }
}
