import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:book_swap_app/core/constants/colors.dart';
import 'package:book_swap_app/core/widgets/loading_indicator.dart';
import 'package:book_swap_app/features/chat/application/chat_providers.dart';

class ChatsOverviewScreen extends ConsumerWidget {
  const ChatsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myChatsAsync = ref.watch(myChatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: kBackgroundColor,
        elevation: 0,
      ),
      body: myChatsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (chats) {
          if (chats.isEmpty) {
            return const Center(
              child: Text(
                'No active chats.\nStart a swap to chat!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }
          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: kSecondaryColor,
                  child: Text(chat.bookTitle[0].toUpperCase(),
                      style: const TextStyle(color: kPrimaryColor)),
                ),
                title: Text(
                  chat.bookTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  chat.lastMessageText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  timeago.format(chat.lastMessageTime.toDate(),
                      locale: 'en_short'),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  // Navigate to the specific chat screen
                  // We need to pass the chatId and title
                  context.push('/chats/${chat.id}?title=${chat.bookTitle}');
                },
              );
            },
          );
        },
      ),
    );
  }
}