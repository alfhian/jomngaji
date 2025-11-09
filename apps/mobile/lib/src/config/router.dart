import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/surah_repository.dart';
import '../models/surah.dart';
import '../screens/belajar/detail_surah_screen.dart';
import '../screens/main_screen.dart';
import '../screens/shared/not_found_screen.dart';

enum AppRoute { home, lessonDetail }

GoRouter createRouter(SurahRepository surahRepository) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: AppRoute.home.name,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: MainScreen(),
        ),
        routes: [
          GoRoute(
            path: 'lessons/:surahId',
            name: AppRoute.lessonDetail.name,
            builder: (context, state) {
              final extra = state.extra;
              if (extra is Surah) {
                return DetailSurahScreen(surah: extra);
              }

              final surahId = int.tryParse(state.pathParameters['surahId'] ?? '');
              final surah =
                  surahId == null ? null : surahRepository.findByNumber(surahId);
              if (surah == null) {
                return const NotFoundScreen();
              }

              return DetailSurahScreen(surah: surah);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}
