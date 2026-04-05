import 'package:epoque_suraksha/core/services/qr_service.dart';
import 'package:epoque_suraksha/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';

class _CornerBracketOverlay extends CustomPainter {
  final double cutSize;
  final double cornerLen;
  final double cornerRadius;
  final Color bracketColor;
  final bool scanned;

  const _CornerBracketOverlay({
    required this.cutSize,
    required this.bracketColor,
    // ignore: unused_element_parameter
    this.cornerLen = 28,
    // ignore: unused_element_parameter
    this.cornerRadius = 12,
    // ignore: unused_element_parameter
    this.scanned = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final cutRect = Rect.fromCenter(
      center: center,
      width: cutSize,
      height: cutSize,
    );

    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.72)
      ..style = PaintingStyle.fill;

    final overlayPath = Path()..addRect(Offset.zero & size);
    final holePath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(cutRect, Radius.circular(cornerRadius)),
      );
    canvas.drawPath(
      Path.combine(PathOperation.difference, overlayPath, holePath),
      overlayPaint,
    );

    final bPaint = Paint()
      ..color = bracketColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final corners = [
      [
        Offset(cutRect.left, cutRect.top + cornerLen),
        Offset(cutRect.left, cutRect.top),
        Offset(cutRect.left + cornerLen, cutRect.top),
      ],
      [
        Offset(cutRect.right - cornerLen, cutRect.top),
        Offset(cutRect.right, cutRect.top),
        Offset(cutRect.right, cutRect.top + cornerLen),
      ],
      [
        Offset(cutRect.right, cutRect.bottom - cornerLen),
        Offset(cutRect.right, cutRect.bottom),
        Offset(cutRect.right - cornerLen, cutRect.bottom),
      ],
      [
        Offset(cutRect.left + cornerLen, cutRect.bottom),
        Offset(cutRect.left, cutRect.bottom),
        Offset(cutRect.left, cutRect.bottom - cornerLen),
      ],
    ];

    for (final pts in corners) {
      final path = Path()
        ..moveTo(pts[0].dx, pts[0].dy)
        ..lineTo(pts[1].dx, pts[1].dy)
        ..lineTo(pts[2].dx, pts[2].dy);
      canvas.drawPath(path, bPaint);
    }
  }

  @override
  bool shouldRepaint(_CornerBracketOverlay old) =>
      old.bracketColor != bracketColor || old.scanned != scanned;
}

class QrScannerPage extends ConsumerStatefulWidget {
  final bool isActive;
  const QrScannerPage({super.key, required this.isActive});

  @override
  ConsumerState<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends ConsumerState<QrScannerPage> {
  bool _isFlashOn = false;
  bool _isScanning = true;

  final MobileScannerController _controller = MobileScannerController();

  void _handleBarcode(BarcodeCapture capture) async {
    if (!mounted || !_isScanning) return;
    final code = capture.barcodes.first;
    if (code.rawValue == null) return;

    setState(() => _isScanning = false);

    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 80);
    }

    try {
      final qrService = ref.read(qrServiceProvider);
      final response = await qrService.verifyQr(code.rawValue!);
      if (!mounted) return;
      _showProfileSheet(response);
    } catch (e) {
      if (!mounted) return;
      _showErrorSheet(e.toString());
    }
  }

  void _toggleFlash() async {
    await _controller.toggleTorch();
    setState(() => _isFlashOn = !_isFlashOn);
  }

  void _scanAgain() => setState(() => _isScanning = true);

  void _showErrorSheet(String message) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _StyledSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.errorRed.withOpacity(0.12),
                border: Border.all(color: AppTheme.errorRed.withOpacity(0.4)),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: AppTheme.errorRed,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'SCAN FAILED',
              style: GoogleFonts.lora(
                fontSize: 11,
                letterSpacing: 3,
                color: AppTheme.errorRed,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: AppTheme.ashGrey,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _GoldButton(
              label: 'Try Again',
              onTap: () {
                Navigator.pop(context);
                _scanAgain();
              },
            ),
          ],
        ),
      ),
    );
    _scanAgain();
  }

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

  bool isSheetOpen = false;

  void _showProfileSheet(Map<String, dynamic> data) async {
    final imagePath = data["profile_image_url"];
    final imageUrl = imagePath != null ? "$imagePath" : "";
    final isAllowed = data["allowed"] == "Allowed";

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _StyledSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.gold.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.gold.withOpacity(0.12),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: AppTheme.gold,
                          ),
                        ),
                  errorBuilder: (_, __, ___) => Container(
                    color: AppTheme.bgInput,
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: 36,
                      color: AppTheme.ashGrey,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            Text(
              data["name"] ?? "",
              style: GoogleFonts.lora(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.snowWhite,
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              data["username"] ?? "",
              style: GoogleFonts.dmSans(
                color: AppTheme.ashGrey,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              data["member_branch_label"] ?? "",
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: AppTheme.ashGrey,
                fontSize: 12,
                letterSpacing: 0.4,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (data["type"] != null)
                  _InfoChip(
                    icon: _iconFor(data["type"]),
                    label: data["type"],
                    variant: _ChipVariant.gold,
                  ),
                if (data["type"] != null && data["member_year"] != null)
                  const SizedBox(width: 8),
                if (data["member_year"] != null)
                  _InfoChip(
                    icon: Icons.calendar_today_outlined,
                    label: 'Year ${data["member_year"]}',
                    variant: _ChipVariant.warning,
                  ),
              ],
            ),

            const SizedBox(height: 12),

            _InfoRow(
              items: [
                if (data["member_college_label"] != null)
                  _InfoRowItem(
                    icon: Icons.location_on_outlined,
                    label: data["member_college_label"],
                  ),
                if (data["member_course_label"] != null)
                  _InfoRowItem(
                    icon: Icons.school_outlined,
                    label: data["member_course_label"],
                  ),
                if (data["gender_label"] != null)
                  _InfoRowItem(
                    icon: Icons.person_outline_rounded,
                    label: data["gender_label"],
                  ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isAllowed
                    ? AppTheme.successGreen.withOpacity(0.12)
                    : AppTheme.errorRed.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isAllowed
                      ? AppTheme.successGreen.withOpacity(0.4)
                      : AppTheme.errorRed.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAllowed
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    size: 22,
                    color: isAllowed
                        ? AppTheme.successGreen
                        : AppTheme.errorRed,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    data["allowed"] ?? "Not Allowed",
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isAllowed
                          ? AppTheme.successGreen
                          : AppTheme.errorRed,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(height: 1, color: AppTheme.puzzleBorder),
            const SizedBox(height: 20),

            _StatTile(label: 'Count', value: data["count"].toString()),

            const SizedBox(height: 24),

            _GoldButton(
              label: 'Done',
              onTap: () {
                Navigator.pop(context);
                _scanAgain();
              },
            ),
          ],
        ),
      ),
    );
    _scanAgain();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return Container(
        color: AppTheme.bgDeep,
        child: Center(
          child: Text(
            'Scanner paused',
            style: GoogleFonts.lora(
              color: AppTheme.ashGrey,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'SCAN QR CODE',
          style: GoogleFonts.lora(
            fontSize: 13,
            letterSpacing: 3,
            color: AppTheme.snowWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _toggleFlash,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.navyCard.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _isFlashOn
                        ? AppTheme.gold.withOpacity(0.5)
                        : AppTheme.puzzleBorder,
                    width: 1,
                  ),
                ),
                child: Icon(
                  _isFlashOn
                      ? Icons.flashlight_on_rounded
                      : Icons.flashlight_off_rounded,
                  size: 18,
                  color: _isFlashOn ? AppTheme.gold : AppTheme.ashGrey,
                ),
              ),
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _handleBarcode),

          CustomPaint(
            size: Size.infinite,
            painter: _CornerBracketOverlay(
              cutSize: 260,
              bracketColor: _isScanning ? AppTheme.gold : AppTheme.successGreen,
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppTheme.bgDeep.withOpacity(0.95),
                    Colors.transparent,
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppTheme.gold.withOpacity(0.2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(
                          Icons.qr_code_rounded,
                          size: 16,
                          color: AppTheme.gold.withOpacity(0.5),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AppTheme.gold.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isScanning
                        ? 'Align the QR code within the frame'
                        : 'QR code detected — processing…',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lora(
                      fontSize: 13,
                      color: _isScanning ? AppTheme.ashGrey : AppTheme.gold,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StyledSheet extends StatelessWidget {
  final Widget child;
  const _StyledSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.navyCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppTheme.puzzleBorder, width: 1),
          left: BorderSide(color: AppTheme.puzzleBorder, width: 1),
          right: BorderSide(color: AppTheme.puzzleBorder, width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 3,
            decoration: BoxDecoration(
              color: AppTheme.puzzleBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

enum _ChipVariant { gold, success, warning, error, neutral }

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final _ChipVariant variant;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.variant = _ChipVariant.neutral,
  });

  Color _accentFor(_ChipVariant v) {
    switch (v) {
      case _ChipVariant.gold:
        return AppTheme.gold;
      case _ChipVariant.success:
        return AppTheme.successGreen;
      case _ChipVariant.warning:
        return AppTheme.warningYellow;
      case _ChipVariant.error:
        return AppTheme.errorRed;
      case _ChipVariant.neutral:
        return AppTheme.ashGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(variant);
    return Container(
      padding: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: accent.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.15),
              border: Border.all(color: accent.withOpacity(0.3), width: 1),
            ),
            child: Icon(icon, size: 15, color: accent),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppTheme.snowWhite,
              letterSpacing: 0.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRowItem {
  final IconData icon;
  final String label;
  const _InfoRowItem({required this.icon, required this.label});
}

class _InfoRow extends StatelessWidget {
  final List<_InfoRowItem> items;
  const _InfoRow({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20,
      runSpacing: 10,
      children: items
          .map(
            (item) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  size: 16,
                  color: AppTheme.gold.withOpacity(0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  item.label,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppTheme.snowWhite.withOpacity(0.75),
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GoldButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(
          label,
          style: GoogleFonts.lora(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppTheme.bgDeep,
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.snowWhite,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.dmSans(
            color: AppTheme.ashGrey,
            fontSize: 9,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
