import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_swap_app/features/auth/application/auth_providers.dart';
import 'package:book_swap_app/features/book_listings/domain/book.dart';
import 'package:book_swap_app/features/book_listings/infrastructure/book_repository.dart';

// 1. Provide Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// 2. Provide BookRepository
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepository(ref.watch(firestoreProvider));
});

// 3. Stream of ALL available books (for Browse Screen)
final availableBooksProvider = StreamProvider<List<Book>>((ref) {
  final repository = ref.watch(bookRepositoryProvider);
  return repository.getAvailableBooks();
});

// 4. Stream of MY books (for My Listings Screen)
final myBooksProvider = StreamProvider<List<Book>>((ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) {
    // Should never happen due to auth wrapper, but good for safety
    return Stream.value([]);
  }
  final repository = ref.watch(bookRepositoryProvider);
  return repository.getBooksByOwner(user.uid);
});