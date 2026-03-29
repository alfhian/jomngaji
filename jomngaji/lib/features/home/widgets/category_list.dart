import 'package:flutter/material.dart';
import 'package:tabler_icons/tabler_icons.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/localization/app_localization.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../core/widgets/premium_upgrade_dialog.dart';
import '../../../routes/app_routes.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categories = [
      (l10n.text('category.iqra'), TablerIcons.book_2, AppRoutes.iqraDasar, AppColors.accent),
      (l10n.text('category.tajwid'), TablerIcons.microphone, AppRoutes.tajwidDasar, AppColors.secondary),
      (l10n.text('category.tilawah'), TablerIcons.wave_sine, AppRoutes.tilawahMenu, Colors.orange),
      (l10n.text('category.tahfidz'), TablerIcons.moon_stars, AppRoutes.tahfidzMenu, Colors.purple),
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, i) {
        final (title, icon, route, color) = categories[i];
        return _categoryCard(
          context,
          title: title,
          icon: icon,
          route: route,
          color: color,
        );
      },
    );
  }

  Widget _categoryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    String? route,
  }) {
    final isPremium = route == AppRoutes.tilawahMenu || route == AppRoutes.tahfidzMenu;

    return GestureDetector(
      onTap: route == null
          ? null
          : () async {
              if (isPremium) {
                await runWithPremiumGate(
                  context,
                  featureName: title,
                  onAllowed: () => Navigator.pushNamed(context, route),
                );
                return;
              }
              Navigator.pushNamed(context, route);
            },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.soft,
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                size: 28,
                color: color,
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  isPremium ? 'Premium Content' : 'Mulai Belajar',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (isPremium) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
