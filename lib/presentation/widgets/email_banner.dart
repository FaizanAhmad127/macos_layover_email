import 'dart:async';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'banner_controller.dart';

/// A transparent banner (waving 🚩 flag + email subject + close button) that
/// travels left→right across the screen and parks at the right edge. It stays
/// until the user dismisses it with the close button — there is no auto-hide.
class EmailBanner extends StatefulWidget {
  const EmailBanner({super.key, required this.controller});

  final BannerController controller;

  @override
  State<EmailBanner> createState() => _EmailBannerState();
}

class _EmailBannerState extends State<EmailBanner>
    with TickerProviderStateMixin {
  late final AnimationController _travelController;
  late final AnimationController _flagController;
  late final Animation<double> _travelX; // -1 (left) → 1 (right)
  late final Animation<double> _flagAngle;

  StreamSubscription<String>? _sub;
  String _subject = '';
  bool _visible = false;

  // Text shadows give legibility over any desktop background (no banner box).
  static const _shadows = [
    Shadow(blurRadius: 6, color: Colors.black, offset: Offset(0, 1)),
    Shadow(blurRadius: 12, color: Colors.black54),
  ];

  @override
  void initState() {
    super.initState();

    // Travel across the full screen width (slow, leisurely glide).
    _travelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    );
    // Flag waves back and forth continuously.
    _flagController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _travelX = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(parent: _travelController, curve: Curves.easeInOut),
    );
    _flagAngle = Tween<double>(begin: -0.18, end: 0.18).animate(
      CurvedAnimation(parent: _flagController, curve: Curves.easeInOut),
    );

    _sub = widget.controller.stream.listen(_onNewSubject);
  }

  Future<void> _onNewSubject(String subject) async {
    setState(() {
      _subject = subject;
      _visible = true;
    });
    // Make the window interactive so the close button is clickable.
    await windowManager.setIgnoreMouseEvents(false);
    await windowManager.show();
    _travelController.forward(from: 0); // restart the travel for each new mail
  }

  Future<void> _dismiss() async {
    setState(() => _visible = false);
    _travelController.reset();
    await windowManager.hide();
    await windowManager.setIgnoreMouseEvents(true);
  }

  @override
  void dispose() {
    _travelController.dispose();
    _flagController.dispose();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _travelX,
      builder: (context, child) {
        return Align(
          alignment: Alignment(_travelX.value, 0),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _flagAngle,
              builder: (_, child) => Transform.rotate(
                angle: _flagAngle.value,
                alignment: Alignment.bottomLeft,
                child: child,
              ),
              child: const Text('🚩', style: TextStyle(fontSize: 34)),
            ),
            const SizedBox(width: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Text(
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
            ),
            const SizedBox(width: 10),
            // Close / cancel button — the only way to remove the banner.
            IconButton(
              onPressed: _dismiss,
              tooltip: 'Dismiss',
              splashRadius: 18,
              icon: const Icon(
                Icons.cancel,
                color: Colors.white,
                size: 24,
                shadows: _shadows,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
