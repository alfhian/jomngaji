import 'dart:convert';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

import '../../../core/widgets/custom_gradient_appbar.dart';
import '../../../core/widgets/premium_upgrade_dialog.dart';
import '../../../models/surah.dart';
import '../../../routes/app_routes.dart';
import '../../auth/services/auth_service.dart';
import '../../home/widgets/app_bottom_nav.dart';
import '../data/quran_loader.dart';

class TadarusMenuPage extends StatefulWidget {
  const TadarusMenuPage({super.key});

  @override
  State<TadarusMenuPage> createState() => _TadarusMenuPageState();
}

class _TadarusMenuPageState extends State<TadarusMenuPage> {
  List<Surah> _allSurahs = [];
  List<Surah> _filteredSurahs = [];
  bool _loading = true;

  double _globalProgress = 0.0;
  String _checkpointLabel = 'Checkpoint 1';

  final TextEditingController _searchCtrl = TextEditingController();
  String _lastRead = '-';
  String _lastRecited = '-';

  int _completedAyahGlobal = 0;
  int _totalAyahGlobal = 0;

  late final AudioPlayer _previewPlayer;
  int _previewSurahIndex = 0;
  int? _playingPreviewIndex;
  bool _isSwitchingPreview = false;

  @override
  void initState() {
    super.initState();
    _previewPlayer = AudioPlayer();
    _previewPlayer.setVolume(1);
    _previewPlayer.setSpeed(1);

    _previewPlayer.playerStateStream.listen((state) async {
      if (!mounted) return;

      if (state.processingState == ProcessingState.completed &&
          !_isSwitchingPreview) {
        await _playNextPreview(autoPlay: true);
      }

      if (!state.playing && state.processingState == ProcessingState.idle) {
        setState(() => _playingPreviewIndex = null);
      }
    });

    _initAudioSession();
    _initPage();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _previewPlayer.dispose();
    super.dispose();
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

  Future<void> _initPage() async {
    setState(() => _loading = true);

    await Future.wait([
      _loadGlobalProgress(),
      _loadSurahs(),
      _loadLastActivity(),
    ]);

    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _loadLastActivity() async {
    try {
      final headers = await AuthService.authHeaders();

      final res = await http.get(
        Uri.parse('http://10.179.249.20:4000/tadarus/last-activity'),
        headers: headers,
      );

      if (res.statusCode != 200) return;

      final json = jsonDecode(res.body);

      if (!mounted) return;
      final lastRead = json['last_read'] as Map<String, dynamic>?;
      final lastRecited = json['last_recited'] as Map<String, dynamic>?;
      final lastReadSurah = lastRead?['surah_name']?.toString();
      final lastReadAyah = lastRead?['ayah']?.toString();
      final lastRecitedSurah = lastRecited?['surah_name']?.toString();
      final lastRecitedAyah = lastRecited?['ayah']?.toString();

      setState(() {
        _lastRead = (lastReadSurah == null || lastReadAyah == null)
            ? 'Belum ada aktivitas baca.'
            : '$lastReadSurah, Ayat $lastReadAyah';
        _lastRecited = (lastRecitedSurah == null || lastRecitedAyah == null)
            ? 'Belum ada aktivitas setoran.'
            : '$lastRecitedSurah, Ayat $lastRecitedAyah';
      });
    } catch (e) {
      debugPrint('Gagal load last activity: $e');
    }
  }

  String _formatPercent(double value) {
    final percent = value * 100;
    if (percent < 1) {
      return percent.toStringAsFixed(2);
    }
    return percent.toStringAsFixed(1);
  }

  Future<void> _loadGlobalProgress() async {
    try {
      final headers = await AuthService.authHeaders();

      final res = await http.get(
        Uri.parse('http://10.179.249.20:4000/tadarus/global-progress'),
        headers: headers,
      );

      if (res.statusCode != 200) return;

      final json = jsonDecode(res.body);
      final completed = (json['completed_ayah'] ?? 0).toInt();
      final total = (json['total_ayah'] ?? 0).toInt();
      final progress = total > 0 ? completed / total : 0.0;

      if (!mounted) return;
      setState(() {
        _completedAyahGlobal = completed;
        _totalAyahGlobal = total;
        _globalProgress = progress;
        _checkpointLabel = _resolveCheckpoint(progress);
      });
    } catch (e) {
      debugPrint('Gagal load global progress: $e');
    }
  }

  Future<void> _loadSurahs() async {
    try {
      final headers = await AuthService.authHeaders();
      final data = await loadQuranDataset();

      final List<Surah> result = [];

      for (final s in data) {
        double progress = 0.0;

        try {
          final res = await http.get(
            Uri.parse('http://10.179.249.20:4000/tadarus/progress?surah=${s.number}'),
            headers: headers,
          );

          if (res.statusCode == 200) {
            final json = jsonDecode(res.body);
            final completed = (json['completed_ayah'] ?? 0).toDouble();
            progress = s.ayahCount > 0 ? completed / s.ayahCount : 0.0;
          }
        } catch (_) {}

        result.add(s.copyWith(progress: progress));
      }

      _allSurahs = result;
      _filteredSurahs = result;
    } catch (e) {
      debugPrint('Gagal load surah: $e');
    }
  }

  String _resolveCheckpoint(double progress) {
    final pct = (progress * 100).round();
    if (pct >= 75) return 'Checkpoint 4';
    if (pct >= 50) return 'Checkpoint 3';
    if (pct >= 25) return 'Checkpoint 2';
    return 'Checkpoint 1';
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filteredSurahs = q.isEmpty
          ? _allSurahs
          : _allSurahs.where((s) {
              return s.name.toLowerCase().contains(q) ||
                  s.number.toString().contains(q);
            }).toList();

      if (_filteredSurahs.isEmpty) {
        _previewSurahIndex = 0;
      } else if (_previewSurahIndex >= _filteredSurahs.length) {
        _previewSurahIndex = _filteredSurahs.length - 1;
      }
    });
  }

  Surah? get _currentPreviewSurah {
    if (_filteredSurahs.isEmpty) return null;
    final safeIndex = _previewSurahIndex.clamp(0, _filteredSurahs.length - 1);
    return _filteredSurahs[safeIndex];
  }

  Future<void> _playPreview({bool fromStart = false}) async {
    final surah = _currentPreviewSurah;
    if (surah == null || _isSwitchingPreview) return;

    final index = _previewSurahIndex;
    final code = surah.number.toString().padLeft(3, '0');

    try {
      _isSwitchingPreview = true;

      if (_playingPreviewIndex == index && _previewPlayer.playing && !fromStart) {
        await _previewPlayer.pause();
        return;
      }

      if (_playingPreviewIndex != index || fromStart) {
        await _previewPlayer.stop();

        final ayah001 = 'assets/audio/tadarus/${code}001.mp3';
        final ayah000 = 'assets/audio/tadarus/${code}000.mp3';

        try {
          await _previewPlayer.setAsset(ayah001);
        } catch (_) {
          await _previewPlayer.setAsset(ayah000);
        }

        if (!mounted) return;
        setState(() {
          _playingPreviewIndex = index;
        });
      }

      _isSwitchingPreview = false;
      await _previewPlayer.play();
    } catch (e) {
      _showError('Audio preview gagal diputar:\n$e');
    } finally {
      _isSwitchingPreview = false;
    }
  }

  Future<void> _stopPreview() async {
    await _previewPlayer.stop();
    if (!mounted) return;
    setState(() => _playingPreviewIndex = null);
  }

  Future<void> _playNextPreview({bool autoPlay = false}) async {
    if (_filteredSurahs.isEmpty) return;

    setState(() {
      _previewSurahIndex = (_previewSurahIndex + 1) % _filteredSurahs.length;
    });

    if (autoPlay) {
      await _playPreview(fromStart: true);
    }
  }

  Future<void> _playPreviousPreview() async {
    if (_filteredSurahs.isEmpty) return;

    setState(() {
      _previewSurahIndex = _previewSurahIndex - 1;
      if (_previewSurahIndex < 0) {
        _previewSurahIndex = _filteredSurahs.length - 1;
      }
    });

    await _playPreview(fromStart: true);
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      extendBody: true,
      appBar: const CustomGradientAppBar(title: 'Tadarus'),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                _progressCard(),
                const SizedBox(height: 14),
                _searchRow(),
                const SizedBox(height: 14),
                _previewPlayerCard(),
                const SizedBox(height: 14),
                _lastActivityCard(),
                const SizedBox(height: 16),
                Text(
                  'Daftar Surah',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                _surahList(),
                const SizedBox(height: 80),
              ],
            ),
    );
  }

  Widget _progressCard() {
    final percentText = _formatPercent(_globalProgress);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE9FFF3), Color(0xFFDFF6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBDEFD6)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF42C88A), Color(0xFF2FAE8C)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.menu_book_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lanjutkan Khatam Al-Qur’an',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_completedAyahGlobal / $_totalAyahGlobal ayat selesai',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _globalProgress,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade300,
                          color: const Color(0xFF2FBF84),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$percentText%',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _checkpointLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0E9F6E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchRow() {
    return TextField(
      controller: _searchCtrl,
      decoration: InputDecoration(
        hintText: 'Cari Surah',
        hintStyle: GoogleFonts.poppins(fontSize: 14),
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _searchCtrl.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchCtrl.clear();
                  _applyFilter();
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _previewPlayerCard() {
    final surah = _currentPreviewSurah;
    final isPlaying = _playingPreviewIndex == _previewSurahIndex && _previewPlayer.playing;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Audio Preview',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            surah == null
                ? 'Tidak ada surah pada hasil pencarian.'
                : '${surah.number}. ${surah.name} • Ayat awal',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _controlButton(
                icon: Icons.skip_previous_rounded,
                onTap: surah == null ? null : _playPreviousPreview,
              ),
              _controlButton(
                icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                onTap: surah == null ? null : _playPreview,
                isPrimary: true,
              ),
              _controlButton(
                icon: Icons.stop_rounded,
                onTap: surah == null ? null : _stopPreview,
              ),
              _controlButton(
                icon: Icons.skip_next_rounded,
                onTap: surah == null ? null : () => _playNextPreview(autoPlay: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required VoidCallback? onTap,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        width: isPrimary ? 54 : 44,
        height: isPrimary ? 54 : 44,
        decoration: BoxDecoration(
          color: onTap == null
              ? Colors.white24
              : isPrimary
                  ? const Color(0xFF42C88A)
                  : Colors.white12,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isPrimary ? 28 : 24,
        ),
      ),
    );
  }

  Widget _lastActivityCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aktivitas Terakhir',
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text('Terakhir Dibaca: $_lastRead', style: GoogleFonts.poppins(fontSize: 13)),
          Text('Terakhir Dilafalkan: $_lastRecited', style: GoogleFonts.poppins(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _surahList() {
    if (_filteredSurahs.isEmpty) {
      return Center(
        child: Text(
          'Surah tidak ditemukan.',
          style: GoogleFonts.poppins(color: Colors.black54),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredSurahs.length,
      itemBuilder: (context, index) {
        final s = _filteredSurahs[index];
        final percent = (s.progress * 100).toStringAsFixed(0);

        return GestureDetector(
          onTap: () async {
            if (s.number != 1) {
              await runWithPremiumGate(
                context,
                featureName: s.name,
                onAllowed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.tadarus,
                  arguments: s,
                ),
              );
              return;
            }
            Navigator.pushNamed(
              context,
              AppRoutes.tadarus,
              arguments: s,
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9FFF3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${s.number}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0E9F6E),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${s.ayahCount} Ayat',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: s.progress,
                          backgroundColor: Colors.grey.shade200,
                          color: const Color(0xFF42C88A),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    if (s.number != 1)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'PRO',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    IconButton(
                      onPressed: () async {
                        setState(() => _previewSurahIndex = index);
                        await _playPreview(fromStart: true);
                      },
                      icon: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF2FBF84)),
                    ),
                    Text(
                      '$percent%',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
