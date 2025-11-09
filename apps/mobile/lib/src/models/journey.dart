import 'learning_program.dart';

enum JourneyStageState { completed, current, upcoming }

enum MissionType { aiPractice, liveSession, reflection }

enum MissionStatus { upcoming, inProgress, complete, missed }

class JourneyStage {
  const JourneyStage({
    required this.title,
    required this.description,
    required this.state,
  });

  final String title;
  final String description;
  final JourneyStageState state;
}

class DailyMission {
  const DailyMission({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.scheduledFor,
    required this.durationMinutes,
    this.surah,
    this.ayahRange,
    this.repetitionGoal,
    this.resources = const [],
    this.ctaLabel,
  });

  final String id;
  final String title;
  final MissionType type;
  final MissionStatus status;
  final DateTime scheduledFor;
  final int durationMinutes;
  final String? surah;
  final String? ayahRange;
  final int? repetitionGoal;
  final List<String> resources;
  final String? ctaLabel;
}

class LearningJourney {
  const LearningJourney({
    required this.id,
    required this.program,
    required this.completionPercent,
    required this.focusStatement,
    required this.stages,
    required this.todayMissions,
    required this.nextAssessment,
    this.activeModule,
  });

  final String id;
  final LearningProgram program;
  final double completionPercent;
  final String focusStatement;
  final List<JourneyStage> stages;
  final List<DailyMission> todayMissions;
  final DateTime nextAssessment;
  final ProgramModule? activeModule;
}
