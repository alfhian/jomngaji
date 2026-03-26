import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../services/progress_service.dart';
import '../../../routes/app_routes.dart';
import '../../auth/services/auth_service.dart';

class TadarusCard extends StatefulWidget {
  const TadarusCard({super.key});

  @override
  State<TadarusCard> createState() => _TadarusCardState();
}

class _TadarusCardState extends State<TadarusCard> {
  // ================= STATE =================
  double _globalProgress = 0.0;
  int _completedAyahGlobal = 0;
  int _totalAyahGlobal = 0;
  String _checkpointLabel = "Checkpoint 1";

  int dailyTarget = 5;
  int monthsGoal = 1;

  @override
  void initState() {
    super.initState();
    _loadGlobalProgress();
    _loadGoal();
  }

  // ================= API =================
  Future<void> _loadGlobalProgress() async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.get(
        Uri.parse(ApiConfig.endpoint('/tadarus/global-progress')),
        headers: headers,
      );

      if (res.statusCode != 200) return;

      final json = jsonDecode(res.body);
      final completed = (json['completed_ayah'] ?? 0).toInt();
      final total = (json['total_ayah'] ?? 0).toInt();
      final progress = total > 0 ? completed / total : 0.0;

      setState(() {
        _completedAyahGlobal = completed;
        _totalAyahGlobal = total;
        _globalProgress = progress;
        _checkpointLabel = _resolveCheckpoint(progress);
      });
    } catch (e) {
      debugPrint("Gagal load global progress: $e");
    }
  }

  Future<void> _loadGoal() async {
    monthsGoal = await ProgressService.getTadarusGoalMonths();
    dailyTarget = ProgressService.calculateDailyTarget(
      monthsGoal,
      totalAyat: 6236,
    );
    setState(() {});
  }

  // ================= LOGIC =================
  String _resolveCheckpoint(double progress) {
    final pct = (progress * 100).round();
    if (pct >= 75) return "Checkpoint 4";
    if (pct >= 50) return "Checkpoint 3";
    if (pct >= 25) return "Checkpoint 2";
    return "Checkpoint 1";
  }

  void _showGoalDialog() {
    int tempGoal = monthsGoal;
    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(
                "Set Goals Khatam",
                style:
                    GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Pilih target berapa bulan khatam:",
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  DropdownButton<int>(
                    value: tempGoal,
                    items: [1, 2, 3, 6, 12].map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text("$m bulan"),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setStateDialog(() => tempGoal = val!);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await ProgressService.saveTadarusGoal(tempGoal);
                    await _loadGoal();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatPercent(double value) {
    final percent = value * 100;
    if (percent < 1) {
      return percent.toStringAsFixed(2);
    }
    return percent.toStringAsFixed(1);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final progressPercentText = _formatPercent(_globalProgress);

    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8), topRight: Radius.circular(8)),
            child: Image.asset(
              "assets/images/tadarus-banner.png",
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header + Set Goals
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tadarus AI",
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87),
                    ),
                    TextButton(
                      onPressed: _showGoalDialog,
                      child: Text(
                        "Set Goals",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress info
                Text(
                  "$_completedAyahGlobal / $_totalAyahGlobal Ayat",
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Text(
                  "$progressPercentText% completion",
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _globalProgress,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade300,
                    color: const Color(0xFF42C88A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Target harian: $dailyTarget ayat (Goal $monthsGoal bulan)",
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54),
                ),
                const SizedBox(height: 16),
                // Button: Lanjutkan Hafalan
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.tadarusMenu);
                  },
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: const Text(
                    "Teruskan Hafalan",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
