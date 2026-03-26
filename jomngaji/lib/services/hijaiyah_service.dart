import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../features/auth/services/auth_service.dart';

class HijaiyahLesson {
  final int id;
  final String title;
  final String description;
  final int orderIndex;
  final int totalLetters;
  final int completedLetters;
  final double averageScore;
  final bool isUnlocked;
  final bool isPremium;

  const HijaiyahLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.orderIndex,
    required this.totalLetters,
    required this.completedLetters,
    required this.averageScore,
    required this.isUnlocked,
    required this.isPremium,
  });

  factory HijaiyahLesson.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value, {int fallback = 0}) {
      return int.tryParse('${value ?? ''}') ?? fallback;
    }

    double toDouble(dynamic value, {double fallback = 0}) {
      return double.tryParse('${value ?? ''}') ?? fallback;
    }

    final id = toInt(json['lesson_id'], fallback: toInt(json['id']));

    return HijaiyahLesson(
      id: id,
      title: (json['title'] ?? 'Pelajaran $id').toString(),
      description: (json['description'] ?? '').toString(),
      orderIndex: toInt(json['order_index'], fallback: id),
      totalLetters: toInt(json['total_letters'], fallback: 2),
      completedLetters: toInt(json['completed_letters']),
      averageScore: toDouble(json['average_score']),
      isUnlocked: json['unlocked'] == true || toInt(json['unlocked']) == 1,
      isPremium: json['is_premium'] == true || toInt(json['is_premium']) == 1,
    );
  }
}

class HijaiyahLessonsPayload {
  final List<HijaiyahLesson> lessons;
  final double progress;

  const HijaiyahLessonsPayload({
    required this.lessons,
    required this.progress,
  });
}

class HijaiyahService {
  static String get baseUrl => ApiConfig.baseUrl;

  static double _normalizeProgress(dynamic raw) {
    final parsed = double.tryParse('${raw ?? 0}') ?? 0;
    if (parsed > 1) return (parsed / 100).clamp(0.0, 1.0);
    return parsed.clamp(0.0, 1.0);
  }

  static Future<void> submitLessonProgress({
    required int lessonId,
    required int completedLetters,
    required double score,
  }) async {
    final headers = await AuthService.authHeaders(
      extra: {'Content-Type': 'application/json'},
    );

    final response = await http.post(
      Uri.parse('$baseUrl/hijaiyah/lessons/$lessonId/submit'),
      headers: headers,
      body: jsonEncode({
        'completed_letters': completedLetters,
        'score': score,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal submit progress hijaiyah: ${response.body}');
    }
  }

  static Future<void> unlockLesson(int lessonId) async {
    final headers = await AuthService.authHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/hijaiyah/lessons/$lessonId/unlock'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal unlock lesson hijaiyah: ${response.body}');
    }
  }

  static Future<HijaiyahLessonsPayload> getLessons() async {
    final headers = await AuthService.authHeaders();

    final lessonsRes = await http.get(
      Uri.parse('$baseUrl/hijaiyah/lessons/status'),
      headers: headers,
    );

    if (lessonsRes.statusCode != 200) {
      throw Exception('Gagal mengambil lesson hijaiyah: ${lessonsRes.body}');
    }

    final lessonsBody = jsonDecode(lessonsRes.body);
    final rawLessons = lessonsBody is Map<String, dynamic>
        ? (lessonsBody['lessons'] ?? lessonsBody['data'] ?? const [])
        : const [];

    if (rawLessons is! List) {
      return const HijaiyahLessonsPayload(lessons: [], progress: 0);
    }

    final lessons = rawLessons
        .whereType<Map<String, dynamic>>()
        .map(HijaiyahLesson.fromJson)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    final totalLetters = lessons.fold<int>(0, (sum, lesson) => sum + lesson.totalLetters);
    final completedLetters = lessons.fold<int>(
      0,
      (sum, lesson) => sum + lesson.completedLetters.clamp(0, lesson.totalLetters),
    );

    double progress = totalLetters > 0 ? completedLetters / totalLetters : 0;
    progress = progress.clamp(0.0, 1.0);

    // Fallback ke endpoint global jika lesson belum memberikan data yang cukup.
    if (totalLetters == 0) {
      final progressRes = await http.get(
        Uri.parse('$baseUrl/hijaiyah/global-progress'),
        headers: headers,
      );

      if (progressRes.statusCode == 200) {
        final progressBody = jsonDecode(progressRes.body);
        if (progressBody is Map<String, dynamic>) {
          progress = _normalizeProgress(progressBody['percentage']);
        }
      }
    }

    return HijaiyahLessonsPayload(lessons: lessons, progress: progress);
  }
}
