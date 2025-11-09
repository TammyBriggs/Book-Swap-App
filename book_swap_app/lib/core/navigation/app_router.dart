import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_swap_app/features/auth/application/auth_providers.dart';
import 'package:book_swap_app/features/auth/presentation/login_screen.dart';
import 'package:book_swap_app/features/auth/presentation/signup_screen.dart';
import 'package:book_swap_app/features/auth/presentation/verify_email_screen.dart';
import 'package:book_swap_app/features/navigation/presentation/main_shell.dart';
import 'package:book_swap_app/features/book_listings/presentation/browse_listings_screen.dart';
import 'package:book_swap_app/features/book_listings/presentation/my_listings_screen.dart';
import 'package:book_swap_app/features/chat/presentation/chats_overview_screen.dart';
import 'package:book_swap_app/features/auth/presentation/settings_screen.dart';
import 'package:book_swap_app/features/book_listings/presentation/post_book_screen.dart';
import 'package:book_swap_app/features/book_listings/domain/book.dart';
import 'package:book_swap_app/features/chat/presentation/chat_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _browseNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'browse');
final _myListingsNavigatorKey =
GlobalKey<NavigatorState>(debugLabel: 'myListings');
final _chatsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'chats');
final _settingsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/browse',
    navigatorKey: _rootNavigatorKey,
    redirect: (context, state) {
      final userAsyncValue = authState;
      final currentLocation = state.uri.toString();

      if (userAsyncValue.isLoading) return null;

      if (userAsyncValue.hasError ||
          !userAsyncValue.hasValue ||
          userAsyncValue.value == null) {
        if (currentLocation != '/login' && currentLocation != '/signup') {
          return '/login';
        }
        return null;
      }

      final user = userAsyncValue.value!;
      if (!user.emailVerified) {
        if (currentLocation != '/verify-email') {
          return '/verify-email';
        }
        return null;
      }

      if (currentLocation == '/login' ||
          currentLocation == '/signup' ||
          currentLocation == '/verify-email') {
        return '/browse';
      }

      if (currentLocation == '/') {
        return '/browse';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      // MOVED TO TOP LEVEL
      GoRoute(
        path: '/post-book',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final bookToEdit = state.extra as Book?;
          return PostBookScreen(bookToEdit: bookToEdit);
        },
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _browseNavigatorKey,
            routes: [
              GoRoute(
                path: '/browse',
                builder: (context, state) => const BrowseListingsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _myListingsNavigatorKey,
            routes: [
              GoRoute(
                path: '/my-listings',
                builder: (context, state) => const MyListingsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _chatsNavigatorKey,
            routes: [
              GoRoute(
                path: '/chats',
                builder: (context, state) => const ChatsOverviewScreen(),
                routes: [
                  GoRoute(
                    path: ':chatId',
                    builder: (context, state) {
                      final chatId = state.pathParameters['chatId']!;
                      final title =
                          state.uri.queryParameters['title'] ?? 'Chat';
                      return ChatScreen(chatId: chatId, chatTitle: title);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});