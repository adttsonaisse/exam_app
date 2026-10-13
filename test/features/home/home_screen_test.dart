import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exam/features/home/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen renders readiness checks and Scan QR button', (tester) async {
    var scanned = false;
    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(
        onScanRequested: () => scanned = true,
      ),
    ));

    expect(find.text('Ujian Aman (Exam Shield)'), findsOneWidget);
    expect(find.text('Kamera Scanner'), findsOneWidget);
    expect(find.text('Koneksi Internet'), findsOneWidget);
    expect(find.text('Scan QR Ujian'), findsOneWidget);

    final button = find.widgetWithText(ElevatedButton, 'Scan QR Ujian');
    expect(button, findsOneWidget);
    await tester.tap(button);
    await tester.pump();

    expect(scanned, isTrue);
  });
}
