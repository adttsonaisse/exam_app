import 'package:flutter/foundation.dart';
import 'package:exam/core/services/kiosk_security_service.dart';
import 'package:exam/core/validators/supervisor_pin_validator.dart';

class AlarmController extends ChangeNotifier {
  final KioskSecurityService kioskService;
  final String supervisorPin;

  bool _isAlarmActive = false;
  ExitAttempt? _currentAttempt;

  AlarmController({
    required this.kioskService,
    this.supervisorPin = SupervisorPinValidator.defaultSupervisorPin,
  });

  bool get isAlarmActive => _isAlarmActive;
  ExitAttempt? get currentAttempt => _currentAttempt;

  void triggerAlarm(ExitAttempt attempt) {
    _currentAttempt = attempt;
    if (_isAlarmActive) {
      notifyListeners();
      return;
    }
    _isAlarmActive = true;
    kioskService.startAlarm();
    notifyListeners();
  }

  bool resolveAlarm(String inputPin) {
    final isValid = SupervisorPinValidator.verifyPin(inputPin, expectedPin: supervisorPin);
    if (isValid) {
      _isAlarmActive = false;
      _currentAttempt = null;
      kioskService.stopAlarm();
      notifyListeners();
      return true;
    }
    return false;
  }
}
