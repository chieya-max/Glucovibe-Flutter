class ActivityEntry {
  final String type; // e.g., Walking, Running
  final int durationMinutes;
  final String intensity; // Low / Moderate / High
  final DateTime time;
  final double calories; // estimated

  ActivityEntry({
    required this.type,
    required this.durationMinutes,
    required this.intensity,
    required this.calories,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

class ActivityService {
  ActivityService._private();
  static final ActivityService instance = ActivityService._private();

  final List<ActivityEntry> _entries = [];

  void logActivity({required String type, required int durationMinutes, required String intensity, double? userWeightKg}) {
    // Estimate calories burned using a very simple MET-based approximation.
    // MET values: walking ~3.5 (moderate), running ~8.0 (high), cycling ~6.0
    final met = _metFor(type, intensity);
    final weight = userWeightKg ?? 70.0; // fallback weight
    // calories = MET * weight(kg) * duration(hours)
    final calories = met * weight * (durationMinutes / 60.0);
    final entry = ActivityEntry(type: type, durationMinutes: durationMinutes, intensity: intensity, calories: calories);
    _entries.add(entry);
  }

  double _metFor(String type, String intensity) {
    final base = (type.toLowerCase().contains('run')) ? 8.0 : (type.toLowerCase().contains('cycle') ? 6.0 : 3.5);
    if (intensity == 'Low') return base * 0.8;
    if (intensity == 'Moderate') return base;
    return base * 1.3; // High
  }

  List<ActivityEntry> todayActivities() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return _entries.where((e) => e.time.isAfter(start)).toList().reversed.toList();
  }

  int todayTotalDuration() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return _entries.where((e) => e.time.isAfter(start)).fold(0, (p, e) => p + e.durationMinutes);
  }

  double todayTotalCalories() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return _entries.where((e) => e.time.isAfter(start)).fold(0.0, (p, e) => p + e.calories);
  }
}
