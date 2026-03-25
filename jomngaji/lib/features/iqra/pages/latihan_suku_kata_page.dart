import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          duration: const Duration(milliseconds: 850),
          backgroundColor: benar ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
          content: Text(
            benar
                ? '✅ Benar! Streak kamu $_streak'
                : '❌ Salah. Jawaban benar: ${current.latin}',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      );

    await Future.delayed(const Duration(milliseconds: 720));

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
    final scoreColor = passed ? const Color(0xFF42C88A) : Colors.redAccent;
    final label = passed ? 'Lolos' : 'Perlu Latihan';
    final emoji = passed ? '🎉' : '⚠️';

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$emoji  $label',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: scoreColor,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 126,
              height: 126,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 108,
                    height: 108,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$scoreInt',
                        style: GoogleFonts.poppins(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: scoreColor,
                        ),
                      ),
                      Text(
                        'Skor',
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Benar: $_correctCount dari $total • +$xpGain XP',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              passed
                  ? 'Level berikutnya otomatis terbuka ✅'
                  : 'Butuh minimal ${_passScore.toInt()}% untuk membuka level berikutnya.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: scoreColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'Tutup',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
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

    Color bg = const Color(0xFFE8FFF0);
    Color border = const Color(0xFF50D1A0);
    Color text = const Color(0xFF42C88A);
    IconData? icon;

    if (_lockedAnswer) {
      if (isCorrect) {
        bg = const Color(0xFFD9F8E5);
        border = const Color(0xFF1E915B);
        text = const Color(0xFF1E915B);
        icon = Icons.check_circle_rounded;
      } else if (isSelected) {
        bg = const Color(0xFFFFE2E2);
        border = const Color(0xFFD84343);
        text = const Color(0xFFD84343);
        icon = Icons.cancel_rounded;
      } else {
        bg = Colors.white.withOpacity(0.75);
        border = Colors.grey.shade300;
        text = Colors.grey.shade600;
      }
    }

    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(
          parent: isSelected && _lockedAnswer && isCorrect ? correctAnim : wrongAnim,
          curve: Curves.easeOutBack,
        ),
      ),
      child: GestureDetector(
        onTap: () => _checkAnswer(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: text,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, color: text, size: 20),
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_sessionQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.level.title, style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFF50D1A0),
        ),
        body: Center(
          child: Text(
            'Belum ada soal untuk level ini.',
            style: GoogleFonts.poppins(fontSize: 15),
          ),
        ),
      );
    }

    final current = _sessionQuestions[_questionIndex];
    final options = _optionsFor(current);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.level.title, style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF50D1A0),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_questionIndex + 1) / _sessionQuestions.length,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF42C88A),
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${_questionIndex + 1}/${_sessionQuestions.length}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Streak: $_streak 🔥',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2F9E6E),
                  ),
                ),
                Text(
                  'Best: $_bestStreak',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36),
              decoration: BoxDecoration(
                color: const Color(0xFFF1FFF6),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.06),
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Center(
                child: Text(
                  current.arabic,
                  style: const TextStyle(
                    fontSize: 90,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF42C88A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/background-mengaji.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white.withOpacity(0.82),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Pilih bacaan latin yang tepat',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...options
                          .map((opt) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildOption(opt),
                              ))
                          .toList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
