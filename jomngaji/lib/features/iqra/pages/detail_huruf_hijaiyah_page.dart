import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_design_tokens.dart';
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

  final AudioPlayer player = AudioPlayer();

  void playAudio(String file) {
    player.play(AssetSource(file));
  }

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
      backgroundColor: AppColors.scaffold,
      appBar: const CustomGradientAppBar(title: "Detail Huruf Hijaiyah"),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _headerHuruf(),
          const SizedBox(height: 32),
          _sectionTitle("Bentuk Sambung"),
          const SizedBox(height: 16),
          _rowSambung("Huruf Awal", awal),
          _rowSambung("Huruf Tengah", tengah),
          _rowSambung("Huruf Akhir", akhir),
          const SizedBox(height: 32),
          _sectionTitle("Harakat Dasar"),
          const SizedBox(height: 16),
          _harakatGrid([
            _HarakatData("Fathah (A)", fathah, "A", AppColors.accent),
            _HarakatData("Kasrah (I)", kasrah, "I", AppColors.secondary),
            _HarakatData("Dhammah (U)", dhammah, "U", Colors.orange),
          ]),
          const SizedBox(height: 32),
          _sectionTitle("Tanwin"),
          const SizedBox(height: 16),
          _harakatGrid([
            _HarakatData("Fathah (AN)", tanwinFathah, "AN", Colors.redAccent),
            _HarakatData("Kasrah (IN)", tanwinKasrah, "IN", Colors.blueAccent),
            _HarakatData("Dhammah (UN)", tanwinDhammah, "UN", Colors.purpleAccent),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _headerHuruf() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.medium,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              huruf,
              style: GoogleFonts.amiri(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            nama,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Cara baca: $caraBaca",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _rowSambung(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.soft,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.amiri(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _harakatGrid(List<_HarakatData> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisExtent: 80,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => playAudio("audio/harakat/${item.arab}.mp3"),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppShadows.soft,
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 32,
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      item.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.arab,
                      style: GoogleFonts.amiri(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        height: 1,
                      ),
                    ),
                    Text(
                      item.latin,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPlaceholder,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HarakatData {
  final String label;
  final String arab;
  final String latin;
  final Color color;

  _HarakatData(this.label, this.arab, this.latin, this.color);
}
