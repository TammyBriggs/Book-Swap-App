import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:book_swap_app/core/constants/colors.dart';
import 'package:book_swap_app/features/book_listings/domain/swap_offer.dart';

class SwapOfferCard extends StatelessWidget {
  final SwapOffer offer;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final bool isOutgoing;

  const SwapOfferCard({
    super.key,
    required this.offer,
    this.onAccept,
    this.onReject,
    this.isOutgoing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: kPrimaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isOutgoing
                  ? 'You requested: ${offer.bookTitle}'
                  : 'Offer for: ${offer.bookTitle}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isOutgoing
                  ? 'Owner: ${offer.bookOwnerEmail}'
                  : 'From: ${offer.requesterEmail}',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Sent: ${timeago.format(offer.createdAt.toDate())}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 12),

            // Show Accept/Reject only if it's INCOMING and PENDING
            if (!isOutgoing && offer.status == SwapStatus.Pending)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onReject,
                    child: const Text('Reject',
                        style: TextStyle(color: Colors.redAccent)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSecondaryColor,
                      foregroundColor: kPrimaryColor,
                    ),
                    child: const Text('Accept'),
                  ),
                ],
              )
            else
            // Otherwise, just show the status
              Text(
                'Status: ${offer.statusString}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: offer.status == SwapStatus.Accepted
                      ? Colors.green
                      : offer.status == SwapStatus.Rejected
                      ? Colors.red
                      : Colors.orange, // Pending
                ),
              ),
          ],
        ),
      ),
    );
  }
}