import 'package:cynopta_flutter/cynopta_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('com.cynopta.sdk/trust');
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      switch (methodCall.method) {
        case 'getVersionName':
          return '1.0.19';
        case 'getVersionCode':
          return 20;
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
          return {
            'score': 0.92,
            'classification': 'VERIFIED_HUMAN',
            'deviceRealnessScore': 0.89,
            'sessionBotRisk': 0.03,
            'reasons': <String>['CLEAN_SESSION'],
            'attestationPayload': 'eyJhbGciOiJFUzI1NiJ9.e30.sig',
            'timestamp': 1700000000123,
            'evaluationLatencyMs': 1,
            'actionName':
                methodCall.arguments?['actionName'] ?? 'ACTION_DEFAULT',
          };
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

  test('evaluateActionTrust deserializes TrustEvaluation fields accurately',
      () async {
    final eval = await Cynopta.evaluateActionTrust('WIRE_TRANSFER');

    expect(eval.score, closeTo(0.92, 1e-6));
    expect(eval.classification, 'VERIFIED_HUMAN');
    expect(eval.deviceRealnessScore, closeTo(0.89, 1e-6));
    expect(eval.sessionBotRisk, closeTo(0.03, 1e-6));
    expect(eval.reasons, ['CLEAN_SESSION']);
    expect(eval.attestationPayload, 'eyJhbGciOiJFUzI1NiJ9.e30.sig');
    expect(eval.timestamp, 1700000000123);
    expect(eval.evaluationLatencyMs, 1);
    expect(eval.actionName, 'WIRE_TRANSFER');
  });

  test('lifecycle and metadata calls invoke expected MethodChannel methods',
      () async {
    expect(await Cynopta.getVersionName(), '1.0.19');
    expect(await Cynopta.getVersionCode(), 20);
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
        'setReportingEnabled',
        'isReportingEnabled',
        'start',
        'stop',
      ]),
    );
  });
}
