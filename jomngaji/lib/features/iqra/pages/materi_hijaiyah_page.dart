import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/premium_upgrade_dialog.dart';
import '../../../services/hijaiyah_service.dart';
import '../data/hijaiyah_data.dart';
import 'materi_huruf_detail_page.dart';

class MateriHijaiyahPage extends StatefulWidget {
  const MateriHijaiyahPage({super.key});

  @override
  State<MateriHijaiyahPage> createState() => _MateriHijaiyahPageState();
}

class _MateriHijaiyahPageState extends State<MateriHijaiyahPage> {
  bool _loading = true;
  double _progress = 0;
  List<HijaiyahLesson> _lessons = [];

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    setState(() => _loading = true);
    try {
      final payload = await HijaiyahService.getLessons();
      if (!mounted) return;
      setState(() {
        _lessons = payload.lessons;
        _progress = payload.progress;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil materi hijaiyah: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<HijaiyahData> _lessonLettersByIndex(int lessonIndex) {
    if (_lessons.isEmpty) return const [];

    final safeIndex = lessonIndex.clamp(0, _lessons.length - 1);
    final start = _lessons
        .take(safeIndex)
        .fold<int>(0, (sum, lesson) => sum + lesson.totalLetters);

    final length = _lessons[safeIndex].totalLetters;

    if (start >= hijaiyahList.length) return const [];

    final end = (start + length).clamp(start, hijaiyahList.length);
    return hijaiyahList.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLessons,
              child: ListView(
                children: [
                  _heroSection(context),
                  const SizedBox(height: 20),
                  _descriptionSection(),
                  const SizedBox(height: 22),
                  _progressSection(),
                  const SizedBox(height: 25),
                  _lessonList(context),
                  const SizedBox(height: 30),
                ],
              ),
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
              "Materi 1",
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Belajar Huruf\nHijaiyah",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 32,
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

  Widget _descriptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Belajar membaca, mengenal, dan mengucapkan huruf Hijaiyah.",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${_lessons.length} Pelajaran",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Progress",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey.shade300,
              minHeight: 8,
              color: const Color(0xFF50D1A0),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${(_progress * 100).toInt()}% selesai",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _lessonList(BuildContext context) {
    if (_lessons.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          'Belum ada materi hijaiyah dari server.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(_lessons.length, (index) {
          final lesson = _lessons[index];
          final unlocked = lesson.isUnlocked;
          final letters = _lessonLettersByIndex(index);

          return _lessonItem(
            context,
            number: index + 1,
            title: lesson.title,
            subtitle: lesson.description,
            unlocked: unlocked,
            isPremium: lesson.isPremium,
            onTap: unlocked
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MateriHurufDetailPage(
                          lessonId: lesson.id,
                          lessonTitle: lesson.title,
                          hurufList: letters,
                        ),
                      ),
                    ).then((_) => _loadLessons());
                  }
                : null,
          );
        }),
      ),
    );
  }

  Widget _lessonItem(
    BuildContext context, {
    required int number,
    required String title,
    required String subtitle,
    required bool unlocked,
    required bool isPremium,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () async {
        if (isPremium) {
          await runWithPremiumGate(
            context,
            featureName: 'Pelajaran ke-$number',
            onAllowed: () => onTap?.call(),
          );
          return;
        }
        if (unlocked) onTap?.call();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: unlocked ? const Color(0xFFE7FFF2) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: unlocked ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              unlocked ? Icons.menu_book_rounded : Icons.lock_rounded,
              size: 26,
              color: unlocked ? const Color(0xFF50D1A0) : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pelajaran ke-$number",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isPremium)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'PRO',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (unlocked)
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
