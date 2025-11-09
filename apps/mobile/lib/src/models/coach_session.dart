class CoachSession {
  const CoachSession({
    required this.id,
    required this.coachName,
    required this.scheduledAt,
    required this.status,
    required this.mode,
    this.meetingUrl,
    this.agenda,
  });

  final String id;
  final String coachName;
  final DateTime scheduledAt;
  final String status;
  final String mode;
  final String? meetingUrl;
  final String? agenda;
}
