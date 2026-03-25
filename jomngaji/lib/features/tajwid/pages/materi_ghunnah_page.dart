import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/custom_gradient_appbar.dart';

class MateriGhunnahPage extends StatefulWidget {
  const MateriGhunnahPage({super.key});

  @override
  State<MateriGhunnahPage> createState() => _MateriGhunnahPageState();
}

class _MateriGhunnahPageState extends State<MateriGhunnahPage> {
  final AudioPlayer _player = AudioPlayer();
  String? _currentPlaying;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _currentPlaying = null);
    });
  }

  Future<void> _playAudio(String fileName) async {
    if (_currentPlaying == fileName) {
      await _player.stop();
      setState(() => _currentPlaying = null);
      return;
    }
    await _player.play(AssetSource('audio/tajwid/ghunnah-$fileName.mp3'));
    setState(() => _currentPlaying = fileName);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomGradientAppBar(title: 'Ghunnah (Dengung)'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF7FB), Color(0xFFF8FAFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _heroCard(),
            const SizedBox(height: 16),
            _hukumCard(
              title: 'Nun Tasydid',
              tag: '2 Harakat',
              description: 'Dengung saat membaca huruf ن yang bertasydid.',
              example: 'إِنَّا أَعْطَيْنَاكَ',
              highlight: ['نّ'],
              audioFile: 'nun-tasydid',
            ),
            _hukumCard(
              title: 'Mim Tasydid',
              tag: '2 Harakat',
              description: 'Dengung saat membaca huruf م yang bertasydid.',
              example: 'ثُمَّ أَمَاتَهُ',
              highlight: ['مّ'],
              audioFile: 'mim-tasydid',
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFDB2777), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        'Ghunnah adalah dengung khas selama 2 harakat. Stabilkan aliran suara di hidung saat membaca.',
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, height: 1.45),
      ),
    );
  }

  Widget _hukumCard({
    required String title,
    required String tag,
    required String description,
    required String example,
    required List<String> highlight,
    required String audioFile,
  }) {
    final isPlaying = _currentPlaying == audioFile;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 12, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFFFCE7F3), borderRadius: BorderRadius.circular(999)),
              child: Text(tag, style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFFBE185D))),
            ),
          ]),
          const SizedBox(height: 8),
          Text(description, style: GoogleFonts.poppins(fontSize: 12.8, color: const Color(0xFF475569))),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(fontSize: 22, color: const Color(0xFF0F172A)),
                children: _buildHighlightedText(example, highlight),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => _playAudio(audioFile),
            icon: Icon(isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded),
            label: Text(isPlaying ? 'Stop Audio' : 'Putar Audio'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFBE185D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildHighlightedText(String text, List<String> highlight) {
    final spans = <TextSpan>[];
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final match = highlight.any((h) => h.contains(char));
      spans.add(TextSpan(
        text: char,
        style: TextStyle(
          color: match ? const Color(0xFFBE185D) : const Color(0xFF0F172A),
          fontWeight: match ? FontWeight.w700 : FontWeight.w500,
        ),
      ));
    }
    return spans;
  }
}
