import { ProgramSummaryDto } from '../../programs/dto/program-summary.dto';

export type JourneyStageState = 'completed' | 'current' | 'upcoming';

export interface JourneyStageDto {
  title: string;
  state: JourneyStageState;
  description: string;
}

export interface ActiveModuleDto {
  id: string;
  title: string;
  order: number;
}

export interface MissionDto {
  id: string;
  title: string;
  missionType: string;
  status: string;
  scheduledFor: string;
  durationMinutes: number;
  surah?: string;
  ayahRange?: string;
  repetitionGoal?: number;
  resources: string[];
}

export interface AssessmentSummaryDto {
  id: string;
  recordedAt: string;
  assessmentType: string;
  overallScore: number;
  tajwidScore: number;
  fluencyScore: number;
  makhrajScore: number;
  pacingScore: number;
  summary?: string;
  focusAreas: string[];
}

export interface CoachSessionDto {
  id: string;
  coachName: string;
  scheduledAt: string;
  status: string;
  meetingUrl?: string;
  agenda?: string;
}

export interface JourneySummaryDto {
  id: string;
  status: string;
  progressPercent: number;
  focusStatement?: string;
  upcomingAssessment?: string;
  program: ProgramSummaryDto;
  activeModule?: ActiveModuleDto;
  stages: JourneyStageDto[];
}

export interface JourneyDashboardDto {
  journey: JourneySummaryDto;
  todaysMissions: MissionDto[];
  latestAssessment?: AssessmentSummaryDto;
  upcomingCoachSessions: CoachSessionDto[];
}
