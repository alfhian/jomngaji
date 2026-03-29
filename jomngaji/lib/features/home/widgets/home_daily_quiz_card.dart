import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../data/daily_quiz_bank.dart';

class HomeDailyQuizCard extends StatefulWidget {
  const HomeDailyQuizCard({super.key});

  @override
  State<HomeDailyQuizCard> createState() => _HomeDailyQuizCardState();
}

class _HomeDailyQuizCardState extends State<HomeDailyQuizCard> {
  static const _dateKey = 'daily_quiz_answered_date';
  static const _pickedKey = 'daily_quiz_picked_index';
  static const _selectedKey = 'daily_quiz_selected_answer';
  static const _isCorrectKey = 'daily_quiz_is_correct';

  DailyQuizItem? _quiz;
  int _pickedIndex = 0;
  bool _loading = true;
  bool _answered = false;
  String? _selected;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  String _today() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadQuiz() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _today();

    final savedDate = prefs.getString(_dateKey);
    final sameDay = savedDate == today;

    int picked = prefs.getInt(_pickedKey) ?? Random().nextInt(dailyQuizBank.length);
    if (!sameDay) {
      picked = Random().nextInt(dailyQuizBank.length);
      await prefs.setString(_dateKey, today);
      await prefs.setInt(_pickedKey, picked);
      await prefs.remove(_selectedKey);
      await prefs.remove(_isCorrectKey);
    }

    setState(() {
      _pickedIndex = picked;
      _quiz = dailyQuizBank[picked];
      _selected = prefs.getString(_selectedKey);
      _answered = _selected != null;
      _isCorrect = prefs.getBool(_isCorrectKey) ?? false;
      _loading = false;
    });
  }

  Future<void> _answer(String option) async {
    if (_answered || _quiz == null) return;

    final correct = option == _quiz!.answer;
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_selectedKey, option);
    await prefs.setBool(_isCorrectKey, correct);

    setState(() {
      _answered = true;
      _selected = option;
      _isCorrect = correct;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _quiz == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.soft,
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 3)),
      );
    }

    final q = _quiz!;
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.medium,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.md),
                topRight: Radius.circular(AppRadius.md),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.psychology_rounded, color: AppColors.accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quiz Harian',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        q.category,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_answered)
                  const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 20),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q.question,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                ...q.options.map((opt) {
                  final selected = _selected == opt;
                  final correctOpt = _answered && opt == q.answer;
                  final wrongSelected = _answered && selected && opt != q.answer;

                  Color bg = Colors.white;
                  Color border = AppColors.border;
                  Color textColor = AppColors.textPrimary;
                  
                  if (correctOpt) {
                    bg = AppColors.accent.withOpacity(0.1);
                    border = AppColors.accent;
                    textColor = AppColors.accent;
                  } else if (wrongSelected) {
                    bg = Colors.red.withOpacity(0.05);
                    border = Colors.redAccent;
                    textColor = Colors.redAccent;
                  } else if (_answered && !selected) {
                    bg = AppColors.scaffold;
                    textColor = AppColors.textSecondary.withOpacity(0.6);
                  }

                  return GestureDetector(
                    onTap: () => _answer(opt),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: border, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              opt,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (correctOpt)
                            const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 18),
                          if (wrongSelected)
                            const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 18),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.scaffold,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _answered
                              ? 'Terima kasih sudah menjawab! Nantikan kuis baru besok.'
                              : 'Jawab kuis harian untuk mengasah pemahamanmu.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
