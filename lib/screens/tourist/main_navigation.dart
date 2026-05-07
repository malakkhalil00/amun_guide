// 📁 lib/screens/tourist/main_navigation.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import '../explore/explore_screen.dart';
import '../explore/tours_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ExploreScreen(),
    ToursScreen(),
    ProfileScreen(),
  ];

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
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.gold,
          unselectedItemColor: Colors.white30,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Tours',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}