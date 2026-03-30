class PronunciationIssue {
  final String category;
  final String code;
  final String location;
  final int? startIndex;
  final int? endIndex;
  final String expected;
  final String actual;
  final String message;

  const PronunciationIssue({
    required this.category,
    required this.code,
    required this.location,
    required this.message,
    this.startIndex,
    this.endIndex,
    this.expected = '',
    this.actual = '',
  });

  factory PronunciationIssue.fromDynamic(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      int? parseIndex(dynamic value) {
        if (value is int) return value;
        if (value is double) return value.toInt();
        if (value is String) return int.tryParse(value);
        return null;
      }

      return PronunciationIssue(
        category: raw['category']?.toString() ?? '',
        code: raw['code']?.toString() ?? '',
        location: raw['location']?.toString() ?? '',
        message: raw['message']?.toString() ?? '',
        startIndex: parseIndex(raw['start_index']),
        endIndex: parseIndex(raw['end_index']),
        expected: raw['expected']?.toString() ?? '',
        actual: raw['actual']?.toString() ?? '',
      );
    }

    return PronunciationIssue(
      category: '',
      code: '',
      location: '',
      message: raw?.toString() ?? '',
    );
  }
}

class EvaluationResult {
  final int score;                 // 0–100 (scores.final)
  final String transcript;         // hasil ASR
  final String feedback;           // saran utama
  final List<String> errors;       // issues
  final List<PronunciationIssue> issueDetails;

  // Optional detail scores (bonus)
  final int? ayatScore;
  final int? audioScore;

  EvaluationResult({
    required this.score,
    required this.transcript,
    required this.feedback,
    required this.errors,
    required this.issueDetails,
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
    final issueDetails = (rawErrors as List<dynamic>)
        .map((e) => PronunciationIssue.fromDynamic(e))
        .toList();
    final errors = issueDetails.map((e) => e.message).where((m) => m.isNotEmpty).toList();

    return EvaluationResult(
      score: score,
      transcript: transcript,
      feedback: feedback,
      errors: errors,
      issueDetails: issueDetails,
      ayatScore: parseScore(scores['ayat']),
      audioScore: parseScore(scores['audio']),
    );
  }

  Map<String, dynamic> toJson() => {
        'score': score,
        'transcript': transcript,
        'feedback': feedback,
        'errors': errors,
        'issue_details': issueDetails
            .map(
              (e) => {
                'category': e.category,
                'code': e.code,
                'location': e.location,
                'start_index': e.startIndex,
                'end_index': e.endIndex,
                'expected': e.expected,
                'actual': e.actual,
                'message': e.message,
              },
            )
            .toList(),
        'ayat_score': ayatScore,
        'audio_score': audioScore,
      };
}
