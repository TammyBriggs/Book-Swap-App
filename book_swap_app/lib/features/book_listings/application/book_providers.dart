import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_swap_app/features/auth/application/auth_providers.dart';
import 'package:book_swap_app/features/book_listings/domain/book.dart';
import 'package:book_swap_app/features/book_listings/infrastructure/book_repository.dart';

import '../domain/swap_offer.dart';

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
  // 1. Watch the auth state provider, NOT just the current user.
  // This forces the provider to rebuild whenever the user logs in or out.
  final authState = ref.watch(authStateProvider);

  // 2. Get the user from the async value
  final user = authState.value;

  if (user == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(bookRepositoryProvider);
  return repository.getBooksByOwner(user.uid);
});

// 5. Stream of outgoing swap offers (Offers I made)
final outgoingSwapsProvider = StreamProvider<List<SwapOffer>>((ref) {
  // FIX: Watch authStateProvider, not just currentUser
  final authState = ref.watch(authStateProvider);
  final user = authState.value;

  if (user == null) return Stream.value([]);

  final repository = ref.watch(bookRepositoryProvider);
  return repository.getOutgoingSwaps(user.uid);
});

// 6. Stream of incoming swap offers (Offers I received)
final incomingSwapsProvider = StreamProvider<List<SwapOffer>>((ref) {
  // FIX: Watch authStateProvider here too!
  final authState = ref.watch(authStateProvider);
  final user = authState.value;

  if (user == null) return Stream.value([]);

  final repository = ref.watch(bookRepositoryProvider);
  return repository.getIncomingSwaps(user.uid);
});