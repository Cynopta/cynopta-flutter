import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/services.dart';

/// Immutable result of offline cryptographic license verification (`cynopta.json`).
class CynoptaLicenseResult {
  /// Whether the host application package and signature are authorized.
  final bool isAuthorized;

  /// Stage-1 license verification status (`Authorized`, `MissingAsset`, `Expired`, etc.).
  final String status;

  /// Human-readable verification diagnostic message.
  final String reason;

  /// Creates an immutable [CynoptaLicenseResult].
  const CynoptaLicenseResult({
    required this.isAuthorized,
    required this.status,
    required this.reason,
  });

  /// Deserializes a [CynoptaLicenseResult] from the native MethodChannel map.
  factory CynoptaLicenseResult.fromMap(Map<Object?, Object?> map) {
    return CynoptaLicenseResult(
      isAuthorized: map['isAuthorized'] as bool? ?? false,
      status: map['status'] as String? ?? 'Unknown',
      reason: map['reason'] as String? ?? '',
    );
  }
}

/// Immutable result of a Cynopta Point-of-Transaction trust evaluation.
class TrustEvaluation {
  /// Combined trust score in `[0.0, 1.0]` (`1.0` = highest trust).
  final double score;

  /// Trust classification (`VERIFIED_HUMAN`, `PROVISIONAL_NEW_DEVICE`,
  /// `SUSPICIOUS_AUTOMATION`, `SESSION_HIJACK_RISK`, or `SYNTHETIC_BOT_FARM`).
  final String classification;

  /// Longitudinal 6-pillar human realness score in `[0.0, 1.0]`.
  final double deviceRealnessScore;

  /// Real-time session bot probability in `[0.0, 1.0]` (`1.0` = highest bot risk).
  final double sessionBotRisk;

  /// Triggered threat and anomaly codes (e.g., `SYNTHETIC_INJECTION_DETECTED`).
  final List<String> reasons;

  /// Cryptographically signed JWS-compact attestation token (`ECDSA P-256`)
  /// suitable for the `X-Cynopta-Attestation` backend HTTP header.
  final String attestationPayload;

  /// Evaluation wall-clock timestamp in epoch milliseconds.
  final int timestamp;

  /// Native on-device evaluation latency in milliseconds.
  final int evaluationLatencyMs;

  /// Action label bound to this evaluation (e.g., `USER_LOGIN`, `WIRE_TRANSFER`).
  final String actionName;

  /// Creates an immutable [TrustEvaluation].
  const TrustEvaluation({
    required this.score,
    required this.classification,
    required this.deviceRealnessScore,
    required this.sessionBotRisk,
    required this.reasons,
    required this.attestationPayload,
    required this.timestamp,
    required this.evaluationLatencyMs,
    required this.actionName,
  });

  /// Deserializes a [TrustEvaluation] from the native MethodChannel map.
  factory TrustEvaluation.fromMap(Map<Object?, Object?> map) {
    final rawReasons = map['reasons'] as List<Object?>? ?? const [];
    return TrustEvaluation(
      score: (map['score'] as num?)?.toDouble() ?? 0.5,
      classification:
          map['classification'] as String? ?? 'PROVISIONAL_NEW_DEVICE',
      deviceRealnessScore:
          (map['deviceRealnessScore'] as num?)?.toDouble() ?? 0.5,
      sessionBotRisk: (map['sessionBotRisk'] as num?)?.toDouble() ?? 0.0,
      reasons: rawReasons.map((e) => e.toString()).toList(growable: false),
      attestationPayload: map['attestationPayload'] as String? ?? '',
      timestamp: (map['timestamp'] as num?)?.toInt() ?? 0,
      evaluationLatencyMs: (map['evaluationLatencyMs'] as num?)?.toInt() ?? 0,
      actionName: map['actionName'] as String? ?? 'ACTION_DEFAULT',
    );
  }
}

/// Top-level Flutter facade for the Cynopta SDK (Android & iOS).
///
/// Communicates with the zero-code native `CynoptaFlutterBridge` over the
/// `com.cynopta.sdk/trust` [MethodChannel].
class Cynopta {
  static const MethodChannel _channel = MethodChannel('com.cynopta.sdk/trust');

  const Cynopta._();

  static bool get _isSupportedMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  /// Starts or resumes background behavioral collection (if previously stopped).
  static Future<void> start() async {
    if (!_isSupportedMobile) return;
    try {
      await _channel.invokeMethod<void>('start');
    } on MissingPluginException {
      // Native SDK not linked on this platform yet.
    }
  }

  /// Stops behavioral collection and optionally wipes all persisted on-device state.
  static Future<void> stop({bool deleteAllData = false}) async {
    if (!_isSupportedMobile) return;
    try {
      await _channel.invokeMethod<void>(
        'stop',
        {'deleteAllData': deleteAllData},
      );
    } on MissingPluginException {
      // Native SDK not linked on this platform yet.
    }
  }

  /// Returns `true` if the native Cynopta SDK is actively collecting and authorized.
  static Future<bool> isStarted() async {
    if (!_isSupportedMobile) return false;
    try {
      return await _channel.invokeMethod<bool>('isStarted') ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Returns `true` if `assets/cynopta.json` passed offline cryptographic verification.
  static Future<bool> isAuthorized() async {
    if (!_isSupportedMobile) return false;
    try {
      return await _channel.invokeMethod<bool>('isAuthorized') ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Returns the detailed Stage-1 offline license verification result.
  static Future<CynoptaLicenseResult?> getLicenseResult() async {
    if (!_isSupportedMobile) return null;
    try {
      final map = await _channel.invokeMapMethod<Object?, Object?>(
        'getLicenseResult',
      );
      if (map == null) return null;
      return CynoptaLicenseResult.fromMap(map);
    } on MissingPluginException {
      return null;
    }
  }

  /// Returns the native Cynopta SDK semantic version string (e.g. `"1.0.18"`).
  static Future<String> getVersionName() async {
    if (!_isSupportedMobile) return '';
    try {
      return await _channel.invokeMethod<String>('getVersionName') ?? '';
    } on MissingPluginException {
      return '';
    }
  }

  /// Returns the native Cynopta SDK integer version code.
  static Future<int> getVersionCode() async {
    if (!_isSupportedMobile) return 0;
    try {
      return await _channel.invokeMethod<int>('getVersionCode') ?? 0;
    } on MissingPluginException {
      return 0;
    }
  }

  /// Performs a Point-of-Transaction trust evaluation bound to [actionName].
  static Future<TrustEvaluation> evaluateActionTrust([
    String actionName = 'ACTION_DEFAULT',
  ]) async {
    if (!_isSupportedMobile) {
      return TrustEvaluation.fromMap({'actionName': actionName});
    }
    try {
      final map = await _channel.invokeMapMethod<Object?, Object?>(
        'evaluateActionTrust',
        {'actionName': actionName},
      );
      return TrustEvaluation.fromMap(map ?? {'actionName': actionName});
    } on MissingPluginException {
      return TrustEvaluation.fromMap({'actionName': actionName});
    }
  }

  /// Returns the most recent cached [TrustEvaluation], or triggers a default evaluation.
  static Future<TrustEvaluation> getLatestTrustEvaluation() async {
    if (!_isSupportedMobile) {
      return TrustEvaluation.fromMap(const {});
    }
    try {
      final map = await _channel.invokeMapMethod<Object?, Object?>(
        'getLatestTrustEvaluation',
      );
      return TrustEvaluation.fromMap(map ?? const {});
    } on MissingPluginException {
      return TrustEvaluation.fromMap(const {});
    }
  }
}
