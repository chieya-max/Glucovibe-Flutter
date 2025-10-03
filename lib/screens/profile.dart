import 'package:flutter/material.dart';
import 'dart:ui' show ImageFilter;
import 'dart:math' as math;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Amiel "mahal si tinay" Dioyo');
  final _ageController = TextEditingController(text: '22');
  final _weightController = TextEditingController(text: '69');
  String _diabetesType = 'Type 2';

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      // Placeholder: persist the data
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Neon palette
    const background = Color(0xFF050814);
    const teal = Color(0xFF00D1C1);
    const indigo = Color(0xFF4B6FFF);
    const violet = Color(0xFF8A6CFF);

  // Avatar asset (patient photo placeholder) - rename your image to this filename
  const String avatarAsset = 'assets/images/patient_photo.jpg';

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Container(
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(18),
                    // ignore: deprecated_member_use
                    border: Border.all(color: indigo.withOpacity(0.10)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        // Avatar displayed above the name field
                        Column(
                          children: [
                            Center(
                              child: CornerGlowAvatar(radius: 36 * 2.5, asset: avatarAsset, glowColor: violet),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Full name',
                                labelStyle: const TextStyle(color: Colors.white),
                                filled: true,
                                // ignore: deprecated_member_use
                                fillColor: Colors.white.withOpacity(0.07),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              validator: (v) => (v == null || v.isEmpty) ? 'Enter name' : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Icon(Icons.cake, color: teal, size: 28),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _ageController,
                                decoration: InputDecoration(
                                  labelText: 'Age',
                                  labelStyle: const TextStyle(color: Colors.white),
                                  filled: true,
                                  // ignore: deprecated_member_use
                                  fillColor: Colors.white.withOpacity(0.07),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                keyboardType: TextInputType.number,
                                validator: (v) => (v == null || v.isEmpty) ? 'Enter age' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.monitor_weight, color: indigo, size: 28),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _weightController,
                                decoration: InputDecoration(
                                  labelText: 'Weight (kg)',
                                  labelStyle: const TextStyle(color: Colors.white),
                                  filled: true,
                                  // ignore: deprecated_member_use
                                  fillColor: Colors.white.withOpacity(0.07),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Diabetes type', labelStyle: TextStyle(color: Colors.white)),
                          dropdownColor: background,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          icon: const Icon(Icons.arrow_drop_down, color: violet),
                          initialValue: _diabetesType,
                          items: const [
                            DropdownMenuItem(value: 'Type 1', child: Text('Type 1')), // could add emoji for kids
                            DropdownMenuItem(value: 'Type 2', child: Text('Type 2')),
                            DropdownMenuItem(value: 'Gestational', child: Text('Gestational')),
                          ],
                          onChanged: (v) => setState(() => _diabetesType = v ?? _diabetesType),
                        ),
                        const SizedBox(height: 24),
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
                            icon: const Icon(Icons.save),
                            label: const Text('Save Profile'),
                            onPressed: _save,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// A larger avatar with an animated colored glow traveling near the top-left corner.
class CornerGlowAvatar extends StatefulWidget {
  final double radius;
  final String asset;
  final Color glowColor;

  const CornerGlowAvatar({super.key, required this.radius, required this.asset, required this.glowColor});

  @override
  State<CornerGlowAvatar> createState() => _CornerGlowAvatarState();
}

class _CornerGlowAvatarState extends State<CornerGlowAvatar> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.radius * 2;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // subtle background rim
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.03),
            ),
          ),
          // avatar image
          ClipOval(
            child: Image.asset(widget.asset, width: size - 6, height: size - 6, fit: BoxFit.cover),
          ),
          // animated corner glow — a small blurred circle that orbits near top-left
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) {
                final t = _ctrl.value;
                // compute a position that moves along a small arc near top-left
                final angle = -math.pi / 2 + (t * math.pi / 2); // from top center toward left top
                final r = widget.radius * 0.65; // radius of orbit
                final dx = (size / 2) + (math.cos(angle) * r) - (size / 2);
                final dy = (size / 2) + (math.sin(angle) * r) - (size / 2);
                return Transform.translate(
                  offset: Offset(dx, dy),
                  child: child,
                );
              },
              child: Center(
                child: IgnorePointer(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: widget.glowColor.withOpacity(0.85),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
