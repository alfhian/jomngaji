import 'package:flutter/material.dart';

import 'widgets/tilawah_recording_practice_page.dart';

class LatihanTilawahRecordingPage extends StatelessWidget {
  const LatihanTilawahRecordingPage({super.key});

  List<TilawahRecordingPrompt> _promptsForLevel(String levelTag) {
    if (levelTag == 'Menengah') {
      return const [
        TilawahRecordingPrompt(
          arabicText: 'وَرَتِّلِ الْقُرْآنَ تَرْتِيلًا',
          tip: 'Baca tartil dan jelas, perhatikan panjang pendek bacaan.',
        ),
        TilawahRecordingPrompt(
          arabicText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
          tip: 'Jaga waqaf di akhir ayat agar makna tetap utuh.',
        ),
        TilawahRecordingPrompt(
          arabicText: 'الرَّحْمَٰنِ الرَّحِيمِ',
          tip: 'Fokus pada kejelasan huruf dan sifat huruf.',
        ),
        TilawahRecordingPrompt(
          arabicText: 'مَالِكِ يَوْمِ الدِّينِ',
          tip: 'Perhatikan mad dan ketukan bacaan yang stabil.',
        ),
        TilawahRecordingPrompt(
          arabicText: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
          tip: 'Jaga tempo dan pengucapan tetap konsisten sampai akhir.',
        ),
      ];
    }

    if (levelTag == 'Mahir') {
      return const [
        TilawahRecordingPrompt(
          arabicText: 'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ',
          tip: 'Latih kestabilan irama dan ketepatan tajwid secara bersamaan.',
        ),
        TilawahRecordingPrompt(
          arabicText: 'فَصَلِّ لِرَبِّكَ وَانْحَرْ',
          tip: 'Perhatikan makhraj huruf dan hentian bacaan yang tepat.',
        ),
        TilawahRecordingPrompt(
          arabicText: 'إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ',
          tip: 'Baca utuh dengan artikulasi jelas dan tidak tergesa-gesa.',
        ),
        TilawahRecordingPrompt(
          arabicText: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
          tip: 'Pastikan qalqalah dan ghunnah dibaca proporsional.',
        ),
        TilawahRecordingPrompt(
          arabicText: 'اللَّهُ الصَّمَدُ',
          tip: 'Baca singkat namun tetap berwibawa dan tepat tajwid.',
        ),
      ];
    }

    return const [
      TilawahRecordingPrompt(
        arabicText: 'اقْرَأْ بِاسْمِ رَبِّكَ',
        tip: 'Mulai dengan tenang dan jelas, jangan terlalu cepat.',
      ),
      TilawahRecordingPrompt(
        arabicText: 'وَرَتِّلِ الْقُرْآنَ تَرْتِيلًا',
        tip: 'Baca perlahan (tartil) sambil memperhatikan setiap huruf.',
      ),
      TilawahRecordingPrompt(
        arabicText: 'يَتْلُونَهُ حَقَّ تِلَاوَتِهِ',
        tip: 'Perhatikan kelancaran sambung kata dan kejelasan makhraj.',
      ),
      TilawahRecordingPrompt(
        arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        tip: 'Latih bacaan basmalah dengan ritme yang stabil.',
      ),
      TilawahRecordingPrompt(
        arabicText: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
        tip: 'Jaga panjang pendek bacaan pada kata-kata mad.',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final map = args is Map<String, dynamic> ? args : <String, dynamic>{};

    final levelTag = (map['level_tag'] ?? 'Pemula').toString();
    final quizCode = (map['quiz_code'] ?? 'tilawah_level_1').toString();
    final lessonId = int.tryParse('${map['lesson_id'] ?? 1}') ?? 1;

    return TilawahRecordingPracticePage(
      title: 'Praktek Bacaan Tilawah',
      quizCode: quizCode,
      lessonId: lessonId,
      accent: const Color(0xFF22A06B),
      intro: 'Level $levelTag • Rekam bacaanmu, putar ulang, lalu nilai pengucapan.',
      prompts: _promptsForLevel(levelTag),
    );
  }
}
