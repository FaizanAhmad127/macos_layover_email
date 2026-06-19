import Cocoa
import FlutterMacOS

// NSPanel (not NSWindow) is REQUIRED to draw over another app's full-screen
// Space. A plain NSWindow — even accessory app + .canJoinAllSpaces + high level
// + orderFrontRegardless — only shows on its home (desktop) Space; verified via
// logs (behavior=273 policy=1 level=1000, still failed). A non-activating panel
// is what Spotlight/Alfred/menu-bar overlays use to float over full-screen.
class MainFlutterWindow: NSPanel {
  private static let overlayLevel = NSWindow.Level.screenSaver
  private static let overlayBehavior: NSWindow.CollectionBehavior =
    [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]

  // Panels/borderless windows refuse key status by default — but the settings
  // screen needs keyboard input, so force these on.
  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { true }

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    // Transparent Flutter render surface — otherwise the Metal layer draws an
    // opaque black rectangle behind the banner (window .clear isn't enough).
    flutterViewController.backgroundColor = .clear
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()

    self.isOpaque = false
    self.backgroundColor = .clear
    self.hasShadow = false

    // Non-activating panel: shows without stealing activation AND joins the
    // active Space (including another app's full-screen Space).
    self.styleMask.insert(.nonactivatingPanel)
    self.hidesOnDeactivate = false  // keep the banner up while another app is active
    self.level = Self.overlayLevel
    self.collectionBehavior = Self.overlayBehavior

    let channel = FlutterMethodChannel(
      name: "com.faizan.macosLayoverEmail/overlay",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "showOverlay":
        // Re-assert level + Space membership + no-shadow every time — other
        // window calls (resize/hide) can reset them.
        self.level = Self.overlayLevel
        self.collectionBehavior = Self.overlayBehavior
        self.hasShadow = false
        self.setIsVisible(true)
        self.orderFrontRegardless()
        result(nil)
      case "hideOverlay":
        self.orderOut(nil)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
