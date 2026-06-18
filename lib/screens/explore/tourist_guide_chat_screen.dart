

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/dio_client.dart';

class TouristGuideChatScreen extends StatefulWidget {
  final int guideId;
  final String guideName;
  final String tourName;
  final bool sendBookingMessage; // لما بيجي من حجز يبعت رسالة تلقائية

  const TouristGuideChatScreen({
    super.key,
    required this.guideId,
    required this.guideName,
    this.tourName = '',
    this.sendBookingMessage = false,
  });

  @override
  State<TouristGuideChatScreen> createState() =>
      _TouristGuideChatScreenState();
}

class _TouristGuideChatScreenState extends State<TouristGuideChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  String _myName = '';
  int _myId = 0;
  bool _isLoading = true;
  bool _isSending = false;

  // الـ key بتاع SharedPreferences
  String get _storageKey => 'chat_${_myId}_${widget.guideId}';

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    // جيب بيانات الـ user الحالي
    final userData = await DioClient.getUserData();
    _myName = userData['name'] ?? 'Tourist';
    _myId = userData['user_id'] ?? 0;

    // حمل الرسائل المحفوظة
    await _loadMessages();

    // لو جاي من حجز، ابعت رسالة تلقائية
    if (widget.sendBookingMessage && widget.tourName.isNotEmpty) {
      final bookingMsg =
          '🎒 $_myName has booked your tour "${widget.tourName}". Please confirm the details.';
      await _addMessage(
        content: bookingMsg,
        senderId: _myId,
        senderName: _myName,
        isSystem: true,
      );
    }

    if (mounted) setState(() => _isLoading = false);
    _scrollToBottom();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      _messages = decoded.map<Map<String, dynamic>>((m) =>
          Map<String, dynamic>.from(m)).toList();
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_messages));
  }

  Future<void> _addMessage({
    required String content,
    required int senderId,
    required String senderName,
    bool isSystem = false,
  }) async {
    final msg = {
      'content': content,
      'sender_id': senderId,
      'sender_name': senderName,
      'is_system': isSystem,
      'created_at': DateTime.now().toIso8601String(),
    };
    setState(() => _messages.add(msg));
    await _saveMessages();
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _msgCtrl.clear();

    await _addMessage(
      content: text,
      senderId: _myId,
      senderName: _myName,
    );

    setState(() => _isSending = false);
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
                    ? _buildEmpty()
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
                Text(
                  widget.guideName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const Text('Guide',
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isMe = msg['sender_id'] == _myId;
    final isSystem = msg['is_system'] == true;
    final content = msg['content'] as String;

    // رسائل النظام (الحجز) تظهر في المنتصف
    if (isSystem) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Expanded(child: Divider(color: Colors.white12)),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.goldDim,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderGold),
              ),
              child: Text(
                content,
                style: const TextStyle(
                    color: AppColors.gold, fontSize: 12, height: 1.4),
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
            maxWidth: MediaQuery.of(context).size.width * 0.72),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

  Widget _buildEmpty() {
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
          Text('Start chatting with ${widget.guideName}',
              style: const TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }
}