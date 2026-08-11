import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/threat_alert.dart';
import 'control_panel.dart';

class ExplainabilityPanel extends StatelessWidget {
  const ExplainabilityPanel({required this.alert, super.key});

  final ThreatAlert? alert;

  @override
  Widget build(BuildContext context) {
    final currentAlert = alert;
    if (currentAlert == null) return const _NoActiveThreat();

    return ControlPanel(
      borderColor: AppColors.danger.withValues(alpha: 0.38),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            eyebrow: 'EXPLAINABLE AI',
            title: 'Why this was flagged',
            trailing: StatusPill(
              label:
                  '${(currentAlert.confidence * 100).toStringAsFixed(1)}% confidence',
              color: AppColors.danger,
              compact: true,
            ),
          ),
          const SizedBox(height: 20),
          _ExplanationBlock(
            icon: Icons.auto_awesome_outlined,
            label: 'MODEL ATTRIBUTION',
            color: AppColors.cyan,
            text: currentAlert.explanation,
          ),
          const SizedBox(height: 12),
          _ExplanationBlock(
            icon: Icons.rule_folder_outlined,
            label: 'PHYSICS INVARIANT',
            color: AppColors.amber,
            text: currentAlert.violatedRule,
          ),
          if (currentAlert.contributors.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text(
              'FEATURE IMPACT',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            for (final contributor in currentAlert.contributors.take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ImpactRow(contribution: contributor),
              ),
          ],
        ],
      ),
    );
  }
}

class _NoActiveThreat extends StatelessWidget {
  const _NoActiveThreat();

  @override
  Widget build(BuildContext context) {
    return ControlPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            eyebrow: 'EXPLAINABLE AI',
            title: 'Decision intelligence',
            trailing: StatusPill(
              label: 'Ready',
              color: AppColors.primary,
              compact: true,
            ),
          ),
          const SizedBox(height: 26),
          Center(
            child: Column(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Icon(
                    Icons.psychology_alt_outlined,
                    color: AppColors.primary,
                    size: 29,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No active anomaly',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                const SizedBox(
                  width: 300,
                  child: Text(
                    'Model attribution and physics-grounded reasons will appear here when the backend raises an alert.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplanationBlock extends StatelessWidget {
  const _ExplanationBlock({
    required this.icon,
    required this.label,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final String label;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.4,
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

class _ImpactRow extends StatelessWidget {
  const _ImpactRow({required this.contribution});

  final FeatureContribution contribution;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 54,
          child: Text(
            contribution.sensor,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: contribution.impact.clamp(0, 1),
              minHeight: 5,
              backgroundColor: AppColors.background,
              color: AppColors.danger,
            ),
          ),
        ),
        const SizedBox(width: 9),
        SizedBox(
          width: 30,
          child: Text(
            '${(contribution.impact * 100).round()}%',
            textAlign: TextAlign.right,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
          ),
        ),
      ],
    );
  }
}
