enum ValveState { open, closed, transitioning, unknown }

extension ValveStateLabel on ValveState {
  String get label => switch (this) {
    ValveState.open => 'OPEN',
    ValveState.closed => 'CLOSED',
    ValveState.transitioning => 'TRANSITION',
    ValveState.unknown => 'UNKNOWN',
  };
}

class TelemetrySnapshot {
  const TelemetrySnapshot({
    required this.timestamp,
    required this.ph,
    required this.flowRate,
    required this.valveState,
    this.rawValveValue,
  });

  final DateTime timestamp;
  final double ph;
  final double flowRate;
  final ValveState valveState;
  final Object? rawValveValue;

  factory TelemetrySnapshot.fromJson(Map<String, dynamic> json) {
    final sensors = _asMap(json['sensors'] ?? json['telemetry'] ?? json);
    final rawValve = sensors['MV101'] ?? sensors['mv101'];

    return TelemetrySnapshot(
      timestamp: _parseTimestamp(json['timestamp'] ?? sensors['timestamp']),
      ph: _asDouble(sensors['AIT201'] ?? sensors['ait201']),
      flowRate: _asDouble(sensors['FIT101'] ?? sensors['fit101']),
      valveState: _parseValve(rawValve),
      rawValveValue: rawValve,
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

ValveState _parseValve(Object? value) {
  if (value is bool) return value ? ValveState.open : ValveState.closed;
  if (value is num) {
    // Native SWaT values: 1 = closed, 2 = open, 0 = transitioning.
    if (value == 2) return ValveState.open;
    if (value == 1) return ValveState.closed;
    if (value == 0) return ValveState.transitioning;
  }

  final normalized = value?.toString().trim().toUpperCase();
  if (normalized == 'OPEN' || normalized == 'ON' || normalized == 'TRUE') {
    return ValveState.open;
  }
  if (normalized == 'CLOSED' ||
      normalized == 'CLOSE' ||
      normalized == 'OFF' ||
      normalized == 'FALSE') {
    return ValveState.closed;
  }
  if (normalized == 'TRANSITIONING' || normalized == 'TRANSITION') {
    return ValveState.transitioning;
  }
  return ValveState.unknown;
}
