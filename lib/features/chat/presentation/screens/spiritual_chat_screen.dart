import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../shared/services/feature_gate_config.dart';
import '../../../profile/presentation/providers/language_provider.dart';
import '../../../../shared/widgets/typing_indicator.dart';
import '../../../ai_guru/models/guru_message.dart';
import '../../../ai_guru/presentation/providers/guru_providers.dart';
import '../../../ai_guru/repositories/guru_repository.dart';
import '../../../ai_guru/services/guru_link_navigation.dart';
import '../../data/models/spiritual_service.dart';
import '../../data/models/chat_message.dart';
import '../../data/config/spiritual_service_prompts.dart';
import '../widgets/service_selector_modal.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/service_form_sheet.dart';
import '../../data/models/feeling_responses.dart';
import '../../data/repositories/feeling_repository.dart';
import '../../../../core/utils/profile_pro_upgrade_nav.dart';
import '../../../../shared/services/premium_service.dart';
import '../../../../core/services/revenuecat_service.dart';
import '../../../ai_guru/config/guru_credit_pack_config.dart';
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

  bool _isLoading = false;
  bool _readingDelivered = false;
  String? _currentConversationId;

  List<GuruConversationSummary> _conversationSummaries = [];

  /// Same family as AI Guru cards: saffron–violet gradient, white border, radius 20.
  BoxDecoration get _streakStyleDecoration => BoxDecoration(
        gradient: AppColors.aiGuruCardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      );

  @override
  void initState() {
    super.initState();
    // Defer network work until after first frame so tab switch / initial paint stays smooth.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _refreshConversationSummaries();
      await _syncGuruAiCreditsToSupabase();
    });
  }

  Future<void> _syncGuruAiCreditsToSupabase() async {
    if (!mounted) return;
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final tier = await ref.read(guruUserTierProvider.future);
      await ref.read(guruAiCreditsServiceProvider).syncTierToProfile(tier);
      ref.invalidate(guruCreditPeekProvider);
    } catch (e) {
      debugPrint('SpiritualChat: sync guru credits: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _askAnythingHomeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshConversationSummaries() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final list = await ref.read(guruRepositoryProvider).listConversations(uid);
      if (mounted) setState(() => _conversationSummaries = list);
    } catch (e) {
      debugPrint('Failed to load conversations: $e');
    }
  }

  SpiritualServiceType _serviceTypeFromDb(String service) {
    for (final v in SpiritualServiceType.values) {
      if (v.name == service) return v;
    }
    return SpiritualServiceType.askAnything;
  }

  List<ChatMessage> _mapGuruMessagesToChat(
    String conversationId,
    List<GuruMessage> rows,
  ) {
    return rows
        .map(
          (m) => ChatMessage(
            conversationId: conversationId,
            role: m.role == 'user' ? ChatRole.user : ChatRole.assistant,
            content: m.content,
            createdAt: m.createdAt,
          ),
        )
        .toList();
  }

  /// Opens or resumes the Supabase-backed thread. Returns conversation id, or null on failure.
  Future<String?> _openServiceConversation(
    SpiritualServiceType service, {
    bool skipGreetingWhenEmpty = false,
    bool loadExistingMessages = true,
  }) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in to chat with Guruji.')),
        );
      }
      return null;
    }
    final repo = ref.read(guruRepositoryProvider);
    try {
      final id = await repo.getOrCreateConversation(
        userId: uid,
        service: service.name,
      );
      final gm = loadExistingMessages
          ? await repo.getRecentMessages(id, limit: 100)
          : <GuruMessage>[];
      if (!mounted) return null;
      setState(() {
        _selectedService = service;
        _messages.clear();
        _messages.addAll(_mapGuruMessagesToChat(id, gm));
        _currentConversationId = id;
        _readingDelivered = _messages.any((m) => m.isReading);
        _showAIGuruHome = false;
        _isInChat = true;
      });
      if (_messages.isEmpty && !skipGreetingWhenEmpty) {
        _addGreetingMessage(service);
      }
      _scrollToBottom();
      return id;
    } catch (e, st) {
      debugPrint('Guru: open conversation failed: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_openChatFailureMessage(e)),
          ),
        );
      }
      return null;
    }
  }

  /// Maps PostgREST / Postgres errors to something actionable (often: run Supabase migrations).
  String _openChatFailureMessage(Object e) {
    final s = e.toString().toLowerCase();
    if (s.contains('check constraint') ||
        s.contains('violates check') ||
        s.contains('23514') ||
        s.contains('spiritual_chat_conversations_service')) {
      return 'Chat can’t start: database is missing Ask Anything rules. '
          'Run Supabase migrations (spiritual_chat_service_expand), then retry.';
    }
    if (s.contains('jwt') &&
        (s.contains('expired') || s.contains('invalid'))) {
      return 'Session expired. Sign in again to chat.';
    }
    if (s.contains('permission denied') || s.contains('rls')) {
      return 'No permission to open chat. Sign in again or check Supabase RLS policies.';
    }
    return 'Could not open chat. Check connection and try again.';
  }

  void _showAllFeaturesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.aiGuruSheetGradient,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: _AllFeaturesSheet(
          onServiceSelected: (service) {
            Navigator.of(context).pop();
            if (service == SpiritualServiceType.askAnything) {
              // Sheet already closed — do not pop again (would break navigation).
              _openServiceConversation(service);
            } else {
              _startInsightService(service);
            }
          },
        ),
      ),
    );
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
    _openServiceConversation(service);
  }

  Future<void> _resumeRemoteConversation(GuruConversationSummary summary) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    final repo = ref.read(guruRepositoryProvider);
    final gm = await repo.getRecentMessages(summary.id, limit: 100);
    if (!mounted) return;
    final service = _serviceTypeFromDb(summary.service);
    setState(() {
      _selectedService = service;
      _messages.clear();
      _messages.addAll(_mapGuruMessagesToChat(summary.id, gm));
      _currentConversationId = summary.id;
      _readingDelivered = _messages.any((m) => m.isReading);
      _isInChat = true;
    });
    _scrollToBottom();
  }

  void _deleteConversation(GuruConversationSummary summary) {
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
                'This will permanently delete this ${_serviceTypeFromDb(summary.service).title} conversation.',
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
                    onPressed: () async {
                      Navigator.pop(context);
                      await ref
                          .read(guruRepositoryProvider)
                          .deleteConversation(summary.id);
                      await _refreshConversationSummaries();
                      if (_currentConversationId == summary.id && mounted) {
                        setState(() {
                          _messages.clear();
                          _currentConversationId = null;
                          _isInChat = false;
                          _showAIGuruHome = true;
                        });
                      }
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
    Future<void>.microtask(_refreshConversationSummaries);
    setState(() {
      _showAIGuruHome = true;
      _isInChat = false;
    });
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

    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in to continue.')),
        );
      }
      return;
    }
    final tier = await ref.read(guruUserTierProvider.future);
    await ref.read(guruAiCreditsServiceProvider).syncTierToProfile(tier);
    final peek = await ref.read(guruAiCreditsServiceProvider).peek();
    if (peek != null && peek.totalSendable <= 0 && mounted) {
      _showQuotaDialog(tier);
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
  
  void _showQuotaDialog(UserTier currentTier) {
    final wFree = FeatureGateConfig.guruWeeklyIncludedFree;
    final wPlus = FeatureGateConfig.guruWeeklyIncludedPlus;
    final wPro = FeatureGateConfig.guruWeeklyIncludedPro;

    final (String body, String primaryLabel) = switch (currentTier) {
      UserTier.free => (
          "You've used this week's included messages with Guruji ($wFree per week on Free).\n\n"
              'Subscribe to Plus or Pro for more each week, or buy credit packs to keep chatting.',
          'View plans',
        ),
      UserTier.plus => (
          "You've used this week's included messages ($wPlus per week on Plus).\n\n"
              'Upgrade to Pro for $wPro per week, or buy credit packs for more anytime.',
          'Upgrade to Pro',
        ),
      UserTier.pro => (
          "You've used this week's included Pro messages ($wPro per week).\n\n"
              'Buy credit packs to keep talking with Guruji without waiting for next week.',
          'Buy credits',
        ),
    };

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFFBF0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'No messages left this week',
          style: TextStyle(
            color: Color(0xFF7C2D12),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          body,
          style: GoogleFonts.outfit(
            fontSize: 14,
            height: 1.4,
            color: const Color(0xFF44403C),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Not now'),
          ),
          if (GuruCreditPackConfig.configuredPacks().isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showBuyCreditsSheet();
              },
              child: const Text('Buy credits'),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB45309),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              if (currentTier == UserTier.pro) {
                _showBuyCreditsSheet();
              } else {
                Navigator.pushNamed(context, AppRouter.paywall);
              }
            },
            child: Text(primaryLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _showBuyCreditsSheet() async {
    final packs = GuruCreditPackConfig.configuredPacks();
    if (packs.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Credit packs are not configured yet. Add GURU_CREDITS_PRODUCT_ID_* to .env and App Store Connect.',
            ),
          ),
        );
      }
      return;
    }
    final rc = RevenueCatService.instance;
    if (!rc.isInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Store is not ready. Try again in a moment.')),
        );
      }
      return;
    }
    final ids = packs.map((p) => p.productId).toList();
    final products = await rc.getStoreProducts(ids);
    final byId = {for (final p in products) p.identifier: p};
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.aiGuruSheetGradient,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'AI Guru credits',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Used after your weekly included messages. Credits do not expire with the week.',
                  style: GoogleFonts.outfit(fontSize: 13, color: AppColors.zinc500, height: 1.35),
                ),
                const SizedBox(height: 16),
                ...packs.map((pack) {
                  final sp = byId[pack.productId];
                  final label = sp?.priceString ?? '${pack.credits} credits';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ElevatedButton(
                      onPressed: sp == null
                          ? null
                          : () async {
                              Navigator.pop(ctx);
                              final out = await rc.purchaseStoreProduct(sp);
                              if (!mounted) return;
                              if (out.success) {
                                final ok = await ref
                                    .read(guruAiCreditsServiceProvider)
                                    .grantPurchasedCredits(pack.credits);
                                ref.invalidate(guruCreditPeekProvider);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      ok
                                          ? '+${pack.credits} credits added'
                                          : 'Purchase OK but could not add credits. Contact support.',
                                    ),
                                  ),
                                );
                              } else if (out.errorMessage != null &&
                                  !(out.cancelled)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(out.errorMessage!)),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        '${pack.credits} credits — $label',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onFormSubmitted(Map<String, dynamic> formData) {
    Navigator.of(context).pop();
    
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

  List<String> _quickRepliesAfterReading(SpiritualServiceType service) {
    switch (service) {
      case SpiritualServiceType.palmistry:
        return const [
          'Heart line aur love life par aur detail',
          'Career / fate line timing',
          'Koi remedy ya daily practice',
        ];
      case SpiritualServiceType.kundli:
        return const [
          'Career aur dasha par aur',
          'Relationship timing',
          'Remedies batayein',
        ];
      case SpiritualServiceType.numerology:
        return const [
          'Mulank aur Namank aur detail',
          'Is saal ka focus',
          'Aur ek sawaal hai',
        ];
      case SpiritualServiceType.mantra:
        return const [
          'Mantra ki roz ki practice',
          'Is mantra ka aur matlab',
          'Dusra mantra suggest karein',
        ];
      case SpiritualServiceType.upcomingEvents:
        return const [
          'Aage ke tyohaar aur batao',
          'Meri date ke hisaab se',
          'Nayi consultation',
        ];
      case SpiritualServiceType.askAnything:
        return const [
          'Aur detail mein samjhao',
          'Mere paas ek sawaal hai',
          'Nayi consultation',
        ];
    }
  }

  Future<void> _requestReading(Map<String, dynamic> formData) async {
    if (_selectedService == null || _currentConversationId == null) return;

    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;

    setState(() => _isLoading = true);
    _scrollToBottom();

    final contextMessage = _buildReadingRequest(formData);
    String? palmImage;
    if (_selectedService == SpiritualServiceType.palmistry) {
      palmImage = formData['palmImage'] as String?;
    }

    final tier = await ref.read(guruUserTierProvider.future);
    final result = await ref.read(guruApiServiceProvider).sendMessage(
          userId: uid,
          tier: tier,
          conversationId: _currentConversationId!,
          service: _selectedService!,
          userMessage: contextMessage,
          imageBase64: palmImage,
          imageMediaType: 'image/jpeg',
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isQuotaExceeded) {
      _showQuotaDialog(result.tier!);
      return;
    }
    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? 'Something went wrong.')),
      );
      return;
    }

    if (!_readingDelivered) {
      _readingDelivered = true;
    }
    setState(() {
      _messages.add(ChatMessage.assistant(
        conversationId: _currentConversationId!,
        content: result.reply!,
        isReading: true,
        quickReplies: _quickRepliesAfterReading(_selectedService!),
      ));
    });
    await _refreshConversationSummaries();
    ref.invalidate(guruCreditPeekProvider);
    _scrollToBottom();
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

  void _addUserMessage(String content, {String? conversationId}) {
    final cid = conversationId ?? _currentConversationId ?? 'temp';
    setState(() {
      _messages.add(ChatMessage.user(
        conversationId: cid,
        content: content,
      ));
    });
    _scrollToBottom();
    _sendMessage(content, conversationId: conversationId);
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

  Future<void> _sendMessage(String content, {String? conversationId}) async {
    final cid = conversationId ?? _currentConversationId;
    final service = _selectedService;
    if (service == null || cid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chat is not ready. Please try sending again.'),
          ),
        );
      }
      return;
    }

    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in to chat with Guruji.')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    _scrollToBottom();

    final now = DateTime.now();
    final messageWithContext =
        "Today's date: ${now.day}/${now.month}/${now.year}. User message: $content";

    final tier = await ref.read(guruUserTierProvider.future);
    final result = await ref.read(guruApiServiceProvider).sendMessage(
          userId: uid,
          tier: tier,
          conversationId: cid,
          service: service,
          userMessage: messageWithContext,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isQuotaExceeded) {
      _showQuotaDialog(result.tier!);
      return;
    }
    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? 'Something went wrong.')),
      );
      return;
    }

    setState(() {
      _messages.add(ChatMessage.assistant(
        conversationId: _currentConversationId!,
        content: result.reply!,
      ));
    });
    await _refreshConversationSummaries();
    ref.invalidate(guruCreditPeekProvider);
    _scrollToBottom();
  }

  void _onSendMessage() {
    if (_isLoading) return;
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    _addUserMessage(text);
  }

  Future<void> _onAskAnythingSendFromHome() async {
    final text = _askAnythingHomeController.text.trim();
    if (text.isEmpty) return;
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in to chat with Guruji.')),
        );
      }
      return;
    }
    _askAnythingHomeController.clear();
    final conversationId = await _openServiceConversation(
      SpiritualServiceType.askAnything,
      skipGreetingWhenEmpty: true,
    );
    if (!mounted || conversationId == null) return;
    _addUserMessage(text, conversationId: conversationId);
  }

  void _startInsightService(SpiritualServiceType service) {
    _openServiceConversation(service);
  }

  /// Opens Ask Anything chat, shows scripted comfort + optional ashram suggestion.
  /// Persists to Supabase so the next Guruji (OpenAI) reply has full context — user can keep chatting.
  Future<void> _openFeelingInChat(String feelingId) async {
    final lang = ref.read(languageProvider);
    final title = FeelingResponses.getTitleForFeelingDisplay(feelingId, lang);
    final response = FeelingResponses.getResponseForFeeling(feelingId);
    if (response == null) return;

    FeelingRepository().logFeeling(feelingId);

    final weekday = DateTime.now().weekday;
    final suggestion =
        await FeelingRepository().getSuggestionForFeelingAndWeekday(feelingId, weekday);

    if (!mounted) return;

    // Load real thread from DB so UI matches history the model will see on the next send.
    final cid = await _openServiceConversation(
      SpiritualServiceType.askAnything,
      skipGreetingWhenEmpty: true,
      loadExistingMessages: true,
    );
    if (!mounted || cid == null) return;

    final userContent = "I'm feeling $title";
    final repo = ref.read(guruRepositoryProvider);
    String? suggestionLine;
    if (suggestion != null) {
      suggestionLine = suggestion.description != null &&
              suggestion.description!.isNotEmpty
          ? '${suggestion.title}\n\n${suggestion.description}'
          : suggestion.title;
    }

    try {
      await repo.saveMessage(cid, 'user', userContent);
      await repo.saveMessage(cid, 'assistant', response);
      if (suggestionLine != null) {
        await repo.saveMessage(
          cid,
          'assistant',
          "Today's suggestion: $suggestionLine",
        );
      }
    } catch (e, st) {
      debugPrint('Guru: persist feeling messages failed: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save this moment. Try again.'),
          ),
        );
      }
      return;
    }

    if (!mounted) return;
    try {
      final fresh = await repo.getRecentMessages(cid, limit: 100);
      if (!mounted) return;
      setState(() {
        _messages.clear();
        _messages.addAll(_mapGuruMessagesToChat(cid, fresh));
        _readingDelivered = _messages.any((m) => m.isReading);
      });
    } catch (e, st) {
      debugPrint('Guru: reload after feeling failed: $e\n$st');
      if (!mounted) return;
      setState(() {
        _messages.add(ChatMessage.user(
          conversationId: cid,
          content: userContent,
        ));
        _messages.add(ChatMessage.assistant(
          conversationId: cid,
          content: response,
        ));
        if (suggestionLine != null) {
          _messages.add(ChatMessage.assistant(
            conversationId: cid,
            content: "Today's suggestion: $suggestionLine",
          ));
        }
      });
    }
    _scrollToBottom();
  }

  Widget _buildAIGuruHomeView() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildAIGuruHeader()),
        SliverToBoxAdapter(child: _buildMoodSection()),
        SliverToBoxAdapter(child: _buildAskAnythingCard()),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  Widget _buildAIGuruHeader() {
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
              onPressed: _openPastConversationsSheet,
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
      child: RepaintBoundary(
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
      ),
    );
  }

  Widget _buildAskAnythingCard() {
    final tierAsync = ref.watch(guruUserTierProvider);
    final peekAsync = ref.watch(guruCreditPeekProvider);
    final UserTier tier = tierAsync.maybeWhen(
      data: (t) => t,
      orElse: () => UserTier.free,
    );
    final peek = peekAsync.valueOrNull;
    final total = peek?.totalSendable ?? 0;
    final canAsk = total > 0;
    final badge = peekAsync.isLoading
        ? '…'
        : peek == null
            ? '—'
            : '${tier.name.toUpperCase()} • $total left this week';

    return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.08),
                          AppColors.deepPurple.withValues(alpha: 0.15),
                          AppColors.primaryOrange.withValues(alpha: 0.06),
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
                                badge,
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
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'No weekly messages left. Upgrade or buy credits.',
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            color: AppColors.primaryOrange,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      if (GuruCreditPackConfig.configuredPacks().isNotEmpty)
                                        TextButton(
                                          onPressed: _showBuyCreditsSheet,
                                          child: Text(
                                            'Buy credits',
                                            style: GoogleFonts.outfit(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primaryOrange,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _askAnythingHomeController,
                                      enabled: canAsk,
                                      textInputAction: TextInputAction.send,
                                      onSubmitted: (_) {
                                        if (canAsk) _onAskAnythingSendFromHome();
                                      },
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
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Material(
                                    color: canAsk ? AppColors.primaryOrange : Colors.grey.shade600,
                                    borderRadius: BorderRadius.circular(24),
                                    child: InkWell(
                                      onTap: canAsk ? () => _onAskAnythingSendFromHome() : null,
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
                        _buildRecentAskAnythingPills(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
  }

  Widget _buildRecentAskAnythingPills() {
    final askRows = _conversationSummaries
        .where((c) => c.service == SpiritualServiceType.askAnything.name)
        .take(8)
        .toList();
    if (askRows.isEmpty) return const SizedBox.shrink();
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
              children: askRows.map((c) {
                final preview = (c.title != null && c.title!.isNotEmpty)
                    ? (c.title!.length > 24 ? '${c.title!.substring(0, 24)}...' : c.title!)
                    : 'Ask Anything';
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await _resumeRemoteConversation(c);
                        if (mounted) {
                          setState(() {
                            _showAIGuruHome = false;
                            _isInChat = true;
                          });
                        }
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.aiGuruScreenGradient),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_showAIGuruHome) _buildAppBar(),
              Expanded(
                child: _showAIGuruHome ? _buildAIGuruHomeView() : _buildChatView(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
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

  Future<void> _openPastConversationsSheet() async {
    await _refreshConversationSummaries();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.aiGuruSheetGradient,
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
              child: _conversationSummaries.isEmpty
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
                      itemCount: _conversationSummaries.length,
                      itemBuilder: (context, index) {
                        final c = _conversationSummaries[index];
                        final svc = _serviceTypeFromDb(c.service);
                        return ListTile(
                          leading: Text(svc.emoji, style: const TextStyle(fontSize: 20)),
                          title: Text(
                            svc.title,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: c.title != null && c.title!.isNotEmpty
                              ? Text(
                                  c.title!.length > 40
                                      ? '${c.title!.substring(0, 40)}...'
                                      : c.title!,
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
                          onTap: () async {
                            Navigator.pop(context);
                            await _resumeRemoteConversation(c);
                            if (mounted) {
                              setState(() {
                                _showAIGuruHome = false;
                                _isInChat = true;
                              });
                            }
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
        Expanded(child: _buildChatBody()),
        _buildChatQuotaLine(),
        ChatInputBar(
          controller: _messageController,
          onSend: _onSendMessage,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildChatQuotaLine() {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    final service = _selectedService;
    final peekAsync = ref.watch(guruCreditPeekProvider);

    if (uid == null || service == null) {
      return const SizedBox.shrink();
    }

    return peekAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (peek) {
        if (peek == null) return const SizedBox.shrink();
        final rem = peek.totalSendable;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6, top: 2),
          child: Text(
            rem == 0
                ? 'No messages left this week  •  Buy credits or wait for reset'
                : '$rem message${rem == 1 ? '' : 's'} left this week (included + purchased)',
            style: TextStyle(
              fontSize: 11,
              color: rem <= 1 ? Colors.orange[700] : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
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
                    gradient: AppColors.aiGuruCardGradient,
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
          onGuruLinkTap: (type, value) =>
              navigateFromGuruLink(context, type, value),
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
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return GridView.builder(
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
                    child: _buildChip(id, widget.languageCode),
                  ),
                );
              },
            );
          },
        ),
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
        gradient: AppColors.aiGuruCardGradient,
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
                            onTap: () => navigateToProfileForProUpgrade(context),
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
      duration: const Duration(milliseconds: 2600),
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
