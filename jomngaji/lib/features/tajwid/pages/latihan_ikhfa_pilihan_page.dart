import 'package:flutter/material.dart';

import 'widgets/tajwid_mcq_quiz_page.dart';

class LatihanIkhfaPilihanPage extends StatelessWidget {
  const LatihanIkhfaPilihanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TajwidMcqQuizPage(
      title: 'Latihan Ikhfa (Pilihan)',
      quizCode: 'nun_tanwin',
      accent: Color(0xFF0EA5E9),
      intro: 'Fokus khusus soal-soal Ikhfa. Hint benar/salah muncul saat jawaban dipilih.',
    );
  }
}
