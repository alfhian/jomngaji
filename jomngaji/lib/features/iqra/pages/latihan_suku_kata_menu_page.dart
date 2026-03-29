import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../core/widgets/premium_upgrade_dialog.dart';
import '../../../services/suku_kata_service.dart';
import 'latihan_suku_kata_page.dart';

class LatihanSukuKataMenuPage extends StatefulWidget {
  const LatihanSukuKataMenuPage({super.key});

  @override
  State<LatihanSukuKataMenuPage> createState() => _LatihanSukuKataMenuPageState();
}

class _LatihanSukuKataMenuPageState extends State<LatihanSukuKataMenuPage> {
  bool _loading = true;
  List<SukuKataLevel> _levels = [];
  double _progressFromApi = 0.0;

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    setState(() => _loading = true);
    try {
      final payload = await SukuKataService.getLevels();
      setState(() {
        _levels = payload.levels;
        _progressFromApi = payload.progressPercentage;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil level: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _progressValue {
    if (_progressFromApi > 0) return _progressFromApi.clamp(0.0, 1.0);
    if (_levels.isEmpty) return 0.0;
    final unlocked = _levels.where((e) => e.isUnlocked).length;
    return unlocked / _levels.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLevels,
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
                            "Level Pelajaran",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _levelList(context),
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
      expandedHeight: 220,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          "Suku Kata",
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
                'Mengenal dan Mengucapkan Suku Kata',
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
                "Progres Latihan",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                "${(_progressValue * 100).toInt()}%",
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
              value: _progressValue,
              backgroundColor: AppColors.scaffold,
              minHeight: 10,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Selesaikan level untuk menguasai pengucapan suku kata.",
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

  Widget _levelList(BuildContext context) {
    if (_levels.isEmpty) {
      return Center(
        child: Text(
          'Level belum tersedia.',
          style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: _levels.map((level) {
        return _levelCard(context, level: level);
      }).toList(),
    );
  }

  Widget _levelCard(
    BuildContext context, {
    required SukuKataLevel level,
  }) {
    final unlocked = level.isUnlocked;

    return GestureDetector(
      onTap: () async {
        if (level.isPremium) {
          await runWithPremiumGate(
            context,
            featureName: level.title,
            onAllowed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LatihanSukuKataPage(level: level),
              ),
            ).then((_) => _loadLevels()),
          );
          return;
        }
        if (unlocked) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LatihanSukuKataPage(level: level),
            ),
          ).then((_) => _loadLevels());
        }
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
                    level.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: unlocked ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    level.description.isEmpty ? 'Soal: ${level.totalQuestions}' : level.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (level.isPremium)
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
