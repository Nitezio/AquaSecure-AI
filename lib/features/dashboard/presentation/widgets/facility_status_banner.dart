import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/threat_alert.dart';
import 'control_panel.dart';

class FacilityStatusBanner extends StatelessWidget {
  const FacilityStatusBanner({
    required this.alert,
    required this.onAcknowledge,
    super.key,
  });

  final ThreatAlert? alert;
  final VoidCallback onAcknowledge;

  @override
  Widget build(BuildContext context) {
    final isThreat = alert != null;
    final accent = isThreat ? AppColors.danger : AppColors.primary;
    final isCompact = MediaQuery.sizeOf(context).width < 720;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      padding: EdgeInsets.all(isCompact ? 18 : 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isThreat
              ? const [Color(0xFF36131B), Color(0xFF17141A)]
              : const [Color(0xFF0B2626), Color(0xFF0C1C23)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isThreat ? 0.17 : 0.08),
            blurRadius: 28,
          ),
        ],
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusCopy(alert: alert),
                if (isThreat) ...[
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: _AcknowledgeButton(onPressed: onAcknowledge),
                  ),
                ],
              ],
            )
          : Row(
              children: [
                _StatusIcon(isThreat: isThreat),
                const SizedBox(width: 18),
                Expanded(child: _StatusCopy(alert: alert)),
                if (isThreat) ...[
                  const SizedBox(width: 20),
                  _AcknowledgeButton(onPressed: onAcknowledge),
                ] else
                  const StatusPill(
                    label: 'Physics stable',
                    color: AppColors.primary,
                    icon: Icons.verified_user_outlined,
                  ),
              ],
            ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.isThreat});

  final bool isThreat;

  @override
  Widget build(BuildContext context) {
    final color = isThreat ? AppColors.danger : AppColors.primary;
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Icon(
        isThreat ? Icons.warning_amber_rounded : Icons.shield_outlined,
        color: color,
        size: 28,
      ),
    );
  }
}

class _StatusCopy extends StatelessWidget {
  const _StatusCopy({required this.alert});

  final ThreatAlert? alert;

  @override
  Widget build(BuildContext context) {
    final isThreat = alert != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (MediaQuery.sizeOf(context).width < 720) ...[
              _StatusIcon(isThreat: isThreat),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                isThreat ? 'CRITICAL THREAT DETECTED' : 'ALL SYSTEMS SECURE',
                style: TextStyle(
                  color: isThreat
                      ? AppColors.dangerSoft
                      : AppColors.primarySoft,
                  fontSize: MediaQuery.sizeOf(context).width < 720 ? 16 : 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          isThreat
              ? '${alert!.sensor} / ${alert!.message}'
              : 'No anomalous process behavior detected. Automated monitoring is active across all six treatment stages.',
          style: TextStyle(
            color: isThreat ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 13,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _AcknowledgeButton extends StatelessWidget {
  const _AcknowledgeButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      key: const Key('acknowledge-alert-button'),
      onPressed: onPressed,
      icon: const Icon(Icons.task_alt_rounded, size: 18),
      label: const Text('ACKNOWLEDGE ALARM'),
      style: FilledButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppColors.danger,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
