import { Injectable, NotFoundException } from '@nestjs/common';
import { addDays, isSameDay } from 'date-fns';

import { PrismaService } from '../common/prisma/prisma.service';
import { JourneyDashboardDto } from './dto/journey-dashboard.dto';
import { StartJourneyDto } from './dto/start-journey.dto';

const JOURNEY_STAGE_BLUEPRINT = [
  {
    title: 'Assessment & Goal Setting',
    description: 'Benchmark bacaan awal bersama AI untuk memetakan kekuatan dan fokus tajwid.',
  },
  {
    title: 'Bootcamp Foundations',
    description: 'Pendalaman makhraj dan tahsin inti bersama mentor.',
  },
  {
    title: 'AI Guided Practice',
    description: 'Latihan harian adaptif dengan umpan balik otomatis.',
  },
  {
    title: 'Mastery & Certification',
    description: 'Kelas langsung dan evaluasi akhir bersama coach.',
  },
] as const;

@Injectable()
export class JourneysService {
  constructor(private readonly prisma: PrismaService) {}

  async startJourney(payload: StartJourneyDto) {
    const journey = await this.prisma.learningJourney.create({
      data: {
        student: { connect: { id: payload.studentId } },
        program: { connect: { id: payload.programId } },
        focusStatement: payload.focusStatement,
        activeModule: payload.activeModuleId
          ? { connect: { id: payload.activeModuleId } }
          : undefined,
        status: 'ACTIVE',
        progressPercent: 5,
        upcomingAssessment: addDays(new Date(), 7),
      },
      include: {
        program: true,
      },
    });

    return journey;
  }

  async getById(id: string) {
    const journey = await this.prisma.learningJourney.findUnique({
      where: { id },
      include: {
        program: true,
        activeModule: true,
        missions: true,
        assessments: true,
        coachSessions: true,
      },
    });

    if (!journey) {
      throw new NotFoundException(`Journey ${id} not found`);
    }

    return journey;
  }

  async getActiveJourneyForStudent(studentId: string) {
    const journey = await this.prisma.learningJourney.findFirst({
      where: {
        studentId,
        status: { in: ['ACTIVE', 'ONBOARDING'] },
      },
      orderBy: { startedAt: 'desc' },
      include: {
        program: true,
        activeModule: true,
      },
    });

    if (!journey) {
      throw new NotFoundException(`Active journey for student ${studentId} not found`);
    }

    return journey;
  }

  async getDashboard(journeyId: string): Promise<JourneyDashboardDto> {
    const journey = await this.prisma.learningJourney.findUnique({
      where: { id: journeyId },
      include: {
        program: true,
        activeModule: true,
        missions: {
          orderBy: { scheduledFor: 'asc' },
        },
        assessments: {
          orderBy: { recordedAt: 'desc' },
        },
        coachSessions: {
          orderBy: { scheduledAt: 'asc' },
          include: {
            coach: true,
          },
        },
      },
    });

    if (!journey) {
      throw new NotFoundException(`Journey ${journeyId} not found`);
    }

    const stageIndex = this.resolveStageIndex(journey.status, journey.progressPercent);
    const stages = JOURNEY_STAGE_BLUEPRINT.map((stage, index) => ({
      title: stage.title,
      description: stage.description,
      state: index < stageIndex ? 'completed' : index === stageIndex ? 'current' : 'upcoming',
    }));

    const todaysMissions = journey.missions
      .filter((mission) => isSameDay(new Date(mission.scheduledFor), new Date()))
      .map((mission) => ({
        id: mission.id,
        title: mission.title,
        missionType: mission.missionType,
        status: mission.status,
        scheduledFor: mission.scheduledFor.toISOString(),
        durationMinutes: mission.durationMinutes,
        surah: mission.surah ?? undefined,
        ayahRange: mission.ayahRange ?? undefined,
        repetitionGoal: mission.repetitionGoal ?? undefined,
        resources: mission.resources,
      }));

    const latestAssessment = journey.assessments[0];

    const upcomingCoachSessions = journey.coachSessions
      .filter((session) => session.status !== 'CANCELLED' && session.scheduledAt > new Date())
      .map((session) => ({
        id: session.id,
        coachName: session.coach?.displayName ?? 'Coach',
        scheduledAt: session.scheduledAt.toISOString(),
        status: session.status,
        meetingUrl: session.meetingUrl ?? undefined,
        agenda: session.agenda ?? undefined,
      }));

    return {
      journey: {
        id: journey.id,
        status: journey.status,
        progressPercent: journey.progressPercent,
        focusStatement: journey.focusStatement ?? undefined,
        upcomingAssessment: journey.upcomingAssessment?.toISOString(),
        program: {
          id: journey.program.id,
          slug: journey.program.slug,
          title: journey.program.title,
          subtitle: journey.program.subtitle ?? undefined,
          focusArea: journey.program.focusArea,
          difficultyLevel: journey.program.difficultyLevel,
          estimatedDurationWeeks: journey.program.estimatedDurationWeeks,
          sellingPoints: journey.program.sellingPoints,
          heroImageUrl: journey.program.heroImageUrl ?? undefined,
        },
        activeModule: journey.activeModule
          ? {
              id: journey.activeModule.id,
              title: journey.activeModule.title,
              order: journey.activeModule.order,
            }
          : undefined,
        stages,
      },
      todaysMissions,
      latestAssessment: latestAssessment
        ? {
            id: latestAssessment.id,
            recordedAt: latestAssessment.recordedAt.toISOString(),
            assessmentType: latestAssessment.assessmentType,
            overallScore: latestAssessment.overallScore,
            tajwidScore: latestAssessment.tajwidScore,
            fluencyScore: latestAssessment.fluencyScore,
            makhrajScore: latestAssessment.makhrajScore,
            pacingScore: latestAssessment.pacingScore,
            summary: latestAssessment.summary ?? undefined,
            focusAreas: latestAssessment.focusAreas,
          }
        : undefined,
      upcomingCoachSessions,
    };
  }

  private resolveStageIndex(status: string, progressPercent: number) {
    if (status === 'COMPLETED') {
      return JOURNEY_STAGE_BLUEPRINT.length;
    }

    if (progressPercent >= 90) {
      return JOURNEY_STAGE_BLUEPRINT.length - 1;
    }

    if (progressPercent >= 60) {
      return 2;
    }

    if (progressPercent >= 30) {
      return 1;
    }

    return 0;
  }
}
