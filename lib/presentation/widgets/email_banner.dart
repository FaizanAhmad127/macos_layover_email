import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/overlay_window.dart';
import 'banner_controller.dart';

/// A transparent pill banner that travels left→right by moving the window
/// itself. The window is content-sized (440×170), so only the pill area
/// captures mouse events — the rest of the screen is unobstructed. Tap anywhere
/// on the pill to dismiss.
///
/// Layout (top→bottom): "Email received" heading, sender name, sender email,
/// subject, then the message body.
class EmailBanner extends StatefulWidget {
  const EmailBanner({super.key, required this.controller});

  final BannerController controller;

  @override
  State<EmailBanner> createState() => _EmailBannerState();
}

class _EmailBannerState extends State<EmailBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _travelController;

  StreamSubscription<BannerEvent>? _sub;
  String _subject = '';
  String _name = '';
  String _from = '';
  String _body = '';
  bool _visible = false;

  // Pill window size — must match what main.dart sets via setSize().
  static const double _pillWidth = 540;
  static const double _pillHeight = 170;

  // Very light pink panel sits behind the text only (not the parrot).
  // 10% opacity (alpha 0x1A) so the panel is a faint pink wash.
  static const _panelColor = Color(0x1AFFE3E8);

  // Light text + drop shadows so it stays readable over the near-transparent
  // panel on any background (light or dark apps behind it).
  static const _shadows = [
    Shadow(blurRadius: 6, color: Colors.black, offset: Offset(0, 1)),
    Shadow(blurRadius: 12, color: Colors.black54),
  ];
  // Panel fills the pill height minus the outer vertical padding (8 top + 8
  // bottom) so the text column has a bounded height and clips/ellipsizes
  // instead of overflowing.
  static const double _panelHeight = _pillHeight - 16;

  @override
  void initState() {
    super.initState();

    _travelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 20000),
    );
    _travelController.addListener(_onTick);

    _sub = widget.controller.stream.listen(_onNewEmail);
  }

  /// Moves the window across the screen on every animation frame.
  void _onTick() {
    final t = _travelController.value;
    final screenW = widget.controller.screenWidth;
    final screenH = widget.controller.screenHeight;
    final x = -_pillWidth + t * screenW;
    final y = (screenH - _pillHeight) / 2;
    windowManager.setPosition(Offset(x, y));
  }

  Future<void> _onNewEmail(BannerEvent email) async {
    setState(() {
      _subject = email.subject;
      _name = email.name;
      _from = email.from;
      _body = email.body;
      _visible = true;
    });
    await windowManager.setIgnoreMouseEvents(false);
    // Show natively (orderFrontRegardless) so the banner draws over full-screen
    // apps without activating the app / switching Spaces.
    await OverlayWindow.show();
    await windowManager.setBackgroundColor(Colors.transparent);
    _travelController.forward(from: 0);
  }

  Future<void> _dismiss() async {
    setState(() => _visible = false);
    _travelController.reset();
    await OverlayWindow.hide();
    await windowManager.setIgnoreMouseEvents(true);
  }

  @override
  void dispose() {
    _travelController.removeListener(_onTick);
    _travelController.dispose();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _dismiss,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                height: _panelHeight,
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _panelColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black26,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading — beautiful script font (built into macOS).
                    const Text(
                      'Email received',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Snell Roundhand',
                        color: Color(0xFF3DDC6E),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        shadows: _shadows,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        shadows: _shadows,
                      ),
                    ),
                    Text(
                      _from,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFE0E0E0),
                        fontSize: 8,
                        shadows: _shadows,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: _shadows,
                      ),
                    ),
                    if (_body.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Flexible(
                        child: Text(
                          _body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFEDEDED),
                            fontSize: 12,
                            height: 1.25,
                            shadows: _shadows,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(-1, 1, 1),
              child: Lottie.asset(
                'assets/animations/parrot.json',
                width: 144,
                height: 144,
                repeat: true,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
