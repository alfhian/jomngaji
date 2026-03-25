import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/custom_gradient_appbar.dart';
import '../data/hijaiyah_data.dart';
import 'detail_huruf_hijaiyah_page.dart';
import 'latihan_pengucapan_page.dart';


class MateriHurufDetailPage extends StatelessWidget {
  final int lessonId;
  final String lessonTitle;
  final List<HijaiyahData> hurufList;

  const MateriHurufDetailPage({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
    required this.hurufList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomGradientAppBar(title: lessonTitle),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _header(),

          const SizedBox(height: 25),

          _sectionTitle("Huruf dalam materi ini"),
          const SizedBox(height: 12),

          ...hurufList.map((h) => _hurufCard(context, h)),

          const SizedBox(height: 30),

          _buttonLatihanSuara(context), // <<-- PAKAI CONTEXT
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF8F3),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ringkasan Materi",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Pada pelajaran ini kamu akan mempelajari huruf $lessonTitle, "
            "cara membacanya, perbedaannya, serta bentuk sambungannya.",
            style: GoogleFonts.poppins(
              height: 1.5,
              fontSize: 14,
              color: Colors.black87,
            ),
          )
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Text(
      t,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _hurufCard(BuildContext context, HijaiyahData data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailHurufHijaiyahPage(
              huruf: data.huruf,
              nama: data.nama,
              caraBaca: data.latin,
              awal: data.awal,
              tengah: data.tengah,
              akhir: data.akhir,
              fathah: data.fathah,
              dhammah: data.dhammah,
              kasrah: data.kasrah,
              tanwinFathah: data.tanwinFathah,
              tanwinDhammah: data.tanwinDhammah,
              tanwinKasrah: data.tanwinKasrah,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: data.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  data.huruf,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                data.nama,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 28, color: Colors.black26)
          ],
        ),
      ),
    );
  }

  Widget _buttonLatihanSuara(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF42C88A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LatihanPengucapanPage(
              lessonId: lessonId, // ✅ BUKAN widget.lessonId
              lessonTitle: lessonTitle,
              hurufList: hurufList,
            ),
          ),
        );
      },
      icon: const Icon(Icons.mic, size: 22),
      label: const Text(
        "Latihan Pengucapan",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}
