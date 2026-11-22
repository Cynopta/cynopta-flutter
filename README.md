# cynopta_flutter

Flutter plugin for the **Cynopta SDK**.

Automatically bundles the native Cynopta SDK (`com.github.Cynopta:android-sdk-dist`) and packages your root `cynopta.json` license file — **zero native Kotlin/Java or Gradle edits required**.

## Setup (2 Steps)

### 1. Add the Flutter Plugin
```bash
flutter pub add cynopta_flutter --git-url=https://github.com/Cynopta/cynopta-flutter.git --git-ref=v1.0.24
```
Or in `pubspec.yaml`:
```yaml
dependencies:
  cynopta_flutter:
    git:
      url: https://github.com/Cynopta/cynopta-flutter.git
      ref: v1.0.24
```

### 2. Place `cynopta.json` in Your Flutter Project Root
Place the `cynopta.json` file provided by Cynopta in the **root of your Flutter project** (right next to `pubspec.yaml`):

```text
your_flutter_app/
├── pubspec.yaml
├── cynopta.json      <-- Place here (auto-bundled at build time)
└── lib/
    └── main.dart
```

---

## Usage in Dart
```dart
import 'package:cynopta_flutter/cynopta_flutter.dart';

Future<void> verifyCheckout() async {
  final eval = await Cynopta.evaluateActionTrust('CHECKOUT_SUBMIT');
  if (eval.score < 0.35) {
    // Trigger MFA or block request
  } else {
    // Forward eval.attestationPayload in the X-Cynopta-Attestation header
  }
}

// Optional: toggle periodic telemetry reporting at runtime
await Cynopta.setReportingEnabled(true);
final isReporting = await Cynopta.isReportingEnabled();
```
