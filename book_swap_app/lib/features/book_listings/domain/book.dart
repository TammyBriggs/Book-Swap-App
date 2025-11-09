import 'package:cloud_firestore/cloud_firestore.dart';

enum BookCondition { brandNew, likeNew, good, used }

enum BookStatus { available, pending, swapped }

class Book {
  final String? id;
  final String title;
  final String author;
  final BookCondition condition;
  final String imageUrl;
  final String ownerId;
  final String ownerEmail;
  final BookStatus status;
  final Timestamp createdAt;
  final String? swapForBookId;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.condition,
    required this.imageUrl,
    required this.ownerId,
    required this.ownerEmail,
    this.status = BookStatus.available,
    Timestamp? createdAt,
    this.swapForBookId,
  }) : createdAt = createdAt ?? Timestamp.now();

  String get conditionString {
    if (condition == BookCondition.brandNew) {
      return 'New';
    }
    if (condition == BookCondition.likeNew) {
      return 'Like New';
    }
    String text = condition.toString().split('.').last;
    return text[0].toUpperCase() + text.substring(1);
  }

  String get statusString {
    String text = status.toString().split('.').last;
    return text[0].toUpperCase() + text.substring(1);
  }

  factory Book.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      condition: BookCondition.values.firstWhere(
            (e) =>
        e.toString().split('.').last.toLowerCase() ==
            data['condition']?.toString().toLowerCase(),
        orElse: () => BookCondition.used,
      ),
      imageUrl: data['imageUrl'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerEmail: data['ownerEmail'] ?? '',
      status: BookStatus.values.firstWhere(
            (e) =>
        e.toString().split('.').last.toLowerCase() ==
            data['status']?.toString().toLowerCase(),
        orElse: () => BookStatus.available,
      ),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      swapForBookId: data['swapForBookId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'condition': condition.toString().split('.').last,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'status': status.toString().split('.').last,
      'createdAt': createdAt,
      'swapForBookId': swapForBookId,
    };
  }

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