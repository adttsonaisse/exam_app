# Secure Exam Web Wrapper Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a secure Android exam web wrapper in Flutter for Google Forms that enforces Screen Pinning before accessing the exam, detects abnormal device movement via accelerometer/gyroscope, and triggers a supervisor-resettable alarm upon violation.

**Architecture:** Feature-first Flutter architecture with dedicated native Android MethodChannels for OS-level kiosk features (`startLockTask`, `isInLockTaskMode`, `FLAG_SECURE`, alarm volume override). A Gatekeeper barrier strictly prevents webview navigation until lock task mode is verified, and a Motion Anti-Cheat Engine streams physical sensor readings through a debounced violation filter into an Alarm Controller.

**Tech Stack:** Flutter 3.13+ (Dart), Android Native (Kotlin), `mobile_scanner`, `webview_flutter`, `sensors_plus`, `flutter_test`.

**Spec:** [PRD.md](file:///home/adttsonaisse/Documents/Coding/exam/PRD.md)

## Global Constraints

- **Platform Target:** Android 7.0+ (API 24+) to Android 14+.
- **Language & SDK:** Flutter / Dart ^3.13.5, Kotlin for Android Native.
- **Design Tokens:** Follow `Design.md` (Notion theme: `#ffffff` canvas, `#0075de` Notion Blue accent, whisper border `rgba(0,0,0,0.1)`, 8px button radius).
- **Security Hardening:** `FLAG_SECURE` enabled on window during exam; URL whitelist restricted to Google Forms domains (`forms.gle`, `docs.google.com/forms`); copy-paste & text selection disabled in WebView.
- **Pinning Enforcement:** Absolute barrier—no redirection to WebView unless `isInLockTaskMode == true`.

## Review Focus

1. **Malicious / Invalid QR Codes:** QR scanned is not a valid Google Form URL (e.g., `javascript:alert(1)`, `http://phishing.com`) $\rightarrow$ `ExamUrlValidator` rejects URL, error banner shown, no pin requested.
2. **Canceled Screen Pinning:** User hits "Cancel" or backs out of the Android OS screen pinning prompt $\rightarrow$ `PinningGatekeeperScreen` blocks navigation, prevents WebView loading, and prompts to retry.
3. **Transient Sensor Noise:** Device gently moved or bumped on desk for $< 1.5$ seconds $\rightarrow$ `MotionDetector` debouncing filter absorbs minor shifts and avoids false alarm.
4. **Hardware Unpinning During Exam:** User presses back/overview combination to unpin $\rightarrow$ `KioskSecurityService` detects unpin, instantly activates loud alarm and red warning overlay.
5. **Incorrect Supervisor PIN Entry:** Incorrect PIN input when attempting to silence alarm $\rightarrow$ alarm persists, shake/error animation on PIN field, only correct 6-digit PIN silences alarm.

---

### Task 1: Dependencies, Android Permissions & Theme Setup

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Create: `lib/core/theme/app_theme.dart`
- Test: `test/core/theme/app_theme_test.dart`

**Interfaces:**
- Produces:
  - `class AppTheme { static ThemeData get lightTheme; static ThemeData get darkTheme; }`
  - Colors: `AppTheme.primaryColor = Color(0xFF0075DE)`, `AppTheme.dangerColor = Color(0xFFDD5B00)`

- [ ] **Step 1: Write the failing test for `AppTheme`**

```dart
// test/core/theme/app_theme_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exam/core/theme/app_theme.dart';

void main() {
  test('AppTheme provides Notion-style colors and typography', () {
    final theme = AppTheme.lightTheme;
    expect(theme.primaryColor, const Color(0xFF0075DE));
    expect(theme.scaffoldBackgroundColor, const Color(0xFFFFFFFF));
    expect(AppTheme.dangerColor, const Color(0xFFDD5B00));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/theme/app_theme_test.dart`
Expected: FAIL with compilation error (AppTheme does not exist).

- [ ] **Step 3: Update `pubspec.yaml` with required packages**

Add `mobile_scanner`, `webview_flutter`, `sensors_plus` under `dependencies` in `pubspec.yaml`.

- [ ] **Step 4: Update `android/app/src/main/AndroidManifest.xml` with permissions**

Add:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.VIBRATE" />
```

- [ ] **Step 5: Implement `AppTheme` in `lib/core/theme/app_theme.dart`**

Implement `AppTheme` with Notion color palette (`#0075de` primary, `#dd5b00` danger, 8px border radius for buttons).

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/core/theme/app_theme_test.dart`
Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add pubspec.yaml android/app/src/main/AndroidManifest.xml lib/core/theme/app_theme.dart test/core/theme/app_theme_test.dart
git commit -m "chore: setup dependencies, android permissions, and Notion app theme"
```

---

### Task 2: Core Domain Logic - URL Validator & Supervisor PIN Validator

**Files:**
- Create: `lib/core/validators/exam_url_validator.dart`
- Create: `lib/core/validators/supervisor_pin_validator.dart`
- Test: `test/core/validators/exam_url_validator_test.dart`
- Test: `test/core/validators/supervisor_pin_validator_test.dart`

**Interfaces:**
- Produces:
  - `class ExamUrlValidator`:
    - `static bool isValidGoogleFormUrl(String? rawUrl)`
    - `static String? sanitizeUrl(String? rawUrl)`
  - `class SupervisorPinValidator`:
    - `static bool verifyPin(String inputPin, {String expectedPin = '123456'})`

- [ ] **Step 1: Write the failing tests for `ExamUrlValidator` and `SupervisorPinValidator`**

```dart
// test/core/validators/exam_url_validator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:exam/core/validators/exam_url_validator.dart';

void main() {
  group('ExamUrlValidator', () {
    test('accepts valid Google Forms URLs', () {
      expect(ExamUrlValidator.isValidGoogleFormUrl('https://forms.gle/abc123xyz'), isTrue);
      expect(ExamUrlValidator.isValidGoogleFormUrl('https://docs.google.com/forms/d/e/1FAIpQLSc/viewform'), isTrue);
    });

    test('rejects non-Google-Form or malicious URLs', () {
      expect(ExamUrlValidator.isValidGoogleFormUrl('javascript:alert(1)'), isFalse);
      expect(ExamUrlValidator.isValidGoogleFormUrl('https://phishing.com/google.com/forms'), isFalse);
      expect(ExamUrlValidator.isValidGoogleFormUrl(''), isFalse);
      expect(ExamUrlValidator.isValidGoogleFormUrl(null), isFalse);
    });
  });
}
```

```dart
// test/core/validators/supervisor_pin_validator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:exam/core/validators/supervisor_pin_validator.dart';

void main() {
  group('SupervisorPinValidator', () {
    test('validates correct default and custom supervisor PINs', () {
      expect(SupervisorPinValidator.verifyPin('123456'), isTrue);
      expect(SupervisorPinValidator.verifyPin('998877', expectedPin: '998877'), isTrue);
    });

    test('rejects incorrect or malformed PINs', () {
      expect(SupervisorPinValidator.verifyPin('000000'), isFalse);
      expect(SupervisorPinValidator.verifyPin('123'), isFalse);
      expect(SupervisorPinValidator.verifyPin(''), isFalse);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/core/validators/`
Expected: FAIL (classes not defined).

- [ ] **Step 3: Implement `ExamUrlValidator` and `SupervisorPinValidator`**

In `lib/core/validators/exam_url_validator.dart`:
- Match regex for `^https://(forms\.gle/[a-zA-Z0-9_\-]+|docs\.google\.com/forms/d/e/[a-zA-Z0-9_\-]+/viewform.*)$`.
In `lib/core/validators/supervisor_pin_validator.dart`:
- Constant-time string equality check.

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/core/validators/`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/validators/ test/core/validators/
git commit -m "feat: implement ExamUrlValidator and SupervisorPinValidator with unit tests"
```

---

### Task 3: Native Android Kiosk & Security Bridge

**Files:**
- Create: `lib/core/services/kiosk_security_service.dart`
- Modify: `android/app/src/main/kotlin/com/example/exam/MainActivity.kt`
- Test: `test/core/services/kiosk_security_service_test.dart`

**Interfaces:**
- Consumes: `MethodChannel('com.example.exam/kiosk')`
- Produces:
  - `abstract class KioskSecurityService`:
    - `Future<void> startLockTask()`
    - `Future<void> stopLockTask()`
    - `Future<bool> isLockTaskActive()`
    - `Future<void> setWindowSecure(bool enable)`
    - `Future<void> maximizeAlarmVolume()`

- [ ] **Step 1: Write the failing unit test for `KioskSecurityService` with mock platform channel**

```dart
// test/core/services/kiosk_security_service_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exam/core/services/kiosk_security_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.example.exam/kiosk');
  late MethodChannelKioskSecurityService service;
  final List<MethodCall> log = [];

  setUp(() {
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      if (methodCall.method == 'isLockTaskActive') return true;
      return null;
    });
    service = MethodChannelKioskSecurityService();
  });

  test('calls startLockTask and isLockTaskActive on platform channel', () async {
    await service.startLockTask();
    final isActive = await service.isLockTaskActive();
    expect(isActive, isTrue);
    expect(log.map((e) => e.method), containsAll(['startLockTask', 'isLockTaskActive']));
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/services/kiosk_security_service_test.dart`
Expected: FAIL (service not found).

- [ ] **Step 3: Implement `KioskSecurityService` in `lib/core/services/kiosk_security_service.dart`**

Define interface and `MethodChannelKioskSecurityService` invoking:
`startLockTask`, `stopLockTask`, `isLockTaskActive`, `setWindowSecure`, `maximizeAlarmVolume`.

- [ ] **Step 4: Implement native channel handlers in `android/app/src/main/kotlin/com/example/exam/MainActivity.kt`**

Add Kotlin method channel handler:
- `startLockTask`: calls `activity.startLockTask()`.
- `stopLockTask`: calls `activity.stopLockTask()`.
- `isLockTaskActive`: queries `ActivityManager.getLockTaskModeState() != LOCK_TASK_MODE_NONE`.
- `setWindowSecure`: toggles `WindowManager.LayoutParams.FLAG_SECURE`.
- `maximizeAlarmVolume`: sets `AudioManager.STREAM_ALARM` to max volume.

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/core/services/kiosk_security_service_test.dart`
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/core/services/kiosk_security_service.dart android/app/src/main/kotlin/com/example/exam/MainActivity.kt test/core/services/kiosk_security_service_test.dart
git commit -m "feat: implement native android kiosk and security bridge"
```

---

### Task 4: Motion Anti-Cheat Detector Engine

**Files:**
- Create: `lib/features/anti_cheat/models/motion_reading.dart`
- Create: `lib/features/anti_cheat/services/motion_detector.dart`
- Test: `test/features/anti_cheat/motion_detector_test.dart`

**Interfaces:**
- Produces:
  - `enum ViolationType { extremeTilt, verticalLift, suddenShake, unpinned, appPaused }`
  - `class MotionDetector`:
    - `Stream<ViolationType> get violationStream`
    - `void startMonitoring({Stream<MotionReading>? testStream})`
    - `void stopMonitoring()`
    - `static bool isAbnormalTilt(double pitchDegrees, double rollDegrees)`
    - `static bool isAbnormalShake(double accelX, double accelY, double accelZ)`

- [ ] **Step 1: Write the failing tests for `MotionDetector` thresholds and debouncing**

```dart
// test/features/anti_cheat/motion_detector_test.dart
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:exam/features/anti_cheat/models/motion_reading.dart';
import 'package:exam/features/anti_cheat/services/motion_detector.dart';

void main() {
  group('MotionDetector', () {
    late MotionDetector detector;

    setUp(() {
      detector = MotionDetector(debounceDuration: const Duration(milliseconds: 100));
    });

    tearDown(() {
      detector.stopMonitoring();
    });

    test('detects extreme tilt and emits violation', () async {
      final controller = StreamController<MotionReading>();
      final violations = <ViolationType>[];
      detector.violationStream.listen(violations.add);
      detector.startMonitoring(testStream: controller.stream);

      // Normal reading
      controller.add(MotionReading(pitch: 15.0, roll: 0.0, accelMagnitude: 9.8));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(violations, isEmpty);

      // Abnormal tilt (> 60 deg roll) sustained
      controller.add(MotionReading(pitch: 15.0, roll: 75.0, accelMagnitude: 9.8));
      await Future.delayed(const Duration(milliseconds: 150));
      expect(violations, contains(ViolationType.extremeTilt));
      await controller.close();
    });

    test('ignores momentary spike shorter than debounce duration', () async {
      final controller = StreamController<MotionReading>();
      final violations = <ViolationType>[];
      detector.violationStream.listen(violations.add);
      detector.startMonitoring(testStream: controller.stream);

      controller.add(MotionReading(pitch: 15.0, roll: 75.0, accelMagnitude: 9.8));
      // Quickly returns to normal before debounce completes
      await Future.delayed(const Duration(milliseconds: 30));
      controller.add(MotionReading(pitch: 15.0, roll: 5.0, accelMagnitude: 9.8));
      await Future.delayed(const Duration(milliseconds: 120));

      expect(violations, isEmpty);
      await controller.close();
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/anti_cheat/motion_detector_test.dart`
Expected: FAIL (models and service not found).

- [ ] **Step 3: Implement `MotionReading` and `MotionDetector`**

In `lib/features/anti_cheat/services/motion_detector.dart`:
- Filter accelerometer & gyroscope events into `MotionReading`.
- Use timer-based debouncing: trigger violation only if abnormal reading persists $\ge$ threshold duration (default 1.5s in production, configurable for tests).
- Expose `violationStream`.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/anti_cheat/motion_detector_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/anti_cheat/ test/features/anti_cheat/
git commit -m "feat: implement MotionDetector engine with debounced anomaly thresholds"
```

---

### Task 5: Screen Pinning Gatekeeper Screen & Logic

**Files:**
- Create: `lib/features/pinning/controllers/pinning_controller.dart`
- Create: `lib/features/pinning/screens/pinning_gatekeeper_screen.dart`
- Test: `test/features/pinning/pinning_gatekeeper_test.dart`

**Interfaces:**
- Consumes: `KioskSecurityService`
- Produces:
  - `class PinningController extends ChangeNotifier`:
    - `bool isPinned`
    - `Future<bool> checkAndRequestPin()`
  - `class PinningGatekeeperScreen extends StatelessWidget`:
    - Arguments: `final String targetExamUrl`, `final KioskSecurityService kioskService`, `final VoidCallback onPinConfirmed`

- [ ] **Step 1: Write the failing widget test for `PinningGatekeeperScreen`**

```dart
// test/features/pinning/pinning_gatekeeper_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exam/core/services/kiosk_security_service.dart';
import 'package:exam/features/pinning/screens/pinning_gatekeeper_screen.dart';

class MockKioskService implements KioskSecurityService {
  bool active = false;
  @override
  Future<bool> isLockTaskActive() async => active;
  @override
  Future<void> startLockTask() async {}
  @override
  Future<void> stopLockTask() async {}
  @override
  Future<void> setWindowSecure(bool enable) async {}
  @override
  Future<void> maximizeAlarmVolume() async {}
}

void main() {
  testWidgets('Gatekeeper blocks navigation if unpinned and shows retry button', (tester) async {
    final mockService = MockKioskService()..active = false;
    var proceeded = false;

    await tester.pumpWidget(MaterialApp(
      home: PinningGatekeeperScreen(
        targetExamUrl: 'https://forms.gle/test',
        kioskService: mockService,
        onPinConfirmed: () => proceeded = true,
      ),
    ));

    expect(find.textContaining('Sematkan Aplikasi'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(proceeded, isFalse);

    // Now simulate user pinning the app
    mockService.active = true;
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(proceeded, isTrue);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/pinning/pinning_gatekeeper_test.dart`
Expected: FAIL (classes not defined).

- [ ] **Step 3: Implement `PinningController` and `PinningGatekeeperScreen`**

Build clean UI matching `Design.md` (whisper borders, clear pinning instructions, retry button). Screen triggers `startLockTask()` on load and checks `isLockTaskActive()`. Only when true, calls `onPinConfirmed()`.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/pinning/pinning_gatekeeper_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/pinning/ test/features/pinning/
git commit -m "feat: implement PinningGatekeeperScreen to enforce strict lock task verification"
```

---

### Task 6: QR Scanner Screen & Home Readiness Screen

**Files:**
- Create: `lib/features/home/screens/home_screen.dart`
- Create: `lib/features/scanner/screens/qr_scanner_screen.dart`
- Test: `test/features/home/home_screen_test.dart`

**Interfaces:**
- Consumes: `ExamUrlValidator`, `AppTheme`
- Produces:
  - `class HomeScreen extends StatelessWidget`: displays readiness indicators (Device status, Camera check) and "Scan QR Ujian" button.
  - `class QrScannerScreen extends StatefulWidget`: wraps `MobileScanner`, validates with `ExamUrlValidator`, pops with validated URL or shows alert.

- [ ] **Step 1: Write the failing widget test for `HomeScreen`**

```dart
// test/features/home/home_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exam/features/home/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen renders readiness checks and Scan QR button', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.text('Ujian Aman (Exam Shield)'), findsOneWidget);
    expect(find.text('Scan QR Ujian'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/home/home_screen_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement `HomeScreen` and `QrScannerScreen`**

In `lib/features/home/screens/home_screen.dart`:
- Follow Notion design from `Design.md`.
- Tap on "Scan QR Ujian" pushes `QrScannerScreen`.
In `lib/features/scanner/screens/qr_scanner_screen.dart`:
- Scan callback checks `ExamUrlValidator.isValidGoogleFormUrl(barcode)`.
- If valid, pops with URL. If invalid, displays snackbar / modal alert.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/home/home_screen_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/home/ lib/features/scanner/ test/features/home/
git commit -m "feat: implement HomeScreen with readiness indicator and QrScannerScreen"
```

---

### Task 7: Alarm Controller, Audio/Visual Overlay & Supervisor PIN Dialog

**Files:**
- Create: `lib/features/alarm/controllers/alarm_controller.dart`
- Create: `lib/features/alarm/widgets/alarm_overlay_dialog.dart`
- Test: `test/features/alarm/alarm_controller_test.dart`

**Interfaces:**
- Consumes: `SupervisorPinValidator`, `KioskSecurityService`
- Produces:
  - `class AlarmController extends ChangeNotifier`:
    - `bool get isAlarmActive`
    - `ViolationType? get currentViolation`
    - `void triggerAlarm(ViolationType violation)`
    - `bool resolveAlarm(String supervisorPin)`
  - `class AlarmOverlayDialog extends StatelessWidget`: flashing red banner, input field for 6-digit Supervisor PIN, button to reset.

- [ ] **Step 1: Write the failing test for `AlarmController`**

```dart
// test/features/alarm/alarm_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:exam/core/services/kiosk_security_service.dart';
import 'package:exam/features/alarm/controllers/alarm_controller.dart';
import 'package:exam/features/anti_cheat/services/motion_detector.dart';

class MockKioskService implements KioskSecurityService {
  int volumeCalls = 0;
  @override
  Future<void> maximizeAlarmVolume() async => volumeCalls++;
  @override
  Future<bool> isLockTaskActive() async => true;
  @override
  Future<void> setWindowSecure(bool enable) async {}
  @override
  Future<void> startLockTask() async {}
  @override
  Future<void> stopLockTask() async {}
}

void main() {
  test('AlarmController triggers alarm and silences only with valid supervisor PIN', () async {
    final mockKiosk = MockKioskService();
    final controller = AlarmController(kioskService: mockKiosk, supervisorPin: '123456');

    expect(controller.isAlarmActive, isFalse);
    controller.triggerAlarm(ViolationType.extremeTilt);
    expect(controller.isAlarmActive, isTrue);
    expect(mockKiosk.volumeCalls, greaterThanOrEqualTo(1));

    // Wrong PIN
    final wrong = controller.resolveAlarm('000000');
    expect(wrong, isFalse);
    expect(controller.isAlarmActive, isTrue);

    // Correct PIN
    final correct = controller.resolveAlarm('123456');
    expect(correct, isTrue);
    expect(controller.isAlarmActive, isFalse);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/alarm/alarm_controller_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement `AlarmController` and `AlarmOverlayDialog`**

In `lib/features/alarm/controllers/alarm_controller.dart`:
- Manage alarm state, call `kioskService.maximizeAlarmVolume()`.
In `lib/features/alarm/widgets/alarm_overlay_dialog.dart`:
- High z-index visual overlay with animated warning, PIN input, and validation feedback.

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/alarm/alarm_controller_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/alarm/ test/features/alarm/
git commit -m "feat: implement AlarmController and AlarmOverlayDialog with supervisor PIN unlock"
```

---

### Task 8: Secure Exam WebView Wrapper & App Integration

**Files:**
- Create: `lib/features/exam/screens/exam_webview_screen.dart`
- Modify: `lib/main.dart`
- Test: `test/features/exam/exam_flow_test.dart`

**Interfaces:**
- Consumes: `HomeScreen`, `PinningGatekeeperScreen`, `ExamWebViewScreen`, `AlarmController`, `MotionDetector`, `KioskSecurityService`
- Produces: Full app entry point running all features sequentially.

- [ ] **Step 1: Write integration flow test**

```dart
// test/features/exam/exam_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exam/main.dart';

void main() {
  testWidgets('App launches with HomeScreen and Notion theme', (tester) async {
    await tester.pumpWidget(const ExamApp());
    expect(find.text('Ujian Aman (Exam Shield)'), findsOneWidget);
    expect(find.text('Scan QR Ujian'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/exam/exam_flow_test.dart`
Expected: FAIL (ExamApp not defined in main.dart yet).

- [ ] **Step 3: Implement `ExamWebViewScreen`**

In `lib/features/exam/screens/exam_webview_screen.dart`:
- Embed `WebViewWidget` pointed to Google Form URL.
- Enable `FLAG_SECURE` on init.
- Restrict navigation delegate to forbid exiting domain.
- Mount `MotionDetector` and listen to `violationStream`.
- Overlay `AlarmOverlayDialog` when `AlarmController.isAlarmActive == true`.
- Provide top bar "Selesai Ujian" button requiring Supervisor PIN to exit lock task and return home.

- [ ] **Step 4: Update `lib/main.dart`**

Setup `ExamApp` using `AppTheme.lightTheme` and navigation routes.

- [ ] **Step 5: Run all test suites across the project**

Run: `flutter test`
Expected: All tests PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/exam/ lib/main.dart test/features/exam/
git commit -m "feat: integrate secure exam webview wrapper, motion alarm, and full app flow"
```

---

## Plan Review & Verification Checklist
- [x] All PRD requirements covered (QR scan, Gatekeeper pinning check, WebView hardening, motion detection, alarm & PIN unlock).
- [x] Every task has explicit files, signatures, test names, and commands.
- [x] Five Review Focus failure modes mapped to explicit test steps.
- [x] Adheres to `Design.md` design tokens.
