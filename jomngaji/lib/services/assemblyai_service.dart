import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class AssemblyAIService {
  final String baseUrl = ApiConfig.endpoint('/ai/assemblyai');

  // Fungsi untuk upload file audio
  Future<String?> uploadAudio(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      print("⚠️ File not found: $path");
      return null;
    }

    final String uploadUrl = "$baseUrl/upload";
    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.files.add(await http.MultipartFile.fromPath('file', path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final json = jsonDecode(respStr);
        return json['upload_url'];  // Return upload URL
      } else {
        print("Failed to upload audio: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error uploading audio: $e");
      return null;
    }
  }

  // Fungsi untuk memulai transkripsi dengan audio URL
  Future<String?> startTranscription(String audioUrl) async {
    final url = Uri.parse('$baseUrl/transcript');
    final response = await http.post(
      url,
      headers: {
        'content-type': 'application/json',
      },
      body: json.encode({
        'audio_url': audioUrl,
        'language_code': 'ar',  // Gunakan kode bahasa Arab
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['id'];  // Return transcription ID
    } else {
      print('Error starting transcription: ${response.statusCode}');
      return null;
    }
  }

  // Fungsi untuk mengecek status transkripsi
  Future<Map<String, dynamic>?> checkTranscriptionStatus(String transcriptionId) async {
    final url = Uri.parse('$baseUrl/transcript/$transcriptionId');
    final response = await http.get(
      url,
      headers: {
        'content-type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      print('Error checking transcription status: ${response.statusCode}');
      return null;
    }
  }

  // Fungsi utama untuk upload, transkripsi, dan pengecekan status
  Future<void> transcribeAudio(String audioPath) async {
    // Upload file audio dan dapatkan URL
    final audioUrl = await uploadAudio(audioPath);
    if (audioUrl == null) {
      print("Failed to upload audio.");
      return;
    }

    // Mulai transkripsi
    final transcriptId = await startTranscription(audioUrl);
    if (transcriptId == null) {
      print("Failed to start transcription.");
      return;
    }

    // Polling status transkripsi hingga selesai
    while (true) {
      await Future.delayed(const Duration(seconds: 3));
      final result = await checkTranscriptionStatus(transcriptId);
      if (result == null) {
        continue;
      }

      if (result['status'] == 'completed') {
        print("Transcription completed: ${result['text']}");
        break;
      } else if (result['status'] == 'error') {
        print("Transcription failed: ${result['error']}");
        break;
      }
    }
  }
}
