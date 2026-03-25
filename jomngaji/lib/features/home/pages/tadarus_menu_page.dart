import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/custom_gradient_appbar.dart';
import '../../../routes/app_routes.dart';
import '../../../models/surah.dart';
import '../../tadarus/data/quran_loader.dart';

class TadarusMenuPage extends StatefulWidget {
  const TadarusMenuPage({super.key});

  @override
  State<TadarusMenuPage> createState() => _TadarusMenuPageState();
}

class _TadarusMenuPageState extends State<TadarusMenuPage> {
  List<Surah> _allSurahs = [];
  List<Surah> _filteredSurahs = [];
  bool _loading = true;

  final TextEditingController _searchCtrl = TextEditingController();
  String _ayatRangeLabel = "Ayat 1–7";

  // Mock aktivitas terakhir
  String _lastRead = "Al-Fatihah, Ayat 1";
  String _lastRecited = "Al-Fatihah, Ayat 1";

  @override
  void initState() {
    super.initState();
    _loadSurahs();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSurahs() async {
    final data = await loadQuranDataset(); // ambil dari backend
    setState(() {
      _allSurahs = data;
      _filteredSurahs = data;
      _loading = false;
    });
  }

  void _applyFilter() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredSurahs = _allSurahs;
      } else {
        _filteredSurahs = _allSurahs.where((s) {
          final name = s.name.toLowerCase();
          return name.contains(q) || s.number.toString().contains(q);
        }).toList();
      }
    });
  }

  void _onSearchPressed() {
    FocusScope.of(context).unfocus();
    _applyFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: const CustomGradientAppBar(title: "Tadarus"),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _progressCard(),
                  const SizedBox(height: 16),
                  _searchRow(),
                  const SizedBox(height: 16),
                  _lastActivityCard(),
                  const SizedBox(height: 16),
                  Text("Daftar Surah",
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Expanded(child: _surahList(context)),
                ],
              ),
            ),
    );
  }

  // ——— Widgets ———

  Widget _progressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE7FFF2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF42C88A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.menu_book_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Lanjutkan Khatam Al-Qur’an",
                    style: GoogleFonts.poppins(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: 0.05,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    color: const Color(0xFF42C88A),
                  ),
                ),
                const SizedBox(height: 6),
                Text("Checkpoint 1",
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: "Cari Surah",
              hintStyle: GoogleFonts.poppins(fontSize: 14),
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF42C88A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(_ayatRangeLabel,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _onSearchPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF42C88A),
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: Text("Cari Surah",
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _lastActivityCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Aktivitas Terakhir",
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text("Terakhir Dibaca: $_lastRead",
              style: GoogleFonts.poppins(fontSize: 13)),
          Text("Terakhir Dilafalkan: $_lastRecited",
              style: GoogleFonts.poppins(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _surahList(BuildContext context) {
    return ListView.builder(
      itemCount: _filteredSurahs.length,
      itemBuilder: (context, index) {
        final s = _filteredSurahs[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.tadarus,
              arguments: s,
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name,
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text("${s.ayahCount} Ayat",
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: s.progress,
                  backgroundColor: Colors.grey.shade300,
                  color: const Color(0xFF42C88A),
                  minHeight: 6,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
