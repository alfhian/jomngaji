import 'package:flutter/material.dart';

import 'widgets/tajwid_mcq_quiz_page.dart';

class LatihanMadPilihanPage extends StatelessWidget {
  const LatihanMadPilihanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TajwidMcqQuizPage(
      title: 'Latihan Mad',
      quizCode: 'mad',
      accent: Color(0xFF8B5CF6),
      intro: 'Kenali jenis-jenis Mad lewat quiz interaktif. Setiap jawaban akan diberi feedback instan.',
    );
  }
}
