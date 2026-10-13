import 'package:flutter/material.dart';
import 'package:exam/core/services/kiosk_security_service.dart';
import 'package:exam/core/theme/app_theme.dart';
import 'package:exam/features/pinning/controllers/pinning_controller.dart';

class PinningGatekeeperScreen extends StatefulWidget {
  final String targetExamUrl;
  final KioskSecurityService kioskService;
  final VoidCallback onPinConfirmed;

  const PinningGatekeeperScreen({
    super.key,
    required this.targetExamUrl,
    required this.kioskService,
    required this.onPinConfirmed,
  });

  @override
  State<PinningGatekeeperScreen> createState() => _PinningGatekeeperScreenState();
}

class _PinningGatekeeperScreenState extends State<PinningGatekeeperScreen> {
  late final PinningController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PinningController(kioskService: widget.kioskService);
    _controller.addListener(_onControllerUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verifyAndPin();
    });
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    if (_controller.isPinned) {
      widget.onPinConfirmed();
    } else {
      setState(() {});
    }
  }

  Future<void> _verifyAndPin() async {
    final success = await _controller.checkAndRequestPin();
    if (success && mounted) {
      widget.onPinConfirmed();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Sematkan Aplikasi'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Security Protocol Timeline Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryContainer,
                      AppTheme.secondaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: scheme.outline),
                ),
                child: Row(
                  children: [
                    _buildStepChip(context, '1', 'Scan QR', isCompleted: true),
                    Expanded(
                      child: Divider(color: scheme.outline, thickness: 1.5, indent: 8, endIndent: 8),
                    ),
                    _buildStepChip(context, '2', 'Sematkan', isActive: true),
                    Expanded(
                      child: Divider(color: AppTheme.hairlineOf(context), thickness: 1.5, indent: 8, endIndent: 8),
                    ),
                    _buildStepChip(context, '3', 'Ujian', isCompleted: false),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Level 1 Border Containment Security Card
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: scheme.outline),
                  boxShadow: AppTheme.cardShadow(context),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                        boxShadow: AppTheme.primaryShadow,
                      ),
                      child: const Icon(
                        Icons.screen_lock_portrait_rounded,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Sematkan Aplikasi untuk Memulai Ujian',
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _controller.errorMessage ??
                          'Aplikasi belum disematkan. Harap izinkan penyematan layar pada dialog sistem Android agar tidak dapat berpindah aplikasi saat ujian.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Instructional Guidance Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer.withValues(
                            alpha: AppTheme.isDark(context) ? 0.25 : 1),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: scheme.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.touch_app_outlined, size: 16, color: scheme.secondary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Petunjuk Penyematan Layar:',
                                  style: textTheme.titleSmall?.copyWith(
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildInstructionRow(context, '1', 'Saat dialog konfirmasi Android muncul, tekan "Sematkan" (Pin).'),
                          const SizedBox(height: 6),
                          _buildInstructionRow(context, '2', 'Jangan menekan tombol "Batal" atau tombol navigasi kembali.'),
                          const SizedBox(height: 6),
                          _buildInstructionRow(context, '3', 'Jika dialog belum muncul, ketuk tombol di bawah untuk meminta izin ulang.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Primary Pinning CTA Button
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusMd),
                  boxShadow: AppTheme.primaryShadow,
                ),
                child: ElevatedButton(
                  onPressed: _controller.isLoading ? null : _verifyAndPin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 56),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  child: _controller.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Sematkan Aplikasi Sekarang',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Perangkat wajib disematkan sebelum akses ke soal ujian dapat dibuka',
                textAlign: TextAlign.center,
                style: textTheme.labelSmall?.copyWith(
                  color: AppTheme.muteOf(context, small: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepChip(BuildContext context, String stepNumber, String title, {bool isCompleted = false, bool isActive = false}) {
    final scheme = Theme.of(context).colorScheme;
    Color bg;
    Color fg;
    Border? border;

    if (isCompleted) {
      bg = AppTheme.successText;
      fg = Colors.white;
    } else if (isActive) {
      bg = AppTheme.primaryColor;
      fg = Colors.white;
      border = Border.all(color: AppTheme.primaryBright, width: 2);
    } else {
      bg = Colors.transparent;
      fg = scheme.onSurfaceVariant;
      border = Border.all(color: scheme.outlineVariant);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: border,
          ),
          child: isCompleted
              ? Icon(Icons.check_rounded, size: 14, color: scheme.onSecondary)
              : Text(
                  stepNumber,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive || isCompleted ? FontWeight.w600 : FontWeight.w400,
            color: isActive || isCompleted ? scheme.onSurface : scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionRow(BuildContext context, String number, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Text(
            number,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primaryColor),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.muteOf(context, small: true),
            ),
          ),
        ),
      ],
    );
  }
}
