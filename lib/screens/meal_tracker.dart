import 'package:flutter/material.dart';

class MealTrackerScreen extends StatefulWidget {
  const MealTrackerScreen({super.key});

  @override
  State<MealTrackerScreen> createState() => _MealTrackerScreenState();
}

class MealEntry {
  final String name;
  final int calories;
  final int sugarGrams;
  final DateTime time;

  MealEntry({required this.name, required this.calories, required this.sugarGrams, DateTime? time}) : time = time ?? DateTime.now();
}

class _MealTrackerScreenState extends State<MealTrackerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _calController = TextEditingController();
  final _sugarController = TextEditingController();

  final List<MealEntry> _entries = [];

  @override
  void dispose() {
    _nameController.dispose();
    _calController.dispose();
    _sugarController.dispose();
    super.dispose();
  }

  void _addEntry() {
    if (_formKey.currentState!.validate()) {
      final entry = MealEntry(
        name: _nameController.text.trim(),
        calories: int.tryParse(_calController.text) ?? 0,
        sugarGrams: int.tryParse(_sugarController.text) ?? 0,
      );
      setState(() {
        _entries.insert(0, entry);
        _nameController.clear();
        _calController.clear();
        _sugarController.clear();
      });
    }
  }

  int get totalCalories => _entries.fold(0, (p, e) => p + e.calories);
  int get totalSugar => _entries.fold(0, (p, e) => p + e.sugarGrams);

  @override
  Widget build(BuildContext context) {
    // Neon palette
    const background = Color(0xFF050814);
    const teal = Color(0xFF00D1C1);
    const indigo = Color(0xFF4B6FFF);
    const violet = Color(0xFF8A6CFF);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Meal Tracker', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Summary card
              Container(
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(18),
                  // ignore: deprecated_member_use
                  border: Border.all(color: indigo.withOpacity(0.10)),
                  // ignore: deprecated_member_use
                  boxShadow: [BoxShadow(color: violet.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 8))],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.fastfood, color: teal, size: 32),
                          const SizedBox(height: 6),
                          Text('$totalCalories kcal', style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                          const Text('Calories', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.cake, color: violet, size: 32),
                          const SizedBox(height: 6),
                          Text('$totalSugar g', style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                          const Text('Sugar', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Form card
              Container(
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(18),
                  // ignore: deprecated_member_use
                  border: Border.all(color: teal.withOpacity(0.10)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Meal name',
                            labelStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            // ignore: deprecated_member_use
                            fillColor: Colors.white.withOpacity(0.07),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          validator: (v) => (v == null || v.isEmpty) ? 'Enter meal name' : null,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _calController,
                                decoration: InputDecoration(
                                  labelText: 'Calories (kcal)',
                                  labelStyle: const TextStyle(color: Colors.white),
                                  filled: true,
                                  // ignore: deprecated_member_use
                                  fillColor: Colors.white.withOpacity(0.07),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                keyboardType: TextInputType.number,
                                validator: (v) => (v == null || v.isEmpty) ? 'Enter calories' : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _sugarController,
                                decoration: InputDecoration(
                                  labelText: 'Sugar (g)',
                                  labelStyle: const TextStyle(color: Colors.white),
                                  filled: true,
                                  // ignore: deprecated_member_use
                                  fillColor: Colors.white.withOpacity(0.07),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                keyboardType: TextInputType.number,
                                validator: (v) => (v == null || v.isEmpty) ? 'Enter sugar grams' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Add Meal'),
                            onPressed: _addEntry,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: _entries.isEmpty
                    ? const Center(child: Text('No meals yet! Try adding one.', style: TextStyle(color: Colors.white, fontSize: 16)))
                    : ListView.separated(
                        itemCount: _entries.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white24),
                        itemBuilder: (context, index) {
                          final e = _entries[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              leading: Icon(Icons.fastfood, color: indigo, size: 32),
                              title: Text(e.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Text('${e.calories} kcal • ${e.sugarGrams} g sugar', style: const TextStyle(color: Colors.white70)),
                              trailing: Text(TimeOfDay.fromDateTime(e.time).format(context), style: const TextStyle(color: Colors.white)),
                            ),
                          );
                        },
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
