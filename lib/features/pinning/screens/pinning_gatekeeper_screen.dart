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
        title: const Text('Verifikasi Keamanan'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Superhuman Elevated Security Verification Card
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.borderColor),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.bone,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(color: AppTheme.hairline),
                      ),
                      child: const Icon(
                        Icons.screen_lock_portrait_rounded,
                        size: 32,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Sematkan Aplikasi untuk Memulai Ujian',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
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
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.bone,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Petunjuk Penyematan Layar:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.foregroundColor,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '1. Saat muncul dialog pop-up Android, tekan "Sematkan" (Pin).\n'
                            '2. Jangan menekan tombol "Batal" atau tombol kembali.\n'
                            '3. Jika dialog tidak muncul, tekan tombol di bawah ini lagi.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: AppTheme.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Primary Pinning CTA Button
              ElevatedButton(
                onPressed: _controller.isLoading ? null : _verifyAndPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
