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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.dangerColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.screen_lock_portrait_rounded,
                  size: 40,
                  color: AppTheme.dangerColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Sematkan Aplikasi untuk Memulai Ujian',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: AppTheme.foregroundColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _controller.errorMessage ??
                    'Aplikasi belum disematkan. Harap izinkan penyematan layar pada dialog sistem Android agar tidak dapat berpindah aplikasi saat ujian.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
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
              const Spacer(),
              ElevatedButton(
                onPressed: _controller.isLoading ? null : _verifyAndPin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
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
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
