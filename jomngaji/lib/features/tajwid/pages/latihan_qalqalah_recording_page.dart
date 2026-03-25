import 'package:flutter/material.dart';

import 'widgets/tajwid_recording_practice_page.dart';

class LatihanQalqalahRecordingPage extends StatelessWidget {
  const LatihanQalqalahRecordingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TajwidRecordingPracticePage(
      title: 'Recording Qalqalah',
      accent: Color(0xFFF97316),
      quizCode: 'qalqalah',
      intro: 'Latih pantulan suara huruf qalqalah dengan ketukan yang pas.',
      prompts: [
        RecordingPrompt(arabicText: 'قَدْ أَفْلَحَ', tip: 'Sughra: pantulan ringan di tengah bacaan.'),
        RecordingPrompt(arabicText: 'وَاللَّهُ أَكْبَرْ', tip: 'Kubra: pantulan lebih kuat saat waqaf.'),
      ],
    );
  }
}
