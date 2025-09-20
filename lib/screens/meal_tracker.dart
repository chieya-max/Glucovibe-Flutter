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
    return Scaffold(
      appBar: AppBar(title: const Text('Meal Tracker')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Calories', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text('$totalCalories kcal', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Sugar', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text('$totalSugar g', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Meal name'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Enter meal name' : null,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _calController,
                            decoration: const InputDecoration(labelText: 'Calories (kcal)'),
                            keyboardType: TextInputType.number,
                            validator: (v) => (v == null || v.isEmpty) ? 'Enter calories' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _sugarController,
                            decoration: const InputDecoration(labelText: 'Sugar (g)'),
                            keyboardType: TextInputType.number,
                            validator: (v) => (v == null || v.isEmpty) ? 'Enter sugar grams' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _addEntry, child: const Text('Add Meal')),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _entries.isEmpty
                    ? const Center(child: Text('No meals logged'))
                    : ListView.separated(
                        itemCount: _entries.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final e = _entries[index];
                          return ListTile(
                            title: Text(e.name),
                            subtitle: Text('${e.calories} kcal • ${e.sugarGrams} g sugar'),
                            trailing: Text(TimeOfDay.fromDateTime(e.time).format(context)),
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
