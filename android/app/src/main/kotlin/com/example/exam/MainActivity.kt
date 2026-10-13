package com.example.exam

import android.app.ActivityManager
import android.content.Context
import android.media.AudioManager
import android.media.Ringtone
import android.media.RingtoneManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.exam/kiosk"
    private var alarmRingtone: Ringtone? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startLockTask" -> {
                    try {
                        startLockTask()
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("LOCK_TASK_FAILED", e.localizedMessage, null)
                    }
                }
                "stopLockTask" -> {
                    try {
                        stopLockTask()
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("STOP_LOCK_TASK_FAILED", e.localizedMessage, null)
                    }
                }
                "isLockTaskActive" -> {
                    try {
                        val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                        val isLocked = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            activityManager.lockTaskModeState != ActivityManager.LOCK_TASK_MODE_NONE
                        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                            @Suppress("DEPRECATION")
                            activityManager.isInLockTaskMode
                        } else {
                            false
                        }
                        result.success(isLocked)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "setWindowSecure" -> {
                    try {
                        val enable = call.argument<Boolean>("enable") ?: true
                        if (enable) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("FLAG_SECURE_FAILED", e.localizedMessage, null)
                    }
                }
                "maximizeAlarmVolume" -> {
                    try {
                        maximizeVolume()
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("VOLUME_OVERRIDE_FAILED", e.localizedMessage, null)
                    }
                }
                "startAlarm" -> {
                    try {
                        maximizeVolume()
                        startSoundAndVibrate()
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("START_ALARM_FAILED", e.localizedMessage, null)
                    }
                }
                "stopAlarm" -> {
                    try {
                        stopSoundAndVibrate()
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("STOP_ALARM_FAILED", e.localizedMessage, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun maximizeVolume() {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val maxAlarm = audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM)
        audioManager.setStreamVolume(AudioManager.STREAM_ALARM, maxAlarm, 0)

        val maxMusic = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, maxMusic, 0)
    }

    private fun startSoundAndVibrate() {
        val alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
        if (alarmRingtone == null) {
            alarmRingtone = RingtoneManager.getRingtone(applicationContext, alarmUri)
        }
        if (alarmRingtone?.isPlaying == false) {
            alarmRingtone?.play()
        }

        val vibrator = getVibratorService()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator?.vibrate(VibrationEffect.createWaveform(longArrayOf(0, 500, 200, 500), 0))
        } else {
            @Suppress("DEPRECATION")
            vibrator?.vibrate(longArrayOf(0, 500, 200, 500), 0)
        }
    }

    private fun stopSoundAndVibrate() {
        alarmRingtone?.stop()
        alarmRingtone = null
        getVibratorService()?.cancel()
    }

    private fun getVibratorService(): Vibrator? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
            vibratorManager?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        }
    }

    override fun onDestroy() {
        stopSoundAndVibrate()
        super.onDestroy()
    }
}
