import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/services/auth/auth_notifier.dart';
import '../../core/routes/app_routes.dart';
import '../../theme/theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscureText = true;

  Future<void> _login() async {
    final notifier = ref.read(authNotifierProvider.notifier);
    await notifier.login(
      usernameController.text.trim(),
      passwordController.text.trim(),
    );
    final state = ref.read(authNotifierProvider);
    if (state.isAuthenticated && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.lora(
        color: AppTheme.ashGrey,
        fontSize: 13,
        letterSpacing: 0.5,
      ),
      floatingLabelStyle: GoogleFonts.lora(
        color: AppTheme.gold,
        fontSize: 12,
        letterSpacing: 0.8,
      ),
      prefixIcon: Icon(prefixIcon, color: AppTheme.ashGrey, size: 18),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppTheme.bgInput,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.puzzleBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.puzzleBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.gold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.errorRed, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.bgDeep,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.gold.withOpacity(0.07), Colors.transparent],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1E3A5F).withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    Container(
                      width: 72,
                      height: 72,
                      decoration: AppTheme.accentCardDecoration.copyWith(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Image.asset(
                        'assets/images/epoquelogo25_col.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),

                    const SizedBox(height: 6),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 1,
                          color: AppTheme.gold.withOpacity(0.5),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Sign in to continue',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(letterSpacing: 1.2),
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 1,
                          color: AppTheme.gold.withOpacity(0.5),
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    Container(
                      decoration: AppTheme.cardDecoration.copyWith(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'USERNAME',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: usernameController,
                            style: GoogleFonts.lora(
                              color: AppTheme.snowWhite,
                              fontSize: 15,
                            ),
                            cursorColor: AppTheme.gold,
                            decoration: _fieldDecoration(
                              label: 'Enter your username',
                              prefixIcon: Icons.person_outline_rounded,
                            ),
                          ),

                          const SizedBox(height: 22),

                          Text(
                            'PASSWORD',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: passwordController,
                            obscureText: _obscureText,
                            style: GoogleFonts.lora(
                              color: AppTheme.snowWhite,
                              fontSize: 15,
                            ),
                            cursorColor: AppTheme.gold,
                            decoration: _fieldDecoration(
                              label: 'Enter your password',
                              prefixIcon: Icons.lock_outline_rounded,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppTheme.ashGrey,
                                  size: 18,
                                ),
                                onPressed: () => setState(
                                  () => _obscureText = !_obscureText,
                                ),
                              ),
                            ),
                          ),

                          if (authState.error != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.errorRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.errorRed.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: AppTheme.errorRed,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authState.error!,
                                      style: GoogleFonts.dmSans(
                                        color: AppTheme.errorRed,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 28),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: authState.isLoading ? null : _login,
                              child: authState.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: AppTheme.bgDeep,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Text(
                                      'Sign In',
                                      style: GoogleFonts.lora(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                        color: AppTheme.bgDeep,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    Text(
                      '© Epoque Suraksha 2026. All rights reserved.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.ashGrey.withOpacity(0.5),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
