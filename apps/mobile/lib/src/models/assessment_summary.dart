class AssessmentSummary {
  const AssessmentSummary({
    required this.overallScore,
    required this.tajwid,
    required this.fluency,
    required this.makhraj,
    required this.pacing,
    required this.recordedAt,
    required this.summary,
    required this.focusAreas,
  });

  final double overallScore;
  final double tajwid;
  final double fluency;
  final double makhraj;
  final double pacing;
  final DateTime recordedAt;
  final String summary;
  final List<String> focusAreas;
}
