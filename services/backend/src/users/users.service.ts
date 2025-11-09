import { Injectable, NotFoundException, UnauthorizedException } from '@nestjs/common';
import * as bcrypt from 'bcryptjs';

import { PrismaService } from '../common/prisma/prisma.service';
import { SignUpDto } from '../auth/dto/sign-up.dto';
import { UserRole } from './user-role.enum';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async createUser(payload: SignUpDto) {
    const passwordHash = await bcrypt.hash(payload.password, 10);
    const role = payload.role ?? UserRole.STUDENT;

    return this.prisma.user.create({
      data: {
        email: payload.email,
        passwordHash,
        displayName: payload.displayName,
        role,
        studentProfile:
          role === UserRole.STUDENT
            ? {
                create: {
                  intakeLevel: payload.intakeLevel ?? 'beginner',
                  primaryGoal: payload.primaryGoal,
                  timezone: payload.timezone,
                  motivationNote: payload.motivationNote,
                },
              }
            : undefined,
        coachProfile:
          role === UserRole.COACH
            ? {
                create: {
                  bio: payload.motivationNote,
                  expertise: [],
                },
              }
            : undefined,
      },
      include: {
        studentProfile: true,
        coachProfile: true,
      },
    });
  }

  async validateUser(email: string, password: string) {
    const user = await this.prisma.user.findUnique({ where: { email } });
    const isValid = user && (await bcrypt.compare(password, user.passwordHash));
    if (!isValid) {
      throw new UnauthorizedException('Invalid credentials');
    }
    return user;
  }

  async findAll() {
    return this.prisma.user.findMany({
      include: {
        studentProfile: true,
        coachProfile: true,
        journeys: true,
        coachSessions: true,
      },
    });
  }

  async findById(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      include: {
        studentProfile: true,
        coachProfile: true,
        journeys: {
          include: {
            program: true,
            activeModule: true,
          },
        },
        coachSessions: true,
      },
    });

    if (!user) {
      throw new NotFoundException(`User ${id} not found`);
    }

    return user;
  }
}
