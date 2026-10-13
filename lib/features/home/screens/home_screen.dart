import 'package:flutter/material.dart';
import 'package:exam/core/theme/app_theme.dart';
import 'package:exam/core/validators/supervisor_pin_validator.dart';
import 'package:exam/features/scanner/screens/qr_scanner_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onScanRequested;
  final void Function(String url)? onUrlScanned;
  final String currentSupervisorPin;
  final void Function(String newPin)? onSupervisorPinChanged;

  const HomeScreen({
    super.key,
    this.onScanRequested,
    this.onUrlScanned,
    this.currentSupervisorPin = SupervisorPinValidator.defaultSupervisorPin,
    this.onSupervisorPinChanged,
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

  void _showPinConfigDialog(BuildContext context) {
    final controller = TextEditingController(text: currentSupervisorPin);
    String? errorText;

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.surfaceColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                side: const BorderSide(color: AppTheme.borderColor),
              ),
              title: const Row(
                children: [
                  Icon(Icons.admin_panel_settings_rounded, color: AppTheme.secondaryColor, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'PIN Pengawas Ujian',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.foregroundColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PIN ini digunakan pengawas untuk mematikan alarm pelanggaran dan membuka kunci sesi ujian.',
                    style: TextStyle(fontSize: 13, height: 1.45, color: AppTheme.secondaryText),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: '6 Digit Master PIN',
                      errorText: errorText,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.secondaryText,
                  ),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newPin = controller.text.trim();
                    if (SupervisorPinValidator.isValidPinFormat(newPin)) {
                      onSupervisorPinChanged?.call(newPin);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PIN Pengawas berhasil diperbarui')),
                      );
                    } else {
                      setDialogState(() {
                        errorText = 'PIN harus berupa 6 digit angka.';
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                  ),
                  child: const Text('Simpan PIN'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Exam Shield'),
        actions: [
          IconButton(
            tooltip: 'Pengaturan PIN Pengawas',
            icon: const Icon(Icons.admin_panel_settings_outlined, color: AppTheme.secondaryColor),
            onPressed: () => _showPinConfigDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Superhuman Signature Hero Section (Singular gesture, no fluff, no pill eyebrow)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
                decoration: BoxDecoration(
                  gradient: AppTheme.heroGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.heroWarm),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ujian Aman (Exam Shield)',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        height: 1.15,
                        color: AppTheme.onDark,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Aplikasi pelaksanaan ujian terkunci anti-contek dengan perlindungan layar penuh dan sensor keamanan.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppTheme.onDarkMute,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Readiness Checklist Section Header
              const Text(
                'Pemeriksaan Kesiapan Perangkat',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.foregroundColor,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),

              // Unified Superhuman Readiness List Container (eliminated copy-paste fragmented cards)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  children: [
                    _buildReadinessRow(
                      icon: Icons.camera_alt_outlined,
                      title: 'Kamera Scanner',
                      description: 'Siap memindai QR code Google Form',
                      isReady: true,
                    ),
                    const Divider(height: 1, thickness: 1, color: AppTheme.hairline, indent: 58),
                    _buildReadinessRow(
                      icon: Icons.wifi_rounded,
                      title: 'Koneksi Internet',
                      description: 'Jaringan seluler / Wi-Fi terhubung',
                      isReady: true,
                    ),
                    const Divider(height: 1, thickness: 1, color: AppTheme.hairline, indent: 58),
                    _buildReadinessRow(
                      icon: Icons.battery_charging_full_rounded,
                      title: 'Status Baterai',
                      description: 'Disarankan daya baterai di atas 20%',
                      isReady: true,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Primary CTA Button (Lavender Glow with Charcoal text, flat, 8px radius)
              ElevatedButton.icon(
                onPressed: () => _handleScan(context),
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                label: const Text(
                  'Scan QR Ujian',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadinessRow({
    required IconData icon,
    required String title,
    required String description,
    required bool isReady,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.bone,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
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
            size: 18,
            color: isReady ? AppTheme.badgeSuccess : AppTheme.dangerColor,
          ),
        ],
      ),
    );
  }
}
