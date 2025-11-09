import { Body, Controller, Get, Param, Post } from '@nestjs/common';

import { LessonsService } from './lessons.service';
import { CreateLessonDto } from './dto/create-lesson.dto';

@Controller('lessons')
export class LessonsController {
  constructor(private readonly lessonsService: LessonsService) {}

  @Get()
  findAll() {
    return this.lessonsService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.lessonsService.findById(id);
  }

  @Post()
  create(@Body() payload: CreateLessonDto) {
    return this.lessonsService.create(payload);
  }
}
