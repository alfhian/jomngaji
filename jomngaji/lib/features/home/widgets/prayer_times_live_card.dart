import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../services/prayer_times_service.dart';

class PrayerTimesLiveCard extends StatefulWidget {
  const PrayerTimesLiveCard({super.key});

  @override
  State<PrayerTimesLiveCard> createState() => _PrayerTimesLiveCardState();
}

class _PrayerTimesLiveCardState extends State<PrayerTimesLiveCard> {
  static const _cityPrefKey = 'prayer_times_city_malaysia';

  PrayerTimesData? _data;
  String? _error;
  bool _loading = true;
  Timer? _ticker;
  String _selectedCity = PrayerTimesService.malaysiaCities.first;

  @override
  void initState() {
    super.initState();
    _init();
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final city = prefs.getString(_cityPrefKey);
    if (city != null && PrayerTimesService.malaysiaCities.contains(city)) {
      _selectedCity = city;
    }
    await _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await PrayerTimesService.fetchTodayByCity(city: _selectedCity);
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

  Future<void> _onCityChanged(String city) async {
    if (city == _selectedCity) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cityPrefKey, city);
    if (!mounted) return;
    setState(() => _selectedCity = city);
    await _load();
  }

  ({String prayer, String time, Duration left}) _nextPrayer() {
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

    return (
      prayer: nextPrayer,
      time: nextTime,
      left: next.difference(now),
    );
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
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.soft,
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 3)),
      );
    }
    
    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.soft,
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 32),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat jadwal sholat',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Coba Lagi'),
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
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.medium,
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCity,
                      dropdownColor: AppColors.primaryLight,
                      iconEnabledColor: Colors.white70,
                      isDense: true,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      items: PrayerTimesService.malaysiaCities.map((city) {
                        return DropdownMenuItem(value: city, child: Text(city));
                      }).toList(),
                      onChanged: (city) {
                        if (city != null) _onCityChanged(city);
                      },
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white54, size: 20),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _labelPrayer(next.prayer),
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Pukul ${next.time}',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Mendatang',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '- $countdown',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppRadius.md),
                bottomRight: Radius.circular(AppRadius.md),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: PrayerTimesService.trackedPrayers.map((p) {
                  final t = data.timings[p] ?? '--:--';
                  final isNext = p == next.prayer;
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isNext ? AppColors.accent : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _labelPrayer(p),
                          style: GoogleFonts.plusJakartaSans(
                            color: isNext ? Colors.white : Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
