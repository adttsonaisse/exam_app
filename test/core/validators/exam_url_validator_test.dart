import 'package:flutter_test/flutter_test.dart';
import 'package:exam/core/validators/exam_url_validator.dart';

void main() {
  group('ExamUrlValidator', () {
    test('accepts valid Google Forms URLs', () {
      expect(ExamUrlValidator.isValidGoogleFormUrl('https://forms.gle/abc123xyz'), isTrue);
      expect(ExamUrlValidator.isValidGoogleFormUrl('https://forms.gle/abc123xyz?usp=sf_link'), isTrue);
      expect(ExamUrlValidator.isValidGoogleFormUrl('https://docs.google.com/forms/d/e/1FAIpQLSc9/viewform'), isTrue);
      expect(ExamUrlValidator.isValidGoogleFormUrl('https://docs.google.com/forms/u/0/d/e/1FAIpQLSc9/viewform'), isTrue);
      expect(ExamUrlValidator.isValidGoogleFormUrl('https://docs.google.com/forms/d/e/1FAIpQLSc9/viewform?usp=sf_link'), isTrue);
    });

    test('rejects non-Google-Form or malicious URLs', () {
      expect(ExamUrlValidator.isValidGoogleFormUrl('javascript:alert(1)'), isFalse);
      expect(ExamUrlValidator.isValidGoogleFormUrl('https://phishing.com/google.com/forms'), isFalse);
      expect(ExamUrlValidator.isValidGoogleFormUrl('http://insecure-site.com'), isFalse);
      expect(ExamUrlValidator.isValidGoogleFormUrl(''), isFalse);
      expect(ExamUrlValidator.isValidGoogleFormUrl(null), isFalse);
    });

    test('sanitizes and trims URL properly', () {
      expect(
        ExamUrlValidator.sanitizeUrl('  https://forms.gle/abc123xyz  '),
        'https://forms.gle/abc123xyz',
      );
      expect(ExamUrlValidator.sanitizeUrl('invalid'), isNull);
    });
  });
}
