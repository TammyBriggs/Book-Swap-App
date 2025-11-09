import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_swap_app/features/auth/presentation/auth_wrapper.dart'; // Import this
import 'firebase_options.dart';
import 'package:book_swap_app/core/constants/colors.dart'; // Import colors

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        fontFamily: 'Poppins', // You might need to add this font
      ),
      // Set AuthWrapper as the home
      home: const AuthWrapper(),
    );
  }
}