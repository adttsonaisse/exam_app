import 'package:flutter/material.dart';
import 'package:exam/core/services/kiosk_security_service.dart';
import 'package:exam/core/theme/app_theme.dart';
import 'package:exam/core/validators/supervisor_pin_validator.dart';
import 'package:exam/features/exam/screens/exam_webview_screen.dart';
import 'package:exam/features/home/screens/home_screen.dart';
import 'package:exam/features/pinning/screens/pinning_gatekeeper_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExamApp());
}

class ExamApp extends StatefulWidget {
  final KioskSecurityService? kioskService;

  const ExamApp({super.key, this.kioskService});

  @override
  State<ExamApp> createState() => _ExamAppState();
}

class _ExamAppState extends State<ExamApp> {
  late final KioskSecurityService _kioskService;
  String? _activeExamUrl;
  bool _isPinConfirmed = false;
  String _supervisorPin = SupervisorPinValidator.defaultSupervisorPin;

  @override
  void initState() {
    super.initState();
    _kioskService = widget.kioskService ?? MethodChannelKioskSecurityService();
  }

  void startExamWithUrl(String url) {
    setState(() {
      _activeExamUrl = url;
      _isPinConfirmed = false;
    });
  }

  void confirmPin() {
    setState(() {
      _isPinConfirmed = true;
    });
  }

  void _onUrlScanned(String url) => startExamWithUrl(url);

  void _onPinConfirmed() => confirmPin();

  void _onExamCompleted() {
    setState(() {
      _activeExamUrl = null;
      _isPinConfirmed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exam Shield',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    // Stage 1: Home Screen (Scan QR)
    if (_activeExamUrl == null) {
      return HomeScreen(
        currentSupervisorPin: _supervisorPin,
        onSupervisorPinChanged: (newPin) => setState(() => _supervisorPin = newPin),
        onUrlScanned: _onUrlScanned,
      );
    }

    // Stage 2: Gatekeeper Screen (Must be pinned before accessing exam)
    if (!_isPinConfirmed) {
      return PinningGatekeeperScreen(
        targetExamUrl: _activeExamUrl!,
        kioskService: _kioskService,
        onPinConfirmed: _onPinConfirmed,
      );
    }

    // Stage 3: Secure Exam Session Screen
    return ExamWebViewScreen(
      examUrl: _activeExamUrl!,
      kioskService: _kioskService,
      supervisorPin: _supervisorPin,
      onExamCompleted: _onExamCompleted,
    );
  }
}
