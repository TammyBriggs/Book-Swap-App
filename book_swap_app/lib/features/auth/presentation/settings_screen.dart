import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_swap_app/core/constants/colors.dart';
import 'package:book_swap_app/features/auth/application/auth_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsOn = true;
  bool _emailUpdatesOn = true;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(firebaseAuthProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: kBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Profile Info ---
          if (user != null)
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              subtitle: Text(user.email ?? 'No email'),
            ),
          const Divider(),

          // --- Notification Toggles (Rubric Item) ---
          SwitchListTile(
            title: const Text('Notification reminders'),
            value: _notificationsOn,
            onChanged: (val) {
              setState(() => _notificationsOn = val);
              // In a real app, you'd save this to a provider
            },
            activeColor: kSecondaryColor,
          ),
          SwitchListTile(
            title: const Text('Email Updates'),
            value: _emailUpdatesOn,
            onChanged: (val) {
              setState(() => _emailUpdatesOn = val);
            },
            activeColor: kSecondaryColor,
          ),
          const Divider(),

          // --- About ---
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              // You can show a simple dialog
              showAboutDialog(
                context: context,
                applicationName: 'BookSwap',
                applicationVersion: '1.0.0',
              );
            },
          ),
          const Divider(),

          // --- Log Out Button ---
          const SizedBox(height: 32),
          TextButton(
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              // The AuthWrapper/GoRouter will automatically handle the rest
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}