import 'dart:async';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'banner_controller.dart';

class EmailBanner extends StatefulWidget {
  const EmailBanner({super.key, required this.controller});

  final BannerController controller;

  @override
  State<EmailBanner> createState() => _EmailBannerState();
}

class _EmailBannerState extends State<EmailBanner>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final AnimationController _flagController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _flagAngle;

  StreamSubscription<String>? _sub;
  Timer? _dismissTimer;
  String _subject = '';

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    // Flag waves back and forth continuously
    _flagController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Rotation in radians around the flag's bottom-left (pole base)
    _flagAngle = Tween<double>(begin: -0.18, end: 0.18).animate(
      CurvedAnimation(parent: _flagController, curve: Curves.easeInOut),
    );

    _slideController.addStatusListener(_onSlideStatus);
    _sub = widget.controller.stream.listen(_onNewSubject);
  }

  Future<void> _onNewSubject(String subject) async {
    _dismissTimer?.cancel();
    setState(() => _subject = subject);

    if (_slideController.isDismissed) {
      await windowManager.show();
      _slideController.forward();
    }
    // If banner is already visible, subject updates in place and timer resets
    _dismissTimer = Timer(const Duration(seconds: 5), _dismiss);
  }

  void _dismiss() => _slideController.reverse();

  void _onSlideStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      windowManager.hide();
    }
  }

  @override
  void dispose() {
    _slideController.removeStatusListener(_onSlideStatus);
    _slideController.dispose();
    _flagController.dispose();
    _sub?.cancel();
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        color: const Color(0xEE111111), // ~93% opaque dark background
        child: Row(
          children: [
            const SizedBox(width: 20),
            AnimatedBuilder(
              animation: _flagAngle,
              builder: (_, child) => Transform.rotate(
                angle: _flagAngle.value,
                alignment: Alignment.bottomLeft,
                child: child,
              ),
              child: const Text('🚩', style: TextStyle(fontSize: 30)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                _subject,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
