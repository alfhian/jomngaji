import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../core/widgets/custom_gradient_appbar.dart';

class LatihanHarakatPage extends StatefulWidget {
  const LatihanHarakatPage({super.key});

  @override
  State<LatihanHarakatPage> createState() => _LatihanHarakatPageState();
}

class _LatihanHarakatPageState extends State<LatihanHarakatPage> {
  static const int totalQuestionTarget = 10;

  final List<String> hurufList = [
    "ب", "ت", "ث", "ج", "ح", "خ", "د", "ذ", "ر", "ز", "س", "ش", "ص", "ض", "ط", "ظ", "ع", "غ", "ف", "ق", "ك", "ل", "م", "ن", "ه", "و", "ي",
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
        margin: const EdgeInsets.all(24),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: benar ? AppColors.accent : Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        content: Row(
          children: [
            Icon(benar ? Icons.check_circle_rounded : Icons.cancel_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                benar
                    ? 'Luar biasa! Jawabanmu benar ✨'
                    : 'Kurang tepat. Jawaban benar: $correctLatin ($currentHuruf$correctHarakat)',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 1600));
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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events_rounded, color: AppColors.accent, size: 64),
            ),
            const SizedBox(height: 24),
            Text(
              'Latihan Selesai!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Skor kamu: $_correctCount/$totalQuestionTarget',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$percent%',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Kembali ke Menu'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _questionNumber = 1;
                  _correctCount = 0;
                  _streak = 0;
                });
                _generateNewQuestion();
              },
              child: const Text('Latihan Lagi'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionButton(String label) {
    final isSelected = _selectedAnswer == label;
    final isCorrectOption = label == correctLatin;

    Color bg = Colors.white;
    Color text = AppColors.textPrimary;
    Color border = AppColors.border;
    IconData? icon;

    if (_answered) {
      if (isCorrectOption) {
        bg = AppColors.accent.withOpacity(0.1);
        text = AppColors.accent;
        border = AppColors.accent;
        icon = Icons.check_circle_rounded;
      } else if (isSelected) {
        bg = Colors.redAccent.withOpacity(0.1);
        text = Colors.redAccent;
        border = Colors.redAccent;
        icon = Icons.cancel_rounded;
      } else {
        bg = AppColors.scaffold;
        text = AppColors.textPlaceholder;
        border = AppColors.border.withOpacity(0.5);
      }
    } else if (isSelected) {
        border = AppColors.accent;
    }

    return GestureDetector(
      onTap: () => _checkAnswer(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.soft,
          border: Border.all(
            color: border,
            width: isSelected || (_answered && isCorrectOption) ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: text,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(height: 8),
              Icon(icon, size: 24, color: text),
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
      backgroundColor: AppColors.scaffold,
      appBar: const CustomGradientAppBar(title: "Latihan Harakat"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: AppShadows.soft,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Soal $_questionNumber dari $totalQuestionTarget',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          'Streak: $_streak 🔥',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0, 1),
                      minHeight: 10,
                      backgroundColor: AppColors.scaffold,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Pilih harakat yang benar!",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.medium,
                border: Border.all(
                  color: _answered
                      ? (_lastAnswerCorrect ? AppColors.accent : Colors.redAccent).withOpacity(0.3)
                      : AppColors.border.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  "$currentHuruf$correctHarakat",
                  style: GoogleFonts.amiri(
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                    color: _answered
                        ? (_lastAnswerCorrect ? AppColors.accent : Colors.redAccent)
                        : AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
              children: [
                _optionButton("A"),
                _optionButton("I"),
                _optionButton("U"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
