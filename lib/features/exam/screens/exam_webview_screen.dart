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
              backgroundColor: AppTheme.surfaceColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                side: const BorderSide(color: AppTheme.borderColor),
              ),
              title: const Row(
                children: [
                  Icon(Icons.lock_outline_rounded, color: AppTheme.secondaryColor),
                  SizedBox(width: 10),
                  Text(
                    'Otorisasi Selesai Ujian',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.foregroundColor,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Untuk mengakhiri sesi ujian dan membuka kunci aplikasi, pengawas wajib memasukkan PIN Pengawas.',
                    style: TextStyle(fontSize: 13, height: 1.4, color: AppTheme.secondaryText),
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
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.secondaryText,
                  ),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                  ),
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
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              // Main WebView
              Column(
                children: [
                  // Superhuman Minimalist Top Status Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: const BoxDecoration(
                      color: AppTheme.surfaceColor,
                      border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.bone,
                            borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            size: 16,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Sesi Ujian Terkunci',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: AppTheme.foregroundColor,
                          ),
                        ),
                        const Spacer(),
                        OutlinedButton(
                          onPressed: _handleExitExam,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppTheme.canvas,
                            foregroundColor: AppTheme.foregroundColor,
                            side: const BorderSide(color: AppTheme.hairline),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                          ),
                          child: const Text(
                            'Selesai Ujian',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    const LinearProgressIndicator(
                      color: AppTheme.secondaryColor,
                      backgroundColor: AppTheme.bone,
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
