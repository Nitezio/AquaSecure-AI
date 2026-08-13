import 'package:aquasecure_ai/features/dashboard/domain/telemetry_snapshot.dart';
import 'package:aquasecure_ai/features/dashboard/domain/threat_alert.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TelemetrySnapshot', () {
    test('parses nested SWaT telemetry and native valve values', () {
      final snapshot = TelemetrySnapshot.fromJson({
        'type': 'telemetry',
        'timestamp': '2026-08-11T10:15:30Z',
        'sensors': {'AIT201': '7.16', 'FIT101': 2.44, 'MV101': 2},
      });

      expect(snapshot.ph, 7.16);
      expect(snapshot.flowRate, 2.44);
      expect(snapshot.valveState, ValveState.open);
    });

    test('accepts flat lowercase integration payloads', () {
      final snapshot = TelemetrySnapshot.fromJson({
        'ait201': 7.2,
        'fit101': '2.41',
        'mv101': false,
      });

      expect(snapshot.ph, 7.2);
      expect(snapshot.flowRate, 2.41);
      expect(snapshot.valveState, ValveState.closed);
    });
  });

  group('ThreatAlert', () {
    test(
      'parses explainability fields and normalizes percentage confidence',
      () {
        final alert = ThreatAlert.fromJson({
          'type': 'alert',
          'timestamp': '2026-08-11T10:15:31Z',
          'severity': 'critical',
          'sensor': 'AIT201',
          'confidence': 97.4,
          'explanation': 'AIT201 was the largest contributor.',
          'violatedRule': 'pH moved without a matching process change.',
          'contributors': [
            {'feature': 'AIT201', 'impact': 0.76, 'value': 9.4},
          ],
        });

        expect(alert.severity, AlertSeverity.critical);
        expect(alert.sensor, 'AIT201');
        expect(alert.confidence, closeTo(0.974, 0.0001));
        expect(alert.contributors.single.sensor, 'AIT201');
      },
    );
  });
}
