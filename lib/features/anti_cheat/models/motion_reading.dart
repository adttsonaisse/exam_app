class MotionReading {
  final double pitch; // in degrees (-90 to 90)
  final double roll; // in degrees (-180 to 180)
  final double accelMagnitude; // in m/s^2 (~9.8 is stationary)

  const MotionReading({
    required this.pitch,
    required this.roll,
    required this.accelMagnitude,
  });

  @override
  String toString() =>
      'MotionReading(pitch: ${pitch.toStringAsFixed(1)}, roll: ${roll.toStringAsFixed(1)}, accel: ${accelMagnitude.toStringAsFixed(1)})';
}
