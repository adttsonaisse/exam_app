class ExamUrlValidator {
  // Regex pattern matching:
  // 1. https://forms.gle/[id]
  // 2. https://docs.google.com/forms/d/...
  static final RegExp _googleFormsPattern = RegExp(
    r'^https:\/\/(forms\.gle\/[a-zA-Z0-9_\-]+|docs\.google\.com\/forms\/d\/(?:e\/[a-zA-Z0-9_\-]+|[a-zA-Z0-9_\-]+)\/(?:viewform|edit|formResponse)(?:\?.*)?)$',
    caseSensitive: false,
  );

  /// Checks if given [rawUrl] is a legitimate Google Forms URL.
  static bool isValidGoogleFormUrl(String? rawUrl) {
    if (rawUrl == null) return false;
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return false;

    try {
      final uri = Uri.parse(trimmed);
      if (!uri.isScheme('https')) return false;
      if (uri.host != 'forms.gle' && uri.host != 'docs.google.com') return false;
      return _googleFormsPattern.hasMatch(trimmed);
    } catch (_) {
      return false;
    }
  }

  /// Sanitizes and returns trimmed URL if valid, or null if invalid.
  static String? sanitizeUrl(String? rawUrl) {
    if (isValidGoogleFormUrl(rawUrl)) {
      return rawUrl!.trim();
    }
    return null;
  }
}
