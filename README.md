# cynopta_flutter

Flutter plugin for the **Cynopta SDK**.

Automatically bundles the native Cynopta SDKs — Android (`com.github.Cynopta:android-sdk-dist`) and iOS (binary xcframeworks inside the plugin) — and packages your `cynopta.json` license file. **No native Kotlin/Java, Swift, Gradle, Podfile or Xcode edits required.**

## Setup (2 Steps)

### 1. Add the Flutter Plugin
```bash
flutter pub add cynopta_flutter --git-url=https://github.com/Cynopta/cynopta-flutter.git --git-ref=v1.0.23
```
Or in `pubspec.yaml`:
```yaml
dependencies:
  cynopta_flutter:
    git:
      url: https://github.com/Cynopta/cynopta-flutter.git
      ref: v1.0.23
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

### 3. iOS: Declare `cynopta.json` as a Flutter Asset
Android picks up the root `cynopta.json` by itself. On iOS, add it to the `assets` in your `pubspec.yaml` so Flutter bundles it into the app:

```yaml
flutter:
  assets:
    - cynopta.json
```

(A `cynopta.json` inside an asset folder you already declare, such as `assets/cynopta.json` under `- assets/`, works too.) The license must list your iOS bundle ID.

---

## iOS Details

- **Minimum iOS:** 13.0. Works with Swift Package Manager (Flutter's default) and CocoaPods.
- **Bundled SDK:** Cynopta iOS SDK 1.0.24 (build 25), as binary xcframeworks; each carries its `NOTICE` and privacy manifest.
- **Startup:** the SDK starts itself when the plugin registers, unless `cynopta.json` sets `"autoStart": false` or the app called `Cynopta.stop()` (then it waits for `Cynopta.start()`, across launches), as on Android.
- **Permissions:** none requested. Optional: to let the SDK refresh in the background, add `com.cynopta.sdk.refresh` to `BGTaskSchedulerPermittedIdentifiers` and `processing` to `UIBackgroundModes` in `ios/Runner/Info.plist`. Without them the SDK simply doesn't register the task.
- **Sealed scores:** as on Android, scores cross the platform channel only as a sealed packet that the plugin opens natively, so a hooked channel can't fake them.

---

## Usage in Dart
```dart
import 'package:cynopta_flutter/cynopta_flutter.dart';

Future<void> verifyCheckout() async {
  final eval = await Cynopta.evaluateActionTrust('CHECKOUT_SUBMIT');
  if (eval.score < 0) {
    // License or lease inactive (-1.00): apply your fallback policy
  } else if (eval.score < 0.35) {
    // Trigger MFA or block request
  } else {
    // Forward eval.attestationPayload in the X-Cynopta-Attestation header
  }
}

// Optional: toggle periodic telemetry reporting at runtime
await Cynopta.setReportingEnabled(true);
final isReporting = await Cynopta.isReportingEnabled();
```
