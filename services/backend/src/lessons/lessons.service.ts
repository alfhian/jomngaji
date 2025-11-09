import { Injectable, NotFoundException } from '@nestjs/common';

import { PrismaService } from '../common/prisma/prisma.service';
import { CreateLessonDto } from './dto/create-lesson.dto';

@Injectable()
export class LessonsService {
  constructor(private readonly prisma: PrismaService) {}

  findAll() {
    return this.prisma.lesson.findMany({ include: { teacher: true, recordings: true } });
  }

  async findById(id: string) {
    const lesson = await this.prisma.lesson.findUnique({
      where: { id },
      include: { teacher: true, recordings: true },
    });

    if (!lesson) {
      throw new NotFoundException(`Lesson ${id} not found`);
    }

    return lesson;
  }

  async create(payload: CreateLessonDto) {
    return this.prisma.lesson.create({
      data: {
        title: payload.title,
        description: payload.description,
        teacher: {
          connect: { id: payload.teacherId },
        },
      },
    });
  }
}
