import 'package:flutter/foundation.dart';
import 'package:amin_gide/features/ai/models/ai_models.dart';
import 'package:amin_gide/features/ai/repositories/ai_repository.dart';

/// AI Provider
class AIProvider extends ChangeNotifier {
  final AIRepository _repository;

  AIProvider(this._repository);

  // State
  ConversationModel? _currentConversation;
  List<ConversationModel> _conversations = [];
  PlanModel? _currentPlan;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  ConversationModel? get currentConversation => _currentConversation;
  List<ConversationModel> get conversations => _conversations;
  PlanModel? get currentPlan => _currentPlan;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Create conversation
  Future<void> createConversation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentConversation = await _repository.createConversation();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send message
  Future<void> sendMessage(String message) async {
    if (_currentConversation == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final msg =
          await _repository.sendMessage(_currentConversation!.id, message);
      _currentConversation = ConversationModel(
        id: _currentConversation!.id,
        userId: _currentConversation!.userId,
        title: _currentConversation!.title,
        messages: [..._currentConversation!.messages, msg],
        createdAt: _currentConversation!.createdAt,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load conversation
  Future<void> loadConversation(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentConversation = await _repository.getConversation(id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load conversations
  Future<void> loadConversations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _conversations = await _repository.getConversations();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create plan
  Future<void> createPlan() async {
    if (_currentConversation == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPlan = await _repository.createPlan(_currentConversation!.id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear state
  void clear() {
    _currentConversation = null;
    _conversations = [];
    _currentPlan = null;
    _errorMessage = null;
    notifyListeners();
  }
}
