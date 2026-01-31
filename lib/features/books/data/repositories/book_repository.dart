import '../models/book_model.dart';
import '../datasources/supabase_book_datasource.dart';
import '../../../../core/services/supabase_service.dart';

class BookRepository {
  static final BookRepository _instance = BookRepository._internal();
  factory BookRepository() => _instance;
  BookRepository._internal();

  final SupabaseBookDataSource _supabaseDataSource = SupabaseBookDataSource();
  final SupabaseService _supabase = SupabaseService();

  // Fallback: Hardcoded books if Supabase is not available
  // Order and progress match reference: Ramayana first (45%), Mahabharata (12%)
  List<BookModel> get _defaultBooks => [
        BookModel(
          id: 'ramayan',
          name: 'Ramayana',
          description:
              'The story of Lord Rama, exemplifying righteousness, devotion, and ideal conduct.',
          totalChapters: 7,
          completedChapters: 3, // ~45% for reference UI
        ),
        BookModel(
          id: 'mahabharata',
          name: 'Mahabharata',
          description:
              'The great epic of ancient India, exploring dharma, duty, and the human condition.',
          totalChapters: 18,
          completedChapters: 2, // ~12% for reference UI
        ),
        BookModel(
          id: 'bhagavad_gita',
          name: 'Bhagavad Gita',
          description:
              'The song of God, teachings on dharma, karma, and the path to liberation.',
          totalChapters: 18,
          completedChapters: 0,
        ),
      ];

  /// Fetch all books - tries Supabase first, falls back to local data
  Future<List<BookModel>> getAllBooks() async {
    if (_supabase.isInitialized) {
      try {
        final books = await _supabaseDataSource.getAllBooks();
        // Use fallback if Supabase returns empty (no books in database yet)
        if (books.isEmpty) {
          return _defaultBooks;
        }
        // Update progress based on user progress if authenticated
        if (_supabase.currentUserId != null) {
          var updatedBooks = <BookModel>[];
          for (var book in books) {
            final progress = await _supabaseDataSource.getUserBookProgress(
              book.id,
              _supabase.currentUserId!,
            );
            if (progress != null) {
              updatedBooks.add(BookModel(
                id: book.id,
                name: book.name,
                nameSanskrit: book.nameSanskrit,
                description: book.description,
                totalChapters: book.totalChapters,
                completedChapters: progress['completed_chapters'] as int? ?? 0,
                coverImagePath: book.coverImagePath,
                coverImageUrl: book.coverImageUrl,
                category: book.category,
                language: book.language,
                lastReadAt: progress['last_read_at'] != null
                    ? DateTime.parse(progress['last_read_at'] as String)
                    : null,
                createdAt: book.createdAt,
                updatedAt: book.updatedAt,
              ));
            } else {
              updatedBooks.add(book);
            }
          }
          return updatedBooks;
        }
        return books;
      } catch (e) {
        print('Error fetching from Supabase, using local data: $e');
        return _defaultBooks;
      }
    }
    return _defaultBooks;
  }

  List<BookModel> get allBooks => _defaultBooks; // For synchronous access

  /// Fetch a single book by ID - tries Supabase first, falls back to local data
  Future<BookModel?> getBookById(String id) async {
    if (_supabase.isInitialized) {
      try {
        final book = await _supabaseDataSource.getBookById(id);
        if (book != null) {
          // Update progress if authenticated
          if (_supabase.currentUserId != null) {
            final progress = await _supabaseDataSource.getUserBookProgress(
              book.id,
              _supabase.currentUserId!,
            );
            if (progress != null) {
              return BookModel(
                id: book.id,
                name: book.name,
                nameSanskrit: book.nameSanskrit,
                description: book.description,
                totalChapters: book.totalChapters,
                completedChapters: progress['completed_chapters'] as int? ?? 0,
                coverImagePath: book.coverImagePath,
                coverImageUrl: book.coverImageUrl,
                category: book.category,
                language: book.language,
                lastReadAt: progress['last_read_at'] != null
                    ? DateTime.parse(progress['last_read_at'] as String)
                    : null,
                createdAt: book.createdAt,
                updatedAt: book.updatedAt,
              );
            }
          }
          return book;
        }
      } catch (e) {
        print('Error fetching book from Supabase, using local data: $e');
      }
    }
    try {
      return allBooks.firstWhere((book) => book.id == id);
    } catch (e) {
      return null;
    }
  }
}
