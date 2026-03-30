import 'dart:io';
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
import 'tadarus_evaluation_result_page.dart';

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
      await _showResult(result);
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

  Future<void> _showResult(EvaluationResult r) async {
    final ayah = widget.surah.ayahs[_currentAyahIndex];
    SystemSound.play(SystemSoundType.alert);
    final action = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => TadarusEvaluationResultPage(
          result: r,
          ayahText: ayah.text,
          currentAyah: ayah.ayah,
          totalAyah: widget.surah.ayahs.length,
        ),
      ),
    );

    if (!mounted) return;
    if (action == 'next') {
      _nextAyah();
      setState(() => _recordedPath = null);
    } else if (action == 'retry') {
      setState(() => _recordedPath = null);
    }
  }
}
