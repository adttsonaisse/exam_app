import 'package:flutter_test/flutter_test.dart';
import 'package:exam/main.dart';

void main() {
  testWidgets('App launches with HomeScreen and vibrant theme', (tester) async {
    await tester.pumpWidget(const ExamApp());
    expect(find.textContaining('Fokus Penuh'), findsOneWidget);
    expect(find.text('Scan QR Ujian'), findsOneWidget);
    expect(find.text('Pemeriksaan Kesiapan Perangkat'), findsOneWidget);
  });
}
