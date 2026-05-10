// 📁 lib/screens/admin/manage_tours_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/widgets/amun_app_bar.dart';
import '../../core/widgets/amun_filter_chip.dart';

class ManageToursScreen extends StatefulWidget {
  const ManageToursScreen({super.key});

  @override
  State<ManageToursScreen> createState() => _ManageToursScreenState();
}

class _ManageToursScreenState extends State<ManageToursScreen> {
  int _activeFilter = 0;
  final _filters = ['All', 'Active', 'Draft', 'Archived'];

  final List<Map<String, dynamic>> _tours = [];

  List<Map<String, dynamic>> get _filtered => _activeFilter == 0
      ? _tours
      : _tours.where((t) => t['status'] == _filters[_activeFilter]).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AmunAppBar(
        title: 'Manage Tours',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.gold),
            onPressed: () => Navigator.pushNamed(context, '/create-tour'),
          ),
        ],
      ),
      body: Column(children: [

        // ─── Filters ────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_filters.length, (i) => AmunFilterChip(
                label: _filters[i],
                isActive: _activeFilter == i,
                onTap: () => setState(() => _activeFilter = i),
              )),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // ─── List ────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            itemCount: _filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _tourCard(_filtered[i], context),
          ),
        ),
      ]),
    );
  }

  Widget _tourCard(Map<String, dynamic> t, BuildContext context) {
    final status = t['status'] as String;
    Color statusColor = status == 'Active'
        ? Colors.green
        : status == 'Draft'
        ? AppColors.gold
        : Colors.white38;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(children: [

        // Image + overlay
        Stack(children: [
          ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(
              height: 120, width: double.infinity,
              child: Image.asset(t['img'], fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      color: AppColors.bgInput,
                      child: const Icon(Icons.image,
                          color: Colors.white24, size: 40))),
            ),
          ),
          Positioned(
            top: 10, right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.5)),
              ),
              child: Text(status,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ]),

        // Info
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(t['name'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ),
                  Text(t['price'],
                      style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ],
              ),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.location_on_outlined,
                    color: Colors.white38, size: 13),
                const SizedBox(width: 3),
                Text(t['location'],
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12)),
                const SizedBox(width: 12),
                const Icon(Icons.calendar_today_outlined,
                    color: Colors.white38, size: 13),
                const SizedBox(width: 3),
                Text('${t['days']}D',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12)),
                const SizedBox(width: 12),
                const Icon(Icons.people_outline,
                    color: Colors.white38, size: 13),
                const SizedBox(width: 3),
                Text('${t['bookings']} bookings',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12)),
              ]),
              const SizedBox(height: 12),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 12),

              // Actions
              Row(children: [
                _actionBtn(
                  Icons.edit_outlined, 'Edit', Colors.blueAccent,
                      () => Navigator.pushNamed(context, '/create-tour'),
                ),
                const SizedBox(width: 8),
                if (status == 'Active')
                  _actionBtn(
                    Icons.archive_outlined, 'Archive', Colors.white38,
                        () => setState(() => t['status'] = 'Archived'),
                  ),
                if (status == 'Draft')
                  _actionBtn(
                    Icons.publish_outlined, 'Publish', Colors.green,
                        () => setState(() => t['status'] = 'Active'),
                  ),
                if (status == 'Archived')
                  _actionBtn(
                    Icons.unarchive_outlined, 'Restore', AppColors.gold,
                        () => setState(() => t['status'] = 'Active'),
                  ),
                const SizedBox(width: 8),
                _actionBtn(
                  Icons.delete_outline, 'Delete', Colors.red,
                      () => _confirmDelete(context, t),
                ),
              ]),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _actionBtn(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('Delete Tour',
            style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete "${t['name']}"?',
            style: const TextStyle(color: Colors.white54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _tours.remove(t));
              Navigator.pop(context);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}