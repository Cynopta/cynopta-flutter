# cynopta_flutter

Pure-Dart Flutter client for the **Cynopta Behavioral Biometrics & Bot Detection SDK**.

## Setup

### 1. Android Gradle & License Configuration
1. Place your signed `cynopta.json` license inside `android/app/src/main/assets/cynopta.json`.
2. Add the JitPack Maven repository in `android/build.gradle.kts` (or `android/settings.gradle.kts`):
   ```kotlin
   allprojects {
       repositories {
           google()
           mavenCentral()
           maven { url = uri("https://jitpack.io") }
       }
   }
   ```
3. Add the Cynopta Android SDK dependency in `android/app/build.gradle.kts`:
   ```kotlin
   dependencies {
       implementation("com.github.Cynopta:android-sdk-dist:1.0.18")
   }
   ```
   *(Zero changes to `MainActivity.kt` are required — `CynoptaInitializer` and `CynoptaFlutterBridge` attach automatically).*

### 2. Add the Dart Package
```bash
flutter pub add cynopta_flutter --git-url=https://github.com/Cynopta/cynopta-flutter.git --git-ref=v1.0.18
```
Or in `pubspec.yaml`:
```yaml
dependencies:
  cynopta_flutter:
    git:
      url: https://github.com/Cynopta/cynopta-flutter.git
      ref: v1.0.18
```

### 3. Usage in Dart
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
```
