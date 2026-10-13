import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exam/core/theme/app_theme.dart';

void main() {
  group('AppTheme Superhuman Design System', () {
    test('provides Superhuman light theme tokens', () {
      final theme = AppTheme.lightTheme;
      expect(theme.primaryColor, const Color(0xFFCBB7FB));
      expect(theme.scaffoldBackgroundColor, const Color(0xFFFFFFFF));
      expect(theme.colorScheme.primary, const Color(0xFFCBB7FB));
      expect(theme.colorScheme.onPrimary, const Color(0xFF292827));
      expect(theme.colorScheme.secondary, const Color(0xFF714CB6));
      expect(theme.colorScheme.surface, const Color(0xFFFFFFFF));
      expect(theme.colorScheme.onSurface, const Color(0xFF292827));
      expect(theme.colorScheme.outline, const Color(0xFFDCD7D3));
    });

    test('provides Superhuman dark theme tokens', () {
      final darkTheme = AppTheme.darkTheme;
      expect(darkTheme.brightness, Brightness.dark);
      expect(darkTheme.scaffoldBackgroundColor, const Color(0xFF121111));
      expect(darkTheme.colorScheme.surface, const Color(0xFF252423));
      expect(darkTheme.colorScheme.onSurface, const Color(0xEBFFFFFF));
      expect(darkTheme.colorScheme.outline, const Color(0xFF3A3938));
    });

    test('defines brand, surface, and semantic colors from Design.md', () {
      // Brand & Accent
      expect(AppTheme.primaryColor, const Color(0xFFCBB7FB)); // Lavender Glow
      expect(AppTheme.primaryHover, const Color(0xFFB89DF0));
      expect(AppTheme.primaryActive, const Color(0xFFA884E5));
      expect(AppTheme.secondaryColor, const Color(0xFF714CB6)); // Amethyst

      // Surface
      expect(AppTheme.canvas, const Color(0xFFFFFFFF));
      expect(AppTheme.bone, const Color(0xFFF5F4F2));
      expect(AppTheme.card, const Color(0xFFFFFFFF));
      expect(AppTheme.canvasDark, const Color(0xFF121111));
      expect(AppTheme.boneDark, const Color(0xFF1A1918));
      expect(AppTheme.cardDark, const Color(0xFF252423));

      // Text
      expect(AppTheme.ink, const Color(0xFF292827));
      expect(AppTheme.mute, const Color(0x99292827));
      expect(AppTheme.ash, const Color(0x66292827));
      expect(AppTheme.stone, const Color(0x4D292827));

      // Hero Elements
      expect(AppTheme.heroWarm, const Color(0xFF1B1938));
      expect(AppTheme.heroGlow, const Color(0xFFCBB7FB));

      // Semantic
      expect(AppTheme.badgeSuccess, const Color(0xFF2B9A66));
      expect(AppTheme.badgeWarning, const Color(0xFFF59E0B));
      expect(AppTheme.badgeInfo, const Color(0xFF3B82F6));
      expect(AppTheme.dangerColor, const Color(0xFFE5484D));
      expect(AppTheme.hairline, const Color(0xFFECE9E5));
      expect(AppTheme.divider, const Color(0xFFDCD7D3));
      expect(AppTheme.ringFocus, const Color(0x80CBB7FB));
    });

    test('defines border radius and spacing scale', () {
      expect(AppTheme.radiusSm, 8.0);
      expect(AppTheme.radiusLg, 16.0);
      expect(AppTheme.spacingXs, 8.0);
      expect(AppTheme.spacingMd, 16.0);
      expect(AppTheme.spacingLg, 24.0);
      expect(AppTheme.spacingSection, 80.0);
    });
  });
}
