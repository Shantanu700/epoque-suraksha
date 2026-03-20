import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth/auth_notifier.dart';
import '../theme/theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    /// ✅ Set system UI style ONCE
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppTheme.primaryGreen,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.cardBackground,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    /// ✅ Delay provider call safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      final notifier = ref.read(authNotifierProvider.notifier);

      await notifier.checkAuth();

      await Future.delayed(const Duration(milliseconds: 500));

      final authState = ref.read(authNotifierProvider);

      if (!mounted) return;

      if (authState.isAuthenticated) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        Navigator.pushReplacementNamed(context, "/login");
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.cardBackground, // 👈 match theme
      body: Center(child: CircularProgressIndicator(color: AppTheme.darkText)),
    );
  }
}
