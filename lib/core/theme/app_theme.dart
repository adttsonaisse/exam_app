import 'package:flutter/material.dart';

/// Design tokens and application theme based on the Superhuman design system.
/// Defined in Design.md.
class AppTheme {
  // Brand & Accent Colors
  static const Color primaryColor = Color(0xFFCBB7FB); // Lavender Glow, sole brand accent
  static const Color onPrimary = Color(0xFF292827); // Charcoal/Ink on primary for AAA contrast
  static const Color primaryHover = Color(0xFFB89DF0);
  static const Color primaryActive = Color(0xFFA884E5);
  static const Color secondaryColor = Color(0xFF714CB6); // Amethyst, used for links and secondary actions
  static const Color link = Color(0xFF714CB6);
  static const Color linkDark = Color(0xFFCBB7FB);

  // Surface Colors - Light Mode (Warm neutrals)
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color backgroundColor = canvas;
  static const Color bone = Color(0xFFF5F4F2); // Inset section groups, muted containers
  static const Color card = Color(0xFFFFFFFF);
  static const Color surfaceColor = card;
  static const Color darkSurface = Color(0xFF1C1B1A);
  static const Color deepSurface = Color(0xFF121111);

  // Surface Colors - Dark Mode
  static const Color canvasDark = Color(0xFF121111);
  static const Color backgroundDark = canvasDark;
  static const Color boneDark = Color(0xFF1A1918);
  static const Color cardDark = Color(0xFF252423);
  static const Color surfaceDark = cardDark;

  // Text Colors - Light Mode
  static const Color ink = Color(0xFF292827); // Primary headings and body
  static const Color foregroundColor = ink;
  static const Color body = Color(0xFF292827);
  static const Color charcoal = Color(0xFF292827);
  static const Color mute = Color(0x99292827); // rgba(41,40,39,0.6) - secondary info
  static const Color secondaryText = mute;
  static const Color ash = Color(0x66292827); // rgba(41,40,39,0.4) - tertiary metadata
  static const Color stone = Color(0x4D292827); // rgba(41,40,39,0.3) - disabled / placeholder
  static const Color mutedText = mute;
  static const Color onDark = Color(0xFFFCFCFC);
  static const Color onDarkMute = Color(0xB8FCFCFC); // rgba(252,252,252,0.72)

  // Text Colors - Dark Mode
  static const Color inkDark = Color(0xEBFFFFFF); // rgba(255,255,255,0.92)
  static const Color foregroundDark = inkDark;
  static const Color muteDark = Color(0x99FFFFFF); // rgba(255,255,255,0.6)
  static const Color secondaryTextDark = muteDark;
  static const Color ashDark = Color(0x66FFFFFF); // rgba(255,255,255,0.4)
  static const Color stoneDark = Color(0x40FFFFFF); // rgba(255,255,255,0.25)

  // Hero Depth Elements
  static const Color heroWarm = Color(0xFF1B1938); // Deep twilight purple
  static const Color heroGlow = Color(0xFFCBB7FB); // Lavender glow
  static const Color heroPink = Color(0xFFCBB7FB);
  static const Color heroDarkGlow = Color(0xFF3A2468);

  // Semantic & Feedback Colors
  static const Color badgeSuccess = Color(0xFF2B9A66);
  static const Color successColor = badgeSuccess;
  static const Color badgeWarning = Color(0xFFF59E0B);
  static const Color warningColor = badgeWarning;
  static const Color badgeInfo = Color(0xFF3B82F6);
  static const Color infoColor = badgeInfo;
  static const Color dangerColor = Color(0xFFE5484D);

  // Borders & Dividers
  static const Color hairline = Color(0xFFECE9E5);
  static const Color divider = Color(0xFFDCD7D3);
  static const Color borderColor = divider;
  static const Color hairlineDark = Color(0xFF252423);
  static const Color dividerDark = Color(0xFF3A3938);
  static const Color borderColorDark = dividerDark;

  // Interaction & Overlays
  static const Color ringFocus = Color(0x80CBB7FB); // rgba(203,183,251,0.5)
  static const Color overlayColor = Color(0x80000000); // rgba(0,0,0,0.5)
  static const Color overlayColorDark = Color(0xB3000000); // rgba(0,0,0,0.7)

  // Border Radius Scale (Binary radius system: 8px small, 16px large)
  static const double radiusNone = 0.0;
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0; // Buttons, inputs, selects, badges, alerts
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0; // Cards, modals, panels
  static const double radiusXl = 16.0; // Backward-compatible alias
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

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [heroWarm, heroGlow],
  );

  static const LinearGradient heroGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [heroWarm, heroDarkGlow],
  );

  // Typography Styles
  static const String fontFamily = 'Super Sans VF';

  static const TextStyle displayXl = TextStyle(
    fontFamily: fontFamily,
    fontSize: 64,
    fontWeight: FontWeight.w500,
    height: 0.96,
    letterSpacing: 0,
    color: ink,
  );

  static const TextStyle headingLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w500,
    height: 0.96,
    letterSpacing: -1.32,
    color: ink,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.50,
    letterSpacing: 0,
    color: ink,
  );

  static const TextStyle buttonMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.20,
    letterSpacing: -0.315,
    color: mute,
  );

  static const TextStyle codeMd = TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.50,
    letterSpacing: 0,
  );

  /// Light theme implementing Superhuman specifications.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: canvas,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: onPrimary,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        error: dangerColor,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: foregroundColor,
        outline: borderColor,
        outlineVariant: hairline,
      ),
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
          elevation: 0,
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
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: canvas,
          foregroundColor: foregroundColor,
          side: const BorderSide(color: hairline),
          elevation: 0,
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
        fillColor: surfaceColor,
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
          borderSide: const BorderSide(color: foregroundColor, width: 1.5),
        ),
        hintStyle: const TextStyle(color: stone, fontSize: 14),
        labelStyle: const TextStyle(color: mute, fontSize: 14),
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
          color: secondaryText,
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

  /// Dark theme implementing Superhuman specifications.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: canvasDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        onPrimary: deepSurface,
        secondary: linkDark,
        onSecondary: deepSurface,
        error: dangerColor,
        onError: Colors.white,
        surface: surfaceDark,
        onSurface: foregroundDark,
        outline: borderColorDark,
        outlineVariant: hairlineDark,
      ),
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
          backgroundColor: primaryColor,
          foregroundColor: deepSurface,
          elevation: 0,
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
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: canvasDark,
          foregroundColor: foregroundDark,
          side: const BorderSide(color: hairlineDark),
          elevation: 0,
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
        fillColor: surfaceDark,
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
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        hintStyle: const TextStyle(color: stoneDark, fontSize: 14),
        labelStyle: const TextStyle(color: muteDark, fontSize: 14),
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
