import { Controller, Get, Param } from '@nestjs/common';

import { ProgramsService } from './programs.service';

@Controller('programs')
export class ProgramsController {
  constructor(private readonly programsService: ProgramsService) {}

  @Get()
  list() {
    return this.programsService.getCatalog();
  }

  @Get(':identifier')
  detail(@Param('identifier') identifier: string) {
    return this.programsService.getDetail(identifier);
  }
}
