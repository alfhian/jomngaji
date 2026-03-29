import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../models/evaluation_result.dart';

class TadarusEvaluationResultPage extends StatelessWidget {
  final EvaluationResult result;
  final String ayahText;
  final int currentAyah;
  final int totalAyah;

  const TadarusEvaluationResultPage({
    super.key,
    required this.result,
    required this.ayahText,
    required this.currentAyah,
    required this.totalAyah,
  });

  static bool _isArabicDiacritic(int codeUnit) {
    return (codeUnit >= 0x0610 && codeUnit <= 0x061A) ||
        (codeUnit >= 0x064B && codeUnit <= 0x065F) ||
        codeUnit == 0x0670 ||
        codeUnit == 0x06ED ||
        codeUnit == 0x0640;
  }

  static bool _isWhitespaceOrMark(String char) {
    final code = char.codeUnitAt(0);
    if (char.trim().isEmpty) return true;
    return _isArabicDiacritic(code);
  }

  List<TextSpan> _highlightedAyahSpans() {
    final issues = result.issueDetails.where((e) {
      return e.location == 'huruf' &&
          e.startIndex != null &&
          e.endIndex != null &&
          e.endIndex! > e.startIndex!;
    }).toList();

    if (issues.isEmpty) {
      return [
        TextSpan(
          text: ayahText,
          style: GoogleFonts.amiri(
            fontSize: 38,
            height: 1.9,
            color: AppColors.textPrimary,
          ),
        ),
      ];
    }

    final normalizedToOriginal = <int>[];
    for (int i = 0; i < ayahText.length; i++) {
      if (_isWhitespaceOrMark(ayahText[i])) continue;
      normalizedToOriginal.add(i);
    }

    final highlighted = <int>{};
    for (final issue in issues) {
      final start = issue.startIndex!;
      final endExclusive = issue.endIndex!;
      if (normalizedToOriginal.isEmpty || start < 0) continue;
      final safeStart = math.min(start, normalizedToOriginal.length - 1);
      final safeEnd = math.min(
        math.max(endExclusive - 1, safeStart),
        normalizedToOriginal.length - 1,
      );
      for (int i = safeStart; i <= safeEnd; i++) {
        highlighted.add(normalizedToOriginal[i]);
      }
    }

    return List.generate(ayahText.length, (i) {
      final active = highlighted.contains(i);
      return TextSpan(
        text: ayahText[i],
        style: GoogleFonts.amiri(
          fontSize: 38,
          height: 1.9,
          color: active ? Colors.redAccent : AppColors.textPrimary,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final score = result.score.clamp(0, 100);
    final hasNext = currentAyah < totalAyah;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: const Color(0xFF78C9A6),
        foregroundColor: Colors.white,
        title: Text(
          'Penilaian',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            color: const Color(0xFF78C9A6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    result.feedback.isNotEmpty ? result.feedback : 'Pelafalanmu sudah baik. Pertahankan!',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 74,
                  height: 74,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 7,
                    backgroundColor: Colors.white38,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECF8F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Koreksi pelafalan didukung teknologi AI',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF3E9A73),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(children: _highlightedAyahSpans()),
                  ),
                ),
                const SizedBox(height: 16),
                if (result.errors.isNotEmpty)
                  ...result.errors.take(2).map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '• $e',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, 'retry'),
                    child: const Text('Ulang'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, hasNext ? 'next' : 'done'),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
                    child: Text(hasNext ? 'Lanjut Ayat ${currentAyah + 1}' : 'Selesai'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
