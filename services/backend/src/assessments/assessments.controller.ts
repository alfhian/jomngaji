import { Body, Controller, Get, Param, Post } from '@nestjs/common';

import { AssessmentsService } from './assessments.service';
import { CreateVoiceAssessmentDto } from './dto/create-voice-assessment.dto';

@Controller('assessments')
export class AssessmentsController {
  constructor(private readonly assessmentsService: AssessmentsService) {}

  @Post('voice')
  createVoice(@Body() payload: CreateVoiceAssessmentDto) {
    return this.assessmentsService.createVoiceAssessment(payload);
  }

  @Get('journey/:journeyId/latest')
  latestForJourney(@Param('journeyId') journeyId: string) {
    return this.assessmentsService.getLatestForJourney(journeyId);
  }
}
