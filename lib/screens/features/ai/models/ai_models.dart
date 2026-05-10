// Models for AI Feature

class ConversationModel {
  final int id;
  final int userId;
  final String title;
  final List<MessageModel> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConversationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      title: json['title'] ?? '',
      messages: (json['messages'] as List?)
              ?.map((m) => MessageModel.fromJson(m))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class MessageModel {
  final int id;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? 0,
      role: json['role'] ?? 'user',
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class PlanModel {
  final int id;
  final int conversationId;
  final int userId;
  final String title;
  final String description;
  final String duration;
  final List<String> itinerary;
  final double estimatedCost;
  final DateTime createdAt;

  PlanModel({
    required this.id,
    required this.conversationId,
    required this.userId,
    required this.title,
    required this.description,
    required this.duration,
    required this.itinerary,
    required this.estimatedCost,
    required this.createdAt,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] ?? 0,
      conversationId: json['conversation_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? '',
      itinerary: List<String>.from(json['itinerary'] ?? []),
      estimatedCost: (json['estimated_cost'] ?? 0).toDouble(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
