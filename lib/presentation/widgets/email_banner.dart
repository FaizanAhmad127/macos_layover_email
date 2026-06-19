import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/overlay_window.dart';
import 'banner_controller.dart';

/// A transparent pill banner (sender + subject + parrot) that travels
/// left→right by moving the window itself. The window is content-sized
/// (420×90), so only the pill area captures mouse events — the rest of the
/// screen is unobstructed. Tap anywhere on the pill to dismiss.
class EmailBanner extends StatefulWidget {
  const EmailBanner({super.key, required this.controller});

  final BannerController controller;

  @override
  State<EmailBanner> createState() => _EmailBannerState();
}

class _EmailBannerState extends State<EmailBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _travelController;

  StreamSubscription<({String subject, String from})>? _sub;
  String _subject = '';
  String _from = '';
  bool _visible = false;

  // Pill window size — must match what main.dart sets via setSize().
  static const double _pillWidth = 420;
  static const double _pillHeight = 90;

  static const _shadows = [
    Shadow(blurRadius: 6, color: Colors.black, offset: Offset(0, 1)),
    Shadow(blurRadius: 12, color: Colors.black54),
  ];

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

  Future<void> _onNewEmail(({String subject, String from}) email) async {
    setState(() {
      _subject = email.subject;
      _from = email.from;
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _from,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFEAEAEA),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      shadows: _shadows,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: _shadows,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(-1, 1, 1),
              child: Lottie.asset(
                'assets/animations/parrot.json',
                width: 72,
                height: 72,
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
