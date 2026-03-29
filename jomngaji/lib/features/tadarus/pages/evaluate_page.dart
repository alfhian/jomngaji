import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:http/http.dart' as http;
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
  static const String _tadarusAudioBaseUrl =
      'https://everyayah.com/data/Alafasy_128kbps';
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

  static bool _isArabicDiacritic(int codeUnit) {
    return (codeUnit >= 0x0610 && codeUnit <= 0x061A) ||
        (codeUnit >= 0x064B && codeUnit <= 0x065F) ||
        codeUnit == 0x0670 ||
        codeUnit == 0x06ED ||
        codeUnit == 0x0640;
  }

  static bool _isWhitespaceOrMark(String char) {
    final code = char.codeUnitAt(0);
    if (char.trim().isEmpty) return true;
    return _isArabicDiacritic(code);
  }

  List<TextSpan> _buildAyahHighlightSpans(
    String originalText,
    List<PronunciationIssue> issues,
  ) {
    final letterIssues = issues.where((e) {
      return e.location == 'huruf' &&
          e.startIndex != null &&
          e.endIndex != null &&
          (e.endIndex! > e.startIndex!);
    }).toList();

    if (letterIssues.isEmpty) {
      return [
        TextSpan(
          text: originalText,
          style: GoogleFonts.amiri(
            fontSize: 30,
            height: 1.9,
            color: const Color(0xFF0F172A),
          ),
        ),
      ];
    }

    final normalizedToOriginal = <int>[];
    for (int i = 0; i < originalText.length; i++) {
      final ch = originalText[i];
      if (_isWhitespaceOrMark(ch)) continue;
      normalizedToOriginal.add(i);
    }

    final highlightedIndexes = <int>{};
    for (final issue in letterIssues) {
      final start = issue.startIndex!;
      final endExclusive = issue.endIndex!;
      if (start < 0 || normalizedToOriginal.isEmpty) continue;
      final safeStart = math.min(start, normalizedToOriginal.length - 1);
      final safeEnd = math.min(
        math.max(endExclusive - 1, safeStart),
        normalizedToOriginal.length - 1,
      );
      for (int idx = safeStart; idx <= safeEnd; idx++) {
        highlightedIndexes.add(normalizedToOriginal[idx]);
      }
    }

    final spans = <TextSpan>[];
    for (int i = 0; i < originalText.length; i++) {
      final ch = originalText[i];
      final isHighlighted = highlightedIndexes.contains(i);
      spans.add(
        TextSpan(
          text: ch,
          style: GoogleFonts.amiri(
            fontSize: 30,
            height: 1.9,
            color: isHighlighted ? Colors.redAccent : const Color(0xFF0F172A),
            fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
            backgroundColor: isHighlighted ? Colors.red.withOpacity(0.12) : null,
          ),
        ),
      );
    }
    return spans;
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
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin mikrofon belum diberikan. Aktifkan izin mikrofon untuk merekam.'),
        ),
      );
      return;
    }

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
  String _audioCode(int index) {
    final s = widget.surah.number.toString().padLeft(3, '0');
    final audioIndex = index + 1;
    final a = audioIndex.toString().padLeft(3, '0');
    return '$s$a';
  }

  List<String> _audioUrlCandidates(int index) {
    final baseCode = _audioCode(index);
    final surah = baseCode.substring(0, 3);
    final ayah = int.tryParse(baseCode.substring(3)) ?? 0;
    final fallback = (ayah + 1).toString().padLeft(3, '0');
    return [
      '$_tadarusAudioBaseUrl/$baseCode.mp3',
      '$_tadarusAudioBaseUrl/$surah$fallback.mp3',
    ];
  }

  Future<void> _playAyahAudio(int index) async {
    if (index < 0 || index >= widget.surah.ayahs.length) return;

    try {
      if (_playingIndex == index && _player.playing) {
        await _player.pause();
        return;
      }

      await _player.stop();

      Object? lastError;
      for (final url in _audioUrlCandidates(index)) {
        try {
          await _player.setUrl(url);
          lastError = null;
          break;
        } catch (e) {
          lastError = e;
        }
      }

      if (lastError != null) {
        throw lastError;
      }

      setState(() => _playingIndex = index);
      await _player.play();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Audio ayat tidak bisa diputar: $e')),
      );
    }
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
    if (_isRecording) return;
    if (!_recorderReady) {
      await _initRecorder();
      if (!_recorderReady) return;
    }

    await _player.stop();

    final dir = await getTemporaryDirectory();
    final path =
        "${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.wav";

    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.pcm16WAV,
      sampleRate: 16000,
      numChannels: 1,
      bitRate: 16000,
      audioSource: AudioSource.microphone,
    );

    setState(() {
      _isRecording = true;
      _recordedPath = path;
    });
  }

  Future<void> _stopRecording() async {
    final savedPath = await _recorder.stopRecorder();
    final filePath = savedPath ?? _recordedPath;

    if (filePath != null) {
      final file = File(filePath);
      if (await file.exists()) {
        final length = await file.length();
        if (length < 2048 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Rekaman sangat kecil / kosong. Di emulator, pastikan Extended Controls > Microphone aktif dan host mic tidak di-mute.',
              ),
            ),
          );
        }
      }
    }

    if (!mounted) return;
    setState(() => _isRecording = false);
  }

  // ================= EVALUATE =================
  Future<void> _evaluate() async {
    if (_recordedPath == null || _isEvaluating) return;

    setState(() => _isEvaluating = true);

    try {
      final refPath = await _downloadReferenceAudio(_currentAyahIndex);

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

  Future<String> _downloadReferenceAudio(int index) async {
    http.Response? response;
    Object? lastError;
    for (final url in _audioUrlCandidates(index)) {
      try {
        final res = await http.get(Uri.parse(url));
        if (res.statusCode == 200) {
          response = res;
          break;
        }
        lastError = 'HTTP ${res.statusCode}';
      } catch (e) {
        lastError = e;
      }
    }

    if (response == null) {
      throw Exception('Gagal download audio referensi. Detail: $lastError');
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${_audioCode(index)}.mp3');
    await file.writeAsBytes(response.bodyBytes);
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
    final ayahText = widget.surah.ayahs[_currentAyahIndex].text;

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
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.82,
              ),
              padding: const EdgeInsets.all(20),
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
              child: SingleChildScrollView(
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

                  const SizedBox(height: 16),

                  // ===== SCORE RING (FIXED & LEBIH LEGA) =====
                  SizedBox(
                    width: 124,
                    height: 124,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow (lebih besar dari ring)
                        Container(
                          width: 124,
                          height: 124,
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
                          width: 108,
                          height: 108,
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
                                fontSize: 34,
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

                  const SizedBox(height: 14),

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

                  if (r.issueDetails.any((e) => e.location == 'huruf')) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detail Kesalahan Per Huruf',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.redAccent,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: RichText(
                              textAlign: TextAlign.right,
                              text: TextSpan(
                                children: _buildAyahHighlightSpans(
                                  ayahText,
                                  r.issueDetails,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Huruf berwarna merah menandakan bagian yang perlu diperbaiki.',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

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
