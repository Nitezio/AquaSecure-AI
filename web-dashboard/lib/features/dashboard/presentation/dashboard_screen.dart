import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../application/dashboard_controller.dart';
import '../data/mock_telemetry_gateway.dart';
import '../data/telemetry_gateway.dart';
import '../data/web_socket_telemetry_gateway.dart';
import '../domain/telemetry_snapshot.dart';
import 'widgets/app_header.dart';
import 'widgets/event_log_panel.dart';
import 'widgets/explainability_panel.dart';
import 'widgets/facility_status_banner.dart';
import 'widgets/metric_card.dart';
import 'widgets/navigation_sidebar.dart';
import 'widgets/process_flow_panel.dart';
import 'widgets/system_readiness_panel.dart';
import 'widgets/telemetry_chart.dart';
import 'widgets/threat_frame.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    final config = AppConfig.fromEnvironment();
    final TelemetryGateway gateway = config.mode == DataMode.demo
        ? MockTelemetryGateway()
        : WebSocketTelemetryGateway(config.webSocketUrl);
    _controller = DashboardController(gateway: gateway, config: config);
    _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final showSidebar = MediaQuery.sizeOf(context).width >= 980;
        return Scaffold(
          body: ThreatFrame(
            active: _controller.isThreatActive,
            child: Row(
              children: [
                if (showSidebar) const NavigationSidebar(),
                Expanded(child: _DashboardBody(controller: _controller)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 720;
    final telemetry = controller.currentTelemetry;
    final ph = telemetry?.ph;
    final flow = telemetry?.flowRate;
    final valve = telemetry?.valveState ?? ValveState.unknown;
    final isThreat = controller.isThreatActive;
    final phCritical = ph != null && (ph < 6.5 || ph > 8.5);

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.65, -0.85),
                  radius: 1.1,
                  colors: [
                    (isThreat ? AppColors.danger : AppColors.primary)
                        .withValues(alpha: 0.055),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              compact ? 16 : 28,
              compact ? 18 : 28,
              compact ? 16 : 28,
              38,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1550),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppHeader(
                      mode: controller.config.mode,
                      connectionState: controller.connectionState,
                      onDemoThreat: controller.isDemoMode && !isThreat
                          ? controller.triggerDemoThreat
                          : null,
                    ),
                    SizedBox(height: compact ? 20 : 28),
                    FacilityStatusBanner(
                      alert: controller.activeAlert,
                      onAcknowledge: controller.acknowledgeActiveAlert,
                    ),
                    const SizedBox(height: 18),
                    _MetricsGrid(
                      ph: ph,
                      flow: flow,
                      valve: valve,
                      isThreat: isThreat,
                      phCritical: phCritical,
                    ),
                    const SizedBox(height: 18),
                    _ResponsivePair(
                      first: TelemetryChart(
                        sensorId: 'AIT202 / ANALYZER TRANSMITTER',
                        title: 'Water pH level',
                        unit: 'pH',
                        samples: controller.phSamples,
                        color: phCritical
                            ? AppColors.danger
                            : AppColors.primary,
                        minY: 6,
                        maxY: 10,
                        interval: 1,
                        warningMin: 6.5,
                        warningMax: 8.5,
                      ),
                      second: TelemetryChart(
                        sensorId: controller.dynamicChartSensorId,
                        title: controller.dynamicChartTitle,
                        unit: 'm3/h', // we can leave unit as is or make it dynamic, let's leave it
                        samples: controller.dynamicChartSamples,
                        color: controller.dynamicChartColor,
                        minY: controller.dynamicChartMinY,
                        maxY: controller.dynamicChartMaxY,
                        interval: (controller.dynamicChartMaxY - controller.dynamicChartMinY) / 4,
                        warningMin: controller.dynamicChartMinY + 0.1,
                        warningMax: controller.dynamicChartMaxY - 0.1,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _ResponsivePair(
                      first: ProcessFlowPanel(isThreat: isThreat),
                      second: ExplainabilityPanel(
                        alert: controller.activeAlert,
                      ),
                      firstFlex: 7,
                      secondFlex: 5,
                    ),
                    const SizedBox(height: 18),
                    _ResponsivePair(
                      first: EventLogPanel(events: controller.events),
                      second: SystemReadinessPanel(
                        connectionState: controller.connectionState,
                        packetsReceived: controller.packetsReceived,
                        anomaliesDetected: controller.anomaliesDetected,
                        isThreat: isThreat,
                      ),
                      firstFlex: 7,
                      secondFlex: 5,
                    ),
                    const SizedBox(height: 24),
                    _Footer(controller: controller),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({
    required this.ph,
    required this.flow,
    required this.valve,
    required this.isThreat,
    required this.phCritical,
  });

  final double? ph;
  final double? flow;
  final ValveState valve;
  final bool isThreat;
  final bool phCritical;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1040
            ? 3
            : constraints.maxWidth >= 590
            ? 2
            : 1;
        const spacing = 16.0;
        final cardWidth =
            (constraints.maxWidth - (columns - 1) * spacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: cardWidth,
              child: MetricCard(
                sensorId: 'AIT201',
                label: 'PH ANALYZER',
                value: ph?.toStringAsFixed(2) ?? '--',
                unit: 'pH',
                color: AppColors.primary,
                icon: Icons.science_outlined,
                status: phCritical ? 'Out of range' : 'Nominal',
                progress: ph == null ? 0 : ((ph! - 5) / 6).clamp(0, 1),
                isCritical: phCritical,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: MetricCard(
                sensorId: 'FIT101',
                label: 'RAW WATER FLOW',
                value: flow?.toStringAsFixed(2) ?? '--',
                unit: 'm3/h',
                color: AppColors.cyan,
                icon: Icons.water_outlined,
                status: 'Stable flow',
                progress: flow == null ? 0 : (flow! / 3.5).clamp(0, 1),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: ValveMetricCard(state: valve, isThreat: isThreat),
            ),
          ],
        );
      },
    );
  }
}

class _ResponsivePair extends StatelessWidget {
  const _ResponsivePair({
    required this.first,
    required this.second,
    this.firstFlex = 1,
    this.secondFlex = 1,
  });

  final Widget first;
  final Widget second;
  final int firstFlex;
  final int secondFlex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 820) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [first, const SizedBox(height: 16), second],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: firstFlex, child: first),
            const SizedBox(width: 16),
            Expanded(flex: secondFlex, child: second),
          ],
        );
      },
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 640;
    final endpoint = controller.isDemoMode
        ? 'LOCAL DEMONSTRATION STREAM'
        : controller.config.webSocketUrl;

    return Flex(
      direction: compact ? Axis.vertical : Axis.horizontal,
      crossAxisAlignment: compact
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.water_drop_rounded, color: AppColors.primary, size: 17),
            SizedBox(width: 7),
            Text(
              'AQUASECURE AI',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        if (!compact) const Spacer() else const SizedBox(height: 9),
        Flexible(
          child: Text(
            'SOURCE  /  $endpoint',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.7,
            ),
          ),
        ),
      ],
    );
  }
}
