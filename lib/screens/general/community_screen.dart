// 📁 lib/screens/general/community_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/widgets/amun_filter_chip.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _activeFilter = 0;
  final _filters = ['All', 'Tips', 'Reviews', 'Questions', 'Photos'];

  // Removing static fallback data entirely since it's an API-driven app.
  final List<dynamic> _posts = [];

  List<dynamic> get _filtered => _activeFilter == 0
      ? _posts
      : _posts.where((p) => p.tag == _filters[_activeFilter].replaceAll('s', '')).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(children: [

          // ─── Header ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Community',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () => _showNewPostSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(children: const [
                      Icon(Icons.add, color: Colors.black, size: 16),
                      SizedBox(width: 5),
                      Text('Post',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ─── Filters ────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 20),
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

          // ─── Posts ──────────────────────────────
          Expanded(
            child: _filtered.isEmpty
              ? const Center(child: Text('No posts found', style: TextStyle(color: Colors.white54)))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, i) => const SizedBox.shrink(), // Will build dynamic post card when API is available
                ),
          ),
        ]),
      ),
    );
  }

  void _showNewPostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          const Text('New Post',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: const TextField(
              maxLines: 4,
              style: TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Share your Egypt experience...',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            _attachBtn(Icons.photo_library_outlined, 'Photo'),
            const SizedBox(width: 10),
            _attachBtn(Icons.location_on_outlined, 'Location'),
            const SizedBox(width: 10),
            _attachBtn(Icons.tag, 'Tag'),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Publish Post',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _attachBtn(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: AppColors.bgInput,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white10),
    ),
    child: Row(children: [
      Icon(icon, color: AppColors.gold, size: 16),
      const SizedBox(width: 6),
      Text(label,
          style: const TextStyle(color: Colors.white54, fontSize: 12)),
    ]),
  );
}