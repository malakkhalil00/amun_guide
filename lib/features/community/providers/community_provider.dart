import 'package:flutter/foundation.dart';
import 'package:amin_gide/features/community/models/community_models.dart';
import 'package:amin_gide/features/community/repositories/community_repository.dart';

/// Community Provider (Comments + Likes)
class CommunityProvider extends ChangeNotifier {
  final CommunityRepository _repository;

  CommunityProvider(this._repository);

  // State
  List<CommentModel> _comments = [];
  List<LikeModel> _myLikes = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<CommentModel> get comments => _comments;
  List<LikeModel> get myLikes => _myLikes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load comments
  Future<void> loadComments(String type, int id, {int page = 1}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _comments = await _repository.getComments(type, id, page: page);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add comment
  Future<void> addComment(CommentRequestModel request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final comment = await _repository.addComment(request);
      _comments.insert(0, comment);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update comment
  Future<void> updateComment(int id, CommentRequestModel request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateComment(id, request);
      final index = _comments.indexWhere((c) => c.id == id);
      if (index != -1) {
        _comments[index] = updated;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete comment
  Future<void> deleteComment(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteComment(id);
      _comments.removeWhere((c) => c.id == id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle like
  Future<void> toggleLike(String type, int typeId) async {
    try {
      await _repository.toggleLike(type, typeId);
      // Update comments if type is comment
      if (type == 'comment') {
        final index = _comments.indexWhere((c) => c.id == typeId);
        if (index != -1) {
          final comment = _comments[index];
          _comments[index] = CommentModel(
            id: comment.id,
            userId: comment.userId,
            type: comment.type,
            typeId: comment.typeId,
            content: comment.content,
            rating: comment.rating,
            likes: comment.userLiked ? comment.likes - 1 : comment.likes + 1,
            userLiked: !comment.userLiked,
            createdAt: comment.createdAt,
            updatedAt: comment.updatedAt,
            user: comment.user,
          );
        }
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Load my likes
  Future<void> loadMyLikes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myLikes = await _repository.getMyLikes();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if liked
  bool isLiked(String type, int typeId) {
    return _myLikes.any((l) => l.type == type && l.typeId == typeId);
  }

  // Clear state
  void clear() {
    _comments = [];
    _myLikes = [];
    _errorMessage = null;
    notifyListeners();
  }
}
