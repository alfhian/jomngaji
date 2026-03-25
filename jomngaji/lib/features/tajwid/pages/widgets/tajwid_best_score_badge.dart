import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../services/tajwid_quiz_service.dart';

enum TajwidBestScoreSource { quiz, recording }

class TajwidBestScoreBadge extends StatefulWidget {
  final String quizCode;
  final String label;
  final TajwidBestScoreSource source;

  const TajwidBestScoreBadge({
    super.key,
    required this.quizCode,
    this.label = 'Best score',
    this.source = TajwidBestScoreSource.quiz,
  });

  @override
  State<TajwidBestScoreBadge> createState() => _TajwidBestScoreBadgeState();
}

class _TajwidBestScoreBadgeState extends State<TajwidBestScoreBadge> {
  Future<double?> _load() async {
    try {
      if (widget.source == TajwidBestScoreSource.recording) {
        final combined = await TajwidQuizService.getCombinedProgress(
          widget.quizCode,
        );
        final recording = combined['recording_detail'];
        if (recording is Map<String, dynamic>) {
          return _extractBestScore(recording);
        }
      }

      final progress = await TajwidQuizService.getQuizProgress(widget.quizCode);
      return _extractBestScore(progress);
    } catch (_) {
      return null;
    }
  }

  double? _extractBestScore(Map<String, dynamic> progress) {
    double? parsePercent(dynamic raw, {bool percentAlready = true}) {
      final value = double.tryParse('${raw ?? ''}');
      if (value == null) return null;
      final normalized = percentAlready ? value : value * 100;
      return normalized.clamp(0, 100).toDouble();
    }

    return parsePercent(progress['best_score']) ??
        parsePercent(progress['highest_score']) ??
        parsePercent(progress['high_score']) ??
        parsePercent(progress['score']) ??
        parsePercent(progress['progress'], percentAlready: false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double?>(
      future: _load(),
      builder: (_, snapshot) {
        final score = snapshot.data;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFBDE9D4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, size: 14, color: Color(0xFF2F9E6E)),
              const SizedBox(width: 6),
              Text(
                '${widget.label}: ${score == null ? '--' : '${score.toStringAsFixed(0)}%'}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2F9E6E),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
