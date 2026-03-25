import 'package:flutter/material.dart';

import 'widgets/tajwid_recording_practice_page.dart';

class LatihanMimMatiRecordingPage extends StatelessWidget {
  const LatihanMimMatiRecordingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TajwidRecordingPracticePage(
      title: 'Recording Mim Mati',
      accent: Color(0xFF3B82F6),
      quizCode: 'mim_mati',
      intro: 'Fokus pada tiga hukum Mim Mati dan konsistensi makhraj bibir.',
      prompts: [
        RecordingPrompt(arabicText: 'نِعْمَةٌ مِنَ اللّٰهِ', tip: 'Idzhar Syafawi: mim dibaca jelas.'),
        RecordingPrompt(arabicText: 'تَرْمِيهِمْ بِحِجَارَةٍ', tip: 'Ikhfa Syafawi: bibir menutup ringan.'),
        RecordingPrompt(arabicText: 'لَهُمْ مَغْفِرَةٌ', tip: 'Idgham Mimi: leburkan mim ke mim berikutnya.'),
      ],
    );
  }
}
