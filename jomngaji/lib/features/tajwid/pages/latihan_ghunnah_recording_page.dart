import 'package:flutter/material.dart';

import 'widgets/tajwid_recording_practice_page.dart';

class LatihanGhunnahRecordingPage extends StatelessWidget {
  const LatihanGhunnahRecordingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TajwidRecordingPracticePage(
      title: 'Recording Ghunnah',
      accent: Color(0xFFEC4899),
      quizCode: 'ghunnah',
      intro: 'Rasakan dengung 2 harakat dan jaga kestabilan suara.',
      prompts: [
        RecordingPrompt(arabicText: 'إِنَّ اللَّهَ', tip: 'Nun tasydid: dengung jelas 2 harakat.'),
        RecordingPrompt(arabicText: 'ثُمَّ إِلَيْنَا', tip: 'Mim tasydid: dengung stabil.'),
        RecordingPrompt(arabicText: 'مِن شَرِّ', tip: 'Ikhfa: dengung samar tidak berlebihan.'),
      ],
    );
  }
}
