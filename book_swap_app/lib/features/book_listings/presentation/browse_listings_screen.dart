import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:book_swap_app/core/constants/colors.dart';
import 'package:book_swap_app/core/widgets/loading_indicator.dart';
import 'package:book_swap_app/features/book_listings/application/book_providers.dart';
import 'package:book_swap_app/features/book_listings/presentation/widgets/book_card.dart';
import 'package:book_swap_app/features/auth/application/auth_providers.dart';

class BrowseListingsScreen extends ConsumerWidget {
  const BrowseListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(availableBooksProvider);
    final currentUser = ref.watch(firebaseAuthProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Listings'),
        backgroundColor: kBackgroundColor,
        elevation: 0,
      ),
      body: booksAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (books) {
          if (books.isEmpty) {
            return const Center(
              child: Text(
                'No books available yet.\nBe the first to post!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              final isMyBook = book.ownerId == currentUser?.uid;

              return BookCard(
                book: book,
                onSwapPressed: isMyBook
                    ? null
                    : () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Confirm Swap'),
                      content:
                      Text('Request to swap for "${book.title}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Request',
                              style: TextStyle(color: kSecondaryColor)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    try {
                      await ref.read(bookRepositoryProvider).requestSwap(
                        book,
                        currentUser!,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Swap request sent!')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed: ${e.toString()}')),
                        );
                      }
                    }
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/post-book'),
        backgroundColor: kSecondaryColor,
        foregroundColor: kPrimaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Post Book'),
      ),
    );
  }
}