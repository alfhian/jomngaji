import 'package:flutter/material.dart';

import '../../../core/localization/app_localization.dart';
import '../../../core/theme/app_design_tokens.dart';
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const HeaderSection(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 100), // Extra bottom padding for FAB/Nav
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PrayerTimesLiveCard(),
                  const SizedBox(height: 32),
                  
                  SectionTitle(
                    title: l10n.text('home.categoryTitle'),
                    showSeeAll: false,
                  ),
                  const SizedBox(height: 18),
                  const CategoryList(),
                  
                  const SizedBox(height: 32),
                  SectionTitle(
                    title: l10n.text('home.dailyQuizTitle'),
                    showSeeAll: false,
                  ),
                  const SizedBox(height: 18),
                  const HomeDailyQuizCard(),
                  
                  const SizedBox(height: 32),
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
}
