import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exam/core/theme/app_theme.dart';

void main() {
  test('AppTheme provides Notion-style colors and typography', () {
    final theme = AppTheme.lightTheme;
    expect(theme.primaryColor, const Color(0xFF0075DE));
    expect(theme.scaffoldBackgroundColor, const Color(0xFFFFFFFF));
    expect(AppTheme.dangerColor, const Color(0xFFDD5B00));
  });
}
