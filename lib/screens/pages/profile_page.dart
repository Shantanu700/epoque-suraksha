import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/auth/auth_notifier.dart';
import '../../core/services/induction_report_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../theme/theme.dart';

final _inductionReportProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final service = ref.watch(inductionReportServiceProvider);
      return service.getInductionReport();
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
        if (mounted) ref.invalidate(_inductionReportProvider);
      });
    }
    if (!widget.isActive) {
      _hasFetched = false;
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(_inductionReportProvider);
    // ignore: body_might_complete_normally_catch_error
    await ref.read(_inductionReportProvider.future).catchError((_) {});
  }

  Future<void> _logout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  int _asInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(_inductionReportProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,

      appBar: AppBar(
        backgroundColor: AppTheme.bgDeep,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
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
            child: reportAsync.when(
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
              data: (branches) {
                final totalStudents = branches.fold<int>(
                  0,
                  (s, b) => s + _asInt(b['total_students']),
                );
                final totalPresent = branches.fold<int>(
                  0,
                  (s, b) => s + _asInt(b['total_present']),
                );
                final totalAbsent = branches.fold<int>(
                  0,
                  (s, b) => s + _asInt(b['total_absent']),
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Sticky summary + section header ──────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SummaryCard(
                            students: totalStudents,
                            present: totalPresent,
                            absent: totalAbsent,
                          ),

                          const SizedBox(height: 24),

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
                                'BRANCH WISE',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  letterSpacing: 2,
                                  color: AppTheme.ashGrey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${branches.length} branches',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                  color: AppTheme.ashGrey.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    // ── Scrollable branch list ───────────────────────────────
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refresh,
                        color: AppTheme.gold,
                        backgroundColor: AppTheme.navyCard,
                        child: branches.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 40),
                                    child: Center(
                                      child: Text(
                                        'No data available',
                                        style: GoogleFonts.dmSans(
                                          color: AppTheme.ashGrey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                                itemCount: branches.length,
                                itemBuilder: (context, i) {
                                  final b = branches[i];
                                  return _BranchCard(
                                    name: (b['branch_name'] ?? '—').toString(),
                                    students: _asInt(b['total_students']),
                                    present: _asInt(b['total_present']),
                                    absent: _asInt(b['total_absent']),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Aggregated overview across all branches.
class _SummaryCard extends StatelessWidget {
  final int students;
  final int present;
  final int absent;
  const _SummaryCard({
    required this.students,
    required this.present,
    required this.absent,
  });

  @override
  Widget build(BuildContext context) {
    final pct = students == 0 ? 0.0 : present / students;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.navyCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.gold.withOpacity(0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OVERALL ATTENDANCE',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              letterSpacing: 2,
              color: AppTheme.gold,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$present',
                style: GoogleFonts.lora(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.snowWhite,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '/ $students present',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppTheme.ashGrey,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${(pct * 100).toStringAsFixed(1)}%',
                  style: GoogleFonts.lora(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppTheme.bgInput,
              valueColor: const AlwaysStoppedAnimation(AppTheme.gold),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'PRESENT',
                  value: present,
                  color: AppTheme.successGreen,
                ),
              ),
              _statDivider(),
              Expanded(
                child: _MiniStat(
                  label: 'ABSENT',
                  value: absent,
                  color: AppTheme.errorRed,
                ),
              ),
              _statDivider(),
              Expanded(
                child: _MiniStat(
                  label: 'STUDENTS',
                  value: students,
                  color: AppTheme.snowWhite,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statDivider() =>
      Container(width: 1, height: 34, color: AppTheme.puzzleBorder);
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 9,
            letterSpacing: 1.5,
            color: AppTheme.ashGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Per-branch attendance card.
class _BranchCard extends StatelessWidget {
  final String name;
  final int students;
  final int present;
  final int absent;
  const _BranchCard({
    required this.name,
    required this.students,
    required this.present,
    required this.absent,
  });

  @override
  Widget build(BuildContext context) {
    final pct = students == 0 ? 0.0 : present / students;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.snowWhite,
                    height: 1.3,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.bgInput,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.gold.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${(pct * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.lora(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.gold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: AppTheme.bgInput,
              valueColor: const AlwaysStoppedAnimation(AppTheme.successGreen),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _tag(
                label: 'Present',
                value: present,
                color: AppTheme.successGreen,
              ),
              const SizedBox(width: 8),
              _tag(label: 'Absent', value: absent, color: AppTheme.errorRed),
              const Spacer(),
              Text(
                'of $students',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppTheme.ashGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag({
    required String label,
    required int value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: AppTheme.ashGrey,
          ),
        ),
        Text(
          '$value',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.snowWhite,
          ),
        ),
      ],
    );
  }
}
