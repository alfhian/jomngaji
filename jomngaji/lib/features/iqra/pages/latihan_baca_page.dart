import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../core/widgets/custom_gradient_appbar.dart';
import '../../../routes/app_routes.dart';
import '../widgets/animated_iqra_card.dart';

class LatihanBacaPage extends StatelessWidget {
  const LatihanBacaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final menus = [
      (
        title: 'Latihan Harakat',
        description: 'Latihan Fathah, Kasrah, Dhammah dengan soal interaktif.',
        route: AppRoutes.latihanHarakat,
        icon: Icons.menu_book_rounded,
        accent: AppColors.accent,
      ),
      (
        title: 'Latihan Suku Kata',
        description: 'Latihan gabungan huruf dan harakat secara bertahap.',
        route: AppRoutes.latihanSukuKataMenu,
        icon: Icons.auto_stories_rounded,
        accent: AppColors.secondary,
      ),
      (
        title: 'Dengarkan & Tebak',
        description: 'Asah pendengaran dengan menebak huruf dari audio.',
        route: AppRoutes.latihanDengar,
        icon: Icons.volume_up_rounded,
        accent: Colors.orange,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: const CustomGradientAppBar(title: 'Latihan Baca'),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _introCard(),
          const SizedBox(height: 32),
          Text(
            "Pilih Metode Latihan",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...menus.map(
            (item) => _menuItem(
              context,
              title: item.title,
              description: item.description,
              route: item.route,
              icon: item.icon,
              accent: item.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _introCard() {
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
                  'Asah Kemampuan\nBacaanmu ✨',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Perkuat dasar harakat, suku kata, sampai latihan mendengar interaktif.',
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
            child: const Icon(Icons.local_library_rounded, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required String title,
    required String description,
    required String route,
    required IconData icon,
    required Color accent,
  }) {
    return AnimatedIqraCard(
      onTap: () => Navigator.pushNamed(context, route),
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
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, size: 26, color: accent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
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
