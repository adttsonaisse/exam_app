import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:exam/core/theme/app_theme.dart';
import 'package:exam/core/validators/exam_url_validator.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    final sanitized = ExamUrlValidator.sanitizeUrl(rawValue);
    if (sanitized != null) {
      // Valid Google Forms URL scanned
      Navigator.pop(context, sanitized);
    } else {
      // Invalid URL
      _showInvalidQrDialog(rawValue);
    }
  }

  void _showInvalidQrDialog(String rawValue) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            side: const BorderSide(color: AppTheme.borderColor),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.badgeWarning, size: 22),
              SizedBox(width: 10),
              Text(
                'QR Code Tidak Valid',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.foregroundColor,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          content: Text(
            'QR code yang dipindai bukan tautan resmi Google Forms ujian.\n\nIsi QR: $rawValue',
            style: const TextStyle(fontSize: 14, height: 1.45, color: AppTheme.secondaryText),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isProcessing = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
              child: const Text('Scan Ulang'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepSurface,
      appBar: AppBar(
        backgroundColor: AppTheme.deepSurface,
        foregroundColor: AppTheme.onDark,
        elevation: 0,
        title: const Text(
          'Pindai QR Code Ujian',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.3),
        ),
        actions: [
          IconButton(
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _scannerController,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: AppTheme.heroGlow);
                  case TorchState.off:
                  case TorchState.unavailable:
                  case TorchState.auto:
                    return const Icon(Icons.flash_off, color: AppTheme.onDark);
                }
              },
            ),
            onPressed: () => _scannerController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          // Precise Matte Viewfinder (Superhuman precision frame, 16px radius, no neon glow)
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.6), width: 1.5),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                  ),
                  // Precision Corner Accents
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppTheme.primaryColor, width: 3.5),
                          left: BorderSide(color: AppTheme.primaryColor, width: 3.5),
                        ),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(AppTheme.radiusLg)),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppTheme.primaryColor, width: 3.5),
                          right: BorderSide(color: AppTheme.primaryColor, width: 3.5),
                        ),
                        borderRadius: BorderRadius.only(topRight: Radius.circular(AppTheme.radiusLg)),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppTheme.primaryColor, width: 3.5),
                          left: BorderSide(color: AppTheme.primaryColor, width: 3.5),
                        ),
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(AppTheme.radiusLg)),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppTheme.primaryColor, width: 3.5),
                          right: BorderSide(color: AppTheme.primaryColor, width: 3.5),
                        ),
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(AppTheme.radiusLg)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Guidance banner (Matte dark chip, warm on-dark text)
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.darkSurface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppTheme.hairlineDark),
              ),
              child: const Row(
                children: [
                  Icon(Icons.qr_code_2_rounded, size: 20, color: AppTheme.primaryColor),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Posisikan QR Code lembar ujian tepat di dalam bingkai scanner',
                      style: TextStyle(
                        color: AppTheme.onDark,
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
