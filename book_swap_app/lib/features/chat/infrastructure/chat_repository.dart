import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:book_swap_app/features/chat/domain/chat_message.dart';
import 'package:book_swap_app/features/chat/domain/chat_metadata.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _chatsCollection =>
      _firestore.collection('chats');

  /// Creates or updates a chat when a swap is initiated.
  /// We'll use the swapOfferId as the chatId for simplicity.
  Future<void> initializeChat(
      String chatId, String bookTitle, List<String> participantIds) async {
    // Use set with merge: true so we don't overwrite if it exists
    await _chatsCollection.doc(chatId).set({
      'bookTitle': bookTitle,
      'participantIds': participantIds,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageText': 'Chat started',
    }, SetOptions(merge: true));
  }

  /// Sends a message and updates the chat metadata.
  Future<void> sendMessage(String chatId, String senderId, String text) async {
    final batch = _firestore.batch();

    // 1. Add message to subcollection
    final messageRef =
    _chatsCollection.doc(chatId).collection('messages').doc();
    final message = ChatMessage(senderId: senderId, text: text);
    batch.set(messageRef, message.toJson());

    // 2. Update chat metadata (for the overview screen)
    final chatRef = _chatsCollection.doc(chatId);
    batch.update(chatRef, {
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageText': text,
    });

    await batch.commit();
  }

  /// STREAM: Get all messages for a specific chat
  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _chatsCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true) // Newest first
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatMessage.fromFirestore(doc))
        .toList());
  }

  /// STREAM: Get all chats I am participating in
  Stream<List<ChatMetadata>> getMyChats(String userId) {
    return _chatsCollection
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatMetadata.fromFirestore(doc))
        .toList());
  }
}