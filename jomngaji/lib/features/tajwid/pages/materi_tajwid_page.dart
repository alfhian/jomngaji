import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../core/widgets/custom_gradient_appbar.dart';
import '../../../routes/app_routes.dart';

class MateriTajwidPage extends StatelessWidget {
  const MateriTajwidPage({super.key});

  @override
  Widget build(BuildContext context) {
    final materials = [
      (
        title: 'Hukum Nun Mati & Tanwin',
        description: 'Idzhar, Idgham, Iqlab, dan Ikhfa dengan contoh praktis.',
        route: AppRoutes.materiNunTanwin,
        icon: Icons.record_voice_over_rounded,
        accent: AppColors.accent,
      ),
      (
        title: 'Hukum Mim Mati',
        description: 'Pelajari Idzhar Syafawi, Ikhfa Syafawi, dan Idgham Mimi.',
        route: AppRoutes.materiMimMati,
        icon: Icons.chat_bubble_outline_rounded,
        accent: AppColors.secondary,
      ),
      (
        title: 'Mad (Panjang Bacaan)',
        description: 'Kenali panjang bacaan dari Mad Thabi’i hingga Mad Lin.',
        route: AppRoutes.materiMad,
        icon: Icons.swap_horiz_rounded,
        accent: Colors.purple,
      ),
      (
        title: 'Qalqalah',
        description: 'Aturan pantulan suara pada huruf qalqalah.',
        route: AppRoutes.materiQalqalah,
        icon: Icons.multitrack_audio_rounded,
        accent: Colors.orange,
      ),
      (
        title: 'Ghunnah (Dengung)',
        description: 'Latih dengung pada nun/mim tasydid secara benar.',
        route: AppRoutes.materiGhunnah,
        icon: Icons.graphic_eq_rounded,
        accent: Colors.pink,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: const CustomGradientAppBar(title: 'Teori Tajwid Dasar'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        children: [
          _introCard(),
          const SizedBox(height: 32),
          Text(
            'Sub Menu Materi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...materials.map(
            (item) => _tajwidItem(
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
      child: Text(
        'Mulai dari teori tajwid untuk memahami hukum bacaan sebelum lanjut ke latihan.',
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => Navigator.pushNamed(context, route),
        child: Container(
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
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
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
      ),
    );
  }
}
