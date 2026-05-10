// 📁 lib/screens/admin/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        slivers: [

          // ─── Header ─────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1A16),
                border: Border(bottom: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Admin Panel',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                              letterSpacing: 1)),
                      SizedBox(height: 4),
                      Text('Good Morning, Admin 👋',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(AppAssets.ahmed,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.admin_panel_settings,
                              color: AppColors.gold)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ─── Stats Row ────────────────────
                Row(children: [
                  _statCard('0', 'Total Tours', Icons.map_outlined),
                  const SizedBox(width: 12),
                  _statCard('0', 'Pending\nPayments', Icons.pending_outlined),
                  const SizedBox(width: 12),
                  _statCard('0', 'Total Users', Icons.people_outline),
                ]),

                const SizedBox(height: 12),

                Row(children: [
                  _statCard('\$0', 'Revenue', Icons.attach_money,
                      wide: true),
                  const SizedBox(width: 12),
                  _statCard('0.0', 'Avg Rating', Icons.star_outline,
                      wide: true),
                ]),

                const SizedBox(height: 28),

                // ─── Quick Actions ────────────────
                const Text('Quick Actions',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _actionCard(
                      icon: Icons.check_circle_outline,
                      title: 'Approve\nPayments',
                      color: Colors.green,
                      onTap: () => Navigator.pushNamed(
                          context, '/approve-payments'),
                    ),
                    _actionCard(
                      icon: Icons.add_circle_outline,
                      title: 'Create\nNew Tour',
                      color: AppColors.gold,
                      onTap: () =>
                          Navigator.pushNamed(context, '/create-tour'),
                    ),
                    _actionCard(
                      icon: Icons.map_outlined,
                      title: 'Manage\nTours',
                      color: Colors.blueAccent,
                      onTap: () =>
                          Navigator.pushNamed(context, '/manage-tours'),
                    ),
                    _actionCard(
                      icon: Icons.people_outline,
                      title: 'Manage\nUsers',
                      color: Colors.purpleAccent,
                      onTap: () =>
                          Navigator.pushNamed(context, '/manage-users'),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ─── Recent Activity ──────────────
                const Text('Recent Activity',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),

                // Activity list waiting for API integration
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('No recent activity available', style: TextStyle(color: Colors.white54)),
                  )
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon,
      {bool wide = false}) {
    return Expanded(
      flex: wide ? 1 : 1,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.gold, size: 20),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: Colors.white38, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 10),
          Text(title,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  height: 1.3)),
        ]),
      ),
    );
  }

  Widget _activityItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: color.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(
                    color: Colors.white38, fontSize: 12)),
          ]),
        ),
        Text(time,
            style: const TextStyle(color: Colors.white24, fontSize: 11)),
      ]),
    );
  }
}