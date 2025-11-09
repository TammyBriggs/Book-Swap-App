import 'package:cloud_firestore/cloud_firestore.dart';

enum SwapStatus { Pending, Accepted, Rejected }

class SwapOffer {
  final String? id;
  final String bookId;
  final String bookTitle;
  final String bookOwnerId;
  final String bookOwnerEmail;

  final String requesterId;
  final String requesterEmail;

  final SwapStatus status;
  final Timestamp createdAt;

  SwapOffer({
    this.id,
    required this.bookId,
    required this.bookTitle,
    required this.bookOwnerId,
    required this.bookOwnerEmail,
    required this.requesterId,
    required this.requesterEmail,
    this.status = SwapStatus.Pending,
    Timestamp? createdAt,
  }) : createdAt = createdAt ?? Timestamp.now();

  String get statusString => status.toString().split('.').last;

  factory SwapOffer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SwapOffer(
      id: doc.id,
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      bookOwnerId: data['bookOwnerId'] ?? '',
      bookOwnerEmail: data['bookOwnerEmail'] ?? '',
      requesterId: data['requesterId'] ?? '',
      requesterEmail: data['requesterEmail'] ?? '',
      status: SwapStatus.values.firstWhere(
            (e) => e.toString() == 'SwapStatus.${data['status']}',
        orElse: () => SwapStatus.Pending,
      ),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookOwnerId': bookOwnerId,
      'bookOwnerEmail': bookOwnerEmail,
      'requesterId': requesterId,
      'requesterEmail': requesterEmail,
      'status': statusString,
      'createdAt': createdAt,
    };
  }
}