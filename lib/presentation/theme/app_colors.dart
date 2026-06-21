import 'package:flutter/material.dart';

/// Central palette for the app. All UI colors live here so they can be tuned
/// in one place. Not instantiable — `static const` members only.
abstract final class AppColors {
  // ── Banner ──
  /// Faint pink wash behind the banner text (10% opacity).
  static const Color bannerPanel = Color(0x1AFFE3E8);

  /// "Email received" heading.
  static const Color bannerHeading = Color(0xFF3DDC6E);

  /// Sender name + subject.
  static const Color bannerTextPrimary = Colors.white;

  /// Sender email address.
  static const Color bannerEmail = Color(0xFFE0E0E0);

  /// Message body preview.
  static const Color bannerBody = Color(0xFFEDEDED);

  // ── Settings ──
  static const Color settingsBackground = Color(0xFF1E1E1E);
  static const Color fieldLabel = Color(0xFFAAAAAA);
  static const Color fieldText = Colors.white;
  static const Color fieldHint = Color(0xFF555555);
  static const Color fieldFill = Color(0xFF2A2A2A);
  static const Color fieldFocusBorder = Color(0xFF4A90D9);
  static const Color iconMuted = Color(0xFF999999);

  // ── Status messages (Material swatch shades aren't const) ──
  static final Color error = Colors.red.shade300;
  static final Color success = Colors.green.shade300;
}
