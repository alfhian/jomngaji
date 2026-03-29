import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../core/widgets/premium_upgrade_dialog.dart';
import '../../../core/widgets/custom_gradient_appbar.dart';
import '../../../routes/app_routes.dart';

class IqraDasarPage extends StatelessWidget {
  const IqraDasarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: const CustomGradientAppBar(title: "Iqra' Dasar"),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _heroCard(),
          const SizedBox(height: 32),
          Text(
            "Kurikulum Belajar",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _iqraItem(
            context,
            color: AppColors.accent,
            title: 'Huruf Hijaiyah',
            subtitle: 'Kenali bentuk dan nama huruf hijaiyah dasar.',
            icon: Icons.grid_view_rounded,
            route: AppRoutes.materiHijaiyah,
          ),
          _iqraItem(
            context,
            color: AppColors.secondary,
            title: 'Latihan Baca',
            subtitle: 'Belajar harakat dan cara menyambung huruf.',
            icon: Icons.auto_stories_rounded,
            route: AppRoutes.latihanBaca,
          ),
          _iqraItem(
            context,
            color: Colors.orange,
            title: 'Makhraj & Pengucapan',
            subtitle: 'Latihan melafalkan huruf dengan tepat.',
            icon: Icons.record_voice_over_rounded,
            route: AppRoutes.makhraj,
          ),
          _iqraItem(
            context,
            color: Colors.purple,
            title: 'Evaluasi Iqra',
            subtitle: 'Uji pemahamanmu sebelum lanjut ke tajwid.',
            icon: Icons.assignment_turned_in_rounded,
            route: AppRoutes.examIqra,
            isPro: true,
          ),
        ],
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.accent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.medium,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mulai Perjalanan\nMengajimu ✨',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kurikulum terstruktur untuk pemula dari nol.',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_rounded, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _iqraItem(
    BuildContext context, {
    required Color color,
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
    bool isPro = false,
  }) {
    return GestureDetector(
      onTap: () async {
        if (isPro) {
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
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.soft,
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, size: 26, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (isPro) ...[
                        const SizedBox(width: 8),
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
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textPlaceholder),
          ],
        ),
      ),
    );
  }
}
