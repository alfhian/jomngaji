import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        accent: const Color(0xFF7C3AED),
      ),
      (
        title: 'Latihan Suku Kata',
        description: 'Latihan gabungan huruf dan harakat secara bertahap.',
        route: AppRoutes.latihanSukuKataMenu,
        icon: Icons.auto_stories_rounded,
        accent: const Color(0xFFEC4899),
      ),
      (
        title: 'Dengarkan & Tebak',
        description: 'Asah pendengaran dengan menebak huruf dari audio.',
        route: AppRoutes.latihanDengar,
        icon: Icons.volume_up_rounded,
        accent: const Color(0xFF22A06B),
      ),
    ];

    return Scaffold(
      appBar: const CustomGradientAppBar(title: 'Latihan Baca'),
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
              const Icon(Icons.local_library_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Latihan Dasar',
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
            'Perkuat kemampuan baca Iqra dari harakat, suku kata, sampai latihan mendengar.',
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
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: accent),
          ],
        ),
      ),
    );
  }
}
