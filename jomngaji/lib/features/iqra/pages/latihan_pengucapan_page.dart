import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jomngaji/models/evaluation_result.dart';
import 'package:jomngaji/services/evaluation_api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/config/api_config.dart';
import '../../../core/theme/app_design_tokens.dart';
import '../data/hijaiyah_data.dart';
import '../../../core/widgets/custom_gradient_appbar.dart';
import '../../../services/hijaiyah_service.dart';

class LatihanPengucapanPage extends StatefulWidget {
  final int lessonId;
  final String lessonTitle;
  final List<HijaiyahData> hurufList;

  const LatihanPengucapanPage({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
    required this.hurufList,
  });

  @override
  State<LatihanPengucapanPage> createState() =>
      _LatihanPengucapanPageState();
}

class _LatihanPengucapanPageState extends State<LatihanPengucapanPage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  bool _recorderReady = false;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isEvaluating = false;

  int _currentIndex = 0;
  late List<String?> _recordedPaths;

  late final EvaluationApi _api;

  @override
  void initState() {
    super.initState();
    _api = EvaluationApi(ApiConfig.baseUrl);
    _recordedPaths = List<String?>.filled(widget.hurufList.length, null);
    _initRecorder();
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

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    _api.dispose();
    super.dispose();
  }

  // ----------------- RECORD -----------------
  Future<void> _startRecording() async {
    if (!_recorderReady || _isRecording) return;

    if (_player.isPlaying) await _player.stopPlayer();

    final dir = await getTemporaryDirectory();
    final path =
        "${dir.path}/latihan_${widget.lessonId}_${_currentIndex}_${DateTime.now().millisecondsSinceEpoch}.wav";

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

  // ----------------- PLAYBACK -----------------
  Future<void> _playRecorded() async {
    final path = _recordedPaths[_currentIndex];
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

  // ----------------- EVALUATE -----------------
  Future<void> _onEvaluate() async {
    if (_isEvaluating) return;

    final path = _recordedPaths[_currentIndex];

    if (path == null || path.isEmpty) {
      _showError("Silakan rekam suara terlebih dahulu");
      return;
    }

    setState(() => _isEvaluating = true);

    try {
      final target = widget.hurufList[_currentIndex].arabic;

      final json = await _api.evaluateAudio(
        audioPath: path,
        targetText: target,
        lessonId: widget.lessonId,
      );

      final result = EvaluationResult.fromJson(json);
      await _handleEvaluationResult(result);
    } catch (e) {
      _showError("Gagal evaluasi: $e");
    } finally {
      if (mounted) setState(() => _isEvaluating = false);
    }
  }

  Future<void> _handleEvaluationResult(EvaluationResult r) async {
    final score = r.score.clamp(0, 100);
    final passed = score >= 50;
    
    Color scoreColor;
    String label;
    String emoji;

    if (score >= 90) {
      scoreColor = AppColors.accent;
      label = "MasyaAllah!";
      emoji = "🌟";
    } else if (score >= 75) {
      scoreColor = AppColors.secondary;
      label = "Bagus!";
      emoji = "👍";
    } else if (score >= 50) {
      scoreColor = Colors.orange;
      label = "Cukup Baik";
      emoji = "🙂";
    } else {
      scoreColor = Colors.redAccent;
      label = "Perlu Latihan";
      emoji = "⚠️";
    }

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
              "$emoji  $label",
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
              r.feedback,
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
    ).then((_) {
      if (score >= 50 && _currentIndex < widget.hurufList.length - 1) {
        setState(() => _currentIndex++);
      } else if (_currentIndex == widget.hurufList.length - 1 && score >= 50) {
        _finishLessonAndBack(score.toDouble());
      }
    });
  }

  Future<void> _finishLessonAndBack(double finalScore) async {
    try {
      await HijaiyahService.submitLessonProgress(
        lessonId: widget.lessonId,
        completedLetters: widget.hurufList.length,
        score: finalScore,
      );
    } catch (e) {
      if (mounted) {
        _showError('Progress belum tersimpan: $e');
      }
    }

    try {
      await HijaiyahService.unlockLesson(widget.lessonId + 1);
    } catch (_) {}

    if (!mounted) return;
    Navigator.of(context).pop();
    Future.microtask(() {
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        content: Text(msg),
      ),
    );
  }

  // ----------------- UI -----------------
  Widget _infoCard() {
    final current = widget.hurufList[_currentIndex];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_rounded, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                "Instruksi Latihan",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Rekam suaramu saat mengucapkan huruf di bawah ini. Ulangi sampai pengucapanmu dinilai baik oleh AI.",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: current.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              "Target: ${current.latin} (${current.nama})",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hurufTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.hurufList.length, (i) {
          final active = i == _currentIndex;
          return GestureDetector(
            onTap: () {
              if (_isRecording) return;
              setState(() => _currentIndex = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: active ? AppColors.accent : Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.full),
                boxShadow: active ? AppShadows.soft : null,
                border: Border.all(
                  color: active ? AppColors.accent : AppColors.border,
                ),
              ),
              child: Text(
                widget.hurufList[i].latin,
                style: GoogleFonts.plusJakartaSans(
                  color: active ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _hurufPreview(HijaiyahData data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.medium,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              data.huruf,
              style: GoogleFonts.amiri(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            data.nama,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            data.latin,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recordControls() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _isRecording ? _stopRecording : _startRecording,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: _isRecording ? Colors.redAccent : AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: AppShadows.medium,
              ),
              child: Icon(
                _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isRecording ? "Sedang Merekam..." : "Tekan untuk Merekam",
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              color: _isRecording ? Colors.redAccent : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _nextLetter() {
    if (_currentIndex >= widget.hurufList.length - 1 || _isRecording) return;
    setState(() => _currentIndex++);
  }

  Widget _playbackAndEvaluateButtons() {
    final hasAudio = _recordedPaths[_currentIndex] != null;
    if (!hasAudio) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isPlaying ? null : _playRecorded,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: Icon(
                  _isPlaying ? Icons.graphic_eq_rounded : Icons.play_arrow_rounded,
                  size: 24,
                ),
                label: Text(_isPlaying ? "Memutar..." : "Putar"),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isEvaluating ? null : _onEvaluate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.auto_awesome_rounded, size: 24),
                label: Text(_isEvaluating ? "Menilai..." : "Nilai"),
              ),
            ),
          ],
        ),
        if (_currentIndex < widget.hurufList.length - 1) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _nextLetter,
              icon: const Icon(Icons.navigate_next_rounded),
              label: const Text("Lewati ke Huruf Berikutnya"),
            ),
          ),
        ],
      ],
    );
  }

  Widget _progressBar() {
    final progress = (_currentIndex + 1) / widget.hurufList.length;
    return Container(
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
                "Progres Pelajaran",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                "${_currentIndex + 1}/${widget.hurufList.length}",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.scaffold,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.hurufList[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: CustomGradientAppBar(title: widget.lessonTitle),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _infoCard(),
            const SizedBox(height: 24),
            _progressBar(),
            const SizedBox(height: 32),
            if (widget.hurufList.length > 1) ...[
              _hurufTabs(),
              const SizedBox(height: 24),
            ],
            _hurufPreview(current),
            const SizedBox(height: 40),
            _recordControls(),
            const SizedBox(height: 32),
            _playbackAndEvaluateButtons(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
