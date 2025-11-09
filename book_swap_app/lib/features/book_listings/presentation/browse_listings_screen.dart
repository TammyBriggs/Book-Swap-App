import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:book_swap_app/core/constants/colors.dart';

class BrowseListingsScreen extends StatelessWidget {
  const BrowseListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Listings'),
        backgroundColor: kBackgroundColor,
        elevation: 0,
      ),
      body: const Center(child: Text('Browse Listings Screen')),
      floatingActionButton: FloatingActionButton.extended(
        // Updated path to match nested route structure
        onPressed: () => context.go('/browse/post-book'),
        backgroundColor: kSecondaryColor,
        foregroundColor: kPrimaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Post Book'),
      ),
    );
  }
}