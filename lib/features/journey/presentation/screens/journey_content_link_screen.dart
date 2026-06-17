import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../books/data/datasources/supabase_granthalaya_datasource.dart';
import '../../../books/presentation/screens/sacred_text_reader_screen.dart';
import '../../../books/presentation/screens/all_sacred_stories_screen.dart';

/// Gateway screen that resolves a ref_type + ref_id/slug from the journey
/// content pool into the correct Granthalaya screen.
///
/// Supported ref_type values:
///   'sacred_text' — fetches SacredTextModel by slug, opens SacredTextReaderScreen
///   'sacred_story' — opens AllSacredStoriesScreen
///
/// Usage from journey task detail:
///   Navigator.of(context).pushNamed(
///     AppRouter.journeyOpenContent,
///     arguments: {'refType': 'sacred_text', 'refIdOrSlug': 'vishnu-sahasranama'},
///   );
class JourneyContentLinkScreen extends ConsumerStatefulWidget {
  final String refType;
  final String refIdOrSlug;
  final String? displayTitle;

  const JourneyContentLinkScreen({
    super.key,
    required this.refType,
    required this.refIdOrSlug,
    this.displayTitle,
  });

  @override
  ConsumerState<JourneyContentLinkScreen> createState() =>
      _JourneyContentLinkScreenState();
}

class _JourneyContentLinkScreenState
    extends ConsumerState<JourneyContentLinkScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  Future<void> _resolve() async {
    if (!mounted || _navigated) return;
    switch (widget.refType) {
      case 'sacred_text':
        await _openSacredText();
        return;
      case 'sacred_story':
        _openSacredStories();
        return;
      default:
        if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _openSacredText() async {
    try {
      final ds = SupabaseGranthalayaDataSource();
      final model = await ds.getSacredTextBySlug(widget.refIdOrSlug);
      if (!mounted) return;
      if (model == null) {
        _showError('Content not found.');
        return;
      }
      _navigated = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SacredTextReaderScreen(sacredText: model)),
      );
    } catch (_) {
      if (mounted) _showError('Could not load content. Please try again.');
    }
  }

  void _openSacredStories() {
    _navigated = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AllSacredStoriesScreen()),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ashramBackgroundDark,
      appBar: AppBar(
        title: Text(
          widget.displayTitle ?? 'Opening…',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.zinc100),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.zinc100,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: const Center(
        child: CircularProgressIndicator(color: AppColors.primaryOrange),
      ),
    );
  }
}
