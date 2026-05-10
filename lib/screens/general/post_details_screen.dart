// 📁 lib/screens/general/post_details_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/widgets/amun_app_bar.dart';

class PostDetailsScreen extends StatefulWidget {
  const PostDetailsScreen({super.key});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  bool _isLiked = true;
  int _likes = 48;
  final _commentController = TextEditingController();

  final List<_Comment> _comments = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: const AmunAppBar(title: 'Post'),
      body: Column(
        children: [
          // ─── Post Content ────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author
                  Row(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: Image.asset(
                            AppAssets.anna,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.bgInput,
                              child: const Icon(
                                Icons.person,
                                color: Colors.white38,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Anna K.',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              '2h ago · Cairo, Egypt',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.blueAccent.withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          'Tips',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Text
                  const Text(
                    'Pro tip for Karnak Temple: Go at 6AM right when it opens. You\'ll have the Hypostyle Hall almost to yourself for 30 minutes. Absolute magic! 🏛️\n\nThe columns are 24 meters tall and the whole forest of them is just breathtaking in the early morning light. No crowds, no noise — just you and 3,500 years of history.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: Image.asset(
                        AppAssets.karnak,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 220,
                          color: AppColors.bgInput,
                          child: const Icon(
                            Icons.image,
                            color: Colors.white24,
                            size: 60,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Actions
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() {
                          _isLiked = !_isLiked;
                          _likes += _isLiked ? 1 : -1;
                        }),
                        child: Row(
                          children: [
                            Icon(
                              _isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_outline,
                              color: _isLiked ? Colors.red : Colors.white38,
                              size: 22,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$_likes',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white38,
                            size: 22,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_comments.length}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.share_outlined,
                        color: Colors.white38,
                        size: 22,
                      ),
                      const SizedBox(width: 14),
                      const Icon(
                        Icons.bookmark_outline,
                        color: Colors.white38,
                        size: 22,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 16),

                  // Comments
                  Text(
                    '${_comments.length} Comments',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  ..._comments.map((c) => _commentCard(c)),
                ],
              ),
            ),
          ),

          // ─── Comment Input ───────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1A16),
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 34,
                    height: 34,
                    child: Image.asset(
                      AppAssets.sarah,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.bgInput,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white38,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgInput,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    if (_commentController.text.isNotEmpty) {
                      setState(() {
                        _comments.insert(
                          0,
                          _Comment(
                            avatar: AppAssets.sarah,
                            name: 'Sarah Ahmed',
                            time: 'Just now',
                            text: _commentController.text,
                            likes: 0,
                          ),
                        );
                        _commentController.clear();
                      });
                    }
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _commentCard(_Comment c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: SizedBox(
              width: 36,
              height: 36,
              child: Image.asset(
                c.avatar,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.bgInput,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white38,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            c.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            c.time,
                            style: const TextStyle(
                              color: Colors.white24,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        c.text,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Like',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 14),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Reply',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ),
                    if (c.likes > 0) ...[
                      const Spacer(),
                      const Icon(Icons.favorite, color: Colors.red, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        '${c.likes}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Comment {
  final String avatar, name, time, text;
  final int likes;
  const _Comment({
    required this.avatar,
    required this.name,
    required this.time,
    required this.text,
    required this.likes,
  });
}
