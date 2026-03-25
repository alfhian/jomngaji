import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jomngaji/models/evaluation_result.dart';
import 'package:jomngaji/services/evaluation_api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/widgets/custom_gradient_appbar.dart';

class MakhrajLetter {
  final String huruf;
  final String nama;

  const MakhrajLetter({
    required this.huruf,
    required this.nama,
  });
}

class MakhrajCategoryPracticePage extends StatefulWidget {
  final String title;
  final String info;
  final Color primaryColor;
  final List<MakhrajLetter> letters;

  const MakhrajCategoryPracticePage({
    super.key,
    required this.title,
    required this.info,
    required this.primaryColor,
    required this.letters,
  });

  @override
  State<MakhrajCategoryPracticePage> createState() =>
      _MakhrajCategoryPracticePageState();
}

class _MakhrajCategoryPracticePageState extends State<MakhrajCategoryPracticePage> {
  static const int _makhrajLessonId = 999;

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  late final EvaluationApi _api;

  bool _recorderReady = false;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isEvaluating = false;

  int _currentIndex = 0;
  late List<String?> _recordedPaths;

  @override
  void initState() {
    super.initState();
    _api = EvaluationApi(ApiConfig.baseUrl);
    _recordedPaths = List<String?>.filled(widget.letters.length, null);
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await Permission.storage.request();

    if (!await Permission.microphone.isGranted) return;

    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
    await _player.openPlayer();

    if (mounted) {
      setState(() => _recorderReady = true);
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    _api.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (!_recorderReady || _isRecording) return;

    if (_player.isPlaying) await _player.stopPlayer();

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/makhraj_${widget.title}_${_currentIndex}_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.aacADTS,
      sampleRate: 16000,
      numChannels: 1,
      bitRate: 16000,
    );

    setState(() {
      _isRecording = true;
      _recordedPaths[_currentIndex] = path;
    });
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    final path = await _recorder.stopRecorder();
    setState(() => _isRecording = false);
    if (path != null) _recordedPaths[_currentIndex] = path;
  }

  Future<void> _playRecorded() async {
    final path = _recordedPaths[_currentIndex];
    if (path == null) return;

    if (!File(path).existsSync()) return;

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

    final path = _recordedPaths[_currentIndex];
    if (path == null || path.isEmpty) {
      _showSnack('Silakan rekam suara terlebih dahulu.');
      return;
    }

    setState(() => _isEvaluating = true);
    try {
      final target = widget.letters[_currentIndex].huruf;

      final json = await _api.evaluateAudio(
        audioPath: path,
        targetText: target,
        lessonId: _makhrajLessonId,
      );

      final result = EvaluationResult.fromJson(json);
      await _showScoreDialog(result);
    } catch (e) {
      _showSnack('Gagal evaluasi: $e');
    } finally {
      if (mounted) setState(() => _isEvaluating = false);
    }
  }

  Future<void> _showScoreDialog(EvaluationResult r) async {
    final score = r.score.clamp(0, 100);
    final passed = score >= 50;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          passed ? 'Lolos ✅' : 'Coba Lagi 💪',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: passed ? Colors.green : Colors.orange,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Skor: $score',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: widget.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              r.feedback.isEmpty
                  ? (passed
                      ? 'Pengucapan sudah baik, lanjut ke huruf berikutnya.'
                      : 'Ulangi lagi dengan pengucapan lebih jelas.')
                  : r.feedback,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (!passed || !mounted) return;

    if (_currentIndex < widget.letters.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _showDoneDialog();
    }
  }

  void _showDoneDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Latihan Selesai 🎉',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Semua huruf di kategori ${widget.title} sudah dievaluasi dan tersimpan.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: widget.primaryColor),
            child: Text(
              'Kembali',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.letters[_currentIndex];

    return Scaffold(
      appBar: CustomGradientAppBar(title: widget.title),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: widget.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              widget.info,
              style: GoogleFonts.poppins(fontSize: 13, height: 1.35),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(widget.letters.length, (i) {
              final active = i == _currentIndex;
              return ChoiceChip(
                selected: active,
                onSelected: (_) => setState(() => _currentIndex = i),
                selectedColor: widget.primaryColor.withOpacity(0.24),
                label: Text(widget.letters[i].nama),
              );
            }),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Column(
              children: [
                Text(
                  current.huruf,
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: widget.primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  current.nama,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _isRecording ? _stopRecording : _startRecording,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isRecording ? Colors.red : widget.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: Icon(_isRecording ? Icons.stop : Icons.mic),
            label: Text(
              _isRecording ? 'Stop Rekam' : 'Mulai Rekam',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isPlaying ? null : _playRecorded,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text('Putar', style: GoogleFonts.poppins()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isEvaluating ? null : _evaluate,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F9E6E),
                    foregroundColor: Colors.white,
                  ),
                  label: Text(
                    _isEvaluating ? 'Menilai...' : 'Nilai',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Semua evaluasi kategori ini disimpan ke lesson_id 999.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
