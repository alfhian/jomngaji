import 'openai_pronunciation_service.dart';
import '../models/evaluation_result.dart';

class PronunciationEvaluator {
  static Future<EvaluationResult> evaluate(
      String audioPath, String target) async {
    final transcript = await OpenAIPronunciationService.transcribe(audioPath);

    if (transcript == null) {
      return EvaluationResult(
        score: 0,
        transcript: "",
        feedback: "Gagal transkripsi audio.",
        errors: [],
        issueDetails: const [],
      );
    }

    final score = _scorePronunciation(transcript, target);
    final errors = _detectTajwidErrors(transcript, target);

    return EvaluationResult(
      score: score,
      transcript: transcript,
      feedback: score >= 80
          ? "Bagus! Lanjutkan."
          : "Masih ada kesalahan, coba ulangi.",
      errors: errors,
      issueDetails: const [],
    );
  }

  static int _scorePronunciation(String transcript, String target) {
    final t = transcript.toLowerCase().trim();
    final goal = target.toLowerCase().trim();

    if (t == goal) return 100;
    if (t.contains(goal)) return 80;
    if (goal.contains(t)) return 60;
    if (t.isNotEmpty) return 40;
    return 0;
  }

  static List<String> _detectTajwidErrors(String transcript, String target) {
    final errors = <String>[];
    // contoh aturan sederhana
    if (transcript.contains("الرحمن") && !transcript.contains("الرحمٰن")) {
      errors.add("Madd kurang panjang pada الرحمن");
    }
    return errors;
  }
}
