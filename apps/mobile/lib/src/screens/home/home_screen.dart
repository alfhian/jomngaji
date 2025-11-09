import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/surah.dart';
import '../belajar/detail_surah_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final _statItems = [
    _StatItem('12K+', 'Santri Aktif'),
    _StatItem('350+', 'Mentor Tersertifikasi'),
    _StatItem('4.9/5', 'Kepuasan Kelas'),
  ];

  static final _programs = [
    _ProgramCardData(
      title: 'Tahsin Pemula',
      description: 'Belajar makhraj dan tajwid dasar dengan metode yang mudah dipahami.',
      accentColor: const Color(0xFF34D399),
      icon: Icons.menu_book_rounded,
    ),
    _ProgramCardData(
      title: 'Tahfidz & Murajaah',
      description: 'Target hafalan mingguan dipadukan dengan review terstruktur.',
      accentColor: const Color(0xFF60A5FA),
      icon: Icons.auto_awesome_rounded,
    ),
    _ProgramCardData(
      title: 'Kelas Anak & Keluarga',
      description: 'Belajar interaktif untuk anak-anak dan sesi privat keluarga.',
      accentColor: const Color(0xFFF472B6),
      icon: Icons.family_restroom_rounded,
    ),
  ];

  static final _featureHighlights = [
    _FeatureHighlight(
      title: 'Mentor Bersertifikat',
      description: 'Pengajar ahli dengan kurikulum modern yang disesuaikan kebutuhan.',
      icon: Icons.verified_rounded,
      color: const Color(0xFF059669),
    ),
    _FeatureHighlight(
      title: 'Pembelajaran Adaptif',
      description: 'Jadwal fleksibel, materi personal, serta progress report berkala.',
      icon: Icons.schedule_rounded,
      color: const Color(0xFF2563EB),
    ),
    _FeatureHighlight(
      title: 'Teknologi AI Voice',
      description: 'Evaluasi bacaan otomatis membantu meningkatkan tajwid Anda.',
      icon: Icons.graphic_eq_rounded,
      color: const Color(0xFFD97706),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = GoogleFonts.poppinsTextTheme(theme.textTheme);

    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF4),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _HeroSection(textTheme: textTheme),
            ),
            SliverToBoxAdapter(
              child: _StatSection(textTheme: textTheme, statItems: _statItems),
            ),
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Program Unggulan Ngaji.ai',
                subtitle:
                    'Pilih jalur belajar yang sesuai tujuan spiritual dan ritme harian Anda.',
              ),
            ),
            SliverToBoxAdapter(
              child: _ProgramSection(programs: _programs),
            ),
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Kenapa Pilih Ngaji.ai?',
                subtitle:
                    'Kami memadukan metode tradisional dengan teknologi untuk hasil terbaik.',
              ),
            ),
            SliverToBoxAdapter(
              child: _FeatureHighlightSection(highlights: _featureHighlights),
            ),
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Mulai dari Surah Populer',
                subtitle:
                    'Bacaan rekomendasi untuk mengawali perjalanan tilawah Anda hari ini.',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              sliver: SliverList.separated(
                itemCount: dummySurahList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final surah = dummySurahList[index];
                  return _SurahCard(
                    surah: surah,
                    onTap: () => Navigator.of(context).push(
                      _createFadeRoute(DetailSurahScreen(surah: surah)),
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: _CallToActionCard(textTheme: textTheme),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF34D399)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Belajar Mengaji Lebih Personal',
                    style: textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Temukan mentor terbaik, jadwal fleksibel, serta evaluasi bacaan dengan teknologi AI.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0F766E),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text('Mulai Sekarang'),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {},
                        child: const Text('Jelajahi Program'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/kids_quran.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF065F46),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatSection extends StatelessWidget {
  const _StatSection({required this.textTheme, required this.statItems});

  final TextTheme textTheme;
  final List<_StatItem> statItems;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: statItems
              .map(
                (item) => Expanded(
                  child: Column(
                    children: [
                      Text(
                        item.value,
                        style: textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF047857),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        textAlign: TextAlign.center,
                        style: textTheme.labelMedium?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _ProgramSection extends StatelessWidget {
  const _ProgramSection({required this.programs});

  final List<_ProgramCardData> programs;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: programs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final program = programs[index];
          return _ProgramCard(program: program);
        },
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.program});

  final _ProgramCardData program;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: program.accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              program.icon,
              color: program.accentColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            program.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF064E3B),
                ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              program.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                    height: 1.4,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: program.accentColor,
            ),
            child: const Text('Selengkapnya'),
          ),
        ],
      ),
    );
  }
}

class _FeatureHighlightSection extends StatelessWidget {
  const _FeatureHighlightSection({required this.highlights});

  final List<_FeatureHighlight> highlights;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: highlights
            .map(
              (highlight) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _FeatureHighlightCard(highlight: highlight),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _FeatureHighlightCard extends StatelessWidget {
  const _FeatureHighlightCard({required this.highlight});

  final _FeatureHighlight highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: highlight.color.withOpacity(0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: highlight.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              highlight.icon,
              color: highlight.color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  highlight.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF064E3B),
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  highlight.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SurahCard extends StatelessWidget {
  const _SurahCard({required this.surah, required this.onTap});

  final Surah surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFF047857),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${surah.ayatCount} ayat',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.black45,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF059669),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallToActionCard extends StatelessWidget {
  const _CallToActionCard({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF047857),
        borderRadius: BorderRadius.circular(28),
        image: const DecorationImage(
          image: AssetImage('assets/images/quran_icon.png'),
          alignment: Alignment.centerRight,
          opacity: 0.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Siap meningkatkan kualitas tilawah Anda?',
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Gabung bersama ribuan santri yang merasakan kemajuan dengan pendampingan mentor dan AI.',
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.85),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF047857),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {},
            child: const Text('Daftar Sekarang'),
          ),
        ],
      ),
    );
  }
}

Route _createFadeRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

class _StatItem {
  const _StatItem(this.value, this.label);
  final String value;
  final String label;
}

class _ProgramCardData {
  const _ProgramCardData({
    required this.title,
    required this.description,
    required this.accentColor,
    required this.icon,
  });

  final String title;
  final String description;
  final Color accentColor;
  final IconData icon;
}

class _FeatureHighlight {
  const _FeatureHighlight({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
}
