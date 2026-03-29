import 'dart:io';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../core/widgets/custom_gradient_appbar.dart';
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

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(24),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: isCorrect ? AppColors.accent : Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        content: Row(
          children: [
            Icon(isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isCorrect
                    ? 'Luar biasa! +5 XP | Streak: $_streak 🔥'
                    : 'Kurang tepat. Jawaban benar: ${_question["arab"]}',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    if (_currentQuestionIndex >= _totalQuestion) {
      _showResultDialog();
      return;
    }

    setState(() => _currentQuestionIndex++);
    _generateQuestion();
  }

  void _showResultDialog() {
    final percent = ((_correctCount / _totalQuestion) * 100).round();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events_rounded, color: AppColors.accent, size: 64),
              ),
              const SizedBox(height: 24),
              Text(
                _correctCount >= 7 ? 'Luar Biasa! ✨' : 'Latihan Selesai!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Benar: $_correctCount/$_totalQuestion\nBest streak: $_bestStreak',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '$percent%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Saran: gunakan headset dan dengarkan audio dengan seksama untuk hasil maksimal.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textPlaceholder,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actions: [
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Kembali ke Menu'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
                child: const Text('Main Lagi'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOption(String opt) {
    final isCorrect = opt == _question["arab"];
    final isSelected = opt == _selectedOption;

    Color bg = Colors.white;
    Color border = AppColors.border;
    Color text = AppColors.textPrimary;
    IconData? icon;

    if (_lockedAnswer) {
      if (isCorrect) {
        bg = AppColors.accent.withOpacity(0.1);
        border = AppColors.accent;
        text = AppColors.accent;
        icon = Icons.check_circle_rounded;
      } else if (isSelected) {
        bg = Colors.redAccent.withOpacity(0.1);
        border = Colors.redAccent;
        text = Colors.redAccent;
        icon = Icons.cancel_rounded;
      } else {
        bg = AppColors.scaffold;
        border = AppColors.border.withOpacity(0.5);
        text = AppColors.textPlaceholder;
      }
    } else if (isSelected) {
      border = AppColors.accent;
    }

    return GestureDetector(
      onTap: () => _checkAnswer(opt),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: border,
            width: isSelected || (_lockedAnswer && isCorrect) ? 2 : 1,
          ),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              opt,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: text,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 12),
              Icon(icon, color: text, size: 28),
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
      backgroundColor: AppColors.scaffold,
      appBar: const CustomGradientAppBar(title: 'Dengarkan & Tebak'),
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: -pi / 2,
                gravity: 0.35,
                colors: const [AppColors.accent, AppColors.secondary, AppColors.gold],
                emissionFrequency: 0.1,
                numberOfParticles: 12,
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: AppShadows.soft,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Soal $_currentQuestionIndex dari $_totalQuestion',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppRadius.full),
                              ),
                              child: Text(
                                'Streak: $_streak 🔥',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.gold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0, 1),
                            minHeight: 10,
                            backgroundColor: AppColors.scaffold,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: _playAudio,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: AppShadows.medium,
                        border: Border.all(
                          color: _isPlaying ? AppColors.accent : AppColors.border.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: (_isPlaying ? AppColors.accent : AppColors.primary).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPlaying ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
                              color: _isPlaying ? AppColors.accent : AppColors.primary,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _isPlaying ? 'Memutar Audio...' : 'Tekan untuk Mendengar',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _isPlaying ? AppColors.accent : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Tebak huruf yang kamu dengar",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...options.map((opt) => _buildOption(opt)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
