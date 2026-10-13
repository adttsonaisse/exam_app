import 'package:flutter/foundation.dart';
import 'package:exam/core/services/kiosk_security_service.dart';
import 'package:exam/core/validators/supervisor_pin_validator.dart';
import 'package:exam/features/anti_cheat/services/motion_detector.dart';

class AlarmController extends ChangeNotifier {
  final KioskSecurityService kioskService;
  final String supervisorPin;

  bool _isAlarmActive = false;
  ViolationType? _currentViolation;

  AlarmController({
    required this.kioskService,
    this.supervisorPin = SupervisorPinValidator.defaultSupervisorPin,
  });

  bool get isAlarmActive => _isAlarmActive;
  ViolationType? get currentViolation => _currentViolation;

  void triggerAlarm(ViolationType violation) {
    _isAlarmActive = true;
    _currentViolation = violation;
    kioskService.maximizeAlarmVolume();
    notifyListeners();
  }

  bool resolveAlarm(String inputPin) {
    final isValid = SupervisorPinValidator.verifyPin(inputPin, expectedPin: supervisorPin);
    if (isValid) {
      _isAlarmActive = false;
      _currentViolation = null;
      notifyListeners();
      return true;
    }
    return false;
  }
}
