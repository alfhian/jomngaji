import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/custom_gradient_appbar.dart';

class PengucapanPage extends StatelessWidget {
  const PengucapanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomGradientAppBar(title: "Pengucapan & Makhraj"),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionTitle("Makhraj Huruf"),
          _makhrajCard(
            "Halqiy (Tenggorokan)",
            "Huruf: ء هـ",
          ),
          _makhrajCard(
            "Lisani (Lidah)",
            "Huruf: ت د ط ظ ل ر",
          ),
          _makhrajCard(
            "Syafawi (Bibir)",
            "Huruf: ف ب م",
          ),
          _makhrajCard(
            "Khaysyum (Rongga Hidung)",
            "Huruf: ن (ghunnah)",
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF42C88A),
        ),
      ),
    );
  }

  Widget _makhrajCard(String title, String detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2FFF6),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 6),
          Text(detail,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              )),
        ],
      ),
    );
  }
}
