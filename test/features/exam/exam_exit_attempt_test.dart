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

  testWidgets('Unpin fallback poll triggers alarm when lock task is inactive',
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
    expect(
      find.text(AlarmOverlayDialog.violationMessage),
      findsOneWidget,
    );
  });
}
