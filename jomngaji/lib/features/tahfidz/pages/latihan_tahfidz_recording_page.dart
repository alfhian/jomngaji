import 'package:flutter/material.dart';

import '../../tilawah/pages/widgets/tilawah_recording_practice_page.dart';

class LatihanTahfidzRecordingPage extends StatelessWidget {
  const LatihanTahfidzRecordingPage({super.key});

  List<TilawahRecordingPrompt> _promptsForLevel(String levelTag) {
    if (levelTag == 'Menengah') {
      return const [
        TilawahRecordingPrompt(
          arabicText: 'وَالْعَصْرِ',
          tip: 'Baca dengan tempo stabil lalu ulangi minimal 3 kali.',
        ),
        TilawahRecordingPrompt(
          arabicText: 'إِنَّ الْإِنْسَانَ لَفِي خُسْرٍ',
          tip: 'Perhatikan ketepatan urutan kata dan waqaf di akhir ayat.',
        ),
        TilawahRecordingPrompt(
          arabicText: 'إِلَّا الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ',
          tip: 'Jaga panjang ayat tanpa tergesa-gesa.',
        ),
        TilawahRecordingPrompt(
          arabicText: 'وَتَوَاصَوْا بِالْحَقِّ',
          tip: 'Fokus pada makhraj huruf ص dan ق.',
        ),
        TilawahRecordingPrompt(
          arabicText: 'وَتَوَاصَوْا بِالصَّبْرِ',
          tip: 'Ulangi sambil menutup mushaf jika sudah yakin.',
        ),
      ];
    }

    if (levelTag == 'Mahir') {
      return const [
        TilawahRecordingPrompt(
          arabicText: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
          tip: 'Setor ayat tanpa jeda panjang dan tetap tartil.',
        ),
        TilawahRecordingPrompt(
          arabicText: 'اللَّهُ الصَّمَدُ',
          tip: 'Pastikan pengucapan jelas walau ayat pendek.',
        ),
        TilawahRecordingPrompt(
          arabicText: 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
          tip: 'Perhatikan huruf د dan pola waqaf sebelum lanjut.',
        ),
        TilawahRecordingPrompt(
          arabicText: 'وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
          tip: 'Jaga akurasi bacaan akhir ayat sampai selesai.',
        ),
        TilawahRecordingPrompt(
          arabicText: 'فَصَلِّ لِرَبِّكَ وَانْحَرْ',
          tip: 'Latih perpindahan ayat dengan napas yang stabil.',
        ),
      ];
    }

    return const [
      TilawahRecordingPrompt(
        arabicText: 'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ',
        tip: 'Mulai dengan bacaan pelan lalu ulangi sampai lancar.',
      ),
      TilawahRecordingPrompt(
        arabicText: 'فَصَلِّ لِرَبِّكَ وَانْحَرْ',
        tip: 'Fokus urutan ayat dan ketepatan bacaan kata per kata.',
      ),
      TilawahRecordingPrompt(
        arabicText: 'إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ',
        tip: 'Perhatikan makhraj dan pengucapan di akhir ayat.',
      ),
      TilawahRecordingPrompt(
        arabicText: 'وَالضُّحَى',
        tip: 'Ulangi beberapa kali untuk memantapkan hafalan pendek.',
      ),
      TilawahRecordingPrompt(
        arabicText: 'وَاللَّيْلِ إِذَا سَجَى',
        tip: 'Jaga tempo tenang dan konsisten hingga ayat selesai.',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final map = args is Map<String, dynamic> ? args : <String, dynamic>{};

    final levelTag = (map['level_tag'] ?? 'Pemula').toString();
    final quizCode = (map['quiz_code'] ?? 'tahfidz_level_1').toString();
    final lessonId = int.tryParse('${map['lesson_id'] ?? 1}') ?? 1;

    return TilawahRecordingPracticePage(
      title: 'Praktek Setoran Hafalan Tahfidz',
      quizCode: quizCode,
      lessonId: lessonId,
      accent: const Color(0xFF22A06B),
      intro: 'Level $levelTag • Rekam hafalanmu, putar ulang, lalu nilai pengucapan.',
      prompts: _promptsForLevel(levelTag),
    );
  }
}
