import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_shadows.dart';

/// Text styles for the app, composed from [AppColors] and [AppShadows].
/// Not instantiable.
abstract final class AppTextStyles {
  /// Elegant script font built into macOS — no asset bundling required.
  static const String scriptFontFamily = 'Snell Roundhand';

  // ── Banner ──
  static const TextStyle bannerHeading = TextStyle(
    fontFamily: scriptFontFamily,
    color: AppColors.bannerHeading,
    fontSize: 30,
    fontWeight: FontWeight.bold,
    shadows: AppShadows.text,
  );

  static const TextStyle bannerName = TextStyle(
    color: AppColors.bannerTextPrimary,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    shadows: AppShadows.text,
  );

  static const TextStyle bannerEmail = TextStyle(
    color: AppColors.bannerEmail,
    fontSize: 8,
    shadows: AppShadows.text,
  );

  static const TextStyle bannerSubject = TextStyle(
    color: AppColors.bannerTextPrimary,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    shadows: AppShadows.text,
  );

  static const TextStyle bannerBody = TextStyle(
    color: AppColors.bannerBody,
    fontSize: 12,
    height: 1.25,
    shadows: AppShadows.text,
  );

  // ── Settings ──
  static const TextStyle settingsTitle = TextStyle(
    color: AppColors.fieldText,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle fieldLabel = TextStyle(
    color: AppColors.fieldLabel,
    fontSize: 12,
  );

  static const TextStyle fieldInput = TextStyle(
    color: AppColors.fieldText,
    fontSize: 14,
  );

  static const TextStyle fieldHint = TextStyle(color: AppColors.fieldHint);

  /// Status line under the Connect button — red on error, green on success.
  static TextStyle statusMessage(bool isError) => TextStyle(
        color: isError ? AppColors.error : AppColors.success,
        fontSize: 12,
      );
}
