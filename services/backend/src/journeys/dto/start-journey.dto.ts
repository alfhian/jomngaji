import { IsOptional, IsString, IsUUID, MaxLength } from 'class-validator';

export class StartJourneyDto {
  @IsUUID()
  studentId!: string;

  @IsUUID()
  programId!: string;

  @IsOptional()
  @IsUUID()
  activeModuleId?: string;

  @IsOptional()
  @IsString()
  @MaxLength(180)
  focusStatement?: string;
}
