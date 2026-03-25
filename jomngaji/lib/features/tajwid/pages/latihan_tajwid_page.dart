import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/premium_upgrade_dialog.dart';
import '../../../../core/widgets/custom_gradient_appbar.dart';
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
        accent: const Color(0xFF22A06B),
        isPro: false,
      ),
      (
        title: 'Latihan Mim Mati',
        description: 'Uji pemahaman hukum Mim Sukun dengan soal dan praktik.',
        route: AppRoutes.latihanMimMatiMenu,
        icon: Icons.mic_rounded,
        accent: const Color(0xFF3B82F6),
        isPro: true,
      ),
      (
        title: 'Latihan Mad',
        description: 'Latihan panjang bacaan Mad Thabi’i, Jaiz, Wajib, dan lainnya.',
        route: AppRoutes.latihanMadMenu,
        icon: Icons.timeline_rounded,
        accent: const Color(0xFF8B5CF6),
        isPro: true,
      ),
      (
        title: 'Latihan Qalqalah',
        description: 'Latihan pantulan suara pada huruf qalqalah.',
        route: AppRoutes.latihanQalqalahMenu,
        icon: Icons.volume_up_rounded,
        accent: const Color(0xFFF97316),
        isPro: true,
      ),
      (
        title: 'Latihan Ghunnah',
        description: 'Latihan dengung pada Nun dan Mim tasydid.',
        route: AppRoutes.latihanGhunnahMenu,
        icon: Icons.surround_sound_rounded,
        accent: const Color(0xFFEC4899),
        isPro: true,
      ),
    ];

    return Scaffold(
      appBar: const CustomGradientAppBar(title: 'Latihan Tajwid'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F9FF), Color(0xFFEFF7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            _introCard(),
            const SizedBox(height: 18),
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
      ),
    );
  }

  Widget _introCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF155EEF), Color(0xFF22A06B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33155EEF),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Latihan Hukum Tajwid',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih materi latihan sesuai hukum tajwid untuk memperkuat pemahaman dan bacaan.',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.95),
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
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
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withOpacity(0.18)),
          boxShadow: const [
            BoxShadow(color: Color(0x12000000), blurRadius: 14, offset: Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
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
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 12.8,
                      color: const Color(0xFF475569),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            if (isPro)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('PRO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: accent),
          ],
        ),
      ),
    );
  }
}
