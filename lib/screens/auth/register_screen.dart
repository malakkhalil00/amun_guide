// ============================================
// 📁 lib/screens/auth/register_screen.dart
// ============================================

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/dio_client.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _profileImagePath;
  String _selectedCountry = 'Egypt';
  String _selectedFlag = '🇪🇬';
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

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _profileImagePath = picked.path);
    }
  }

  Future<void> _register() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      _showSnackBar('Please fill in all fields', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        address: '$_selectedCountry',
        profileImagePath: _profileImagePath,
      );

      final data = response.data;
      final token = data['token'] ?? data['data']?['token'] ?? '';
      final user = data['user'] ?? data['data']?['user'] ?? {};

      if (token.toString().isNotEmpty) {
        await DioClient.saveToken(token.toString());
        await DioClient.saveUserData(
          name: user['name'] ?? _nameController.text.trim(),
          email: user['email'] ?? _emailController.text.trim(),
          phone: user['phone'] ?? _phoneController.text.trim(),
          address: user['address'] ?? _selectedCountry,
          profileImage: user['profile_image'] ?? '',
          role: user['role'] ?? 'tourist',
          userId: user['id'] ?? 0,
        );

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Register',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ===== Profile Image =====
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: const Color(0xFF2A2A1E),
                      backgroundImage: _profileImagePath != null
                          ? FileImage(File(_profileImagePath!))
                          : null,
                      child: _profileImagePath == null
                          ? const Icon(Icons.person, color: Colors.white38, size: 40)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFC5A358),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.black, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ===== Title =====
            const Text(
              'Join Amun Guide',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Create an account to start your premium\nEgyptian journey.',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            // ===== Full Name =====
            _label('Full Name'),
            const SizedBox(height: 10),
            _buildTextField(controller: _nameController, hint: 'John Doe'),
            
            const SizedBox(height: 20),

            // ===== Email =====
            _label('Email'),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _emailController,
              hint: 'john@example.com',
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 20),

            // ===== Phone =====
            _label('Phone'),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _phoneController,
              hint: '01012345678',
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 20),

            // ===== Password =====
            _label('Password'),
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
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 15),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.white38,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ===== Country/Region =====
            _label('Country/Region'),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _showCountryPicker(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A1E),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Text(_selectedFlag, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_selectedCountry,
                          style: const TextStyle(color: Colors.white, fontSize: 15)),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white38),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ===== Create Account Button =====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
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
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Create Account',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // ===== Already have account =====
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(color: Colors.white54, fontSize: 14)),
                      TextSpan(
                          text: 'Login',
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

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(
            child: Text('Select Country',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          ..._countries.map((c) => ListTile(
            leading: Text(c['flag']!, style: const TextStyle(fontSize: 24)),
            title: Text(c['name']!, style: const TextStyle(color: Colors.white)),
            onTap: () {
              setState(() {
                _selectedCountry = c['name']!;
                _selectedFlag = c['flag']!;
              });
              Navigator.pop(ctx);
            },
          )),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: Colors.white54,
          fontSize: 14,
          fontWeight: FontWeight.w500));

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
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}