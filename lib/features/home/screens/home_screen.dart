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
                  Icon(Icons.admin_panel_settings_rounded,
                      color: scheme.secondary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'PIN Pengawas Ujian',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: scheme.onSurface),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PIN ini digunakan pengawas untuk mematikan alarm pelanggaran dan membuka kunci sesi ujian.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.onSurfaceVariant,
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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius:
                    BorderRadius.circular(AppTheme.radiusSm),
                boxShadow: AppTheme.primaryShadow,
              ),
              child: const Icon(Icons.shield_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Exam Shield'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Pengaturan PIN Pengawas',
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: AppTheme.primaryColor,
                    size: 20),
              ),
              onPressed: () => _showPinConfigDialog(context),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 20.0),
                      decoration: BoxDecoration(
                        gradient: AppTheme.isDark(context)
                            ? AppTheme.heroGradientDark
                            : AppTheme.heroGradient,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusXl),
                        boxShadow: AppTheme.cardShadow(context),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -36,
                            top: -36,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 36,
                            bottom: -52,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.heroCyan
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _buildHeroChip(
                                      Icons.lock_rounded, 'Kiosk Terkunci'),
                                  const SizedBox(width: 8),
                                  _buildHeroChip(
                                      Icons.sensors_rounded, 'Sensor Gerak'),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Ujian Aman,\nFokus Penuh.',
                                style: textTheme.headlineSmall?.copyWith(
                                  color: AppTheme.onDark,
                                  fontWeight: FontWeight.w800,
                                  height: 1.05,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Kunci layar penuh + deteksi gerak otomatis. Scan QR, kerjakan soal, pengawas memegang PIN.',
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pemeriksaan Kesiapan Perangkat',
                      style: textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(color: scheme.outline),
                        boxShadow: AppTheme.cardShadow(context),
                      ),
                      child: Column(
                        children: [
                          _buildReadinessRow(
                            context,
                            icon: Icons.camera_alt_outlined,
                            iconTint: AppTheme.primaryContainer,
                            iconColor: AppTheme.primaryColor,
                            title: 'Kamera Scanner',
                            description:
                                'Kamera aktif untuk memindai QR code soal',
                            statusLabel: 'Siap',
                            isReady: true,
                          ),
                          Divider(
                              height: 1,
                              thickness: 1,
                              color: scheme.outlineVariant,
                              indent: 56),
                          _buildReadinessRow(
                            context,
                            icon: Icons.wifi_rounded,
                            iconTint: AppTheme.secondaryContainer,
                            iconColor: AppTheme.secondaryColor,
                            title: 'Koneksi Internet',
                            description: 'Jaringan data / Wi-Fi terhubung stabil',
                            statusLabel: 'Aktif',
                            isReady: true,
                          ),
                          Divider(
                              height: 1,
                              thickness: 1,
                              color: scheme.outlineVariant,
                              indent: 56),
                          _buildReadinessRow(
                            context,
                            icon: Icons.battery_charging_full_rounded,
                            iconTint: AppTheme.tertiaryContainer,
                            iconColor: AppTheme.successText,
                            title: 'Status Baterai',
                            description:
                                'Daya perangkat di atas batas minimal ujian',
                            statusLabel: 'Optimal',
                            isReady: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                        boxShadow: AppTheme.primaryShadow,
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => _handleScan(context),
                        icon: const Icon(Icons.qr_code_scanner_rounded,
                            size: 20, color: Colors.white),
                        label: const Text('Scan QR Ujian',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
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
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Arahkan kamera ke QR Code lembar ujian yang disediakan oleh pengawas',
                      textAlign: TextAlign.center,
                      style: textTheme.labelSmall?.copyWith(
                        color: AppTheme.muteOf(context, small: true),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadinessRow(
    BuildContext context, {
    required IconData icon,
    required Color iconTint,
    required Color iconColor,
    required String title,
    required String description,
    required String statusLabel,
    required bool isReady,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconTint,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: textTheme.labelMedium?.copyWith(
                    color: AppTheme.muteOf(context, small: true),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isReady
                  ? AppTheme.successTint
                  : AppTheme.dangerTint,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isReady ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                  size: 14,
                  color: isReady ? AppTheme.successText : AppTheme.dangerColor,
                ),
                const SizedBox(width: 4),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isReady ? AppTheme.successText : AppTheme.dangerColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
