// 📁 lib/screens/auth/reset_password_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/widgets/amun_button.dart';
import '../../core/widgets/amun_input.dart';
import '../../core/widgets/amun_app_bar.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (_newPassword.text.isEmpty || _confirmPassword.text.isEmpty) {
      _showSnackBar('Please fill in all fields', isError: true);
      return;
    }
    if (_newPassword.text != _confirmPassword.text) {
      _showSnackBar('Passwords do not match', isError: true);
      return;
    }
    if (_tokenController.text.isEmpty || _emailController.text.isEmpty) {
      _showSnackBar('Please enter your email and token', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.resetPassword(
        token: _tokenController.text.trim(),
        email: _emailController.text.trim(),
        password: _newPassword.text,
        passwordConfirmation: _confirmPassword.text,
      );
      if (mounted) {
        _showSnackBar('Password reset successfully!', isError: false);
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      _showSnackBar('Failed to reset password. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.gold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: const AmunAppBar(title: 'New Password'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            Center(
              child: Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline,
                    color: AppColors.gold, size: 44),
              ),
            ),

            const SizedBox(height: 32),

            const Text('Create New Password',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              'Enter the reset token sent to your email and create a new password.',
              style: TextStyle(
                  color: Colors.white54, fontSize: 14, height: 1.6),
            ),

            const SizedBox(height: 32),

            AmunInput(
              controller: _emailController,
              hint: 'Email Address',
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 14),

            AmunInput(
              controller: _tokenController,
              hint: 'Reset Token',
              prefixIcon: Icons.vpn_key_outlined,
            ),
            const SizedBox(height: 14),

            AmunInput(
              controller: _newPassword,
              hint: 'New Password',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 14),

            AmunInput(
              controller: _confirmPassword,
              hint: 'Confirm Password',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
            ),

            const SizedBox(height: 28),

            _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : AmunButton(
                    label: 'Reset Password',
                    onTap: _resetPassword,
                    icon: Icons.check,
                  ),
          ],
        ),
      ),
    );
  }
}