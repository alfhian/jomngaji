import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // Import audioplayers
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts
import '../../../core/widgets/custom_gradient_appbar.dart';

class DetailHurufHijaiyahPage extends StatelessWidget {
  final String huruf;
  final String nama;
  final String caraBaca;
  final String awal;
  final String tengah;
  final String akhir;
  
  final String fathah;
  final String kasrah;
  final String dhammah;
  final String tanwinFathah;
  final String tanwinKasrah;
  final String tanwinDhammah;

  // Inisialisasi player
  final AudioPlayer player = AudioPlayer();

  // Function untuk memutar audio
  void playAudio(String file) {
    player.play(AssetSource(file));
  }

  // Constructor dengan parameter yang dibutuhkan
  DetailHurufHijaiyahPage({
    super.key,
    required this.huruf,
    required this.nama,
    required this.caraBaca,
    required this.awal,
    required this.tengah,
    required this.akhir,
    required this.fathah,
    required this.kasrah,
    required this.dhammah,
    required this.tanwinFathah,
    required this.tanwinKasrah,
    required this.tanwinDhammah,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomGradientAppBar(title: "Detail Huruf Hijaiyah"),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 10),

            // ================================
            // HURUF BESAR
            // ================================
            Center(
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2FFF6),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Center(
                  child: Text(
                    huruf,
                    style: const TextStyle(
                      fontSize: 90,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF42C88A),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Nama huruf
            Center(
              child: Text(
                nama,
                style: GoogleFonts.cairo(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Cara baca
            Center(
              child: Text(
                "Cara baca: $caraBaca",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ================================
            // 1. Bentuk Sambung
            // ================================
            _title("Bentuk Sambung"),

            const SizedBox(height: 12),
            _rowText("Awal", awal),
            const SizedBox(height: 8),
            _rowText("Tengah", tengah),
            const SizedBox(height: 8),
            _rowText("Akhir", akhir),

            const SizedBox(height: 30),

            // ================================
            // 2. Harakat Dasar
            // ================================
            _title("Harakat Dasar"),
            const SizedBox(height: 12),

            _harakatCard("Fathah", fathah, "A", const Color(0xFFFFF9C4)),
            _harakatCard("Kasrah", kasrah, "I", const Color(0xFFE1F5FE)),
            _harakatCard("Dhammah", dhammah, "U", const Color(0xFFE1BEE7)),

            const SizedBox(height: 30),

            // ================================
            // 3. Tanwin
            // ================================
            _title("Tanwin"),
            const SizedBox(height: 12),

            _harakatCard("Tanwin Fathah", tanwinFathah, "AN", const Color(0xFFFFE0B2)),
            _harakatCard("Tanwin Kasrah", tanwinKasrah, "IN", const Color(0xFFB2EBF2)),
            _harakatCard("Tanwin Dhammah", tanwinDhammah, "UN", const Color(0xFFD1C4E9)),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Judul section (Bentuk Sambung, Harakat Dasar, dll)
  Widget _title(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF42C88A),
      ),
    );
  }

  // Row untuk menampilkan bentuk sambung huruf
  Widget _rowText(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF42C88A),
          ),
        ),
      ],
    );
  }

  // Row untuk menampilkan harakat
  Widget _harakatRow(String label, String symbol, String latin) {
    return GestureDetector(
      onTap: () {
        // Memutar audio harakat saat ditekan
        playAudio("audio/harakat/$symbol.mp3");
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6FFF6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Column(
              children: [
                Text(
                  symbol,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF42C88A),
                  ),
                ),
                Text(
                  latin,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // ======================
  // HARAKAT CARD
  // ======================
  Widget _harakatCard(String label, String arab, String latin, Color color) {
    return GestureDetector(
      onTap: () => playAudio("audio/harakat/$arab.mp3"),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 16)),
            Column(
              children: [
                Text(
                  arab,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF42C88A),
                  ),
                ),
                Text(
                  latin,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
