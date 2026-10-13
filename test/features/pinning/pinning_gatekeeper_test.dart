import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exam/core/services/kiosk_security_service.dart';
import 'package:exam/features/pinning/screens/pinning_gatekeeper_screen.dart';

class MockKioskService implements KioskSecurityService {
  bool active = false;

  @override
  Future<bool> isLockTaskActive() async => active;

  @override
  Future<void> startLockTask() async {}

  @override
  Future<void> stopLockTask() async {}

  @override
  Future<void> setWindowSecure(bool enable) async {}

  @override
  Future<void> maximizeAlarmVolume() async {}

  @override
  Future<void> startAlarm() async {}

  @override
  Future<void> stopAlarm() async {}
}

void main() {
  testWidgets('Gatekeeper blocks navigation if unpinned and allows proceed when pinned', (tester) async {
    final mockService = MockKioskService()..active = false;
    var proceeded = false;

    await tester.pumpWidget(MaterialApp(
      home: PinningGatekeeperScreen(
        targetExamUrl: 'https://forms.gle/test1234',
        kioskService: mockService,
        onPinConfirmed: () => proceeded = true,
      ),
    ));

    await tester.pumpAndSettle();

    // Verification: Screen displays barrier title and instructions
    expect(find.textContaining('Sematkan Aplikasi'), findsWidgets);
    expect(find.textContaining('belum disematkan'), findsOneWidget);
    expect(proceeded, isFalse);

    // Simulate pinning success
    mockService.active = true;
    final retryButton = find.widgetWithText(ElevatedButton, 'Sematkan Aplikasi Sekarang');
    expect(retryButton, findsOneWidget);

    await tester.tap(retryButton);
    await tester.pumpAndSettle();

    expect(proceeded, isTrue);
  });
}
