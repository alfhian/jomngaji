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
      _feedback = isCorrect ? '✅ Benar' : '❌ Salah. Jawaban: $correct';
      if (isCorrect) _mcqCorrect++;
    });

    await Future<void>.delayed(const Duration(milliseconds: 850));
    _goNext();
  }

  Future<void> _startRecording() async {
    if (!_recorderReady || _isRecording) return;

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/exam_iqra_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.aacADTS,
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

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'result',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (_, anim, __, ___) {
        final v = Curves.easeOutBack.transform(anim.value);
        return Opacity(
          opacity: v,
          child: Transform.scale(
            scale: v,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isGreat)
                  ConfettiWidget(
                    confettiController: _resultConfetti,
                    blastDirection: -3.14 / 2,
                    numberOfParticles: 16,
                    gravity: 0.3,
                  ),
                Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isGreat ? 'MasyaAllah! Nilai Bagus 🌟' : 'Tes Akhir Selesai ✅',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            color: isGreat ? const Color(0xFF2F9E6E) : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Pilihan ganda benar: $_mcqCorrect/5\n'
                          'Pengucapan lolos: $_pronunciationPassed/5\n'
                          'Final score: ${finalScore.toStringAsFixed(1)}%',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF42C88A),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Kembali'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      appBar: const CustomGradientAppBar(title: 'Tes Akhir Iqra'),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/ujian-mengaji.png',
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomCenter,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.88),
                    Colors.white.withOpacity(0.82),
                    Colors.white.withOpacity(0.72),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF42C88A),
                        backgroundColor: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Soal ${_currentIndex + 1}/${_questions.length} • ${_q.type == _ExamType.mcq ? 'Pilihan Ganda' : 'Pengucapan'}',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _q.prompt,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _q.arabic,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 42,
                          color: Color(0xFF42C88A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: _feedback.isEmpty ? 0 : 1,
                  child: Text(
                    _feedback,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: _feedback.contains('✅') ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _q.type == _ExamType.mcq ? _buildMcqOptions() : _buildPronunciationPanel(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMcqOptions() {
    return ListView.separated(
      itemCount: _q.options.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final opt = _q.options[i];
        final selected = _selectedOption == opt;

        return GestureDetector(
          onTap: () => _answerMcq(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFE7FFF2) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? const Color(0xFF42C88A) : Colors.grey.shade300,
              ),
            ),
            child: Center(
              child: Text(
                opt,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2F9E6E),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPronunciationPanel() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _isRecording ? _stopRecording : _startRecording,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isRecording ? Colors.red : const Color(0xFF42C88A),
            foregroundColor: Colors.white,
          ),
          icon: Icon(_isRecording ? Icons.stop : Icons.mic),
          label: Text(_isRecording ? 'Stop Rekam' : 'Mulai Rekam'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isPlaying ? null : _playRecorded,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Putar'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isEvaluating ? null : _evaluatePronunciation,
                icon: const Icon(Icons.auto_awesome),
                label: Text(_isEvaluating ? 'Menilai...' : 'Nilai'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _pronunciationDone ? _goNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2F9E6E),
              foregroundColor: Colors.white,
            ),
            child: const Text('Lanjut'),
          ),
        ),
      ],
    );
  }
}
