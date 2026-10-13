import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exam/core/services/kiosk_security_service.dart';
import 'package:exam/features/alarm/widgets/alarm_overlay_dialog.dart';
import 'package:exam/features/exam/screens/exam_webview_screen.dart';

class MockKioskService implements KioskSecurityService {
  bool isPinned = true;
  int startAlarmCalls = 0;
  int stopAlarmCalls = 0;
  final StreamController<ExitAttempt> exitAttempts =
      StreamController<ExitAttempt>.broadcast();

  @override
  Stream<ExitAttempt> get exitAttemptStream => exitAttempts.stream;

  @override
  Future<bool> isLockTaskActive() async => isPinned;

  @override
  Future<void> startLockTask() async {}

  @override
  Future<void> stopLockTask() async {}

  @override
  Future<void> setWindowSecure(bool enable) async {}

  @override
  Future<void> maximizeAlarmVolume() async {}

  @override
  Future<void> startAlarm() async => startAlarmCalls++;

  @override
  Future<void> stopAlarm() async => stopAlarmCalls++;

  Future<void> dispose() => exitAttempts.close();
}

void main() {
  testWidgets('Native exit attempt triggers alarm overlay with generic message',
      (tester) async {
    final mockKiosk = MockKioskService();
    addTearDown(mockKiosk.dispose);

    await tester.pumpWidget(MaterialApp(
      home: ExamWebViewScreen(
        examUrl: 'https://forms.gle/test1234',
        kioskService: mockKiosk,
        onExamCompleted: () {},
      ),
    ));
    await tester.pump();

    expect(find.byType(AlarmOverlayDialog), findsNothing);

    mockKiosk.exitAttempts.add(ExitAttempt.backPressed);
    await tester.pump();

    expect(mockKiosk.startAlarmCalls, 1);
    expect(find.byType(AlarmOverlayDialog), findsOneWidget);
    expect(
      find.text(AlarmOverlayDialog.violationMessage),
      findsOneWidget,
    );
  });

  testWidgets('Unpin alarm resolved by PIN shows re-pin barrier without alarm loop',
      (tester) async {
    final mockKiosk = MockKioskService()..isPinned = false;
    addTearDown(mockKiosk.dispose);

    await tester.pumpWidget(MaterialApp(
      home: ExamWebViewScreen(
        examUrl: 'https://forms.gle/test1234',
        kioskService: mockKiosk,
        onExamCompleted: () {},
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(AlarmOverlayDialog), findsOneWidget);

    // Supervisor enters the correct PIN to silence the alarm.
    // (Bounded pumps: the exam loading bar animates forever, so no settle.)
    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.widgetWithText(
        ElevatedButton, 'Matikan Alarm & Lanjutkan Ujian'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    // Re-pin barrier appears with Next disabled; alarm must not return.
    expect(find.text('Lanjut ke Ujian'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(AlarmOverlayDialog), findsNothing);

    final nextButton = find.widgetWithText(ElevatedButton, 'Lanjut ke Ujian');
    expect(tester.widget<ElevatedButton>(nextButton).onPressed, isNull);

    // Re-pin the app: Next enables, tapping it resumes the exam.
    mockKiosk.isPinned = true;
    final retryButton =
        find.widgetWithText(ElevatedButton, 'Sematkan Aplikasi Sekarang');
    await tester.ensureVisible(retryButton);
    await tester.tap(retryButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.widget<ElevatedButton>(nextButton).onPressed, isNotNull);
    await tester.ensureVisible(nextButton);
    await tester.tap(nextButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Lanjut ke Ujian'), findsNothing);
    expect(find.byType(AlarmOverlayDialog), findsNothing);
    expect(find.text('Sesi Ujian Terkunci'), findsOneWidget);
  });
}
