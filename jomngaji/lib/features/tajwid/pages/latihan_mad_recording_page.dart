import 'package:flutter/material.dart';

import 'widgets/tajwid_recording_practice_page.dart';

class LatihanMadRecordingPage extends StatelessWidget {
  const LatihanMadRecordingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TajwidRecordingPracticePage(
      title: 'Recording Mad',
      accent: Color(0xFF8B5CF6),
      quizCode: 'mad',
      intro: 'Jaga panjang pendek bacaan sesuai jenis Mad.',
      prompts: [
        RecordingPrompt(arabicText: 'قَالَ', tip: 'Mad Thabi\'i dibaca 2 harakat.'),
        RecordingPrompt(arabicText: 'جَاءَكُمْ', tip: 'Mad Wajib Muttashil 4-5 harakat.'),
        RecordingPrompt(arabicText: 'فِي أَنفُسِكُمْ', tip: 'Mad Jaiz Munfashil 4-5 harakat.'),
      ],
    );
  }
}
