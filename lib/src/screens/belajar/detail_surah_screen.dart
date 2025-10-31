import 'package:flutter/material.dart';
import '../../models/surah.dart';
import '../../services/audio_service.dart';
import 'hafalan_screen.dart';

class DetailSurahScreen extends StatefulWidget {
  final Surah surah;

  const DetailSurahScreen({super.key, required this.surah});

  @override
  State<DetailSurahScreen> createState() => _DetailSurahScreenState();
}

class _DetailSurahScreenState extends State<DetailSurahScreen> {
  final AudioService _audioService = AudioService();
  bool _isPlaying = false;
  int _currentAyat = -1;

  final List<String> _dummyAyat = [
    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
    'الرَّحْمَٰنِ الرَّحِيمِ',
    'مَالِكِ يَوْمِ الدِّينِ',
    'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
    'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
    'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
  ];

  void _playNextAyat(int index) async {
    if (index >= _dummyAyat.length) {
      setState(() {
        _isPlaying = false;
        _currentAyat = -1;
      });
      return;
    }

    setState(() => _currentAyat = index);

    await _audioService.playFromAsset(
      'audio/alfatihah/alfatihah_${index + 1}.mp3',
      onComplete: () => _playNextAyat(index + 1),
    );
  }

  void _togglePlay() {
    if (_isPlaying) {
      _audioService.stop();
      setState(() {
        _isPlaying = false;
        _currentAyat = -1;
      });
    } else {
      setState(() {
        _isPlaying = true;
        _currentAyat = 0;
      });
      _playNextAyat(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFF),
      appBar: AppBar(
        title: Text(widget.surah.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF8FD3FE),
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 28),
              label: Text(_isPlaying ? "Pause Bacaan" : "Putar Bacaan"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: _togglePlay,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _dummyAyat.length,
              itemBuilder: (context, index) {
                final isActive = index == _currentAyat;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF8FD3FE).withOpacity(0.2)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _dummyAyat[index],
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 34,
                          fontFamily: 'Scheherazade', // font Arabic elegan
                          color: isActive
                              ? const Color(0xFF0066CC)
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Ayat ${index + 1}",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
