import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../routes/app_routes.dart';
import '../../../../services/tajwid_quiz_service.dart';
import 'widgets/tajwid_best_score_badge.dart';

class LatihanQalqalahMenuPage extends StatelessWidget {
  const LatihanQalqalahMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: null,
      body: ListView(
        children: [
          _heroSection(context),
          const SizedBox(height: 20),
          _descriptionSection(),
          const SizedBox(height: 22),
          _progressSection(), // progress bar sesuai tema
          const SizedBox(height: 25),
          _exerciseList(context),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // =========================
  // Hero section
  // =========================
  Widget _heroSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        image: const DecorationImage(
          image: AssetImage("assets/images/hijaiyah_banner_2.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.05),
              Colors.black.withOpacity(0.40),
            ],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // back button glass
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),

            const SizedBox(height: 28),

            Text(
              "Latihan Tajwid",
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Qalqalah (ق ل ق ل ة)",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 32,
                height: 1.25,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 16),

            // badge level/jenis
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Text(
                "Pemula",
                style: GoogleFonts.poppins(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // Description
  // =========================
  Widget _descriptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pilih gaya latihan untuk menguasai hukum Qalqalah (Sughra dan Kubra).",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            "2 Aktivitas latihan",
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // =========================
  // Progress section
  // =========================
  Future<double> _loadProgress() async {
    try {
      final combined = await TajwidQuizService.getCombinedProgress('qalqalah');
      final raw = combined['combined_progress'];
      final value = double.tryParse('${raw ?? 0}') ?? 0;
      return value.clamp(0.0, 1.0);
    } catch (_) {
      return 0;
    }
  }

  Widget _progressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FutureBuilder<double>(
        future: _loadProgress(),
        builder: (_, snapshot) {
          final progressValue = (snapshot.data ?? 0).clamp(0.0, 1.0);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Progress",
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Colors.grey.shade300,
                  minHeight: 8,
                  color: const Color(0xFF50D1A0),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${(progressValue * 100).toInt()}% selesai",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
              ),
            ],
          );
        },
      ),
    );
  }

  // =========================
  // Exercise list
  // =========================
  Widget _exerciseList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _exerciseItem(
            context,
            title: "Latihan Soal Interaktif",
            subtitle: "Jawab soal pilihan untuk mengenali hukum Qalqalah",
            icon: Icons.quiz_rounded,
            color: const Color(0xFFE3F2FD),
            iconColor: const Color(0xFF2196F3),
            onTap: () => Navigator.pushNamed(context, AppRoutes.latihanQalqalahPilihan),
            scoreBadge: const TajwidBestScoreBadge(quizCode: 'qalqalah', label: 'Best score soal'),
            unlocked: true,
          ),
          _exerciseItem(
            context,
            title: "Praktek Bacaan Tajwid",
            subtitle: "Simulasi membaca dengan suara (rekaman suara)",
            icon: Icons.mic_rounded,
            color: const Color(0xFFFFEBEE),
            iconColor: const Color(0xFFE53935),
            onTap: () => Navigator.pushNamed(context, AppRoutes.latihanQalqalahRecording),
            scoreBadge: const TajwidBestScoreBadge(quizCode: 'qalqalah', label: 'Best score praktek', source: TajwidBestScoreSource.recording),
            unlocked: true,
          ),
        ],
      ),
    );
  }

  // =========================
  // Single exercise card
  // =========================
  Widget _exerciseItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
    required Widget scoreBadge,
    required bool unlocked,
  }) {
    return GestureDetector(
      onTap: unlocked ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: unlocked ? color : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: unlocked ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 26, color: iconColor),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      )),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  scoreBadge,
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF50D1A0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
