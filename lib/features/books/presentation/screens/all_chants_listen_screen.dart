import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/antarmarg_placeholder.dart';
import '../../data/models/granthalaya_models.dart';
import '../providers/book_providers.dart';
import '../providers/now_playing_provider.dart';

class AllChantsListenScreen extends ConsumerStatefulWidget {
  const AllChantsListenScreen({super.key});

  @override
  ConsumerState<AllChantsListenScreen> createState() => _AllChantsListenScreenState();
}

class _AllChantsListenScreenState extends ConsumerState<AllChantsListenScreen> {
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

  void _playChant(ChantModel chant) {
    ref.read(nowPlayingProvider.notifier).setTrackAndPlay(
      title: chant.title,
      subtitle: chant.subtitle,
      coverUrl: chant.imageUrl,
      audioUrl: chant.effectiveAudioUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chantsAsync = ref.watch(chantsProvider);
    final allChants = chantsAsync.valueOrNull ?? [];

    final deities = allChants.map((c) => c.deitySlug).where((d) => d != null && d.isNotEmpty).cast<String>().toSet().toList()..sort();

    var filtered = allChants.toList();
    if (_selectedDeity != null) filtered = filtered.where((c) => c.deitySlug?.toLowerCase() == _selectedDeity!.toLowerCase()).toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((c) => c.title.toLowerCase().contains(q) || (c.subtitle?.toLowerCase().contains(q) ?? false)).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text('All Chants', style: GoogleFonts.crimsonPro(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
                hintText: 'Search chants...',
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
            child: chantsAsync.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.matteGold))
                : filtered.isEmpty
                    ? Center(child: SizedBox(width: 160, height: 180, child: const AntarmargPlaceholder(compact: true)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _buildChantTile(filtered[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildChantTile(ChantModel chant) {
    final gradient = _getDeityGradient(chant.deitySlug);
    final hasImage = chant.imageUrl != null && chant.imageUrl!.isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _playChant(chant),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: gradient.first.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 56, height: 56,
                  child: hasImage
                      ? AppNetworkImage(imageUrl: chant.imageUrl!, fit: BoxFit.cover)
                      : Container(
                          decoration: BoxDecoration(gradient: LinearGradient(colors: [gradient.first.withValues(alpha: 0.2), gradient.last.withValues(alpha: 0.1)])),
                          child: Icon(Icons.music_note, color: gradient.first, size: 24),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (chant.deitySlug != null)
                      ShaderMask(
                        shaderCallback: (b) => LinearGradient(colors: gradient).createShader(b),
                        child: Text(chant.deitySlug!.toUpperCase(), style: GoogleFonts.cinzel(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
                      ),
                    Text(chant.title, style: GoogleFonts.crimsonPro(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(chant.subtitle ?? chant.durationFormatted, style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
                  ],
                ),
              ),
              const Icon(Icons.play_circle_fill, color: AppColors.matteGold, size: 32),
            ],
          ),
        ),
      ),
    );
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
