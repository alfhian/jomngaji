import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jomngaji/models/evaluation_result.dart';
import 'package:jomngaji/services/evaluation_api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/widgets/custom_gradient_appbar.dart';
import '../../../auth/services/auth_service.dart';
import 'tajwid_best_score_badge.dart';

class RecordingPrompt {
  final String arabicText;
  final String tip;

  const RecordingPrompt({required this.arabicText, required this.tip});
}

class TajwidRecordingPracticePage extends StatefulWidget {
  final String title;
  final String quizCode;
  final Color accent;
  final String intro;
  final List<RecordingPrompt> prompts;

  const TajwidRecordingPracticePage({
    super.key,
    required this.title,
    required this.quizCode,
    required this.accent,
    required this.intro,
    required this.prompts,
  });

  @override
  State<TajwidRecordingPracticePage> createState() =>
      _TajwidRecordingPracticePageState();
}

class _TajwidRecordingPracticePageState extends State<TajwidRecordingPracticePage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  late final EvaluationApi _api;

  bool _recorderReady = false;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isEvaluating = false;

  int _index = 0;
  String _feedback = '';
  late List<String?> _recordedPaths;
  int? _lessonId;

  static const Map<String, int> _fallbackLessonMap = {
    'nun_tanwin': 1,
    'mim_mati': 2,
    'mad': 3,
    'qalqalah': 4,
    'ghunnah': 5,
    'ikhfa': 6,
  };

  @override
  void initState() {
    super.initState();
    _api = EvaluationApi(AuthService.baseUrl);
    _recordedPaths = List<String?>.filled(widget.prompts.length, null);
    _initRecorder();
    _resolveLessonId();
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await Permission.storage.request();

    if (!await Permission.microphone.isGranted) return;

    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
    await _player.openPlayer();

    if (mounted) setState(() => _recorderReady = true);
  }

  Future<void> _resolveLessonId() async {
    if (!mounted) return;
    setState(() => _lessonId = _fallbackLessonMap[widget.quizCode]);
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (!_recorderReady || _isRecording) return;
    if (_player.isPlaying) await _player.stopPlayer();

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/tajwid_${widget.quizCode}_${_index}_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.aacADTS,
      sampleRate: 16000,
      numChannels: 1,
      bitRate: 16000,
    );

    setState(() {
      _isRecording = true;
      _feedback = 'Sedang merekam...';
      _recordedPaths[_index] = path;
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    final path = await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
      if (path != null) _recordedPaths[_index] = path;
      _feedback = 'Rekaman selesai. Siap diputar & dinilai.';
    });
  }

  Future<void> _playRecorded() async {
    final path = _recordedPaths[_index];
    if (path == null) return;
    final file = File(path);
    if (!file.existsSync()) return;

    setState(() => _isPlaying = true);
    await _player.startPlayer(
      fromURI: path,
      whenFinished: () {
        if (mounted) setState(() => _isPlaying = false);
      },
    );
  }

  Future<void> _evaluate() async {
    if (_isEvaluating) return;

    final path = _recordedPaths[_index];
    if (path == null || path.isEmpty) {
      _showError('Silakan rekam suara terlebih dahulu');
      return;
    }

    final lessonId = _lessonId;
    if (lessonId == null) {
      _showError('Lesson ID belum tersedia. Coba buka ulang halaman.');
      return;
    }

    setState(() => _isEvaluating = true);
    try {
      final prompt = widget.prompts[_index];
      final json = await _api.evaluateTajwid(
        audioPath: path,
        targetText: prompt.arabicText,
        lessonId: lessonId,
      );

      final result = EvaluationResult.fromJson(json);
      await _showScoreDialog(result);
    } catch (e) {
      _showError('Gagal evaluasi: $e');
    } finally {
      if (mounted) setState(() => _isEvaluating = false);
    }
  }

  Future<void> _showScoreDialog(EvaluationResult result) async {
    final score = result.score.clamp(0, 100);
    late final Color scoreColor;
    late final String label;
    late final String emoji;

    if (score >= 90) {
      scoreColor = const Color(0xFF42C88A);
      label = 'MasyaAllah!';
      emoji = '🌟';
    } else if (score >= 75) {
      scoreColor = const Color(0xFF5FB3F3);
      label = 'Bagus!';
      emoji = '👍';
    } else if (score >= 50) {
      scoreColor = Colors.orange;
      label = 'Cukup Baik';
      emoji = '🙂';
    } else {
      scoreColor = Colors.redAccent;
      label = 'Perlu Latihan';
      emoji = '⚠️';
    }

    SystemSound.play(SystemSoundType.alert);

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'score',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(blurRadius: 30, color: Colors.black26),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$emoji  $label',
                    style: GoogleFonts.poppins(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: scoreColor,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: score / 100,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$score',
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: scoreColor,
                              ),
                            ),
                            Text(
                              'Skor',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    result.feedback,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scoreColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Tutup',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim.value),
          child: Opacity(opacity: anim.value, child: child),
        );
      },
    );
  }

  void _nextPrompt() {
    if (_index >= widget.prompts.length - 1) return;
    setState(() {
      _index++;
      _isRecording = false;
      _isPlaying = false;
      _feedback = '';
    });
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
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
      case 'ikhfa':
        return {'ن', 'ً', 'ٍ', 'ٌ'};
      default:
        return {};
    }
  }

  Widget _buildHighlightedPrompt(String text) {
    final highlights = _highlightCharsForCode(widget.quizCode);
    final spans = text.split('').map((char) {
      final highlighted = highlights.contains(char);
      return TextSpan(
        text: char,
        style: TextStyle(
          color: highlighted ? const Color(0xFF42C88A) : const Color(0xFF1F2937),
          fontWeight: highlighted ? FontWeight.w800 : FontWeight.w700,
        ),
      );
    }).toList();

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, height: 1.25),
        children: spans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prompt = widget.prompts[_index];
    final hasAudio = _recordedPaths[_index] != null;

    return Scaffold(
      appBar: CustomGradientAppBar(title: widget.title),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F9FF), Color(0xFFEFF7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [widget.accent.withOpacity(0.18), widget.accent.withOpacity(0.08)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.intro,
                    style: GoogleFonts.poppins(fontSize: 13, height: 1.45),
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  TajwidBestScoreBadge(
                    quizCode: widget.quizCode,
                    label: 'Best Score Praktek',
                    source: TajwidBestScoreSource.recording,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (_index + 1) / widget.prompts.length,
              minHeight: 8,
              borderRadius: BorderRadius.circular(99),
              backgroundColor: const Color(0xFFE2E8F0),
              color: widget.accent,
            ),
            const SizedBox(height: 8),
            Text(
              'Latihan ${_index + 1}/${widget.prompts.length}',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 12)],
              ),
              child: _buildHighlightedPrompt(prompt.arabicText),
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _isRecording ? _stopRecording : _startRecording,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: _isRecording ? Colors.red : widget.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                _isRecording ? 'Sedang merekam...' : 'Tap untuk rekam',
                style: GoogleFonts.poppins(),
              ),
            ),
            const SizedBox(height: 14),
            if (hasAudio) ...[
              FilledButton.icon(
                onPressed: _isPlaying ? null : _playRecorded,
                icon: Icon(_isPlaying ? Icons.graphic_eq_rounded : Icons.play_arrow_rounded),
                label: Text(_isPlaying ? 'Memutar...' : 'Putar Rekaman'),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _isEvaluating ? null : _evaluate,
                icon: _isEvaluating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                style: FilledButton.styleFrom(backgroundColor: widget.accent),
                label: Text(_isEvaluating ? 'Menilai...' : 'Nilai Pengucapan'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _nextPrompt,
                icon: const Icon(Icons.navigate_next_rounded),
                label: const Text('Soal Berikutnya'),
              ),
            ],
            if (_feedback.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(_feedback, style: GoogleFonts.poppins(fontSize: 12.5)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
