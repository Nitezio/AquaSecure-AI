import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/telemetry_gateway.dart';
import 'control_panel.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    required this.mode,
    required this.connectionState,
    required this.onDemoThreat,
    super.key,
  });

  final DataMode mode;
  final GatewayConnectionState connectionState;
  final VoidCallback? onDemoThreat;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 720;
    final connectionColor = switch (connectionState) {
      GatewayConnectionState.connected => AppColors.primary,
      GatewayConnectionState.connecting ||
      GatewayConnectionState.retrying => AppColors.amber,
      GatewayConnectionState.disconnected => AppColors.danger,
    };
    final connectionLabel = switch (connectionState) {
      GatewayConnectionState.connected => 'Stream online',
      GatewayConnectionState.connecting => 'Connecting',
      GatewayConnectionState.retrying => 'Reconnecting',
      GatewayConnectionState.disconnected => 'Offline',
    };

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FACILITY 01  /  CONTROL ROOM',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: isCompact ? 9 : 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                isCompact ? 'Operations' : 'Water Defense Operations',
                style: isCompact
                    ? Theme.of(context).textTheme.headlineSmall
                    : Theme.of(context).textTheme.displaySmall,
              ),
            ],
          ),
        ),
        if (!isCompact) ...[
          StatusPill(
            label: mode == DataMode.demo ? 'Demo feed' : 'Live feed',
            color: mode == DataMode.demo ? AppColors.cyan : AppColors.primary,
            icon: mode == DataMode.demo
                ? Icons.science_outlined
                : Icons.sensors_outlined,
          ),
          const SizedBox(width: 10),
          StatusPill(label: connectionLabel, color: connectionColor),
          if (onDemoThreat != null) ...[
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: onDemoThreat,
              icon: const Icon(Icons.bolt_rounded, size: 17),
              label: const Text('RUN ATTACK DEMO'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.amber,
                side: const BorderSide(color: Color(0x66FFB648)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 17,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ] else
          PopupMenuButton<String>(
            tooltip: 'Dashboard status',
            color: AppColors.panelLight,
            icon: const Icon(Icons.more_horiz_rounded),
            onSelected: (value) {
              if (value == 'demo') onDemoThreat?.call();
            },
            itemBuilder: (_) => [
              PopupMenuItem<String>(
                enabled: false,
                child: StatusPill(
                  label: connectionLabel,
                  color: connectionColor,
                  compact: true,
                ),
              ),
              if (onDemoThreat != null)
                const PopupMenuItem<String>(
                  value: 'demo',
                  child: Row(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        color: AppColors.amber,
                        size: 18,
                      ),
                      SizedBox(width: 9),
                      Text('Run attack demo'),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
