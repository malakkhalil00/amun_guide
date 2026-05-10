// 📁 lib/screens/auth/splash_screen.dart

import 'package:flutter/material.dart';
import '../../core/services/dio_client.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final isLoggedIn = await DioClient.isLoggedIn();
    if (isLoggedIn) {
      final userData = await DioClient.getUserData();
      final role = userData['role'] ?? 'tourist';
      if (mounted) {
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin');
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1208),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 120,
              height: 120,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.explore,
                color: Color(0xFFC5A358),
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Amun Guide',
              style: TextStyle(
                color: Color(0xFFC5A358),
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Discover Ancient Egypt',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Color(0xFFC5A358),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}