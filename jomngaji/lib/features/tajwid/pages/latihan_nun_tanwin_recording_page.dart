import 'package:flutter/material.dart';

import 'widgets/tajwid_recording_practice_page.dart';

class LatihanNunTanwinRecordingPage extends StatelessWidget {
  const LatihanNunTanwinRecordingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TajwidRecordingPracticePage(
      title: 'Recording Nun Mati & Tanwin',
      accent: Color(0xFF22A06B),
      quizCode: 'nun_tanwin',
      intro: 'Latih pelafalan Nun Mati & Tanwin dengan rekaman. Ulangi sampai bacaan makin stabil.',
      prompts: [
        RecordingPrompt(arabicText: 'مِنْ نُورٍ', tip: 'Perjelas hukum Idzhar.'),
        RecordingPrompt(arabicText: 'مَنْ يَقُولُ', tip: 'Perhatikan Idgham dengan dengung cukup.'),
        RecordingPrompt(arabicText: 'أَنْبِيَاءَ', tip: 'Iqlab: ubah nun menjadi bunyi mim samar.'),
        RecordingPrompt(arabicText: 'مِنْ رَبِّهِمْ', tip: 'Ikhfa: bacaan samar, tidak terlalu jelas.'),
      ],
    );
  }
}
