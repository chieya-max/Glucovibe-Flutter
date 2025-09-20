import 'package:flutter/material.dart';
import '../services/activity_service.dart';

class ActivityTrackerScreen extends StatefulWidget {
  const ActivityTrackerScreen({super.key});

  @override
  State<ActivityTrackerScreen> createState() => _ActivityTrackerScreenState();
}

class _ActivityTrackerScreenState extends State<ActivityTrackerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();
  String _type = 'Walking';
  String _intensity = 'Moderate';
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _durationController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _log() {
    if (_formKey.currentState!.validate()) {
      final duration = int.tryParse(_durationController.text) ?? 0;
      final weight = double.tryParse(_weightController.text);
      ActivityService.instance.logActivity(type: _type, durationMinutes: duration, intensity: _intensity, userWeightKg: weight);
      _durationController.clear();
      // refresh UI
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Activity logged')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final activities = ActivityService.instance.todayActivities();
    final totalDuration = ActivityService.instance.todayTotalDuration();
    final totalCalories = ActivityService.instance.todayTotalCalories();

    return Scaffold(
      appBar: AppBar(title: const Text('Activity Tracker')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(children: [const Text('Duration'), const SizedBox(height: 8), Text('$totalDuration min')]),
                      Column(children: [const Text('Calories'), const SizedBox(height: 8), Text('${totalCalories.toStringAsFixed(0)} kcal')]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _type,
                            items: const [
                              DropdownMenuItem(value: 'Walking', child: Text('Walking')),
                              DropdownMenuItem(value: 'Running', child: Text('Running')),
                              DropdownMenuItem(value: 'Cycling', child: Text('Cycling')),
                              DropdownMenuItem(value: 'Swimming', child: Text('Swimming')),
                            ],
                            onChanged: (v) => setState(() => _type = v ?? _type),
                            decoration: const InputDecoration(labelText: 'Type'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _intensity,
                            items: const [
                              DropdownMenuItem(value: 'Low', child: Text('Low')),
                              DropdownMenuItem(value: 'Moderate', child: Text('Moderate')),
                              DropdownMenuItem(value: 'High', child: Text('High')),
                            ],
                            onChanged: (v) => setState(() => _intensity = v ?? _intensity),
                            decoration: const InputDecoration(labelText: 'Intensity'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                            validator: (v) => (v == null || v.isEmpty) ? 'Enter duration' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Your weight (kg, optional)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _log, child: const Text('Log Activity')),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: activities.isEmpty
                    ? const Center(child: Text('No activities logged'))
                    : ListView.separated(
                        itemCount: activities.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final a = activities[index];
                          return ListTile(
                            title: Text('${a.type} • ${a.durationMinutes} min'),
                            subtitle: Text('${a.intensity} • ${a.calories.toStringAsFixed(0)} kcal'),
                            trailing: Text(TimeOfDay.fromDateTime(a.time).format(context)),
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
