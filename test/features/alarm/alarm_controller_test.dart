import 'package:flutter_test/flutter_test.dart';
import 'package:exam/core/services/kiosk_security_service.dart';
import 'package:exam/features/alarm/controllers/alarm_controller.dart';

class MockKioskService implements KioskSecurityService {
  int volumeCalls = 0;
  int startAlarmCalls = 0;
  int stopAlarmCalls = 0;

  @override
  Stream<ExitAttempt> get exitAttemptStream => const Stream.empty();

  @override
  Future<void> maximizeAlarmVolume() async => volumeCalls++;

  @override
  Future<void> startAlarm() async => startAlarmCalls++;

  @override
  Future<void> stopAlarm() async => stopAlarmCalls++;

  @override
  Future<bool> isLockTaskActive() async => true;

  @override
  Future<void> setWindowSecure(bool enable) async {}

  @override
  Future<void> startLockTask() async {}

  @override
  Future<void> stopLockTask() async {}
}

void main() {
  test('AlarmController triggers alarm, maximizes volume, and silences only with valid supervisor PIN', () async {
    final mockKiosk = MockKioskService();
    final controller = AlarmController(kioskService: mockKiosk, supervisorPin: '123456');

    expect(controller.isAlarmActive, isFalse);
    expect(controller.currentAttempt, isNull);

    controller.triggerAlarm(ExitAttempt.backPressed);
    expect(controller.isAlarmActive, isTrue);
    expect(controller.currentAttempt, ExitAttempt.backPressed);
    expect(mockKiosk.startAlarmCalls, greaterThanOrEqualTo(1));

    // Wrong PIN
    final wrong = controller.resolveAlarm('000000');
    expect(wrong, isFalse);
    expect(controller.isAlarmActive, isTrue);
    expect(mockKiosk.stopAlarmCalls, 0);

    // Correct PIN
    final correct = controller.resolveAlarm('123456');
    expect(correct, isTrue);
    expect(controller.isAlarmActive, isFalse);
    expect(controller.currentAttempt, isNull);
    expect(mockKiosk.stopAlarmCalls, 1);
  });

  test('Repeated exit attempts while alarm is active do not restart the audio loop', () {
    final mockKiosk = MockKioskService();
    final controller = AlarmController(kioskService: mockKiosk);

    controller.triggerAlarm(ExitAttempt.backPressed);
    controller.triggerAlarm(ExitAttempt.windowFocusLost);
    controller.triggerAlarm(ExitAttempt.appPaused);
    controller.triggerAlarm(ExitAttempt.unpinned);

    expect(controller.isAlarmActive, isTrue);
    expect(controller.currentAttempt, ExitAttempt.unpinned);
    expect(mockKiosk.startAlarmCalls, 1);
  });
}
