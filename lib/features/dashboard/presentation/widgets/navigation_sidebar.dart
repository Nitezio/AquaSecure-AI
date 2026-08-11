import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class NavigationSidebar extends StatelessWidget {
  const NavigationSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      decoration: const BoxDecoration(
        color: AppColors.backgroundElevated,
        border: Border(right: BorderSide(color: AppColors.panelBorder)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 22),
            const _BrandMark(),
            const SizedBox(height: 38),
            const _NavItem(
              icon: Icons.grid_view_rounded,
              label: 'Overview',
              active: true,
            ),
            const _NavItem(
              icon: Icons.monitor_heart_outlined,
              label: 'Telemetry',
            ),
            const _NavItem(icon: Icons.gpp_maybe_outlined, label: 'Incidents'),
            const _NavItem(icon: Icons.account_tree_outlined, label: 'Process'),
            const Spacer(),
            const _NavItem(icon: Icons.settings_outlined, label: 'Settings'),
            const SizedBox(height: 18),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.panelLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.panelBorder),
              ),
              alignment: Alignment.center,
              child: const Text(
                'SR',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primarySoft,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.cyan],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x5521E6C1), blurRadius: 18)],
      ),
      child: const Icon(Icons.water_drop_rounded, color: AppColors.background),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Container(
        width: 48,
        height: 48,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.11)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          border: active
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
              : null,
        ),
        child: Icon(
          icon,
          size: 21,
          color: active ? AppColors.primary : AppColors.textMuted,
        ),
      ),
    );
  }
}
