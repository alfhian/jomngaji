export interface ProgramSummaryDto {
  id: string;
  slug: string;
  title: string;
  subtitle?: string;
  focusArea: string;
  difficultyLevel: string;
  estimatedDurationWeeks: number;
  sellingPoints: string[];
  heroImageUrl?: string;
}
