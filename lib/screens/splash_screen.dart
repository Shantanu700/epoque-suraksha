import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/auth/auth_notifier.dart';
import '../theme/theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.navyCard,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

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
      Navigator.pushReplacementNamed(
        context,
        authState.isAuthenticated ? "/home" : "/login",
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -80,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.gold.withOpacity(0.09), Colors.transparent],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.navyCard.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 48,
            right: 28,
            child: Opacity(
              opacity: 0.18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  4,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Container(
                      width: 20.0 + i * 12,
                      height: 1,
                      color: AppTheme.gold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 48,
            left: 28,
            child: Opacity(
              opacity: 0.18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  4,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Container(
                      width: 20.0 + i * 12,
                      height: 1,
                      color: AppTheme.gold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppTheme.navyCard,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: AppTheme.gold.withOpacity(0.35),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.gold.withOpacity(0.14),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Image.asset(
                      'assets/images/kiet_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'KIET',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF2EDE4),
                      letterSpacing: 8,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Container(
                    width: 40,
                    height: 1,
                    color: AppTheme.gold.withOpacity(0.6),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'SURAKSHA',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 10,
                      color: AppTheme.ashGrey,
                      letterSpacing: 4,
                    ),
                  ),

                  const SizedBox(height: 48),

                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      color: AppTheme.gold.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeIn,
              child: Text(
                'v1.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.ashGrey.withOpacity(0.35),
                  fontSize: 11,
                  fontFamily: 'Georgia',
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
