import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/custom_gradient_appbar.dart';

class MateriMimMatiPage extends StatefulWidget {
  const MateriMimMatiPage({super.key});

  @override
  State<MateriMimMatiPage> createState() => _MateriMimMatiPageState();
}

class _MateriMimMatiPageState extends State<MateriMimMatiPage> {
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
    await _player.play(AssetSource('audio/tajwid/mim-mati-$fileName.mp3'));
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
      appBar: const CustomGradientAppBar(title: 'Hukum Mim Mati'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFF), Color(0xFFF2F8FF)],
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
              title: 'Idzhar Syafawi',
              tag: 'Jelas',
              description: 'Mim mati dibaca jelas saat bertemu huruf selain mim dan ba.',
              example: 'نِعْمَةٌ مِنَ اللّٰهِ',
              highlight: ['مْ', 'ن'],
              audioFile: 'idzhar-syafawi',
            ),
            _hukumCard(
              title: 'Ikhfa Syafawi',
              tag: 'Samar',
              description: 'Mim mati dibaca samar saat bertemu huruf ب.',
              example: 'تَرْمِيهِمْ بِحِجَارَةٍ',
              highlight: ['مْ', 'ب'],
              audioFile: 'ikhfa-syafawi',
            ),
            _hukumCard(
              title: 'Idgham Mimi',
              tag: 'Melebur',
              description: 'Mim mati dilebur ke mim setelahnya disertai dengung.',
              example: 'لَهُمْ مَغْفِرَةٌ',
              highlight: ['مْ', 'م'],
              audioFile: 'idgham-mimi',
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
          colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        'Hukum Mim Mati punya 3 aturan inti. Fokuskan bibir saat latihan agar pelafalan lebih tepat.',
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
              decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(999)),
              child: Text(tag, style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF4338CA))),
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
              backgroundColor: const Color(0xFF4F46E5),
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
          color: match ? const Color(0xFF4F46E5) : const Color(0xFF0F172A),
          fontWeight: match ? FontWeight.w700 : FontWeight.w500,
        ),
      ));
    }
    return spans;
  }
}
