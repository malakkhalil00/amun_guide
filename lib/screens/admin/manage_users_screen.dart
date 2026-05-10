// 📁 lib/screens/admin/manage_users_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/widgets/amun_app_bar.dart';
import '../../core/widgets/amun_filter_chip.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  int _activeFilter = 0;
  final _filters = ['All', 'Tourist', 'Local', 'Business', 'Banned'];
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _users = [];

  List<Map<String, dynamic>> get _filtered {
    var list = _activeFilter == 0
        ? _users
        : _users.where((u) {
      if (_filters[_activeFilter] == 'Banned') {
        return u['status'] == 'Banned';
      }
      return u['type'] == _filters[_activeFilter];
    }).toList();

    final q = _searchController.text.toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((u) =>
      u['name'].toLowerCase().contains(q) ||
          u['email'].toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: const AmunAppBar(title: 'Manage Users'),
      body: Column(children: [

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(children: [

            // Search
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(children: [
                const Icon(Icons.search, color: Colors.white38, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Search by name or email...',
                      hintStyle: TextStyle(
                          color: Colors.white38, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 12),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_filters.length, (i) => AmunFilterChip(
                  label: _filters[i],
                  isActive: _activeFilter == i,
                  onTap: () => setState(() => _activeFilter = i),
                )),
              ),
            ),
          ]),
        ),

        const SizedBox(height: 14),

        // List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            itemCount: _filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _userCard(_filtered[i]),
          ),
        ),
      ]),
    );
  }

  Widget _userCard(Map<String, dynamic> u) {
    final isBanned = u['status'] == 'Banned';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBanned
              ? Colors.red.withOpacity(0.3)
              : Colors.white10,
        ),
      ),
      child: Row(children: [

        // Avatar
        Stack(children: [
          ClipOval(
            child: SizedBox(
              width: 46, height: 46,
              child: Image.asset(u['avatar'], fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      color: AppColors.bgInput,
                      child: const Icon(Icons.person,
                          color: Colors.white38))),
            ),
          ),
          if (isBanned)
            Positioned(
              bottom: 0, right: 0,
              child: Container(
                width: 16, height: 16,
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.block,
                    color: Colors.white, size: 10),
              ),
            ),
        ]),

        const SizedBox(width: 12),

        // Info
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(u['name'],
                style: TextStyle(
                    color: isBanned ? Colors.white38 : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const SizedBox(height: 2),
            Text(u['email'],
                style: const TextStyle(
                    color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 4),
            Row(children: [
              _typeBadge(u['type']),
              const SizedBox(width: 8),
              Text('${u['trips']} trips',
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 11)),
              const SizedBox(width: 8),
              Text('Joined ${u['joined']}',
                  style: const TextStyle(
                      color: Colors.white24, fontSize: 11)),
            ]),
          ]),
        ),

        // Action button
        GestureDetector(
          onTap: () => _showUserActions(u),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(Icons.more_vert,
                color: Colors.white38, size: 18),
          ),
        ),
      ]),
    );
  }

  Widget _typeBadge(String type) {
    Color color;
    switch (type) {
      case 'Local':    color = Colors.blueAccent;   break;
      case 'Business': color = Colors.purpleAccent; break;
      default:         color = AppColors.gold;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(type,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _showUserActions(Map<String, dynamic> u) {
    final isBanned = u['status'] == 'Banned';
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Text(u['name'],
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _sheetAction(
            Icons.visibility_outlined, 'View Profile', Colors.white,
                () => Navigator.pop(context),
          ),
          const SizedBox(height: 10),
          _sheetAction(
            Icons.email_outlined, 'Send Message', Colors.blueAccent,
                () => Navigator.pop(context),
          ),
          const SizedBox(height: 10),
          _sheetAction(
            isBanned ? Icons.check_circle_outline : Icons.block_outlined,
            isBanned ? 'Unban User' : 'Ban User',
            isBanned ? Colors.green : Colors.red,
                () {
              setState(() => u['status'] = isBanned ? 'Active' : 'Banned');
              Navigator.pop(context);
            },
          ),
        ]),
      ),
    );
  }

  Widget _sheetAction(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ]),
      ),
    );
  }
}