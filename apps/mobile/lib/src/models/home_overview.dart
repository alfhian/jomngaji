import 'assessment_summary.dart';
import 'coach_session.dart';
import 'community_highlight.dart';
import 'journey.dart';
import 'learning_program.dart';
import 'student_profile.dart';

class HomeOverview {
  const HomeOverview({
    required this.profile,
    required this.journey,
    required this.recommendedPrograms,
    required this.assessment,
    required this.upcomingSessions,
    required this.communityHighlights,
  });

  final StudentProfile profile;
  final LearningJourney journey;
  final List<LearningProgram> recommendedPrograms;
  final AssessmentSummary assessment;
  final List<CoachSession> upcomingSessions;
  final List<CommunityHighlight> communityHighlights;
}
