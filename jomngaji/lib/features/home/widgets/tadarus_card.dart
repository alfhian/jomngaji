import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../core/theme/app_design_tokens.dart';
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
                  borderRadius: BorderRadius.circular(AppRadius.md)),
              title: Text(
                "Target Khatam",
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 18, fontWeight: FontWeight.w800),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Berapa bulan target khatam Anda?",
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.scaffold,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: tempGoal,
                        isExpanded: true,
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
                    ),
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
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
    return percent.toStringAsFixed(1);
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final progressPercentText = _formatPercent(_globalProgress);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.medium,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.md),
              topRight: Radius.circular(AppRadius.md),
            ),
            child: Stack(
              children: [
                Image.asset(
                  "assets/images/tadarus-banner.png",
                  width: double.infinity,
                  height: 140,
                  fit: BoxFit.cover,
                ),
                Container(
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tadarus AI",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Monitoring progress hafalanmu",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Progres Keseluruhan",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: _showGoalDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Set Goals",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$_completedAyahGlobal / $_totalAyahGlobal Ayat",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      "$progressPercentText%",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _globalProgress,
                    minHeight: 10,
                    backgroundColor: AppColors.scaffold,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.scaffold,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flag_rounded, size: 18, color: AppColors.gold),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Target: $dailyTarget ayat/hari untuk khatam dalam $monthsGoal bulan.",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.tadarusMenu);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle_fill_rounded, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        "Teruskan Tadarus",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
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
