import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/antarmarg_placeholder.dart';
import '../../data/models/meditation_guide_model.dart';
import '../providers/book_providers.dart';
import 'meditation_audio_screen.dart';

class AllMeditationListenScreen extends ConsumerStatefulWidget {
  const AllMeditationListenScreen({super.key});

  @override
  ConsumerState<AllMeditationListenScreen> createState() => _AllMeditationListenScreenState();
}

class _AllMeditationListenScreenState extends ConsumerState<AllMeditationListenScreen> {
  String _searchQuery = '';
  String? _selectedType;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final medsAsync = ref.watch(meditationGuidesProvider);
    final allMeds = medsAsync.valueOrNull ?? [];

    final types = allMeds.map((m) => m.meditationType).toSet().toList()..sort();

    var filtered = allMeds.toList();
    if (_selectedType != null) filtered = filtered.where((m) => m.meditationType == _selectedType).toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((m) => m.guideName.toLowerCase().contains(q) || m.meditationType.toLowerCase().contains(q)).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text('Meditation', style: GoogleFonts.crimsonPro(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
                hintText: 'Search meditation guides...',
                hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.3)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.3)),
                filled: true, fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          if (types.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _filterChip('All', _selectedType == null, () => setState(() => _selectedType = null)),
                  ...types.map((t) {
                    final label = MeditationGuideModel(id: '', guideName: '', meditationType: t, durationSeconds: 0, difficulty: '', totalSteps: 0, steps: []).typeLabel;
                    return _filterChip(label, _selectedType == t, () => setState(() => _selectedType = _selectedType == t ? null : t));
                  }),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: medsAsync.isLoading
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

  Widget _buildCard(MeditationGuideModel guide) {
    final hasImage = guide.coverImageUrl != null && guide.coverImageUrl!.isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MeditationAudioScreen(guide: guide))),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
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
                            AppNetworkImage(imageUrl: guide.coverImageUrl!, fit: BoxFit.cover),
                            Positioned(right: 8, bottom: 8, child: _playBadge()),
                          ])
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.purple.withValues(alpha: 0.2), Colors.indigo.withValues(alpha: 0.1)]),
                            ),
                            child: const Center(child: Icon(Icons.self_improvement, color: AppColors.matteGold, size: 40)),
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
                      Text(guide.typeLabel.toUpperCase(), style: GoogleFonts.cinzel(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.purple, letterSpacing: 1)),
                      const SizedBox(height: 2),
                      Text(guide.guideName, style: GoogleFonts.crimsonPro(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      Text('${guide.durationFormatted} · ${guide.difficulty}', style: GoogleFonts.inter(fontSize: 9, color: Colors.white.withValues(alpha: 0.5))),
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
}
