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
        final scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogTheme.backgroundColor ??
              scheme.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            side: BorderSide(color: scheme.outline),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppTheme.badgeWarning, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'QR Code Tidak Valid',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: scheme.onSurface),
                ),
              ),
            ],
          ),
          content: Text(
            'QR code yang dipindai bukan tautan resmi Google Forms ujian.\n\nIsi QR: $rawValue',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
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
    final navInset = MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      backgroundColor: AppTheme.deepSurface,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppTheme.deepSurface,
        foregroundColor: AppTheme.onDark,
        elevation: 0,
        title: const Text(
          'Pindai QR Code Ujian',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.3),
        ),
        actions: [
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _scannerController,
            builder: (context, state, child) {
              final unavailable =
                  state.torchState == TorchState.unavailable;
              final isOn = state.torchState == TorchState.on;
              return Semantics(
                button: true,
                enabled: !unavailable,
                toggled: isOn,
                label: 'Alihkan lampu kilat',
                child: IconButton(
                  tooltip: 'Alihkan lampu kilat',
                  onPressed: unavailable
                      ? null
                      : () => _scannerController.toggleTorch(),
                  icon: Icon(
                    isOn ? Icons.flash_on : Icons.flash_off,
                    color: isOn
                        ? AppTheme.heroCyan
                        : AppTheme.onDark,
                    semanticLabel: isOn
                        ? 'Lampu kilat menyala'
                        : 'Lampu kilat mati',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          // Precise Matte Viewfinder (vivid violet frame + cyan corners)
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.5),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.heroCyan.withValues(alpha: 0.35),
                          offset: const Offset(0, 0),
                          blurRadius: 32,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                  // Precision Corner Accents
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        border: const Border(
                          top: BorderSide(color: AppTheme.heroCyan, width: 5),
                          left: BorderSide(color: AppTheme.heroCyan, width: 5),
                        ),
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(AppTheme.radiusLg)),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.heroCyan.withValues(alpha: 0.6),
                            offset: const Offset(0, 2),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        border: const Border(
                          top: BorderSide(color: AppTheme.heroCyan, width: 5),
                          right: BorderSide(color: AppTheme.heroCyan, width: 5),
                        ),
                        borderRadius: const BorderRadius.only(topRight: Radius.circular(AppTheme.radiusLg)),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.heroCyan.withValues(alpha: 0.6),
                            offset: const Offset(0, 2),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        border: const Border(
                          bottom: BorderSide(color: AppTheme.primaryBright, width: 5),
                          left: BorderSide(color: AppTheme.primaryBright, width: 5),
                        ),
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(AppTheme.radiusLg)),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        border: const Border(
                          bottom: BorderSide(color: AppTheme.primaryBright, width: 5),
                          right: BorderSide(color: AppTheme.primaryBright, width: 5),
                        ),
                        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(AppTheme.radiusLg)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Guidance banner (Matte dark chip, warm on-dark text)
          Positioned(
            bottom: navInset + 24,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1B4B), Color(0xFF4C1D95)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border:
                    Border.all(color: AppTheme.heroCyan.withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.qr_code_2_rounded,
                      size: 22, color: AppTheme.heroCyan),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Posisikan QR Code lembar ujian tepat di dalam bingkai scanner',
                      style: TextStyle(
                        color: AppTheme.onDark,
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
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
