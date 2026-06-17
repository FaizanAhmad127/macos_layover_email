import 'dart:async';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'banner_controller.dart';

/// A transparent banner (email icon + sender + subject + close button) that
/// travels left→right across the screen and parks at the right edge. It stays
/// until the user dismisses it with the close button — there is no auto-hide.
class EmailBanner extends StatefulWidget {
  const EmailBanner({super.key, required this.controller});

  final BannerController controller;

  @override
  State<EmailBanner> createState() => _EmailBannerState();
}

class _EmailBannerState extends State<EmailBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _travelController;
  late final Animation<double> _travelX; // -1 (left) → 1 (right)

  StreamSubscription<({String subject, String from})>? _sub;
  String _subject = '';
  String _from = '';
  bool _visible = false;

  // Text shadows give legibility over any desktop background (no banner box).
  static const _shadows = [
    Shadow(blurRadius: 6, color: Colors.black, offset: Offset(0, 1)),
    Shadow(blurRadius: 12, color: Colors.black54),
  ];

  @override
  void initState() {
    super.initState();

    // Travel across the full screen width — slow, leisurely glide.
    _travelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );
    _travelX = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(parent: _travelController, curve: Curves.easeInOut),
    );

    _sub = widget.controller.stream.listen(_onNewEmail);
  }

  Future<void> _onNewEmail(({String subject, String from}) email) async {
    setState(() {
      _subject = email.subject;
      _from = email.from;
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
            const Icon(
              Icons.email,
              color: Colors.white,
              size: 34,
              shadows: _shadows,
            ),
            const SizedBox(width: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
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
