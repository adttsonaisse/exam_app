import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:exam/core/services/kiosk_security_service.dart';
import 'package:exam/core/theme/app_theme.dart';
import 'package:exam/core/validators/exam_url_validator.dart';
import 'package:exam/core/validators/supervisor_pin_validator.dart';
import 'package:exam/features/alarm/controllers/alarm_controller.dart';
import 'package:exam/features/alarm/widgets/alarm_overlay_dialog.dart';
import 'package:exam/features/anti_cheat/services/motion_detector.dart';

class ExamWebViewScreen extends StatefulWidget {
  final String examUrl;
  final KioskSecurityService kioskService;
  final String supervisorPin;
  final VoidCallback onExamCompleted;
  final MotionDetector? customMotionDetector;
  final AlarmController? customAlarmController;
  final WebViewController? customWebViewController;

  const ExamWebViewScreen({
    super.key,
    required this.examUrl,
    required this.kioskService,
    required this.onExamCompleted,
    this.supervisorPin = SupervisorPinValidator.defaultSupervisorPin,
    this.customMotionDetector,
    this.customAlarmController,
    this.customWebViewController,
  });

  @override
  State<ExamWebViewScreen> createState() => _ExamWebViewScreenState();
}

class _ExamWebViewScreenState extends State<ExamWebViewScreen> with WidgetsBindingObserver {
  WebViewController? _webViewController;
  late final MotionDetector _motionDetector;
  late final AlarmController _alarmController;

  StreamSubscription<ViolationType>? _violationSub;
  Timer? _pinCheckTimer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _alarmController = widget.customAlarmController ??
        AlarmController(
          kioskService: widget.kioskService,
          supervisorPin: widget.supervisorPin,
        );
    _alarmController.addListener(_onAlarmUpdated);

    _motionDetector = widget.customMotionDetector ?? MotionDetector();
    _violationSub = _motionDetector.violationStream.listen((violation) {
      _alarmController.triggerAlarm(violation);
    });
    _motionDetector.startMonitoring();

    // Secure window against screenshots
    widget.kioskService.setWindowSecure(true);

    // Periodically verify lock task is still active (detect unpinning via hardware keys)
    _pinCheckTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final isPinned = await widget.kioskService.isLockTaskActive();
      if (!isPinned && mounted) {
        _alarmController.triggerAlarm(ViolationType.unpinned);
      }
    });

    _initWebView();
  }

  void _onAlarmUpdated() {
    if (mounted) setState(() {});
  }

  void _initWebView() {
    if (widget.customWebViewController != null) {
      _webViewController = widget.customWebViewController;
      return;
    }

    if (WebViewPlatform.instance != null) {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) {
              if (mounted) setState(() => _isLoading = true);
            },
            onPageFinished: (_) {
              if (mounted) setState(() => _isLoading = false);
              // Inject anti-copy CSS & JS
              _webViewController?.runJavaScript('''
                document.body.style.userSelect = 'none';
                document.body.style.webkitUserSelect = 'none';
                document.addEventListener('contextmenu', function(e) { e.preventDefault(); });
              ''');
            },
            onNavigationRequest: (NavigationRequest request) {
              // Only allow Google Forms domains
              if (ExamUrlValidator.isValidGoogleFormUrl(request.url) ||
                  request.url.contains('accounts.google.com')) {
                return NavigationDecision.navigate;
              }
              return NavigationDecision.prevent;
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.examUrl));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _alarmController.triggerAlarm(ViolationType.appPaused);
    }
  }

  Future<void> _handleExitExam() async {
    final pinController = TextEditingController();
    String? errorText;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              ),
              title: const Text('Otorisasi Selesai Ujian'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Untuk mengakhiri sesi ujian dan membuka kunci aplikasi, pengawas wajib memasukkan PIN Pengawas.',
                    style: TextStyle(fontSize: 13, color: AppTheme.secondaryText),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'PIN Pengawas',
                      errorText: errorText,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final isValid = SupervisorPinValidator.verifyPin(
                      pinController.text.trim(),
                      expectedPin: widget.supervisorPin,
                    );
                    if (isValid) {
                      Navigator.pop(context, true);
                    } else {
                      setDialogState(() {
                        errorText = 'PIN salah. Hubungi pengawas.';
                      });
                    }
                  },
                  child: const Text('Konfirmasi Selesai'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true && mounted) {
      await widget.kioskService.stopLockTask();
      await widget.kioskService.setWindowSecure(false);
      widget.onExamCompleted();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pinCheckTimer?.cancel();
    _violationSub?.cancel();
    _motionDetector.dispose();
    _alarmController.removeListener(_onAlarmUpdated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Disable hardware back button
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              // Main WebView
              Column(
                children: [
                  // Minimal Top Status Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(
                      color: AppTheme.surfaceColor,
                      border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_rounded, size: 18, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        const Text(
                          'Sesi Ujian Terkunci',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.foregroundColor,
                          ),
                        ),
                        const Spacer(),
                        OutlinedButton(
                          onPressed: _handleExitExam,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Selesai Ujian',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    const LinearProgressIndicator(
                      color: AppTheme.primaryColor,
                      backgroundColor: Colors.transparent,
                      minHeight: 2,
                    ),
                  Expanded(
                    child: _webViewController != null
                        ? WebViewWidget(controller: _webViewController!)
                        : const Center(
                            child: Text(
                              'Halaman Ujian Google Form',
                              style: TextStyle(color: AppTheme.secondaryText),
                            ),
                          ),
                  ),
                ],
              ),

              // Alarm Overlay
              if (_alarmController.isAlarmActive)
                Positioned.fill(
                  child: AlarmOverlayDialog(alarmController: _alarmController),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
