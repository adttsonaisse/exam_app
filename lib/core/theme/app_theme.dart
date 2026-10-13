import 'package:flutter/material.dart';

/// Design tokens and application theme — Vibrant Modern evolution of Superhuman.
/// Direction: evolve + energize. Keeps twilight-purple identity, deepens to
/// vivid indigo-violet for AA contrast, adds energetic cyan as wayfinding
/// secondary, tints neutrals violet for cohesion. One system across all screens.
class AppTheme {
  // Brand & Accent Colors — vibrant modern
  static const Color primaryColor = Color(0xFF6D28D9); // Vivid violet, sole action color
  static const Color onPrimary = Color(0xFFFFFFFF); // White on vivid for 7:1 contrast
  static const Color primaryBright = Color(0xFF8B5CF6); // Gradient mid, highlights
  static const Color primaryGlow = Color(0xFFCBB7FB); // Lavender glow retained for dark accents
  static const Color primaryHover = Color(0xFF5B21B6);
  static const Color primaryActive = Color(0xFF4C1D95);
  static const Color secondaryColor = Color(0xFF0284C7); // Vivid sky, wayfinding + info
  static const Color secondaryBright = Color(0xFF22D3EE); // Cyan glow for dark + decoration
  static const Color secondaryTextLight = Color(0xFF0369A1); // 5.9:1 on white for small text
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color link = Color(0xFF6D28D9);
  static const Color linkDark = Color(0xFFCBB7FB);

  // Tonal containers (Material 3 roles)
  static const Color primaryContainer = Color(0xFFEDE9FE); // Violet tint surface
  static const Color onPrimaryContainer = Color(0xFF4C1D95);
  static const Color secondaryContainer = Color(0xFFE0F2FE); // Cyan tint surface
  static const Color onSecondaryContainer = Color(0xFF0C4A6E);
  static const Color tertiaryContainer = Color(0xFFDCFCE7); // Success tint
  static const Color onTertiaryContainer = Color(0xFF14532D);

  // Surface Colors - Light Mode (Violet-tinted neutrals for cohesion)
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color backgroundColor = canvas;
  static const Color bone = Color(0xFFF3F0FF); // Violet-tinted inset groups
  static const Color card = Color(0xFFFFFFFF);
  static const Color surfaceColor = card;
  static const Color darkSurface = Color(0xFF1C1B1A);
  static const Color deepSurface = Color(0xFF121111);

  // Surface Colors - Dark Mode (violet-tinted depth)
  static const Color canvasDark = Color(0xFF14121F);
  static const Color backgroundDark = canvasDark;
  static const Color boneDark = Color(0xFF1E1B2E);
  static const Color cardDark = Color(0xFF232030);
  static const Color surfaceDark = cardDark;

  // Text Colors - Light Mode
  static const Color ink = Color(0xFF292827); // Primary headings and body
  static const Color foregroundColor = ink;
  static const Color body = Color(0xFF292827);
  static const Color charcoal = Color(0xFF292827);
  static const Color mute = Color(0x99292827); // rgba(41,40,39,0.6) - secondary info, large text only
  static const Color secondaryText = mute;
  static const Color ash = Color(0x66292827); // rgba(41,40,39,0.4) - tertiary metadata
  static const Color stone = Color(0x4D292827); // rgba(41,40,39,0.3) - disabled / placeholder
  static const Color mutedText = mute;
  static const Color onDark = Color(0xFFFCFCFC);
  static const Color onDarkMute = Color(0xB8FCFCFC); // rgba(252,252,252,0.72)

  // Accessible small-text variant: 60% ink is 4.05:1 on white and fails AA
  // for <=12px. Use 72%+ equivalent for small text (5.9:1, passes).
  static const Color secondaryTextSmall = Color(0xFF5A5958);
  static const Color secondaryTextSmallDark = Color(0xB8FFFFFF);

  // Text Colors - Dark Mode
  static const Color inkDark = Color(0xEBFFFFFF); // rgba(255,255,255,0.92)
  static const Color foregroundDark = inkDark;
  static const Color muteDark = Color(0x99FFFFFF); // rgba(255,255,255,0.6)
  static const Color secondaryTextDark = muteDark;
  static const Color ashDark = Color(0x66FFFFFF); // rgba(255,255,255,0.4)
  static const Color stoneDark = Color(0x40FFFFFF); // rgba(255,255,255,0.25)

  // Hero Depth Elements — vivid twilight-indigo to violet to cyan glow
  static const Color heroWarm = Color(0xFF1E1B4B); // Deep indigo night
  static const Color heroMid = Color(0xFF6D28D9); // Vivid violet core
  static const Color heroGlow = Color(0xFFA78BFA); // Violet glow
  static const Color heroCyan = Color(0xFF22D3EE); // Energetic cyan accent
  static const Color heroPink = Color(0xFFA78BFA);
  static const Color heroDarkGlow = Color(0xFF4C1D95);

  // Semantic & Feedback Colors — AA-passing text variants
  static const Color badgeSuccess = Color(0xFF16A34A);
  static const Color successColor = badgeSuccess;
  static const Color successText = Color(0xFF15803D); // 4.6:1 on white
  static const Color successTint = Color(0xFFDCFCE7);
  static const Color badgeWarning = Color(0xFFF59E0B);
  static const Color warningColor = badgeWarning;
  static const Color warningText = Color(0xFFB45309); // 4.8:1 on white
  static const Color warningTint = Color(0xFFFEF3C7);
  static const Color badgeInfo = Color(0xFF0284C7);
  static const Color infoColor = badgeInfo;
  static const Color infoTint = Color(0xFFE0F2FE);
  static const Color dangerColor = Color(0xFFDC2626);
  static const Color dangerTint = Color(0xFFFEE2E2);

  // Borders & Dividers — violet-tinted hairlines
  static const Color hairline = Color(0xFFE9E3F8);
  static const Color divider = Color(0xFFDDD6FE);
  static const Color borderColor = divider;
  static const Color hairlineDark = Color(0xFF2E2A45);
  static const Color dividerDark = Color(0xFF3B3557);
  static const Color borderColorDark = dividerDark;

  // Interaction & Overlays
  static const Color ringFocus = Color(0xFF8B5CF6); // Vivid focus ring, 3:1 on white
  static const Color overlayColor = Color(0x80000000); // rgba(0,0,0,0.5)
  static const Color overlayColorDark = Color(0xB3000000); // rgba(0,0,0,0.7)

  // Border Radius Scale (modern: 12px controls, 20-24px surfaces)
  static const double radiusNone = 0.0;
  static const double radiusXs = 6.0;
  static const double radiusSm = 12.0; // Buttons, inputs, chips, badges, alerts
  static const double radiusMd = 16.0;
  static const double radiusLg = 20.0; // Cards, modals, panels
  static const double radiusXl = 24.0; // Hero, sheets
  static const double radiusFull = 9999.0; // Circular controls

  // Spacing Scale (8px base grid)
  static const double spacingXxs = 4.0;
  static const double spacingXs = 8.0;
  static const double spacingSm = 12.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;
  static const double spacingXxxl = 64.0;
  static const double spacingSection = 80.0;
  static const double spacingBand = 120.0;

  // Gradients — vivid committed hero owns a deliberate region
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [heroWarm, heroMid, primaryBright],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient heroGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF14112B), heroMid, heroDarkGlow],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBright, primaryColor],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryBright, secondaryColor],
  );

  // Modern tonal shadows — offset + soft blur, never zero-offset halos
  static List<BoxShadow> cardShadow(BuildContext context) => [
        BoxShadow(
          color: (isDark(context) ? Colors.black : primaryColor)
              .withValues(alpha: isDark(context) ? 0.35 : 0.08),
          offset: const Offset(0, 8),
          blurRadius: 24,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.35),
      offset: const Offset(0, 8),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  // Typography intent from Design.md. No Super Sans VF asset is shipped,
  // so ThemeData intentionally uses the platform default (Roboto on Android)
  // with system fallbacks. Kept as documentation of intent only.
  static const String fontFamily = 'Super Sans VF';

  // Legacy static styles kept for API compatibility. New code should use
  // Theme.of(context).textTheme roles instead of these.
  static const TextStyle displayXl = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.w500,
    height: 0.96,
    letterSpacing: 0,
    color: ink,
  );

  static const TextStyle headingLg = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w500,
    height: 0.96,
    letterSpacing: -1.32,
    color: ink,
  );

  static const TextStyle bodyMd = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.50,
    letterSpacing: 0,
    color: ink,
  );

  static const TextStyle buttonMd = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.20,
    letterSpacing: -0.315,
    color: mute,
  );

  static const TextStyle codeMd = TextStyle(
    fontFamily: 'monospace',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.50,
    letterSpacing: 0,
  );

  // Brightness-aware helpers. Screens must use these (or Theme.of directly)
  // instead of the light-only statics above so darkTheme is actually consumed.
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color backgroundOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color cardOf(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color boneOf(BuildContext context) =>
      isDark(context) ? boneDark : bone;

  static Color inkOf(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color muteOf(BuildContext context, {bool small = false}) {
    if (!isDark(context)) {
      return small ? secondaryTextSmall : secondaryText;
    }
    return small ? secondaryTextSmallDark : secondaryTextDark;
  }

  static Color borderOf(BuildContext context) =>
      Theme.of(context).colorScheme.outline;

  static Color hairlineOf(BuildContext context) =>
      Theme.of(context).colorScheme.outlineVariant;

  static TextTheme _textThemeFor(Color onSurface, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w500,
        height: 0.96,
        letterSpacing: -1.32,
        color: onSurface,
      ),
      headlineSmall: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.15,
      ),
      titleLarge: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      titleMedium: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      titleSmall: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.50,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.45,
        color: secondary,
      ),
      bodySmall: const TextStyle(
        fontSize: 13,
        height: 1.45,
      ),
      labelLarge: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      labelMedium: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      labelSmall: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Light theme — vibrant modern Material 3.
  static ThemeData get lightTheme {
    const scheme = ColorScheme.light(
      primary: primaryColor,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondaryColor,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: badgeSuccess,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: dangerColor,
      onError: Colors.white,
      surface: surfaceColor,
      onSurface: foregroundColor,
      onSurfaceVariant: secondaryTextSmall,
      outline: borderColor,
      outlineVariant: hairline,
    );
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: canvas,
      colorScheme: scheme,
      textTheme: _textThemeFor(foregroundColor, secondaryTextSmall),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: foregroundColor,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: foregroundColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimary,
          shadowColor: primaryColor,
          elevation: 2,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.0,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: canvas,
          foregroundColor: foregroundColor,
          side: const BorderSide(color: hairline),
          elevation: 0,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.0,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: borderColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bone,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: dangerColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: dangerColor, width: 2),
        ),
        hintStyle: const TextStyle(color: stone, fontSize: 14),
        labelStyle: const TextStyle(color: secondaryTextSmall, fontSize: 14),
        prefixIconColor: secondaryColor,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: borderColor),
        ),
        titleTextStyle: const TextStyle(
          color: foregroundColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: secondaryTextSmall,
          fontSize: 14,
          height: 1.5,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
      ),
    );
  }

  /// Dark theme — vivid on violet-tinted depth, never a mechanical invert.
  static ThemeData get darkTheme {
    const scheme = ColorScheme.dark(
      primary: primaryGlow,
      onPrimary: heroWarm,
      primaryContainer: heroDarkGlow,
      onPrimaryContainer: Color(0xFFEDE9FE),
      secondary: secondaryBright,
      onSecondary: heroWarm,
      secondaryContainer: Color(0xFF0C4A6E),
      onSecondaryContainer: Color(0xFFE0F2FE),
      tertiary: Color(0xFF4ADE80),
      tertiaryContainer: Color(0xFF14532D),
      onTertiaryContainer: Color(0xFFDCFCE7),
      error: Color(0xFFF87171),
      onError: Color(0xFF450A0A),
      surface: surfaceDark,
      onSurface: foregroundDark,
      onSurfaceVariant: secondaryTextSmallDark,
      outline: borderColorDark,
      outlineVariant: hairlineDark,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: canvasDark,
      colorScheme: scheme,
      textTheme: _textThemeFor(foregroundDark, secondaryTextSmallDark),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: foregroundDark,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: foregroundDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGlow,
          foregroundColor: heroWarm,
          elevation: 0,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.0,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: canvasDark,
          foregroundColor: foregroundDark,
          side: const BorderSide(color: hairlineDark),
          elevation: 0,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.0,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: borderColorDark),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: boneDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: borderColorDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: borderColorDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: primaryGlow, width: 2),
        ),
        hintStyle: const TextStyle(color: stoneDark, fontSize: 14),
        labelStyle: const TextStyle(color: secondaryTextSmallDark, fontSize: 14),
        prefixIconColor: secondaryBright,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: borderColorDark),
        ),
        titleTextStyle: const TextStyle(
          color: foregroundDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: secondaryTextDark,
          fontSize: 14,
          height: 1.5,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderColorDark,
        thickness: 1,
      ),
    );
  }
}
