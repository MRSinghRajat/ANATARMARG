import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/providers/language_provider.dart';
import '../../../../shared/widgets/typing_indicator.dart';
import '../../data/models/spiritual_service.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/conversation_history.dart';
import '../../data/config/spiritual_service_prompts.dart';
import '../widgets/service_selector_modal.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/service_form_sheet.dart';
import '../widgets/conversation_history_list.dart';
import '../../data/services/spiritual_chat_service.dart';
import '../../data/services/consultation_usage_service.dart';

/// Main screen for the AI Spiritual Chatbot.
/// Shows conversation history or active chat.
class SpiritualChatScreen extends ConsumerStatefulWidget {
  const SpiritualChatScreen({super.key});

  @override
  ConsumerState<SpiritualChatScreen> createState() => _SpiritualChatScreenState();
}

class _SpiritualChatScreenState extends ConsumerState<SpiritualChatScreen> {
  // View state
  bool _isInChat = false; // true = showing chat, false = showing history list
  
  // Current chat state
  SpiritualServiceType? _selectedService;
  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpiritualChatService _chatService = SpiritualChatService();
  final ConsultationUsageService _usageService = ConsultationUsageService.instance;
  
  bool _isLoading = false;
  bool _readingDelivered = false;
  Map<String, dynamic>? _userProfile;
  String? _currentConversationId;

  final List<ConversationHistory> _conversationHistory = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _persistConversations();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String get _storageKey {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? 'guest';
    return 'ai_chat_history_$userId';
  }

  Future<void> _loadConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = prefs.getString(_storageKey);
      if (encoded != null && encoded.isNotEmpty) {
        final loaded = ConversationHistory.decodeList(encoded);
        if (mounted) {
          setState(() => _conversationHistory.addAll(loaded));
        }
      }
    } catch (e) {
      debugPrint('Failed to load AI conversations: $e');
    }
  }

  Future<void> _persistConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = ConversationHistory.encodeList(_conversationHistory);
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Failed to persist AI conversations: $e');
    }
  }

  void _showServiceSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => ServiceSelectorModal(
        onServiceSelected: _onServiceSelected,
        selectedService: _selectedService,
      ),
    );
  }

  void _onServiceSelected(SpiritualServiceType service) {
    Navigator.of(context).pop();
    
    // Create new conversation
    final newConversation = ConversationHistory.create(
      service: service,
    );
    
    setState(() {
      _selectedService = service;
      _messages.clear();
      _userProfile = null;
      _currentConversationId = newConversation.id;
      _readingDelivered = false;
      _isInChat = true;
      
      // Add to history
      _conversationHistory.insert(0, newConversation);
    });
    
    _addGreetingMessage(service);
  }

  void _resumeConversation(ConversationHistory conversation) {
    setState(() {
      _selectedService = conversation.service;
      _messages.clear();
      _messages.addAll(conversation.messages);
      _userProfile = conversation.userProfile;
      _currentConversationId = conversation.id;
      _readingDelivered = true; // Already delivered in previous session
      _isInChat = true;
    });
    _scrollToBottom();
  }

  void _deleteConversation(ConversationHistory conversation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.ashramBackgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: Text(
          AppStrings.get('delete_conversation', ref.read(languageProvider)),
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This will permanently delete this ${conversation.service.title} conversation.',
          style: GoogleFonts.outfit(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.get('cancel', ref.read(languageProvider)),
              style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.6)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _conversationHistory.removeWhere((c) => c.id == conversation.id);
              });
              _persistConversations();
            },
            child: Text(
              AppStrings.get('delete', ref.read(languageProvider)),
              style: GoogleFonts.outfit(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _goBackToHistory() {
    // Save current conversation before going back
    _saveCurrentConversation();
    
    setState(() {
      _isInChat = false;
    });
  }

  void _saveCurrentConversation() {
    if (_currentConversationId == null || _messages.isEmpty) return;
    
    final index = _conversationHistory.indexWhere(
      (c) => c.id == _currentConversationId,
    );
    
    if (index != -1) {
      // Get the last non-empty message for preview
      String? lastMessage;
      for (int i = _messages.length - 1; i >= 0; i--) {
        if (_messages[i].content.isNotEmpty) {
          lastMessage = _messages[i].content;
          break;
        }
      }
      
      _conversationHistory[index] = _conversationHistory[index].copyWith(
        updatedAt: DateTime.now(),
        messages: List.from(_messages),
        lastMessage: lastMessage,
        userProfile: _userProfile,
      );
    }
    _persistConversations();
  }

  void _addGreetingMessage(SpiritualServiceType service) {
    final greeting = SpiritualServicePrompts.getGreeting(service);
    setState(() {
      _messages.add(ChatMessage.assistant(
        conversationId: _currentConversationId ?? 'temp',
        content: greeting,
        quickReplies: ["Yes, let's begin", "I have questions first"],
      ));
    });
    _scrollToBottom();
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

  void _onQuickReplyTap(String reply) {
    if (reply == "Yes, let's begin") {
      _showDataCollectionForm();
    } else if (reply == "I have questions first") {
      _addUserMessage("I have some questions before we begin.");
    } else if (reply == "New consultation") {
      _showServiceSelector();
    } else {
      _addUserMessage(reply);
    }
  }

  Future<void> _showDataCollectionForm() async {
    if (_selectedService == null) return;
    
    // Check usage limit before showing form
    final canStart = await _usageService.canStartConsultation();
    if (!canStart && mounted) {
      _showUsageLimitDialog();
      return;
    }
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceFormSheet(
        service: _selectedService!,
        onSubmit: _onFormSubmitted,
      ),
    );
  }
  
  void _showUsageLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.ashramBackgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.ashramSaffron.withOpacity(0.3),
          ),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.lock_outline,
              color: AppColors.ashramSaffron,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Monthly Limit Reached',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ashramAccentGold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You've used all ${ConsultationUsageService.freeMonthlyLimit} free consultations this month.",
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Upgrade to Premium for unlimited spiritual guidance!',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.ashramAccentGold,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Maybe Later',
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Premium upgrade coming soon!'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.ashramSaffron,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Go Premium',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _onFormSubmitted(Map<String, dynamic> formData) {
    Navigator.of(context).pop();
    setState(() {
      _userProfile = formData;
    });
    
    // Extract image if present (for palmistry)
    String? imageBase64;
    if (_selectedService == SpiritualServiceType.palmistry) {
      imageBase64 = formData['palmImage'] as String?;
    }
    
    // Add user message showing they submitted their details (with image if present)
    _addUserMessageWithImage(
      _formatFormDataAsMessage(formData),
      imageBase64: imageBase64,
    );
    
    // Send to AI for reading
    _requestReading(formData);
  }

  String _formatFormDataAsMessage(Map<String, dynamic> formData) {
    final buffer = StringBuffer();
    buffer.writeln("Here are my details:");
    formData.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        // Skip showing palmImage binary data in text - it will be shown as image
        if (key == 'palmImage') {
          buffer.writeln("• Palm Image: [Image uploaded]");
        } else {
          final label = key.replaceAll('_', ' ').split(' ').map((w) => 
            w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}'
          ).join(' ');
          buffer.writeln("• $label: $value");
        }
      }
    });
    return buffer.toString().trim();
  }

  Future<void> _requestReading(Map<String, dynamic> formData) async {
    if (_selectedService == null) return;
    
    setState(() => _isLoading = true);
    _scrollToBottom();

    try {
      // Build context message for AI
      final contextMessage = _buildReadingRequest(formData);
      
      // Extract palm image if this is a palmistry reading
      String? palmImage;
      if (_selectedService == SpiritualServiceType.palmistry) {
        palmImage = formData['palmImage'] as String?;
      }
      
      final response = await _chatService.chat(
        service: _selectedService!,
        userMessage: contextMessage,
        userProfile: formData,
        history: _messages.map((m) => m.toGptFormat()).toList(),
        imageBase64: palmImage,
      );

      if (mounted) {
        // Increment usage count after successful reading
        if (!_readingDelivered) {
          await _usageService.incrementConsultationCount();
          _readingDelivered = true;
        }
        
        setState(() {
          _messages.add(ChatMessage.assistant(
            conversationId: _currentConversationId ?? 'temp',
            content: response,
            isReading: true,
            quickReplies: ["Tell me more", "I have a question", "New consultation"],
          ));
          _isLoading = false;
        });
        _scrollToBottom();
        _saveCurrentConversation();
      }
    } catch (e) {
      print('Error requesting reading: $e');
      if (mounted) {
        String errorMessage = "I apologize, but I'm having trouble connecting right now. Please try again in a moment. 🙏";
        
        // Provide more helpful error messages
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('api key')) {
          errorMessage = "API key is not configured. Please check your .env file has a valid GPT_API_KEY. 🔑";
        } else if (errorString.contains('timeout') || errorString.contains('timed out')) {
          errorMessage = "The request took too long. Please try again - sometimes the spirits need a moment longer to connect. 🕉️";
        } else if (errorString.contains('401') || errorString.contains('unauthorized')) {
          errorMessage = "API authentication failed. Please check your GPT_API_KEY is valid. 🔐";
        } else if (errorString.contains('429') || errorString.contains('rate limit')) {
          errorMessage = "Too many requests. Please wait a moment and try again. 🙏";
        } else if (errorString.contains('500') || errorString.contains('502') || errorString.contains('503')) {
          errorMessage = "The service is temporarily unavailable. Please try again shortly. 🙏";
        }
        
        setState(() {
          _messages.add(ChatMessage.assistant(
            conversationId: _currentConversationId ?? 'temp',
            content: errorMessage,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  String _buildReadingRequest(Map<String, dynamic> formData) {
    final buffer = StringBuffer();
    
    // Add current date context for all services
    final now = DateTime.now();
    buffer.writeln("IMPORTANT: Today's date is ${now.day}/${now.month}/${now.year}. Always provide future dates for events and predictions.");
    buffer.writeln();
    
    if (_selectedService == SpiritualServiceType.palmistry) {
      // Special prompt for palmistry with image - clearer instructions
      buffer.writeln("I have attached an image of my palm. Please analyze this palm image and provide a detailed palmistry reading.");
      buffer.writeln("\nAdditional details:");
      formData.forEach((key, value) {
        // Don't include the base64 image data in the text
        if (key != 'palmImage' && value != null && value.toString().isNotEmpty) {
          buffer.writeln("- $key: $value");
        }
      });
      buffer.writeln("\nBased on the palm image I've shared, please provide:");
      buffer.writeln("1. Analysis of major lines (Heart, Head, Life, Fate)");
      buffer.writeln("2. Mount analysis");
      buffer.writeln("3. Finger shape observations");
      buffer.writeln("4. Insights on love, career, health");
      buffer.writeln("5. Overall life path interpretation");
      buffer.writeln("\nProvide ONE comprehensive reading response only.");
    } else if (_selectedService == SpiritualServiceType.upcomingEvents) {
      // Special prompt for upcoming events
      buffer.writeln("Please provide information about UPCOMING spiritual events and festivals from today's date (${now.day}/${now.month}/${now.year}) onwards.");
      buffer.writeln("\nUser's interest area:");
      formData.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          buffer.writeln("$key: $value");
        }
      });
      buffer.writeln("\nProvide only FUTURE dates. Never give past dates. Include the year in all dates.");
    } else {
      buffer.writeln("Please provide me with a comprehensive ${_selectedService!.title} reading based on the following details:");
      formData.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          buffer.writeln("$key: $value");
        }
      });
    }
    return buffer.toString();
  }

  void _addUserMessage(String content) {
    setState(() {
      _messages.add(ChatMessage.user(
        conversationId: _currentConversationId ?? 'temp',
        content: content,
      ));
    });
    _scrollToBottom();
    _sendMessage(content);
  }

  void _addUserMessageWithImage(String content, {String? imageBase64}) {
    setState(() {
      _messages.add(ChatMessage.user(
        conversationId: _currentConversationId ?? 'temp',
        content: content,
        imageBase64: imageBase64,
      ));
    });
    _scrollToBottom();
    // Note: Don't call _sendMessage here - the reading request is sent separately
  }

  Future<void> _sendMessage(String content) async {
    if (_selectedService == null) return;
    
    setState(() => _isLoading = true);
    _scrollToBottom();

    try {
      // Add date context for follow-up messages too
      final now = DateTime.now();
      final messageWithContext = "Today's date: ${now.day}/${now.month}/${now.year}. User message: $content";
      
      final response = await _chatService.chat(
        service: _selectedService!,
        userMessage: messageWithContext,
        userProfile: _userProfile,
        history: _messages.map((m) => m.toGptFormat()).toList(),
      );

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage.assistant(
            conversationId: _currentConversationId ?? 'temp',
            content: response,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
        _saveCurrentConversation();
      }
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        String errorMessage = "I apologize, but I'm having trouble connecting right now. Please try again. 🙏";
        
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('api key')) {
          errorMessage = "API key is not configured. Please check your .env file. 🔑";
        } else if (errorString.contains('timeout')) {
          errorMessage = "The request took too long. Please try again. 🕉️";
        }
        
        setState(() {
          _messages.add(ChatMessage.assistant(
            conversationId: _currentConversationId ?? 'temp',
            content: errorMessage,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _onSendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    _messageController.clear();
    _addUserMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ashramBackgroundDark,
      appBar: _buildAppBar(),
      body: _isInChat ? _buildChatView() : _buildHistoryView(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.ashramBackgroundDark,
      elevation: 0,
      centerTitle: true,
      leading: _isInChat
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: _goBackToHistory,
              tooltip: 'Back to conversations',
            )
          : null,
      title: _isInChat && _selectedService != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedService!.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedService!.title,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ashramAccentGold,
                  ),
                ),
              ],
            )
          : Text(
              'Spiritual Advisor',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.ashramAccentGold,
              ),
            ),
      actions: [
        IconButton(
          icon: const Icon(Icons.apps, color: AppColors.ashramAccentGold),
          onPressed: _showServiceSelector,
          tooltip: 'All Services',
        ),
      ],
    );
  }

  Widget _buildHistoryView() {
    return ConversationHistoryList(
      conversations: _conversationHistory,
      onConversationTap: _resumeConversation,
      onDeleteTap: _deleteConversation,
      onNewConversation: _showServiceSelector,
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        // Usage indicator banner for free users
        _UsageBanner(usageService: _usageService),
        Expanded(child: _buildChatBody()),
        ChatInputBar(
          controller: _messageController,
          onSend: _onSendMessage,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildChatBody() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoading && index == _messages.length) {
          return Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.ashramSaffron.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🕉️', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const TypingIndicator(
                    label: 'Preparing your guidance...',
                    compact: false,
                  ),
                ),
              ],
            ),
          );
        }

        final message = _messages[index];
        return ChatMessageBubble(
          message: message,
          onQuickReplyTap: _onQuickReplyTap,
        );
      },
    );
  }
}

/// Widget that shows remaining consultations for free users.
class _UsageBanner extends StatelessWidget {
  final ConsultationUsageService usageService;

  const _UsageBanner({required this.usageService});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: usageService.getRemainingConsultations(),
      builder: (context, snapshot) {
        final remaining = snapshot.data ?? -1;
        
        // Don't show for premium users (unlimited = -1)
        if (remaining < 0 || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        // Show banner only when consultations are limited
        final isLow = remaining <= 1;
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLow
                  ? [
                      Colors.orange.withOpacity(0.2),
                      Colors.orange.withOpacity(0.1),
                    ]
                  : [
                      AppColors.ashramSaffron.withOpacity(0.15),
                      AppColors.ashramSaffron.withOpacity(0.05),
                    ],
            ),
            border: Border(
              bottom: BorderSide(
                color: isLow
                    ? Colors.orange.withOpacity(0.3)
                    : AppColors.ashramSaffron.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isLow ? Icons.warning_amber_rounded : Icons.auto_awesome,
                size: 16,
                color: isLow ? Colors.orange : AppColors.ashramAccentGold,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isLow
                      ? 'Only $remaining consultation${remaining == 1 ? '' : 's'} remaining this month'
                      : '$remaining free consultation${remaining == 1 ? '' : 's'} remaining this month',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isLow
                        ? Colors.orange
                        : Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Premium upgrade coming soon!')),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Go Premium',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ashramAccentGold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
