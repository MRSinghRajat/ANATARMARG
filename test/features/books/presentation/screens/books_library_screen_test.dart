import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ashrae_playground/features/books/presentation/screens/books_library_screen.dart';
import 'package:ashrae_playground/features/books/data/repositories/book_repository.dart';
import 'package:ashrae_playground/features/books/data/models/book_model.dart';
import 'package:ashrae_playground/features/books/presentation/providers/book_providers.dart';
import 'package:ashrae_playground/shared/widgets/app_network_image.dart';

class FakeBookRepository implements BookRepository {
  @override
  Future<List<BookModel>> getAllBooks() async {
    return [
      BookModel(
        id: '1',
        name: 'Test Book',
        description: 'Test Description',
        totalChapters: 10,
        coverImageUrl: 'https://example.com/image.jpg',
      ),
    ];
  }

  @override
  List<BookModel> get allBooks => [];

  @override
  Future<BookModel?> getBookById(String id) async => null;
}

void main() {
  testWidgets('renders AppNetworkImage for book with image', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bookRepositoryProvider.overrideWithValue(FakeBookRepository()),
        ],
        child: const MaterialApp(
          home: BooksLibraryScreen(),
        ),
      ),
    );

    // Wait for data
    await tester.pumpAndSettle();

    // Verify AppNetworkImage widget is present
    expect(find.byType(AppNetworkImage), findsOneWidget);

    // Verify properties
    final imageWidget = tester.widget<AppNetworkImage>(find.byType(AppNetworkImage));
    expect(imageWidget.imageUrl, 'https://example.com/image.jpg');
  });
}
