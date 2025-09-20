import 'package:flutter/material.dart';
import 'dart:ui';
import 'dashboard.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _blurAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
  _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  // Increased blur range because the logo is larger now
  _blurAnim = Tween<double>(begin: 16.0, end: 32.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  _opacityAnim = Tween<double>(begin: 0.45, end: 0.75).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo with a silhouette-following purple glow effect
              Center(
                child: SizedBox(
                  width: 320,
                  height: 320,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated tinted, blurred duplicate behind the main image to act as a silhouette glow
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return ImageFiltered(
                                imageFilter: ImageFilter.blur(sigmaX: _blurAnim.value, sigmaY: _blurAnim.value),
                                child: ColorFiltered(
                                  // ignore: deprecated_member_use
                                  colorFilter: ColorFilter.mode(Colors.deepPurple.withOpacity(_opacityAnim.value), BlendMode.srcATop),
                                  child: child,
                                ),
                              );
                            },
                            child: Image.asset(
                              'assets/images/health_icon.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),

                      // Main image on top (no white circular background)
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Image.asset(
                          'assets/images/health_icon.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome to GlucoVibe',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Manage glucose, medications and activity all in one place.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DashboardScreen()));
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Text('Open Dashboard', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  // Placeholder for sign in / onboarding
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Onboarding not implemented')));
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Create Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
