import 'package:flutter/foundation.dart';
import 'package:amin_gide/features/notification/models/notification_models.dart';
import 'package:amin_gide/features/notification/repositories/notification_repository.dart';

/// Notification Provider
class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;

  NotificationProvider(this._repository);

  // State
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Load notifications
  Future<void> loadNotifications({int page = 1, int perPage = 20}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _repository.getNotifications(
        page: page,
        perPage: perPage,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark as read
  Future<void> markAsRead(int id) async {
    try {
      await _repository.markAsRead(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          userId: _notifications[index].userId,
          type: _notifications[index].type,
          title: _notifications[index].title,
          message: _notifications[index].message,
          icon: _notifications[index].icon,
          data: _notifications[index].data,
          isRead: true,
          createdAt: _notifications[index].createdAt,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      _notifications = _notifications
          .map((n) => NotificationModel(
                id: n.id,
                userId: n.userId,
                type: n.type,
                title: n.title,
                message: n.message,
                icon: n.icon,
                data: n.data,
                isRead: true,
                createdAt: n.createdAt,
              ))
          .toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Clear state
  void clear() {
    _notifications = [];
    _errorMessage = null;
    notifyListeners();
  }
}
