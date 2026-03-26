import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_session/audio_session.dart';

import '../../../core/config/api_config.dart';
import '../../../models/surah.dart';
import '../../../models/evaluation_result.dart';
import '../../../services/evaluation_api.dart';
import '../../../core/widgets/custom_gradient_appbar.dart';

class EvaluatePage extends StatefulWidget {
  final Surah surah;
  final Ayah ayah;

  const EvaluatePage({
    super.key,
    required this.surah,
    required this.ayah,
  });

  @override
  State<EvaluatePage> createState() => _EvaluatePageState();
}

class _EvaluatePageState extends State<EvaluatePage> {
  // ================= AYAH =================
  late int _currentAyahIndex;
  int? _playingIndex;

  // ================= AUDIO PLAYER =================
  late final ja.AudioPlayer _player;

  // ================= RECORDER =================
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _recorderReady = false;
  bool _isRecording = false;

  String? _recordedPath;

  // ================= EVALUATION =================
  late final EvaluationApi _api;
  bool _isEvaluating = false;

  String _scoreDescription(int score) {
    if (score >= 90) {
      return "MasyaAllah 🌟 bacaanmu sangat bagus dan mendekati contoh qari.";
    } else if (score >= 75) {
      return "Bacaan sudah baik 👍 tinggal sedikit memperhalus pelafalan.";
    } else if (score >= 60) {
      return "Cukup bagus 🙂 tapi masih ada beberapa pelafalan yang kurang tepat.";
    } else if (score >= 40) {
      return "Pelafalan kurang cocok ⚠️ perlu latihan lebih pelan dan jelas.";
    } else {
      return "Pelafalan belum cocok ❌ coba dengarkan contoh lalu ulangi perlahan.";
    }
  }


  @override
  void initState() {
    super.initState();

    _api = EvaluationApi(ApiConfig.baseUrl);
    _currentAyahIndex = widget.surah.ayahs.indexOf(widget.ayah);

    _player = ja.AudioPlayer();
    _initAudioSession();
    _initRecorder();

    _player.processingStateStream.listen((state) {
      if (state == ja.ProcessingState.completed) {
        setState(() => _playingIndex = null);
      }
    });
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        androidAudioAttributes: AndroidAudioAttributes(
          usage: AndroidAudioUsage.media,
          contentType: AndroidAudioContentType.music,
        ),
      ),
    );
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await Permission.storage.request();

    if (!await Permission.microphone.isGranted) return;

    await _recorder.openRecorder();
    setState(() => _recorderReady = true);
  }

  @override
  void dispose() {
    _player.dispose();
    _recorder.closeRecorder();
    super.dispose();
  }

  // ================= AUDIO =================
  String _assetPath(int index) {
    final s = widget.surah.number.toString().padLeft(3, '0');
    final a = index.toString().padLeft(3, '0');
    return 'assets/audio/tadarus/$s$a.mp3';
  }

  Future<void> _playAyahAudio(int index) async {
    if (index < 0 || index >= widget.surah.ayahs.length) return;

    final assetPath = _assetPath(index);

    if (_playingIndex == index && _player.playing) {
      await _player.pause();
      return;
    }

    await _player.stop();
    await _player.setAsset(assetPath);

    setState(() => _playingIndex = index);
    await _player.play();
  }

  void _nextAyah() {
    if (_currentAyahIndex + 1 >= widget.surah.ayahs.length) return;
    setState(() => _currentAyahIndex++);
    _playAyahAudio(_currentAyahIndex);
  }

  void _prevAyah() {
    if (_currentAyahIndex - 1 < 0) return;
    setState(() => _currentAyahIndex--);
    _playAyahAudio(_currentAyahIndex);
  }

  // ================= RECORD =================
  Future<void> _startRecording() async {
    if (!_recorderReady || _isRecording) return;

    await _player.stop();

    final dir = await getTemporaryDirectory();
    final path =
        "${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.aac";

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
    await _recorder.stopRecorder();
    setState(() => _isRecording = false);
  }

  // ================= EVALUATE =================
  Future<void> _evaluate() async {
    if (_recordedPath == null || _isEvaluating) return;

    setState(() => _isEvaluating = true);

    try {
      final refPath = await _copyAsset(_assetPath(_currentAyahIndex));

      final json = await _api.evaluateTadarusAudio(
        surah: widget.surah.number,
        ayah: widget.surah.ayahs[_currentAyahIndex].ayah,
        totalAyah: widget.surah.ayahs.length,
        userAudioPath: _recordedPath!,
        referenceAudioPath: refPath,
      );

      final result = EvaluationResult.fromJson(json);
      _showResult(result);
    } finally {
      setState(() => _isEvaluating = false);
    }
  }

  Future<String> _copyAsset(String asset) async {
    final data = await rootBundle.load(asset);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${asset.split('/').last}');
    await file.writeAsBytes(data.buffer.asUint8List());
    return file.path;
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final ayah = widget.surah.ayahs[_currentAyahIndex];

    return Scaffold(
      appBar: const CustomGradientAppBar(title: "Evaluasi Ayat"),
      bottomNavigationBar: _playerControls(),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            "QS ${widget.surah.name} • Ayat ${ayah.ayah}",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          _ayahCard(ayah),
          const SizedBox(height: 30),
          _recordSection(),
          const SizedBox(height: 24),
          if (_recordedPath != null) _evaluateButton(),
        ],
      ),
    );
  }

  Widget _ayahCard(Ayah ayah) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                ayah.text,
                style: GoogleFonts.amiri(fontSize: 30, height: 2),
                textAlign: TextAlign.right,
              ),
            ),
            if (ayah.transliteration?.isNotEmpty == true) ...[
              const Divider(height: 32),
              Text(
                ayah.transliteration!,
                style: GoogleFonts.notoSerif(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
            if (ayah.translation?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Text(
                ayah.translation!,
                style: GoogleFonts.poppins(height: 1.6),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _recordSection() {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isRecording ? Colors.red : const Color(0xFF42C88A),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                color: Colors.black26,
              )
            ],
          ),
          child: IconButton(
            iconSize: 42,
            icon: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              color: Colors.white,
            ),
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

  Widget _evaluateButton() {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isEvaluating ? null : _evaluate,
        icon: _isEvaluating
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.auto_awesome),
        label: Text(
          _isEvaluating ? "Menilai..." : "Nilai Bacaan",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF42C88A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _playerControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _prevAyah,
              icon: const Icon(Icons.skip_previous),
              iconSize: 32,
            ),
            IconButton(
              onPressed: () => _playAyahAudio(_currentAyahIndex),
              iconSize: 44,
              icon: StreamBuilder<ja.PlayerState>(
                stream: _player.playerStateStream,
                builder: (_, snapshot) {
                  final playing = snapshot.data?.playing ?? false;
                  return Icon(
                    playing
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                  );
                },
              ),
            ),
            IconButton(
              onPressed: _nextAyah,
              icon: const Icon(Icons.skip_next),
              iconSize: 32,
            ),
          ],
        ),
      ),
    );
  }

  void _showResult(EvaluationResult r) {
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

                  // ===== SCORE RING (FIXED & LEBIH LEGA) =====
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow (lebih besar dari ring)
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

                        // Progress ring (lebih kecil)
                        SizedBox(
                          width: 130,
                          height: 130,
                          child: CircularProgressIndicator(
                            value: score / 100,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey.shade200,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(scoreColor),
                          ),
                        ),

                        // Score text (AMAN, tidak ketutup)
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

                  const SizedBox(height: 20),

                  // ===== DESKRIPSI =====
                  Text(
                    _scoreDescription(score),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  // ===== ERROR LIST =====
                  if (r.errors.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...r.errors.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 16,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                e,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 26),

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
                        "Tutup",
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
          child: Opacity(
            opacity: anim.value,
            child: child,
          ),
        );
      },
    );
  }
}
