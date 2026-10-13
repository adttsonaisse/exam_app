import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:exam/core/services/kiosk_security_service.dart';
import 'package:exam/core/theme/app_theme.dart';
import 'package:exam/core/validators/exam_url_validator.dart';
import 'package:exam/core/validators/supervisor_pin_validator.dart';
import 'package:exam/features/alarm/controllers/alarm_controller.dart';
import 'package:exam/features/alarm/widgets/alarm_overlay_dialog.dart';
import 'package:exam/features/pinning/screens/pinning_gatekeeper_screen.dart';

class ExamWebViewScreen extends StatefulWidget {
  final String examUrl;
  final KioskSecurityService kioskService;
  final String supervisorPin;
  final VoidCallback onExamCompleted;
  final AlarmController? customAlarmController;
  final WebViewController? customWebViewController;

  const ExamWebViewScreen({
    super.key,
    required this.examUrl,
    required this.kioskService,
    required this.onExamCompleted,
    this.supervisorPin = SupervisorPinValidator.defaultSupervisorPin,
    this.customAlarmController,
    this.customWebViewController,
  });

  @override
  State<ExamWebViewScreen> createState() => _ExamWebViewScreenState();
}

class _ExamWebViewScreenState extends State<ExamWebViewScreen> with WidgetsBindingObserver {
  WebViewController? _webViewController;
  late final AlarmController _alarmController;

  StreamSubscription<ExitAttempt>? _exitAttemptSub;
  Timer? _pinCheckTimer;
  bool _isLoading = true;
  bool _requiresRepin = false;

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

    // Native exit-attempt events trigger the alarm immediately.
    // Suppressed while the re-pin barrier is shown (it already blocks the exam).
    _exitAttemptSub =
        widget.kioskService.exitAttemptStream.listen((attempt) {
      if (!_requiresRepin && mounted) {
        _alarmController.triggerAlarm(attempt);
      }
    });

    // Secure window against screenshots
    widget.kioskService.setWindowSecure(true);

    // Fallback poll in case a native event is missed (e.g. hardware-key unpin).
    _pinCheckTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      final isPinned = await widget.kioskService.isLockTaskActive();
      if (!isPinned && mounted && !_requiresRepin) {
        _alarmController.triggerAlarm(ExitAttempt.unpinned);
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
    if ((state == AppLifecycleState.paused ||
            state == AppLifecycleState.inactive) &&
        !_requiresRepin) {
      _alarmController.triggerAlarm(ExitAttempt.appPaused);
    }
  }

  /// After a supervisor PIN resolves an alarm, show the re-pin barrier
  /// if the app is still not pinned. This breaks the resolve -> re-alarm
  /// loop: the exam stays blocked until the app is pinned again.
  /// The barrier is set synchronously for the unpinned case so the 500ms
  /// fallback poll cannot re-fire the alarm before the async check lands.
  void _handleAlarmResolved(ExitAttempt attempt) {
    if (attempt == ExitAttempt.unpinned) {
      setState(() => _requiresRepin = true);
      return;
    }
    widget.kioskService.isLockTaskActive().then((isPinned) {
      if (!isPinned && mounted) setState(() => _requiresRepin = true);
    });
  }

  Widget _buildRepinBarrier() {
    return Semantics(
      label:
          'Aplikasi belum disematkan ulang. Sematkan aplikasi untuk lanjut ujian.',
      child: PinningGatekeeperScreen(
        targetExamUrl: widget.examUrl,
        kioskService: widget.kioskService,
        onPinConfirmed: () {
          if (mounted) setState(() => _requiresRepin = false);
        },
      ),
    );
  }

  Future<void> _handleExitExam() async {
    final pinController = TextEditingController();
    String? errorText;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                  Icon(Icons.lock_outline_rounded, color: scheme.secondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Otorisasi Selesai Ujian',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: scheme.onSurface),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Untuk mengakhiri sesi ujian dan membuka kunci aplikasi, pengawas wajib memasukkan PIN Pengawas.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.onSurfaceVariant,
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
    _exitAttemptSub?.cancel();
    _alarmController.removeListener(_onAlarmUpdated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return PopScope(
      canPop: false, // Disable hardware back button
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Stack(
            children: [
              // Main WebView
              Column(
                children: [
                  // Vibrant locked-session status bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      border: Border(bottom: BorderSide(color: scheme.outline)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSm),
                            boxShadow: AppTheme.primaryShadow,
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Sesi Ujian Terkunci',
                                style: textTheme.titleSmall?.copyWith(
                                  color: scheme.onSurface,
                                ),
                              ),
                              Text(
                                'Mode kunci aktif • Tetap di halaman ujian',
                                style: textTheme.labelSmall?.copyWith(
                                  color: AppTheme.isDark(context)
                                      ? AppTheme.secondaryBright
                                      : AppTheme.secondaryTextLight,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: _handleExitExam,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: scheme.surface,
                            foregroundColor: scheme.onSurface,
                            side: BorderSide(color: scheme.outlineVariant),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            minimumSize: const Size(48, 48),
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
                    LinearProgressIndicator(
                      color: AppTheme.primaryBright,
                      backgroundColor: AppTheme.primaryContainer,
                      minHeight: 3,
                    ),
                  Expanded(
                    child: _webViewController != null
                        ? WebViewWidget(controller: _webViewController!)
                        : Center(
                            child: Text(
                              'Halaman Ujian Google Form',
                              style: textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                  ),
                ],
              ),

              // Alarm Overlay
              if (_alarmController.isAlarmActive)
                Positioned.fill(
                  child: AlarmOverlayDialog(
                    alarmController: _alarmController,
                    onResolved: _handleAlarmResolved,
                  ),
                ),

              // Re-pin barrier: blocks the exam until the app is pinned again.
              // The WebView stays alive underneath so form answers are kept.
              if (_requiresRepin)
                Positioned.fill(
                  child: _buildRepinBarrier(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
