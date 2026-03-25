import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'halqiy_page.dart';
import 'khaysyum_page.dart';
import 'lisani_page.dart';
import 'syafawi_page.dart';

class MakhrajPage extends StatefulWidget {
  const MakhrajPage({super.key});

  @override
  State<MakhrajPage> createState() => _MakhrajPageState();
}

class _MakhrajPageState extends State<MakhrajPage> {
  final Set<int> _visited = <int>{};

  late final List<_MakhrajItem> _items = [
    _MakhrajItem(
      title: 'Halqiy (Tenggorokan)',
      subtitle: 'Huruf: ء هـ',
      icon: Icons.record_voice_over_rounded,
      pageBuilder: (_) => const HalqiyPage(),
    ),
    _MakhrajItem(
      title: 'Lisani (Lidah)',
      subtitle: 'Huruf: ت د ط ظ ل ر',
      icon: Icons.forum_rounded,
      pageBuilder: (_) => const LisaniPage(),
    ),
    _MakhrajItem(
      title: 'Syafawi (Bibir)',
      subtitle: 'Huruf: ف ب م',
      icon: Icons.mic_rounded,
      pageBuilder: (_) => const SyafawiPage(),
    ),
    _MakhrajItem(
      title: 'Khaysyum (Rongga Hidung)',
      subtitle: 'Huruf: ن (ghunnah)',
      icon: Icons.graphic_eq_rounded,
      pageBuilder: (_) => const KhaysyumPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final progress = _items.isEmpty ? 0.0 : _visited.length / _items.length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: null,
      body: ListView(
        children: [
          _heroSection(context),
          const SizedBox(height: 18),
          _descriptionSection(),
          const SizedBox(height: 18),
          _progressSection(progress),
          const SizedBox(height: 18),
          _makhrajInfoCard(),
          const SizedBox(height: 18),
          _makhrajCards(context),
          const SizedBox(height: 28),
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
              Colors.black.withOpacity(0.42),
            ],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 36),
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
            const SizedBox(height: 24),
            Text(
              'Latihan Pengucapan',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Makhraj Huruf\nHijaiyah',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 31,
                height: 1.2,
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
      child: Text(
        'Belajar kategori makhraj seperti Halqiy, Lisani, Syafawi, dan Khaysyum agar pengucapan huruf lebih tepat.',
        style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  Widget _progressSection(double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress Eksplorasi Makhraj',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              color: const Color(0xFF50D1A0),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_visited.length}/${_items.length} kategori dibuka',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _makhrajInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFFECB3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.record_voice_over_rounded, color: Color(0xFF8D6E63)),
                const SizedBox(width: 8),
                Text(
                  'Apa itu Makhraj?',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6D4C41),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Makhraj adalah tempat keluarnya huruf saat diucapkan (contoh: tenggorokan, lidah, bibir, dan rongga hidung). '
              'Pilih kategori di bawah untuk masuk ke halaman latihan khusus masing-masing.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.45,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _makhrajCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ...List.generate(_items.length, (i) {
            final item = _items[i];
            final opened = _visited.contains(i);

            return GestureDetector(
              onTap: () {
                setState(() => _visited.add(i));
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: item.pageBuilder),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: opened ? const Color(0xFFE7FFF2) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: opened ? const Color(0xFF50D1A0) : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: opened
                          ? const Color(0xFF50D1A0)
                          : Colors.grey.shade300,
                      child: Icon(item.icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      opened ? Icons.play_circle_fill_rounded : Icons.chevron_right_rounded,
                      color: opened ? const Color(0xFF50D1A0) : Colors.black45,
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              image: const DecorationImage(
                image: AssetImage('assets/images/background-mengaji.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.84),
              ),
              child: Text(
                'Tip: mulai dari Halqiy lalu lanjut Lisani → Syafawi → Khaysyum agar urutan latihan lebih terstruktur.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MakhrajItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder pageBuilder;

  const _MakhrajItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.pageBuilder,
  });
}
