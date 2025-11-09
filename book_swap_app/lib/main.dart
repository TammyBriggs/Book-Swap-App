import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_swap_app/core/navigation/app_router.dart'; // Import router
import 'firebase_options.dart';
import 'package:book_swap_app/core/constants/colors.dart'; // Import colors

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the router provider
    final router = ref.watch(routerProvider);
    // Use MaterialApp.router
    return MaterialApp.router(
      title: 'BookSwap',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kBackgroundColor,
        colorScheme: const ColorScheme.dark(
          primary: kSecondaryColor,
          secondary: kSecondaryColor,
          background: kBackgroundColor,
          surface: kPrimaryColor,
        ),
        fontFamily: 'Poppins',
      ),
      // Set the router configuration
      routerConfig: router,
    );
  }
}