// 📁 lib/screens/auth/welcome_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/widgets/ventur_auth_widgets.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedRole = 0;
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF0B0B0F),
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _selectedRoleStr => _selectedRole == 0 ? 'tourist' : 'guide';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Background ───────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              AppAssets.welcomeBg,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color.fromARGB(255, 139, 109, 60)),
            ),
          ),

          // ── Gradient ─────────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x11000000),
                    Color(0x33000000),
                    Color(0xcc000000),
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // ── Animated content ──────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo + app name top-left
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
                      child: Row(
                        children: [
                          Image.asset(
                            AppAssets.logo,
                            width: 55,
                            height: 55,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.explore,
                              color: AppColors.gold,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'AMUN GUIDE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Hero text ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 60, 28, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Discover Egypt\nLike Never Before',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 46,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 15),
                          // Dot indicators (like reference)
                          Row(
                            children: List.generate(
                              3,
                              (i) => Container(
                                margin: const EdgeInsets.only(right: 6),
                                width: i == 0 ? 20 : 8,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: i == 0 ? Colors.white : Colors.white38,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // ── Curved white card ────────────────────────
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF111315),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(40),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(28, 30, 28, 36),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card heading
                          const Text(
                            'Choose Your Role',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 1),
                          const Text(
                            'Choose how you want to explore the world with Amun Guide',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 22),

                          // ── Tourist card ──────────────────────
                          _VenturRoleCard(
                            emoji: '🧳',
                            title: 'Tourist',
                            desc: 'Explore destinations and book experiences',
                            isSelected: _selectedRole == 0,
                            dark: true,
                            onTap: () => setState(() => _selectedRole = 0),
                          ),

                          const SizedBox(height: 14),

                          // ── Guide card ────────────────────────
                          _VenturRoleCard(
                            emoji: '🗺️',
                            title: 'Guide',
                            desc: 'Create tours and manage travelers',
                            isSelected: _selectedRole == 1,
                            dark: true,
                            onTap: () => setState(() => _selectedRole = 1),
                          ),

                          const SizedBox(height: 26),

                          // ── Continue button ───────────────────
                          // ── Continue button - استبدل VenturPrimaryBtn بده
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                '/login',
                                arguments: {'role': _selectedRoleStr},
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gold,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Continue as ${_selectedRole == 0 ? 'Tourist' : 'Guide'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/register',
                                arguments: {'role': _selectedRoleStr},
                              ),
                              child: RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Don't have an account?  ",
                                      style: TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 13,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Sign Up',
                                      style: TextStyle(
                                        color: AppColors.gold,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ventur Role Card ──────────────────────────────────────────────────────────
class _VenturRoleCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;
  final bool isSelected;
  final bool dark;
  final VoidCallback onTap;

  const _VenturRoleCard({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.isSelected,
    required this.dark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = dark
        ? const Color.fromARGB(255, 15, 16, 20)
        : const Color(0xFFF8FAFC);
    final border = isSelected ? AppColors.gold : Colors.transparent;
    final titleColor = dark ? Colors.white : const Color(0xFF0F172A);
    final descColor = dark ? Colors.white54 : const Color(0xFF64748B);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: isSelected ? 1.5 : 0),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.gold.withValues(alpha: 0.15)
                    : Colors.white10,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    desc,
                    style: TextStyle(
                      color: descColor,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: dark ? Colors.white30 : const Color(0xFFCBD5E1),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
