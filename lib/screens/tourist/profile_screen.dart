// 📁 lib/screens/tourist/profile_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/dio_client.dart';
import '../../core/widgets/amun_app_bar.dart';

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
  int _reviews = 0;
  int _points = 0;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
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
        _trips = data['trips_count'] ?? data['trips'] ?? 0;
        _reviews = data['reviews_count'] ?? data['reviews'] ?? 0;
        _points = data['points'] ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AmunAppBar(
        title: 'My Profile',
        showBack: Navigator.canPop(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white54),
            onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        child: Column(children: [

          const SizedBox(height: 20),

          // ─── Avatar + Name ───────────────────────────
          Center(
            child: Column(children: [
              Stack(children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 2.5),
                  ),
                  child: ClipOval(
                    child: _profileImage.isNotEmpty && _profileImage.startsWith('http')
                        ? Image.network(_profileImage, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.person, color: Colors.white54, size: 50))
                        : Image.asset(AppAssets.sarah, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.person, color: Colors.white54, size: 50)),
                  ),
                ),
                Positioned(bottom: 0, right: 0,
                  child: Container(
                    width: 26, height: 26,
                    decoration: const BoxDecoration(
                        color: AppColors.gold, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.black, size: 14),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Text(_name,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.goldDim,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                ),
                child: const Text('✨ Premium Traveler',
                    style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
          ),

          const SizedBox(height: 24),

          // ─── Stats ───────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statItem('$_trips', 'Trips'),
                _divider(),
                _statItem('$_reviews', 'Reviews'),
                _divider(),
                _statItem('$_points', 'Points'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─── Personal Info ───────────────────────────
          _sectionTitle('Personal Info'),
          const SizedBox(height: 12),
          _infoRow(Icons.email_outlined, 'Email', _email.isEmpty ? 'Not set' : _email),
          _infoRow(Icons.phone_outlined, 'Phone', _phone.isEmpty ? 'Not set' : _phone),
          _infoRow(Icons.flag_outlined, 'Country', _country.isEmpty ? 'Egypt' : _country),
          _infoRow(Icons.language_outlined, 'Language', 'Arabic, English'),

          const SizedBox(height: 24),

          // ─── Settings ────────────────────────────────
          _sectionTitle('Settings'),
          const SizedBox(height: 12),
          _settingsItem(Icons.bookmark_outline, 'Saved Places',
              onTap: () => Navigator.pushNamed(context, '/saved-places')),
          _settingsItem(Icons.notifications_outlined, 'Notifications',
              onTap: () => Navigator.pushNamed(context, '/notifications')),
          _settingsItem(Icons.lock_outline, 'Change Password',
              onTap: () => Navigator.pushNamed(context, '/forgot-password')),
                 _settingsItem(Icons.lock_outline, 'About Us',
              onTap: () => Navigator.pushNamed(context, '/about-us')),
          _settingsItem(Icons.help_outline, 'Help & Support', onTap: () {}),

          const SizedBox(height: 24),

          // ─── Logout ──────────────────────────────────
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
                  Text('Log Out',
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _statItem(String value, String label) => Column(children: [
    Text(value,
        style: const TextStyle(
            color: AppColors.gold,
            fontSize: 22,
            fontWeight: FontWeight.bold)),
    const SizedBox(height: 4),
    Text(label,
        style: const TextStyle(color: Colors.white38, fontSize: 12)),
  ]);

  Widget _divider() => Container(
      width: 1, height: 36, color: Colors.white10);

  Widget _sectionTitle(String title) => Align(
    alignment: Alignment.centerLeft,
    child: Text(title,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold)),
  );

  Widget _infoRow(IconData icon, String label, String value) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white10),
    ),
    child: Row(children: [
      Icon(icon, color: AppColors.gold, size: 18),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
        ]),
      ),
    ]),
  );

  Widget _settingsItem(IconData icon, String label,
      {required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(children: [
            Icon(icon, color: Colors.white54, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white24, size: 14),
          ]),
        ),
      );

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(color: Colors.white54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/welcome', (route) => false);
              }
            },
            child: const Text('Log Out',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}