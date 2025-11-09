import {
  ArrayMinSize,
  IsArray,
  IsEnum,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
} from 'class-validator';

enum AssessmentTypeDto {
  ONBOARDING = 'ONBOARDING',
  WEEKLY = 'WEEKLY',
  CHECKPOINT = 'CHECKPOINT',
}

export class CreateVoiceAssessmentDto {
  @IsUUID()
  journeyId!: string;

  @IsEnum(AssessmentTypeDto)
  assessmentType!: AssessmentTypeDto;

  @IsNumber()
  @Min(0)
  @Max(100)
  overallScore!: number;

  @IsNumber()
  @Min(0)
  @Max(100)
  tajwidScore!: number;

  @IsNumber()
  @Min(0)
  @Max(100)
  fluencyScore!: number;

  @IsNumber()
  @Min(0)
  @Max(100)
  makhrajScore!: number;

  @IsNumber()
  @Min(0)
  @Max(100)
  pacingScore!: number;

  @IsOptional()
  @IsString()
  summary?: string;

  @IsOptional()
  @IsString()
  audioUrl?: string;

  @IsArray()
  @ArrayMinSize(1)
  @IsString({ each: true })
  focusAreas!: string[];
}

export { AssessmentTypeDto };
