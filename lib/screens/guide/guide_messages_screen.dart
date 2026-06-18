// 📁 lib/screens/guide/guide_messages_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/dio_client.dart';

class GuideMessagesScreen extends StatefulWidget {
  const GuideMessagesScreen({super.key});

  @override
  State<GuideMessagesScreen> createState() => _GuideMessagesScreenState();
}

class _GuideMessagesScreenState extends State<GuideMessagesScreen> {
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  int _myGuideId = 0;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);

    final userData = await DioClient.getUserData();
    _myGuideId = userData['user_id'] ?? 0;

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _conversations = [
          {
            'key': 'mock_1',
            'tourist_id': '101',
            'tourist_name': 'Ahmed Mostafa',
            'last_message': '🎒 Ahmed has booked your tour "Luxor by Night".',
            'last_time': '10:14',
            'unread': 2,
            'messages': [
              {
                'content':
                    '🎒 Ahmed has booked your tour "Luxor by Night". Please confirm the details.',
                'sender_id': 101,
                'sender_name': 'Ahmed Mostafa',
                'is_system': true,
                'created_at': DateTime.now()
                    .subtract(const Duration(hours: 1))
                    .toIso8601String(),
              },
              {
                'content':
                    'Hi! I\'m really excited about the Luxor tour. What time should I be ready?',
                'sender_id': 101,
                'sender_name': 'Ahmed Mostafa',
                'is_system': false,
                'created_at': DateTime.now()
                    .subtract(const Duration(minutes: 45))
                    .toIso8601String(),
              },
            ],
          },
          {
            'key': 'mock_2',
            'tourist_id': '102',
            'tourist_name': 'Sara El-Sayed',
            'last_message': 'Hi, is the Pyramids tour still available?',
            'last_time': '09:52',
            'unread': 1,
            'messages': [
              {
                'content':
                    'Hi, is the Pyramids tour still available for this weekend?',
                'sender_id': 102,
                'sender_name': 'Sara El-Sayed',
                'is_system': false,
                'created_at': DateTime.now()
                    .subtract(const Duration(hours: 2))
                    .toIso8601String(),
              },
            ],
          },
          {
            'key': 'mock_3',
            'tourist_id': '103',
            'tourist_name': 'James Miller',
            'last_message': 'Thank you so much! Great experience.',
            'last_time': 'Yesterday',
            'unread': 0,
            'messages': [
              {
                'content':
                    'The tour was absolutely amazing! You really know your history.',
                'sender_id': 103,
                'sender_name': 'James Miller',
                'is_system': false,
                'created_at': DateTime.now()
                    .subtract(const Duration(days: 1, hours: 3))
                    .toIso8601String(),
              },
              {
                'content':
                    'Thank you James! It was a pleasure showing you around Egypt.',
                'sender_id': _myGuideId,
                'sender_name': 'Guide',
                'is_system': false,
                'created_at': DateTime.now()
                    .subtract(const Duration(days: 1, hours: 2))
                    .toIso8601String(),
              },
              {
                'content': 'Thank you so much! Great experience.',
                'sender_id': 103,
                'sender_name': 'James Miller',
                'is_system': false,
                'created_at': DateTime.now()
                    .subtract(const Duration(days: 1))
                    .toIso8601String(),
              },
            ],
          },
          {
            'key': 'mock_4',
            'tourist_id': '104',
            'tourist_name': 'Nour Hassan',
            'last_message': 'Can we reschedule to Friday instead?',
            'last_time': 'Yesterday',
            'unread': 0,
            'messages': [
              {
                'content': 'Hello! Can we reschedule to Friday instead?',
                'sender_id': 104,
                'sender_name': 'Nour Hassan',
                'is_system': false,
                'created_at': DateTime.now()
                    .subtract(const Duration(days: 1, hours: 5))
                    .toIso8601String(),
              },
              {
                'content':
                    'Sure Nour, Friday works fine. I\'ll update your booking.',
                'sender_id': _myGuideId,
                'sender_name': 'Guide',
                'is_system': false,
                'created_at': DateTime.now()
                    .subtract(const Duration(days: 1, hours: 4))
                    .toIso8601String(),
              },
              {
                'content': 'Can we reschedule to Friday instead?',
                'sender_id': 104,
                'sender_name': 'Nour Hassan',
                'is_system': false,
                'created_at': DateTime.now()
                    .subtract(const Duration(days: 1, hours: 3))
                    .toIso8601String(),
              },
            ],
          },
          {
            'key': 'mock_5',
            'tourist_id': '105',
            'tourist_name': 'Lena Braun',
            'last_message': 'Perfect, see you at 8am!',
            'last_time': 'Mon',
            'unread': 0,
            'messages': [
              {
                'content': 'What time does the tour start tomorrow?',
                'sender_id': 105,
                'sender_name': 'Lena Braun',
                'is_system': false,
                'created_at': DateTime.now()
                    .subtract(const Duration(days: 3, hours: 2))
                    .toIso8601String(),
              },
              {
                'content': 'We start at 8am sharp, meet at the hotel lobby.',
                'sender_id': _myGuideId,
                'sender_name': 'Guide',
                'is_system': false,
                'created_at': DateTime.now()
                    .subtract(const Duration(days: 3, hours: 1))
                    .toIso8601String(),
              },
              {
                'content': 'Perfect, see you at 8am!',
                'sender_id': 105,
                'sender_name': 'Lena Braun',
                'is_system': false,
                'created_at': DateTime.now()
                    .subtract(const Duration(days: 3))
                    .toIso8601String(),
              },
            ],
          },
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? _buildSkeleton()
                : _conversations.isEmpty
                ? _buildEmpty()
                : RefreshIndicator(
                    onRefresh: _loadConversations,
                    color: AppColors.gold,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _conversations.length,
                      itemBuilder: (_, i) =>
                          _buildConversationCard(_conversations[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.goldDim,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGold),
            ),
            child: const Icon(
              Icons.message_rounded,
              color: AppColors.gold,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Messages',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Tourist conversations',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _loadConversations,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Colors.white54,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard(Map<String, dynamic> conv) {
    final unread = conv['unread'] as int;
    final hasUnread = unread > 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              GuideChatScreen(conversation: conv, guideId: _myGuideId),
        ),
      ).then((_) => _loadConversations()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasUnread ? AppColors.borderGold : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.goldDim,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderGold),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: AppColors.gold,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conv['tourist_name'] ?? 'Tourist',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conv['last_message'] ?? '',
                    style: TextStyle(
                      color: hasUnread ? Colors.white60 : Colors.white38,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  conv['last_time'] ?? '',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
                if (hasUnread) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unread',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderGold),
            ),
            child: const Icon(
              Icons.message_outlined,
              color: AppColors.gold,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No messages yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tourist messages will appear here',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// GUIDE CHAT SCREEN
// ════════════════════════════════════════════════════════════

class GuideChatScreen extends StatefulWidget {
  final Map<String, dynamic> conversation;
  final int guideId;

  const GuideChatScreen({
    super.key,
    required this.conversation,
    required this.guideId,
  });

  @override
  State<GuideChatScreen> createState() => _GuideChatScreenState();
}

class _GuideChatScreenState extends State<GuideChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  bool _isSending = false;
  String _guideName = '';

  @override
  void initState() {
    super.initState();
    _loadGuideInfo();
    _loadMessages();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadGuideInfo() async {
    final userData = await DioClient.getUserData();
    if (mounted) setState(() => _guideName = userData['name'] ?? 'Guide');
  }

  void _loadMessages() {
    final List raw = widget.conversation['messages'] as List? ?? [];
    setState(() {
      _messages = raw
          .map<Map<String, dynamic>>((m) => Map<String, dynamic>.from(m))
          .toList();
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _msgCtrl.clear();

    final msg = {
      'content': text,
      'sender_id': widget.guideId,
      'sender_name': _guideName,
      'is_system': false,
      'created_at': DateTime.now().toIso8601String(),
    };

    setState(() {
      _messages.add(msg);
      _isSending = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyChat()
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) => _buildMessage(_messages[i]),
                  ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.goldDim,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderGold),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.gold,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.conversation['tourist_name'] ?? 'Tourist',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Tourist',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isMe = msg['sender_id'].toString() == widget.guideId.toString();
    final isSystem = msg['is_system'] == true;
    final content = msg['content'] as String;

    if (isSystem) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Expanded(child: Divider(color: Colors.white12)),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.goldDim,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderGold),
              ),
              child: Text(
                content,
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 12,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Expanded(child: Divider(color: Colors.white12)),
          ],
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.gold : AppColors.bgCard,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: isMe ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          content,
          style: TextStyle(
            color: isMe ? Colors.black : Colors.white,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              style: const TextStyle(color: Colors.white),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Reply to tourist...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: AppColors.bgInput,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.gold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isSending ? AppColors.goldDark : AppColors.gold,
                shape: BoxShape.circle,
              ),
              child: _isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline_rounded,
            color: Colors.white24,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'No messages yet',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Waiting for ${widget.conversation['tourist_name'] ?? 'tourist'} to start',
            style: const TextStyle(color: Colors.white24, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
