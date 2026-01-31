import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/book_repository.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository();
});
