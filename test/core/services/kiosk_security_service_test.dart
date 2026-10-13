import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exam/core/services/kiosk_security_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.example.exam/kiosk');
  const eventChannel = EventChannel('com.example.exam/kiosk_events');
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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(eventChannel, null);
  });

  test('calls startLockTask, stopLockTask, isLockTaskActive, setWindowSecure, maximizeAlarmVolume, startAlarm, stopAlarm', () async {
    await service.startLockTask();
    final isActive = await service.isLockTaskActive();
    await service.setWindowSecure(true);
    await service.maximizeAlarmVolume();
    await service.startAlarm();
    await service.stopAlarm();
    await service.stopLockTask();

    expect(isActive, isTrue);
    expect(
      log.map((e) => e.method).toList(),
      equals(['startLockTask', 'isLockTaskActive', 'setWindowSecure', 'maximizeAlarmVolume', 'startAlarm', 'stopAlarm', 'stopLockTask']),
    );
  });

  test('exitAttemptStream maps native event names to ExitAttempt and drops unknown events', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(
      eventChannel,
      MockStreamHandler.inline(onListen: (arguments, events) {
        events.success('backPressed');
        events.success('windowFocusLost');
        events.success('appPaused');
        events.success('unpinned');
        events.success('bogusEvent');
        events.endOfStream();
      }),
    );

    await expectLater(
      service.exitAttemptStream,
      emitsInOrder([
        ExitAttempt.backPressed,
        ExitAttempt.windowFocusLost,
        ExitAttempt.appPaused,
        ExitAttempt.unpinned,
        emitsDone,
      ]),
    );
  });
}
