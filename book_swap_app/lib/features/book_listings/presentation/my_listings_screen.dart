import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
            _MyBooksTab(),
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
              onEditPressed: () {
                context.push('/post-book', extra: book);
              },
              onDeletePressed: () async {
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
                    await ref.read(bookRepositoryProvider).deleteBook(book.id!);
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
    final incomingAsync = ref.watch(incomingSwapsProvider);
    final outgoingAsync = ref.watch(outgoingSwapsProvider);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          color: Colors.black12,
          child: const Text('Received Offers',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: incomingAsync.when(
            loading: () => const LoadingIndicator(),
            error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      'Error: $err\n\n(Have you created the Firestore Index for the "swaps" collection?)'),
                )),
            data: (offers) {
              if (offers.isEmpty) {
                return const Center(
                    child: Text('No received offers.',
                        style: TextStyle(color: Colors.grey)));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  return SwapOfferCard(
                    offer: offer,
                    isOutgoing: false,
                    onAccept: () => ref
                        .read(bookRepositoryProvider)
                        .updateSwapStatus(
                        offer.id!, offer.bookId, SwapStatus.accepted),
                    onReject: () => ref
                        .read(bookRepositoryProvider)
                        .updateSwapStatus(
                        offer.id!, offer.bookId, SwapStatus.rejected),
                  );
                },
              );
            },
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          color: Colors.black12,
          child: const Text('Sent Requests',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: outgoingAsync.when(
            loading: () => const LoadingIndicator(),
            error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      'Error: $err\n\n(Have you created the Firestore Index for the "swaps" collection?)'),
                )),
            data: (offers) {
              if (offers.isEmpty) {
                return const Center(
                    child: Text('No sent requests.',
                        style: TextStyle(color: Colors.grey)));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: offers.length,
                itemBuilder: (context, index) {
                  final offer = offers[index];
                  return SwapOfferCard(
                    offer: offer,
                    isOutgoing: true,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}