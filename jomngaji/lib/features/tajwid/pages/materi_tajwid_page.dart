import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        accent: const Color(0xFF22A06B),
      ),
      (
        title: 'Hukum Mim Mati',
        description: 'Pelajari Idzhar Syafawi, Ikhfa Syafawi, dan Idgham Mimi.',
        route: AppRoutes.materiMimMati,
        icon: Icons.chat_bubble_outline_rounded,
        accent: const Color(0xFF3B82F6),
      ),
      (
        title: 'Mad (Panjang Bacaan)',
        description: 'Kenali panjang bacaan dari Mad Thabi’i hingga Mad Lin.',
        route: AppRoutes.materiMad,
        icon: Icons.swap_horiz_rounded,
        accent: const Color(0xFF8B5CF6),
      ),
      (
        title: 'Qalqalah',
        description: 'Aturan pantulan suara pada huruf qalqalah.',
        route: AppRoutes.materiQalqalah,
        icon: Icons.multitrack_audio_rounded,
        accent: const Color(0xFFF97316),
      ),
      (
        title: 'Ghunnah (Dengung)',
        description: 'Latih dengung pada nun/mim tasydid secara benar.',
        route: AppRoutes.materiGhunnah,
        icon: Icons.graphic_eq_rounded,
        accent: const Color(0xFFEC4899),
      ),
    ];

    return Scaffold(
      appBar: const CustomGradientAppBar(title: 'Teori Tajwid Dasar'),
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
              const Icon(Icons.auto_stories_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Mulai dari Dasar',
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
            'Tajwid membantu bacaan Al-Qur\'an lebih tepat, indah, dan menjaga makna ayat.',
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.pushNamed(context, route),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withOpacity(0.18)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
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
      ),
    );
  }
}
