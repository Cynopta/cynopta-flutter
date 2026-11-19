//
//  CynoptaFlutterPlugin.swift
//  cynopta_flutter
//
//  Copyright © 2026 Cynopta Ltd. All rights reserved.
//

import Flutter
import UIKit
import CynoptaAppKit

/// The iOS side of the `com.cynopta.sdk/trust` channel. As on Android, the SDK serves the channel (`CynoptaBridge`, the
/// counterpart of Android's `CynoptaFlutterBridge`) and starts itself the way Android's does at launch
/// (`Cynopta.autoStart()`); this class only connects the two. The SDK reads the license from the app's Flutter assets
/// (`cynopta.json` or `assets/cynopta.json`, declared in pubspec.yaml) or from the app bundle.
public class CynoptaFlutterPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: CynoptaBridge.channelName, binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(CynoptaFlutterPlugin(), channel: channel)
        // Once per engine; the SDK starts only once.
        Cynopta.autoStart()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        CynoptaBridge.handle(method: call.method, arguments: call.arguments) { reply in
            switch reply {
            case .success(let value):
                result(Self.flutterValue(value))
            case .error(let code, let message):
                result(FlutterError(code: code, message: message, details: nil))
            case .notImplemented:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    /// Data as Uint8List: the sealed packet `d`, which Dart reads as bytes.
    static func flutterValue(_ value: Any?) -> Any? {
        guard let map = value as? [String: Any] else {
            return value
        }
        return map.mapValues { value -> Any in
            if let data = value as? Data {
                return FlutterStandardTypedData(bytes: data)
            }
            return value
        }
    }
}
