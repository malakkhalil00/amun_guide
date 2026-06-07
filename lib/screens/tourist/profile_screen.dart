import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/dio_client.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'User';
  String _email = '';
  String _phone = '';
  String _country = '';
  String _profileImage = '';
  int _trips = 0;
  bool _isLoadingTrips = true;
  final _authService = AuthService();
  Uint8List? _pickedImageBytes;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await DioClient.getUserData();
    if (mounted) {
      setState(() {
        _name = data['name'] ?? 'User';
        _email = data['email'] ?? '';
        _phone = data['phone'] ?? '';
        _country = data['address'] ?? 'Egypt';
        _profileImage = data['profile_image'] ?? '';
        if (_profileImage.startsWith('base64:')) {
          _pickedImageBytes = base64Decode(_profileImage.substring(7));
        }
      });
    }
  }

  Future<void> _loadTrips() async {
    try {
      final dio = DioClient().dio;
      final response = await dio.get('/api/v1/tour-bookings/my-bookings');
      final data = response.data;
      final List items = data['data'] ?? data ?? [];
      if (mounted) setState(() => _trips = items.length);
    } catch (_) {
      if (mounted) setState(() => _trips = 0);
    } finally {
      if (mounted) setState(() => _isLoadingTrips = false);
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _pickedImageBytes = bytes);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile_image', picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ── Header ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Spacer(),
                  const Text(
                    'Profile',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/edit-profile',
                          );
                          if (result == true) _loadUserData();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white10),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: Colors.white54,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Avatar + Name + Email ────────────────
              Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold, width: 2),
                        ),
                        child: ClipOval(
                          child: _pickedImageBytes != null
                              ? Image.memory(
                                  _pickedImageBytes!,
                                  fit: BoxFit.cover,
                                )
                              : _profileImage.isNotEmpty &&
                                    _profileImage.startsWith('http')
                              ? Image.network(
                                  _profileImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person,
                                    color: Colors.white54,
                                    size: 40,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  color: Colors.white54,
                                  size: 40,
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 26,
                            height: 26,
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _email.isEmpty ? 'No email' : _email,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.goldDim,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.gold.withOpacity(0.3),
                            ),
                          ),
                          child: const Text(
                            '✨ Premium Traveler',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Trips stat ───────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.goldDim,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.luggage_rounded,
                        color: AppColors.gold,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Trips',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        _isLoadingTrips
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.gold,
                                ),
                              )
                            : Text(
                                '$_trips Trips',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Account ──────────────────────────────
              _sectionTitle('Account'),
              const SizedBox(height: 10),
              _item(
                Icons.person_outline,
                'Manage Profile',
                onTap: () => Navigator.pushNamed(context, '/edit-profile'),
              ),
              _item(
                Icons.lock_outline,
                'Password & Security',
                onTap: () => Navigator.pushNamed(context, '/forgot-password'),
              ),
              _item(
                Icons.notifications_outlined,
                'Notifications',
                onTap: () => Navigator.pushNamed(context, '/notifications'),
              ),
              _item(
                Icons.bookmark_outline,
                'Saved Places',
                onTap: () => Navigator.pushNamed(context, '/saved-places'),
              ),

              const SizedBox(height: 24),

              // ── Preferences ──────────────────────────
              _sectionTitle('Preferences'),
              const SizedBox(height: 10),
              _item(
                Icons.info_outline,
                'About Us',
                onTap: () => Navigator.pushNamed(context, '/about-us'),
              ),
              _item(Icons.help_outline, 'Help & Support', onTap: () {}),

              const SizedBox(height: 24),

              // ── Logout ───────────────────────────────
              GestureDetector(
                onTap: () => _showLogoutDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.logout, color: Colors.redAccent, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Log Out',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      title,
      style: const TextStyle(
        color: Colors.white38,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  );

  Widget _item(IconData icon, String label, {required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white54, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white24,
                size: 14,
              ),
            ],
          ),
        ),
      );

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log Out',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/welcome',
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Log Out',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
