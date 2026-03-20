import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/routes/app_routes.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          await ref.read(authNotifierProvider.notifier).logout();

          if (!context.mounted) return;

          Navigator.pushReplacementNamed(context, AppRoutes.login);
        },
        child: const Text("Logout"),
      ),
    );
  }
}
