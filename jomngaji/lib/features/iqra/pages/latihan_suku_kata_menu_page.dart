import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/premium_upgrade_dialog.dart';
import '../../../services/suku_kata_service.dart';
import 'latihan_suku_kata_page.dart';

class LatihanSukuKataMenuPage extends StatefulWidget {
  const LatihanSukuKataMenuPage({super.key});

  @override
  State<LatihanSukuKataMenuPage> createState() => _LatihanSukuKataMenuPageState();
}

class _LatihanSukuKataMenuPageState extends State<LatihanSukuKataMenuPage> {
  bool _loading = true;
  List<SukuKataLevel> _levels = [];
  double _progressFromApi = 0.0;

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    setState(() => _loading = true);
    try {
      final payload = await SukuKataService.getLevels();
      setState(() {
        _levels = payload.levels;
        _progressFromApi = payload.progressPercentage;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil level: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _progressValue {
    if (_progressFromApi > 0) return _progressFromApi.clamp(0.0, 1.0);
    if (_levels.isEmpty) return 0.0;
    final unlocked = _levels.where((e) => e.isUnlocked).length;
    return unlocked / _levels.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLevels,
              child: ListView(
                children: [
                  _heroSection(context),
                  const SizedBox(height: 20),
                  _descriptionSection(),
                  const SizedBox(height: 22),
                  _progressSection(),
                  const SizedBox(height: 25),
                  _levelList(context),
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
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Latihan 2',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Mengenal dan Mengucapkan Suku Kata',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 32,
                height: 1.25,
                fontWeight: FontWeight.w800,
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
            'Belajar membaca, mengenal, dan mengucapkan suku kata.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_levels.length} Level Pelajaran',
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
            'Progress',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progressValue,
              backgroundColor: Colors.grey.shade300,
              minHeight: 8,
              color: const Color(0xFF50D1A0),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(_progressValue * 100).toInt()}% selesai',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelList(BuildContext context) {
    if (_levels.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          'Belum ada level dari server.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _levels.map((level) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _levelCard(
              context,
              level: level,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _levelCard(
    BuildContext context, {
    required SukuKataLevel level,
  }) {
    final unlocked = level.isUnlocked;

    return GestureDetector(
      onTap: () async {
        if (level.isPremium) {
          await runWithPremiumGate(
            context,
            featureName: level.title,
            onAllowed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LatihanSukuKataPage(level: level),
              ),
            ).then((_) => _loadLevels()),
          );
          return;
        }
        if (unlocked) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LatihanSukuKataPage(level: level),
            ),
          ).then((_) => _loadLevels());
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
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
                    level.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    level.description.isEmpty ? 'Soal: ${level.totalQuestions}' : level.description,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (level.isPremium)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'PRO',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
