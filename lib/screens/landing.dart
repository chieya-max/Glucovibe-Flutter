import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'dashboard.dart';

// FUTURISTIC ANIMATED LANDING HERO
// - Central holographic device rotates gently
// - Concentric neon rings pulse outward
// - Data streams flow in from the sides and morph into icons
// - Particle field in the background
// - CTA pulses and navigates to Dashboard
// - Reduced motion and static PNG fallback supported

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with TickerProviderStateMixin {
  late final AnimationController introController; // drives the intro (2.5s)
  late final AnimationController idleController; // looping idle animations
  late final Animation<double> introAnim;

  @override
  void initState() {
    super.initState();
    introController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    idleController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();

    introAnim = CurvedAnimation(parent: introController, curve: Curves.easeOutCubic);

    // start the intro
    introController.forward();
  }

  @override
  void dispose() {
    introController.dispose();
    idleController.dispose();
    super.dispose();
  }

  bool get reduceMotion => MediaQuery.of(context).disableAnimations;

  // Colors (teal, indigo, violet)
  final Color teal = const Color(0xFF00D1C1);
  final Color indigo = const Color(0xFF4B6FFF);
  final Color violet = const Color(0xFF8A6CFF);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height >= size.width;
    final base = math.min(size.width, size.height);
    // responsive hero: scale with smallest dimension but clamp to reasonable values
    double heroSize = base * (isPortrait ? 0.62 : 0.42);
    heroSize = heroSize.clamp(220.0, 520.0);
    final isSmallWidth = size.width < 460;

  // Reduced motion / accessibility fallback: show a static image and the CTA
    if (reduceMotion) {
      return Scaffold(
        backgroundColor: const Color(0xFF050814),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Try to show an explicit fallback image; if missing, use the main health_icon
                  Image.asset(
                    'assets/images/landing_fallback.png',
                    width: heroSize,
                    height: heroSize,
                    fit: BoxFit.contain,
                    errorBuilder: (context, _, __) => _EdgeGlowIcon(
                      asset: 'assets/images/health_icon.png',
                      size: heroSize,
                      // static (no animation) for reduced motion
                      pulse: null,
                      glowColor: indigo,
                    ),
                  ),
                  const SizedBox(height: 18),
                  // ignore: deprecated_member_use
                  Text('GlucoVibe', style: TextStyle(color: Colors.white.withOpacity(0.98), fontSize: 28, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  // ignore: deprecated_member_use
                  Text('Personal health monitoring, reimagined', style: TextStyle(color: Colors.white.withOpacity(0.66), fontSize: 14)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DashboardScreen())),
                    child: const Padding(padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), child: Text('Open Dashboard')),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF050814),
      body: SafeArea(
        child: Stack(
          children: [
            // soft particle field background
            Positioned.fill(child: _ParticleField(idleController: idleController)),

            // main content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hero area
                    SizedBox(
                      width: heroSize,
                      height: heroSize * 0.95,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // left & right flowing data streams
                          Positioned.fill(child: _DataStreams(intro: introAnim, teal: teal, indigo: indigo, violet: violet)),

                          // concentric rings (pulsing with intro)
                          _ConcentricRings(intro: introAnim, idleController: idleController, teal: teal, indigo: indigo, violet: violet),

                          // subtle rotating device mockup / hologram
                          _HolographicDevice(intro: introAnim, idleController: idleController),

                          // App logo centered over the holographic device
                          // This places the project's `health_icon.png` at the visual logo position.
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(heroSize * 0.04),
                                  child: _EdgeGlowIcon(
                                    asset: 'assets/images/health_icon.png',
                                    size: heroSize * 0.72,
                                    // animate pulse using the idleController value
                                    pulse: idleController,
                                    glowColor: teal,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Title + subtitle
                    FadeTransition(
                      opacity: introAnim,
                      child: Column(
                        children: [
                          Text('GlucoVibe',
                              style: TextStyle(
                                // ignore: deprecated_member_use
                                color: Colors.white.withOpacity(0.98),
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                shadows: [
                                  // ignore: deprecated_member_use
                                  Shadow(blurRadius: 18, color: indigo.withOpacity(0.32)),
                                  // ignore: deprecated_member_use
                                  Shadow(blurRadius: 28, color: teal.withOpacity(0.18)),
                                ],
                              )),
                          const SizedBox(height: 6),
                          // ignore: deprecated_member_use
                          Text('Personal health monitoring, reimagined', style: TextStyle(color: Colors.white.withOpacity(0.66), fontSize: 14)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Adaptive CTA: full-width on small screens, compact on larger ones
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.96, end: 1.0).animate(CurvedAnimation(parent: introController, curve: const Interval(0.6, 1.0, curve: Curves.elasticOut))),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DashboardScreen())),
                        child: AnimatedBuilder(
                          animation: idleController,
                          builder: (context, child) {
                            final pulse = reduceMotion ? 0.0 : (0.5 + 0.5 * math.sin(idleController.value * 2 * math.pi));
                            // ignore: deprecated_member_use
                            final gradient = LinearGradient(colors: [teal.withOpacity(0.95), indigo.withOpacity(0.95), violet.withOpacity(0.95)]);
                            return ConstrainedBox(
                              constraints: BoxConstraints(minWidth: isSmallWidth ? double.infinity : 140, maxWidth: isSmallWidth ? double.infinity : 380),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: gradient,
                                  borderRadius: BorderRadius.circular(12),
                                  // ignore: deprecated_member_use
                                  boxShadow: [BoxShadow(color: violet.withOpacity(0.12 + 0.06 * pulse), blurRadius: 26 + 8 * pulse, spreadRadius: 1 + 2 * pulse)],
                                ),
                                // ignore: deprecated_member_use
                                child: Text('Get Started', style: TextStyle(color: Colors.white.withOpacity(0.98), fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- Subcomponents --------------------

class _ParticleField extends StatelessWidget {
  final AnimationController idleController;
  const _ParticleField({required this.idleController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: idleController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(idleController.value),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double t;
  _ParticlePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final rng = math.Random(123);
    final base = math.min(size.width, size.height);
    final int count = (base / 6).clamp(20, 140).toInt();

    for (int i = 0; i < count; i++) {
      final ang = (i / count) * 2 * math.pi;
      final r = 0.18 + 0.82 * (rng.nextDouble());
      final speed = 0.2 + rng.nextDouble() * 0.8;
      final x = center.dx + (size.width * 0.55 * r) * math.cos(ang + t * 2 * math.pi * speed);
      final y = center.dy + (size.height * 0.55 * r) * math.sin(ang + t * 2 * math.pi * speed);
      final c = Color.lerp(const Color(0xFF00D1C1), const Color(0xFF8A6CFF), rng.nextDouble())!;
      // ignore: deprecated_member_use
      paint.color = c.withOpacity(0.05 + rng.nextDouble() * 0.12);
      final radius = (0.6 + rng.nextDouble() * 2.2) * (base / 420).clamp(0.6, 2.0);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => oldDelegate.t != t;
}

class _ConcentricRings extends StatelessWidget {
  final Animation<double> intro;
  final AnimationController idleController;
  final Color teal;
  final Color indigo;
  final Color violet;

  const _ConcentricRings({required this.intro, required this.idleController, required this.teal, required this.indigo, required this.violet});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([intro, idleController]),
      builder: (context, child) {
        final pulse = intro.value * 1.0 + 0.08 * math.sin(idleController.value * 2 * math.pi);
        return CustomPaint(
          painter: _RingsPainter(pulse: pulse, teal: teal, indigo: indigo, violet: violet),
        );
      },
    );
  }
}

class _RingsPainter extends CustomPainter {
  final double pulse;
  final Color teal;
  final Color indigo;
  final Color violet;
  _RingsPainter({required this.pulse, required this.teal, required this.indigo, required this.violet});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = math.min(size.width, size.height) * 0.46;
    final paint = Paint()..style = PaintingStyle.stroke;

    for (int i = 0; i < 4; i++) {
      final r = maxR * (0.35 + i * 0.18) * (1.0 + 0.06 * pulse);
      paint.strokeWidth = 1.2 + i * 0.6;
      // ignore: deprecated_member_use
      paint.shader = RadialGradient(colors: [teal.withOpacity(0.08 + 0.02 * i), indigo.withOpacity(0.06 * (i + 1)), violet.withOpacity(0.04)]).createShader(Rect.fromCircle(center: center, radius: r));
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter oldDelegate) => oldDelegate.pulse != pulse;
}

class _HolographicDevice extends StatelessWidget {
  final Animation<double> intro;
  final AnimationController idleController;
  const _HolographicDevice({required this.intro, required this.idleController});

  @override
  Widget build(BuildContext context) {
    final rotate = (1 - intro.value) * 0.18 + 0.02 * math.sin(idleController.value * 2 * math.pi);
    return AnimatedBuilder(
      animation: Listenable.merge([intro, idleController]),
      builder: (context, child) {
        return Transform.rotate(
          angle: rotate,
          child: LayoutBuilder(builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final deviceW = math.min(w, h);
            final devWidth = deviceW * (0.36 + 0.18 * intro.value);
            final devHeight = deviceW * (0.58 + 0.18 * intro.value);
            return Container(
              width: devWidth,
              height: devHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(lerpDouble(14, 28, intro.value) ?? 20),
                gradient: LinearGradient(colors: [const Color(0xAA0B1020), const Color(0x220B1020)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                // ignore: deprecated_member_use
                border: Border.all(color: Colors.white.withOpacity(0.20)),
                // ignore: deprecated_member_use
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 18)],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4), child: Container(color: Colors.transparent))),
                  Positioned(
                      top: devHeight * 0.06,
                      // ignore: deprecated_member_use
                      child: Opacity(opacity: intro.value, child: Icon(Icons.remove_red_eye, color: Colors.white.withOpacity(0.06), size: math.max(14, devWidth * 0.06)))),
                  Container(
                    width: devWidth * (0.36 + 0.18 * intro.value),
                    height: devWidth * (0.36 + 0.18 * intro.value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // ignore: deprecated_member_use
                      gradient: RadialGradient(colors: [const Color(0xFF00D1C1).withOpacity(0.12), const Color(0xFF8A6CFF).withOpacity(0.06)]),
                      // ignore: deprecated_member_use
                      boxShadow: [BoxShadow(color: const Color(0xFF8A6CFF).withOpacity(0.08), blurRadius: 26 * intro.value)],
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

class _DataStreams extends StatelessWidget {
  final Animation<double> intro;
  final Color teal;
  final Color indigo;
  final Color violet;
  // ignore: unused_element_parameter
  const _DataStreams({required this.intro, required this.teal, required this.indigo, required this.violet, super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return Stack(
          children: [
            // left stream
            Positioned(
              left: -w * 0.18 * (1 - intro.value),
              top: h * 0.25,
              child: Transform.rotate(
                angle: -0.18 * (1 - intro.value),
                child: _StreamShape(width: w * 0.42, height: h * 0.18, colors: [teal, indigo, violet], progress: intro.value),
              ),
            ),
            // right stream
            Positioned(
              right: -w * 0.18 * (1 - intro.value),
              top: h * 0.13,
              child: Transform.rotate(
                angle: 0.12 * (1 - intro.value),
                child: _StreamShape(width: w * 0.42, height: h * 0.18, colors: [violet, indigo, teal], progress: intro.value),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _StreamShape extends StatelessWidget {
  final double width;
  final double height;
  final List<Color> colors;
  final double progress; // 0..1
  const _StreamShape({required this.width, required this.height, required this.colors, required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _StreamPainter(colors: colors, t: progress),
      ),
    );
  }
}

class _StreamPainter extends CustomPainter {
  final List<Color> colors;
  final double t;
  _StreamPainter({required this.colors, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, size.height * 0.1);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.35, size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.65, size.width, size.height * 0.8);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // ignore: deprecated_member_use
    paint.shader = LinearGradient(colors: [colors[0].withOpacity(0.28 * t), colors[1].withOpacity(0.22 * t), colors[2].withOpacity(0.18 * t)]).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);

    // small icon at the tip (morphing simulated by opacity)
    // ignore: deprecated_member_use
    final iconPaint = Paint()..color = Colors.white.withOpacity(0.0 + 0.9 * t);
    canvas.drawCircle(Offset(size.width, size.height * 0.8), 8 * t + 2.0, iconPaint);
  }

  @override
  bool shouldRepaint(covariant _StreamPainter oldDelegate) => oldDelegate.t != t;
}

// Edge-following glow helper: draws blurred, color-tinted copies of the image
// behind the original so the glow follows the non-transparent edges of the PNG.
class _EdgeGlowIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Animation<double>? pulse; // optional; if provided the glow will subtly pulse
  final Color glowColor;

  const _EdgeGlowIcon({required this.asset, required this.size, this.pulse, required this.glowColor});

  Widget _buildGlowStack(double p) {
    final glowStrength = 0.6 + 0.5 * p; // 0.6..1.1
    final blurSmall = (6.0 * (0.8 + 0.6 * p)).clamp(2.0, 28.0);
    final blurLarge = (18.0 * (0.6 + 0.6 * p)).clamp(6.0, 48.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer soft halo
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blurLarge, sigmaY: blurLarge),
            child: ColorFiltered(
              // ignore: deprecated_member_use
              colorFilter: ColorFilter.mode(glowColor.withOpacity(0.12 * glowStrength), BlendMode.srcATop),
              child: Image.asset(asset, width: size, height: size, fit: BoxFit.contain),
            ),
          ),

          // Inner brighter glow
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blurSmall, sigmaY: blurSmall),
            child: ColorFiltered(
              // ignore: deprecated_member_use
              colorFilter: ColorFilter.mode(glowColor.withOpacity(0.26 * glowStrength), BlendMode.srcATop),
              child: Image.asset(asset, width: size, height: size, fit: BoxFit.contain),
            ),
          ),

          // Crisp original image on top
          Image.asset(asset, width: size, height: size, fit: BoxFit.contain),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (pulse != null) {
      return AnimatedBuilder(
        animation: pulse!,
        builder: (context, child) {
          return _buildGlowStack(pulse!.value);
        },
      );
    }
    return _buildGlowStack(1.0);
  }
}

// Public wrapper so other screens can reuse the glow aesthetic.
class EdgeGlowIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Animation<double>? pulse;
  final Color glowColor;

  const EdgeGlowIcon({super.key, required this.asset, required this.size, this.pulse, required this.glowColor});

  @override
  Widget build(BuildContext context) {
    return _EdgeGlowIcon(asset: asset, size: size, pulse: pulse, glowColor: glowColor);
  }
}

// KPI cards removed; the logo image is now placed in the hero.

// -------------------- Export guidance --------------------
/*
Notes about exporting to Lottie or Rive:
- This Flutter code is an approximation. Exporting to Lottie or Rive requires building the animation inside the Rive editor or with After Effects + Bodymovin.
- Suggested named states: "intro" (0..2.5s), "idle" (loop), "hover_card" (card hover/expand), "cta_press" (CTA press).
- In Rive: recreate the device, rings, streams, particles, KPI cards as shapes/artboards and add state machine inputs matching the state names above. Export .riv file and add via `rive` package.
- In Lottie: create vector shapes and timeline in After Effects, export JSON with Bodymovin and use `lottie` package in Flutter.

Reduced motion fallback:
- The code respects `MediaQuery.of(context).disableAnimations` via the `reduceMotion` flag and reduces idle pulsing.

Static PNG fallback:
- Provide a static PNG at `assets/images/landing_fallback.png`. In reduced-motion mode, you can display a centered `Image.asset('assets/images/landing_fallback.png')` instead of the animated hero.

Performance notes:
- This implementation uses lightweight CustomPainters and simple animated controllers. If you need a production-ready Lottie/Rive file, export from the respective designer tool and use the packages `lottie` or `rive`.
*/

