/// Sizes, radii, spacing, and durations used across the UI. Single source of
/// truth — e.g. the banner pill size is consumed by both `main.dart` (window
/// `setSize`) and `email_banner.dart` (travel math). Not instantiable.
abstract final class AppDimensions {
  // ── Banner pill window ──
  static const double pillWidth = 540;
  static const double pillHeight = 170;

  /// Panel fills the pill height minus the outer vertical padding so the text
  /// column has a bounded height and clips/ellipsizes instead of overflowing.
  static const double panelHeight = pillHeight - (bannerOuterPaddingV * 2);

  // ── Settings window ──
  static const double settingsWidth = 420;
  static const double settingsHeight = 380;

  // ── Banner layout ──
  static const double bannerOuterPaddingH = 16;
  static const double bannerOuterPaddingV = 8;
  static const double panelPaddingH = 16;
  static const double panelPaddingV = 10;
  static const double panelRadius = 16;
  static const double parrotSize = 144;
  static const double parrotGap = 10;
  static const double gapHeadingToName = 4;
  static const double gapNameBlockToSubject = 4;
  static const double gapSubjectToBody = 2;

  // ── Settings layout ──
  static const double settingsPadding = 24;
  static const double settingsTitleGap = 20;
  static const double fieldGap = 12;
  static const double fieldToButtonGap = 16;
  static const double statusGap = 12;
  static const double fieldLabelGap = 4;
  static const double fieldRadius = 6;
  static const double fieldContentPaddingH = 12;
  static const double fieldContentPaddingV = 10;
  static const double iconSize = 18;
  static const double iconSplashRadius = 18;
  static const double quitButtonInset = 4;
  static const double spinnerSize = 16;
  static const double spinnerStroke = 2;

  // ── Durations ──
  static const Duration bannerTravel = Duration(milliseconds: 20000);
}
