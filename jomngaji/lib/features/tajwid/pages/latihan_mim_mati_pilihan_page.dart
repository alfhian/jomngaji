import 'package:flutter/material.dart';

import 'widgets/tajwid_mcq_quiz_page.dart';

class LatihanMimMatiPilihanPage extends StatelessWidget {
  const LatihanMimMatiPilihanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TajwidMcqQuizPage(
      title: 'Latihan Mim Mati',
      quizCode: 'mim_mati',
      accent: Color(0xFF3B82F6),
      intro: 'Fokuskan pada Idzhar Syafawi, Ikhfa Syafawi, dan Idgham Mimi. Hint langsung akan muncul setelah memilih.',
    );
  }
}
