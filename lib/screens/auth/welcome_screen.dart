// 📁 lib/screens/auth/welcome_screen.dart
// ✅ New UI — Tourist/Guide toggle + Login form in one screen

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/dio_client.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  // ── Role toggle ────────────────────────────────────
  int _selectedRole = 0; // 0 = tourist, 1 = guide

  // ── Form controllers ───────────────────────────────
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nationalIdController = TextEditingController();

  // ── State ──────────────────────────────────────────
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  // ── Services ───────────────────────────────────────
  final _authService = AuthService();

  // ── Animation ─────────────────────────────────────
  late AnimationController _animController;
  late Animation<double> _fade;
  late Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  // ── Remember Me: load saved credentials ───────────
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('remember_me') ?? false;
    if (remember) {
      final email = prefs.getString('saved_email') ?? '';
      final password = prefs.getString('saved_password') ?? '';
      setState(() {
        _rememberMe = true;
        _emailController.text = email;
        _passwordController.text = password;
      });
    }
  }

  // ── Remember Me: save or clear credentials ─────────
  Future<void> _handleRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('saved_email', _emailController.text.trim());
      await prefs.setString('saved_password', _passwordController.text);
    } else {
      await prefs.setBool('remember_me', false);
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
    }
  }

  bool get _isGuide => _selectedRole == 1;
  String get _roleStr => _isGuide ? 'guide' : 'tourist';

  // ── Login logic (محمي — نفس الـ login_screen الأصلي) ──
  Future<void> _login() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        (_isGuide && _nationalIdController.text.isEmpty)) {
      _showSnackBar('Please fill in all fields', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final data = response.data;
      final token = data['token'] ?? data['data']?['token'] ?? '';
      final user = data['user'] ?? data['data']?['user'] ?? {};

      if (token.toString().isNotEmpty) {
        await _handleRememberMe();
        await DioClient.saveToken(token.toString());
        final backendRole = user['role']?.toString();
        final finalRole = (backendRole != null && backendRole.isNotEmpty)
            ? backendRole
            : _roleStr;
        await DioClient.saveUserData(
          name: user['name'] ?? '',
          email: user['email'] ?? _emailController.text.trim(),
          phone: user['phone'] ?? '',
          address: user['address'] ?? '',
          profileImage: user['profile_image'] ?? '',
          role: finalRole,
          userId: user['id'] ?? 0,
        );
        if (mounted) {
          if (finalRole == 'admin') {
            Navigator.pushReplacementNamed(context, '/admin');
          } else if (finalRole == 'guide') {
            Navigator.pushReplacementNamed(context, '/guide-home');
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      } else {
        _showSnackBar('Login failed. Please try again.', isError: true);
      }
    } on DioException catch (e) {
      String msg = 'Login failed. Please check your credentials.';
      if (e.response?.data != null && e.response!.data is Map) {
        final err = e.response!.data as Map;
        msg = err['message']?.toString() ?? err['error']?.toString() ?? msg;
      }
      _showSnackBar(msg, isError: true);
    } catch (_) {
      _showSnackBar(
        'Login failed. Please check your credentials.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.gold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── Full-screen background image ─────────────
          Positioned.fill(
            child: Image.asset(
              AppAssets.welcomeBg,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF3D2B1A)),
            ),
          ),

          // ── Top gradient ─────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: const Alignment(0, 0.25),
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom gradient ───────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: const Alignment(0, 0.1),
                  colors: [
                    Colors.black.withValues(alpha: 0.9),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.65],
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Logo + app name ─────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          // decoration: BoxDecoration(
                          //   color: Colors.white.withValues(alpha: 0.15),
                          //   borderRadius: BorderRadius.circular(0),
                          //   border: Border.all(
                          //     color: Colors.white.withValues(alpha: 0.2),
                          //   ),
                          // ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              AppAssets.logo,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.explore_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'AMUN GUIDE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Hero heading ────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 40, 28, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Discover Egypt\nLike Never Before',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: List.generate(
                            3,
                            (i) => Container(
                              margin: const EdgeInsets.only(right: 6),
                              width: i == 0 ? 24 : 8,
                              height: 4,
                              decoration: BoxDecoration(
                                color: i == 0
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  // ── Bottom card ─────────────────────────
                  Expanded(
                    child: SlideTransition(
                      position: _cardSlide,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(146, 42, 36, 31),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(36),
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            24,
                            24,
                            24,
                            MediaQuery.of(context).viewInsets.bottom + 32,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Toggle Tourist / Guide ──────
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(
                                    255,
                                    255,
                                    255,
                                    1,
                                  ).withValues(alpha: 0.07),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    _RoleTab(
                                      label: 'Tourist',
                                      isSelected: _selectedRole == 0,
                                      onTap: () =>
                                          setState(() => _selectedRole = 0),
                                    ),
                                    _RoleTab(
                                      label: 'Guide',
                                      isSelected: _selectedRole == 1,
                                      onTap: () =>
                                          setState(() => _selectedRole = 1),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 22),

                              // ── Email ───────────────────────
                              _FieldLabel('Email Address'),
                              const SizedBox(height: 8),
                              _InputField(
                                controller: _emailController,
                                hint: 'user@example.com',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),

                              const SizedBox(height: 16),

                              // ── Password ────────────────────
                              _FieldLabel('Password'),
                              const SizedBox(height: 8),
                              _InputField(
                                controller: _passwordController,
                                hint: '••••••••',
                                icon: Icons.lock_outline,
                                obscure: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.white38,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ),

                              // ── National ID — Guide only ────
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: _isGuide
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 16),
                                          _FieldLabel('National ID'),
                                          const SizedBox(height: 8),
                                          _InputField(
                                            controller: _nationalIdController,
                                            hint: 'Enter your national ID',
                                            icon: Icons.badge_outlined,
                                            keyboardType: TextInputType.number,
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),

                              const SizedBox(height: 14),

                              // ── Remember Me + Forgot Password ─
                              Row(
                                children: [
                                  // Remember Me
                                  GestureDetector(
                                    onTap: () => setState(
                                      () => _rememberMe = !_rememberMe,
                                    ),
                                    child: Row(
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: _rememberMe
                                                ? AppColors.gold
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            border: Border.all(
                                              color: _rememberMe
                                                  ? AppColors.gold
                                                  : Colors.white24,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: _rememberMe
                                              ? const Icon(
                                                  Icons.check,
                                                  color: Colors.black,
                                                  size: 13,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Remember me',
                                          style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const Spacer(),
                                  // Forgot Password
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      '/forgot-password',
                                    ),
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: AppColors.gold,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 22),

                              // ── Sign In button ──────────────
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.gold,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.black,
                                          ),
                                        )
                                      : Text(
                                          'Sign In as ${_isGuide ? 'Guide' : 'Tourist'}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // ── Sign Up link ────────────────
                              Center(
                                child: GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    '/register',
                                    arguments: {'role': _roleStr},
                                  ),
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Don't have an account?  ",
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.4,
                                            ),
                                            fontSize: 13,
                                          ),
                                        ),
                                        const TextSpan(
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
                      ),
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

// ── Role Tab ──────────────────────────────────────────────────────────────────
class _RoleTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? Colors.black
                  : Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Field Label ───────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ── Input Field ───────────────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.gold, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
