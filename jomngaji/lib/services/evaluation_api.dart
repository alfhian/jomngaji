import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../features/auth/services/auth_service.dart';

class EvaluationApi {
  final String baseUrl;
  final http.Client _client;

  EvaluationApi(this.baseUrl, {http.Client? client})
      : _client = client ?? http.Client();

  Exception _error(int status, String body) {
    return Exception('[$status] $body');
  }

  Map<String, dynamic> _decode(String body) {
    return jsonDecode(body) as Map<String, dynamic>;
  }

  Future<Map<String, String>> _authHeaders() async {
    return AuthService.authHeaders();
  }

  MediaType _audioMediaType(String path, {MediaType? fallback}) {
    final ext = File(path).path.split('.').last.toLowerCase();
    switch (ext) {
      case 'wav':
        return MediaType('audio', 'wav');
      case 'mp3':
        return MediaType('audio', 'mpeg');
      case 'm4a':
      case 'aac':
        return MediaType('audio', 'aac');
      case 'webm':
        return MediaType('audio', 'webm');
      default:
        return fallback ?? MediaType('application', 'octet-stream');
    }
  }

  Future<Map<String, dynamic>> evaluateAudio({
    required String audioPath,
    required String targetText,
    required int lessonId,
  }) async {
    final uri = Uri.parse('$baseUrl/evaluate');
    final headers = await _authHeaders();

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers);

    request.fields.addAll({
      'target': targetText,
      'lesson_id': lessonId.toString(),
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'audio',
        audioPath,
        contentType: _audioMediaType(audioPath, fallback: MediaType('audio', 'wav')),
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw _error(response.statusCode, response.body);
    }

    return _decode(response.body);
  }

  Future<Map<String, dynamic>> evaluateTadarus({
    required String audioPath,
    required String targetText,
    int? surah,
    int? ayah,
  }) async {
    final uri = Uri.parse('$baseUrl/evaluate/tadarus');

    final request = http.MultipartRequest('POST', uri)
      ..fields['target'] = targetText;

    if (surah != null) request.fields['surah'] = surah.toString();
    if (ayah != null) request.fields['ayah'] = ayah.toString();

    request.files.add(
      await http.MultipartFile.fromPath(
        'audio',
        audioPath,
        contentType: _audioMediaType(audioPath, fallback: MediaType('audio', 'wav')),
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw _error(response.statusCode, response.body);
    }

    return _decode(response.body);
  }

  Future<Map<String, dynamic>> evaluateTajwid({
    required String audioPath,
    required String targetText,
    required int lessonId,
  }) async {
    final uri = Uri.parse('$baseUrl/evaluate/tajwid');
    final headers = await _authHeaders();

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers);

    request.fields.addAll({
      'lesson_id': lessonId.toString(),
      'target_text': targetText,
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'audio',
        audioPath,
        contentType: _audioMediaType(audioPath, fallback: MediaType('audio', 'aac')),
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw _error(response.statusCode, response.body);
    }

    return _decode(response.body);
  }

  Future<Map<String, dynamic>> evaluateTilawah({
    required String audioPath,
    required String targetText,
    required int lessonId,
  }) async {
    final uri = Uri.parse('$baseUrl/evaluate/tilawah');
    final headers = await _authHeaders();

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers);

    request.fields.addAll({
      'lesson_id': lessonId.toString(),
      'target_text': targetText,
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'audio',
        audioPath,
        contentType: _audioMediaType(audioPath, fallback: MediaType('audio', 'aac')),
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw _error(response.statusCode, response.body);
    }

    return _decode(response.body);
  }

  Future<Map<String, dynamic>> evaluateTahfidz({
    required String audioPath,
    required String targetText,
    required int lessonId,
  }) async {
    final uri = Uri.parse('$baseUrl/evaluate/tahfidz');
    final headers = await _authHeaders();

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers);

    request.fields.addAll({
      'lesson_id': lessonId.toString(),
      'target_text': targetText,
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'audio',
        audioPath,
        contentType: _audioMediaType(audioPath, fallback: MediaType('audio', 'aac')),
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw _error(response.statusCode, response.body);
    }

    return _decode(response.body);
  }

  Future<Map<String, dynamic>> evaluateTadarusAudio({
    required int surah,
    required int ayah,
    required int totalAyah,
    required String userAudioPath,
    required String referenceAudioPath,
  }) async {
    final uri = Uri.parse('$baseUrl/evaluate/tadarus/audio');
    final headers = await _authHeaders();

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers);

    request.fields.addAll({
      'surah': surah.toString(),
      'ayah': ayah.toString(),
      'total_ayah': totalAyah.toString(),
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'user_audio',
        userAudioPath,
        contentType: _audioMediaType(userAudioPath, fallback: MediaType('audio', 'aac')),
      ),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'reference_audio',
        referenceAudioPath,
        contentType: _audioMediaType(referenceAudioPath, fallback: MediaType('audio', 'mpeg')),
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw _error(response.statusCode, response.body);
    }

    return _decode(response.body);
  }

  void dispose() {
    _client.close();
  }
}
