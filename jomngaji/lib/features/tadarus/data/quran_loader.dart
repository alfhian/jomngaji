import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../models/surah.dart';

final String baseUrl = ApiConfig.endpoint('/quran');
List<Surah>? _surahDatasetCache;
final Map<int, Surah> _surahDetailCache = {};

// Ambil daftar surah
Future<List<Surah>> loadQuranDataset() async {
  if (_surahDatasetCache != null) return _surahDatasetCache!;
  final res = await http.get(Uri.parse("$baseUrl/surahs"));
  if (res.statusCode != 200) {
    throw Exception("Failed to load surahs: ${res.statusCode}");
  }

  final dynamic raw = jsonDecode(res.body);

  if (raw is List) {
    final parsed = raw.map<Surah>((s) => Surah.fromJson(s as Map<String, dynamic>)).toList();
    _surahDatasetCache = parsed;
    return parsed;
  }

  throw Exception("Unexpected /quran/surahs response shape: ${raw.runtimeType}");
}

// Ambil detail surah
Future<Surah> loadSurahDetail(int number) async {
  final cached = _surahDetailCache[number];
  if (cached != null) return cached;
  final res = await http.get(Uri.parse("$baseUrl/surah/$number"));
  if (res.statusCode != 200) {
    throw Exception("Failed to load surah $number: ${res.statusCode}");
  }

  final dynamic raw = jsonDecode(res.body);

  if (raw is Map<String, dynamic>) {
    final parsed = Surah.fromJson(raw);
    _surahDetailCache[number] = parsed;
    return parsed;
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
