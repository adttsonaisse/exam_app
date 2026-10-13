import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:exam/features/anti_cheat/models/motion_reading.dart';

enum ViolationType {
  extremeTilt,
  verticalLift,
  suddenShake,
  flipDown,
  unpinned,
  appPaused,
}

class MotionDetector {
  final Duration debounceDuration;
  final StreamController<ViolationType> _violationController =
      StreamController<ViolationType>.broadcast();

  StreamSubscription<dynamic>? _subscription;
  Timer? _debounceTimer;
  ViolationType? _pendingViolation;

  MotionDetector({this.debounceDuration = const Duration(milliseconds: 1500)});

  Stream<ViolationType> get violationStream => _violationController.stream;

  void startMonitoring({Stream<MotionReading>? testStream}) {
    stopMonitoring();

    if (testStream != null) {
      _subscription = testStream.listen(_processReading);
    } else {
      // Listen to physical device accelerometer
      _subscription = accelerometerEventStream().listen((event) {
        final x = event.x;
        final y = event.y;
        final z = event.z;

        final magnitude = sqrt(x * x + y * y + z * z);
        // Portrait phone reference:
        // pitch: vertical lift (y axis relative to z)
        final pitch = atan2(y.abs(), z.abs()) * 180.0 / pi;
        // roll: lateral tilt left/right (x axis relative to z)
        final roll = atan2(x.abs(), z.abs()) * 180.0 / pi;
        // z < -3.0 indicates screen facing down onto surface
        final isFlippedDown = z < -3.0;

        _processReading(
          MotionReading(
            pitch: pitch,
            roll: roll,
            accelMagnitude: magnitude,
            isFlippedDown: isFlippedDown,
          ),
        );
      });
    }
  }

  void _processReading(MotionReading reading) {
    // 1. Sudden Shake: Impulsive acceleration spike (> 25 m/s^2).
    // An impulsive shake is emitted immediately without waiting for a 1.5s hold.
    if (reading.accelMagnitude > 25.0) {
      _violationController.add(ViolationType.suddenShake);
      return;
    }

    // 2. Continuous orientation angles use debouncing to filter out transient desk bumps.
    ViolationType? detected;
    if (reading.isFlippedDown) {
      detected = ViolationType.flipDown;
    } else if (reading.pitch > 75.0) {
      detected = ViolationType.verticalLift;
    } else if (reading.roll > 60.0) {
      detected = ViolationType.extremeTilt;
    }

    if (detected != null) {
      if (_pendingViolation == detected) {
        return;
      }
      _pendingViolation = detected;
      _debounceTimer?.cancel();
      _debounceTimer = Timer(debounceDuration, () {
        if (_pendingViolation != null) {
          _violationController.add(_pendingViolation!);
          _pendingViolation = null;
        }
      });
    } else {
      _pendingViolation = null;
      _debounceTimer?.cancel();
      _debounceTimer = null;
    }
  }

  /// Manually emit a violation (e.g. unpinned by hardware keys or app paused)
  void emitViolation(ViolationType type) {
    _violationController.add(type);
  }

  void stopMonitoring() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _pendingViolation = null;
    _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    stopMonitoring();
    _violationController.close();
  }
}
