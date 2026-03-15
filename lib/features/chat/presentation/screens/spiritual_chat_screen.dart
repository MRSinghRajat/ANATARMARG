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
import '../../data/services/spiritual_chat_service.dart';
import '../../data/services/consultation_usage_service.dart';
import '../../data/models/feeling_responses.dart';
import '../../data/models/feeling_suggestion_model.dart';
import '../../data/repositories/feeling_repository.dart';
import '../../../subscription/presentation/screens/paywall_screen.dart';
import '../../../../shared/services/premium_service.dart';
import '../../../onboarding/presentation/screens/spiritual_onboarding_screen.dart';

/// Main screen for the AI Spiritual Chatbot.
/// Shows conversation history or active chat.
class SpiritualChatScreen extends ConsumerStatefulWidget {
  const SpiritualChatScreen({super.key, this.animationSeed = 0});

  /// When this changes (e.g. user switched to this tab), mood animations replay.
  final int animationSeed;

  @override
  ConsumerState<SpiritualChatScreen> createState() => _SpiritualChatScreenState();
}

class _SpiritualChatScreenState extends ConsumerState<SpiritualChatScreen> {
  // View state
  bool _showAIGuruHome = true; // AI Guru dashboard (hero, mood, ask anything, tools)
  bool _isInChat = false; // true = showing chat, false = showing history list

  // Current chat state
  SpiritualServiceType? _selectedService;
  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _askAnythingHomeController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpiritualChatService _chatService = SpiritualChatService();
  final ConsultationUsageService _usageService = ConsultationUsageService.instance;

  bool _isLoading = false;
  bool _readingDelivered = false;
  Map<String, dynamic>? _userProfile;
  String? _currentConversationId;

  final List<ConversationHistory> _conversationHistory = [];

  /// Same theme as My Growth / Ashram: orange–purple gradient, white border, radius 20.
  BoxDecoration get _streakStyleDecoration => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryOrange.withValues(alpha: 0.2),
            AppColors.deepPurple.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      );

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _persistConversations();
    _messageController.dispose();
    _askAnythingHomeController.dispose();
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

  void _showAllFeaturesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.ashramBackgroundDark,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => _AllFeaturesSheet(
        onServiceSelected: (service) {
          Navigator.of(context).pop();
          if (service == SpiritualServiceType.askAnything) {
            _onServiceSelected(service);
          } else {
            _startInsightService(service);
          }
        },
      ),
    );
  }

  void _showServiceSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.ashramBackgroundDark,
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
      _showAIGuruHome = false;
      _isInChat = true;
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
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: _streakStyleDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.get('delete_conversation', ref.read(languageProvider)),
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This will permanently delete this ${conversation.service.title} conversation.',
                style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      AppStrings.get('cancel', ref.read(languageProvider)),
                      style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.6)),
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
            ],
          ),
        ),
      ),
    );
  }

  void _goBackToAIGuruHome() {
    _saveCurrentConversation();
    setState(() {
      _showAIGuruHome = true;
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
      backgroundColor: AppColors.ashramBackgroundDark,
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
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: _streakStyleDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
          children: [
            const                 Icon(
                  Icons.lock_outline,
                  color: AppColors.primaryOrange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Monthly Limit Reached',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "You've used all ${ConsultationUsageService.freeMonthlyLimit} free consultations this month.",
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Upgrade to Premium for unlimited spiritual guidance!',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Maybe Later',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    PaywallScreen.showAsBottomSheet(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
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
          ],
        ),
      ),
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
          if (errorString.contains('quota') || errorString.contains('insufficient_quota')) {
            errorMessage = "The AI service has reached its usage limit. Please check your OpenAI account billing and plan at platform.openai.com, or try again later. 🙏";
          } else {
            errorMessage = "Too many requests. Please wait a moment and try again. 🙏";
          }
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
        if (_selectedService == SpiritualServiceType.askAnything) {
          await _usageService.incrementAskAnythingCount();
        }
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
        } else if (errorString.contains('429') && (errorString.contains('quota') || errorString.contains('insufficient_quota'))) {
          errorMessage = "The AI service has reached its usage limit. Please check your OpenAI account billing and plan at platform.openai.com, or try again later. 🙏";
        } else if (errorString.contains('429') || errorString.contains('rate limit')) {
          errorMessage = "Too many requests. Please wait a moment and try again. 🙏";
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

  Future<void> _onAskAnythingSendFromHome() async {
    final text = _askAnythingHomeController.text.trim();
    if (text.isEmpty) return;
    final canAsk = await _usageService.canAskAnything();
    if (!mounted) return;
    if (!canAsk) {
      _showAskAnythingLimitDialog();
      return;
    }
    _askAnythingHomeController.clear();
    _startAskAnythingAndGoToChat(text);
  }

  void _startAskAnythingAndGoToChat(String firstMessage) {
    final newConversation = ConversationHistory.create(
      service: SpiritualServiceType.askAnything,
    );
    setState(() {
      _selectedService = SpiritualServiceType.askAnything;
      _messages.clear();
      _userProfile = null;
      _currentConversationId = newConversation.id;
      _readingDelivered = false;
      _showAIGuruHome = false;
      _isInChat = true;
      _conversationHistory.insert(0, newConversation);
    });
    _addUserMessage(firstMessage);
  }

  void _showAskAnythingLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.ashramBackgroundDark,
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: _streakStyleDecoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primaryOrange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ask Anything limit reached',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "You've used your free Ask Anything questions this month. Upgrade to Premium for more spiritual guidance.",
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Maybe Later',
                      style: GoogleFonts.outfit(color: Colors.white70),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      PaywallScreen.showAsBottomSheet(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Upgrade',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startInsightService(SpiritualServiceType service) {
    final newConversation = ConversationHistory.create(service: service);
    setState(() {
      _selectedService = service;
      _messages.clear();
      _userProfile = null;
      _currentConversationId = newConversation.id;
      _readingDelivered = false;
      _showAIGuruHome = false;
      _isInChat = true;
      _conversationHistory.insert(0, newConversation);
    });
    _addGreetingMessage(service);
  }

  /// Opens the chat with the selected feeling as user message and AI response (no API call, no insight consumed).
  Future<void> _openFeelingInChat(String feelingId) async {
    final lang = ref.read(languageProvider);
    final title = FeelingResponses.getTitleForFeelingDisplay(feelingId, lang);
    final response = FeelingResponses.getResponseForFeeling(feelingId);
    if (response == null) return;

    FeelingRepository().logFeeling(feelingId);

    final newConversation = ConversationHistory.create(
      service: SpiritualServiceType.askAnything,
    );
    final weekday = DateTime.now().weekday;
    final suggestion =
        await FeelingRepository().getSuggestionForFeelingAndWeekday(feelingId, weekday);

    if (!mounted) return;
    setState(() {
      _selectedService = SpiritualServiceType.askAnything;
      _messages.clear();
      _userProfile = null;
      _currentConversationId = newConversation.id;
      _readingDelivered = false;
      _showAIGuruHome = false;
      _isInChat = true;
      _conversationHistory.insert(0, newConversation);

      final userContent = "I'm feeling $title";
      _messages.add(ChatMessage.user(
        conversationId: newConversation.id,
        content: userContent,
      ));
      _messages.add(ChatMessage.assistant(
        conversationId: newConversation.id,
        content: response,
      ));
      if (suggestion != null) {
        final suggestionText = suggestion.description != null &&
                suggestion.description!.isNotEmpty
            ? '${suggestion.title}\n\n${suggestion.description}'
            : suggestion.title;
        _messages.add(ChatMessage.assistant(
          conversationId: newConversation.id,
          content: "Today's suggestion: $suggestionText",
        ));
      }
    });
    _scrollToBottom();
  }

  void _showFeelingResponseSheet(String feelingId) {
    final lang = ref.read(languageProvider);
    final title = FeelingResponses.getTitleForFeelingDisplay(feelingId, lang);
    final response = FeelingResponses.getResponseForFeeling(feelingId);
    final emoji = FeelingResponses.getEmojiForFeeling(feelingId);
    if (response == null) return;

    // Save to Supabase for logged-in users
    FeelingRepository().logFeeling(feelingId);

    // Weekday 1 = Monday .. 7 = Sunday
    final weekday = DateTime.now().weekday;
    final suggestionFuture =
        FeelingRepository().getSuggestionForFeelingAndWeekday(feelingId, weekday);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.ashramBackgroundDark,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          left: 16,
          right: 16,
          top: 24,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryOrange.withValues(alpha: 0.2),
              AppColors.deepPurple.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji ?? '🙏', style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              response,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white70,
                height: 1.45,
              ),
            ),
            FutureBuilder<FeelingSuggestion?>(
              future: suggestionFuture,
              builder: (context, snap) {
                final suggestion = snap.data;
                if (suggestion == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline_rounded,
                              size: 18,
                              color: AppColors.primaryOrange,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Today's suggestion",
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryOrange,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          suggestion.title,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        if (suggestion.description != null &&
                            suggestion.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            suggestion.description!,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIGuruHomeView() {
    return FutureBuilder<bool>(
      future: PremiumService.instance.isPremium,
      builder: (context, premiumSnap) {
        final isPremium = premiumSnap.data ?? false;
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildAIGuruHeader(isPremium)),
            SliverToBoxAdapter(child: _buildMoodSection()),
            SliverToBoxAdapter(child: _buildAskAnythingCard(isPremium)),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        );
      },
    );
  }

  Widget _buildAIGuruHeader(bool isPremium) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.history_rounded),
              color: AppColors.primaryOrange,
              onPressed: _showPastConversationsSheet,
              tooltip: 'Past conversations',
            ),
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              color: AppColors.primaryOrange,
              onPressed: _showAllFeaturesSheet,
              tooltip: 'AI Stars',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSection() {
    final lang = ref.watch(languageProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: KeyedSubtree(
        key: ValueKey('mood_${widget.animationSeed}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BlinkingIcon(
              icon: Icons.auto_awesome,
              color: Colors.white.withValues(alpha: 0.9),
              size: 24,
            ),
            const SizedBox(height: 2),
            FutureBuilder<String?>(
              future: SpiritualOnboardingScreen.getStoredUserName(),
              builder: (context, snap) {
                final name = snap.data;
                final fullText = name != null && name.isNotEmpty
                    ? AppStrings.get('how_are_you_feeling_today_with_name', lang).replaceAll('{name}', name)
                    : AppStrings.get('how_are_you_feeling_today', lang);
                return TypewriterText(
                  text: fullText,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  duration: const Duration(milliseconds: 1800),
                );
              },
            ),
            const SizedBox(height: 4),
            _StaggeredFeelingGrid(languageCode: lang, onFeelingTap: _openFeelingInChat),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildAskAnythingCard(bool isPremium) {
    return FutureBuilder<int>(
      future: _usageService.getRemainingAskAnything(),
      builder: (context, snap) {
        final remaining = snap.data ?? 0;
        final canAsk = isPremium || remaining > 0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'ASK ANYTHING',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            isPremium ? 'PREMIUM ACTIVE' : '$remaining INSIGHTS LEFT',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryOrange.withValues(alpha: 0.9),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!canAsk)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Upgrade to ask more questions.',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: AppColors.primaryOrange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _askAnythingHomeController,
                                  enabled: canAsk,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Type your deepest inquiry...',
                                    hintStyle: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: Colors.white38,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withValues(alpha: 0.06),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                  ),
                                  onSubmitted: (_) => _onAskAnythingSendFromHome(),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Material(
                                color: canAsk ? AppColors.primaryOrange : Colors.grey.shade600,
                                borderRadius: BorderRadius.circular(24),
                                child: InkWell(
                                  onTap: canAsk ? _onAskAnythingSendFromHome : null,
                                  borderRadius: BorderRadius.circular(24),
                                  child: const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Recent Ask Anything conversations as pills
                    _buildRecentAskAnythingPills(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentAskAnythingPills() {
    final askAnythingConversations = _conversationHistory
        .where((c) => c.service == SpiritualServiceType.askAnything)
        .toList();
    if (askAnythingConversations.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Text(
            'RECENT INVOCATIONS',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryOrange.withValues(alpha: 0.85),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: askAnythingConversations.map((c) {
                final preview = (c.lastMessage != null && c.lastMessage!.isNotEmpty)
                    ? (c.lastMessage!.length > 24 ? '${c.lastMessage!.substring(0, 24)}...' : c.lastMessage!)
                    : 'Ask Anything';
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _resumeConversation(c);
                        setState(() {
                          _showAIGuruHome = false;
                          _isInChat = true;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                        child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Text(
                          preview,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ashramBackgroundDark,
      appBar: _showAIGuruHome ? null : _buildAppBar(),
      body: _showAIGuruHome ? _buildAIGuruHomeView() : _buildChatView(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.ashramBackgroundDark,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: _goBackToAIGuruHome,
        tooltip: 'Back to Home',
      ),
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
                    color: AppColors.primaryOrange,
                  ),
                ),
              ],
            )
          : Text(
              'Spiritual Advisor',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryOrange,
              ),
            ),
      actions: [
        IconButton(
          icon: const Icon(Icons.auto_awesome, color: AppColors.primaryOrange),
          onPressed: _showServiceSelector,
          tooltip: 'All Services',
        ),
      ],
    );
  }

  void _showPastConversationsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.ashramBackgroundDark,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryOrange.withValues(alpha: 0.2),
              AppColors.deepPurple.withValues(alpha: 0.2),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(
              'Past conversations',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryOrange,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: _conversationHistory.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No conversations yet. Start from Home or tap below.',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _conversationHistory.length,
                      itemBuilder: (context, index) {
                        final c = _conversationHistory[index];
                        return ListTile(
                          leading: Text(c.service.emoji, style: const TextStyle(fontSize: 20)),
                          title: Text(
                            c.service.title,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: c.lastMessage != null && c.lastMessage!.isNotEmpty
                              ? Text(
                                  c.lastMessage!.length > 40
                                      ? '${c.lastMessage!.substring(0, 40)}...'
                                      : c.lastMessage!,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.white60,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.white54, size: 20),
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteConversation(c);
                            },
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _resumeConversation(c);
                            setState(() {
                              _showAIGuruHome = false;
                              _isInChat = true;
                            });
                          },
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showServiceSelector();
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('New consultation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        // Usage indicator: insights left (Ask Anything) or consultations left
        _UsageBanner(
          usageService: _usageService,
          selectedService: _selectedService,
        ),
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
                    color: AppColors.primaryOrange.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.3)),
                  ),
                  child: const Center(
                    child: Text('🕉️', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryOrange.withValues(alpha: 0.15),
                        AppColors.deepPurple.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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

/// Feeling chips grid with staggered zoom-in animation (first to last).
class _StaggeredFeelingGrid extends StatefulWidget {
  final String languageCode;
  final void Function(String id) onFeelingTap;

  const _StaggeredFeelingGrid({required this.languageCode, required this.onFeelingTap});

  @override
  State<_StaggeredFeelingGrid> createState() => _StaggeredFeelingGridState();
}

class _StaggeredFeelingGridState extends State<_StaggeredFeelingGrid>
    with SingleTickerProviderStateMixin {
  static const _staggerDelay = 0.07;
  static const _animDuration = 0.22;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const gap = 8.0;
    final ids = FeelingResponses.allIds;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: gap),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: gap,
          crossAxisSpacing: gap,
          childAspectRatio: 1.05,
        ),
        itemCount: ids.length,
        itemBuilder: (context, index) {
          final id = ids[index];
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final start = index * _staggerDelay;
              final end = start + _animDuration;
              double t = 0;
              if (_controller.value <= start) {
                t = 0;
              } else if (_controller.value >= end) {
                t = 1;
              } else {
                t = (_controller.value - start) / (end - start);
              }
              t = Curves.easeOut.transform(t);
              final scale = 0.3 + 0.7 * t;
              final opacity = t;
              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: child,
                ),
              );
            },
            child: _buildChip(id, widget.languageCode),
          );
        },
      ),
    );
  }

  Widget _buildChip(String id, String languageCode) {
    final title = FeelingResponses.getTitleForFeelingDisplay(id, languageCode);
    final emoji = FeelingResponses.getEmojiForFeeling(id) ?? '🙏';
    final isJoyful = id == 'joyful';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onFeelingTap(id),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: TextStyle(
                  fontSize: 22,
                  color: isJoyful ? Colors.amber : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet: all features (services grid, premium insight, practice plan).
class _AllFeaturesSheet extends StatelessWidget {
  final void Function(SpiritualServiceType) onServiceSelected;

  const _AllFeaturesSheet({required this.onServiceSelected});

  static BoxDecoration get _cardDecoration => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryOrange.withValues(alpha: 0.2),
            AppColors.deepPurple.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      );

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Center(child: Text('🕉️', style: TextStyle(fontSize: 36))),
              const SizedBox(height: 8),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFF4E4B6), Color(0xFFD4AF37)],
                ).createShader(bounds),
                child: Center(
                  child: Text(
                    'Choose Your Guidance',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Select a spiritual service to begin your consultation',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              // Services grid (same layout as All features, content from Choose your guidance)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.1,
                children: SpiritualServiceType.values.map((service) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onServiceSelected(service),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: _cardDecoration,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(service.emoji, style: const TextStyle(fontSize: 32)),
                            const SizedBox(height: 6),
                            Text(
                              service.title,
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              service.shortDescription,
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.6),
                                height: 1.25,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // Premium Insight section
              Text(
                'Premium Insight Tools',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(height: 12),
              FutureBuilder<bool>(
                future: PremiumService.instance.isPremium,
                builder: (context, snap) {
                  final isPremium = snap.data ?? false;
                  if (isPremium) {
                    return Column(
                      children: [
                        _featureTile(context, 'Numerology', 'Life path & numbers', Icons.calculate, () => onServiceSelected(SpiritualServiceType.numerology)),
                        const SizedBox(height: 10),
                        _featureTile(context, 'Kundali Analysis', 'Birth chart insights', Icons.wb_sunny_outlined, () => onServiceSelected(SpiritualServiceType.kundli)),
                        const SizedBox(height: 10),
                        _featureTile(context, 'Palmistry', 'Palm reading', Icons.front_hand_outlined, () => onServiceSelected(SpiritualServiceType.palmistry)),
                      ],
                    );
                  }
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unlock deeper guidance',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Kundali, Palmistry, Numerology & more.',
                          style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70),
                        ),
                        const SizedBox(height: 12),
                        Material(
                          color: AppColors.primaryOrange,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => PaywallScreen.showAsBottomSheet(context),
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Text('Upgrade', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Practice plan card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.fact_check, color: AppColors.primaryOrange, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Personalized Practice Plan',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Updated 2 hours ago',
                      style: GoogleFonts.outfit(fontSize: 11, color: AppColors.primaryOrange.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 12),
                    Text('Morning: 15min Meditation • Afternoon: Breathing • Evening: Journaling', style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primaryOrange.withValues(alpha: 0.5)),
                          foregroundColor: AppColors.primaryOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("Begin Today's Journey", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _featureTile(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: _cardDecoration,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Icon(icon, color: AppColors.primaryOrange, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                    Text(subtitle, style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.primaryOrange.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget that shows remaining insights (Ask Anything) or consultations for free users.
class _UsageBanner extends StatelessWidget {
  final ConsultationUsageService usageService;
  final SpiritualServiceType? selectedService;

  const _UsageBanner({
    required this.usageService,
    this.selectedService,
  });

  @override
  Widget build(BuildContext context) {
    final isAskAnything =
        selectedService == SpiritualServiceType.askAnything;

    return FutureBuilder<int>(
      future: isAskAnything
          ? usageService.getRemainingAskAnything()
          : usageService.getRemainingConsultations(),
      builder: (context, snapshot) {
        final remaining = snapshot.data ?? -1;

        // Don't show for premium users (unlimited = -1)
        if (remaining < 0 || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final isLow = remaining <= 1;
        final String message = isAskAnything
            ? (isLow
                ? 'Only $remaining insight${remaining == 1 ? '' : 's'} left this month'
                : '$remaining insight${remaining == 1 ? '' : 's'} left this month')
            : (isLow
                ? 'Only $remaining consultation${remaining == 1 ? '' : 's'} remaining this month'
                : '$remaining free consultation${remaining == 1 ? '' : 's'} remaining this month');

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLow
                  ? [
                      Colors.orange.withValues(alpha: 0.2),
                      Colors.orange.withValues(alpha: 0.1),
                    ]
                  : [
                      AppColors.primaryOrange.withValues(alpha: 0.15),
                      AppColors.deepPurple.withValues(alpha: 0.08),
                    ],
            ),
            border: Border(
              bottom: BorderSide(
                color: isLow
                    ? Colors.orange.withValues(alpha: 0.3)
                    : AppColors.primaryOrange.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isLow ? Icons.warning_amber_rounded : Icons.auto_awesome,
                size: 16,
                color: isLow ? Colors.orange : AppColors.primaryOrange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isLow
                        ? Colors.orange
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  PaywallScreen.showAsBottomSheet(context);
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
                    color: AppColors.primaryOrange,
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

/// Typewriter animation: reveals [text] character by character over [duration].
class TypewriterText extends StatefulWidget {
  const TypewriterText({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(milliseconds: 1500),
    this.textAlign = TextAlign.center,
  });

  final String text;
  final TextStyle style;
  final Duration duration;
  final TextAlign textAlign;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final visibleLength = _animation.value.clamp(0, widget.text.length);
        final visibleText = widget.text.substring(0, visibleLength);
        return Text(
          visibleText,
          style: widget.style,
          textAlign: widget.textAlign,
        );
      },
    );
  }
}

/// Blinking icon: gentle opacity pulse to draw attention.
class BlinkingIcon extends StatefulWidget {
  const BlinkingIcon({
    super.key,
    required this.icon,
    this.color,
    this.size = 24,
  });

  final IconData icon;
  final Color? color;
  final double size;

  @override
  State<BlinkingIcon> createState() => _BlinkingIconState();
}

class _BlinkingIconState extends State<BlinkingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Icon(
        widget.icon,
        color: widget.color,
        size: widget.size,
      ),
    );
  }
}
