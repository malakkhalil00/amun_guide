// 📁 lib/screens/auth/onboarding_screen.dart
// ✅ Updated UI — matches reference app style (full-screen image + glassmorphism card)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _current = 0;

  late AnimationController _contentAnimController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      image: AppAssets.onboarding1,
      title: 'Discover Premium\nLiving',
      subtitle:
          'Find the most exclusive properties in Egypt\'s most desirable locations.',
    ),
    _OnboardingData(
      image: AppAssets.onboarding2,
      title: 'Rent Properties\nAround You',
      subtitle:
          'Seamlessly discover and rent high-end apartments with just a few taps.',
    ),
    _OnboardingData(
      image: AppAssets.onboarding3,
      title: 'Invest In Your\nFuture',
      subtitle:
          'Join an elite community of property investors and secure your luxury lifestyle.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _contentAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentFade = CurvedAnimation(
      parent: _contentAnimController,
      curve: Curves.easeOut,
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentAnimController,
            curve: Curves.easeOutCubic,
          ),
        );
    _contentAnimController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _contentAnimController.dispose();
    super.dispose();
  }

  void _next() {
    if (_current < _pages.length - 1) {
      _contentAnimController.reset();
      _controller.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  void _skip() => Navigator.pushReplacementNamed(context, '/welcome');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Full-screen paged images ───────────────────────
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) {
              setState(() => _current = i);
              _contentAnimController.reset();
              _contentAnimController.forward();
            },
            itemCount: _pages.length,
            itemBuilder: (_, i) => _FullScreenImage(image: _pages[i].image),
          ),

          // ── Top bar: logo + skip ───────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo icon
                  Container(
                    width: 40,
                    height: 40,
                    // decoration: BoxDecoration(
                    //   // color: Colors.white.withValues(alpha: 0.15),
                    //   // borderRadius: BorderRadius.circular(10),
                    //   border: Border.all(
                    //     color: Colors.white.withValues(alpha: 0.2),
                    //   ),
                    // ),
                    child: Image.asset(AppAssets.logo, width: 100, height: 100),
                  ),

                  if (_current < _pages.length - 1)
                    GestureDetector(
                      onTap: _skip,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Bottom glassmorphism card ──────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                // Glass effect
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Dots ────────────────────────────────
                      Row(
                        children: List.generate(
                          _pages.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.only(right: 6),
                            width: _current == i ? 28 : 8,
                            height: 4,
                            decoration: BoxDecoration(
                              color: _current == i
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Title ────────────────────────────────
                      FadeTransition(
                        opacity: _contentFade,
                        child: SlideTransition(
                          position: _contentSlide,
                          child: Text(
                            _pages[_current].title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Subtitle ─────────────────────────────
                      FadeTransition(
                        opacity: _contentFade,
                        child: SlideTransition(
                          position: _contentSlide,
                          child: Text(
                            _pages[_current].subtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Next button (circular) ────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Page counter text
                          Text(
                            '${_current + 1} / ${_pages.length}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 13,
                            ),
                          ),

                          // Circular next / get started button
                          GestureDetector(
                            onTap: _next,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _current == _pages.length - 1 ? 160 : 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: _current == _pages.length - 1
                                    ? const Text(
                                        'Get Started',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.black,
                                        size: 24,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

// ── Full Screen Image ─────────────────────────────────────────────────────────
class _FullScreenImage extends StatelessWidget {
  final String image;
  const _FullScreenImage({required this.image});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.bgCard,
            child: const Icon(Icons.image, color: Colors.white12, size: 80),
          ),
        ),
        // Top gradient (for status bar readability)
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [Colors.black.withValues(alpha: 0.4), Colors.transparent],
            ),
          ),
        ),
        // Bottom gradient (blends into glass card)
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.center,
              colors: [Colors.black, Colors.transparent],
              stops: [0.0, 0.6],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────
class _OnboardingData {
  final String image, title, subtitle;
  const _OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}
