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

    setState(() => _recorderReady = true);
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  // ----------------- RECORD -----------------
  Future<void> _startRecording() async {
    if (!_recorderReady || _isRecording) return;

    if (_player.isPlaying) await _player.stopPlayer();

    final dir = await getTemporaryDirectory();
    final path =
        "${dir.path}/latihan_${_currentIndex}_${DateTime.now().millisecondsSinceEpoch}.aac";

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

      print(json);

      final result = EvaluationResult.fromJson(json);

      print('=== PARSED EVALUATION RESULT ===');
      print('score: ${result.score}');
      print('feedback: ${result.feedback}');
      print('errors: ${result.errors}');

      await _handleEvaluationResult(result);
    } catch (e) {
      _showError("Gagal evaluasi: $e");
    } finally {
      if (mounted) setState(() => _isEvaluating = false);
    }
  }

  Future<void> _handleEvaluationResult(EvaluationResult r) async {
    final score = r.score.clamp(0, 100);
    Color scoreColor;
    String label;
    String emoji;

    if (score >= 90) {
      scoreColor = const Color(0xFF42C88A);
      label = "MasyaAllah!";
      emoji = "🌟";
    } else if (score >= 75) {
      scoreColor = const Color(0xFF5FB3F3);
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

    SystemSound.play(SystemSoundType.alert);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "score",
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
                  BoxShadow(
                    blurRadius: 30,
                    color: Colors.black26,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$emoji  $label",
                    style: GoogleFonts.poppins(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: scoreColor,
                    ),
                  ),
                  const SizedBox(height: 22),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.75, end: 1),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.elasticOut,
                    builder: (_, scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  scoreColor.withOpacity(0.25),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          if (score >= 50)
                            const Positioned(
                              top: 6,
                              right: 12,
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                color: Color(0xFFFFC107),
                                size: 22,
                              ),
                            ),
                          SizedBox(
                            width: 130,
                            height: 130,
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
                                "$score",
                                style: GoogleFonts.poppins(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: scoreColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Skor",
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
                  ),
                  const SizedBox(height: 20),
                  Text(
                    r.feedback,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  // if (r.errors.isNotEmpty) ...[
                  //   const SizedBox(height: 16),
                  //   ...r.errors.map(
                  //     (e) => Padding(
                  //       padding: const EdgeInsets.only(top: 4),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           const Icon(Icons.error_outline, size: 16, color: Colors.redAccent),
                  //           const SizedBox(width: 6),
                  //           Flexible(
                  //             child: Text(
                  //               e,
                  //               textAlign: TextAlign.center,
                  //               style: GoogleFonts.poppins(fontSize: 13, color: Colors.redAccent),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ],
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scoreColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        "Tutup",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
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
    ).then((_) {
      // Jika skor >=50, lanjut ke huruf berikutnya
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
        _showError('Progress belum tersimpan sempurna: $e');
      }
    }

    try {
      await HijaiyahService.unlockLesson(widget.lessonId + 1);
    } catch (_) {
      // best effort: lesson berikutnya bisa jadi belum ada / premium policy server
    }

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
      SnackBar(content: Text(msg)),
    );
  }

  // ----------------- UI -----------------
  Widget _infoCard() {
    final current = widget.hurufList[_currentIndex];
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE7FFF2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        "Latihan bunyi: \"${current.latin}\"",
        style: GoogleFonts.poppins(fontSize: 14),
      ),
    );
  }

  Widget _hurufTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.hurufList.length, (i) {
        final active = i == _currentIndex;
        return GestureDetector(
          onTap: () {
            if (_isRecording) return;
            setState(() => _currentIndex = i);
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active ? const Color(0xFF42C88A) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.hurufList[i].latin,
              style: GoogleFonts.poppins(color: active ? Colors.white : Colors.black),
            ),
          ),
        );
      }),
    );
  }

  Widget _hurufPreview(HijaiyahData data) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: data.color,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Center(
            child: Text(
              data.huruf,
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(data.latin, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(data.nama, style: GoogleFonts.poppins(color: Colors.black54)),
      ],
    );
  }

  Widget _recordControls() {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isRecording ? Colors.red : const Color(0xFF42C88A),
            boxShadow: [BoxShadow(blurRadius: 12, color: Colors.black26)],
          ),
          child: IconButton(
            iconSize: 42,
            icon: Icon(_isRecording ? Icons.stop : Icons.mic, color: Colors.white),
            onPressed: _isRecording ? _stopRecording : _startRecording,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isRecording ? "Sedang merekam..." : "Tap untuk mulai merekam",
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _playbackAndEvaluateButtons() {
    final hasAudio = _recordedPaths[_currentIndex] != null;
    if (!hasAudio) return const SizedBox.shrink();

    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _isPlaying ? null : _playRecorded,
          icon: const Icon(Icons.play_arrow),
          label: Text(_isPlaying ? "Memutar..." : "Putar rekaman"),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5E60CE)),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _isEvaluating ? null : _onEvaluate,
          icon: const Icon(Icons.auto_awesome),
          label: Text(_isEvaluating ? "Menilai..." : "Nilai Pengucapan"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.hurufList[_currentIndex];

    return Scaffold(
      appBar: CustomGradientAppBar(title: widget.lessonTitle),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _infoCard(),
          if (widget.hurufList.length > 1) _hurufTabs(),
          const SizedBox(height: 16),
          _hurufPreview(current),
          const SizedBox(height: 24),
          _recordControls(),
          const SizedBox(height: 20),
          _playbackAndEvaluateButtons(),
        ],
      ),
    );
  }
}
