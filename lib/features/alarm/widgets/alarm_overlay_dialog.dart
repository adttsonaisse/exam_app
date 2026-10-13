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

class _AlarmOverlayDialogState extends State<AlarmOverlayDialog> {
  final TextEditingController _pinController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
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
    return Container(
      color: Colors.red.shade900.withValues(alpha: 0.95),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_rounded,
                      size: 38,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'PERINGATAN PELANGGARAN!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.red,
                      letterSpacing: 0.5,
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
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Alarm suara aktif. Harap letakkan perangkat Anda di atas meja dan panggil pengawas ujian untuk mematikan alarm.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'Masukkan PIN Pengawas',
                      hintText: '6 digit PIN',
                      errorText: _errorMessage,
                      prefixIcon: const Icon(Icons.lock_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _handleReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Matikan Alarm & Lanjutkan Ujian',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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
