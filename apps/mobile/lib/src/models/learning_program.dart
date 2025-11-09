import 'package:flutter/material.dart';

class ProgramModule {
  const ProgramModule({
    required this.id,
    required this.order,
    required this.title,
    required this.description,
    required this.focusSurah,
    required this.ayahRange,
    required this.estimatedMinutes,
    required this.outcomes,
  });

  final String id;
  final int order;
  final String title;
  final String description;
  final String focusSurah;
  final String ayahRange;
  final int estimatedMinutes;
  final List<String> outcomes;
}

class LearningProgram {
  const LearningProgram({
    required this.id,
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.focusArea,
    required this.level,
    required this.estimatedWeeks,
    required this.accentColor,
    required this.sellingPoints,
    required this.modules,
  });

  final String id;
  final String slug;
  final String title;
  final String subtitle;
  final String focusArea;
  final String level;
  final int estimatedWeeks;
  final Color accentColor;
  final List<String> sellingPoints;
  final List<ProgramModule> modules;
}
