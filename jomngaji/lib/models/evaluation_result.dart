class EvaluationResult {
  final int score;                 // 0–100 (scores.final)
  final String transcript;         // hasil ASR
  final String feedback;           // saran utama
  final List<String> errors;       // issues

  // Optional detail scores (bonus)
  final int? ayatScore;
  final int? audioScore;

  EvaluationResult({
    required this.score,
    required this.transcript,
    required this.feedback,
    required this.errors,
    this.ayatScore,
    this.audioScore,
  });

  factory EvaluationResult.fromJson(Map<String, dynamic> json) {
    // =============================
    // SCORE (🔥 FIX)
    // =============================
    final scores = json['scores'] as Map<String, dynamic>? ?? {};

    int parseScore(dynamic v) {
      return switch (v) {
        int s => s,
        double s => s.round(),
        String s => int.tryParse(s) ?? 0,
        _ => 0,
      };
    }

    final score = parseScore(
      scores['final'] ?? json['score'], // fallback lama
    );

    // =============================
    // TRANSCRIPT
    // =============================
    final transcript = json['text']?.toString() ?? '';

    // =============================
    // FEEDBACK
    // =============================
    final feedback =
        json['feedback']?.toString() ??
        ((json['suggestions'] as List<dynamic>? ?? []).isNotEmpty
            ? json['suggestions'].first.toString()
            : '');

    // =============================
    // ERRORS / ISSUES
    // =============================
    final rawErrors = json['issues'] ?? json['errors'] ?? const <dynamic>[];

    final errors = (rawErrors as List<dynamic>)
        .map((e) => e is Map && e.containsKey('message')
            ? e['message'].toString()
            : e.toString())
        .toList();

    return EvaluationResult(
      score: score,
      transcript: transcript,
      feedback: feedback,
      errors: errors,
      ayatScore: parseScore(scores['ayat']),
      audioScore: parseScore(scores['audio']),
    );
  }

  Map<String, dynamic> toJson() => {
        'score': score,
        'transcript': transcript,
        'feedback': feedback,
        'errors': errors,
        'ayat_score': ayatScore,
        'audio_score': audioScore,
      };
}
