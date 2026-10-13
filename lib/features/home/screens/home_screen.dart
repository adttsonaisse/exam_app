import 'package:flutter/material.dart';
import 'package:exam/core/theme/app_theme.dart';
import 'package:exam/features/scanner/screens/qr_scanner_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onScanRequested;
  final void Function(String url)? onUrlScanned;

  const HomeScreen({
    super.key,
    this.onScanRequested,
    this.onUrlScanned,
  });

  Future<void> _handleScan(BuildContext context) async {
    if (onScanRequested != null) {
      onScanRequested!();
      return;
    }

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const QrScannerScreen(),
      ),
    );

    if (result != null && onUrlScanned != null) {
      onUrlScanned!(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Exam Shield'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              // App Title & Headline
              const Text(
                'Ujian Aman (Exam Shield)',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.625,
                  color: AppTheme.foregroundColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Aplikasi pelaksanaan ujian terkunci anti-contek dengan perlindungan layar penuh dan sensor keamanan.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 32),

              // Readiness Checklist Section
              const Text(
                'Pemeriksaan Kesiapan Perangkat',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.foregroundColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildReadinessCard(
                icon: Icons.camera_alt_outlined,
                title: 'Kamera Scanner',
                description: 'Siap memindai QR code Google Form',
                isReady: true,
              ),
              const SizedBox(height: 8),
              _buildReadinessCard(
                icon: Icons.wifi,
                title: 'Koneksi Internet',
                description: 'Jaringan seluler / Wi-Fi terhubung',
                isReady: true,
              ),
              const SizedBox(height: 8),
              _buildReadinessCard(
                icon: Icons.battery_charging_full_rounded,
                title: 'Status Baterai',
                description: 'Disarankan daya baterai di atas 20%',
                isReady: true,
              ),

              const Spacer(),

              // Primary CTA Button
              ElevatedButton.icon(
                onPressed: () => _handleScan(context),
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                label: const Text(
                  'Scan QR Ujian',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadinessCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isReady,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(icon, size: 20, color: AppTheme.foregroundColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.foregroundColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isReady ? Icons.check_circle_rounded : Icons.error_outline_rounded,
            size: 20,
            color: isReady ? AppTheme.successColor : AppTheme.dangerColor,
          ),
        ],
      ),
    );
  }
}
