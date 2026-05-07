// Models for Community Feature (Comments + Likes)

class CommentModel {
  final int id;
  final int userId;
  final String type; // 'tour', 'place', 'plan'
  final int typeId;
  final String content;
  final double rating;
  final int likes;
  final bool userLiked;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? user; // Nested user data

  CommentModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.typeId,
    required this.content,
    required this.rating,
    required this.likes,
    required this.userLiked,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      type: json['type'] ?? '',
      typeId: json['type_id'] ?? 0,
      content: json['content'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      likes: json['likes'] ?? 0,
      userLiked: json['user_liked'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      user: json['user'],
    );
  }
}

class CommentRequestModel {
  final String type;
  final int typeId;
  final String content;
  final double rating;

  CommentRequestModel({
    required this.type,
    required this.typeId,
    required this.content,
    required this.rating,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'type_id': typeId,
        'content': content,
        'rating': rating,
      };
}

class LikeModel {
  final int id;
  final int userId;
  final String type; // 'tour', 'place', 'plan', 'comment'
  final int typeId;
  final DateTime createdAt;

  LikeModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.typeId,
    required this.createdAt,
  });

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      type: json['type'] ?? '',
      typeId: json['type_id'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
