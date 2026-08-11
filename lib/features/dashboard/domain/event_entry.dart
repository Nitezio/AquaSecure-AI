enum EventTone { neutral, success, warning, critical }

class EventEntry {
  const EventEntry({
    required this.timestamp,
    required this.title,
    required this.description,
    required this.tone,
  });

  final DateTime timestamp;
  final String title;
  final String description;
  final EventTone tone;
}
