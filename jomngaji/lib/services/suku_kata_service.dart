import 'dart:convert';

import 'package:http/http.dart' as http;

import '../features/auth/services/auth_service.dart';

class SukuKataLevel {
  final int id;
  final String title;
  final String description;
  final int totalQuestions;
  final int orderIndex;
  final bool isPremium;
  final bool isUnlocked;
  final int completedQuestions;
  final double averageScore;

  const SukuKataLevel({
    required this.id,
    required this.title,
    required this.description,
    required this.totalQuestions,
    required this.orderIndex,
    required this.isPremium,
    required this.isUnlocked,
    required this.completedQuestions,
    required this.averageScore,
  });

  factory SukuKataLevel.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v, {int fallback = 0}) => int.tryParse('${v ?? ''}') ?? fallback;
    double _toDouble(dynamic v, {double fallback = 0}) => double.tryParse('${v ?? ''}') ?? fallback;

    final id = _toInt(json['level_id'], fallback: _toInt(json['id']));

    return SukuKataLevel(
      id: id,
      title: (json['title'] ?? 'Level $id').toString(),
      description: (json['description'] ?? '').toString(),
      totalQuestions: _toInt(json['total_questions'], fallback: 5),
      orderIndex: _toInt(json['order_index'], fallback: id),
      isPremium: _toInt(json['is_premium']) == 1 || json['is_premium'] == true,
      isUnlocked: json['unlocked'] == true || json['is_unlocked'] == true || _toInt(json['unlocked']) == 1,
      completedQuestions: _toInt(json['completed_questions']),
      averageScore: _toDouble(json['average_score']),
    );
  }
}

class SukuKataLevelsPayload {
  final double progressPercentage;
  final List<SukuKataLevel> levels;

  const SukuKataLevelsPayload({
    required this.progressPercentage,
    required this.levels,
  });
}

class SukuKataQuestion {
  final int id;
  final int levelId;
  final String huruf;
  final String arabic;
  final String latin;

  const SukuKataQuestion({
    required this.id,
    required this.levelId,
    required this.huruf,
    required this.arabic,
    required this.latin,
  });

  factory SukuKataQuestion.fromJson(Map<String, dynamic> json, {int levelIdFallback = 0}) {
    int _toInt(dynamic v, {int fallback = 0}) => int.tryParse('${v ?? ''}') ?? fallback;

    final arabic = (json['arabic'] ?? '').toString();

    return SukuKataQuestion(
      id: _toInt(json['id']),
      levelId: _toInt(json['level_id'], fallback: levelIdFallback),
      huruf: (json['huruf'] ?? arabic).toString(),
      arabic: arabic,
      latin: (json['latin'] ?? '').toString().toUpperCase(),
    );
  }
}

class PremiumLockedException implements Exception {
  final String message;

  const PremiumLockedException([this.message = 'Level ini hanya untuk pengguna premium.']);

  @override
  String toString() => message;
}

class SukuKataService {
  static const String baseUrl = 'http://10.179.249.20:4000';

  static double _normalizeProgress(dynamic raw) {
    final parsed = double.tryParse('${raw ?? 0}') ?? 0;
    if (parsed > 1) {
      return (parsed / 100).clamp(0.0, 1.0);
    }
    return parsed.clamp(0.0, 1.0);
  }

  static Future<SukuKataLevelsPayload> getLevels() async {
    final headers = await AuthService.authHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/suku-kata/levels'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil level suku kata: ${response.body}');
    }

    final body = jsonDecode(response.body);
    final progress = body is Map<String, dynamic>
        ? _normalizeProgress(body['progress_percentage'])
        : 0.0;

    final raw = body is List
        ? body
        : (body is Map<String, dynamic>
            ? (body['levels'] ?? body['data'] ?? const [])
            : const []);

    if (raw is! List) {
      return const SukuKataLevelsPayload(progressPercentage: 0, levels: []);
    }

    final levels = raw
        .whereType<Map<String, dynamic>>()
        .map(SukuKataLevel.fromJson)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    return SukuKataLevelsPayload(
      progressPercentage: progress,
      levels: levels,
    );
  }

  static Future<List<SukuKataQuestion>> getLevelQuestions(int levelId) async {
    final headers = await AuthService.authHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/suku-kata/levels/$levelId/questions'),
      headers: headers,
    );

    if (response.statusCode == 403 && response.body.contains('PREMIUM_LOCKED')) {
      throw const PremiumLockedException();
    }

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil soal level: ${response.body}');
    }

    final body = jsonDecode(response.body);
    final raw = body is List
        ? body
        : (body is Map<String, dynamic>
            ? (body['questions'] ?? body['data'] ?? const [])
            : const []);

    if (raw is! List) return [];

    return raw
        .whereType<Map<String, dynamic>>()
        .map((e) => SukuKataQuestion.fromJson(e, levelIdFallback: levelId))
        .toList();
  }

  static Future<Map<String, dynamic>> submitLevelScore({
    required int levelId,
    required double score,
  }) async {
    final headers = await AuthService.authHeaders(
      extra: {'Content-Type': 'application/json'},
    );

    final response = await http.post(
      Uri.parse('$baseUrl/suku-kata/levels/$levelId/submit'),
      headers: headers,
      body: jsonEncode({'score': score}),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal submit score: ${response.body}');
    }

    final body = jsonDecode(response.body);
    if (body is Map<String, dynamic>) return body;
    return {'data': body};
  }
}
