import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_design_tokens.dart';
import '../../../../core/widgets/custom_gradient_appbar.dart';
import '../../../../core/widgets/premium_upgrade_dialog.dart';
import '../../../../routes/app_routes.dart';
import '../widgets/animated_tajwid_card.dart';

class LatihanTajwidMenuPage extends StatelessWidget {
  const LatihanTajwidMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final menus = [
      (
        title: 'Latihan Nun Mati & Tanwin',
        description: 'Soal interaktif dan latihan bacaan Nun Sukun & Tanwin.',
        route: AppRoutes.latihanNunTanwinMenu,
        icon: Icons.music_note_rounded,
        accent: AppColors.accent,
        isPro: false,
      ),
      (
        title: 'Latihan Mim Mati',
        description: 'Uji pemahaman hukum Mim Sukun dengan soal dan praktik.',
        route: AppRoutes.latihanMimMatiMenu,
        icon: Icons.mic_rounded,
        accent: AppColors.secondary,
        isPro: true,
      ),
      (
        title: 'Latihan Mad',
        description: 'Latihan panjang bacaan Mad Thabi’i, Jaiz, Wajib, dan lainnya.',
        route: AppRoutes.latihanMadMenu,
        icon: Icons.timeline_rounded,
        accent: Colors.purple,
        isPro: true,
      ),
      (
        title: 'Latihan Qalqalah',
        description: 'Latihan pantulan suara pada huruf qalqalah.',
        route: AppRoutes.latihanQalqalahMenu,
        icon: Icons.volume_up_rounded,
        accent: Colors.orange,
        isPro: true,
      ),
      (
        title: 'Latihan Ghunnah',
        description: 'Latihan dengung pada Nun dan Mim tasydid.',
        route: AppRoutes.latihanGhunnahMenu,
        icon: Icons.surround_sound_rounded,
        accent: Colors.pink,
        isPro: true,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: const CustomGradientAppBar(title: 'Latihan Tajwid'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        children: [
          _introCard(),
          const SizedBox(height: 32),
          Text(
            'Sub Menu Latihan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...menus.map(
            (item) => _tajwidItem(
              context,
              title: item.title,
              description: item.description,
              route: item.route,
              icon: item.icon,
              accent: item.accent,
              isPro: item.isPro,
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
      child: Text(
        'Pilih sub menu latihan tajwid sesuai kebutuhanmu untuk memperkuat pemahaman dan kelancaran baca.',
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          height: 1.45,
        ),
      ),
    );
  }

  Widget _tajwidItem(
    BuildContext context, {
    required String title,
    required String description,
    required String route,
    required IconData icon,
    required Color accent,
    required bool isPro,
  }) {
    return AnimatedTajwidCard(
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
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
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
                    description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.45,
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
