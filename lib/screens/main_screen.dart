import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/theme.dart';
import 'pages/qr_scanner_page.dart';
import 'pages/profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      QrScannerPage(isActive: _currentIndex == 0),
      ProfilePage(isActive: _currentIndex == 1),
    ];

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
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(
        icon: Icons.qr_code_scanner_outlined,
        activeIcon: Icons.qr_code_scanner_rounded,
        label: 'Scan QR',
      ),
      _NavItem(
        icon: Icons.list_alt_outlined,
        activeIcon: Icons.list_alt_rounded,
        label: 'Reports',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.navyCard,
        border: const Border(
          top: BorderSide(color: AppTheme.puzzleBorder, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isSelected = i == currentIndex;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Active pill background
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 56 : 40,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.gold.withOpacity(0.13)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? Border.all(
                                  color: AppTheme.gold.withOpacity(0.25),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Center(
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            size: 20,
                            color: isSelected
                                ? AppTheme.gold
                                : AppTheme.ashGrey,
                          ),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Label
                      Text(
                        item.label,
                        style: GoogleFonts.lora(
                          fontSize: 10,
                          letterSpacing: 0.5,
                          color: isSelected ? AppTheme.gold : AppTheme.ashGrey,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
