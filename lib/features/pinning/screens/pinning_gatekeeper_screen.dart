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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
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
                  color: AppTheme.bone,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.hairline),
                ),
                child: Row(
                  children: [
                    _buildStepChip('1', 'Scan QR', isCompleted: true),
                    const Expanded(
                      child: Divider(color: AppTheme.divider, thickness: 1.5, indent: 8, endIndent: 8),
                    ),
                    _buildStepChip('2', 'Sematkan', isActive: true),
                    const Expanded(
                      child: Divider(color: AppTheme.hairline, thickness: 1.5, indent: 8, endIndent: 8),
                    ),
                    _buildStepChip('3', 'Ujian', isCompleted: false),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Level 1 Border Containment Security Card
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppTheme.bone,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(color: AppTheme.hairline),
                      ),
                      child: const Icon(
                        Icons.screen_lock_portrait_rounded,
                        size: 28,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Sematkan Aplikasi untuk Memulai Ujian',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: AppTheme.foregroundColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _controller.errorMessage ??
                          'Aplikasi belum disematkan. Harap izinkan penyematan layar pada dialog sistem Android agar tidak dapat berpindah aplikasi saat ujian.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Instructional Guidance Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.bone,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.touch_app_outlined, size: 16, color: AppTheme.secondaryColor),
                              SizedBox(width: 8),
                              Text(
                                'Petunjuk Penyematan Layar:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.foregroundColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildInstructionRow('1', 'Saat dialog konfirmasi Android muncul, tekan "Sematkan" (Pin).'),
                          const SizedBox(height: 6),
                          _buildInstructionRow('2', 'Jangan menekan tombol "Batal" atau tombol navigasi kembali.'),
                          const SizedBox(height: 6),
                          _buildInstructionRow('3', 'Jika dialog belum muncul, ketuk tombol di bawah untuk meminta izin ulang.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Primary Pinning CTA Button
              ElevatedButton(
                onPressed: _controller.isLoading ? null : _verifyAndPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.onPrimary,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 52),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                ),
                child: _controller.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.onPrimary,
                        ),
                      )
                    : const Text(
                        'Sematkan Aplikasi Sekarang',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2),
                      ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Perangkat wajib disematkan sebelum akses ke soal ujian dapat dibuka',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppTheme.secondaryText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepChip(String stepNumber, String title, {bool isCompleted = false, bool isActive = false}) {
    Color bg;
    Color fg;
    Border? border;

    if (isCompleted) {
      bg = AppTheme.secondaryColor;
      fg = Colors.white;
    } else if (isActive) {
      bg = AppTheme.primaryColor;
      fg = AppTheme.onPrimary;
      border = Border.all(color: AppTheme.secondaryColor, width: 1.2);
    } else {
      bg = Colors.transparent;
      fg = AppTheme.secondaryText;
      border = Border.all(color: AppTheme.hairline);
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
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
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
            color: isActive || isCompleted ? AppTheme.foregroundColor : AppTheme.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionRow(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.hairline),
          ),
          child: Text(
            number,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.secondaryColor),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, height: 1.45, color: AppTheme.secondaryText),
          ),
        ),
      ],
    );
  }
}
