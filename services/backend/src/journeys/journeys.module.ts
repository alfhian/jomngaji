import { Module } from '@nestjs/common';

import { PrismaModule } from '../common/prisma/prisma.module';
import { JourneysController } from './journeys.controller';
import { JourneysService } from './journeys.service';

@Module({
  imports: [PrismaModule],
  controllers: [JourneysController],
  providers: [JourneysService],
  exports: [JourneysService],
})
export class JourneysModule {}
