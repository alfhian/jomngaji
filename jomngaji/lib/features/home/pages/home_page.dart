import 'package:flutter/material.dart';

import '../../../core/localization/app_localization.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../core/widgets/section_title.dart';
import '../../../features/doa/data/doa_data.dart';
import '../../../routes/app_routes.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/category_list.dart';
import '../widgets/header_section.dart';
import '../widgets/home_daily_quiz_card.dart';
import '../widgets/prayer_times_live_card.dart';
import '../widgets/tadarus_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      extendBody: true,
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HeaderSection(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PrayerTimesLiveCard(),
                  const SizedBox(height: 18),
                  _promoCard(),
                  const SizedBox(height: 22),
                  const CategoryList(),
                  const SizedBox(height: 26),
                  const SectionTitle(
                    title: 'Aktivitas Hari Ini',
                    showSeeAll: false,
                  ),
                  const SizedBox(height: 14),
                  _activityCards(context),
                  const SizedBox(height: 26),
                  SectionTitle(
                    title: context.l10n.text('home.dailyQuizTitle'),
                    showSeeAll: false,
                  ),
                  const SizedBox(height: 14),
                  const HomeDailyQuizCard(),
                  const SizedBox(height: 24),
                  const SectionTitle(
                    title: 'Doa Hari Ini',
                    showSeeAll: false,
                  ),
                  const SizedBox(height: 14),
                  _doaTodayCard(context),
                  const SizedBox(height: 24),
                  const TadarusCard(),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        boxShadow: AppShadows.soft,
                      ),
                      child: Image.asset(
                        'assets/images/background-mengaji.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _promoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D7F0D), Color(0xFF4C990E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Banyak yang sudah memulai belajar ngaji hari ini',
              style: TextStyle(
                color: Colors.white.withOpacity(0.96),
                fontWeight: FontWeight.w700,
                fontSize: 17,
                height: 1.3,
              ),
            ),
          ),
          const Icon(Icons.trending_up_rounded, color: Colors.white, size: 30),
        ],
      ),
    );
  }

  Widget _activityCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _activityCard(
            title: 'Belajar',
            subtitle: 'Mulai Belajar',
            icon: Icons.auto_stories_rounded,
            onTap: () => Navigator.pushNamed(context, AppRoutes.tilawahMenu),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _activityCard(
            title: 'Ikhtiar',
            subtitle: 'Lihat Ikhtiarku',
            icon: Icons.hourglass_top_rounded,
            onTap: () => Navigator.pushNamed(context, AppRoutes.doaMenu),
          ),
        ),
      ],
    );
  }

  Widget _activityCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8F2),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: const Color(0xFFCAE0B9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF4A8E1D), size: 30),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF4A8E1D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _doaTodayCard(BuildContext context) {
    final now = DateTime.now();
    final idx = (now.year + now.month + now.day + now.hour) % doaList.length;
    final doa = doaList[idx];
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.doaDetail, arguments: doa),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppRadius.md)),
              child: Image.asset(
                'assets/images/background-mengaji.png',
                width: 130,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  doa.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
