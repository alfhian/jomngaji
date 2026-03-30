import 'dart:convert';
import 'dart:io';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:jomngaji/models/evaluation_result.dart';
import 'package:jomngaji/services/evaluation_api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/config/api_config.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../../../core/widgets/custom_gradient_appbar.dart';
import '../../../features/auth/services/auth_service.dart';
import '../../../services/progress_service.dart';

class ExamIqraPage extends StatefulWidget {
  const ExamIqraPage({super.key});

  @override
  State<ExamIqraPage> createState() => _ExamIqraPageState();
}

enum _ExamType { mcq, pronunciation }

class _ExamQuestion {
  final _ExamType type;
  final String prompt;
  final String arabic;
  final List<String> options;
  final String correct;
  final String? targetPronunciation;

  const _ExamQuestion.mcq({
    required this.prompt,
    required this.arabic,
    required this.options,
    required this.correct,
  })  : type = _ExamType.mcq,
        targetPronunciation = null;

  const _ExamQuestion.pronunciation({
    required this.prompt,
    required this.arabic,
    required this.targetPronunciation,
  })  : type = _ExamType.pronunciation,
        options = const [],
        correct = '';
}

class _ExamIqraPageState extends State<ExamIqraPage> {
  static String get _baseUrl => ApiConfig.baseUrl;

  final List<_ExamQuestion> _questions = const [
    _ExamQuestion.mcq(
      prompt: 'Pilih bacaan yang benar',
      arabic: 'بَ',
      options: ['BA', 'BI', 'BU'],
      correct: 'BA',
    ),
    _ExamQuestion.pronunciation(
      prompt: 'Latihan pengucapan',
      arabic: 'تَ',
      targetPronunciation: 'ت',
    ),
    _ExamQuestion.mcq(
      prompt: 'Pilih bacaan yang benar',
      arabic: 'قُلْ هُوَ اللّٰهُ أَحَدٌ',
      options: ['Qul huwallahu ahad', 'Qala huwallahu ahad', 'Qul huwa lahu ahad'],
      correct: 'Qul huwallahu ahad',
    ),
    _ExamQuestion.pronunciation(
      prompt: 'Latihan pengucapan',
      arabic: 'ح',
      targetPronunciation: 'ح',
    ),
    _ExamQuestion.mcq(
      prompt: 'Pilih bacaan yang benar',
      arabic: 'فِي',
      options: ['FII', 'FAA', 'FUU'],
      correct: 'FII',
    ),
    _ExamQuestion.pronunciation(
      prompt: 'Latihan pengucapan',
      arabic: 'غ',
      targetPronunciation: 'غ',
    ),
    _ExamQuestion.mcq(
      prompt: 'Pilih bacaan yang benar',
      arabic: 'مُحَمَّد',
      options: ['MUHAMMAD', 'MIHAMMAD', 'MUHIMID'],
      correct: 'MUHAMMAD',
    ),
    _ExamQuestion.pronunciation(
      prompt: 'Latihan pengucapan',
      arabic: 'ض',
      targetPronunciation: 'ض',
    ),
    _ExamQuestion.mcq(
      prompt: 'Pilih bacaan yang benar',
      arabic: 'قَلْبٍ',
      options: ['QALBIN', 'QALBAN', 'QULBIN'],
      correct: 'QALBIN',
    ),
    _ExamQuestion.pronunciation(
      prompt: 'Latihan pengucapan',
      arabic: 'ن',
      targetPronunciation: 'ن',
    ),
  ];

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  late final EvaluationApi _api;
  late ConfettiController _resultConfetti;

  int _currentIndex = 0;
  int _mcqCorrect = 0;
  int _pronunciationPassed = 0;
  final List<double> _recordingScores = [];

  bool _answerLocked = false;
  String? _selectedOption;
  String _feedback = '';

  bool _recorderReady = false;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isEvaluating = false;
  String? _recordedPath;
  bool _pronunciationDone = false;

  @override
  void initState() {
    super.initState();
    _api = EvaluationApi(_baseUrl);
    _resultConfetti = ConfettiController(duration: const Duration(milliseconds: 900));
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await Permission.storage.request();

    if (!await Permission.microphone.isGranted) return;

    await _recorder.openRecorder();
    await _player.openPlayer();

    if (mounted) setState(() => _recorderReady = true);
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    _api.dispose();
    _resultConfetti.dispose();
    super.dispose();
  }

  _ExamQuestion get _q => _questions[_currentIndex];

  Future<void> _answerMcq(String selected) async {
    if (_answerLocked) return;

    final correct = _q.correct;
    final isCorrect = selected == correct;

    setState(() {
      _answerLocked = true;
      _selectedOption = selected;
      _feedback = isCorrect ? 'Luar biasa! ✅' : 'Kurang tepat. Jawaban: $correct ❌';
      if (isCorrect) _mcqCorrect++;
    });

    await Future<void>.delayed(const Duration(milliseconds: 1500));
    _goNext();
  }

  Future<void> _startRecording() async {
    if (!_recorderReady || _isRecording) return;

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/exam_iqra_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.pcm16WAV,
      sampleRate: 16000,
      numChannels: 1,
      bitRate: 16000,
    );

    setState(() {
      _isRecording = true;
      _recordedPath = path;
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    final path = await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
      if (path != null) _recordedPath = path;
    });
  }

  Future<void> _playRecorded() async {
    if (_recordedPath == null || _isPlaying) return;
    if (!File(_recordedPath!).existsSync()) return;

    setState(() => _isPlaying = true);
    await _player.startPlayer(
      fromURI: _recordedPath,
      whenFinished: () {
        if (mounted) setState(() => _isPlaying = false);
      },
    );
  }

  Future<void> _evaluatePronunciation() async {
    if (_isEvaluating) return;
    if (_recordedPath == null) {
      _showSnack('Rekam suara dulu sebelum dinilai.');
      return;
    }

    setState(() => _isEvaluating = true);
    try {
      final json = await _api.evaluateAudio(
        audioPath: _recordedPath!,
        targetText: _q.targetPronunciation!,
        lessonId: 999,
      );
      final result = EvaluationResult.fromJson(json);
      final score = result.score.clamp(0, 100);

      _recordingScores.add(score.toDouble());
      if (score >= 50) _pronunciationPassed++;

      setState(() {
        _pronunciationDone = true;
        _feedback = 'Skor pengucapan: $score';
      });
    } catch (e) {
      _showSnack('Gagal evaluasi pengucapan: $e');
    } finally {
      if (mounted) setState(() => _isEvaluating = false);
    }
  }

  Future<void> _goNext() async {
    if (!mounted) return;

    if (_currentIndex >= _questions.length - 1) {
      await _finishExam();
      return;
    }

    setState(() {
      _currentIndex++;
      _answerLocked = false;
      _selectedOption = null;
      _feedback = '';
      _recordedPath = null;
      _pronunciationDone = false;
    });
  }

  Future<void> _finishExam() async {
    final totalQuestions = _questions.length;
    final totalCorrect = _mcqCorrect + _pronunciationPassed;
    final finalScore = (totalCorrect / totalQuestions) * 100;

    try {
      await _submitIqraExam(
        totalQuestions: totalQuestions,
        correctAnswers: totalCorrect,
        recordingScores: _recordingScores,
      );
    } catch (e) {
      _showSnack('Gagal submit exam ke server: $e');
    }

    await ProgressService.saveExamScore(totalCorrect);
    await ProgressService.saveXP(totalCorrect * 10);

    if (!mounted) return;

    final isGreat = finalScore >= 80;
    if (isGreat) {
      _resultConfetti.play();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              if (isGreat)
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _resultConfetti,
                    blastDirection: -3.14 / 2,
                    numberOfParticles: 16,
                    gravity: 0.3,
                    colors: const [AppColors.accent, AppColors.secondary, AppColors.gold],
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (isGreat ? AppColors.accent : AppColors.primary).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isGreat ? Icons.emoji_events_rounded : Icons.assignment_turned_in_rounded,
                  color: isGreat ? AppColors.accent : AppColors.primary,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isGreat ? 'MasyaAllah! Bagus 🌟' : 'Evaluasi Selesai! ✅',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Pilihan Ganda: $_mcqCorrect/5\n'
                'Pengucapan: $_pronunciationPassed/5',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${finalScore.toStringAsFixed(0)}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: isGreat ? AppColors.accent : AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Kembali ke Menu'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitIqraExam({
    required int totalQuestions,
    required int correctAnswers,
    required List<double> recordingScores,
  }) async {
    final headers = await AuthService.authHeaders(
      extra: {'Content-Type': 'application/json'},
    );

    final res = await http.post(
      Uri.parse('$_baseUrl/iqra-exam/submit'),
      headers: headers,
      body: jsonEncode({
        'total_questions': totalQuestions,
        'correct_answers': correctAnswers,
        'recording_scores': recordingScores,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('[${res.statusCode}] ${res.body}');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: const CustomGradientAppBar(title: 'Evaluasi Iqra'),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/ujian-mengaji.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          SingleChildScrollView(
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
                            'Exam Iqra',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'Pilihan & Praktek',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPlaceholder,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Soal ${_currentIndex + 1} dari ${_questions.length}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPlaceholder,
                          ),
                        ),
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: AppShadows.medium,
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Image.asset(
                          'assets/images/ujian-mengaji.png',
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _q.prompt,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _q.arabic,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.amiri(
                          fontSize: 48,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (_feedback.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      color: (_feedback.contains('✅') || _feedback.contains('Luar')) ? AppColors.accent.withOpacity(0.1) : Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      _feedback,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: (_feedback.contains('✅') || _feedback.contains('Luar')) ? AppColors.accent : Colors.redAccent,
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                _q.type == _ExamType.mcq ? _buildMcqOptions() : _buildPronunciationPanel(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMcqOptions() {
    return Column(
      children: _q.options.map((opt) {
        final selected = _selectedOption == opt;
        final isCorrect = opt == _q.correct;
        
        Color bg = Colors.white;
        Color border = AppColors.border;
        Color text = AppColors.textPrimary;

        if (_answerLocked) {
          if (isCorrect) {
            bg = AppColors.accent.withOpacity(0.1);
            border = AppColors.accent;
            text = AppColors.accent;
          } else if (selected) {
            bg = Colors.redAccent.withOpacity(0.1);
            border = Colors.redAccent;
            text = Colors.redAccent;
          } else {
            bg = AppColors.scaffold;
            text = AppColors.textPlaceholder;
          }
        } else if (selected) {
          border = AppColors.accent;
        }

        return GestureDetector(
          onTap: () => _answerMcq(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: border,
                width: selected || (_answerLocked && isCorrect) ? 2 : 1,
              ),
              boxShadow: AppShadows.soft,
            ),
            child: Center(
              child: Text(
                opt,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: text,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPronunciationPanel() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isRecording ? _stopRecording : _startRecording,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isRecording ? Colors.redAccent : AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            icon: Icon(_isRecording ? Icons.stop_rounded : Icons.mic_rounded, size: 24),
            label: Text(_isRecording ? 'Berhenti Merekam' : 'Mulai Rekam Suara'),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isPlaying || _recordedPath == null ? null : _playRecorded,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 24),
                label: const Text('Putar'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isEvaluating ? null : _evaluatePronunciation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.auto_awesome_rounded, size: 24),
                label: Text(_isEvaluating ? 'Menilai...' : 'Nilai'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        if (_pronunciationDone)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _goNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: const Text('Lanjut ke Soal Berikutnya'),
            ),
          ),
      ],
    );
  }
}
