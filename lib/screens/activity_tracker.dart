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
        title: const Text('Activity Tracker', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary card
              Container(
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(18),
                  // ignore: deprecated_member_use
                  border: Border.all(color: violet.withOpacity(0.10)),
                  // ignore: deprecated_member_use
                  boxShadow: [BoxShadow(color: indigo.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 8))],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.timer, color: teal, size: 32),
                          const SizedBox(height: 6),
                          Text('$totalDuration min', style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                          const Text('Total Time', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.local_fire_department, color: violet, size: 32),
                          const SizedBox(height: 6),
                          Text('${totalCalories.toStringAsFixed(0)} kcal', style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                          const Text('Calories', style: TextStyle(color: Colors.white70, fontSize: 13)),
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
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(labelText: 'Type', labelStyle: TextStyle(color: Colors.white)),
                                dropdownColor: background,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                icon: const Icon(Icons.arrow_drop_down, color: violet),
                                initialValue: _type,
                                items: const [
                                  DropdownMenuItem(value: 'Walking', child: Text('🚶 Walking')),
                                  DropdownMenuItem(value: 'Running', child: Text('🏃 Running')),
                                  DropdownMenuItem(value: 'Cycling', child: Text('🚴 Cycling')),
                                  DropdownMenuItem(value: 'Swimming', child: Text('🏊 Swimming')),
                                ],
                                onChanged: (v) => setState(() => _type = v ?? _type),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(labelText: 'Intensity', labelStyle: TextStyle(color: Colors.white)),
                                dropdownColor: background,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                icon: const Icon(Icons.arrow_drop_down, color: teal),
                                initialValue: _intensity,
                                items: const [
                                  DropdownMenuItem(value: 'Low', child: Text('🌱 Low')),
                                  DropdownMenuItem(value: 'Moderate', child: Text('🌿 Moderate')),
                                  DropdownMenuItem(value: 'High', child: Text('🔥 High')),
                                ],
                                onChanged: (v) => setState(() => _intensity = v ?? _intensity),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _durationController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Duration (min)',
                                  labelStyle: const TextStyle(color: Colors.white),
                                  filled: true,
                                  // ignore: deprecated_member_use
                                  fillColor: Colors.white.withOpacity(0.07),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                validator: (v) => (v == null || v.isEmpty) ? 'Enter duration' : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _weightController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Weight (kg, optional)',
                                  labelStyle: const TextStyle(color: Colors.white),
                                  filled: true,
                                  // ignore: deprecated_member_use
                                  fillColor: Colors.white.withOpacity(0.07),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: violet,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Log Activity'),
                            onPressed: _log,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: activities.isEmpty
                    ? const Center(child: Text('No activities yet! Try logging one.', style: TextStyle(color: Colors.white, fontSize: 16)))
                    : ListView.separated(
                        itemCount: activities.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white24),
                        itemBuilder: (context, index) {
                          final a = activities[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              leading: Icon(
                                a.type == 'Walking' ? Icons.directions_walk :
                                a.type == 'Running' ? Icons.directions_run :
                                a.type == 'Cycling' ? Icons.pedal_bike :
                                a.type == 'Swimming' ? Icons.pool : Icons.sports,
                                color: teal,
                                size: 32,
                              ),
                              title: Text('${a.type} • ${a.durationMinutes} min', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Text('${a.intensity} • ${a.calories.toStringAsFixed(0)} kcal', style: const TextStyle(color: Colors.white70)),
                              trailing: Text(TimeOfDay.fromDateTime(a.time).format(context), style: const TextStyle(color: Colors.white)),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
