import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_swap_app/core/constants/colors.dart';
import 'package:book_swap_app/core/widgets/loading_indicator.dart';
import 'package:book_swap_app/features/auth/application/auth_providers.dart';
import 'package:book_swap_app/features/chat/application/chat_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String chatTitle;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.chatTitle,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear(); // Optimistic clear
    try {
      final user = ref.read(firebaseAuthProvider).currentUser!;
      await ref.read(chatRepositoryProvider).sendMessage(
        widget.chatId,
        user.uid,
        text,
      );
    } catch (e) {
      // Handle error (maybe show snackbar)
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final currentUser = ref.watch(firebaseAuthProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatTitle),
        backgroundColor: kBackgroundColor,
      ),
      body: Column(
        children: [
          // --- Message List ---
          Expanded(
            child: messagesAsync.when(
              loading: () => const LoadingIndicator(),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }
                return ListView.builder(
                  reverse: true, // Show newest at the bottom
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUser?.uid;

                    return Align(
                      alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? kSecondaryColor : Colors.grey[800],
                          borderRadius: BorderRadius.circular(20).copyWith(
                            bottomRight:
                            isMe ? Radius.zero : const Radius.circular(20),
                            bottomLeft:
                            !isMe ? Radius.zero : const Radius.circular(20),
                          ),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: isMe ? kPrimaryColor : Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // --- Message Input ---
          Container(
            padding: const EdgeInsets.all(8),
            color: kBackgroundColor,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: kSecondaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: kPrimaryColor),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}