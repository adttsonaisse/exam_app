import 'package:flutter_test/flutter_test.dart';
import 'package:exam/core/validators/supervisor_pin_validator.dart';

void main() {
  group('SupervisorPinValidator', () {
    test('validates correct default and custom supervisor PINs', () {
      expect(SupervisorPinValidator.verifyPin('123456'), isTrue);
      expect(SupervisorPinValidator.verifyPin('998877', expectedPin: '998877'), isTrue);
    });

    test('rejects incorrect or malformed PINs', () {
      expect(SupervisorPinValidator.verifyPin('000000'), isFalse);
      expect(SupervisorPinValidator.verifyPin('123'), isFalse);
      expect(SupervisorPinValidator.verifyPin(''), isFalse);
      expect(SupervisorPinValidator.verifyPin('abcdef'), isFalse);
    });

    test('validates format of 6 digit numeric PIN', () {
      expect(SupervisorPinValidator.isValidPinFormat('123456'), isTrue);
      expect(SupervisorPinValidator.isValidPinFormat('12345'), isFalse);
      expect(SupervisorPinValidator.isValidPinFormat('1234567'), isFalse);
      expect(SupervisorPinValidator.isValidPinFormat('12a456'), isFalse);
    });
  });
}
