import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/telemetry_gateway.dart';
import 'control_panel.dart';

class SystemReadinessPanel extends StatelessWidget {
  const SystemReadinessPanel({
    required this.connectionState,
    required this.packetsReceived,
    required this.anomaliesDetected,
    required this.isThreat,
    super.key,
  });

  final GatewayConnectionState connectionState;
  final int packetsReceived;
  final int anomaliesDetected;
  final bool isThreat;

  @override
  Widget build(BuildContext context) {
    return ControlPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            eyebrow: 'SYSTEM HEALTH',
            title: 'Defense readiness',
          ),
          const SizedBox(height: 20),
          _HealthRow(
            label: 'Telemetry gateway',
            value: connectionState == GatewayConnectionState.connected
                ? 'ONLINE'
                : 'CONNECTING',
            color: connectionState == GatewayConnectionState.connected
                ? AppColors.primary
                : AppColors.amber,
          ),
          const _HealthRow(
            label: 'Anomaly watchdog',
            value: 'ARMED',
            color: AppColors.primary,
          ),
          _HealthRow(
            label: 'Control policy',
            value: isThreat ? 'MANUAL' : 'AUTOMATIC',
            color: isThreat ? AppColors.danger : AppColors.cyan,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'PACKETS',
                  value: _compact(packetsReceived),
                ),
              ),
              Container(width: 1, height: 34, color: AppColors.panelBorder),
              Expanded(
                child: _MiniStat(
                  label: 'ANOMALIES',
                  value: anomaliesDetected.toString(),
                ),
              ),
              Container(width: 1, height: 34, color: AppColors.panelBorder),
              const Expanded(
                child: _MiniStat(label: 'LATENCY', value: '<2s'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _compact(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }
}

class _HealthRow extends StatelessWidget {
  const _HealthRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 7,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
          ),
        ),
      ],
    );
  }
}
