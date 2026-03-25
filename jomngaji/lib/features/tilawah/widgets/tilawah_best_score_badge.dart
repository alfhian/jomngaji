import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../features/auth/services/auth_service.dart';

enum TilawahBestScoreSource { quiz, recording }

class TilawahBestScoreBadge extends StatefulWidget {
  final String quizCode;
  final int lessonId;
  final String label;
  final TilawahBestScoreSource source;

  const TilawahBestScoreBadge({
    super.key,
    required this.quizCode,
    required this.lessonId,
    this.label = 'Best score',
    this.source = TilawahBestScoreSource.quiz,
  });

  @override
  State<TilawahBestScoreBadge> createState() => _TilawahBestScoreBadgeState();
}

class _TilawahBestScoreBadgeState extends State<TilawahBestScoreBadge> {
  Future<double?> _load() async {
    try {
      final headers = await AuthService.authHeaders();
      if (widget.source == TilawahBestScoreSource.recording) {
        final res = await http.get(
          Uri.parse('${AuthService.baseUrl}/evaluate/tilawah/last?lesson_id=${widget.lessonId}'),
          headers: headers,
        );

        if (res.statusCode == 200) {
          final body = jsonDecode(res.body);
          if (body is Map<String, dynamic>) {
            final raw = body['score_final'] ?? body['best_score'] ?? body['score'];
            final value = double.tryParse('${raw ?? ''}');
            return value?.clamp(0, 100).toDouble();
          }
        }
        return null;
      }

      final res = await http.get(
        Uri.parse('${AuthService.baseUrl}/quizzes/${widget.quizCode}/progress'),
        headers: headers,
      );

      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body);
      if (body is! Map<String, dynamic>) return null;

      final raw = body['best_score'] ?? body['highest_score'] ?? body['score'];
      final value = double.tryParse('${raw ?? ''}');
      return value?.clamp(0, 100).toDouble();
    } catch (_) {
      return null;
    }
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
