// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'profile.dart';
// reuse the edge-glow icon aesthetic
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
    // Neon palette (match landing)
    const background = Color(0xFF050814);
    const teal = Color(0xFF00D1C1);
    const indigo = Color(0xFF4B6FFF);
    const violet = Color(0xFF8A6CFF);
    final medications = [
      {'name': 'Metformin', 'time': '08:00'},
      {'name': 'Insulin (basal)', 'time': '22:00'},
    ];
    final goal = {'target': '70-130 mg/dL', 'progress': 0.6};

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: const [
            // show a compact glowing logo in the app bar
            SizedBox(width: 6),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  const Icon(Icons.person, color: Colors.white70),
                ],
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Glucose card (translucent neon style)
              Container(
                decoration: BoxDecoration(
                  // ignore: duplicate_ignore
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  // ignore: duplicate_ignore
                  // ignore: deprecated_member_use
                  border: Border.all(color: indigo.withOpacity(0.08)),
                  // ignore: duplicate_ignore
                  // ignore: deprecated_member_use
                  boxShadow: [BoxShadow(color: violet.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Latest Glucose', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[200])),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('$latestGlucose', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(width: 8),
                                Text('mg/dL', style: TextStyle(color: Colors.grey[400])),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Trend: $trend', style: const TextStyle(color: Colors.greenAccent)),
                          ],
                        ),
                      ),
                      // Quick action - detailed glucose recording
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: teal),
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
              // Medications (translucent)
              Container(
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  // ignore: duplicate_ignore
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: indigo.withOpacity(0.06)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Medications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[200])),
                      const SizedBox(height: 8),
                      ...medications.map((m) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.medication, color: indigo),
                            title: Text(m['name']!, style: TextStyle(color: Colors.grey[100])),
                            subtitle: Text('Next dose: ${m['time']}', style: TextStyle(color: Colors.grey[400])),
                            trailing: IconButton(
                              icon: Icon(Icons.check_circle_outline, color: teal),
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
              // Goal / progress
              Container(
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: indigo.withOpacity(0.06)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily Goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[200])),
                      const SizedBox(height: 8),
                      Text('Target: ${goal['target']}', style: TextStyle(color: Colors.grey[300])),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: goal['progress'] as double, color: teal, backgroundColor: Colors.white12),
                      const SizedBox(height: 8),
                      Text('${((goal['progress'] as double) * 100).round()}% of goal achieved', style: TextStyle(color: Colors.grey[300])),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Quick actions
              // Quick actions
              Container(
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: indigo.withOpacity(0.05)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[200])),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _QuickAction(
                            icon: Icons.water_drop,
                            label: 'Log Water',
                            labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                            iconColor: violet,
                            onTap: () => _showLogWaterDialog(context),
                          ),
                          _QuickAction(
                            icon: Icons.restaurant,
                            label: 'Log Meal',
                            labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                            iconColor: violet,
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MealTrackerScreen())),
                          ),
                          _QuickAction(
                            icon: Icons.favorite,
                            label: 'Activity',
                            labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                            iconColor: violet,
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
  final TextStyle? labelStyle;
  final Color? iconColor;

  const _QuickAction({required this.icon, required this.label, required this.onTap, this.labelStyle, this.iconColor});

  @override
  Widget build(BuildContext context) {
    final ic = iconColor ?? const Color(0xFF8A6CFF);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: ic.withOpacity(0.12),
            child: Icon(icon, color: ic),
          ),
          const SizedBox(height: 8),
          Text(label, style: labelStyle ?? const TextStyle(fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }
}
