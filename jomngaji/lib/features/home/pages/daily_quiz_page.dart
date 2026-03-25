import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/custom_gradient_appbar.dart';

class DailyQuizPage extends StatefulWidget {
  const DailyQuizPage({super.key});

  @override
  State<DailyQuizPage> createState() => _DailyQuizPageState();
}

class _DailyQuizPageState extends State<DailyQuizPage> {
  final List<Map<String, dynamic>> soalList = [
    {
      "ayat": "ذَوْجٌ",
      "jawaban": "dzaujun",
      "opsi": ["dzaujun", "zaujun", "dzuujun", "zuujun"]
    },
    {
      "ayat": "قُلْ هُوَ اللَّهُ أَحَدٌ",
      "jawaban": "Qul huwallahu ahad",
      "opsi": ["Qul huwallahu ahad", "Qul huwallahu samad", "Qul huwallahu wahid"]
    },
  ];

  int questionIndex = 0;
  int correctCount = 0;

  void checkAnswer(String answer) async {
    bool benar = answer == soalList[questionIndex]["jawaban"];
    if (benar) correctCount++;
    await Future.delayed(const Duration(milliseconds: 400));
    if (questionIndex == soalList.length - 1) {
      finishQuiz();
      return;
    }
    setState(() => questionIndex++);
  }

  void finishQuiz() {
    double scorePercent = (correctCount / soalList.length) * 100;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          scorePercent >= 50 ? "Bagus Sekali!" : "Ayo Coba Lagi",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: scorePercent >= 50 ? Colors.green : Colors.red,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          "Benar: $correctCount dari ${soalList.length}",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final soal = soalList[questionIndex];
    return Scaffold(
      appBar: const CustomGradientAppBar(title: "Kuis Harian"),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (questionIndex + 1) / soalList.length,
              backgroundColor: Colors.grey[300],
              color: const Color(0xFF42C88A),
              minHeight: 8,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
                ],
              ),
              child: Center(
                child: Text(
                  soal["ayat"],
                  style: GoogleFonts.amiri(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.5,
                children: [
                  for (var o in soal["opsi"])
                    ElevatedButton(
                      onPressed: () => checkAnswer(o),
                      child: Text(o),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
