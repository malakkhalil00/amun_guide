// 📁 lib/screens/auth/login_screen.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/dio_client.dart';
import '../../core/widgets/ventur_auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nationalIdController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _role = 'tourist';
  final _authService = AuthService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _role = args['role'] ?? 'tourist';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  bool get _isGuide => _role == 'guide';

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
        await DioClient.saveToken(token.toString());
        final backendRole = user['role']?.toString();
        final finalRole = (backendRole != null && backendRole.isNotEmpty)
            ? backendRole
            : _role;
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
      String errorMsg = 'Login failed. Please check your credentials.';
      if (e.response?.data != null && e.response!.data is Map) {
        final errData = e.response!.data as Map;
        errorMsg =
            errData['message']?.toString() ??
            errData['error']?.toString() ??
            errorMsg;
      }
      _showSnackBar(errorMsg, isError: true);
    } catch (e) {
      _showSnackBar(
        'Login failed. Please check your credentials.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.gold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // ── Background image ──────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              AppAssets.karnak3,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppColors.bgDark),
            ),
          ),

          // ── Dark gradient overlay ─────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66000000),
                    Color(0xCC0B0B0F),
                    Color(0xFF0B0B0F),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // ── Gold accent glow ──────────────────────────────────
          Positioned(
            bottom: 350,
            left: -100,
            right: -100,
            child: IgnorePointer(
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: .08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top bar ─────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleIconBtn(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                          RolePill(isGuide: _isGuide),
                        ],
                      ),
                    ),

                    // ── Hero text ────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 48, 28, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isGuide ? 'Welcome\nBack, Guide' : 'Welcome\nBack',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 44,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 40,
                            height: 2,
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isGuide
                                ? 'Sign in to manage your tours'
                                : 'Sign in to continue your adventure',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── Curved card ──────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(42),
                        ),
                        border: Border.all(
                          color: AppColors.borderGold.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Email ────────────────────────────
                          _DarkLabel('Email Address'),
                          const SizedBox(height: 10),
                          _DarkInput(
                            controller: _emailController,
                            hint: 'user@example.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 18),

                          // ── Password ─────────────────────────
                          _DarkLabel('Password'),
                          const SizedBox(height: 10),
                          _DarkInput(
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

                          // ── National ID للـ guide فقط ─────────
                          if (_isGuide) ...[
                            const SizedBox(height: 18),
                            _DarkLabel('National ID'),
                            const SizedBox(height: 10),
                            _DarkInput(
                              controller: _nationalIdController,
                              hint: 'Enter your national ID',
                              icon: Icons.badge_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ],

                          // ── Forgot password ──────────────────
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                '/forgot-password',
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // ── Sign In button ───────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 56,
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
                                  : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── Divider ──────────────────────────
                          Row(
                            children: [
                              Expanded(child: Divider(color: AppColors.border)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                child: Text(
                                  'or continue with',
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: AppColors.border)),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // ── Social buttons ───────────────────
                          Row(
                            children: [
                              Expanded(
                                child: SocialBtn(
                                  label: 'Apple',
                                  onTap: () {
                                    _showSnackBar('Coming soon!');
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SocialBtn(
                                  label: 'Google',
                                  onTap: () {
                                    _showSnackBar('Coming soon!');
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ── Sign up link ─────────────────────
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/register',
                                arguments: {'role': _role},
                              ),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: "Don't have an account?  ",
                                      style: TextStyle(
                                        color: Colors.white54,
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

                          const SizedBox(height: 8),
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

// ── Dark field label ──────────────────────────────────────────────────────────
class _DarkLabel extends StatelessWidget {
  final String text;
  const _DarkLabel(this.text);

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

// ── Dark styled input field ───────────────────────────────────────────────────
class _DarkInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const _DarkInput({
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
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
