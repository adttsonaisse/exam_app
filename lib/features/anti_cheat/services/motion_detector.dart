import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:exam/features/anti_cheat/models/motion_reading.dart';

enum ViolationType {
  extremeTilt,
  verticalLift,
  suddenShake,
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
        final pitch = atan2(-x, sqrt(y * y + z * z)) * 180.0 / pi;
        final roll = atan2(y, z) * 180.0 / pi;

        _processReading(
          MotionReading(
            pitch: pitch.abs(),
            roll: roll.abs(),
            accelMagnitude: magnitude,
          ),
        );
      });
    }
  }

  void _processReading(MotionReading reading) {
    ViolationType? detected;

    // Check thresholds
    if (reading.accelMagnitude > 25.0) {
      detected = ViolationType.suddenShake;
    } else if (reading.pitch > 75.0) {
      detected = ViolationType.verticalLift;
    } else if (reading.roll > 60.0) {
      detected = ViolationType.extremeTilt;
    }

    if (detected != null) {
      if (_pendingViolation == detected) {
        // Still pending the same violation, let debounce timer run
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
      // Normal reading cancels any transient anomaly
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
