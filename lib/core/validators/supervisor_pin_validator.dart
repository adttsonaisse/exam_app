class SupervisorPinValidator {
  static const String defaultSupervisorPin = '123456';

  static final RegExp _pinFormatPattern = RegExp(r'^\d{6}$');

  /// Validates format of 6-digit numeric PIN.
  static bool isValidPinFormat(String? pin) {
    if (pin == null) return false;
    return _pinFormatPattern.hasMatch(pin);
  }

  /// Verifies input PIN against expected PIN.
  static bool verifyPin(String? inputPin, {String expectedPin = defaultSupervisorPin}) {
    if (inputPin == null || !isValidPinFormat(inputPin)) {
      return false;
    }
    // Simple constant-length check
    if (inputPin.length != expectedPin.length) {
      return false;
    }

    var matches = true;
    for (var i = 0; i < inputPin.length; i++) {
      if (inputPin.codeUnitAt(i) != expectedPin.codeUnitAt(i)) {
        matches = false;
      }
    }
    return matches;
  }
}
