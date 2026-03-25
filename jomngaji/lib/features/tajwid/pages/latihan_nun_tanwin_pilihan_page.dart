import 'package:flutter/material.dart';

import 'widgets/tajwid_mcq_quiz_page.dart';

class LatihanNunTanwinPilihanPage extends StatelessWidget {
  const LatihanNunTanwinPilihanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TajwidMcqQuizPage(
      title: 'Latihan Nun Mati & Tanwin',
      quizCode: 'nun_tanwin',
      accent: Color(0xFF22A06B),
      intro: 'Jawab cepat dan tepat. Setelah memilih jawaban, kamu akan langsung mendapat hint benar/salah.',
    );
  }
}
