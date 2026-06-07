// 📁 lib/screens/tourist/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/amun_app_bar.dart';
import '../../core/widgets/amun_button.dart';
import '../../core/widgets/amun_input.dart';
import '../../core/services/dio_client.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  Uint8List? _pickedImageBytes;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final data = await DioClient.getUserData();
    if (!mounted) return;
    final profileImage = data['profile_image'] ?? '';
    setState(() {
      _name.text = data['name'] ?? '';
      _email.text = data['email'] ?? '';
      _phone.text = data['phone'] ?? '';
      _address.text = data['address'] ?? '';
      _isLoading = false;
      if (profileImage.startsWith('base64:')) {
        _pickedImageBytes = base64Decode(profileImage.substring(7));
      }
    });
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final base64Str = base64Encode(bytes);
      setState(() => _pickedImageBytes = bytes);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile_image', 'base64:$base64Str');
    }
  }

  Future<void> _saveProfile() async {
    if (_name.text.trim().isEmpty) {
      _showSnackBar('Please enter your name', isError: true);
      return;
    }
    if (_email.text.trim().isEmpty) {
      _showSnackBar('Please enter your email', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final currentData = await DioClient.getUserData();
      await DioClient.saveUserData(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        address: _address.text.trim(),
        profileImage: currentData['profile_image'],
        role: currentData['role'],
        userId: currentData['user_id'],
      );

      if (!mounted) return;
      _showSnackBar('Profile updated successfully!');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to save. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : AppColors.gold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: const AmunAppBar(title: 'Edit Profile'),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // ── Avatar ──────────────────────────
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.gold,
                              width: 2.5,
                            ),
                          ),
                          child: ClipOval(
                            child: _pickedImageBytes != null
                                ? Image.memory(
                                    _pickedImageBytes!,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.person,
                                    color: Colors.white54,
                                    size: 50,
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: AppColors.gold,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Text(
                    'Tap to change photo',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),

                  const SizedBox(height: 32),

                  AmunInput(
                    controller: _name,
                    hint: 'Full Name',
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 14),

                  AmunInput(
                    controller: _email,
                    hint: 'Email Address',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),

                  AmunInput(
                    controller: _phone,
                    hint: 'Phone Number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),

                  AmunInput(
                    controller: _address,
                    hint: 'Address',
                    prefixIcon: Icons.location_on_outlined,
                  ),

                  const SizedBox(height: 32),

                  _isSaving
                      ? const CircularProgressIndicator(color: AppColors.gold)
                      : AmunButton(
                          label: 'Save Changes',
                          onTap: _saveProfile,
                          icon: Icons.check,
                        ),
                ],
              ),
            ),
    );
  }
}
