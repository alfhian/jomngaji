import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../services/tajwid_quiz_service.dart';

class TajwidMcqQuizPage extends StatefulWidget {
  final String title;
  final String quizCode;
  final Color accent;
  final String intro;

  const TajwidMcqQuizPage({
    super.key,
    required this.title,
    required this.quizCode,
    required this.accent,
    required this.intro,
  });

  @override
  State<TajwidMcqQuizPage> createState() => _TajwidMcqQuizPageState();
}

class _TajwidMcqQuizPageState extends State<TajwidMcqQuizPage>
    with TickerProviderStateMixin {
  static const int _maxQuestions = 5;
  static const double _passScore = 60;

  bool _loading = true;
  String? _error;

  List<TajwidQuizQuestion> _sessionQuestions = [];

  int _questionIndex = 0;
  int _correctCount = 0;
  int _streak = 0;
  int _bestStreak = 0;
  double? _bestScorePercent;

  String? _selectedOption;
  bool? _selectedWasCorrect;
  bool _lockedAnswer = false;

  final List<Map<String, dynamic>> _answers = [];
  int? _serverCorrect;
  int? _serverTotal;

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

  String _norm(String text) => text.trim().toLowerCase();

  Future<void> _loadQuestions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final payload = await TajwidQuizService.fetchQuestions(widget.quizCode);
      final questions = payload.questions
          .map((q) {
            final opts = [...q.options]..shuffle();
            return TajwidQuizQuestion(
              id: q.id,
              questionText: q.questionText,
              options: opts,
              correctAnswer: q.correctAnswer,
            );
          })
          .toList()
        ..shuffle();

      if (!mounted) return;
      setState(() {
        _sessionQuestions =
            questions.take(min(_maxQuestions, questions.length)).toList();
      });

      try {
        final progress = await TajwidQuizService.getQuizProgress(widget.quizCode);
        final best = _extractBestScore(progress);
        if (!mounted) return;
        setState(() => _bestScorePercent = best);
      } catch (_) {
        // Optional: progress bisa belum ada attempt.
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Gagal mengambil soal: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isCorrect(TajwidQuizQuestion question, String answer) {
    if (question.correctAnswer.trim().isEmpty) return false;
    return _norm(answer) == _norm(question.correctAnswer);
  }

  double? _extractBestScore(Map<String, dynamic> progress) {
    double? parsePercent(dynamic raw, {bool percentAlready = true}) {
      final value = double.tryParse('${raw ?? ''}');
      if (value == null) return null;
      final normalized = percentAlready ? value : value * 100;
      return normalized.clamp(0, 100).toDouble();
    }

    final bestScore = parsePercent(progress['best_score']);
    if (bestScore != null) return bestScore;

    final highestScore = parsePercent(progress['highest_score']);
    if (highestScore != null) return highestScore;

    final highScore = parsePercent(progress['high_score']);
    if (highScore != null) return highScore;

    final score = parsePercent(progress['score']);
    if (score != null) return score;

    final progressValue = parsePercent(progress['progress'], percentAlready: false);
    return progressValue;
  }

  Future<void> _checkAnswer(String answer) async {
    if (_lockedAnswer) return;

    final current = _sessionQuestions[_questionIndex];
    final hasLocalCorrectAnswer = current.correctAnswer.trim().isNotEmpty;
    final benar = hasLocalCorrectAnswer ? _isCorrect(current, answer) : false;

    setState(() {
      _lockedAnswer = true;
      _selectedOption = answer;
      _selectedWasCorrect = benar;

      if (hasLocalCorrectAnswer) {
        if (benar) {
          _correctCount++;
          _streak++;
          _bestStreak = max(_bestStreak, _streak);
        } else {
          _streak = 0;
        }
      }

      _answers.add({
        'question_id': current.id,
        'selected_option': answer,
      });
    });

    if (hasLocalCorrectAnswer) {
      if (benar) {
        correctAnim.forward(from: 0);
      } else {
        wrongAnim.forward(from: 0);
      }
    }

    final correctText = current.correctAnswer.trim().isNotEmpty
        ? current.correctAnswer
        : '-';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          duration: const Duration(milliseconds: 850),
          backgroundColor: hasLocalCorrectAnswer
              ? (benar ? const Color(0xFF2E7D32) : const Color(0xFFC62828))
              : const Color(0xFF1E88E5),
          content: Text(
            hasLocalCorrectAnswer
                ? (benar ? '✅ Benar! Streak kamu $_streak' : '❌ Salah. Jawaban benar: $correctText')
                : '✅ Jawaban disimpan. Nilai final dihitung saat submit akhir.',
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
      _selectedWasCorrect = null;
    });
  }

  Future<void> _finishLevel() async {
    final total = _sessionQuestions.length;
    final fallbackScorePercent = total == 0 ? 0.0 : (_correctCount / total) * 100;

    try {
      final result = await TajwidQuizService.submitQuiz(
        quizCode: widget.quizCode,
        answers: _answers,
      );
      _serverCorrect = int.tryParse('${result['correct'] ?? ''}');
      _serverTotal = int.tryParse('${result['total'] ?? ''}');
    } catch (_) {}

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _resultDialog(fallbackScorePercent, total),
    );
  }

  Widget _resultDialog(double fallbackScore, int fallbackTotal) {
    final total = _serverTotal ?? fallbackTotal;
    final correct = _serverCorrect ?? _correctCount;
    final score = total == 0 ? fallbackScore : (correct / total) * 100;
    final passed = score >= _passScore;
    final xpGain = correct * 5;
    final scoreInt = score.round();
    final scoreColor = passed ? const Color(0xFF42C88A) : Colors.redAccent;
    final label = passed ? 'Lolos' : 'Perlu Latihan';
    final emoji = passed ? '🎉' : '⚠️';

    _bestScorePercent = max(_bestScorePercent ?? 0, score);

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
              'Benar: $correct dari $total • +$xpGain XP',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              passed
                  ? 'Mantap! Pertahankan performamu ✅'
                  : 'Belum lolos, ayo coba lagi sampai lebih mantap.',
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

  Set<String> _highlightCharsForCode(String code) {
    switch (code) {
      case 'nun_tanwin':
        return {'ن', 'ً', 'ٍ', 'ٌ'};
      case 'mim_mati':
        return {'م', 'ْ'};
      case 'mad':
        return {'ا', 'و', 'ي'};
      case 'qalqalah':
        return {'ق', 'ط', 'ب', 'ج', 'د'};
      case 'ghunnah':
        return {'ن', 'م'};
      default:
        return {};
    }
  }

  Widget _buildArabicQuestion(String text) {
    final isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    if (!isArabic) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 18,
            height: 1.45,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2C2C2C),
          ),
        ),
      );
    }

    final highlights = _highlightCharsForCode(widget.quizCode);
    final spans = text.split('').map((char) {
      final highlighted = highlights.contains(char);
      return TextSpan(
        text: char,
        style: TextStyle(
          color: highlighted ? const Color(0xFF42C88A) : const Color(0xFF2C2C2C),
          fontWeight: highlighted ? FontWeight.w800 : FontWeight.w700,
        ),
      );
    }).toList();

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 66,
          fontWeight: FontWeight.bold,
          height: 1.25,
        ),
        children: spans,
      ),
    );
  }

  Widget _buildOption(String label) {
    final current = _sessionQuestions[_questionIndex];
    final isCorrect = _isCorrect(current, label);
    final isSelected = _selectedOption == label;
    final selectedCorrect = _selectedWasCorrect == true;

    Color bg = const Color(0xFFE8FFF0);
    Color border = const Color(0xFF50D1A0);
    Color text = const Color(0xFF42C88A);
    IconData? icon;

    if (_lockedAnswer) {
      if (isSelected && selectedCorrect) {
        bg = const Color(0xFFD9F8E5);
        border = const Color(0xFF1E915B);
        text = const Color(0xFF1E915B);
        icon = Icons.check_circle_rounded;
      } else if (isCorrect) {
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

    final Animation<double> optionAnimation =
        (isSelected && _lockedAnswer)
            ? (selectedCorrect ? correctAnim : wrongAnim)
            : kAlwaysDismissedAnimation;

    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(
          parent: optionAnimation,
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
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: text,
                  ),
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

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title, style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFF50D1A0),
        ),
        body: Center(
          child: Text(
            _error!,
            style: GoogleFonts.poppins(fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_sessionQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title, style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFF50D1A0),
        ),
        body: Center(
          child: Text(
            'Belum ada soal untuk quiz ini.',
            style: GoogleFonts.poppins(fontSize: 15),
          ),
        ),
      );
    }

    final current = _sessionQuestions[_questionIndex];
    final options = current.options;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: GoogleFonts.poppins()),
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
                  'Best Streak: $_bestStreak',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF8F1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBCE8D1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_rounded, color: Color(0xFF2F9E6E), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Best Score: ${(_bestScorePercent ?? 0).toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2F9E6E),
                    ),
                  ),
                ],
              ),
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
                child: _buildArabicQuestion(current.questionText),
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
                        'Pilih jawaban yang tepat',
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
