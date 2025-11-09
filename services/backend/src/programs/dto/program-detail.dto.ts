import { ProgramSummaryDto } from './program-summary.dto';

export interface ProgramModuleDto {
  id: string;
  order: number;
  title: string;
  description?: string;
  focusSurah?: string;
  focusAyahRange?: string;
  outcomes: string[];
  estimatedHours: number;
}

export interface ProgramDetailDto extends ProgramSummaryDto {
  modules: ProgramModuleDto[];
}
