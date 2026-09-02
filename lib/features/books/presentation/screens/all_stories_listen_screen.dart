import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/localized.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/antarmarg_placeholder.dart';
import '../../data/models/granthalaya_models.dart';
import '../providers/book_providers.dart';
import 'story_audio_screen.dart';

class AllStoriesListenScreen extends ConsumerStatefulWidget {
  const AllStoriesListenScreen({super.key});

  @override
  ConsumerState<AllStoriesListenScreen> createState() => _AllStoriesListenScreenState();
}

class _AllStoriesListenScreenState extends ConsumerState<AllStoriesListenScreen> {
  String _searchQuery = '';
  String? _selectedDeity;
  final TextEditingController _searchController = TextEditingController();

  static const _deityGradients = <String, List<Color>>{
    'shiva': [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    'krishna': [Color(0xFF0E7490), Color(0xFF0891B2)],
    'hanuman': [Color(0xFFEA580C), Color(0xFFF59E0B)],
    'ganesha': [Color(0xFFE11D48), Color(0xFFF43F5E)],
  };

  List<Color> _getDeityGradient(String? slug) {
    if (slug == null) return const [Color(0xFFC5A059), Color(0xFFA88B3D)];
    return _deityGradients[slug.toLowerCase()] ?? const [Color(0xFFC5A059), Color(0xFFA88B3D)];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storiesAsync = ref.watch(storiesWithAudioProvider);
    final allStories = storiesAsync.valueOrNull ?? [];

    final deities = allStories.map((s) => s.deitySlug).where((d) => d != null && d.isNotEmpty).cast<String>().toSet().toList()..sort();

    var filtered = allStories.toList();
    if (_selectedDeity != null) filtered = filtered.where((s) => s.deitySlug?.toLowerCase() == _selectedDeity!.toLowerCase()).toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((s) => s.title.toLowerCase().contains(q) || (s.titleHindi?.toLowerCase().contains(q) ?? false)).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text('Stories Audio', style: GoogleFonts.crimsonPro(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search stories...',
                hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.3)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.3)),
                filled: true, fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          if (deities.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _filterChip('All', _selectedDeity == null, () => setState(() => _selectedDeity = null)),
                  ...deities.map((d) => _deityChip(d, _selectedDeity == d, () => setState(() => _selectedDeity = _selectedDeity == d ? null : d))),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: storiesAsync.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.matteGold))
                : filtered.isEmpty
                    ? Center(child: SizedBox(width: 160, height: 180, child: const AntarmargPlaceholder(compact: true)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 14, mainAxisSpacing: 14),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _buildCard(filtered[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(SacredStoryModel story) {
    final gradient = _getDeityGradient(story.deitySlug);
    final hasImage = story.coverImageUrl != null && story.coverImageUrl!.isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StoryAudioScreen(story: story))),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: gradient.first.withValues(alpha: 0.3)),
            color: const Color(0xFF0F0F0F),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: SizedBox(
                    width: double.infinity,
                    child: hasImage
                        ? Stack(fit: StackFit.expand, children: [
                            AppNetworkImage(imageUrl: story.coverImageUrl!, fit: BoxFit.cover),
                            Positioned(right: 8, bottom: 8, child: _playBadge()),
                          ])
                        : Container(
                            decoration: BoxDecoration(gradient: LinearGradient(colors: [gradient.first.withValues(alpha: 0.2), gradient.last.withValues(alpha: 0.1)])),
                            child: Center(child: Icon(Icons.auto_stories, color: gradient.first, size: 40)),
                          ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (story.deitySlug != null)
                        ShaderMask(
                          shaderCallback: (b) => LinearGradient(colors: gradient).createShader(b),
                          child: Text(story.deitySlug!.toUpperCase(), style: GoogleFonts.cinzel(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
                        ),
                      const SizedBox(height: 2),
                      Text(localized(ref, en: story.title, hi: story.titleHindi), style: GoogleFonts.crimsonPro(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      Text('${story.estimatedMinutes}m', style: GoogleFonts.inter(fontSize: 9, color: Colors.white.withValues(alpha: 0.5))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _playBadge() {
    return Container(width: 28, height: 28, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle), child: const Icon(Icons.play_arrow, color: AppColors.matteGold, size: 16));
  }

  Widget _filterChip(String label, bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: active ? AppColors.matteGold : Colors.transparent, borderRadius: BorderRadius.circular(999), border: Border.all(color: active ? AppColors.matteGold : AppColors.matteGold.withValues(alpha: 0.2))),
          child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: active ? Colors.black : AppColors.matteGold.withValues(alpha: 0.6))),
        ),
      ),
    );
  }

  Widget _deityChip(String slug, bool active, VoidCallback onTap) {
    final gradient = _getDeityGradient(slug);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: active ? gradient.first : Colors.transparent, borderRadius: BorderRadius.circular(999), border: Border.all(color: gradient.first.withValues(alpha: active ? 1 : 0.3))),
          child: Text(slug.replaceAll('_', ' '), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: active ? Colors.white : gradient.first)),
        ),
      ),
    );
  }
}
