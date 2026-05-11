// 📁 lib/screens/tourist/main_navigation.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import '../explore/explore_screen.dart';
import '../explore/tours_screen.dart';
import '../general/about_us_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
   _screens = [
  DashboardScreen(
    onExplore: () => setState(() => _currentIndex = 1),
    onTours: () => setState(() => _currentIndex = 2),
  ),
  const ExploreScreen(),
  const ToursScreen(),
  const AboutUsScreen(),
  const ProfileScreen(),
];
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? AppColors.gold.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.gold : Colors.white30,
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.gold : Colors.white30,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // FAB — Ask AI (يظهر فقط في Home)
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/ai-chat'),
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.black,
              elevation: 4,
              label: const Text('Ask AI',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              icon: const Icon(Icons.auto_awesome, size: 18),
            )
          : null,

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E1A16),
          border: Border(top: BorderSide(color: Colors.white10, width: 1)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, Icons.home_outlined, Icons.home, 'Home'),
            _navItem(1, Icons.explore_outlined, Icons.explore, 'Explore'),
            _navItem(2, Icons.map_outlined, Icons.map, 'Tours'),
            _navItem(3, Icons.info_outline, Icons.info, 'About'),
            _navItem(4, Icons.person_outline, Icons.person, 'Profile'),
          ],
        ),
      ),
    );
  }
}