# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users

- **Siswa / Peserta Ujian (primary):** Indonesian school students on their own Android smartphones (BYOD). Situation: in-classroom digital exam; job: open app → scan QR → confirm pin → work the Google Form without interruption or distraction.
- **Guru / Pengawas Ujian:** Teacher/invigilator controlling the exam room. Job: gain certainty no student opens other apps/tabs; respond physically to a loud alarm when a violation occurs; enter the Supervisor PIN to silence/reset the alarm or to authorize exam exit.

## Product Purpose

Secure wrapper around unmodified Google Forms that locks the exam inside a verified Android kiosk (Lock Task / Screen Pinning), detects suspicious physical device movement via onboard sensors, and raises an immediate room-audible alarm that only a supervisor can reset. Success means exams run on student-owned phones with no unpinned access to form content, no silent bypass, and no lost answers when an alarm fires.

## Positioning

Ordinary free exam browsers and kiosk wrappers can be bypassed by cancelling the Screen Pinning dialog (notably on MIUI, ColorOS, OneUI, FuntouchOS vendor ROMs) and have no answer for physical cheating gestures. This product's mechanism a neighboring wrapper could not truthfully copy: an absolute Gatekeeper barrier that never opens the WebView until `isInLockTaskMode == true`, combined with a debounced physical Motion Anti-Cheat Engine (tilt / lift / shake / flip) wired to a supervisor-PIN-only alarm — all as a standalone client configured by QR code with no backend.

## Operating Context

- Workflow: Home readiness check (camera permission, battery, internet) → tap Scan QR Ujian → camera scans QR on board/desk → URL validation → Screen Pinning request → Gatekeeper hold-or-pass → locked exam session with sensors active → Submit in Google Form → Selesai Ujian → supervisor PIN unpins and returns to Home.
- Environment: Indonesian school exam rooms; dim lighting possible (scanner flash toggle); devices rest on desks at roughly 0–35° baseline tilt.
- Tools and materials: student-owned Android phones across vendor ROMs; Google Forms (including forms requiring school-account login); supervisor-held 6-digit PIN; QR code carrying the exam URL.
- Rituals: supervisor physically walks to the alarming desk, verifies the situation, enters PIN; every alarm incident is logged locally with timestamp, anomaly type, and duration.

## Capabilities and Constraints

- **FR-1 Home & QR scan:** readiness indicators (camera, battery <20% warning, internet Wi-Fi/cellular); `mobile_scanner`-based QR scan with flash toggle; URL sanitization restricted to `forms.gle` and `docs.google.com/forms` (plus registered school form domains); invalid/phishing/`javascript:` URLs rejected with warning, no pin requested.
- **FR-2 Pinning Gatekeeper (absolute barrier):** native `startLockTask()` via `MethodChannel('com.example.exam/kiosk')`; `ActivityManager.isInLockTaskMode()` (PINNED/LOCKED) checked before any WebView navigation; unpinned/cancelled state holds on a warning screen with retry ("Coba Sematkan Lagi"); confirmed in interview: v1 behavior only.
- **FR-3 Secure WebView:** isolated `webview_flutter` with no address bar or free navigation; `FLAG_SECURE` on during session (black screen on screenshot/recording/task-switcher preview); text selection, long-press context menu, and drag-and-drop disabled; `target="_blank"` / `window.open()` blocked; Google-account login and cookies preserved for school-domain forms.
- **FR-4 Motion detection (fixed thresholds, confirmed):** accelerometer + gyroscope via `sensors_plus` at UI/Normal rate (~20–50 Hz); baseline calibrated at session start; extreme tilt roll >60°, vertical lift 75–90°, sudden shake >2.5g, face-down flip; debounce/smoothing requires persistence (~1.5 s production) so momentary bumps do not alarm; detection-to-alarm latency <500 ms; WebView state never reloads away student answers.
- **FR-5 Alarm & violation handling:** triggers are abnormal motion, unpin attempt (`isInLockTaskMode` → false), and app backgrounding (`paused`/`inactive`); response is max-volume siren via `STREAM_ALARM`/`STREAM_MUSIC` override (ignores silent mode), flashing red full-screen warning in Indonesian, continuous vibration; silencing requires the Supervisor PIN only; wrong PIN keeps the alarm with field-level error feedback.
- **FR-6 Supervisor mode & exit:** static configurable 6-digit Supervisor PIN (default `123456`, teacher-editable on Home; confirmed in interview — no QR-embedded PIN in v1); Submit → Selesai Ujian → supervisor PIN required for `stopLockTask()` and return Home.
- **Technical constraints:** Android 7.0 (API 24) through Android 14+; vendor-ROM pinning-dialog-cancel behavior assumed hostile; offline WebView shows a friendly banner without destroying form content; USB-debugging/developer-options detection is optional warning only.
- **Non-goals (v1):** not a question CMS (Google Forms remains content source and answer store); does not fully replace human invigilators; standalone client, no server backend.
- **Explicitly out of scope for v1 (confirmed):** front-camera face-presence detection; adjustable Low/Medium/High motion sensitivity; QR-embedded supervisor PIN.

## Brand Commitments

- Name: Exam Shield / Secure Exam Wrapper (PRD v1.0.0 draft).
- Voice: Indonesian-language school exam UI (e.g. "Scan QR Ujian", "Sematkan Aplikasi", "Selesai Ujian"); calm, minimal-distraction Notion-style direction per PRD §8.
- Binding references: PRD.md and docs/superpowers/plans/2026-10-13-secure-exam-wrapper.md are the agreed product authorities. Existing Design.md left untouched by init; visual-world decisions belong to later new-work/document work, not this record.

## Evidence on Hand

- PRD: `PRD.md` (Secure Exam Web Wrapper v1.0.0, FR-1–FR-6, risk table, open questions since resolved by interview above).
- Implementation: `lib/main.dart` (`ExamApp` three-stage flow: Home → PinningGatekeeper → ExamWebView), `lib/core/validators/`, `lib/core/services/kiosk_security_service.dart`, `lib/core/theme/app_theme.dart`, `lib/features/{home,scanner,pinning,exam,alarm,anti_cheat}/`.
- Plan: `docs/superpowers/plans/2026-10-13-secure-exam-wrapper.md` (8 tasks, review-focus failure modes).
- Dependencies: `mobile_scanner`, `webview_flutter`, `sensors_plus` (per `pubspec.yaml`).
- Absences future work must not fabricate: no production QR samples, no registered school domains beyond Google Forms defaults, no testimonials, customers, benchmarks, or deployment claims.

## Product Principles

1. **Unpinned means unopened.** No exam content renders until the OS itself confirms lock-task mode; a cancellable system dialog is treated as hostile, never as consent.
2. **Aid the invigilator, never replace them.** The alarm identifies the desk; the human judges the situation and holds the only key (Supervisor PIN).
3. **Sensitive but not twitchy.** Detection favors debounced persistence over instant reaction so an ordinary bump never disrupts the whole room.
4. **Answers outlive alarms.** No violation, vibration, overlay, or connectivity loss may discard or reload away a student's form state.
5. **Standalone simplicity for exam day.** QR in, PIN out, no backend to provision — the room must be runnable from a whiteboard QR and a memorized PIN.

## Accessibility & Inclusion

- Alarm is tri-modal (max-volume siren, flashing red Indonesian-language banner, continuous vibration) so a violation is perceivable across a noisy classroom.
- Scanner provides a flash toggle for dim rooms; Home warns on low battery (<20%) and shows connectivity state before the exam starts.
- Must run across student-owned Android 7.0–14+ devices and vendor ROMs with 44px+ touch targets; no product-specific formal standard (e.g. WCAG) has been adopted.
