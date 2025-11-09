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

// Private key for the root navigator
final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/browse',
    navigatorKey: _rootNavigatorKey,
    redirect: (context, state) {
      final userAsyncValue = authState;

      // This is the user's current location
      final currentLocation = state.uri.toString();

      // If auth state is still loading, don't do anything yet
      if (userAsyncValue.isLoading) return null;

      // If user is NOT logged in (or has an error)
      if (userAsyncValue.hasError || !userAsyncValue.hasValue || userAsyncValue.value == null) {
        // If they are NOT already on a login/signup page, send them to login
        if (currentLocation != '/login' && currentLocation != '/signup') {
          return '/login';
        }
        return null; // They are already where they need to be
      }

      // --- If we get here, the user IS logged in ---
      final user = userAsyncValue.value!;

      // Check if email is verified
      if (!user.emailVerified) {
        // If not verified, and NOT already on the verify screen, send them there
        if (currentLocation != '/verify-email') {
          return '/verify-email';
        }
        return null;
      }

      // --- If we get here, the user is logged in AND verified ---
      // If they are currently on any auth screen, send them to the home page
      if (currentLocation == '/login' ||
          currentLocation == '/signup' ||
          currentLocation == '/verify-email') {
        return '/browse';
      }

      // Otherwise, let them go where they want
      return null;
    },
    routes: [
      // --- Auth Routes ---
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

      // --- Main App Shell (Bottom Navigation) ---
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Browse Listings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/browse',
                builder: (context, state) => const BrowseListingsScreen(),
              ),
            ],
          ),
          // Branch 2: My Listings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my-listings',
                builder: (context, state) => const MyListingsScreen(),
              ),
            ],
          ),
          // Branch 3: Chats
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chats',
                builder: (context, state) => const ChatsOverviewScreen(),
              ),
            ],
          ),
          // Branch 4: Settings
          StatefulShellBranch(
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