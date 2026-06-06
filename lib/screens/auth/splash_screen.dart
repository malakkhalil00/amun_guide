// 📁 lib/screens/auth/splash_screen.dart
// ✅ Updated UI — cleaner dark splash matching reference aesthetic

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/dio_client.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Controllers ───────────────────────────────────
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _shimmerController;
  late AnimationController _lineController;
  late AnimationController _bgGlowController;

  // ── Animations ────────────────────────────────────
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _shimmer;
  late Animation<double> _lineWidth;
  late Animation<double> _lineFade;
  late Animation<double> _bgGlow;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _initAnimations();
    _startSequence();
    _checkAuth();
  }

  void _initAnimations() {
    // Logo
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Text
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    // Shimmer
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _shimmer = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Gold line
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _lineWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeOutCubic),
    );
    _lineFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _lineController, curve: Curves.easeOut));

    // Background glow pulse
    _bgGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _bgGlow = Tween<double>(begin: 0.06, end: 0.12).animate(
      CurvedAnimation(parent: _bgGlowController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();
    _lineController.forward();

    await Future.delayed(const Duration(milliseconds: 250));
    _shimmerController.forward();
  }

  // ✅ Logic محمي — لم يتغير
  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;

    final isLoggedIn = await DioClient.isLoggedIn();
    if (isLoggedIn) {
      final userData = await DioClient.getUserData();
      final role = userData['role'] ?? 'tourist';
      if (mounted) {
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else if (role == 'guide') {
          Navigator.pushReplacementNamed(context, '/guide-home');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _shimmerController.dispose();
    _lineController.dispose();
    _bgGlowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // ── Animated background glow ───────────────────────
          AnimatedBuilder(
            animation: _bgGlow,
            builder: (_, __) => Positioned.fill(
              child: CustomPaint(
                painter: _RadialGlowPainter(opacity: _bgGlow.value),
              ),
            ),
          ),

          // ── Subtle Egyptian hieroglyph pattern overlay ─────
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(painter: _PatternPainter()),
            ),
          ),

          // ── Top gold gradient strip ────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.gold,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main content ───────────────────────────────────
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo circle with shimmer
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _logoController,
                    _shimmerController,
                  ]),
                  builder: (_, __) => FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: _LogoWidget(shimmerValue: _shimmer.value),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // App name
                AnimatedBuilder(
                  animation: _textController,
                  builder: (_, __) => FadeTransition(
                    opacity: _textFade,
                    child: SlideTransition(
                      position: _textSlide,
                      child: const Text(
                        'AMUN GUIDE',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 10,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Animated gold line
                AnimatedBuilder(
                  animation: _lineController,
                  builder: (_, __) => FadeTransition(
                    opacity: _lineFade,
                    child: SizeTransition(
                      sizeFactor: _lineWidth,
                      axis: Axis.horizontal,
                      child: Container(
                        width: 100,
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.gold,
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Tagline
                AnimatedBuilder(
                  animation: _textController,
                  builder: (_, __) => FadeTransition(
                    opacity: _subtitleFade,
                    child: SlideTransition(
                      position: _subtitleSlide,
                      child: const Text(
                        'Discover Ancient Egypt',
                        style: TextStyle(
                          color: Colors.white30,
                          fontSize: 13,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom loader ──────────────────────────────────
          Positioned(
            bottom: 52,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _textController,
              builder: (_, child) =>
                  FadeTransition(opacity: _subtitleFade, child: child),
              child: Column(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.gold.withValues(alpha: 0.6),
                      strokeWidth: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Loading your journey...',
                    style: TextStyle(
                      color: Colors.white24,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logo Widget ────────────────────────────────────────────────────────────────
class _LogoWidget extends StatelessWidget {
  final double shimmerValue;
  const _LogoWidget({required this.shimmerValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.bgCard,
        border: Border.all(color: AppColors.borderGold, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.25),
            blurRadius: 40,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.08),
            blurRadius: 80,
            spreadRadius: 20,
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 80,
                height: 80,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.explore_rounded,
                  color: AppColors.gold,
                  size: 54,
                ),
              ),
            ),
            // Shimmer sweep
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(shimmerValue * 180, 0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Radial Glow Painter ────────────────────────────────────────────────────────
class _RadialGlowPainter extends CustomPainter {
  final double opacity;
  const _RadialGlowPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        radius: 0.7,
        colors: [Color.fromRGBO(197, 163, 88, opacity), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_RadialGlowPainter old) => old.opacity != opacity;
}

// ── Subtle Pattern Painter ─────────────────────────────────────────────────────
class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const spacing = 60.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(x, y),
            width: spacing * 0.4,
            height: spacing * 0.4,
          ),
          paint,
        );
        canvas.drawLine(
          Offset(x - spacing * 0.2, y),
          Offset(x + spacing * 0.2, y),
          paint,
        );
        canvas.drawLine(
          Offset(x, y - spacing * 0.2),
          Offset(x, y + spacing * 0.2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
