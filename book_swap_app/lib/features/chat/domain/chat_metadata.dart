import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a chat conversation in the 'chats' collection
class ChatMetadata {
  final String id; // The chat document ID (same as swapOfferId)
  final String bookTitle;
  final List<String> participantIds; // [userA_uid, userB_uid]
  final Timestamp lastMessageTime;
  final String lastMessageText;

  ChatMetadata({
    required this.id,
    required this.bookTitle,
    required this.participantIds,
    required this.lastMessageTime,
    required this.lastMessageText,
  });

  factory ChatMetadata.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMetadata(
      id: doc.id,
      bookTitle: data['bookTitle'] ?? 'Chat',
      participantIds: List<String>.from(data['participantIds'] ?? []),
      lastMessageTime: data['lastMessageTime'] ?? Timestamp.now(),
      lastMessageText: data['lastMessageText'] ?? '',
    );
  }
}