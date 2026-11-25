import 'dart:ffi';
import 'dart:math' show Random;
import 'dart:typed_data' show ByteData, Endian;

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/services.dart';

typedef _NativeEvalFn = Uint64 Function(
  Uint64,
  Uint64,
  Uint64,
  Uint64,
  Uint64,
  Uint64,
);
typedef _DartEvalFn = int Function(int, int, int, int, int, int);

/// Immutable result of license verification (`cynopta.json`).
class CynoptaLicenseResult {
  /// Whether the host application is authorized.
  final bool isAuthorized;

  /// License verification status (`Authorized`, `MissingAsset`, `Expired`, etc.).
  final String status;

  /// Verification diagnostic message.
  final String reason;

  /// Creates an immutable [CynoptaLicenseResult].
  const CynoptaLicenseResult({
    required this.isAuthorized,
    required this.status,
    required this.reason,
  });

  /// Deserializes a [CynoptaLicenseResult] from a plugin map.
  factory CynoptaLicenseResult.fromMap(Map<Object?, Object?> map) {
    return CynoptaLicenseResult(
      isAuthorized: map['isAuthorized'] as bool? ?? false,
      status: map['status'] as String? ?? 'Unknown',
      reason: map['reason'] as String? ?? '',
    );
  }
}

/// Immutable result of a Cynopta trust evaluation.
class TrustEvaluation {
  /// Combined trust score in `[0.0, 1.0]` (`1.0` = highest trust).
  final double score;

  /// Trust classification label (e.g., `VERIFIED_HUMAN`, `PROVISIONAL_NEW_DEVICE`,
  /// `SUSPICIOUS_SESSION`, `SESSION_HIJACK_RISK`, or `SYNTHETIC_BOT_FARM`).
  final String classification;

  /// Longitudinal device trust score in `[0.0, 1.0]`.
  final double deviceRealnessScore;

  /// Session risk probability in `[0.0, 1.0]` (`1.0` = highest risk).
  final double sessionBotRisk;

  /// Diagnostic reason codes associated with the evaluation.
  final List<String> reasons;

  /// Signed backend attestation token suitable for the `X-Cynopta-Attestation` header.
  final String attestationPayload;

  /// Evaluation wall-clock timestamp in epoch milliseconds.
  final int timestamp;

  /// Evaluation latency in milliseconds.
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

  /// Deserializes a [TrustEvaluation] from a plugin map.
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
class Cynopta {
  static const MethodChannel _channel = MethodChannel('com.cynopta.sdk/trust');
  static final Random _rng = _createRng();
  static _DartEvalFn? _cachedFn;

  const Cynopta._();

  static Random _createRng() {
    try {
      return Random.secure();
    } catch (_) {
      return Random();
    }
  }

  static _DartEvalFn? get _evalFn {
    if (_cachedFn != null) return _cachedFn;
    try {
      final lib = DynamicLibrary.open('libcynopta-security.so');
      _cachedFn = lib.lookupFunction<_NativeEvalFn, _DartEvalFn>(
        'cf0',
        isLeaf: true,
      );
    } catch (_) {
      _cachedFn = null;
    }
    return _cachedFn;
  }

  static bool get _isSupportedMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  /// Starts or resumes SDK collection.
  static Future<void> start() async {
    if (!_isSupportedMobile) return;
    try {
      await _channel.invokeMethod<void>('start');
    } on MissingPluginException {
      // Native SDK not linked on this platform.
    }
  }

  /// Stops SDK collection and optionally deletes persisted local state.
  static Future<void> stop({bool deleteAllData = false}) async {
    if (!_isSupportedMobile) return;
    try {
      await _channel.invokeMethod<void>(
        'stop',
        {'deleteAllData': deleteAllData},
      );
    } on MissingPluginException {
      // Native SDK not linked on this platform.
    }
  }

  /// Returns `true` if the Cynopta SDK is active and authorized.
  static Future<bool> isStarted() async {
    if (!_isSupportedMobile) return false;
    try {
      return await _channel.invokeMethod<bool>('isStarted') ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Returns `true` if the application passed license verification.
  static Future<bool> isAuthorized() async {
    if (!_isSupportedMobile) return false;
    try {
      return await _channel.invokeMethod<bool>('isAuthorized') ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Returns the license verification result.
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

  /// Returns the native Cynopta SDK version string (e.g. `"1.0.27"`).
  static Future<String> getVersionName() async {
    if (!_isSupportedMobile) return '';
    try {
      return await _channel.invokeMethod<String>('getVersionName') ?? '';
    } on MissingPluginException {
      return '';
    }
  }

  /// Returns the native Cynopta SDK version code.
  static Future<int> getVersionCode() async {
    if (!_isSupportedMobile) return 0;
    try {
      return await _channel.invokeMethod<int>('getVersionCode') ?? 0;
    } on MissingPluginException {
      return 0;
    }
  }

  /// Enables or disables periodic telemetry reporting.
  static Future<void> setReportingEnabled(bool enabled) async {
    if (!_isSupportedMobile) return;
    try {
      await _channel.invokeMethod<void>(
        'setReportingEnabled',
        {'enabled': enabled},
      );
    } on MissingPluginException {
      // Native SDK not linked on this platform.
    }
  }

  /// Returns `true` if periodic telemetry reporting is currently enabled.
  static Future<bool> isReportingEnabled() async {
    if (!_isSupportedMobile) return false;
    try {
      return await _channel.invokeMethod<bool>('isReportingEnabled') ?? true;
    } on MissingPluginException {
      return false;
    }
  }

  /// Performs a trust evaluation bound to [actionName].
  static Future<TrustEvaluation> evaluateActionTrust([
    String actionName = 'ACTION_DEFAULT',
  ]) async {
    if (!_isSupportedMobile) {
      return TrustEvaluation.fromMap({'actionName': actionName});
    }
    final int nonce = _nextNonce();
    try {
      final map = await _channel.invokeMapMethod<Object?, Object?>(
        'evaluateActionTrust',
        {'actionName': actionName, 'nonce': nonce},
      );
      return _decodeResponse(map, nonce, actionName);
    } on MissingPluginException {
      return TrustEvaluation(
        score: 0.5,
        classification: 'PROVISIONAL_NEW_DEVICE',
        deviceRealnessScore: 0.5,
        sessionBotRisk: 0.0,
        reasons: const ['NATIVE_BRIDGE_UNAVAILABLE'],
        attestationPayload: '',
        timestamp: 0,
        evaluationLatencyMs: 0,
        actionName: actionName,
      );
    }
  }

  /// Returns the most recent cached [TrustEvaluation], or triggers a new evaluation.
  static Future<TrustEvaluation> getLatestTrustEvaluation() async {
    if (!_isSupportedMobile) {
      return TrustEvaluation.fromMap(const {});
    }
    final int nonce = _nextNonce();
    try {
      final map = await _channel.invokeMapMethod<Object?, Object?>(
        'getLatestTrustEvaluation',
        {'nonce': nonce},
      );
      return _decodeResponse(map, nonce, 'GET_TRUST_EVALUATION');
    } on MissingPluginException {
      return const TrustEvaluation(
        score: 0.5,
        classification: 'PROVISIONAL_NEW_DEVICE',
        deviceRealnessScore: 0.5,
        sessionBotRisk: 0.0,
        reasons: ['NATIVE_BRIDGE_UNAVAILABLE'],
        attestationPayload: '',
        timestamp: 0,
        evaluationLatencyMs: 0,
        actionName: 'GET_TRUST_EVALUATION',
      );
    }
  }

  static int _nextNonce() {
    final int hi = _rng.nextInt(0x100000000);
    final int lo = _rng.nextInt(0x100000000);
    final int n = (hi << 32) | (lo & 0xFFFFFFFF);
    return n == 0 ? 1 : n;
  }

  static TrustEvaluation _decodeResponse(
    Map<Object?, Object?>? map,
    int nonce,
    String defaultActionName,
  ) {
    final Map<Object?, Object?> safeMap = map ?? const {};
    final rawReasons = safeMap['reasons'] as List<Object?>? ?? const [];
    final reasons = rawReasons.map((e) => e.toString()).toList(growable: false);
    final String actionName =
        safeMap['actionName'] as String? ?? defaultActionName;
    final String attestationPayload =
        safeMap['attestationPayload'] as String? ?? '';
    final int timestamp = (safeMap['timestamp'] as num?)?.toInt() ?? 0;
    final int evaluationLatencyMs =
        (safeMap['evaluationLatencyMs'] as num?)?.toInt() ?? 0;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final Object? raw = safeMap['d'];
      final _DartEvalFn? fn = _evalFn;
      if (raw is! Uint8List || raw.length != 40 || fn == null) {
        return TrustEvaluation(
          score: 0.0,
          classification: 'SESSION_HIJACK_RISK',
          deviceRealnessScore: 0.0,
          sessionBotRisk: 1.0,
          reasons: reasons,
          attestationPayload: attestationPayload,
          timestamp: timestamp,
          evaluationLatencyMs: evaluationLatencyMs,
          actionName: actionName,
        );
      }

      final ByteData view = ByteData.sublistView(raw);
      final int r = fn(
        nonce,
        view.getUint64(0, Endian.little),
        view.getUint64(8, Endian.little),
        view.getUint64(16, Endian.little),
        view.getUint64(24, Endian.little),
        view.getUint64(32, Endian.little),
      );
      if (r == 0) {
        return TrustEvaluation(
          score: 0.0,
          classification: 'SESSION_HIJACK_RISK',
          deviceRealnessScore: 0.0,
          sessionBotRisk: 1.0,
          reasons: reasons,
          attestationPayload: attestationPayload,
          timestamp: timestamp,
          evaluationLatencyMs: evaluationLatencyMs,
          actionName: actionName,
        );
      }

      final String fallback =
          safeMap['c'] as String? ?? 'PROVISIONAL_NEW_DEVICE';
      return TrustEvaluation(
        score: _decodeUnits(r & 0xFFFF),
        classification: _decodeClassification((r >>> 48) & 0xFF, fallback),
        deviceRealnessScore: _decodeUnits((r >>> 16) & 0xFFFF),
        sessionBotRisk: _decodeUnits((r >>> 32) & 0xFFFF),
        reasons: reasons,
        attestationPayload: attestationPayload,
        timestamp: timestamp,
        evaluationLatencyMs: evaluationLatencyMs,
        actionName: actionName,
      );
    }

    return TrustEvaluation.fromMap({
      ...safeMap,
      'actionName': actionName,
    });
  }

  static double _decodeUnits(int raw) =>
      raw == 0xFFFF ? -1.0 : raw * 0.0001;

  static String _decodeClassification(int code, String fallback) {
    switch (code) {
      case 1:
        return 'VERIFIED_HUMAN';
      case 2:
        return 'PROVISIONAL_NEW_DEVICE';
      case 3:
        return 'SUSPICIOUS_SESSION';
      case 4:
        return 'SUSPICIOUS_PROVISIONAL';
      case 5:
        return 'SESSION_HIJACK_RISK';
      case 6:
        return 'SYNTHETIC_BOT_FARM';
      case 7:
        return 'UNAUTHORIZED_LICENSE';
      case 8:
        return 'LEASE_SUSPENDED';
      case 9:
        return 'LEASE_NOT_COVERED';
      case 10:
        return 'LEASE_QUOTA_REACHED';
      default:
        return fallback;
    }
  }
}
