import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_design_tokens.dart';
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
      backgroundColor: AppColors.scaffold,
      appBar: CustomGradientAppBar(title: lessonTitle),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _header(),
          const SizedBox(height: 32),
          Text(
            "Huruf dalam Materi Ini",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...hurufList.map((h) => _hurufCard(context, h)),
          const SizedBox(height: 32),
          _buttonLatihanSuara(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_stories_rounded, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                "Ringkasan Materi",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Pada pelajaran ini kamu akan mempelajari huruf $lessonTitle, "
            "cara membacanya, perbedaannya, serta bentuk sambungannya.",
            style: GoogleFonts.plusJakartaSans(
              height: 1.5,
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
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
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: AppShadows.soft,
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: data.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  data.huruf,
                  style: GoogleFonts.amiri(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.nama,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Lihat detail & bentuk sambung",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textPlaceholder)
          ],
        ),
      ),
    );
  }

  Widget _buttonLatihanSuara(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LatihanPengucapanPage(
                lessonId: lessonId,
                lessonTitle: lessonTitle,
                hurufList: hurufList,
              ),
            ),
          );
        },
        icon: const Icon(Icons.mic_rounded, size: 24),
        label: const Text("Mulai Latihan Pengucapan"),
      ),
    );
  }
}
