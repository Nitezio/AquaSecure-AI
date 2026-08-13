enum DataMode { demo, live }

class AppConfig {
  const AppConfig({required this.mode, required this.webSocketUrl});

  final DataMode mode;
  final String webSocketUrl;

  static AppConfig fromEnvironment() {
    const compiledMode = String.fromEnvironment(
      'DATA_MODE',
      defaultValue: 'demo',
    );
    const compiledUrl = String.fromEnvironment(
      'WS_URL',
      defaultValue: 'ws://localhost:8080/ws',
    );

    final query = Uri.base.queryParameters;
    final requestedMode = (query['mode'] ?? compiledMode).toLowerCase();
    final requestedUrl = query['ws'] ?? compiledUrl;

    return AppConfig(
      mode: requestedMode == 'live' ? DataMode.live : DataMode.demo,
      webSocketUrl: requestedUrl,
    );
  }
}
