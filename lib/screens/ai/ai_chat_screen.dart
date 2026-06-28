// 📁 lib/screens/ai/ai_chat_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/services/conversation_service.dart';
import '../../core/widgets/amun_app_bar.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _conversationService = ConversationService();
  int? _conversationId;
  bool _isSending = false;

  final List<_Message> _messages = [
    _Message(
      text: 'Hello! I\'m Amun, your personal Egypt travel assistant. 🏛️\n\nAsk me anything — itineraries, hidden gems, best times to visit, or local tips!',
      isUser: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initConversation();
  }

  Future<void> _initConversation() async {
    try {
      final response = await _conversationService.createConversation(context: 'Egypt travel assistant');
      final data = response.data;
      _conversationId = data['data']?['id'] ?? data['id'];
    } catch (e) {
      debugPrint('Could not create conversation: $e');
    }
  }

  final _quickReplies = [
    '3-day Cairo plan 🔺',
    'Best time to visit Luxor',
    'Hidden gems in Aswan',
    'Budget trip tips 💰',
  ];

  void _sendMessage(String text) {
    if (text.trim().isEmpty || _isSending) return;
    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _controller.clear();
      _isSending = true;
    });

    _scrollToBottom();

    // Try API call, fall back to mock
    if (_conversationId != null) {
      _sendToApi(text);
    } else {
      _mockResponse(text);
    }
  }

  Future<void> _sendToApi(String text) async {
    try {
      final response = await _conversationService.sendMessage(
        _conversationId!,
        {
          'message': text,
          'content': text,
          'sender': 'user',
        },
      );
      final data = response.data;
      final aiReply = data['data']?['response'] ?? data['response'] ?? data['message'] ?? '';
      if (mounted && aiReply.toString().isNotEmpty) {
        setState(() {
          _messages.add(_Message(
            text: aiReply.toString(),
            isUser: false,
            hasPlan: text.toLowerCase().contains('plan') || text.toLowerCase().contains('itinerary'),
          ));
          _isSending = false;
        });
        _scrollToBottom();
        return;
      }
    } catch (e) {
      debugPrint('AI API error: $e');
    }
    // Fallback to mock
    _mockResponse(text);
  }

  void _mockResponse(String text) {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _messages.add(_Message(
          text: _getMockResponse(text),
          isUser: false,
          hasPlan: text.toLowerCase().contains('plan') ||
              text.toLowerCase().contains('itinerary') ||
              text.toLowerCase().contains('cairo'),
        ));
        _isSending = false;
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getMockResponse(String msg) {
    if (msg.toLowerCase().contains('cairo') ||
        msg.toLowerCase().contains('plan')) {
      return 'Great choice! Here\'s a perfect 3-day Cairo itinerary for you:\n\n📅 Day 1 — Giza Plateau\n📅 Day 2 — Old Cairo & Museum\n📅 Day 3 — Khan el-Khalili\n\nWant me to generate the full detailed plan?';
    } else if (msg.toLowerCase().contains('luxor')) {
      return 'Luxor is best visited between October and April when temperatures are cooler. 🌤️\n\nTop spots: Karnak Temple, Valley of Kings, Luxor Temple, and a Nile felucca ride at sunset!';
    } else if (msg.toLowerCase().contains('aswan')) {
      return 'Aswan\'s hidden gems include:\n\n🏝️ Elephantine Island\n⛵ Nubian Village boat trip\n🏛️ Temple of Khnum\n🌅 Aga Khan Mausoleum at sunset\n\nWant a full Aswan day plan?';
    } else {
      return 'That\'s a great question! Let me help you plan the perfect Egypt experience. Could you tell me more about your travel dates and interests?';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AmunAppBar(
        title: 'Amun AI',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: AppColors.goldDim,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold.withOpacity(0.4)),
              ),
              child: ClipOval(
                child: Image.asset(AppAssets.amunAvatar,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.auto_awesome,
                        color: AppColors.gold, size: 18)),
              ),
            ),
          ),
        ],
      ),

      body: Column(children: [

        // ─── Messages ───────────────────────────
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            itemCount: _messages.length,
            itemBuilder: (_, i) => _buildMessage(_messages[i], context),
          ),
        ),

        // ─── Quick Replies ───────────────────────
        if (_messages.length <= 2)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _quickReplies.map((q) => GestureDetector(
                  onTap: () => _sendMessage(q),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                    ),
                    child: Text(q,
                        style: const TextStyle(
                            color: AppColors.gold, fontSize: 12)),
                  ),
                )).toList(),
              ),
            ),
          ),

        // ─── Input ──────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1A16),
            border: Border(top: BorderSide(color: Colors.white10)),
          ),
          child: Row(children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.bgInput,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white10),
                ),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  onSubmitted: _sendMessage,
                  decoration: const InputDecoration(
                    hintText: 'Ask Amun anything...',
                    hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _sendMessage(_controller.text),
              child: Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(
                    color: AppColors.gold, shape: BoxShape.circle),
                child: const Icon(Icons.send_rounded,
                    color: Colors.black, size: 20),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildMessage(_Message msg, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
        msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // AI avatar
          if (!msg.isUser) ...[
            Container(
              width: 32, height: 32,
              margin: const EdgeInsets.only(right: 8, top: 4),
              decoration: BoxDecoration(
                color: AppColors.goldDim,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold.withOpacity(0.4)),
              ),
              child: const Icon(Icons.auto_awesome,
                  color: AppColors.gold, size: 16),
            ),
          ],

          // Bubble
          Flexible(
            child: Column(
              crossAxisAlignment: msg.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: msg.isUser ? AppColors.gold : AppColors.bgCard,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                      bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                    ),
                    border: msg.isUser
                        ? null
                        : Border.all(color: Colors.white10),
                  ),
                  child: Text(msg.text,
                      style: TextStyle(
                          color: msg.isUser ? Colors.black : Colors.white,
                          fontSize: 14,
                          height: 1.5)),
                ),

                // Plan card CTA
                if (msg.hasPlan) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        context, '/ai-plan-details'),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.goldDim,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.gold.withOpacity(0.4)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.map_outlined,
                            color: AppColors.gold, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('View Full Itinerary Plan',
                              style: TextStyle(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            color: AppColors.gold, size: 14),
                      ]),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  final bool hasPlan;
  const _Message({
    required this.text,
    required this.isUser,
    this.hasPlan = false,
  });
}
