import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/telemetry_snapshot.dart';
import 'control_panel.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.sensorId,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
    required this.status,
    super.key,
    this.progress,
    this.isCritical = false,
  });

  final String sensorId;
  final String label;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;
  final String status;
  final double? progress;
  final bool isCritical;

  @override
  Widget build(BuildContext context) {
    final accent = isCritical ? AppColors.danger : color;
    return ControlPanel(
      borderColor: isCritical
          ? AppColors.danger.withValues(alpha: 0.45)
          : AppColors.panelBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sensorId,
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.9,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.1,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                status.toUpperCase(),
                style: TextStyle(
                  color: accent,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 4,
              value: (progress ?? 0.7).clamp(0, 1),
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
        ],
      ),
    );
  }
}

class ValveMetricCard extends StatelessWidget {
  const ValveMetricCard({
    required this.state,
    required this.isThreat,
    super.key,
  });

  final ValveState state;
  final bool isThreat;

  @override
  Widget build(BuildContext context) {
    final color = isThreat ? AppColors.danger : AppColors.amber;
    return ControlPanel(
      borderColor: isThreat
          ? AppColors.danger.withValues(alpha: 0.45)
          : AppColors.panelBorder,
      child: Row(
        children: [
          SizedBox(
            width: 86,
            height: 86,
            child: CustomPaint(
              painter: _ValveGaugePainter(
                color: color,
                fraction: switch (state) {
                  ValveState.open => 0.86,
                  ValveState.closed => 0.12,
                  ValveState.transitioning => 0.5,
                  ValveState.unknown => 0,
                },
              ),
              child: Icon(
                Icons.settings_input_component_rounded,
                color: color,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MV101',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'INTAKE VALVE',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isThreat ? 'MANUAL' : state.label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isThreat ? 'Override enforced' : 'Remote control enabled',
                  style: TextStyle(color: color, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ValveGaugePainter extends CustomPainter {
  const _ValveGaugePainter({required this.color, required this.fraction});

  final Color color;
  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: size.width / 2 - 5);
    final background = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = AppColors.panelBorder;
    final foreground = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, math.pi * 0.75, math.pi * 1.5, false, background);
    canvas.drawArc(
      rect,
      math.pi * 0.75,
      math.pi * 1.5 * fraction,
      false,
      foreground,
    );
  }

  @override
  bool shouldRepaint(covariant _ValveGaugePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.fraction != fraction;
  }
}
