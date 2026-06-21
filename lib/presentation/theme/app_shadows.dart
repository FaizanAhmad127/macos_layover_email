import 'package:flutter/material.dart';

/// Reusable shadow definitions. Not instantiable.
abstract final class AppShadows {
  /// Drop shadows on banner text so it stays readable over the
  /// near-transparent panel on any background (light or dark apps behind it).
  static const List<Shadow> text = [
    Shadow(blurRadius: 6, color: Colors.black, offset: Offset(0, 1)),
    Shadow(blurRadius: 12, color: Colors.black54),
  ];

  /// Soft shadow lifting the banner panel off the screen.
  static const List<BoxShadow> panel = [
    BoxShadow(blurRadius: 10, color: Colors.black26, offset: Offset(0, 2)),
  ];
}
