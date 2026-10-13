import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:exam/features/anti_cheat/models/motion_reading.dart';
import 'package:exam/features/anti_cheat/services/motion_detector.dart';

void main() {
  group('MotionDetector', () {
    late MotionDetector detector;

    setUp(() {
      detector = MotionDetector(debounceDuration: const Duration(milliseconds: 100));
    });

    tearDown(() {
      detector.stopMonitoring();
    });

    test('detects extreme tilt and emits violation', () async {
      final controller = StreamController<MotionReading>();
      final violations = <ViolationType>[];
      final sub = detector.violationStream.listen(violations.add);
      detector.startMonitoring(testStream: controller.stream);

      // Normal reading (sitting on desk)
      controller.add(const MotionReading(pitch: 15.0, roll: 0.0, accelMagnitude: 9.8));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(violations, isEmpty);

      // Abnormal tilt (> 60 deg roll) sustained
      controller.add(const MotionReading(pitch: 15.0, roll: 75.0, accelMagnitude: 9.8));
      await Future.delayed(const Duration(milliseconds: 150));
      expect(violations, contains(ViolationType.extremeTilt));

      await sub.cancel();
      await controller.close();
    });

    test('detects vertical lift and emits violation', () async {
      final controller = StreamController<MotionReading>();
      final violations = <ViolationType>[];
      final sub = detector.violationStream.listen(violations.add);
      detector.startMonitoring(testStream: controller.stream);

      // Vertical lift (> 75 deg pitch) sustained
      controller.add(const MotionReading(pitch: 80.0, roll: 0.0, accelMagnitude: 9.8));
      await Future.delayed(const Duration(milliseconds: 150));
      expect(violations, contains(ViolationType.verticalLift));

      await sub.cancel();
      await controller.close();
    });

    test('detects sudden shake immediately even if reading returns to normal quickly', () async {
      final controller = StreamController<MotionReading>();
      final violations = <ViolationType>[];
      final sub = detector.violationStream.listen(violations.add);
      detector.startMonitoring(testStream: controller.stream);

      // Transient acceleration spike (> 25 m/s^2) for only 20ms
      controller.add(const MotionReading(pitch: 10.0, roll: 0.0, accelMagnitude: 28.0));
      await Future.delayed(const Duration(milliseconds: 20));
      controller.add(const MotionReading(pitch: 10.0, roll: 0.0, accelMagnitude: 9.8));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(violations, contains(ViolationType.suddenShake));

      await sub.cancel();
      await controller.close();
    });

    test('detects flip down and emits violation', () async {
      final controller = StreamController<MotionReading>();
      final violations = <ViolationType>[];
      final sub = detector.violationStream.listen(violations.add);
      detector.startMonitoring(testStream: controller.stream);

      // Flip down screen onto desk sustained
      controller.add(const MotionReading(pitch: 0.0, roll: 0.0, accelMagnitude: 9.8, isFlippedDown: true));
      await Future.delayed(const Duration(milliseconds: 150));
      expect(violations, contains(ViolationType.flipDown));

      await sub.cancel();
      await controller.close();
    });

    test('ignores momentary tilt spike shorter than debounce duration', () async {
      final controller = StreamController<MotionReading>();
      final violations = <ViolationType>[];
      final sub = detector.violationStream.listen(violations.add);
      detector.startMonitoring(testStream: controller.stream);

      controller.add(const MotionReading(pitch: 15.0, roll: 75.0, accelMagnitude: 9.8));
      // Quickly returns to normal before debounce duration (100ms) completes
      await Future.delayed(const Duration(milliseconds: 30));
      controller.add(const MotionReading(pitch: 15.0, roll: 5.0, accelMagnitude: 9.8));
      await Future.delayed(const Duration(milliseconds: 120));

      expect(violations, isEmpty);

      await sub.cancel();
      await controller.close();
    });
  });
}
