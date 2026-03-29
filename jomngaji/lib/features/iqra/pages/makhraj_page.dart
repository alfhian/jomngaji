import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_design_tokens.dart';
import 'halqiy_page.dart';
import 'khaysyum_page.dart';
import 'lisani_page.dart';
import 'syafawi_page.dart';

class MakhrajPage extends StatefulWidget {
  const MakhrajPage({super.key});

  @override
  State<MakhrajPage> createState() => _MakhrajPageState();
}

class _MakhrajPageState extends State<MakhrajPage> {
  final Set<int> _visited = <int>{};

  late final List<_MakhrajItem> _items = [
    _MakhrajItem(
      title: 'Halqiy (Tenggorokan)',
      subtitle: 'Huruf: ء هـ',
      icon: Icons.record_voice_over_rounded,
      pageBuilder: (_) => const HalqiyPage(),
      color: AppColors.accent,
    ),
    _MakhrajItem(
      title: 'Lisani (Lidah)',
      subtitle: 'Huruf: ت د ط ظ ل ر',
      icon: Icons.forum_rounded,
      pageBuilder: (_) => const LisaniPage(),
      color: AppColors.secondary,
    ),
    _MakhrajItem(
      title: 'Syafawi (Bibir)',
      subtitle: 'Huruf: ف ب م',
      icon: Icons.mic_rounded,
      pageBuilder: (_) => const SyafawiPage(),
      color: Colors.orange,
    ),
    _MakhrajItem(
      title: 'Khaysyum (Rongga Hidung)',
      subtitle: 'Huruf: ن (ghunnah)',
      icon: Icons.graphic_eq_rounded,
      pageBuilder: (_) => const KhaysyumPage(),
      color: Colors.purple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final progress = _items.isEmpty ? 0.0 : _visited.length / _items.length;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: CustomScrollView(
        slivers: [
          _sliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _progressSection(progress),
                  const SizedBox(height: 32),
                  _makhrajInfoCard(),
                  const SizedBox(height: 32),
                  Text(
                    "Kategori Makhraj",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _makhrajCards(context),
                  const SizedBox(height: 32),
                  _tipCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          "Makhraj Huruf",
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              "assets/images/hijaiyah_banner_2.png",
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    AppColors.primary.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: 24,
              right: 24,
              child: Text(
                'Latihan Pengucapan\nHijaiyah yang Tepat',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _progressSection(double progress) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Progres Eksplorasi",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.scaffold,
              minHeight: 10,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "${_visited.length}/${_items.length} kategori makhraj telah dibuka.",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _makhrajInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_rounded, color: AppColors.gold, size: 24),
              const SizedBox(width: 12),
              Text(
                'Apa itu Makhraj?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Makhraj adalah tempat keluarnya huruf saat diucapkan, seperti dari tenggorokan, lidah, bibir, atau rongga hidung. Penguasaan makhraj sangat penting agar bacaan Al-Quran lebih tartil dan benar.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _makhrajCards(BuildContext context) {
    return Column(
      children: List.generate(_items.length, (i) {
        final item = _items[i];
        final opened = _visited.contains(i);

        return GestureDetector(
          onTap: () {
            setState(() => _visited.add(i));
            Navigator.push(
              context,
              MaterialPageRoute(builder: item.pageBuilder),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppShadows.soft,
              border: Border.all(
                color: opened ? item.color.withOpacity(0.3) : AppColors.border.withOpacity(0.5),
                width: opened ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(item.icon, color: item.color, size: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  opened ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                  color: opened ? AppColors.accent : AppColors.textPlaceholder,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _tipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.medium,
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_rounded, color: AppColors.gold, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Tips: Mulailah dari Halqiy (Tenggorokan) agar urutan latihan lebih terstruktur.',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MakhrajItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder pageBuilder;
  final Color color;

  const _MakhrajItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.pageBuilder,
    required this.color,
  });
}
