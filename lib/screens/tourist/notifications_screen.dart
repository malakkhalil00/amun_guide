// 📁 lib/screens/tourist/notifications_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/amun_app_bar.dart';
import '../../features/profile/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // ── Load Notifications ────────────────────
  Future<void> _loadNotifications() async {
    // TODO: لما الـ API يجهز — استبدل الـ dummy data بالكود ده
    // try {
    //   final response = await _dio.get(Api.notifications);
    //   if (response.statusCode == 200) {
    //     final list = (response.data['data'] as List)
    //         .map((e) => NotificationModel.fromJson(e))
    //         .toList();
    //     setState(() { _notifications = list; _isLoading = false; });
    //   }
    // } catch (e) {
    //   setState(() => _isLoading = false);
    // }

    // ── Dummy data ───────────────────────────
    await Future.delayed(const Duration(milliseconds: 600)); // simulate network
    if (!mounted) return;
    setState(() {
      _notifications = _dummyNotifications();
      _isLoading = false;
    });
  }

  // ── Mark as Read ──────────────────────────
  void _markAsRead(int id) {
    setState(() {
      _notifications = _notifications.map((n) {
        return n.id == id ? n.copyWith(isRead: true) : n;
      }).toList();
    });

    // TODO: لما الـ API يجهز
    // _dio.post(Api.markNotificationRead(id));
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
    });

    // TODO: لما الـ API يجهز
    // _dio.post(Api.markAllNotificationsRead);
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AmunAppBar(
        title: 'Notifications',
        actions: _unreadCount > 0
            ? [
                TextButton(
                  onPressed: _markAllAsRead,
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(color: AppColors.gold, fontSize: 12),
                  ),
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          : _notifications.isEmpty
          ? _buildEmpty()
          : _buildList(),
    );
  }

  // ── Empty State ───────────────────────────
  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none, color: Colors.white24, size: 64),
          SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // ── List ──────────────────────────────────
  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: _notifications.length,
      separatorBuilder: (_, __) =>
          const Divider(color: Colors.white10, height: 1, indent: 72),
      itemBuilder: (_, i) => _buildTile(_notifications[i]),
    );
  }

  Widget _buildTile(NotificationModel n) {
    return InkWell(
      onTap: () => _markAsRead(n.id),
      child: Container(
        color: n.isRead ? Colors.transparent : Colors.white.withOpacity(0.03),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon ──────────────────────
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _typeColor(n.type).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _typeIcon(n.type),
                color: _typeColor(n.type),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            // ── Content ───────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: n.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!n.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.body,
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(n.createdAt),
                    style: const TextStyle(color: Colors.white30, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────
  IconData _typeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.booking:
        return Icons.confirmation_number_outlined;
      case NotificationType.tour:
        return Icons.map_outlined;
      case NotificationType.message:
        return Icons.chat_bubble_outline;
      case NotificationType.offer:
        return Icons.local_offer_outlined;
      case NotificationType.system:
        return Icons.info_outline;
    }
  }

  Color _typeColor(NotificationType type) {
    switch (type) {
      case NotificationType.booking:
        return AppColors.gold;
      case NotificationType.tour:
        return Colors.blueAccent;
      case NotificationType.message:
        return Colors.greenAccent;
      case NotificationType.offer:
        return Colors.orangeAccent;
      case NotificationType.system:
        return Colors.white54;
    }
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  // ── Dummy Data ────────────────────────────
  List<NotificationModel> _dummyNotifications() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: 1,
        type: NotificationType.booking,
        title: 'Booking Confirmed!',
        body: 'Your booking for "Pyramids Full Day Tour" has been confirmed.',
        createdAt: now.subtract(const Duration(minutes: 10)),
        isRead: false,
      ),
      NotificationModel(
        id: 2,
        type: NotificationType.tour,
        title: 'Tour Tomorrow',
        body: 'Reminder: "Luxor Temple Night Tour" starts tomorrow at 8:00 PM.',
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      NotificationModel(
        id: 3,
        type: NotificationType.message,
        title: 'New Message from Ahmed',
        body: 'Your guide Ahmed sent you a message about the tour details.',
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: false,
      ),
      NotificationModel(
        id: 4,
        type: NotificationType.offer,
        title: '20% Off This Weekend!',
        body:
            'Book any tour this weekend and get 20% discount. Limited time offer.',
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationModel(
        id: 5,
        type: NotificationType.system,
        title: 'App Updated',
        body:
            'Amun Guide has been updated with new features. Check what\'s new!',
        createdAt: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),
      NotificationModel(
        id: 6,
        type: NotificationType.booking,
        title: 'Booking Cancelled',
        body:
            'Your booking for "Aswan Day Trip" has been cancelled. Refund in 3-5 days.',
        createdAt: now.subtract(const Duration(days: 5)),
        isRead: true,
      ),
    ];
  }
}
