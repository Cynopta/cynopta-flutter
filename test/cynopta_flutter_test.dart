import 'package:cynopta_flutter/cynopta_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('com.cynopta.sdk/trust');
  final List<MethodCall> log = <MethodCall>[];
  late Map<String, Object?> Function(MethodCall call) evalHandler;

  setUp(() {
    log.clear();
    evalHandler = (MethodCall call) => {
          'score': 0.99,
          'classification': 'VERIFIED_HUMAN',
          'deviceRealnessScore': 0.99,
          'sessionBotRisk': 0.01,
          'reasons': const ['CLEAN_SESSION'],
          'actionName':
              call.arguments?['actionName'] as String? ?? 'ACTION_DEFAULT',
        };

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      switch (methodCall.method) {
        case 'getVersionName':
          return '1.0.23';
        case 'getVersionCode':
          return 24;
        case 'isStarted':
          return true;
        case 'isAuthorized':
          return true;
        case 'isReportingEnabled':
          return true;
        case 'setReportingEnabled':
          return true;
        case 'getLicenseResult':
          return {
            'isAuthorized': true,
            'status': 'Authorized',
            'reason': 'Valid signature',
          };
        case 'evaluateActionTrust':
        case 'getLatestTrustEvaluation':
          return evalHandler(methodCall);
        case 'start':
        case 'stop':
          return null;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('TrustEvaluation.fromMap and CynoptaLicenseResult.fromMap parse fields',
      () {
    final eval = TrustEvaluation.fromMap({
      'score': 0.92,
      'classification': 'VERIFIED_HUMAN',
      'deviceRealnessScore': 0.89,
      'sessionBotRisk': 0.03,
      'reasons': const ['CLEAN_SESSION'],
      'attestationPayload': 'att-token',
      'timestamp': 1700000000123,
      'evaluationLatencyMs': 2,
      'actionName': 'WIRE_TRANSFER',
    });

    expect(eval.score, 0.92);
    expect(eval.classification, 'VERIFIED_HUMAN');
    expect(eval.deviceRealnessScore, 0.89);
    expect(eval.sessionBotRisk, 0.03);
    expect(eval.reasons, ['CLEAN_SESSION']);
    expect(eval.attestationPayload, 'att-token');
    expect(eval.timestamp, 1700000000123);
    expect(eval.evaluationLatencyMs, 2);
    expect(eval.actionName, 'WIRE_TRANSFER');

    final lic = CynoptaLicenseResult.fromMap({
      'isAuthorized': true,
      'status': 'Authorized',
      'reason': 'Valid signature',
    });
    expect(lic.isAuthorized, isTrue);
    expect(lic.status, 'Authorized');
    expect(lic.reason, 'Valid signature');
  });

  test(
      'evaluateActionTrust sends non-zero nonce and fails closed on unverified Android responses',
      () async {
    final eval = await Cynopta.evaluateActionTrust('WIRE_TRANSFER');

    expect(log.single.method, 'evaluateActionTrust');
    expect(log.single.arguments['actionName'], 'WIRE_TRANSFER');
    expect(log.single.arguments['nonce'], isA<int>());
    expect(log.single.arguments['nonce'], isNot(0));
    expect(eval.score, 0.0);
    expect(eval.deviceRealnessScore, 0.0);
    expect(eval.sessionBotRisk, 1.0);
    expect(eval.classification, 'SESSION_HIJACK_RISK');
    expect(eval.actionName, 'WIRE_TRANSFER');
  });

  test('getLatestTrustEvaluation sends non-zero nonce and handles empty maps safely',
      () async {
    evalHandler = (_) => {};

    final eval = await Cynopta.getLatestTrustEvaluation();
    expect(log.single.method, 'getLatestTrustEvaluation');
    expect(log.single.arguments['nonce'], isA<int>());
    expect(log.single.arguments['nonce'], isNot(0));
    expect(eval.score, 0.0);
    expect(eval.sessionBotRisk, 1.0);
    expect(eval.classification, 'SESSION_HIJACK_RISK');
  });

  test('MissingPluginException surfaces NATIVE_BRIDGE_UNAVAILABLE reason',
      () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);

    final eval = await Cynopta.evaluateActionTrust('APP_OPEN');
    expect(eval.score, 0.5);
    expect(eval.classification, 'PROVISIONAL_NEW_DEVICE');
    expect(eval.actionName, 'APP_OPEN');
    expect(eval.reasons, ['NATIVE_BRIDGE_UNAVAILABLE']);
  });

  test('lifecycle, reporting, license, and version methods forward as expected',
      () async {
    expect(await Cynopta.getVersionName(), '1.0.23');
    expect(await Cynopta.getVersionCode(), 24);
    expect(await Cynopta.isStarted(), isTrue);
    expect(await Cynopta.isAuthorized(), isTrue);

    final lic = await Cynopta.getLicenseResult();
    expect(lic, isNotNull);
    expect(lic!.isAuthorized, isTrue);
    expect(lic.status, 'Authorized');

    await Cynopta.setReportingEnabled(false);
    expect(await Cynopta.isReportingEnabled(), isTrue);

    await Cynopta.start();
    await Cynopta.stop(deleteAllData: true);

    expect(
      log.map((c) => c.method),
      containsAll([
        'getVersionName',
        'getVersionCode',
        'isStarted',
        'isAuthorized',
        'getLicenseResult',
        'setReportingEnabled',
        'isReportingEnabled',
        'start',
        'stop',
      ]),
    );
  });
}
