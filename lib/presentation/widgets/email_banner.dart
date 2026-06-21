import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/constants/app_strings.dart';
import '../../core/overlay_window.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text_styles.dart';
import 'banner_controller.dart';

/// A transparent pill banner that travels left→right by moving the window
/// itself. The window is content-sized ([AppDimensions.pillWidth] ×
/// [AppDimensions.pillHeight]), so only the pill area captures mouse events —
/// the rest of the screen is unobstructed. Tap anywhere on the pill to dismiss.
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

  @override
  void initState() {
    super.initState();

    _travelController = AnimationController(
      vsync: this,
      duration: AppDimensions.bannerTravel,
    );
    _travelController.addListener(_onTick);

    _sub = widget.controller.stream.listen(_onNewEmail);
  }

  /// Moves the window across the screen on every animation frame.
  void _onTick() {
    final t = _travelController.value;
    final screenW = widget.controller.screenWidth;
    final screenH = widget.controller.screenHeight;
    final x = -AppDimensions.pillWidth + t * screenW;
    final y = (screenH - AppDimensions.pillHeight) / 2;
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.bannerOuterPaddingH,
          vertical: AppDimensions.bannerOuterPaddingV,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _TextPanel(_name, _from, _subject, _body)),
            const SizedBox(width: AppDimensions.parrotGap),
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(-1, 1, 1),
              child: Lottie.asset(
                'assets/animations/parrot.json',
                width: AppDimensions.parrotSize,
                height: AppDimensions.parrotSize,
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

/// The faint pink panel behind the email text (parrot stays outside it).
class _TextPanel extends StatelessWidget {
  const _TextPanel(this.name, this.from, this.subject, this.body);

  final String name;
  final String from;
  final String subject;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.panelHeight,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.panelPaddingH,
        vertical: AppDimensions.panelPaddingV,
      ),
      decoration: BoxDecoration(
        color: AppColors.bannerPanel,
        borderRadius: BorderRadius.circular(AppDimensions.panelRadius),
        boxShadow: AppShadows.panel,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading — beautiful script font (built into macOS).
          const Text(
            AppStrings.bannerHeading,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bannerHeading,
          ),
          const SizedBox(height: AppDimensions.gapHeadingToName),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bannerName,
          ),
          Text(
            from,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bannerEmail,
          ),
          const SizedBox(height: AppDimensions.gapNameBlockToSubject),
          Text(
            subject,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bannerSubject,
          ),
          if (body.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.gapSubjectToBody),
            Flexible(
              child: Text(
                body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bannerBody,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
