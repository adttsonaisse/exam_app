import 'package:flutter/material.dart';
import 'package:exam/core/theme/app_theme.dart';
import 'package:exam/features/alarm/controllers/alarm_controller.dart';
import 'package:exam/features/anti_cheat/services/motion_detector.dart';

class AlarmOverlayDialog extends StatefulWidget {
  final AlarmController alarmController;

  const AlarmOverlayDialog({
    super.key,
    required this.alarmController,
  });

  @override
  State<AlarmOverlayDialog> createState() => _AlarmOverlayDialogState();
}

class _AlarmOverlayDialogState extends State<AlarmOverlayDialog>
  with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  final TextEditingController _pinController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  String _getViolationDescription(ViolationType? type) {
    switch (type) {
      case ViolationType.extremeTilt:
        return 'Terdeteksi perangkat dimiringkan secara drastis!';
      case ViolationType.verticalLift:
        return 'Terdeteksi perangkat diangkat melebihi batas wajar!';
      case ViolationType.suddenShake:
        return 'Terdeteksi gerakan guncangan/hentakan mendadak!';
      case ViolationType.flipDown:
        return 'Terdeteksi perangkat dibalik (layar menghadap ke bawah)!';
      case ViolationType.unpinned:
        return 'Peringatan: Aplikasi dilepas dari mode sematan (unpinned)!';
      case ViolationType.appPaused:
        return 'Peringatan: Terdeteksi upaya berpindah aplikasi!';
      case null:
        return 'Terdeteksi pergerakan abnormal saat ujian!';
    }
  }

  void _handleReset() {
    final inputPin = _pinController.text.trim();
    final success = widget.alarmController.resolveAlarm(inputPin);
    if (!success) {
      setState(() {
        _errorMessage = 'PIN Pengawas salah. Hubungi pengawas ruangan.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final alpha = 0.88 + (_pulseController.value * 0.08);
        return Container(
          color: Color.lerp(
            const Color(0xEB1B1938), // Twilight purple base
            AppTheme.dangerColor.withValues(alpha: 0.95),
            _pulseController.value * 0.45,
          )!.withValues(alpha: alpha),
          child: child,
        );
      },
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: AppTheme.borderColor),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2E000000),
                    blurRadius: 28,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.bone,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(color: AppTheme.dangerColor.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        size: 32,
                        color: AppTheme.dangerColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'PERINGATAN PELANGGARAN!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.dangerColor,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getViolationDescription(widget.alarmController.currentViolation),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.foregroundColor,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Alarm suara aktif. Harap letakkan perangkat Anda di atas meja dan panggil pengawas ujian untuk mematikan alarm.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'Masukkan PIN Pengawas',
                      hintText: '6 digit PIN',
                      errorText: _errorMessage,
                      prefixIcon: const Icon(Icons.lock_rounded, size: 20, color: AppTheme.mute),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _handleReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.dangerColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                    ),
                    child: const Text(
                      'Matikan Alarm & Lanjutkan Ujian',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
