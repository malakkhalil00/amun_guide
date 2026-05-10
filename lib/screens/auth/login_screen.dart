// ============================================
// 📁 lib/screens/auth/login_screen.dart
// ============================================

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/dio_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _authService = AuthService();

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
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
        await DioClient.saveUserData(
          name: user['name'] ?? '',
          email: user['email'] ?? _emailController.text.trim(),
          phone: user['phone'] ?? '',
          address: user['address'] ?? '',
          profileImage: user['profile_image'] ?? '',
          role: user['role'] ?? 'tourist',
          userId: user['id'] ?? 0,
        );

        if (mounted) {
          final role = user['role'] ?? 'tourist';
          if (role == 'admin') {
            Navigator.pushReplacementNamed(context, '/admin');
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
        errorMsg = errData['message']?.toString() ?? errData['error']?.toString() ?? errorMsg;
      }
      _showSnackBar(errorMsg, isError: true);
    } catch (e) {
      _showSnackBar('Login failed. Please check your credentials.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFFC5A358),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Log In',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // ===== Title =====
            const Text(
              'Welcome Back to\nAmun Guide',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Enter your details to access your premium\ntravel itinerary.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 40),

            // ===== Email =====
            const Text('Email Address',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _emailController,
              hint: 'user@example.com',
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 20),

            // ===== Password =====
            const Text('Password',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A1E),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle:
                  const TextStyle(color: Colors.white38, fontSize: 15),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.white38,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 18),
                ),
              ),
            ),

            // ===== Forgot Password =====
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, '/forgot-password'),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Color(0xFFC5A358),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ===== Log In Button =====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC5A358),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text('Log In',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17)),
              ),
            ),

            const SizedBox(height: 32),

            // ===== Or continue with =====
            Row(
              children: const [
                Expanded(child: Divider(color: Colors.white24)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text('Or continue with',
                      style:
                      TextStyle(color: Colors.white38, fontSize: 13)),
                ),
                Expanded(child: Divider(color: Colors.white24)),
              ],
            ),

            const SizedBox(height: 24),

            // ===== Apple & Google =====
            Row(
              children: [
                Expanded(
                  child: _socialButton(
                    label: 'Apple',
                    icon: Icons.apple,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _socialButton(
                    label: 'Google',
                    icon: Icons.g_mobiledata,
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ===== Sign Up =====
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/register'),
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                          text: "Don't have an account?",
                          style: TextStyle(
                              color: Colors.white54, fontSize: 14)),
                      TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                              color: Color(0xFFC5A358),
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A1E),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
          const TextStyle(color: Colors.white38, fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _socialButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A1E),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}