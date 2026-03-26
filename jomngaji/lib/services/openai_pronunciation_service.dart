import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class OpenAIPronunciationService {
  static String get transcribeUrl =>
      ApiConfig.endpoint('/ai/openai/transcriptions');

  /// Kirim audio ke OpenAI Whisper untuk transkripsi
  static Future<String?> transcribe(String audioPath) async {
    final file = File(audioPath);
    if (!file.existsSync()) {
      print("❌ Audio file not found: $audioPath");
      return null;
    }

    try {
      final request = http.MultipartRequest("POST", Uri.parse(transcribeUrl))
        ..fields["model"] = "whisper-1"
        ..files.add(await http.MultipartFile.fromPath("file", audioPath));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["text"]; // Hasil transkripsi
      } else {
        print("❌ Transcription failed: ${response.statusCode}");
        print(response.body);
        return null;
      }
    } catch (e) {
      print("❌ Error: $e");
      return null;
    }
  }
}
