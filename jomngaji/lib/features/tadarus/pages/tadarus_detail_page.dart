import 'dart:convert';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

import '../../../core/config/api_config.dart';
import '../../../core/widgets/custom_gradient_appbar.dart';
import '../../../models/surah.dart';
import '../../auth/services/auth_service.dart';
import '../data/quran_loader.dart';
import 'evaluate_page.dart';

class TadarusDetailPage extends StatefulWidget {
  final Surah surah;

  const TadarusDetailPage({super.key, required this.surah});

  @override
  State<TadarusDetailPage> createState() => _TadarusDetailPageState();
}

class _TadarusDetailPageState extends State<TadarusDetailPage> {
  Surah? surah;
  double progressValue = 0.0;

  int _currentAyahIndex = 0;
  int? _playingIndex;
  bool _isSwitchingTrack = false;

  final Map<int, GlobalKey> _ayahKeys = {};
  late final AudioPlayer _player;

  @override
  void initState() {
    super.initState();

    _player = AudioPlayer();
    _player.setVolume(1);
    _player.setSpeed(1);

    _initAudioSession();
    _loadSurahAndProgress();

    _player.playerStateStream.listen((state) async {
      if (!mounted) return;

      if (state.processingState == ProcessingState.completed) {
        await _playNextAyah(autoPlay: true);
      }

      if (!state.playing && state.processingState == ProcessingState.idle) {
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
          contentType: AndroidAudioContentType.speech,
        ),
      ),
    );
  }

  Future<int> _fetchCompletedAyahCount(int surahNumber) async {
    final headers = await AuthService.authHeaders();
    final res = await http.get(
      Uri.parse(ApiConfig.endpoint('/tadarus/progress?surah=$surahNumber')),
      headers: headers,
    );

    if (res.statusCode != 200) return 0;

    final json = jsonDecode(res.body);
    return json['completed_ayah'] ?? 0;
  }

  Future<void> _loadSurahAndProgress() async {
    final s = await loadSurahDetail(widget.surah.number);
    final completed = await _fetchCompletedAyahCount(s.number);
    final index = completed.clamp(0, s.ayahs.length - 1);

    if (!mounted) return;
    setState(() {
      surah = s;
      progressValue = completed / s.ayahs.length;
      _currentAyahIndex = index;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToAyah(index);
    });
  }

  Future<void> _playAyahAudio(int index) async {
    if (surah == null || _isSwitchingTrack) return;
    if (index < 0 || index >= surah!.ayahs.length) {
      _showError('Ayat di luar jangkauan.');
      return;
    }

    final s = surah!.number.toString().padLeft(3, '0');
    final audioIndex = surah!.number == 1 ? index : (index + 1);
    final a = audioIndex.toString().padLeft(3, '0');
    final asset = 'assets/audio/tadarus/$s$a.mp3';

    try {
      _isSwitchingTrack = true;

      if (_playingIndex == index && _player.playing) {
        await _player.pause();
        return;
      }

      if (_playingIndex != index) {
        await _player.stop();
        await _player.setAsset(asset);
      }

      if (!mounted) return;
      setState(() {
        _playingIndex = index;
        _currentAyahIndex = index;
        progressValue = (index + 1) / surah!.ayahs.length;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToAyah(index);
      });

      _isSwitchingTrack = false;
      await _player.play();
    } catch (e) {
      _showError('Audio gagal diputar:\n$e');
    } finally {
      _isSwitchingTrack = false;
    }
  }

  Future<void> _stopAudio() async {
    await _player.stop();
    if (!mounted) return;
    setState(() => _playingIndex = null);
  }

  Future<void> _playPreviousAyah() async {
    if (surah == null) return;

    final prevIndex = _currentAyahIndex - 1;
    if (prevIndex < 0) {
      _showError('Ini sudah ayat pertama.');
      return;
    }

    await _playAyahAudio(prevIndex);
  }

  Future<void> _playNextAyah({bool autoPlay = false}) async {
    if (surah == null) return;

    final nextIndex = _currentAyahIndex + 1;
    if (nextIndex >= surah!.ayahs.length) {
      if (!autoPlay) {
        _showError('Ini sudah ayat terakhir.');
      }
      await _stopAudio();
      return;
    }

    await _playAyahAudio(nextIndex);
  }

  void _scrollToAyah(int index) {
    final key = _ayahKeys[index];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 400),
        alignment: 0.3,
      );
    }
  }

  void _onEvaluateAyah(Ayah ayah) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EvaluatePage(
          surah: surah!,
          ayah: ayah,
        ),
      ),
    );

    await _loadSurahAndProgress();
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (surah == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: const CustomGradientAppBar(title: 'Tadarus AI'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _headerCard(surah!),
            const SizedBox(height: 14),
            _playerControls(),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.builder(
                itemCount: surah!.ayahs.length,
                itemBuilder: (context, index) {
                  final ayah = surah!.ayahs[index];
                  final isActive = _playingIndex == index;
                  final key = _ayahKeys.putIfAbsent(index, () => GlobalKey());

                  return Container(
                    key: key,
                    child: _ayahBlock(ayah, isActive, index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playerControls() {
    final isPlayingCurrent = _playingIndex == _currentAyahIndex && _player.playing;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _controlButton(
            icon: Icons.skip_previous_rounded,
            onTap: _playPreviousAyah,
          ),
          _controlButton(
            icon: isPlayingCurrent ? Icons.pause_rounded : Icons.play_arrow_rounded,
            onTap: () => _playAyahAudio(_currentAyahIndex),
            isPrimary: true,
          ),
          _controlButton(
            icon: Icons.stop_rounded,
            onTap: _stopAudio,
          ),
          _controlButton(
            icon: Icons.skip_next_rounded,
            onTap: _playNextAyah,
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: isPrimary ? 56 : 46,
        height: isPrimary ? 56 : 46,
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF42C88A) : Colors.white12,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isPrimary ? 30 : 24,
        ),
      ),
    );
  }

  Widget _headerCard(Surah surah) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE9FFF3), Color(0xFFDFF6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBDEFD6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            surah.name,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Surah ke-${surah.number}, ${surah.ayahs.length} ayat',
            style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF334155)),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 9,
              backgroundColor: Colors.grey.shade300,
              color: const Color(0xFF42C88A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(progressValue * 100).toStringAsFixed(0)}% selesai',
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _ayahBlock(Ayah ayah, bool isActive, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE8FFF4) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? const Color(0xFF86E0B3) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Ayat ${ayah.ayah}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _playAyahAudio(index),
                icon: Icon(
                  isActive && _player.playing ? Icons.pause_circle : Icons.play_circle,
                  size: 30,
                  color: const Color(0xFF2FBF84),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              ayah.text,
              textAlign: TextAlign.right,
              style: GoogleFonts.amiri(
                fontSize: 29,
                height: 1.9,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          if (ayah.transliteration?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Text(
              ayah.transliteration!,
              style: GoogleFonts.notoSerif(
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
            ),
          ],
          if (ayah.translation?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              ayah.translation!,
              style: GoogleFonts.poppins(
                color: const Color(0xFF334155),
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => _onEvaluateAyah(ayah),
              icon: const Icon(Icons.record_voice_over),
              label: const Text('Rekam & Nilai Ayat Ini'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2FBF84),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
