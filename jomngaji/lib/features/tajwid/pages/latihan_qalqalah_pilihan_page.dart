import 'package:flutter/material.dart';

import 'widgets/tajwid_mcq_quiz_page.dart';

class LatihanQalqalahPilihanPage extends StatelessWidget {
  const LatihanQalqalahPilihanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TajwidMcqQuizPage(
      title: 'Latihan Qalqalah',
      quizCode: 'qalqalah',
      accent: Color(0xFFF97316),
      intro: 'Bedakan Qalqalah Kubra dan Sughra lewat soal yang lebih seru dan modern.',
    );
  }
}
