import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../core/widgets/custom_gradient_appbar.dart';
import '../../../core/widgets/premium_upgrade_dialog.dart';
import '../../../services/suku_kata_service.dart';

class LatihanSukuKataPage extends StatefulWidget {
  final SukuKataLevel level;

  const LatihanSukuKataPage({
    super.key,
    required this.level,
  });

  @override
  State<LatihanSukuKataPage> createState() => _LatihanSukuKataPageState();
}

class _LatihanSukuKataPageState extends State<LatihanSukuKataPage>
    with TickerProviderStateMixin {
  static const int _maxQuestions = 5;
  static const double _passScore = 70;

  bool _loading = true;
  List<SukuKataQuestion> _questions = [];
  List<SukuKataQuestion> _sessionQuestions = [];

  int _questionIndex = 0;
  int _correctCount = 0;
  int _streak = 0;
  int _bestStreak = 0;

  String? _selectedOption;
  bool _lockedAnswer = false;

  late AnimationController correctAnim;
  late AnimationController wrongAnim;

  @override
  void initState() {
    super.initState();

    correctAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    wrongAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _loadQuestions();
  }

  @override
  void dispose() {
    correctAnim.dispose();
    wrongAnim.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() => _loading = true);
    try {
      final questions = await SukuKataService.getLevelQuestions(widget.level.id);
      questions.shuffle();
      setState(() {
        _questions = questions;
        _sessionQuestions =
            questions.take(min(_maxQuestions, questions.length)).toList();
      });
    } on PremiumLockedException {
      if (!mounted) return;
      await showPremiumUpgradeDialog(
        context,
        featureName: widget.level.title,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil soal: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<String> _optionsFor(SukuKataQuestion question) {
    final random = Random();
    final pool = _questions.map((e) => e.latin).toSet().toList();
    pool.remove(question.latin);
    pool.shuffle(random);

    final options = <String>[question.latin, ...pool.take(2)];
    options.shuffle(random);
    return options;
  }

  Future<void> _checkAnswer(String answer) async {
    if (_lockedAnswer) return;

    final current = _sessionQuestions[_questionIndex];
    final benar = answer.toUpperCase() == current.latin.toUpperCase();

    setState(() {
      _lockedAnswer = true;
      _selectedOption = answer;
      if (benar) {
        _correctCount++;
        _streak++;
        _bestStreak = max(_bestStreak, _streak);
      } else {
        _streak = 0;
      }
    });

    if (benar) {
      correctAnim.forward(from: 0);
    } else {
      wrongAnim.forward(from: 0);
    }

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
                    ? 'Luar biasa! Streak kamu $_streak 🔥'
                    : 'Kurang tepat. Jawaban benar: ${current.latin}',
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

    await Future.delayed(const Duration(milliseconds: 1600));

    if (_questionIndex >= _sessionQuestions.length - 1) {
      await _finishLevel();
      return;
    }

    setState(() {
      _questionIndex++;
      _lockedAnswer = false;
      _selectedOption = null;
    });
  }

  Future<void> _finishLevel() async {
    final total = _sessionQuestions.length;
    final scorePercent = total == 0 ? 0.0 : (_correctCount / total) * 100;
    final xpGain = _correctCount * 5;

    try {
      await SukuKataService.submitLevelScore(
        levelId: widget.level.id,
        score: scorePercent,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submit score gagal: $e')),
        );
      }
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _resultDialog(scorePercent, xpGain, total),
    );
  }

  Widget _resultDialog(double score, int xpGain, int total) {
    final passed = score >= _passScore;
    final scoreInt = score.round();
    final scoreColor = passed ? AppColors.accent : Colors.redAccent;
    final label = passed ? 'Lolos!' : 'Perlu Latihan';
    final emoji = passed ? '🎉' : '⚠️';

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$emoji  $label',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: scoreColor,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 12,
                      strokeCap: StrokeCap.round,
                      backgroundColor: AppColors.scaffold,
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$scoreInt',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: scoreColor,
                        ),
                      ),
                      Text(
                        'SKOR',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPlaceholder,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Benar: $_correctCount dari $total • +$xpGain XP',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              passed
                  ? 'Selamat! Level berikutnya telah terbuka.'
                  : 'Butuh minimal ${_passScore.toInt()}% untuk membuka level berikutnya.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: scoreColor,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String label) {
    final current = _sessionQuestions[_questionIndex];
    final isCorrect = label.toUpperCase() == current.latin.toUpperCase();
    final isSelected = _selectedOption == label;

    Color bg = Colors.white;
    Color border = AppColors.border;
    Color text = AppColors.textPrimary;
    IconData? icon;

    if (_lockedAnswer) {
      if (isCorrect) {
        bg = AppColors.accent.withOpacity(0.1);
        border = AppColors.accent;
        text = AppColors.accent;
        icon = Icons.check_circle_rounded;
      } else if (isSelected) {
        bg = Colors.redAccent.withOpacity(0.1);
        border = Colors.redAccent;
        text = Colors.redAccent;
        icon = Icons.cancel_rounded;
      } else {
        bg = AppColors.scaffold;
        border = AppColors.border.withOpacity(0.5);
        text = AppColors.textPlaceholder;
      }
    } else if (isSelected) {
      border = AppColors.accent;
    }

    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(
          parent: isSelected && _lockedAnswer && isCorrect ? correctAnim : (isSelected && _lockedAnswer && !isCorrect ? wrongAnim : AlwaysStoppedAnimation(0)),
          curve: Curves.easeOutBack,
        ),
      ),
      child: GestureDetector(
        onTap: () => _checkAnswer(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: border,
              width: isSelected || (_lockedAnswer && isCorrect) ? 2 : 1,
            ),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: text,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 12),
                Icon(icon, color: text, size: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.scaffold,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_sessionQuestions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: CustomGradientAppBar(title: widget.level.title),
        body: Center(
          child: Text(
            'Belum ada soal untuk level ini.',
            style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final current = _sessionQuestions[_questionIndex];
    final options = _optionsFor(current);
    final progress = (_questionIndex + 1) / _sessionQuestions.length;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CustomGradientAppBar(title: widget.level.title),
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
                        'Soal ${_questionIndex + 1} dari ${_sessionQuestions.length}',
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.medium,
                border: Border.all(
                  color: _lockedAnswer
                      ? (_selectedOption?.toUpperCase() == current.latin.toUpperCase() ? AppColors.accent : Colors.redAccent).withOpacity(0.3)
                      : AppColors.border.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  current.arabic,
                  style: GoogleFonts.amiri(
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                    color: _lockedAnswer
                        ? (_selectedOption?.toUpperCase() == current.latin.toUpperCase() ? AppColors.accent : Colors.redAccent)
                        : AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Pilih bacaan latin yang tepat",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ...options.map((opt) => _buildOption(opt)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
