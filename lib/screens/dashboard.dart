import 'package:flutter/material.dart';
import 'profile.dart';
import 'meal_tracker.dart';
import '../services/hydration_service.dart';
import 'activity_tracker.dart';
import '../services/glucose_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String trend = 'Stable';

  @override
  void initState() {
    super.initState();
    final latest = GlucoseService.instance.latestReading();
    if (latest != null) {
      // simplistic trend detection placeholder
      trend = 'Stable';
    }
  }

  @override
  Widget build(BuildContext context) {
    final latestGlucose = GlucoseService.instance.latestReading()?.value ?? 128; // mg/dL
    final medications = [
      {'name': 'Metformin', 'time': '08:00'},
      {'name': 'Insulin (basal)', 'time': '22:00'},
    ];
    final goal = {'target': '70-130 mg/dL', 'progress': 0.6};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diabetes Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
            tooltip: 'Profile',
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Glucose card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Latest Glucose', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('$latestGlucose', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                const Text('mg/dL', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Trend: $trend', style: const TextStyle(color: Colors.green)),
                          ],
                        ),
                      ),
                      // Quick action - detailed glucose recording
                      ElevatedButton.icon(
                        onPressed: () => _showRecordDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Record'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Medications
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Medications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      ...medications.map((m) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.medication, color: Colors.blue),
                            title: Text(m['name']!),
                            subtitle: Text('Next dose: ${m['time']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Marked ${m['name']} taken')));
                              },
                            ),
                          )),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Goal / progress
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Daily Goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('Target: ${goal['target']}'),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: goal['progress'] as double),
                      const SizedBox(height: 8),
                      Text('${((goal['progress'] as double) * 100).round()}% of goal achieved'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Quick actions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _QuickAction(
                            icon: Icons.water_drop,
                            label: 'Log Water',
                            onTap: () => _showLogWaterDialog(context),
                          ),
                          _QuickAction(
                            icon: Icons.restaurant,
                            label: 'Log Meal',
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MealTrackerScreen())),
                          ),
                          _QuickAction(
                            icon: Icons.favorite,
                            label: 'Activity',
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ActivityTrackerScreen())),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showRecordDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final valueController = TextEditingController();
    String sampleType = 'Capillary';
    String contextType = 'Fasting';
    final notesController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Record Glucose'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: valueController,
                  decoration: const InputDecoration(labelText: 'Value (mg/dL)'),
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || v.isEmpty) ? 'Enter glucose value' : null,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: sampleType,
                  items: const [
                    DropdownMenuItem(value: 'Capillary', child: Text('Capillary (finger-prick)')),
                    DropdownMenuItem(value: 'Venous', child: Text('Venous')),
                    DropdownMenuItem(value: 'Plasma', child: Text('Plasma')),
                  ],
                  onChanged: (v) => sampleType = v ?? sampleType,
                  decoration: const InputDecoration(labelText: 'Sample type'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: contextType,
                  items: const [
                    DropdownMenuItem(value: 'Fasting', child: Text('Fasting')),
                    DropdownMenuItem(value: 'Pre-meal', child: Text('Pre-meal')),
                    DropdownMenuItem(value: 'Post-meal', child: Text('Post-meal')),
                    DropdownMenuItem(value: 'Random', child: Text('Random')),
                  ],
                  onChanged: (v) => contextType = v ?? contextType,
                  decoration: const InputDecoration(labelText: 'Context'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                ),
                const SizedBox(height: 8),
                const Text('Tip: include meter reading and sample source for better tracking', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final value = int.tryParse(valueController.text) ?? 0;
                final reading = GlucoseReading(value: value, sampleType: sampleType, context: contextType, notes: notesController.text.isEmpty ? null : notesController.text);
                GlucoseService.instance.logReading(reading);
                Navigator.of(ctx).pop();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Glucose $value mg/dL recorded ($contextType)')));
              }
            },
            child: const Text('Save')),
        ],
      ),
    );
  }

  Future<void> _showLogWaterDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController(text: '250');
    String unit = 'ml';

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Water'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      amountController.text = '250'; unit = 'ml';
                    },
                    child: const Text('250 ml'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      amountController.text = '500'; unit = 'ml';
                    },
                    child: const Text('500 ml'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      amountController.text = '1'; unit = 'cup';
                    },
                    child: const Text('1 cup'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      amountController.text = '8'; unit = 'oz';
                    },
                    child: const Text('8 oz'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (v) => (v == null || v.isEmpty) ? 'Enter amount' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: unit,
                items: const [
                  DropdownMenuItem(value: 'ml', child: Text('ml')),
                  DropdownMenuItem(value: 'oz', child: Text('oz')),
                  DropdownMenuItem(value: 'cup', child: Text('cup')),
                ],
                onChanged: (v) => unit = v ?? unit,
                decoration: const InputDecoration(labelText: 'Unit'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final amount = double.tryParse(amountController.text) ?? 0.0;
                HydrationService.instance.logDrinkUnit(amount, unit);
                final totalMl = HydrationService.instance.todayTotalMl();
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logged ${amountController.text} $unit — today total: $totalMl ml')));
                setState(() {});
              }
            },
            child: const Text('Save')),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            // ignore: deprecated_member_use
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
