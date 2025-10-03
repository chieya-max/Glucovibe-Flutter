import 'package:flutter/material.dart';

class HydrationService {
  HydrationService._private() {
    _totalNotifier = ValueNotifier<int>(todayTotalMl());
  }

  static final HydrationService instance = HydrationService._private();

  // In-memory log of drink events (milliliters)
  final List<_DrinkEvent> _events = [];

  // Notifier to allow UI to react to changes in today's total
  late final ValueNotifier<int> _totalNotifier;
  ValueNotifier<int> get totalListenable => _totalNotifier;

  /// Log a drink amount in milliliters.
  void logDrinkMl(int ml) {
    _events.add(_DrinkEvent(ml, DateTime.now()));
    // notify listeners (UI) about the update
    _totalNotifier.value = todayTotalMl();
  }

  /// Log a drink amount provided with a unit. Supported units: 'ml', 'oz', 'cup'.
  /// Example: logDrinkUnit(8, 'oz')
  void logDrinkUnit(double amount, String unit) {
    final ml = _toMl(amount, unit);
    _events.add(_DrinkEvent(ml.round(), DateTime.now()));
    // notify listeners (UI) about the update
    _totalNotifier.value = todayTotalMl();
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

// Reusable themed widget to display today's hydration and quick-log actions.
// This widget is styled to match the dashboard's neon/glass aesthetic.
class HydrationCard extends StatelessWidget {
  final void Function(BuildContext context)? onAddPressed;
  const HydrationCard({super.key, this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    // Palette matching dashboard
    const teal = Color(0xFF00D1C1);
    const indigo = Color(0xFF4B6FFF);
    const violet = Color(0xFF8A6CFF);

    return ValueListenableBuilder<int>(
      valueListenable: HydrationService.instance.totalListenable,
      builder: (context, totalMl, _) {
        return Container(
          decoration: BoxDecoration(
            // dark glass background matching dashboard
            // ignore: deprecated_member_use
            color: const Color(0xFF050814).withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            // ignore: deprecated_member_use
            border: Border.all(color: indigo.withOpacity(0.06)),
            // ignore: deprecated_member_use
            boxShadow: [BoxShadow(color: violet.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hydration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[200])),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$totalMl ml', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 6),
                        Text('${(totalMl / 240.0).toStringAsFixed(1)} cups', style: TextStyle(color: Colors.grey[300])),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: teal),
                      onPressed: () => onAddPressed?.call(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _QuickHydrationButton(amountMl: 250, color: indigo),
                    _QuickHydrationButton(amountMl: 500, color: indigo),
                    _QuickHydrationButton(amountMl: 240 /* 1 cup */, color: violet),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickHydrationButton extends StatelessWidget {
  final int amountMl;
  final Color color;
  const _QuickHydrationButton({required this.amountMl, required this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        // ignore: deprecated_member_use
        backgroundColor: color.withOpacity(0.12),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        HydrationService.instance.logDrinkMl(amountMl);
        final total = HydrationService.instance.todayTotalMl();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logged $amountMl ml — today total: $total ml')));
      },
      child: Text('$amountMl ml'),
    );
  }
}
