import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/prayer_times_service.dart';

class PrayerTimesLiveCard extends StatefulWidget {
  const PrayerTimesLiveCard({super.key});

  @override
  State<PrayerTimesLiveCard> createState() => _PrayerTimesLiveCardState();
}

class _PrayerTimesLiveCardState extends State<PrayerTimesLiveCard> {
  PrayerTimesData? _data;
  String? _error;
  bool _loading = true;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _load();
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await PrayerTimesService.fetchTodayByCity();
      if (!mounted) return;
      setState(() {
        _data = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  (String prayer, String time, Duration left) _nextPrayer() {
    final now = DateTime.now();
    final timings = _data?.timings ?? {};

    DateTime? next;
    String nextPrayer = '-';
    String nextTime = '--:--';

    for (final prayer in PrayerTimesService.trackedPrayers) {
      final t = timings[prayer];
      if (t == null || !t.contains(':')) continue;
      final parts = t.split(':');
      final dt = DateTime(
        now.year,
        now.month,
        now.day,
        int.tryParse(parts[0]) ?? 0,
        int.tryParse(parts[1]) ?? 0,
      );
      if (dt.isAfter(now)) {
        next = dt;
        nextPrayer = prayer;
        nextTime = t;
        break;
      }
    }

    if (next == null) {
      final subuh = timings['Fajr'] ?? '04:45';
      final parts = subuh.split(':');
      next = DateTime(
        now.year,
        now.month,
        now.day + 1,
        int.tryParse(parts[0]) ?? 4,
        int.tryParse(parts[1]) ?? 45,
      );
      nextPrayer = 'Fajr';
      nextTime = subuh;
    }

    return (nextPrayer, nextTime, next.difference(now));
  }

  String _labelPrayer(String apiName) {
    switch (apiName) {
      case 'Fajr':
        return 'Subuh';
      case 'Dhuhr':
        return 'Dzuhur';
      case 'Asr':
        return 'Ashar';
      case 'Maghrib':
        return 'Maghrib';
      case 'Isha':
        return 'Isya';
      default:
        return apiName;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jadwal sholat belum bisa dimuat',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              _error ?? '',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    final data = _data!;
    final next = _nextPrayer();
    final left = next.left;
    final countdown =
        '${left.inHours.toString().padLeft(2, '0')}:${(left.inMinutes % 60).toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time_filled_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Waktu Sholat Hari Ini',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                tooltip: 'Refresh jadwal',
              ),
            ],
          ),
          Text(
            '${data.readableDate} • ${data.timezone}',
            style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  'Selanjutnya: ${_labelPrayer(next.prayer)} (${next.time})',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  countdown,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF86EFAC),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PrayerTimesService.trackedPrayers.map((p) {
              final t = data.timings[p] ?? '--:--';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_labelPrayer(p)} • $t',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
