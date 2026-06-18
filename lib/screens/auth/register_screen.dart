// 📁 lib/screens/auth/register_screen.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/dio_client.dart';
import '../../core/widgets/ventur_auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  final _languagesController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _profileImagePath;
  String _selectedCountry = 'Egypt';
  String _selectedFlag = '🇪🇬';
  String _role = 'tourist';
  final _authService = AuthService();

  final List<Map<String, String>> _countries = [
    {'flag': '🇺🇸', 'name': 'United States'},
    {'flag': '🇪🇬', 'name': 'Egypt'},
    {'flag': '🇬🇧', 'name': 'United Kingdom'},
    {'flag': '🇩🇪', 'name': 'Germany'},
    {'flag': '🇫🇷', 'name': 'France'},
    {'flag': '🇸🇦', 'name': 'Saudi Arabia'},
    {'flag': '🇦🇪', 'name': 'UAE'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    print('📦 Args received: $args');
    if (args is Map<String, dynamic>) {
      _role = args['role'] ?? 'tourist';
      print('🎭 Role set to: $_role');
    }
  }

  bool get _isGuide => _role == 'guide';

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _profileImagePath = picked.path);
  }

  Future<void> _register() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      _showSnackBar('Please fill in all fields', isError: true);
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        address: _selectedCountry,
        role: _role,
        nationalId: _isGuide ? _experienceController.text.trim() : null,
        profileImagePath: _profileImagePath,
      );
      final data = response.data;
      final token = data['token'] ?? data['data']?['token'] ?? '';
      final user = data['user'] ?? data['data']?['user'] ?? {};
      if (token.toString().isNotEmpty) {
        await DioClient.saveToken(token.toString());
        final finalRole = _role;
        await DioClient.saveUserData(
          name: user['name'] ?? _nameController.text.trim(),
          email: user['email'] ?? _emailController.text.trim(),
          phone: user['phone'] ?? _phoneController.text.trim(),
          address: user['address'] ?? _selectedCountry,
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
        _showSnackBar('Registration successful! Please login.', isError: false);
        if (mounted) Navigator.pop(context);
      }
    } on DioException catch (e) {
      String errorMsg = 'Registration failed. Please try again.';
      if (e.response?.data != null && e.response!.data is Map) {
        final errData = e.response!.data as Map;
        if (errData['errors'] != null && errData['errors'] is Map) {
          final errors = errData['errors'] as Map;
          errorMsg = errors.values.first is List
              ? (errors.values.first as List).first.toString()
              : errors.values.first.toString();
        } else {
          errorMsg = errData['message']?.toString() ?? errorMsg;
        }
      }
      _showSnackBar(errorMsg, isError: true);
    } catch (e) {
      _showSnackBar('Registration failed. Please try again.', isError: true);
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
              _isGuide ? AppAssets.siwa : AppAssets.karnak3,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppColors.bgDark),
            ),
          ),

          // ── Dark gradient overlay (نفس الـ login) ────────────
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

          // ── Content ───────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top bar ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleIconBtn(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      RolePill(
                        isGuide: _isGuide,
                        label:
                            'Signing up as ${_isGuide ? 'Guide' : 'Tourist'}',
                      ),
                    ],
                  ),
                ),

                // ── Hero heading ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 36, 28, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isGuide ? 'Join as a\nGuide.' : 'Create\nAccount.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w800, // ✅ bold
                          height: 1.15,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _isGuide
                            ? 'Create your guide profile'
                            : 'Start your adventure today',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── ✅ الكارد بياخد باقي الشاشة ويسكرول من جوه ──
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(146, 42, 36, 31),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(36),
                      ),
                      border: Border.all(
                        color: const Color.fromARGB(
                          0,
                          197,
                          163,
                          88,
                        ).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 30, 28, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Avatar picker ──────────────────────
                          Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 78,
                                    height: 78,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.bgInput,
                                      border: Border.all(
                                        color: AppColors.borderGold,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: _profileImagePath != null
                                          ? Image.file(
                                              File(_profileImagePath!),
                                              fit: BoxFit.cover,
                                            )
                                          : const Icon(
                                              Icons.person,
                                              color: Colors.white38,
                                              size: 36,
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: AppColors.gold,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.bgCard,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.black,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 26),

                          Text(
                            'Basic Information',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _DarkLabel('Full Name'),
                          const SizedBox(height: 8),
                          _DarkInput(
                            controller: _nameController,
                            hint: 'John Doe',
                            icon: Icons.person_outline,
                          ),

                          const SizedBox(height: 16),

                          _DarkLabel('Email'),
                          const SizedBox(height: 8),
                          _DarkInput(
                            controller: _emailController,
                            hint: 'john@example.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 16),

                          _DarkLabel('Phone'),
                          const SizedBox(height: 8),
                          _DarkInput(
                            controller: _phoneController,
                            hint: '01012345678',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 16),

                          _DarkLabel('Password'),
                          const SizedBox(height: 8),
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

                          const SizedBox(height: 16),

                          _DarkLabel('Confirm Password'),
                          const SizedBox(height: 8),
                          _DarkInput(
                            controller: _confirmPasswordController,
                            hint: '••••••••',
                            icon: Icons.lock_outline,
                            obscure: _obscureConfirm,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.white38,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          _DarkLabel('Country'),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _showCountryPicker(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.bgInput,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: .08),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.flag_outlined,
                                    color: AppColors.gold,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '$_selectedFlag $_selectedCountry',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white38,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          if (_isGuide) ...[
                            const SizedBox(height: 28),
                            Text(
                              'Guide Information',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                top: 12,
                                bottom: 16,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.goldDim,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderGold),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppColors.gold,
                                    size: 14,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Guide profile fields will be available after account creation',
                                      style: TextStyle(
                                        color: AppColors.gold,
                                        fontSize: 11,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _DarkLabel('National ID'),
                            const SizedBox(height: 8),
                            _DarkInput(
                              controller: _experienceController,
                              hint: 'Enter your national ID',
                              icon: Icons.badge_outlined,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            _DarkLabel('Languages Spoken'),
                            const SizedBox(height: 8),
                            _DarkInput(
                              controller: _languagesController,
                              hint: 'e.g. Arabic, English, French',
                              icon: Icons.language_outlined,
                              enabled: false,
                            ),
                            const SizedBox(height: 16),
                            _DarkLabel('Short Biography'),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.bgInput.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: .05),
                                ),
                              ),
                              child: TextField(
                                controller: _bioController,
                                maxLines: 3,
                                enabled: false,
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 14,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Tell travelers about yourself...',
                                  hintStyle: TextStyle(
                                    color: Colors.white24,
                                    fontSize: 13,
                                  ),
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.only(
                                      left: 12,
                                      right: 8,
                                      top: 12,
                                    ),
                                    child: Icon(
                                      Icons.description_outlined,
                                      color: Colors.white24,
                                      size: 20,
                                    ),
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                    minWidth: 0,
                                    minHeight: 0,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),

                          // ── Register button (Gold) ─────────────
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  255,
                                  255,
                                  255,
                                ),
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
                                      _isGuide
                                          ? 'Create Guide Account'
                                          : 'Create Account',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Already have an account?  ',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 13,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Sign In',
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

                          const SizedBox(height: 12),
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
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select Country',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._countries.map(
            (c) => ListTile(
              leading: Text(c['flag']!, style: const TextStyle(fontSize: 22)),
              title: Text(
                c['name']!,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                setState(() {
                  _selectedCountry = c['name']!;
                  _selectedFlag = c['flag']!;
                });
                Navigator.pop(ctx);
              },
            ),
          ),
          const SizedBox(height: 20),
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

// ── Dark styled input ─────────────────────────────────────────────────────────
class _DarkInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final bool enabled;

  const _DarkInput({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: enabled
            ? AppColors.bgInput
            : AppColors.bgInput.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: enabled
              ? Colors.white.withValues(alpha: .08)
              : Colors.white.withValues(alpha: .04),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        enabled: enabled,
        style: TextStyle(
          color: enabled ? Colors.white : Colors.white38,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
          prefixIcon: Icon(
            icon,
            color: enabled ? AppColors.gold : Colors.white24,
            size: 20,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
