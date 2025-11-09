import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String? id;
  final String senderId;
  final String text;
  final Timestamp timestamp;

  ChatMessage({
    this.id,
    required this.senderId,
    required this.text,
    Timestamp? timestamp,
  }) : timestamp = timestamp ?? Timestamp.now();

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
    };
  }
}