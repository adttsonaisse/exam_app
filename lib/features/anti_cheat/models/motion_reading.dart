class MotionReading {
  final double pitch; // vertical lift in degrees (0 to 90)
  final double roll; // lateral tilt in degrees (0 to 90)
  final double accelMagnitude; // in m/s^2 (~9.8 is stationary)
  final bool isFlippedDown; // screen turned face-down onto desk

  const MotionReading({
    required this.pitch,
    required this.roll,
    required this.accelMagnitude,
    this.isFlippedDown = false,
  });

  @override
  String toString() =>
      'MotionReading(pitch: ${pitch.toStringAsFixed(1)}, roll: ${roll.toStringAsFixed(1)}, accel: ${accelMagnitude.toStringAsFixed(1)}, flipped: $isFlippedDown)';
}
