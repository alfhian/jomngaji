class StudentProfile {
  const StudentProfile({
    required this.name,
    required this.level,
    required this.primaryGoal,
    required this.streakDays,
    required this.completedSessions,
    required this.timezone,
    required this.nextCheckIn,
  });

  final String name;
  final String level;
  final String primaryGoal;
  final int streakDays;
  final int completedSessions;
  final String timezone;
  final DateTime nextCheckIn;
}
