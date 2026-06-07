// 📁 lib/screens/tourist/main_navigation.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import '../explore/explore_screen.dart';
import '../explore/tours_screen.dart';
import '../booking/my_bookings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _scaleAnims;

  // ── نبني الـ dashboard كل مرة نيجي عليه ──
  DashboardScreen _buildDashboard() => DashboardScreen(
        onExplore: () => setState(() => _currentIndex = 1),
        onTours: () => setState(() => _currentIndex = 2),
      );

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      _buildDashboard(),
      const ExploreScreen(),
      const ToursScreen(),
      const MyBookingsScreen(),
      const ProfileScreen(),
    ];

    _controllers = List.generate(
      5,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );

    _scaleAnims = _controllers.map((c) {
      return Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: c, curve: Curves.easeOut),
      );
    }).toList();

    _controllers[0].forward();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTabTap(int index) {
    if (_currentIndex == index) return;
    _controllers[_currentIndex].reverse();
    _controllers[index].forward();

    setState(() {
      // لما نيجي على الـ Home نعمل rebuild للـ dashboard
      if (index == 0) {
        _screens[0] = _buildDashboard();
      }
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    final items = [
      (Icons.home_outlined, Icons.home_rounded, 'Home'),
      (Icons.explore_outlined, Icons.explore_rounded, 'Explore'),
      (Icons.map_outlined, Icons.map_rounded, 'Tours'),
      (Icons.bookmark_border_rounded, Icons.bookmark_rounded, 'My Trips'),
      (Icons.person_outline, Icons.person_rounded, 'Profile'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (i) => _navItem(
                index: i,
                icon: items[i].$1,
                activeIcon: items[i].$2,
                label: items[i].$3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnims[index],
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.goldDim : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: isActive
                      ? Border.all(color: AppColors.borderGold)
                      : null,
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? AppColors.gold : Colors.white30,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isActive ? AppColors.gold : Colors.white30,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}