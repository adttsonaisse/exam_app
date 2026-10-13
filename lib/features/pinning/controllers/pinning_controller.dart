import 'package:flutter/foundation.dart';
import 'package:exam/core/services/kiosk_security_service.dart';

class PinningController extends ChangeNotifier {
  final KioskSecurityService kioskService;

  bool _isPinned = false;
  bool _isLoading = false;
  String? _errorMessage;

  PinningController({required this.kioskService});

  bool get isPinned => _isPinned;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> checkAndRequestPin() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // First check if already pinned
      var pinned = await kioskService.isLockTaskActive();
      if (!pinned) {
        await kioskService.startLockTask();
        pinned = await kioskService.isLockTaskActive();
      }

      _isPinned = pinned;
      if (!pinned) {
        _errorMessage =
            'Aplikasi belum disematkan. Harap izinkan penyematan layar pada dialog sistem Android.';
      }
      return pinned;
    } catch (e) {
      _errorMessage = 'Gagal meminta penyematan aplikasi: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
