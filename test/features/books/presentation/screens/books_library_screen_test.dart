import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antarmarg/features/books/presentation/screens/books_library_screen.dart';
import 'package:antarmarg/features/books/data/repositories/book_repository.dart';
import 'package:antarmarg/features/books/data/models/book_model.dart';
import 'package:antarmarg/features/books/presentation/providers/book_providers.dart';

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
  test('bookRepositoryProvider override exposes FakeBookRepository', () {
    final container = ProviderContainer(
      overrides: [
        bookRepositoryProvider.overrideWithValue(FakeBookRepository()),
      ],
    );
    addTearDown(container.dispose);
    expect(container.read(bookRepositoryProvider), isA<FakeBookRepository>());
  });

  testWidgets('BooksLibraryScreen builds with fake book repository', (tester) async {
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
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    expect(find.byType(BooksLibraryScreen), findsOneWidget);
    expect(find.text('Read'), findsWidgets);
  });
}
