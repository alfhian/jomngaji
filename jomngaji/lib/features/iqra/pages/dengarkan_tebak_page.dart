import 'dart:io';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import '../../../services/progress_service.dart';

class DengarkanTebakPage extends StatefulWidget {
  const DengarkanTebakPage({super.key});

  @override
  State<DengarkanTebakPage> createState() => _DengarkanTebakPageState();
}

class _DengarkanTebakPageState extends State<DengarkanTebakPage> {
  static const int _totalQuestion = 10;

  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  late ConfettiController _confettiController;

  bool _isPlaying = false;
  bool _lockedAnswer = false;
  int _currentQuestionIndex = 1;
  int _correctCount = 0;
  int _streak = 0;
  int _bestStreak = 0;

  String _feedback = "";
  String? _selectedOption;

  final List<Map<String, String>> audioList = [
    {"audio": "fatah_a.mp3", "arab": "اَ"},
    {"audio": "fatah_ba.mp3", "arab": "بَ"},
    {"audio": "fatah_ta.mp3", "arab": "تَ"},
    {"audio": "fatah_tsa.mp3", "arab": "ثَ"},
    {"audio": "fatah_ja.mp3", "arab": "جَ"},
    {"audio": "fatah_ha.mp3", "arab": "حَ"},
    {"audio": "fatah_ka.mp3", "arab": "خَ"},
    {"audio": "fatah_da.mp3", "arab": "دَ"},
    {"audio": "fatah_dza.mp3", "arab": "ذَ"},
    {"audio": "fatah_ro.mp3", "arab": "رَ"},
    {"audio": "fatah_za.mp3", "arab": "زَ"},
    {"audio": "fatah_sa.mp3", "arab": "سَ"},
    {"audio": "fatah_sya.mp3", "arab": "شَ"},
    {"audio": "fatah_sho.mp3", "arab": "صَ"},
    {"audio": "fatah_dho.mp3", "arab": "ضَ"},
    {"audio": "fatah_tho.mp3", "arab": "طَ"},
    {"audio": "fatah_dzo.mp3", "arab": "ظَ"},
    {"audio": "fatah_aa.mp3", "arab": "عَ"},
    {"audio": "fatah_gho.mp3", "arab": "غَ"},
    {"audio": "fatah_fa.mp3", "arab": "فَ"},
    {"audio": "fatah_qo.mp3", "arab": "قَ"},
    {"audio": "fatah_ka.mp3", "arab": "كَ"},
    {"audio": "fatah_la.mp3", "arab": "لَ"},
    {"audio": "fatah_ma.mp3", "arab": "مَ"},
    {"audio": "fatah_na.mp3", "arab": "نَ"},
    {"audio": "fatah_haa.mp3", "arab": "هَ"},
    {"audio": "fatah_wa.mp3", "arab": "وَ"},
    {"audio": "fatah_ya.mp3", "arab": "يَ"},
  ];

  late Map<String, String> _question;
  List<String> options = [];

  @override
  void initState() {
    super.initState();
    _player.openPlayer();
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 800));
    _generateQuestion();
  }

  @override
  void dispose() {
    _player.closePlayer();
    _confettiController.dispose();
    super.dispose();
  }

  void _generateQuestion() {
    final random = Random();
    _question = audioList[random.nextInt(audioList.length)];

    options = [_question["arab"]!];
    while (options.length < 3) {
      final pick = audioList[random.nextInt(audioList.length)]["arab"]!;
      if (!options.contains(pick)) options.add(pick);
    }
    options.shuffle();

    setState(() {
      _feedback = "";
      _lockedAnswer = false;
      _selectedOption = null;
    });
  }

  Future<String> loadAsset(String assetPath) async {
    final bytes = await rootBundle.load(assetPath);
    final file = File(
      '${(await getTemporaryDirectory()).path}/${assetPath.split("/").last}',
    );
    await file.writeAsBytes(bytes.buffer.asUint8List());
    return file.path;
  }

  Future<void> _playAudio() async {
    if (_isPlaying) return;
    setState(() => _isPlaying = true);

    final path = await loadAsset('assets/audio/huruf/${_question["audio"]}');

    await _player.startPlayer(
      fromURI: path,
      whenFinished: () {
        if (mounted) setState(() => _isPlaying = false);
      },
    );
  }

  Future<void> _checkAnswer(String selected) async {
    if (_lockedAnswer) return;

    final isCorrect = selected == _question["arab"];

    setState(() {
      _lockedAnswer = true;
      _selectedOption = selected;
      if (isCorrect) {
        _correctCount++;
        _streak++;
        _bestStreak = max(_bestStreak, _streak);
        _feedback = '✅ Benar!';
      } else {
        _streak = 0;
        _feedback = '❌ Salah';
      }
    });

    if (isCorrect) {
      _confettiController.play();
      final xp = await ProgressService.getXP();
      await ProgressService.saveXP(xp + 5);
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          duration: const Duration(milliseconds: 850),
          backgroundColor: isCorrect ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
          content: Text(
            isCorrect
                ? 'Mantap! +5 XP | Streak: $_streak'
                : 'Jawaban yang benar: ${_question["arab"]}',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      );

    await Future.delayed(const Duration(milliseconds: 760));
    if (!mounted) return;

    if (_currentQuestionIndex >= _totalQuestion) {
      _showResultDialog();
      return;
    }

    setState(() => _currentQuestionIndex++);
    _generateQuestion();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        final percent = ((_correctCount / _totalQuestion) * 100).round();
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _correctCount >= 7 ? 'Keren! Pendengaran Tajam 👂' : 'Bagus, lanjut latihan ya! ✨',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2F9E6E),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Benar: $_correctCount/$_totalQuestion\nSkor: $percent%\nBest streak: $_bestStreak',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 15),
                ),
                const SizedBox(height: 16),
                Text(
                  'Saran: gunakan headset + ulang 2x audio sebelum menjawab untuk naikkan akurasi.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text('Kembali', style: GoogleFonts.poppins()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF42C88A),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _currentQuestionIndex = 1;
                            _correctCount = 0;
                            _streak = 0;
                            _bestStreak = 0;
                          });
                          _generateQuestion();
                        },
                        child: Text(
                          'Main Lagi',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  Widget _buildOption(String opt) {
    final isCorrect = opt == _question["arab"];
    final isSelected = opt == _selectedOption;

    Color bg = const Color(0xFFE8FFF0);
    Color border = const Color(0xFF50D1A0);
    Color text = const Color(0xFF42C88A);
    IconData? icon;

    if (_lockedAnswer) {
      if (isCorrect) {
        bg = const Color(0xFFD9F8E5);
        border = const Color(0xFF1E915B);
        text = const Color(0xFF1E915B);
        icon = Icons.check_circle_rounded;
      } else if (isSelected) {
        bg = const Color(0xFFFFE2E2);
        border = const Color(0xFFD84343);
        text = const Color(0xFFD84343);
        icon = Icons.cancel_rounded;
      } else {
        bg = Colors.white.withOpacity(0.75);
        border = Colors.grey.shade300;
        text = Colors.grey.shade600;
      }
    }

    return GestureDetector(
      onTap: () => _checkAnswer(opt),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              opt,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: text,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, color: text, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _currentQuestionIndex / _totalQuestion;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dengarkan & Tebak', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF50D1A0),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: -pi / 2,
                gravity: 0.35,
                colors: const [Colors.green, Colors.blue, Colors.orange],
                emissionFrequency: 0.1,
                numberOfParticles: 12,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFF42C88A),
                          backgroundColor: Colors.grey.shade200,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$_currentQuestionIndex/$_totalQuestion',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Streak: $_streak 🔥',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2F9E6E),
                        ),
                      ),
                      Text(
                        'Best: $_bestStreak',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: _playAudio,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: _isPlaying
                            ? const Color(0xFFD9F8E5)
                            : const Color(0xFFEAF9F0),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF42C88A).withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isPlaying ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
                            color: const Color(0xFF2F9E6E),
                            size: 30,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _isPlaying ? 'Memutar audio...' : 'Dengarkan suara',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2F9E6E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _feedback,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _feedback.contains('Benar')
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/background-mengaji.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.white.withOpacity(0.82),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Tebak huruf berdasarkan audio',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...options
                                .map((opt) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _buildOption(opt),
                                    ))
                                .toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
