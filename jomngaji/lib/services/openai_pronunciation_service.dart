import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OpenAIPronunciationService {
  static const String apiKey = "REMOVEDproj-JftLUsCkdkAm8m95Yyiq4PYTPchCXHIkHdGqfDBjWNaIpvvS5PMaAYeTOva1z_HomERu1DmcOoT3BlbkFJYNUQ0auzTiMkCybBAow_Mc-_ZBeqNsiVfjwipotphc_sEiseNeuAucULMWtj0_BVZzdcUaArMA";
  static const String transcribeUrl = "https://api.openai.com/v1/audio/transcriptions";

  /// Kirim audio ke OpenAI Whisper untuk transkripsi
  static Future<String?> transcribe(String audioPath) async {
    final file = File(audioPath);
    if (!file.existsSync()) {
      print("❌ Audio file not found: $audioPath");
      return null;
    }

    try {
      final request = http.MultipartRequest("POST", Uri.parse(transcribeUrl))
        ..headers["Authorization"] = "Bearer $apiKey"
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
