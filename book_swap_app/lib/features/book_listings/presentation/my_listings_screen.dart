import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_swap_app/core/constants/colors.dart';
import 'package:book_swap_app/core/widgets/loading_indicator.dart';
import 'package:book_swap_app/features/book_listings/application/book_providers.dart';
import 'package:book_swap_app/features/book_listings/presentation/widgets/book_card.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myBooksAsync = ref.watch(myBooksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        backgroundColor: kBackgroundColor,
        elevation: 0,
      ),
      body: myBooksAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (books) {
          if (books.isEmpty) {
            return const Center(
              child: Text(
                'You haven\'t posted any books yet.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return BookCard(
                book: book,
                isMyListing: true,
                onDeletePressed: () async {
                  // Confirm deletion
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Listing?'),
                      content: const Text(
                          'Are you sure you want to remove this book?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && book.id != null) {
                    try {
                      await ref
                          .read(bookRepositoryProvider)
                          .deleteBook(book.id!);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Listing deleted successfully')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to delete: $e')),
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
    );
  }
}