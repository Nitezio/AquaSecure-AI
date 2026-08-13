import '../domain/dashboard_message.dart';

enum GatewayConnectionState { disconnected, connecting, connected, retrying }

abstract class TelemetryGateway {
  Stream<DashboardMessage> get messages;
  Stream<GatewayConnectionState> get connectionStates;

  Future<void> connect();
  Future<void> disconnect();
  void acknowledge(String alertId);
  void triggerDemoThreat() {}
}
