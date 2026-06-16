// 📁 lib/screens/guide/guide_messages_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/conversation_service.dart';
import '../../core/services/dio_client.dart';

class GuideMessagesScreen extends StatefulWidget {
  const GuideMessagesScreen({super.key});

  @override
  State<GuideMessagesScreen> createState() => _GuideMessagesScreenState();
}

class _GuideMessagesScreenState extends State<GuideMessagesScreen> {
  final _service = ConversationService();

  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    try {
      final response = await _service.getMyConversations();
      final data = response.data;
      final List items = data['data'] ?? data ?? [];
      if (mounted) {
        setState(() {
          _conversations = items.map<Map<String, dynamic>>((c) => {
            'id': c['id'],
            'title': c['title'] ?? c['context'] ?? 'Conversation',
            'last_message': c['last_message'] ?? c['context'] ?? '',
            'unread': c['unread_count'] ?? 0,
            'updated_at': c['updated_at']?.toString().split('T').first ?? '',
            'participant': c['tourist']?['name'] ?? c['user']?['name'] ?? 'Tourist',
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Conversations error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          20, MediaQuery.of(context).padding.top + 16, 20, 20),
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
            child: const Icon(Icons.message_rounded,
                color: AppColors.gold, size: 20),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Messages',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text('Tourist conversations',
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
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
              child: const Icon(Icons.refresh_rounded,
                  color: Colors.white54, size: 18),
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
          builder: (_) => GuideChatScreen(conversation: conv),
        ),
      ).then((_) => _loadConversations()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: hasUnread ? AppColors.borderGold : AppColors.border),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.goldDim,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderGold),
              ),
              child: const Icon(Icons.person_rounded,
                  color: AppColors.gold, size: 24),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(conv['participant'] ?? '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    conv['last_message'] ?? '',
                    style: TextStyle(
                        color: hasUnread ? Colors.white60 : Colors.white38,
                        fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Time + unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(conv['updated_at'] ?? '',
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 11)),
                if (hasUnread) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$unread',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
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
            child: const Icon(Icons.message_outlined,
                color: AppColors.gold, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('No messages yet',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Tourist messages will appear here',
              style: TextStyle(color: Colors.white38, fontSize: 13)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// CHAT SCREEN
// ════════════════════════════════════════════════════════════

class GuideChatScreen extends StatefulWidget {
  final Map<String, dynamic> conversation;

  const GuideChatScreen({super.key, required this.conversation});

  @override
  State<GuideChatScreen> createState() => _GuideChatScreenState();
}

class _GuideChatScreenState extends State<GuideChatScreen> {
  final _service = ConversationService();
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  int _myUserId = 0;

  @override
  void initState() {
    super.initState();
    _loadMyId();
    _loadMessages();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMyId() async {
    final data = await DioClient.getUserData();
    if (mounted) setState(() => _myUserId = data['user_id'] ?? 0);
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await _service.getMessages(widget.conversation['id']);
      final data = response.data;
      final List items = data['data'] ?? data ?? [];
      if (mounted) {
        setState(() {
          _messages = items.map<Map<String, dynamic>>((m) => {
            'id': m['id'],
            'content': m['content'] ?? m['message'] ?? '',
            'sender_id': m['user_id'] ?? m['sender_id'] ?? 0,
            'sender_name': m['user']?['name'] ?? m['sender']?['name'] ?? '',
            'created_at': m['created_at']?.toString() ?? '',
            'is_ai': m['is_ai'] ?? false,
          }).toList();
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Messages error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _msgCtrl.clear();

    try {
      await _service.sendMessage(
        widget.conversation['id'],
        {'content': text},
      );
      await _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to send message'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.gold))
                : _messages.isEmpty
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
          16, MediaQuery.of(context).padding.top + 12, 16, 16),
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
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 14),
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
            child: const Icon(Icons.person_rounded,
                color: AppColors.gold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.conversation['participant'] ?? 'Tourist',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const Text('Tourist',
                    style:
                        TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: _loadMessages,
            child: const Icon(Icons.refresh_rounded,
                color: Colors.white38, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isMe = msg['sender_id'] == _myUserId;
    final content = msg['content'] as String;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.gold : AppColors.bgCard,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: isMe
              ? null
              : Border.all(color: AppColors.border),
        ),
        child: Text(
          content,
          style: TextStyle(
              color: isMe ? Colors.black : Colors.white,
              fontSize: 14,
              height: 1.4),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
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
                hintText: 'Type a message...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: AppColors.bgInput,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
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
                          color: Colors.black, strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded,
                      color: Colors.black, size: 20),
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
          const Icon(Icons.chat_bubble_outline_rounded,
              color: Colors.white24, size: 48),
          const SizedBox(height: 12),
          const Text('No messages yet',
              style: TextStyle(color: Colors.white38, fontSize: 14)),
          const SizedBox(height: 8),
          Text('Start the conversation with ${widget.conversation['participant']}',
              style: const TextStyle(color: Colors.white24, fontSize: 12),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}