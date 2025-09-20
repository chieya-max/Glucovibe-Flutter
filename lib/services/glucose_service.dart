class GlucoseReading {
  final int value; // mg/dL
  final String sampleType; // Capillary, Venous, Plasma
  final String context; // Fasting, Pre-meal, Post-meal, Random
  final DateTime time;
  final String? notes;

  GlucoseReading({required this.value, required this.sampleType, required this.context, DateTime? time, this.notes}) : time = time ?? DateTime.now();
}

class GlucoseService {
  GlucoseService._private();
  static final GlucoseService instance = GlucoseService._private();

  final List<GlucoseReading> _readings = [];

  void logReading(GlucoseReading r) => _readings.add(r);

  GlucoseReading? latestReading() {
    if (_readings.isEmpty) return null;
    return _readings.last;
  }

  List<GlucoseReading> todaysReadings() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return _readings.where((r) => r.time.isAfter(start)).toList();
  }
}
