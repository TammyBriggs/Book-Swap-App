import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_swap_app/features/auth/application/auth_providers.dart';
import 'package:book_swap_app/features/auth/domain/auth_exception.dart';
import 'package:book_swap_app/features/auth/presentation/signup_screen.dart'; // To navigate
import 'package:book_swap_app/core/constants/colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ref.read(authRepositoryProvider).signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Auth state will change, and AuthWrapper will navigate
      } on AuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message)),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Your Logo
                    const Icon(Icons.book, size: 80, color: kSecondaryColor),
                    const SizedBox(height: 16),
                    const Text(
                      'BookSwap',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Swap Your Books With Other Students',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 48),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) =>
                      val!.isEmpty ? 'Please enter an email' : null,
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (val) =>
                      val!.length < 6 ? 'Password too short' : null,
                    ),
                    const SizedBox(height: 32),

                    // Sign In Button
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kSecondaryColor,
                          foregroundColor: kPrimaryColor,
                          padding:
                          const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Sign In'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Go to Sign Up
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => const SignUpScreen(),
                        ));
                      },
                      child: const Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(color: kSecondaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}