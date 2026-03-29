import 'dart:convert';

import 'package:http/http.dart' as http;

class PrayerTimesData {
  final Map<String, String> timings;
  final String readableDate;
  final String timezone;

  const PrayerTimesData({
    required this.timings,
    required this.readableDate,
    required this.timezone,
  });
}

class PrayerTimesService {
  PrayerTimesService._();

  static const _endpoint = 'https://api.aladhan.com/v1/timingsByCity';

  static const List<String> trackedPrayers = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  static const List<String> malaysiaCities = [
    'Kuala Lumpur',
    'Shah Alam',
    'Johor Bahru',
    'Ipoh',
    'Kota Kinabalu',
    'Kuching',
    'Alor Setar',
    'Melaka',
    'Kuantan',
    'Kuala Terengganu',
  ];

  static Future<PrayerTimesData> fetchTodayByCity({
    String city = 'Kuala Lumpur',
    String country = 'Malaysia',
    int method = 11,
  }) async {
    final url = Uri.parse(
      '$_endpoint?city=${Uri.encodeQueryComponent(city)}'
      '&country=${Uri.encodeQueryComponent(country)}'
      '&method=$method',
    );
    final res = await http.get(url).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) {
      throw Exception('Gagal memuat jadwal sholat (${res.statusCode})');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final timingsRaw = data['timings'] as Map<String, dynamic>? ?? {};
    final date = data['date'] as Map<String, dynamic>? ?? {};
    final meta = data['meta'] as Map<String, dynamic>? ?? {};

    final timings = <String, String>{};
    for (final key in trackedPrayers) {
      final raw = timingsRaw[key]?.toString() ?? '--:--';
      timings[key] = _normalizeTime(raw);
    }

    return PrayerTimesData(
      timings: timings,
      readableDate: (date['readable']?.toString() ?? '').trim(),
      timezone: (meta['timezone']?.toString() ?? '').trim(),
    );
  }

  static String _normalizeTime(String input) {
    final sanitized = input.split(' ').first.trim();
    final match = RegExp(r'^\d{1,2}:\d{2}').firstMatch(sanitized);
    if (match == null) return '--:--';
    final value = match.group(0)!;
    final parts = value.split(':');
    final hh = parts[0].padLeft(2, '0');
    return '$hh:${parts[1]}';
  }
}
