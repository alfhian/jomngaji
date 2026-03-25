import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/doa.dart';

class DoaDetailPage extends StatelessWidget {
  final Doa doa;

  const DoaDetailPage({super.key, required this.doa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FCF9),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _header(context),
            const SizedBox(height: 14),
            _arabicCard(),
            const SizedBox(height: 12),
            _sectionCard(
              title: 'Latin',
              child: Text(
                doa.latin,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  height: 1.7,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _sectionCard(
              title: 'Arti',
              child: Text(
                doa.arti,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.8,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (doa.audioUrl != null)
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur pemutar audio akan segera tersedia.'),
                    ),
                  );
                },
                icon: const Icon(Icons.volume_up_rounded),
                label: const Text('Putar Audio Doa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A9F73),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF11805E), Color(0xFF34C68F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(99),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            doa.title,
            style: GoogleFonts.poppins(
              fontSize: 23,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Baca dengan tartil dan pahami maknanya.',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: Colors.white.withOpacity(0.92),
            ),
          ),
        ],
      ),
    );
  }

  Widget _arabicCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Arab',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A9F73),
            ),
          ),
          const SizedBox(height: 10),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              doa.arab,
              textAlign: TextAlign.right,
              style: GoogleFonts.amiri(
                fontSize: 34,
                height: 1.8,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2F6EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A9F73),
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
