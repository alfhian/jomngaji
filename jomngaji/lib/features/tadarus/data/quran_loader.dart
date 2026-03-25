import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/surah.dart';

const String baseUrl = "http://10.179.249.20:4000/quran";

// Ambil daftar surah
Future<List<Surah>> loadQuranDataset() async {
  final res = await http.get(Uri.parse("$baseUrl/surahs"));
  if (res.statusCode != 200) {
    throw Exception("Failed to load surahs: ${res.statusCode}");
  }

  final dynamic raw = jsonDecode(res.body);

  if (raw is List) {
    return raw.map<Surah>((s) => Surah.fromJson(s as Map<String, dynamic>)).toList();
  }

  throw Exception("Unexpected /quran/surahs response shape: ${raw.runtimeType}");
}

// Ambil detail surah
Future<Surah> loadSurahDetail(int number) async {
  final res = await http.get(Uri.parse("$baseUrl/surah/$number"));
  if (res.statusCode != 200) {
    throw Exception("Failed to load surah $number: ${res.statusCode}");
  }

  final dynamic raw = jsonDecode(res.body);

  if (raw is Map<String, dynamic>) {
    return Surah.fromJson(raw);
  }

  throw Exception("Unexpected /quran/surah/$number response shape: ${raw.runtimeType}");
}

// Ambil detail ayah
Future<Ayah> loadAyahDetail(int surahNumber, int ayahNumber) async {
  final res = await http.get(Uri.parse("$baseUrl/ayah/$surahNumber/$ayahNumber"));
  if (res.statusCode != 200) {
    throw Exception("Failed to load ayah $surahNumber:$ayahNumber");
  }

  final dynamic raw = jsonDecode(res.body);

  if (raw is Map<String, dynamic>) {
    return Ayah.fromJson(raw);
  }

  throw Exception("Unexpected /quran/ayah response shape: ${raw.runtimeType}");
}
