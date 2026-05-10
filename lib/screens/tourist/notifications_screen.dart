// 📁 lib/screens/tourist/notifications_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/amun_app_bar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _tab = 0;
  final _tabs = ['All', 'Trips', 'System', 'Social'];

  // Removing static fallback data entirely since it's an API-driven app.
  final List<dynamic> _notifications = [];

  List<dynamic> get _filtered => _tab == 0
      ? _notifications
      : _notifications
      .where((n) => n.type == _tabs[_tab])
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: const AmunAppBar(title: 'Notifications'),
      body: Column(children: [

        // Filter Tabs
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_tabs.length, (i) => GestureDetector(
                onTap: () => setState(() => _tab = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _tab == i ? AppColors.gold : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _tab == i
                            ? AppColors.gold
                            : Colors.white12),
                  ),
                  child: Text(_tabs[i],
                      style: TextStyle(
                          color: _tab == i ? Colors.black : Colors.white54,
                          fontSize: 13,
                          fontWeight: _tab == i
                              ? FontWeight.bold
                              : FontWeight.normal)),
                ),
              )),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // List
        Expanded(
          child: _filtered.isEmpty
            ? const Center(child: Text('No notifications right now', style: TextStyle(color: Colors.white54)))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => const SizedBox.shrink(), // Will build dynamic notif card when API is available
              ),
        ),
      ]),
    );
  }
}