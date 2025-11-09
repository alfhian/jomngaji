import { Body, Controller, Get, Param, Post } from '@nestjs/common';

import { JourneysService } from './journeys.service';
import { StartJourneyDto } from './dto/start-journey.dto';

@Controller('journeys')
export class JourneysController {
  constructor(private readonly journeysService: JourneysService) {}

  @Post()
  start(@Body() payload: StartJourneyDto) {
    return this.journeysService.startJourney(payload);
  }

  @Get('student/:studentId/active')
  activeForStudent(@Param('studentId') studentId: string) {
    return this.journeysService.getActiveJourneyForStudent(studentId);
  }

  @Get(':id')
  findById(@Param('id') id: string) {
    return this.journeysService.getById(id);
  }

  @Get(':id/dashboard')
  dashboard(@Param('id') id: string) {
    return this.journeysService.getDashboard(id);
  }
}
