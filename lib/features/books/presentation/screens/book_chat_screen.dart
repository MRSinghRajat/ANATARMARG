import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/animated_guide.dart';
import '../../../../shared/widgets/typing_indicator.dart';
import '../../../../shared/services/guide_animation_service.dart';
import '../../data/models/book_model.dart';
import '../../../content/data/datasources/gpt_api_service.dart';

class BookChatScreen extends ConsumerStatefulWidget {
  final BookModel book;

  /// Optional verse text - when provided, adds as initial context for the chat
  final String? verseContext;

  const BookChatScreen({
    super.key,
    required this.book,
    this.verseContext,
  });

  @override
  ConsumerState<BookChatScreen> createState() => _BookChatScreenState();
}

class _BookChatScreenState extends ConsumerState<BookChatScreen> {
  final GPTApiService _gptService = GPTApiService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    GuideAnimationService().setState(GuideState.thinking);
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    if (widget.verseContext != null && widget.verseContext!.isNotEmpty) {
      _messages.add({
        'role': 'user',
        'content': 'Explain this verse: ${widget.verseContext}',
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendVerseContextMessage();
      });
    } else {
      _messages.add({
        'role': 'assistant',
        'content':
            'Namaste! I\'m here to help you understand ${widget.book.name}. What would you like to explore?',
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendVerseContextMessage() async {
    if (widget.verseContext == null || widget.verseContext!.isEmpty) return;
    final userMessage = 'Explain this verse: ${widget.verseContext}';
    setState(() => _isLoading = true);
    _scrollToBottom();
    try {
      final response = await _gptService.chatWithBook(
        book: widget.book.name,
        bookDescription: widget.book.description,
        category: widget.book.category,
        userMessage: userMessage,
        history: [
          {'role': 'user', 'content': userMessage},
        ],
      );
      if (mounted) {
        setState(() {
          _messages.add({'role': 'assistant', 'content': response});
          _isLoading = false;
          _scrollToBottom();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content':
                'I\'m having trouble connecting right now. Please try again in a moment.',
          });
          _isLoading = false;
          _scrollToBottom();
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final userMessage = _messageController.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'content': userMessage,
      });
      _messageController.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await _gptService.chatWithBook(
        book: widget.book.name,
        bookDescription: widget.book.description,
        category: widget.book.category,
        userMessage: userMessage,
        history: _messages
            .where((m) => m['role'] != 'user' || m['content'] != userMessage)
            .map((m) => {
                  'role': m['role']!,
                  'content': m['content']!,
                })
            .toList(),
      );

      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content': response,
          });
          _isLoading = false;
          _scrollToBottom();
        });
        GuideAnimationService().setState(GuideState.speaking);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content':
                'I\'m having trouble connecting right now. Please try again in a moment.',
          });
          _isLoading = false;
          _scrollToBottom();
        });
      }
    }

    Future.delayed(const Duration(seconds: 1), () {
      GuideAnimationService().setState(GuideState.thinking);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AnimatedGuide(width: 510, height: 510),
                      const SizedBox(height: 24),
                      Text(
                        'Chat about ${widget.book.name}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ask questions about this sacred text',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.secondaryText,
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      return _buildTypingBubble();
                    }
                    final message = _messages[index];
                    final isUser = message['role'] == 'user';
                    return _buildMessageBubble(
                      message['content']!,
                      isUser,
                      showAnimation: index == _messages.length - 1,
                    );
                  },
                ),
        ),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask about ${widget.book.name}...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: const Icon(Icons.send_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.warmOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypingBubble() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: const TypingIndicator(label: 'Thinking'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(
    String content,
    bool isUser, {
    bool showAnimation = false,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: showAnimation ? 0 : 1, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - value)),
            child: Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                decoration: BoxDecoration(
                  color: isUser
                      ? AppColors.warmOrange.withOpacity(0.15)
                      : AppColors.cardBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                    bottomLeft: !isUser ? const Radius.circular(4) : const Radius.circular(16),
                  ),
                ),
                child: Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
