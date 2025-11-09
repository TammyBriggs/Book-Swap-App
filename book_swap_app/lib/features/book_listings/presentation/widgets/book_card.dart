import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:book_swap_app/core/constants/colors.dart';
import 'package:book_swap_app/features/book_listings/domain/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final bool isMyListing;
  final VoidCallback? onSwapPressed;
  final VoidCallback? onDeletePressed;

  const BookCard({
    super.key,
    required this.book,
    this.isMyListing = false,
    this.onSwapPressed,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: kPrimaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Book Cover Image ---
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                book.imageUrl,
                width: 80,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 120,
                  color: Colors.grey[800],
                  child: const Icon(Icons.book, color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // --- Book Details ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By ${book.author}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),

                  // Condition Badge
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: kSecondaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      book.conditionString,
                      style: const TextStyle(
                        color: kSecondaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Posted Time
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        timeago.format(book.createdAt.toDate()),
                        style:
                        const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- Action Button (Swap or Delete) ---
            if (isMyListing)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: onDeletePressed,
              )
            else if (book.status == BookStatus.Available)
            // We will implement the actual swap logic later
              ElevatedButton(
                onPressed: onSwapPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSecondaryColor,
                  foregroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 36), // Compact button
                ),
                child: const Text('Swap'),
              ),
          ],
        ),
      ),
    );
  }
}