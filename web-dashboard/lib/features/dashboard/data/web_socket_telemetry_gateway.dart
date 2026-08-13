import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../domain/dashboard_message.dart';
import '../domain/telemetry_snapshot.dart';
import '../domain/threat_alert.dart';
import 'telemetry_gateway.dart';

class WebSocketTelemetryGateway implements TelemetryGateway {
  WebSocketTelemetryGateway(this.url);

  final String url;
  final _messages = StreamController<DashboardMessage>.broadcast();
  final _states = StreamController<GatewayConnectionState>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _retryTimer;
  bool _manualDisconnect = false;
  bool _connecting = false;
  int _retryAttempt = 0;

  @override
  Stream<DashboardMessage> get messages => _messages.stream;

  @override
  Stream<GatewayConnectionState> get connectionStates => _states.stream;

  @override
  Future<void> connect() async {
    if (_connecting || _channel != null) return;
    _manualDisconnect = false;
    _connecting = true;
    _states.add(
      _retryAttempt == 0
          ? GatewayConnectionState.connecting
          : GatewayConnectionState.retrying,
    );

    try {
      final channel = WebSocketChannel.connect(Uri.parse(url));
      _channel = channel;
      _subscription = channel.stream.listen(
        _onData,
        onError: (_) => _handleDisconnect(),
        onDone: _handleDisconnect,
        cancelOnError: true,
      );
      await channel.ready;
      _retryAttempt = 0;
      _states.add(GatewayConnectionState.connected);
    } catch (_) {
      await _subscription?.cancel();
      _subscription = null;
      _channel = null;
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  void _onData(dynamic rawData) {
    try {
      final decoded = jsonDecode(rawData.toString());
      if (decoded is! Map) return;
      final json = decoded.map((key, value) => MapEntry(key.toString(), value));
      final type = (json['type'] ?? json['event'] ?? '')
          .toString()
          .toLowerCase();

      if (type == 'reset' || type == 'clear') {
        _messages.add(const ResetMessage());
        return;
      }

      final anomaly = json['anomaly'] == true || json['isAnomaly'] == true;
      if (type == 'alert' || type == 'anomaly' || anomaly) {
        _messages.add(AlertMessage(ThreatAlert.fromJson(json)));
        return;
      }

      if (type == 'telemetry' ||
          json.containsKey('sensors') ||
          json.containsKey('AIT201') ||
          json.containsKey('ait201')) {
        _messages.add(TelemetryMessage(TelemetrySnapshot.fromJson(json)));
      }
    } catch (_) {
      // Malformed backend frames are ignored so one payload cannot stop the feed.
    }
  }

  void _handleDisconnect() {
    _subscription = null;
    _channel = null;
    if (_manualDisconnect) {
      _states.add(GatewayConnectionState.disconnected);
    } else {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_manualDisconnect || _retryTimer?.isActive == true) return;
    _states.add(GatewayConnectionState.retrying);
    _retryAttempt = (_retryAttempt + 1).clamp(1, 6);
    final delay = Duration(seconds: 1 << (_retryAttempt - 1));
    _retryTimer = Timer(delay, connect);
  }

  @override
  void acknowledge(String alertId) {
    _channel?.sink.add(
      jsonEncode({
        'type': 'alert_acknowledgement',
        'alertId': alertId,
        'acknowledgedAt': DateTime.now().toUtc().toIso8601String(),
      }),
    );
  }

  @override
  void triggerDemoThreat() {
    // Live threats are emitted only by the backend anomaly pipeline.
  }

  @override
  Future<void> disconnect() async {
    _manualDisconnect = true;
    _retryTimer?.cancel();
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
    _states.add(GatewayConnectionState.disconnected);
  }
}
