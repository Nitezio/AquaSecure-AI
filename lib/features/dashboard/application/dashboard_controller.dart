import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';
import '../data/telemetry_gateway.dart';
import '../domain/dashboard_message.dart';
import '../domain/event_entry.dart';
import '../domain/telemetry_snapshot.dart';
import '../domain/threat_alert.dart';

class ChartSample {
  const ChartSample({required this.timestamp, required this.value});

  final DateTime timestamp;
  final double value;
}

class DashboardController extends ChangeNotifier {
  DashboardController({required this.gateway, required this.config});

  final TelemetryGateway gateway;
  final AppConfig config;

  StreamSubscription<DashboardMessage>? _messageSubscription;
  StreamSubscription<GatewayConnectionState>? _connectionSubscription;

  GatewayConnectionState connectionState = GatewayConnectionState.disconnected;
  TelemetrySnapshot? currentTelemetry;
  ThreatAlert? activeAlert;
  ThreatAlert? lastAcknowledgedAlert;
  final List<ChartSample> phSamples = [];
  final List<ChartSample> flowSamples = [];
  final List<EventEntry> events = [];
  int packetsReceived = 0;
  int anomaliesDetected = 0;
  DateTime? connectedSince;

  bool get isThreatActive => activeAlert != null;
  bool get isDemoMode => config.mode == DataMode.demo;
  bool get isConnected => connectionState == GatewayConnectionState.connected;

  Future<void> start() async {
    _messageSubscription = gateway.messages.listen(_onMessage);
    _connectionSubscription = gateway.connectionStates.listen((state) {
      final wasConnected = isConnected;
      connectionState = state;
      if (!wasConnected && state == GatewayConnectionState.connected) {
        connectedSince = DateTime.now();
        _addEvent(
          'Telemetry link established',
          isDemoMode
              ? 'Deterministic SWaT demonstration stream online.'
              : 'Connected to ${config.webSocketUrl}.',
          EventTone.success,
        );
      }
      notifyListeners();
    });
    await gateway.connect();
  }

  void _onMessage(DashboardMessage message) {
    switch (message) {
      case TelemetryMessage(:final snapshot):
        currentTelemetry = snapshot;
        packetsReceived++;
        _appendSample(
          phSamples,
          ChartSample(timestamp: snapshot.timestamp, value: snapshot.ph),
        );
        _appendSample(
          flowSamples,
          ChartSample(timestamp: snapshot.timestamp, value: snapshot.flowRate),
        );
      case AlertMessage(:final alert):
        activeAlert = alert;
        anomaliesDetected++;
        _addEvent(
          alert.title,
          '${alert.sensor} / ${alert.message}',
          EventTone.critical,
        );
      case ResetMessage():
        activeAlert = null;
        _addEvent(
          'Threat state cleared remotely',
          'The backend returned the dashboard to monitoring mode.',
          EventTone.success,
        );
    }
    notifyListeners();
  }

  void _appendSample(List<ChartSample> target, ChartSample sample) {
    target.add(sample);
    if (target.length > 60) target.removeAt(0);
  }

  void _addEvent(String title, String description, EventTone tone) {
    events.insert(
      0,
      EventEntry(
        timestamp: DateTime.now(),
        title: title,
        description: description,
        tone: tone,
      ),
    );
    if (events.length > 12) events.removeLast();
  }

  void triggerDemoThreat() => gateway.triggerDemoThreat();

  void acknowledgeActiveAlert() {
    final alert = activeAlert;
    if (alert == null) return;
    gateway.acknowledge(alert.id);
    lastAcknowledgedAlert = alert;
    activeAlert = null;
    _addEvent(
      'Alarm acknowledged',
      '${alert.id} cleared by the facility operator.',
      EventTone.warning,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    gateway.disconnect();
    super.dispose();
  }
}
