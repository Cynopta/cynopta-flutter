## Unreleased (ios branch)

* Added iOS support: the plugin bundles the Cynopta iOS SDK 1.0.24 (build 25) as binary xcframeworks, for Swift Package Manager and CocoaPods hosts.
* iOS uses the same `com.cynopta.sdk/trust` channel and sealed score packet as Android; the Dart client now opens it on both platforms (`cf0`, found in the process on iOS).
* On iOS, declare `cynopta.json` as a Flutter asset.

## 1.0.23

* Updated Cynopta Android SDK dependency to `1.0.23`.

## 1.0.22

* Updated Cynopta Android SDK dependency to `1.0.22`.
