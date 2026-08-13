import 'dart:async';
import 'dart:math';

import '../domain/dashboard_message.dart';
import '../domain/telemetry_snapshot.dart';
import '../domain/threat_alert.dart';
import 'telemetry_gateway.dart';

class MockTelemetryGateway implements TelemetryGateway {
  final _messages = StreamController<DashboardMessage>.broadcast();
  final _states = StreamController<GatewayConnectionState>.broadcast();
  final _random = Random(42);

  Timer? _timer;
  int _tick = 0;
  bool _threatActive = false;

  @override
  Stream<DashboardMessage> get messages => _messages.stream;

  @override
  Stream<GatewayConnectionState> get connectionStates => _states.stream;

  @override
  Future<void> connect() async {
    _states.add(GatewayConnectionState.connecting);
    await Future<void>.delayed(const Duration(milliseconds: 320));
    _states.add(GatewayConnectionState.connected);
    _emitTelemetry();
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      _tick++;
      _emitTelemetry();
    });
  }

  void _emitTelemetry() {
    final now = DateTime.now();
    final wave = sin(_tick / 5.4);
    final fineWave = sin(_tick / 2.7);
    final noise = (_random.nextDouble() - 0.5) * 0.035;
    final attackLift = _threatActive ? 2.2 + sin(_tick / 2) * 0.22 : 0.0;

    _messages.add(
      TelemetryMessage(
        TelemetrySnapshot(
          timestamp: now,
          ph: 7.18 + wave * 0.11 + noise + attackLift,
          flowRate: 2.43 + fineWave * 0.065 + noise / 2,
          valveState: ValveState.open,
          rawValveValue: 2,
        ),
      ),
    );
  }

  @override
  void triggerDemoThreat() {
    if (_threatActive) return;
    _threatActive = true;
    final now = DateTime.now();
    _messages.add(AlertMessage(ThreatAlert.demo(now)));
    _emitTelemetry();
  }

  @override
  void acknowledge(String alertId) {
    _threatActive = false;
  }

  @override
  Future<void> disconnect() async {
    _timer?.cancel();
    _timer = null;
    _states.add(GatewayConnectionState.disconnected);
  }
}
