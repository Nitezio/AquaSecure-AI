import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/dashboard_controller.dart';
import 'control_panel.dart';

class TelemetryChart extends StatelessWidget {
  const TelemetryChart({
    required this.sensorId,
    required this.title,
    required this.unit,
    required this.samples,
    required this.color,
    required this.minY,
    required this.maxY,
    required this.interval,
    super.key,
    this.warningMin,
    this.warningMax,
  });

  final String sensorId;
  final String title;
  final String unit;
  final List<ChartSample> samples;
  final Color color;
  final double minY;
  final double maxY;
  final double interval;
  final double? warningMin;
  final double? warningMax;

  @override
  Widget build(BuildContext context) {
    final latest = samples.isEmpty ? null : samples.last.value;
    final spots = [
      for (var index = 0; index < samples.length; index++)
        FlSpot(index.toDouble(), samples[index].value),
    ];

    return ControlPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            eyebrow: sensorId,
            title: title,
            trailing: latest == null
                ? null
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: latest.toStringAsFixed(2),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: ' $unit',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'LIVE / 60 SEC',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: samples.length < 2
                ? const _ChartLoadingState()
                : LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: 59,
                      minY: minY,
                      maxY: maxY,
                      clipData: const FlClipData.all(),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: interval,
                        verticalInterval: 10,
                        getDrawingHorizontalLine: (_) => const FlLine(
                          color: Color(0x162B4B57),
                          strokeWidth: 1,
                        ),
                        getDrawingVerticalLine: (_) => const FlLine(
                          color: Color(0x102B4B57),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 15,
                            reservedSize: 25,
                            getTitlesWidget: (value, meta) {
                              final remaining = (59 - value.toInt()).clamp(
                                0,
                                59,
                              );
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  remaining == 0 ? 'NOW' : '-${remaining}s',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: interval,
                            reservedSize: 34,
                            getTitlesWidget: (value, meta) => SideTitleWidget(
                              meta: meta,
                              child: Text(
                                value.toStringAsFixed(value >= 10 ? 0 : 1),
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 8,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          if (warningMin != null) _thresholdLine(warningMin!),
                          if (warningMax != null) _thresholdLine(warningMax!),
                        ],
                      ),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => AppColors.panelLight,
                          getTooltipItems: (spots) => spots
                              .map(
                                (spot) => LineTooltipItem(
                                  '${spot.y.toStringAsFixed(2)} $unit',
                                  const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          color: color,
                          barWidth: 2.2,
                          isCurved: true,
                          curveSmoothness: 0.25,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                color.withValues(alpha: 0.25),
                                color.withValues(alpha: 0.01),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 250),
                  ),
          ),
        ],
      ),
    );
  }

  HorizontalLine _thresholdLine(double y) {
    return HorizontalLine(
      y: y,
      color: AppColors.danger.withValues(alpha: 0.45),
      strokeWidth: 1,
      dashArray: [5, 5],
    );
  }
}

class _ChartLoadingState extends StatelessWidget {
  const _ChartLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'CALIBRATING LIVE FEED',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
