import 'package:flutter/material.dart';

import '../../../core/localization/app_localization.dart';
import '../../../core/widgets/section_title.dart';
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
    final l10n = context.l10n;

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const HeaderSection(),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(title: l10n.text('home.categoryTitle'), showSeeAll: false),
                    SizedBox(height: 12),
                    CategoryList(),
                    SizedBox(height: 20),
                    const PrayerTimesLiveCard(),
                    SizedBox(height: 24),
                    SectionTitle(title: l10n.text('home.dailyQuizTitle'), showSeeAll: false),
                    SizedBox(height: 12),
                    HomeDailyQuizCard(),
                    SizedBox(height: 24),
                    TadarusCard(),
                    SizedBox(height: 18),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: double.infinity,
                    height: 108,
                    child: Image.asset(
                      'assets/images/background-mengaji.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
