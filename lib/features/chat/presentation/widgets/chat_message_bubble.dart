import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../ai_guru/services/guru_link_parser.dart';
import '../../data/models/chat_message.dart';

/// Widget that displays a single chat message bubble.
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(String)? onQuickReplyTap;
  final void Function(String type, String value)? onGuruLinkTap;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onQuickReplyTap,
    this.onGuruLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                _buildAvatar(),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: _buildMessageContent(context, isUser),
              ),
              if (isUser) ...[
                const SizedBox(width: 8),
                _buildUserAvatar(),
              ],
            ],
          ),
          // Quick replies
          if (!isUser && message.quickReplies != null && message.quickReplies!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 44, top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: message.quickReplies!.map((reply) {
                  return _QuickReplyChip(
                    label: reply,
                    onTap: () => onQuickReplyTap?.call(reply),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: AppColors.aiGuruBubbleGradient,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: const Center(
        child: Text('🕉️', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.earthBrown.withValues(alpha:0.3),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.earthBrown.withValues(alpha:0.3),
          width: 1,
        ),
      ),
      child: const Center(
        child: Icon(Icons.person, color: Colors.white70, size: 20),
      ),
    );
  }

  static const Color _guruLinkBg = Color(0xFFFFF4E6);
  static const Color _guruLinkFg = Color(0xFF7C2D12);

  Widget _buildMessageText(BuildContext context, bool isUser) {
    final baseStyle = GoogleFonts.outfit(
      fontSize: 14,
      color: Colors.white.withValues(alpha: 0.9),
      height: 1.5,
    );
    if (isUser) {
      return SelectableText(
        message.content,
        style: baseStyle,
      );
    }
    final segments = GuruLinkParser.parse(message.content);
    final hasLinks = segments.any((s) => s is GuruLinkSegment);
    if (!hasLinks) {
      return SelectableText(
        message.content,
        style: baseStyle,
      );
    }
    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          for (final s in segments)
            if (s is GuruTextSegment)
              TextSpan(text: s.text)
            else if (s is GuruLinkSegment)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  child: Material(
                    color: _guruLinkBg.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: onGuruLinkTap != null
                          ? () => onGuruLinkTap!(s.type, s.value)
                          : null,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: Text(
                          '${s.type}: ${s.value}',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _guruLinkFg,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, bool isUser) {
    final timeFormat = DateFormat('h:mm a');
    
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: EdgeInsets.all(message.isReading ? 16 : 12),
      decoration: BoxDecoration(
        gradient: isUser
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.earthBrown.withValues(alpha:0.4),
                  AppColors.earthBrown.withValues(alpha:0.2),
                ],
              )
            : message.isReading
                ? AppColors.aiGuruCardGradient
                : AppColors.aiGuruBubbleGradient,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(6),
          bottomRight: isUser ? const Radius.circular(6) : const Radius.circular(20),
        ),
        border: Border.all(
          color: isUser
              ? AppColors.earthBrown.withValues(alpha: 0.2)
              : message.isReading
                  ? AppColors.primaryOrange.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isReading)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: AppColors.primaryOrange,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Your Reading',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ],
              ),
            ),
          // Display image if present
          if (message.imageBase64 != null && message.imageBase64!.isNotEmpty)
            _buildImagePreview(context, message.imageBase64!),
          if (message.content.isNotEmpty) _buildMessageText(context, isUser),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              timeFormat.format(message.createdAt),
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, String base64Image) {
    try {
      final Uint8List bytes = base64Decode(base64Image);
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GestureDetector(
          onTap: () => _showFullImage(context, bytes),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: 200,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primaryOrange.withValues(alpha: 0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Image.memory(
                    bytes,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        color: Colors.grey.withValues(alpha: 0.2),
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.white54),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha:0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.back_hand_outlined,
                            color: AppColors.primaryOrange,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Palm Image',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      return Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha:0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('Image could not be loaded', style: TextStyle(color: Colors.white54)),
        ),
      );
    }
  }

  void _showFullImage(BuildContext context, Uint8List bytes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                child: Image.memory(
                  bytes,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha:0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickReplyChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickReplyChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryOrange.withValues(alpha: 0.2),
                AppColors.deepPurple.withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryOrange,
            ),
          ),
        ),
      ),
    );
  }
}
