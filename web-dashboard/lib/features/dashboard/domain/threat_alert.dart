enum AlertSeverity { info, warning, critical }

extension AlertSeverityLabel on AlertSeverity {
  String get label => name.toUpperCase();
}

class FeatureContribution {
  const FeatureContribution({
    required this.sensor,
    required this.impact,
    this.value,
  });

  final String sensor;
  final double impact;
  final double? value;

  factory FeatureContribution.fromJson(Map<String, dynamic> json) {
    return FeatureContribution(
      sensor: (json['sensor'] ?? json['feature'] ?? 'Unknown').toString(),
      impact: _asDouble(
        json['impact'] ?? json['contribution'] ?? json['score'],
      ),
      value: json['value'] == null ? null : _asDouble(json['value']),
    );
  }
}

class ThreatAlert {
  const ThreatAlert({
    required this.id,
    required this.timestamp,
    required this.severity,
    required this.sensor,
    required this.title,
    required this.message,
    required this.explanation,
    required this.violatedRule,
    required this.recommendation,
    required this.confidence,
    required this.contributors,
  });

  final String id;
  final DateTime timestamp;
  final AlertSeverity severity;
  final String sensor;
  final String title;
  final String message;
  final String explanation;
  final String violatedRule;
  final String recommendation;
  final double confidence;
  final List<FeatureContribution> contributors;

  factory ThreatAlert.fromJson(Map<String, dynamic> json) {
    final details = _asMap(json['details'] ?? json['alert'] ?? json);
    final rawContributors =
        details['contributors'] ?? details['featureContributions'];
    final contributors = <FeatureContribution>[];
    if (rawContributors is List) {
      for (final item in rawContributors) {
        contributors.add(FeatureContribution.fromJson(_asMap(item)));
      }
    }

    final timestamp = _parseTimestamp(
      json['timestamp'] ?? details['timestamp'],
    );
    final sensor = (details['sensor'] ?? details['source'] ?? 'ICS').toString();

    return ThreatAlert(
      id:
          (details['id'] ??
                  details['alertId'] ??
                  timestamp.microsecondsSinceEpoch)
              .toString(),
      timestamp: timestamp,
      severity: _parseSeverity(details['severity']),
      sensor: sensor,
      title: (details['title'] ?? 'Anomalous process behavior').toString(),
      message:
          (details['message'] ??
                  details['reason'] ??
                  'The anomaly service flagged unexpected telemetry.')
              .toString(),
      explanation:
          (details['explanation'] ??
                  details['xaiExplanation'] ??
                  '$sensor contributed most strongly to the anomaly score.')
              .toString(),
      violatedRule:
          (details['violatedRule'] ??
                  details['physicsRule'] ??
                  'No physics-rule explanation was supplied.')
              .toString(),
      recommendation:
          (details['recommendation'] ??
                  'Verify the affected process stage and place field controls in manual mode.')
              .toString(),
      confidence: _normalizeConfidence(
        details['confidence'] ?? details['anomalyScore'] ?? 0,
      ),
      contributors: contributors,
    );
  }

  factory ThreatAlert.demo(DateTime timestamp) {
    return ThreatAlert(
      id: 'DEMO-${timestamp.millisecondsSinceEpoch}',
      timestamp: timestamp,
      severity: AlertSeverity.critical,
      sensor: 'AIT201',
      title: 'CHEMICAL PROCESS ANOMALY',
      message: 'Rapid pH deviation detected in Stage P2 treatment feed.',
      explanation:
          'AIT201 shifted 3.4 standard deviations above its learned operating baseline while flow remained stable.',
      violatedRule:
          'pH increased while chemical dosing and inlet flow states reported no corresponding process change.',
      recommendation:
          'Inspect P2 dosing controls, verify AIT201 locally, and maintain manual override until cleared.',
      confidence: 0.974,
      contributors: const [
        FeatureContribution(sensor: 'AIT201', impact: 0.76, value: 9.42),
        FeatureContribution(sensor: 'FIT101', impact: 0.16, value: 2.47),
        FeatureContribution(sensor: 'MV101', impact: 0.08, value: 2),
      ],
    );
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return const <String, dynamic>{};
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

double _normalizeConfidence(Object? value) {
  final parsed = _asDouble(value);
  return (parsed > 1 ? parsed / 100 : parsed).clamp(0, 1).toDouble();
}

DateTime _parseTimestamp(Object? value) {
  if (value is num) {
    final raw = value.toInt();
    return DateTime.fromMillisecondsSinceEpoch(
      raw < 100000000000 ? raw * 1000 : raw,
    );
  }
  return DateTime.tryParse(value?.toString() ?? '')?.toLocal() ??
      DateTime.now();
}

AlertSeverity _parseSeverity(Object? value) {
  return switch (value?.toString().toLowerCase()) {
    'critical' || 'high' || 'emergency' => AlertSeverity.critical,
    'warning' || 'medium' => AlertSeverity.warning,
    _ => AlertSeverity.info,
  };
}
