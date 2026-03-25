import 'dart:convert';

import 'package:http/http.dart' as http;

import '../features/auth/services/auth_service.dart';

class TajwidQuizQuestion {
  final int id;
  final String questionText;
  final List<String> options;
  final String correctAnswer;

  const TajwidQuizQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });

  factory TajwidQuizQuestion.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value, {int fallback = 0}) {
      return int.tryParse('${value ?? ''}') ?? fallback;
    }

    List<String> parseOptions(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      if (raw is String && raw.isNotEmpty) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            return decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {}
      }
      return const [];
    }

    final options = parseOptions(json['options']);

    return TajwidQuizQuestion(
      id: toInt(json['question_id'], fallback: toInt(json['id'])),
      questionText: (json['question_text'] ?? json['question'] ?? '').toString(),
      options: options,
      correctAnswer: (json['correct_answer'] ?? '').toString(),
    );
  }
}

class TajwidQuizPayload {
  final List<TajwidQuizQuestion> questions;

  const TajwidQuizPayload({
    required this.questions,
  });
}

class TajwidQuizService {
  static String get _baseUrl => AuthService.baseUrl;

  static Future<TajwidQuizPayload> fetchQuestions(String quizCode) async {
    final res = await http.get(Uri.parse('$_baseUrl/quizzes/$quizCode/questions'));

    if (res.statusCode != 200) {
      throw Exception('Gagal mengambil soal quiz ($quizCode): ${res.body}');
    }

    final body = jsonDecode(res.body);
    // Backend saat ini mengembalikan List langsung:
    // [ {question_id, question_text, options}, ... ]
    if (body is List) {
      final questions = body
          .whereType<Map<String, dynamic>>()
          .map(TajwidQuizQuestion.fromJson)
          .where((q) => q.questionText.isNotEmpty && q.options.isNotEmpty)
          .toList();

      return TajwidQuizPayload(questions: questions);
    }

    // Jaga kompatibilitas bila backend diubah ke bentuk map.
    if (body is! Map<String, dynamic>) {
      return const TajwidQuizPayload(questions: []);
    }

    final rawQuestions = body['questions'];

    if (rawQuestions is! List) {
      return const TajwidQuizPayload(questions: []);
    }

    final questions = rawQuestions
        .whereType<Map<String, dynamic>>()
        .map(TajwidQuizQuestion.fromJson)
        .where((q) => q.questionText.isNotEmpty && q.options.isNotEmpty)
        .toList();

    return TajwidQuizPayload(questions: questions);
  }

  static Future<Map<String, dynamic>> submitQuiz({
    required String quizCode,
    required List<Map<String, dynamic>> answers,
  }) async {
    final headers = await AuthService.authHeaders(
      extra: {'Content-Type': 'application/json'},
    );

    final payload = {
      'answers': answers,
    };

    final res = await http.post(
      Uri.parse('$_baseUrl/quizzes/$quizCode/submit'),
      headers: headers,
      body: jsonEncode(payload),
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal submit quiz ($quizCode): ${res.body}');
    }

    final body = jsonDecode(res.body);
    return body is Map<String, dynamic> ? body : <String, dynamic>{};
  }

  static Future<Map<String, dynamic>> getQuizProgress(String quizCode) async {
    final headers = await AuthService.authHeaders();

    final res = await http.get(
      Uri.parse('$_baseUrl/quizzes/$quizCode/progress'),
      headers: headers,
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal mengambil progress quiz ($quizCode): ${res.body}');
    }

    final body = jsonDecode(res.body);
    return body is Map<String, dynamic> ? body : <String, dynamic>{};
  }

  static Future<Map<String, dynamic>> getCombinedProgress(String quizCode) async {
    final headers = await AuthService.authHeaders();

    final res = await http.get(
      Uri.parse('$_baseUrl/tajwid/$quizCode/combined-progress'),
      headers: headers,
    );

    if (res.statusCode != 200) {
      throw Exception(
        'Gagal mengambil combined progress tajwid ($quizCode): ${res.body}',
      );
    }

    final body = jsonDecode(res.body);
    return body is Map<String, dynamic> ? body : <String, dynamic>{};
  }
}
