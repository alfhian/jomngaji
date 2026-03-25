import 'package:flutter/material.dart';

import 'widgets/tajwid_recording_practice_page.dart';

class LatihanIkhfaRecordingPage extends StatelessWidget {
  const LatihanIkhfaRecordingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TajwidRecordingPracticePage(
      title: 'Latihan Ikhfa (Recording)',
      accent: Color(0xFF0EA5E9),
      quizCode: 'ikhfa',
      intro: 'Latihan fokus Ikhfa dengan rekaman dan evaluasi cepat.',
      prompts: [
        RecordingPrompt(arabicText: 'مِنْ رَبِّهِمْ', tip: 'Nun dibaca samar, jangan terlalu jelas.'),
        RecordingPrompt(arabicText: 'أَنْزَلَ', tip: 'Jaga dengung tipis sebelum huruf ikhfa.'),
        RecordingPrompt(arabicText: 'مِنْ ثَمَرَاتٍ', tip: 'Ikhfa pada nun sukun bertemu tsa.'),
      ],
    );
  }
}
