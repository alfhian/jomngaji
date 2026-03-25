import 'package:flutter/material.dart';
import '../../../../core/widgets/premium_upgrade_dialog.dart';
import '../../../../core/widgets/custom_gradient_appbar.dart';
import '../../../../routes/app_routes.dart';
import '../widgets/animated_tajwid_card.dart';

class TajwidDasarPage extends StatelessWidget {
  const TajwidDasarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomGradientAppBar(title: 'Tajwid Dasar'),
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
            _tajwidItem(
              context,
              color: const Color(0xFFEAF3FF),
              iconColor: const Color(0xFF2563EB),
              title: 'Teori Tajwid',
              subtitle: 'Materi dasar hukum bacaan lengkap dengan contoh dan audio.',
              icon: Icons.menu_book_rounded,
              route: AppRoutes.materiTajwid,
            ),
            _tajwidItem(
              context,
              color: const Color(0xFFFFF1F2),
              iconColor: const Color(0xFFE11D48),
              title: 'Latihan Tajwid',
              subtitle: 'Latihan interaktif untuk menguji pemahaman tiap materi.',
              icon: Icons.edit_note_rounded,
              route: AppRoutes.latihanTajwid,
            ),
            _tajwidItem(
              context,
              color: const Color(0xFFECFDF3),
              iconColor: const Color(0xFF16A34A),
              title: 'Tes Akhir',
              subtitle: 'Uji kemampuan tajwid kamu secara menyeluruh.',
              icon: Icons.quiz_rounded,
              route: AppRoutes.examTajwid,
              isPro: true,
            ),
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
            'Belajar Tajwid Lebih Nyaman',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text(
            'Mulai dari teori, lanjut latihan, dan tutup dengan tes akhir untuk melihat progresmu.',
            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _tajwidItem(
    BuildContext context, {
    required Color color,
    required Color iconColor,
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
    bool isPro = false,
  }) {
    return AnimatedTajwidCard(
      onTap: () async {
        if (isPro) {
          await runWithPremiumGate(
            context,
            featureName: title,
            onAllowed: () => Navigator.pushNamed(context, route),
          );
          return;
        }
        Navigator.pushNamed(context, route);
      },
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
            if (isPro)
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
}
