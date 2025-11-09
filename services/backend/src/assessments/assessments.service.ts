import { Injectable, NotFoundException } from '@nestjs/common';

import { PrismaService } from '../common/prisma/prisma.service';
import { CreateVoiceAssessmentDto } from './dto/create-voice-assessment.dto';

@Injectable()
export class AssessmentsService {
  constructor(private readonly prisma: PrismaService) {}

  async createVoiceAssessment(payload: CreateVoiceAssessmentDto) {
    return this.prisma.voiceAssessment.create({
      data: {
        journey: { connect: { id: payload.journeyId } },
        assessmentType: payload.assessmentType,
        overallScore: payload.overallScore,
        tajwidScore: payload.tajwidScore,
        fluencyScore: payload.fluencyScore,
        makhrajScore: payload.makhrajScore,
        pacingScore: payload.pacingScore,
        summary: payload.summary,
        audioUrl: payload.audioUrl,
        focusAreas: payload.focusAreas,
      },
    });
  }

  async getLatestForJourney(journeyId: string) {
    const assessment = await this.prisma.voiceAssessment.findFirst({
      where: { journeyId },
      orderBy: { recordedAt: 'desc' },
    });

    if (!assessment) {
      throw new NotFoundException(`No assessment for journey ${journeyId}`);
    }

    return assessment;
  }
}
