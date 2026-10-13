import 'package:flutter/services.dart';

abstract class KioskSecurityService {
  /// Request the system to lock the task / pin the app.
  Future<void> startLockTask();

  /// Stop lock task mode / unpin the app.
  Future<void> stopLockTask();

  /// Check whether the app is currently in lock task / pinned mode.
  Future<bool> isLockTaskActive();

  /// Enable or disable FLAG_SECURE on the Android window (anti-screenshot/recording).
  Future<void> setWindowSecure(bool enable);

  /// Maximize alarm / media stream volume.
  Future<void> maximizeAlarmVolume();

  /// Start playing alarm siren tone and loop vibration.
  Future<void> startAlarm();

  /// Stop alarm siren tone and vibration.
  Future<void> stopAlarm();
}

class MethodChannelKioskSecurityService implements KioskSecurityService {
  static const MethodChannel _channel = MethodChannel('com.example.exam/kiosk');

  final MethodChannel channel;

  MethodChannelKioskSecurityService({MethodChannel? customChannel})
      : channel = customChannel ?? _channel;

  @override
  Future<void> startLockTask() async {
    try {
      await channel.invokeMethod<void>('startLockTask');
    } catch (_) {
      // Platform error handling
    }
  }

  @override
  Future<void> stopLockTask() async {
    try {
      await channel.invokeMethod<void>('stopLockTask');
    } catch (_) {
      // Platform error handling
    }
  }

  @override
  Future<bool> isLockTaskActive() async {
    try {
      final result = await channel.invokeMethod<bool>('isLockTaskActive');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> setWindowSecure(bool enable) async {
    try {
      await channel.invokeMethod<void>('setWindowSecure', {'enable': enable});
    } catch (_) {
      // Platform error handling
    }
  }

  @override
  Future<void> maximizeAlarmVolume() async {
    try {
      await channel.invokeMethod<void>('maximizeAlarmVolume');
    } catch (_) {
      // Platform error handling
    }
  }

  @override
  Future<void> startAlarm() async {
    try {
      await channel.invokeMethod<void>('startAlarm');
    } catch (_) {
      // Platform error handling
    }
  }

  @override
  Future<void> stopAlarm() async {
    try {
      await channel.invokeMethod<void>('stopAlarm');
    } catch (_) {
      // Platform error handling
    }
  }
}
