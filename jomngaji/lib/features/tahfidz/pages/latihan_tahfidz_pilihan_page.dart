import 'package:flutter/material.dart';

import '../../tajwid/pages/widgets/tajwid_mcq_quiz_page.dart';

class LatihanTahfidzPilihanPage extends StatelessWidget {
  const LatihanTahfidzPilihanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final map = args is Map<String, dynamic> ? args : <String, dynamic>{};

    final levelTag = (map['level_tag'] ?? 'Pemula').toString();
    final quizCode = (map['quiz_code'] ?? 'tahfidz_level_1').toString();

    return TajwidMcqQuizPage(
      title: 'Latihan Soal Interaktif Tahfidz',
      quizCode: quizCode,
      accent: const Color(0xFF2F9E6E),
      intro:
          'Level $levelTag • Jawab soal sesuai tingkatan untuk memperkuat hafalan dan muraja\'ah.',
    );
  }
}
