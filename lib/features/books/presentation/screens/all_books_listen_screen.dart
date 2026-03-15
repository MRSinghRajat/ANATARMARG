import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/antarmarg_placeholder.dart';
import '../../data/models/book_model.dart';
import '../providers/book_providers.dart';
import 'book_audio_detail_screen.dart';

class AllBooksListenScreen extends ConsumerStatefulWidget {
  const AllBooksListenScreen({super.key});

  @override
  ConsumerState<AllBooksListenScreen> createState() => _AllBooksListenScreenState();
}

class _AllBooksListenScreenState extends ConsumerState<AllBooksListenScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksWithAudioProvider);
    final allBooks = booksAsync.valueOrNull ?? [];

    var filtered = allBooks.toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((b) => b.name.toLowerCase().contains(q) || (b.nameSanskrit?.toLowerCase().contains(q) ?? false)).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text('Audiobooks', style: GoogleFonts.crimsonPro(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
                hintText: 'Search audiobooks...',
                hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.white.withValues(alpha: 0.3)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.3)),
                filled: true, fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: booksAsync.isLoading
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

  Widget _buildCard(BookModel book) {
    final hasImage = book.coverImageUrl != null && book.coverImageUrl!.isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookAudioDetailScreen(book: book))),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.matteGold.withValues(alpha: 0.15)),
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
                            AppNetworkImage(imageUrl: book.coverImageUrl!, fit: BoxFit.cover),
                            Positioned(right: 8, bottom: 8, child: _playBadge()),
                          ])
                        : Container(
                            color: AppColors.matteGold.withValues(alpha: 0.05),
                            child: const Center(child: Icon(Icons.menu_book, color: AppColors.matteGold, size: 40)),
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
                      Text(book.name, style: GoogleFonts.crimsonPro(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      Text('${book.totalChapters} chapters', style: GoogleFonts.inter(fontSize: 9, color: Colors.white.withValues(alpha: 0.5))),
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
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle),
      child: const Icon(Icons.play_arrow, color: AppColors.matteGold, size: 16),
    );
  }
}
