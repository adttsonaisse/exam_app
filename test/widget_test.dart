import 'package:flutter_test/flutter_test.dart';
import 'package:exam/core/services/kiosk_security_service.dart';
import 'package:exam/main.dart';

class MockKioskService implements KioskSecurityService {
  bool isPinned = false;
  bool isSecure = false;
  int alarmVolumeCalls = 0;

  @override
  Future<bool> isLockTaskActive() async => isPinned;

  @override
  Future<void> startLockTask() async {}

  @override
  Future<void> stopLockTask() async {
    isPinned = false;
  }

  @override
  Future<void> setWindowSecure(bool enable) async {
    isSecure = enable;
  }

  @override
  Future<void> maximizeAlarmVolume() async {
    alarmVolumeCalls++;
  }

  @override
  Future<void> startAlarm() async {
    alarmVolumeCalls++;
  }

  @override
  Future<void> stopAlarm() async {}
}

void main() {
  testWidgets('End-to-end flow: Home -> Gatekeeper -> Exam Screen', (tester) async {
    final mockKiosk = MockKioskService();

    await tester.pumpWidget(ExamApp(kioskService: mockKiosk));
    await tester.pump();

    // 1. Verify Home Screen is visible
    expect(find.text('Ujian Aman (Exam Shield)'), findsOneWidget);
    expect(find.text('Scan QR Ujian'), findsOneWidget);

    // 2. Trigger scan callback (simulating QR scan)
    final homeState = tester.state(find.byType(ExamApp)) as dynamic;
    homeState.startExamWithUrl('https://forms.gle/abc123xyz');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // 3. Verify Gatekeeper Screen is shown (app is not pinned yet)
    expect(find.textContaining('Sematkan Aplikasi'), findsWidgets);

    // 4. User successfully pins the app and confirms
    mockKiosk.isPinned = true;
    homeState.confirmPin();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // 5. Verify Exam session bar is visible
    expect(find.text('Sesi Ujian Terkunci'), findsOneWidget);
    expect(find.text('Selesai Ujian'), findsOneWidget);
  });
}
