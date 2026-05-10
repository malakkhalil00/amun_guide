// 📁 lib/screens/auth/forgot_password_screen.dart

import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});
  final _emailController = TextEditingController();
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151411),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Reset Password',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            // صورة القفل
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 240,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/forgot.png',
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, st) => Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2A1A),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.lock_outline,
                        color: Color(0xFFC5A358), size: 80),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            const Text('Forgot Password?',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            const Text(
              "Don't worry, it happens. Enter the email address associated with your account and we'll send you a magic link to reset your password.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.6),
            ),

            const SizedBox(height: 30),

            // Email label
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Email Address',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A241F),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'user@example.com',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // زرار Send
            _SendResetButton(
              emailController: _emailController,
              authService: _authService,
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                        text: 'Remember your password?  ',
                        style: TextStyle(color: Colors.white54, fontSize: 14)),
                    TextSpan(
                        text: 'Log In',
                        style: TextStyle(
                            color: Color(0xFFC5A358),
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
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

class _SendResetButton extends StatefulWidget {
  final TextEditingController emailController;
  final AuthService authService;
  const _SendResetButton({required this.emailController, required this.authService});

  @override
  State<_SendResetButton> createState() => _SendResetButtonState();
}

class _SendResetButtonState extends State<_SendResetButton> {
  bool _isLoading = false;

  Future<void> _sendResetLink() async {
    if (widget.emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.authService.forgotPassword(email: widget.emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reset link sent! Check your email.'),
            backgroundColor: Color(0xFFC5A358),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send reset link. Try again.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _sendResetLink,
        icon: _isLoading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
            : const Icon(Icons.send, color: Colors.black, size: 18),
        label: Text(_isLoading ? 'Sending...' : 'Send Reset Link',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC5A358),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }
}