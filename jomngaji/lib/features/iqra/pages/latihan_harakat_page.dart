import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/custom_gradient_appbar.dart';

class LatihanHarakatPage extends StatefulWidget {
  const LatihanHarakatPage({super.key});

  @override
  State<LatihanHarakatPage> createState() => _LatihanHarakatPageState();
}

class _LatihanHarakatPageState extends State<LatihanHarakatPage> {
  static const int totalQuestionTarget = 10;

  final List<String> hurufList = [
    "ب",
    "ت",
    "ث",
    "ج",
    "ح",
    "خ",
    "د",
    "ذ",
    "ر",
    "ز",
    "س",
    "ش",
    "ص",
    "ض",
    "ط",
    "ظ",
    "ع",
    "غ",
    "ف",
    "ق",
    "ك",
    "ل",
    "م",
    "ن",
    "ه",
    "و",
    "ي",
  ];

  final Map<String, String> harakat = {
    "A": "َ", // Fathah
    "I": "ِ", // Kasrah
    "U": "ُ", // Dhammah
  };

  late String currentHuruf;
  late String correctLatin;
  late String correctHarakat;

  int _questionNumber = 1;
  int _correctCount = 0;
  int _streak = 0;

  bool _answered = false;
  String? _selectedAnswer;
  bool _lastAnswerCorrect = false;

  @override
  void initState() {
    super.initState();
    _generateNewQuestion();
  }

  void _generateNewQuestion() {
    final random = Random();
    currentHuruf = hurufList[random.nextInt(hurufList.length)];

    final keys = harakat.keys.toList();
    correctLatin = keys[random.nextInt(keys.length)];
    correctHarakat = harakat[correctLatin]!;

    setState(() {
      _answered = false;
      _selectedAnswer = null;
    });
  }

  Future<void> _checkAnswer(String answer) async {
    if (_answered) return;

    final benar = answer == correctLatin;

    setState(() {
      _answered = true;
      _selectedAnswer = answer;
      _lastAnswerCorrect = benar;
      if (benar) {
        _correctCount++;
        _streak++;
      } else {
        _streak = 0;
      }
    });

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(milliseconds: 900),
        backgroundColor: benar ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
        content: Text(
          benar
              ? '✅ Benar! Mantap, lanjut ya!'
              : '❌ Kurang tepat. Jawaban benar: $correctLatin ($currentHuruf$correctHarakat)',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;

    if (_questionNumber >= totalQuestionTarget) {
      _showSummaryDialog();
      return;
    }

    setState(() {
      _questionNumber++;
    });
    _generateNewQuestion();
  }

  void _showSummaryDialog() {
    final percent = ((_correctCount / totalQuestionTarget) * 100).round();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Selesai 🎉',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Skor kamu: $_correctCount/$totalQuestionTarget',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              '$percent%',
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF42C88A),
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Kembali',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF42C88A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _questionNumber = 1;
                _correctCount = 0;
                _streak = 0;
              });
              _generateNewQuestion();
            },
            child: Text(
              'Main Lagi',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionButton(String label) {
    final isSelected = _selectedAnswer == label;
    final isCorrectOption = label == correctLatin;

    Color bg = const Color(0xFFE8FFF0);
    Color text = const Color(0xFF42C88A);
    IconData? icon;

    if (_answered) {
      if (isCorrectOption) {
        bg = const Color(0xFFD4F7DF);
        text = const Color(0xFF1B8A4A);
        icon = Icons.check_circle_rounded;
      } else if (isSelected) {
        bg = const Color(0xFFFFE1E1);
        text = const Color(0xFFC62828);
        icon = Icons.cancel_rounded;
      } else {
        bg = Colors.grey.shade100;
        text = Colors.grey.shade600;
      }
    }

    return GestureDetector(
      onTap: () => _checkAnswer(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
          border: Border.all(
            color: isSelected ? text.withOpacity(0.35) : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: text,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(height: 6),
              Icon(icon, size: 20, color: text),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _questionNumber / totalQuestionTarget;

    return Scaffold(
      appBar: const CustomGradientAppBar(title: "Latihan Harakat"),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Soal $_questionNumber/$totalQuestionTarget',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF9F0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Streak: $_streak 🔥',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2F9E6E),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                color: const Color(0xFF42C88A),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Pilih harakat yang benar!",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: _answered
                    ? (_lastAnswerCorrect
                        ? const Color(0xFFE8F9EE)
                        : const Color(0xFFFFECEC))
                    : const Color(0xFFF2FFF6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _answered
                      ? (_lastAnswerCorrect
                          ? const Color(0xFF42C88A).withOpacity(0.25)
                          : Colors.red.withOpacity(0.22))
                      : Colors.transparent,
                ),
              ),
              child: Center(
                child: Text(
                  "$currentHuruf$correctHarakat",
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF42C88A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 18,
                crossAxisSpacing: 18,
                children: [
                  _optionButton("A"),
                  _optionButton("I"),
                  _optionButton("U"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
