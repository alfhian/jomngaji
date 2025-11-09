import { IsOptional, IsString, IsUUID } from 'class-validator';

export class CreateLessonDto {
  @IsString()
  title!: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsUUID()
  teacherId!: string;
}
