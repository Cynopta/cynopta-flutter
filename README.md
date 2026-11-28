# cynopta_flutter

Flutter plugin for the **Cynopta SDK**.

Automatically pulls in the native Cynopta SDKs — Android (`com.github.Cynopta:android-sdk-dist`) and iOS (`github.com/Cynopta/ios-sdk-dist`, through Swift Package Manager) — and packages your `cynopta.json` license file. **No native Kotlin/Java, Swift, Gradle, Podfile or Xcode edits required.**

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

- **Minimum iOS:** 13.0.
- **Swift Package Manager only:** the plugin supports iOS through Swift Package Manager, Flutter's default. Other plugins can keep using CocoaPods in the same app. If your app has Swift Package Manager turned off, the iOS build stops with "The following plugin(s) are only compatible with Swift Package Manager: cynopta_flutter"; turn it back on with `flutter config --enable-swift-package-manager`, or remove `enable-swift-package-manager: false` from your `pubspec.yaml` (see [Swift Package Manager for app developers](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers)).
- **SDK:** Cynopta iOS SDK 1.0.26, from [`Cynopta/ios-sdk-dist`](https://github.com/Cynopta/ios-sdk-dist); Xcode downloads it on the first build.
- **App Store:** what the SDK reads and sends, the App Privacy answers and a paragraph for App Review's notes are in the ["Privacy and App Review" section](https://github.com/Cynopta/ios-sdk-dist#3-privacy-and-app-review) of `ios-sdk-dist`'s README.
- **Startup:** the SDK starts itself when the app finishes launching, unless `cynopta.json` sets `"autoStart": false` or the app called `Cynopta.stop()` (then it waits for `Cynopta.start()`, across launches), as on Android.
- **Permissions:** none requested, and the SDK doesn't use location. Optional: to let the SDK refresh in the background, add `com.cynopta.sdk.refresh` to `BGTaskSchedulerPermittedIdentifiers` and `processing` to `UIBackgroundModes` in `ios/Runner/Info.plist`. Without them the SDK simply doesn't register the task.

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
