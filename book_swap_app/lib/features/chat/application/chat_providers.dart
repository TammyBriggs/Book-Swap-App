import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:book_swap_app/features/auth/application/auth_providers.dart';
import 'package:book_swap_app/features/chat/infrastructure/chat_repository.dart';
import 'package:book_swap_app/features/chat/domain/chat_message.dart';
import 'package:book_swap_app/features/chat/domain/chat_metadata.dart';

// 1. Provide Repository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(FirebaseFirestore.instance);
});

// 2. Stream of my chats
final myChatsProvider = StreamProvider<List<ChatMetadata>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(chatRepositoryProvider).getMyChats(user.uid);
});

// 3. Family Stream Provider for messages in a SPECIFIC chat
// "Family" means it takes an argument (the chatId)
final chatMessagesProvider =
StreamProvider.family<List<ChatMessage>, String>((ref, chatId) {
  return ref.watch(chatRepositoryProvider).getMessages(chatId);
});