import 'package:flutter/material.dart';

import 'widgets/tajwid_mcq_quiz_page.dart';

class LatihanGhunnahPilihanPage extends StatelessWidget {
  const LatihanGhunnahPilihanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TajwidMcqQuizPage(
      title: 'Latihan Ghunnah',
      quizCode: 'ghunnah',
      accent: Color(0xFFEC4899),
      intro: 'Latih insting Ghunnah dengan soal pilihan ganda dari database quiz. Jawaban langsung dapat hint benar/salah.',
    );
  }
}
