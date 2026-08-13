import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/event_entry.dart';
import 'control_panel.dart';

class EventLogPanel extends StatelessWidget {
  const EventLogPanel({required this.events, super.key});

  final List<EventEntry> events;

  @override
  Widget build(BuildContext context) {
    return ControlPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            eyebrow: 'AUDIT TRAIL',
            title: 'Recent activity',
            trailing: Text(
              '${events.length.toString().padLeft(2, '0')} EVENTS',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (events.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  'Waiting for facility events...',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ),
            )
          else
            for (var index = 0; index < events.take(5).length; index++)
              _EventRow(
                event: events[index],
                drawLine: index != events.take(5).length - 1,
              ),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.drawLine});

  final EventEntry event;
  final bool drawLine;

  @override
  Widget build(BuildContext context) {
    final color = switch (event.tone) {
      EventTone.neutral => AppColors.cyan,
      EventTone.success => AppColors.primary,
      EventTone.warning => AppColors.amber,
      EventTone.critical => AppColors.danger,
    };
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 18,
            child: Column(
              children: [
                const SizedBox(height: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 7,
                      ),
                    ],
                  ),
                ),
                if (drawLine)
                  Expanded(
                    child: Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      color: AppColors.panelBorder,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: drawLine ? 17 : 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(event.timestamp),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(dateTime.hour)}:${two(dateTime.minute)}:${two(dateTime.second)}';
  }
}
