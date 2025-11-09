import { Injectable, NotFoundException } from '@nestjs/common';

import { PrismaService } from '../common/prisma/prisma.service';
import { ProgramDetailDto } from './dto/program-detail.dto';
import { ProgramSummaryDto } from './dto/program-summary.dto';

@Injectable()
export class ProgramsService {
  constructor(private readonly prisma: PrismaService) {}

  async getCatalog(): Promise<ProgramSummaryDto[]> {
    const programs = await this.prisma.learningProgram.findMany({
      orderBy: { title: 'asc' },
    });

    return programs.map((program) => ({
      id: program.id,
      slug: program.slug,
      title: program.title,
      subtitle: program.subtitle ?? undefined,
      focusArea: program.focusArea,
      difficultyLevel: program.difficultyLevel,
      estimatedDurationWeeks: program.estimatedDurationWeeks,
      sellingPoints: program.sellingPoints,
      heroImageUrl: program.heroImageUrl ?? undefined,
    }));
  }

  async getDetail(identifier: string): Promise<ProgramDetailDto> {
    const program = await this.prisma.learningProgram.findFirst({
      where: {
        OR: [{ id: identifier }, { slug: identifier }],
      },
      include: {
        modules: { orderBy: { order: 'asc' } },
      },
    });

    if (!program) {
      throw new NotFoundException(`Program ${identifier} not found`);
    }

    return {
      id: program.id,
      slug: program.slug,
      title: program.title,
      subtitle: program.subtitle ?? undefined,
      focusArea: program.focusArea,
      difficultyLevel: program.difficultyLevel,
      estimatedDurationWeeks: program.estimatedDurationWeeks,
      sellingPoints: program.sellingPoints,
      heroImageUrl: program.heroImageUrl ?? undefined,
      modules: program.modules.map((module) => ({
        id: module.id,
        order: module.order,
        title: module.title,
        description: module.description ?? undefined,
        focusSurah: module.focusSurah ?? undefined,
        focusAyahRange: module.focusAyahRange ?? undefined,
        outcomes: module.outcomes,
        estimatedHours: module.estimatedHours,
      })),
    };
  }
}
