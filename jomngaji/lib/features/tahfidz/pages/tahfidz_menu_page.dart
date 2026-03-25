import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../core/widgets/premium_upgrade_dialog.dart';
import '../../../features/auth/services/auth_service.dart';
import '../../../features/iqra/widgets/animated_iqra_card.dart';
import '../../../features/tilawah/widgets/tilawah_best_score_badge.dart';
import '../../../routes/app_routes.dart';
import '../../../core/widgets/custom_gradient_appbar.dart';

class TahfidzMenuPage extends StatelessWidget {
  const TahfidzMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomGradientAppBar(title: 'Tahfidz Dasar'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FBFF), Color(0xFFF1F7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _heroCard(),
            const SizedBox(height: 18),
            _levelItem(
              context,
              color: const Color(0xFFEAF3FF),
              iconColor: const Color(0xFF2563EB),
              title: 'Tingkatan 1 — Pemula',
              subtitle: 'Mulai hafalan surat pendek dengan pola pengulangan dasar.',
              icon: Icons.looks_one_rounded,
              description:
                  'Bangun kebiasaan setoran harian dan muraja\'ah ringan untuk hafalan awal.',
              levelTag: 'Pemula',
              quizCode: 'tahfidz_level_1',
              lessonId: 1,
            ),
            _levelItem(
              context,
              color: const Color(0xFFECFDF3),
              iconColor: const Color(0xFF16A34A),
              title: 'Tingkatan 2 — Menengah',
              subtitle: 'Perkuat sambungan ayat dan konsistensi muraja\'ah harian.',
              icon: Icons.looks_two_rounded,
              description:
                  'Latihan hafalan ayat lebih panjang dengan fokus kelancaran dan ketepatan urutan.',
              levelTag: 'Menengah',
              quizCode: 'tahfidz_level_2',
              lessonId: 2,
            ),
            _levelItem(
              context,
              color: const Color(0xFFFFFBEB),
              iconColor: const Color(0xFFF59E0B),
              title: 'Tingkatan 3 — Mahir',
              subtitle: 'Uji ketahanan hafalan, adab setoran, dan stabilitas bacaan.',
              icon: Icons.looks_3_rounded,
              description:
                  'Simulasi setoran hafalan dengan evaluasi bacaan untuk memantapkan hafalan.',
              levelTag: 'Mahir',
              quizCode: 'tahfidz_level_3',
              lessonId: 3,
            ),
            _examItem(context),
          ],
        ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF155EEF), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Belajar Tahfidz Bertahap',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text(
            'Pilih 3 tingkatan pembelajaran tahfidz. Setiap tingkat berisi latihan soal interaktif dan praktek setoran hafalan.',
            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _levelItem(
    BuildContext context, {
    required Color color,
    required Color iconColor,
    required String title,
    required String subtitle,
    required IconData icon,
    required String description,
    required String levelTag,
    required String quizCode,
    required int lessonId,
  }) {
    return AnimatedIqraCard(
      onTap: () => runWithPremiumGate(
        context,
        featureName: title,
        onAllowed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _TahfidzLevelPage(
              title: title,
              description: description,
              levelTag: levelTag,
              quizCode: quizCode,
              lessonId: lessonId,
            ),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0x12000000), blurRadius: 12, offset: Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 24, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('PRO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: iconColor),
          ],
        ),
      ),
    );
  }

  Widget _examItem(BuildContext context) {
    return AnimatedIqraCard(
      onTap: () => runWithPremiumGate(
        context,
        featureName: 'Tes Akhir Tahfidz',
        onAllowed: () => Navigator.pushNamed(context, AppRoutes.examTahfidz),
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 4, bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0x12000000), blurRadius: 12, offset: Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE11D48).withOpacity(0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.verified_rounded, size: 24, color: Color(0xFFE11D48)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tes Akhir Tahfidz',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Selesaikan ujian pilihan ganda dan pengucapan untuk menutup semua level.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFE11D48)),
          ],
        ),
      ),
    );
  }
}

class _TahfidzLevelPage extends StatelessWidget {
  final String title;
  final String description;
  final String levelTag;
  final String quizCode;
  final int lessonId;

  const _TahfidzLevelPage({
    required this.title,
    required this.description,
    required this.levelTag,
    required this.quizCode,
    required this.lessonId,
  });

  double _parseProgress(dynamic raw) {
    final value = double.tryParse('${raw ?? ''}') ?? 0;
    if (value > 1) return (value / 100).clamp(0.0, 1.0);
    return value.clamp(0.0, 1.0);
  }

  Future<double> _loadProgress() async {
    try {
      final headers = await AuthService.authHeaders();

      final quizRes = await http.get(
        Uri.parse('${AuthService.baseUrl}/quizzes/$quizCode/progress'),
        headers: headers,
      );

      final recRes = await http.get(
        Uri.parse('${AuthService.baseUrl}/evaluate/tahfidz/last?lesson_id=$lessonId'),
        headers: headers,
      );

      double quizProgress = 0;
      if (quizRes.statusCode == 200) {
        final body = jsonDecode(quizRes.body);
        if (body is Map<String, dynamic>) {
          final passed = body['passed'] == true;
          quizProgress = passed ? 1.0 : _parseProgress(body['progress']);
        }
      }

      double recProgress = 0;
      if (recRes.statusCode == 200) {
        final body = jsonDecode(recRes.body);
        if (body is Map<String, dynamic>) {
          final score = double.tryParse(
                '${body['score_final'] ?? body['best_score'] ?? body['score'] ?? 0}',
              ) ??
              0;
          recProgress = score > 0 ? 1.0 : 0.0;
        }
      }

      return ((quizProgress * 0.5) + (recProgress * 0.5)).clamp(0.0, 1.0);
    } catch (_) {
      return 0;
    }
  }

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
          _progressSection(),
          const SizedBox(height: 25),
          _exerciseList(context),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _heroSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        image: const DecorationImage(
          image: AssetImage('assets/images/hijaiyah_banner_2.png'),
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
              'Latihan Tahfidz',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 28,
                height: 1.25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
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
                levelTag,
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

  Widget _descriptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            '2 Aktivitas latihan',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
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
                'Progress',
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
                '${(progressValue * 100).toInt()}% selesai',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _exerciseList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _exerciseItem(
            context,
            title: 'Latihan Soal Interaktif',
            subtitle: 'Jawab soal untuk menguatkan urutan dan adab hafalan.',
            icon: Icons.quiz_rounded,
            color: const Color(0xFFE3F2FD),
            iconColor: const Color(0xFF2196F3),
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.latihanTahfidzPilihan,
              arguments: {
                'quiz_code': quizCode,
                'level_tag': levelTag,
              },
            ),
            scoreBadge: TilawahBestScoreBadge(
              quizCode: quizCode,
              lessonId: lessonId,
              label: 'Best score soal',
            ),
            unlocked: true,
          ),
          _exerciseItem(
            context,
            title: 'Praktek Setoran Hafalan',
            subtitle: 'Rekam hafalanmu, putar ulang, lalu nilai pengucapan.',
            icon: Icons.mic_rounded,
            color: const Color(0xFFFFEBEE),
            iconColor: const Color(0xFFE53935),
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.latihanTahfidzRecording,
              arguments: {
                'quiz_code': quizCode,
                'level_tag': levelTag,
                'lesson_id': lessonId,
              },
            ),
            scoreBadge: TilawahBestScoreBadge(
              quizCode: quizCode,
              lessonId: lessonId,
              label: 'Best score praktek',
              source: TilawahBestScoreSource.recording,
            ),
            unlocked: true,
          ),
        ],
      ),
    );
  }

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
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
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
