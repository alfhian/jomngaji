import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import 'whisper_ffi.dart';
import '../../../utils/model_loader.dart';

class PronunciationResult {
  final int score; // 0 - 100
  final String transcription;
  final String makhraj;
  final String saran;

  PronunciationResult({
    required this.score,
    required this.transcription,
    required this.makhraj,
    required this.saran,
  });

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'transcription': transcription,
      'makhraj': makhraj,
      'saran': saran,
    };
  }
}

class PronunciationEngine {
  PronunciationEngine._();
  static final PronunciationEngine instance = PronunciationEngine._();

  Future<PronunciationResult> evaluate({
    required String audioPath,
    required String targetText,
    required String languageCode,
  }) async {
    debugPrint("🎯 Evaluate audio: $audioPath");

    // 1. Load PCM dari WAV (16-bit PCM, header 44 bytes)
    final Int16List pcm = await _loadPcmFromWav(audioPath);
    debugPrint("🎧 PCM length (samples): ${pcm.length}");

    if (pcm.isEmpty) {
      throw Exception("PCM kosong dari file: $audioPath");
    }

    // 2. Pastikan model Whisper ready
    String transcription;
    final modelPath = await ModelLoader.loadWhisperModelSmall();

    final modelFile = File(modelPath);
    final modelExists = modelFile.existsSync();
    final modelSize = modelExists ? await modelFile.length() : 0;

    debugPrint("🧠 Whisper model path: $modelPath");
    debugPrint("🧠 Exists: $modelExists | Size: $modelSize bytes");

    if (!modelExists || modelSize == 0) {
      throw Exception(
          "Model Whisper tidak ditemukan atau kosong. Path: $modelPath");
    }

    try {
      transcription = await WhisperFfi.instance.transcribePcmInt16(
        pcm: pcm,
        languageCode: languageCode,
        modelPath: modelPath,
      );
    } catch (e) {
      // Kalau error 'belum di-init', coba initOnce lalu ulang
      if (e.toString().contains('WhisperFfi belum di-init')) {
        debugPrint("ℹ️ Auto init Whisper, lalu transcribe ulang...");
        await WhisperFfi.instance.initOnce(modelPath);

        transcription = await WhisperFfi.instance.transcribePcmInt16(
          pcm: pcm,
          languageCode: languageCode,
          modelPath: modelPath,
        );
      } else {
        debugPrint("❌ Error transcribe: $e");
        rethrow;
      }
    }

    debugPrint("📝 Transcription: '$transcription'");

    // 3. String similarity
    final double similarity =
        _stringSimilarity(_normalize(targetText), _normalize(transcription));

    final int score = (similarity * 100).clamp(0, 100).round();

    // 4. Makhraj & saran
    final String makhraj = _makhrajFromTarget(targetText, score);
    final String saran = _saranFromScore(score);

    return PronunciationResult(
      score: score,
      transcription: transcription,
      makhraj: makhraj,
      saran: saran,
    );
  }

  // =========================================================
  //  WAV → PCM16 loader
  // =========================================================

  Future<Int16List> _loadPcmFromWav(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw Exception("WAV file tidak ditemukan: $path");
    }

    final bytes = await file.readAsBytes();
    debugPrint("🎧 WAV size: ${bytes.length} bytes");

    if (bytes.length < 44) {
      throw Exception("WAV file corrupt (kurang dari 44 byte header): $path");
    }

    // Skip 44-byte header
    final Uint8List raw = bytes.sublist(44);

    if (raw.isEmpty) {
      throw Exception("Data audio kosong setelah header: $path");
    }

    final pcm = raw.buffer.asInt16List(
      raw.offsetInBytes,
      raw.lengthInBytes ~/ 2,
    );

    return pcm;
  }

  // =========================================================
  //  Text normalization & similarity
  // =========================================================

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF ]'), '')
        .trim();
  }

  double _stringSimilarity(String a, String b) {
    if (a.isEmpty && b.isEmpty) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    final int dist = _levenshtein(a, b);
    final int maxLen = max(a.length, b.length);
    return 1.0 - (dist / maxLen);
  }

  int _levenshtein(String s, String t) {
    final n = s.length;
    final m = t.length;
    if (n == 0) return m;
    if (m == 0) return n;

    final List<List<int>> d =
        List.generate(n + 1, (_) => List<int>.filled(m + 1, 0));

    for (int i = 0; i <= n; i++) d[i][0] = i;
    for (int j = 0; j <= m; j++) d[0][j] = j;

    for (int i = 1; i <= n; i++) {
      for (int j = 1; j <= m; j++) {
        final cost = s[i - 1] == t[j - 1] ? 0 : 1;
        d[i][j] = [
          d[i - 1][j] + 1,
          d[i][j - 1] + 1,
          d[i - 1][j - 1] + cost,
        ].reduce(min);
      }
    }

    return d[n][m];
  }

  String _saranFromScore(int score) {
    if (score >= 90) {
      return "Pengucapanmu sudah sangat baik, pertahankan dan lanjutkan ke huruf berikutnya.";
    } else if (score >= 75) {
      return "Sudah bagus, perbaiki sedikit panjang-pendek suara dan penekanan di awal/akhir huruf.";
    } else if (score >= 60) {
      return "Perlu latihan lagi. Fokus pada bentuk mulut dan keluarnya udara saat mengucapkan huruf ini.";
    } else {
      return "Coba ulangi lagi pelan-pelan, dengarkan contoh bacaan guru atau audio, lalu tirukan beberapa kali.";
    }
  }

  String _makhrajFromTarget(String target, int score) {
    final RegExp arabic = RegExp(r'[\u0600-\u06FF]');
    final match = arabic.firstMatch(target);
    if (match == null) {
      return "Makhraj tidak terdeteksi dari target.";
    }
    final String huruf = match.group(0)!;

    String area;
    const halqiyah = ['ح', 'خ', 'ع', 'غ', 'ه'];
    const lisaniyah = ['ت', 'د', 'ط', 'ص', 'س', 'z', 'ظ', 'ذ', 'ث', 'ض', 'ل', 'ر', 'ن'];
    const shafawiyah = ['ب', 'ف', 'm', 'و'];

    if (halqiyah.contains(huruf)) {
      area = "tenggorokan (halqiyah)";
    } else if (lisaniyah.contains(huruf)) {
      area = "lidah (lisaniyah)";
    } else if (shafawiyah.contains(huruf)) {
      area = "bibir (shafawiyah)";
    } else {
      area = "makhraj khusus huruf tersebut";
    }

    if (score >= 80) {
      return "Huruf $huruf keluar dari $area dengan cukup baik.";
    } else {
      return "Perhatikan kembali huruf $huruf yang keluar dari $area, coba rasakan posisi lidah dan bibir saat mengucapkannya.";
    }
  }
}
