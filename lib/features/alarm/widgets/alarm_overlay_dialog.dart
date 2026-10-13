import 'package:flutter/material.dart';
import 'package:exam/core/theme/app_theme.dart';
import 'package:exam/features/alarm/controllers/alarm_controller.dart';

class AlarmOverlayDialog extends StatefulWidget {
  final AlarmController alarmController;

  static const String violationMessage =
      'Terdeteksi upaya keluar dari mode ujian! Letakkan perangkat di atas meja dan panggil pengawas.';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _pulseController.stop();
    } else if (!_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pinController.dispose();
    super.dispose();
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
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      return _buildStaticOverlay(context);
    }
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final alpha = 0.88 + (_pulseController.value * 0.08);
        return Container(
          color: Color.lerp(
            AppTheme.heroWarm.withValues(alpha: 0.92),
            AppTheme.dangerColor.withValues(alpha: 0.95),
            _pulseController.value * 0.45,
          )!.withValues(alpha: alpha),
          child: child,
        );
      },
      child: _buildCard(context),
    );
  }

  Widget _buildStaticOverlay(BuildContext context) {
    return Container(
      color: AppTheme.dangerColor.withValues(alpha: 0.92),
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    const violationText = AlarmOverlayDialog.violationMessage;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                  color: AppTheme.dangerColor.withValues(alpha: 0.45),
                  width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.dangerColor.withValues(alpha: 0.35),
                  offset: const Offset(0, 12),
                  blurRadius: 32,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMd),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppTheme.dangerColor.withValues(alpha: 0.45),
                          offset: const Offset(0, 8),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      size: 32,
                      color: Colors.white,
                      semanticLabel: 'Peringatan pelanggaran',
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'PERINGATAN PELANGGARAN!',
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(
                    color: AppTheme.dangerColor,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),
                Semantics(
                  liveRegion: true,
                  label: 'Penyebab alarm: $violationText',
                  child: Text(
                    violationText,
                    textAlign: TextAlign.center,
                    style: textTheme.titleSmall?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Alarm suara aktif. Harap letakkan perangkat Anda di atas meja dan panggil pengawas ujian untuk mematikan alarm.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
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
                    prefixIcon: Icon(Icons.lock_rounded,
                        size: 20, color: scheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _handleReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.dangerColor,
                    foregroundColor: scheme.onError,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 48),
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
    );
  }
}
