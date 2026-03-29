import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../core/widgets/premium_upgrade_dialog.dart';
import '../../../services/hijaiyah_service.dart';
import '../data/hijaiyah_data.dart';
import 'materi_huruf_detail_page.dart';

class MateriHijaiyahPage extends StatefulWidget {
  const MateriHijaiyahPage({super.key});

  @override
  State<MateriHijaiyahPage> createState() => _MateriHijaiyahPageState();
}

class _MateriHijaiyahPageState extends State<MateriHijaiyahPage> {
  bool _loading = true;
  double _progress = 0;
  List<HijaiyahLesson> _lessons = [];

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    setState(() => _loading = true);
    try {
      final payload = await HijaiyahService.getLessons();
      if (!mounted) return;
      setState(() {
        _lessons = payload.lessons;
        _progress = payload.progress;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil materi hijaiyah: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<HijaiyahData> _lessonLettersByIndex(int lessonIndex) {
    if (_lessons.isEmpty) return const [];

    final safeIndex = lessonIndex.clamp(0, _lessons.length - 1);
    final start = _lessons
        .take(safeIndex)
        .fold<int>(0, (sum, lesson) => sum + lesson.totalLetters);

    final length = _lessons[safeIndex].totalLetters;

    if (start >= hijaiyahList.length) return const [];

    final end = (start + length).clamp(start, hijaiyahList.length);
    return hijaiyahList.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLessons,
              child: CustomScrollView(
                slivers: [
                  _sliverAppBar(context),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _progressSection(),
                          const SizedBox(height: 32),
                          Text(
                            "Daftar Pelajaran",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _lessonList(context),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _sliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          "Huruf Hijaiyah",
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
                    Colors.black.withOpacity(0.4),
                    AppColors.primary.withOpacity(0.8),
                  ],
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

  Widget _progressSection() {
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
                "Progres Belajar",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                "${(_progress * 100).toInt()}%",
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
              value: _progress,
              backgroundColor: AppColors.scaffold,
              minHeight: 10,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Selesaikan semua materi untuk membuka tes akhir.",
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

  Widget _lessonList(BuildContext context) {
    if (_lessons.isEmpty) {
      return Center(
        child: Text(
          'Materi belum tersedia.',
          style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: List.generate(_lessons.length, (index) {
        final lesson = _lessons[index];
        final unlocked = lesson.isUnlocked;
        final letters = _lessonLettersByIndex(index);

        return _lessonItem(
          context,
          number: index + 1,
          title: lesson.title,
          subtitle: lesson.description,
          unlocked: unlocked,
          isPremium: lesson.isPremium,
          onTap: unlocked
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MateriHurufDetailPage(
                        lessonId: lesson.id,
                        lessonTitle: lesson.title,
                        hurufList: letters,
                      ),
                    ),
                  ).then((_) => _loadLessons());
                }
              : null,
        );
      }),
    );
  }

  Widget _lessonItem(
    BuildContext context, {
    required int number,
    required String title,
    required String subtitle,
    required bool unlocked,
    required bool isPremium,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () async {
        if (isPremium) {
          await runWithPremiumGate(
            context,
            featureName: 'Pelajaran $number',
            onAllowed: () => onTap?.call(),
          );
          return;
        }
        if (unlocked) onTap?.call();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.soft,
          border: Border.all(
            color: unlocked ? AppColors.accent.withOpacity(0.3) : AppColors.border.withOpacity(0.5),
            width: unlocked ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: unlocked ? AppColors.accent.withOpacity(0.1) : AppColors.scaffold,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: unlocked
                    ? const Icon(Icons.play_circle_fill_rounded, color: AppColors.accent, size: 28)
                    : const Icon(Icons.lock_rounded, color: AppColors.textPlaceholder, size: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pelajaran $number",
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: unlocked ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (isPremium)
              Container(
                margin: const EdgeInsets.only(right: 8),
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
            if (unlocked)
              const Icon(Icons.chevron_right_rounded, color: AppColors.textPlaceholder),
          ],
        ),
      ),
    );
  }
}
