import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jomngaji/models/evaluation_result.dart';
import 'package:jomngaji/services/evaluation_api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/theme/app_design_tokens.dart';
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
        '${dir.path}/makhraj_${widget.title}_${_currentIndex}_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.pcm16WAV,
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
    final scoreColor = passed ? AppColors.accent : Colors.orange;

    await showDialog(
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
                color: scoreColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                passed ? Icons.check_circle_rounded : Icons.replay_circle_filled_rounded,
                color: scoreColor,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              passed ? 'Lolos! ✨' : 'Coba Lagi 💪',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Skor Pengucapan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$score',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: scoreColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              r.feedback.isEmpty
                  ? (passed
                      ? 'Pengucapan sudah baik, lanjut ke huruf berikutnya.'
                      : 'Ulangi lagi dengan pengucapan lebih jelas.')
                  : r.feedback,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: scoreColor,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
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
              'Latihan Selesai! 🎉',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Semua huruf di kategori ${widget.title} sudah dievaluasi dengan baik.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
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
      ),
    );
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
    final current = widget.letters[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CustomGradientAppBar(title: widget.title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_rounded, color: AppColors.primary, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.info,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Pilih Huruf",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(widget.letters.length, (i) {
                final active = i == _currentIndex;
                return ChoiceChip(
                  selected: active,
                  onSelected: (_) => setState(() => _currentIndex = i),
                  selectedColor: AppColors.accent,
                  backgroundColor: Colors.white,
                  checkmarkColor: Colors.white,
                  labelStyle: GoogleFonts.plusJakartaSans(
                    color: active ? Colors.white : AppColors.textSecondary,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    side: BorderSide(
                      color: active ? AppColors.accent : AppColors.border,
                    ),
                  ),
                  label: Text(widget.letters[i].nama),
                );
              }),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.medium,
                border: Border.all(color: AppColors.border.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Text(
                    current.huruf,
                    style: GoogleFonts.amiri(
                      fontSize: 100,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    current.nama,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isRecording ? _stopRecording : _startRecording,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRecording ? Colors.redAccent : AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                icon: Icon(_isRecording ? Icons.stop_rounded : Icons.mic_rounded, size: 24),
                label: Text(
                  _isRecording ? 'Berhenti Merekam' : 'Mulai Rekam Suara',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isPlaying || _recordedPaths[_currentIndex] == null ? null : _playRecorded,
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
                    onPressed: _isEvaluating ? null : _evaluate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.auto_awesome_rounded, size: 24),
                    label: Text(
                      _isEvaluating ? 'Menilai...' : 'Nilai',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Latihan ini akan membantu akurasi pengucapanmu.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textPlaceholder,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
