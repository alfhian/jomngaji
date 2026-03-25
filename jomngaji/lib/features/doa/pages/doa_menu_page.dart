import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/doa.dart';
import '../../../routes/app_routes.dart';
import '../../home/widgets/app_bottom_nav.dart';
import '../data/doa_data.dart';

class DoaMenuPage extends StatelessWidget {
  const DoaMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FCF9),
      extendBody: true,
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _heroSection(context)),
            SliverToBoxAdapter(child: _summaryCard()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
              sliver: SliverList.builder(
                itemCount: doaList.length,
                itemBuilder: (context, index) {
                  final doa = doaList[index];
                  return _doaCard(context, doa, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFF128A64), Color(0xFF3CCF95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
            borderRadius: BorderRadius.circular(99),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Doa Harian',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Baca, pahami, dan amalkan doa-doa pilihan setiap hari.',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F9EF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_stories_rounded, color: Color(0xFF1E9A71)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${doaList.length} doa siap dipelajari lengkap dengan teks Arab, latin, dan arti.',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: Colors.black87,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _doaCard(BuildContext context, Doa doa, int index) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.doaDetail, arguments: doa),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFDDF5EA)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE7FFF2),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF168A66),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doa.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      doa.arab,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.amiri(
                        fontSize: 17,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF1E9A71), size: 28),
          ],
        ),
      ),
    );
  }
}
