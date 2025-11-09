import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_swap_app/core/constants/colors.dart';
import 'package:book_swap_app/core/widgets/loading_indicator.dart';
import 'package:book_swap_app/features/book_listings/application/book_providers.dart';
import 'package:book_swap_app/features/book_listings/domain/swap_offer.dart';
import 'package:book_swap_app/features/book_listings/presentation/widgets/book_card.dart';
import 'package:book_swap_app/features/book_listings/presentation/widgets/swap_offer_card.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Listings'),
          backgroundColor: kBackgroundColor,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Books'),
              Tab(text: 'My Offers'),
            ],
            indicatorColor: kSecondaryColor,
            labelColor: kSecondaryColor,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: TabBarView(
          children: [
            // --- Tab 1: My Books ---
            _MyBooksTab(),

            // --- Tab 2: My Offers (Incoming) ---
            _MyOffersTab(),
          ],
        ),
      ),
    );
  }
}

class _MyBooksTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myBooksAsync = ref.watch(myBooksProvider);

    return myBooksAsync.when(
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
                // ... (Delete logic remains exactly the same as before)
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
    );
  }
}

class _MyOffersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomingSwapsAsync = ref.watch(incomingSwapsProvider);

    return incomingSwapsAsync.when(
      loading: () => const LoadingIndicator(),
      error: (err, stack) {
        // You will probably get an Index Error here!
        // Click the link in your console to create the index for the 'swaps' collection.
        print(err);
        return Center(
            child: Text('Error: $err\n\n(Have you created the Firestore Index?)'));
      },
      data: (offers) {
        if (offers.isEmpty) {
          return const Center(
            child: Text(
              'You have no incoming swap offers.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: offers.length,
          itemBuilder: (context, index) {
            final offer = offers[index];
            return SwapOfferCard(
              offer: offer,
              onAccept: () async {
                try {
                  await ref.read(bookRepositoryProvider).updateSwapStatus(
                    offer.id!,
                    offer.bookId,
                    SwapStatus.Accepted,
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed: $e')),
                    );
                  }
                }
              },
              onReject: () async {
                try {
                  await ref.read(bookRepositoryProvider).updateSwapStatus(
                    offer.id!,
                    offer.bookId,
                    SwapStatus.Rejected,
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed: $e')),
                    );
                  }
                }
              },
            );
          },
        );
      },
    );
  }
}