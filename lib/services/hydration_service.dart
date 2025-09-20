class HydrationService {
  HydrationService._private();
  static final HydrationService instance = HydrationService._private();

  // In-memory log of drink events (milliliters)
  final List<_DrinkEvent> _events = [];

  /// Log a drink amount in milliliters.
  void logDrinkMl(int ml) {
    _events.add(_DrinkEvent(ml, DateTime.now()));
  }

  /// Log a drink amount provided with a unit. Supported units: 'ml', 'oz', 'cup'.
  /// Example: logDrinkUnit(8, 'oz')
  void logDrinkUnit(double amount, String unit) {
    final ml = _toMl(amount, unit);
    _events.add(_DrinkEvent(ml.round(), DateTime.now()));
  }

  double _toMl(double amount, String unit) {
    switch (unit.toLowerCase()) {
      case 'ml':
        return amount;
      case 'oz':
      case 'fl oz':
        return amount * 29.5735; // fluid ounce to ml
      case 'cup':
        return amount * 240.0; // standard cup ~240 ml
      default:
        return amount; // assume ml
    }
  }

  /// Returns total ml logged for today.
  int todayTotalMl() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return _events.where((e) => e.time.isAfter(start)).fold(0, (p, e) => p + e.ml);
  }

  /// Returns today's total converted to a preferred unit.
  double todayTotalInUnit(String unit) {
    final ml = todayTotalMl();
    switch (unit.toLowerCase()) {
      case 'ml':
        return ml.toDouble();
      case 'oz':
      case 'fl oz':
        return ml / 29.5735;
      case 'cup':
        return ml / 240.0;
      default:
        return ml.toDouble();
    }
  }
}

class _DrinkEvent {
  final int ml;
  final DateTime time;
  _DrinkEvent(this.ml, this.time);
}
