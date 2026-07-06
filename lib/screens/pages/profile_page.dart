import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/auth/auth_notifier.dart';
import '../../core/services/gatepass_count_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../theme/theme.dart';

final _gatePassCountProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final service = ref.watch(gatePasscountServiceProvider);
      final res = await service.getGatePasscount('');
      final list = res['msg'] as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    });

class ProfilePage extends ConsumerStatefulWidget {
  final bool isActive;
  const ProfilePage({super.key, required this.isActive});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _hasFetched = false;

  @override
  void didUpdateWidget(ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_hasFetched) {
      _hasFetched = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.invalidate(_gatePassCountProvider);
      });
    }
    if (!widget.isActive) {
      _hasFetched = false;
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(_gatePassCountProvider);
    // ignore: body_might_complete_normally_catch_error
    await ref.read(_gatePassCountProvider.future).catchError((_) {});
  }

  Future<void> _logout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final countAsync = ref.watch(_gatePassCountProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,

      appBar: AppBar(
        backgroundColor: AppTheme.bgDeep,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'REPORT',
          style: GoogleFonts.lora(
            fontSize: 13,
            letterSpacing: 3,
            color: AppTheme.snowWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _logout,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.navyCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.errorRed.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 17,
                  color: AppTheme.errorRed,
                ),
              ),
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.gold.withOpacity(0.06), Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            top: false,
            child: countAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.gold,
                  strokeWidth: 2,
                ),
              ),
              error: (e, _) => RefreshIndicator(
                onRefresh: _refresh,
                color: AppTheme.gold,
                backgroundColor: AppTheme.navyCard,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppTheme.errorRed,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load report',
                            style: GoogleFonts.lora(
                              color: AppTheme.ashGrey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Pull down to retry',
                            style: GoogleFonts.dmSans(
                              color: AppTheme.ashGrey.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              data: (counts) => RefreshIndicator(
                onRefresh: _refresh,
                color: AppTheme.gold,
                backgroundColor: AppTheme.navyCard,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 3,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppTheme.gold,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'GATE PASS COUNTS',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            letterSpacing: 2,
                            color: AppTheme.ashGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    ...counts.map(
                      (item) => _CountCard(
                        type: item['type'] ?? '—',
                        count: item['count'] ?? 0,
                      ),
                    ),

                    if (counts.length > 1) ...[
                      const SizedBox(height: 12),
                      Container(height: 1, color: AppTheme.puzzleBorder),
                      const SizedBox(height: 16),
                      _TotalRow(
                        total: counts.fold<int>(
                          0,
                          (sum, item) => sum + (item['count'] as int? ?? 0),
                        ),
                      ),
                    ],
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

class _CountCard extends StatelessWidget {
  final String type;
  final int count;
  const _CountCard({required this.type, required this.count});

  IconData _iconFor(String type) {
    switch (type.toLowerCase()) {
      case 'student':
        return Icons.school_outlined;
      case 'employee':
      case 'faculty':
      case 'staff':
        return Icons.badge_outlined;
      case 'guest':
        return Icons.person_outline_rounded;
      case 'participation':
        return Icons.how_to_reg_outlined;
      default:
        return Icons.group_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.navyCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.puzzleBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.gold.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Icon(_iconFor(type), color: AppTheme.gold, size: 20),
          ),

          const SizedBox(width: 16),

          // Type label
          Expanded(
            child: Text(
              type,
              style: GoogleFonts.lora(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.snowWhite,
                letterSpacing: 0.3,
              ),
            ),
          ),

          // Count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.bgInput,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.gold.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              count.toString(),
              style: GoogleFonts.lora(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.gold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final int total;
  const _TotalRow({required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'TOTAL',
          style: GoogleFonts.dmSans(
            fontSize: 10,
            letterSpacing: 2,
            color: AppTheme.ashGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          total.toString(),
          style: GoogleFonts.lora(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.snowWhite,
          ),
        ),
      ],
    );
  }
}
