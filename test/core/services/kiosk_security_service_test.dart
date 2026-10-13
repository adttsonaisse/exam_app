import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exam/core/services/kiosk_security_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.example.exam/kiosk');
  late MethodChannelKioskSecurityService service;
  final List<MethodCall> log = [];

  setUp(() {
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      if (methodCall.method == 'isLockTaskActive') return true;
      return null;
    });
    service = MethodChannelKioskSecurityService();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('calls startLockTask, stopLockTask, isLockTaskActive, setWindowSecure, maximizeAlarmVolume', () async {
    await service.startLockTask();
    final isActive = await service.isLockTaskActive();
    await service.setWindowSecure(true);
    await service.maximizeAlarmVolume();
    await service.stopLockTask();

    expect(isActive, isTrue);
    expect(
      log.map((e) => e.method).toList(),
      equals(['startLockTask', 'isLockTaskActive', 'setWindowSecure', 'maximizeAlarmVolume', 'stopLockTask']),
    );
  });
}
