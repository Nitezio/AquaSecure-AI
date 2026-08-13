import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'control_panel.dart';

class ProcessFlowPanel extends StatelessWidget {
  const ProcessFlowPanel({required this.isThreat, super.key});

  final bool isThreat;

  static const _stages = [
    ('P1', 'Raw water', Icons.water_outlined),
    ('P2', 'Chemical', Icons.science_outlined),
    ('P3', 'Filtration', Icons.filter_alt_outlined),
    ('P4', 'Dechlor.', Icons.opacity_outlined),
    ('P5', 'Reverse osmosis', Icons.waves_outlined),
    ('P6', 'Recovery', Icons.recycling_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return ControlPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            eyebrow: 'PROCESS MAP',
            title: 'Treatment stages',
            trailing: StatusPill(
              label: isThreat ? 'Manual isolation' : 'Auto control',
              color: isThreat ? AppColors.danger : AppColors.primary,
              compact: true,
            ),
          ),
          const SizedBox(height: 26),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var index = 0; index < _stages.length; index++) ...[
                  _StageNode(
                    code: _stages[index].$1,
                    label: _stages[index].$2,
                    icon: _stages[index].$3,
                    state: isThreat && index == 1
                        ? _StageState.threat
                        : isThreat && index > 1
                        ? _StageState.isolated
                        : _StageState.secure,
                  ),
                  if (index < _stages.length - 1)
                    _StageConnector(isThreat: isThreat && index >= 1),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.panelBorder),
            ),
            child: Row(
              children: [
                Icon(
                  isThreat ? Icons.pan_tool_alt_outlined : Icons.hub_outlined,
                  color: isThreat ? AppColors.danger : AppColors.cyan,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isThreat
                        ? 'Downstream PLC commands are visually marked as isolated. Field verification is required.'
                        : 'Six-stage process synchronized. Telemetry is within the learned operating envelope.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _StageState { secure, threat, isolated }

class _StageNode extends StatelessWidget {
  const _StageNode({
    required this.code,
    required this.label,
    required this.icon,
    required this.state,
  });

  final String code;
  final String label;
  final IconData icon;
  final _StageState state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _StageState.secure => AppColors.primary,
      _StageState.threat => AppColors.danger,
      _StageState.isolated => AppColors.amber,
    };
    final stateLabel = switch (state) {
      _StageState.secure => 'ONLINE',
      _StageState.threat => 'ALERT',
      _StageState.isolated => 'MANUAL',
    };

    return SizedBox(
      width: 86,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: color.withValues(alpha: 0.55)),
                ),
                child: Icon(icon, color: color, size: 23),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.panelLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    code.substring(1),
                    style: TextStyle(
                      color: color,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            stateLabel,
            style: TextStyle(
              color: color,
              fontSize: 7,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _StageConnector extends StatelessWidget {
  const _StageConnector({required this.isThreat});

  final bool isThreat;

  @override
  Widget build(BuildContext context) {
    final color = isThreat ? AppColors.amber : AppColors.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: SizedBox(
        width: 28,
        child: Row(
          children: [
            Expanded(child: Divider(color: color.withValues(alpha: 0.55))),
            Icon(Icons.chevron_right_rounded, color: color, size: 13),
          ],
        ),
      ),
    );
  }
}
