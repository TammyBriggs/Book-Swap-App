import 'package:cloud_firestore/cloud_firestore.dart';

// Enum for book condition (from rubric)
enum BookCondition { New, LikeNew, Good, Used }

// Enum for book status
enum BookStatus { Available, Pending, Swapped }

class Book {
  final String? id; // Document ID
  final String title;
  final String author;
  final BookCondition condition;
  final String imageUrl;
  final String ownerId;
  final String ownerEmail; // Useful for display
  final BookStatus status;
  final Timestamp createdAt;
  // This field will be added when a swap is requested
  final String? swapForBookId;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.condition,
    required this.imageUrl,
    required this.ownerId,
    required this.ownerEmail,
    this.status = BookStatus.Available,
    Timestamp? createdAt,
    this.swapForBookId,
  }) : createdAt = createdAt ?? Timestamp.now();

  // Helper to convert enum to string for Firestore
  String get conditionString => condition.toString().split('.').last;
  String get statusString => status.toString().split('.').last;

  // Factory to create a Book from a Firestore Document
  factory Book.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      condition: BookCondition.values.firstWhere(
            (e) => e.toString() == 'BookCondition.${data['condition']}',
        orElse: () => BookCondition.Used,
      ),
      imageUrl: data['imageUrl'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerEmail: data['ownerEmail'] ?? '',
      status: BookStatus.values.firstWhere(
            (e) => e.toString() == 'BookStatus.${data['status']}',
        orElse: () => BookStatus.Available,
      ),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      swapForBookId: data['swapForBookId'],
    );
  }

  // Method to convert Book object to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'condition': conditionString,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'status': statusString,
      'createdAt': createdAt,
      'swapForBookId': swapForBookId,
    };
  }

  // CopyWith method for easy updates
  Book copyWith({
    String? id,
    String? title,
    String? author,
    BookCondition? condition,
    String? imageUrl,
    String? ownerId,
    String? ownerEmail,
    BookStatus? status,
    Timestamp? createdAt,
    String? swapForBookId,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      condition: condition ?? this.condition,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      swapForBookId: swapForBookId ?? this.swapForBookId,
    );
  }
}