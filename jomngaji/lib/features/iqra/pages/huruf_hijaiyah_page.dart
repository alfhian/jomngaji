import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/custom_gradient_appbar.dart';

class DetailHurufHijaiyahPage extends StatefulWidget {
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

  const DetailHurufHijaiyahPage({
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
  State<DetailHurufHijaiyahPage> createState() =>
      _DetailHurufHijaiyahPageState();
}

class _DetailHurufHijaiyahPageState extends State<DetailHurufHijaiyahPage> {
  final AudioPlayer player = AudioPlayer();

  void playAudio(String file) {
    player.play(AssetSource(file));
  }

  // ===== Placeholder AI Matching (akan diganti Whisper/OpenAI API)
  Future<void> startRecording() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fitur rekam suara segera hadir!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomGradientAppBar(title: "Detail Huruf"),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),
          _headerHuruf(),
          const SizedBox(height: 20),

          _deskripsiHuruf(),
          const SizedBox(height: 25),

          _sectionTitle("Bentuk Sambung"),
          const SizedBox(height: 10),
          _rowSambung("Awal", widget.awal),
          _rowSambung("Tengah", widget.tengah),
          _rowSambung("Akhir", widget.akhir),
          const SizedBox(height: 25),

          _sectionTitle("Harakat Dasar"),
          const SizedBox(height: 10),
          _harakat("Fathah", widget.fathah, "A"),
          _harakat("Kasrah", widget.kasrah, "I"),
          _harakat("Dhammah", widget.dhammah, "U"),

          const SizedBox(height: 25),
          _sectionTitle("Tanwin"),
          const SizedBox(height: 10),
          _harakat("Tanwin Fathah", widget.tanwinFathah, "AN"),
          _harakat("Tanwin Kasrah", widget.tanwinKasrah, "IN"),
          _harakat("Tanwin Dhammah", widget.tanwinDhammah, "UN"),

          const SizedBox(height: 35),

          _buttonDengarContoh(),

          const SizedBox(height: 15),

          _buttonRekam(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ==================================================
  Widget _headerHuruf() {
    return Center(
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Center(
          child: Text(
            widget.huruf,
            style: GoogleFonts.cairo(
              fontSize: 95,
              color: Colors.blueGrey.shade700,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _deskripsiHuruf() {
    return Column(
      children: [
        Text(
          widget.nama,
          style: GoogleFonts.cairo(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Cara baca: ${widget.caraBaca}",
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 14),
        Text(
          "Huruf ${widget.nama} merupakan salah satu huruf dasar dalam bahasa Arab. "
          "Pelajari bentuk sambungannya, variasi harakat, serta cara pelafalannya dengan benar.",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String t) {
    return Text(
      t,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _rowSambung(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 15)),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _harakat(String title, String arab, String latin) {
    return GestureDetector(
      onTap: () => playAudio("audio/harakat/$arab.mp3"),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF7FF),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 15)),
            Column(
              children: [
                Text(
                  arab,
                  style: GoogleFonts.cairo(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  latin,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttonDengarContoh() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey.shade600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: () => playAudio("audio/huruf/${widget.huruf}.mp3"),
      icon: const Icon(Icons.volume_up_rounded),
      label: const Text(
        "Dengarkan Contoh Bacaan",
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buttonRekam() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF42C88A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: () => startRecording(),
      icon: const Icon(Icons.mic_rounded),
      label: const Text(
        "Mulai Rekam Pengucapan",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}
