import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/book_repository.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository();
});

/// True = Read mode (show book resume bar). False = Listen mode (audio player only).
final granthalayaReadModeProvider = StateProvider<bool>((ref) => true);
