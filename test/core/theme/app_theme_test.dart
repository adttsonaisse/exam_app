import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exam/core/theme/app_theme.dart';

void main() {
  group('AppTheme Vibrant Modern Design System', () {
    test('provides vibrant light theme tokens', () {
      final theme = AppTheme.lightTheme;
      expect(theme.primaryColor, const Color(0xFF6D28D9));
      expect(theme.scaffoldBackgroundColor, const Color(0xFFFFFFFF));
      expect(theme.colorScheme.primary, const Color(0xFF6D28D9));
      expect(theme.colorScheme.onPrimary, const Color(0xFFFFFFFF));
      expect(theme.colorScheme.secondary, const Color(0xFF0284C7));
      expect(theme.colorScheme.surface, const Color(0xFFFFFFFF));
      expect(theme.colorScheme.onSurface, const Color(0xFF292827));
      expect(theme.colorScheme.outline, const Color(0xFFDDD6FE));
    });

    test('provides vibrant dark theme tokens', () {
      final darkTheme = AppTheme.darkTheme;
      expect(darkTheme.brightness, Brightness.dark);
      expect(darkTheme.scaffoldBackgroundColor, const Color(0xFF14121F));
      expect(darkTheme.colorScheme.surface, const Color(0xFF232030));
      expect(darkTheme.colorScheme.onSurface, const Color(0xEBFFFFFF));
      expect(darkTheme.colorScheme.outline, const Color(0xFF3B3557));
    });

    test('defines brand, surface, and semantic colors', () {
      // Brand & Accent — vibrant evolve + energize
      expect(AppTheme.primaryColor, const Color(0xFF6D28D9)); // Vivid violet
      expect(AppTheme.primaryBright, const Color(0xFF8B5CF6));
      expect(AppTheme.primaryHover, const Color(0xFF5B21B6));
      expect(AppTheme.primaryActive, const Color(0xFF4C1D95));
      expect(AppTheme.secondaryColor, const Color(0xFF0284C7)); // Vivid sky
      expect(AppTheme.secondaryBright, const Color(0xFF22D3EE));

      // Surface — violet-tinted cohesion
      expect(AppTheme.canvas, const Color(0xFFFFFFFF));
      expect(AppTheme.bone, const Color(0xFFF3F0FF));
      expect(AppTheme.card, const Color(0xFFFFFFFF));
      expect(AppTheme.canvasDark, const Color(0xFF14121F));
      expect(AppTheme.boneDark, const Color(0xFF1E1B2E));
      expect(AppTheme.cardDark, const Color(0xFF232030));

      // Text
      expect(AppTheme.ink, const Color(0xFF292827));
      expect(AppTheme.mute, const Color(0x99292827));
      expect(AppTheme.ash, const Color(0x66292827));
      expect(AppTheme.stone, const Color(0x4D292827));

      // Hero Elements — vivid twilight indigo
      expect(AppTheme.heroWarm, const Color(0xFF1E1B4B));
      expect(AppTheme.heroMid, const Color(0xFF6D28D9));
      expect(AppTheme.heroGlow, const Color(0xFFA78BFA));
      expect(AppTheme.heroCyan, const Color(0xFF22D3EE));

      // Semantic — AA-passing
      expect(AppTheme.badgeSuccess, const Color(0xFF16A34A));
      expect(AppTheme.successText, const Color(0xFF15803D));
      expect(AppTheme.badgeWarning, const Color(0xFFF59E0B));
      expect(AppTheme.warningText, const Color(0xFFB45309));
      expect(AppTheme.badgeInfo, const Color(0xFF0284C7));
      expect(AppTheme.dangerColor, const Color(0xFFDC2626));
      expect(AppTheme.hairline, const Color(0xFFE9E3F8));
      expect(AppTheme.divider, const Color(0xFFDDD6FE));
      expect(AppTheme.ringFocus, const Color(0xFF8B5CF6));
    });

    test('defines border radius and spacing scale', () {
      expect(AppTheme.radiusSm, 12.0);
      expect(AppTheme.radiusMd, 16.0);
      expect(AppTheme.radiusLg, 20.0);
      expect(AppTheme.radiusXl, 24.0);
      expect(AppTheme.spacingXs, 8.0);
      expect(AppTheme.spacingMd, 16.0);
      expect(AppTheme.spacingLg, 24.0);
      expect(AppTheme.spacingSection, 80.0);
    });

    test('action and small-text pairs pass WCAG AA', () {
      expect(
        _contrast(const Color(0xFFFFFFFF), AppTheme.primaryColor),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(AppTheme.primaryColor, const Color(0xFFFFFFFF)),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(AppTheme.secondaryTextLight, const Color(0xFFFFFFFF)),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrast(AppTheme.successText, const Color(0xFFFFFFFF)),
        greaterThanOrEqualTo(4.5),
      );
    });
  });
}

double _contrast(Color a, Color b) {
  final l1 = a.computeLuminance();
  final l2 = b.computeLuminance();
  final hi = l1 > l2 ? l1 : l2;
  final lo = l1 > l2 ? l2 : l1;
  return (hi + 0.05) / (lo + 0.05);
}
