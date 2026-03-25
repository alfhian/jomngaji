import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/quran_loader.dart';
import '../../../models/surah.dart';
import 'tadarus_detail_page.dart';

class SurahListPage extends StatefulWidget {
  const SurahListPage({super.key});

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  List<Surah> surahs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    final data = await loadQuranDataset();
    setState(() {
      surahs = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Surah")),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: surahs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final s = surahs[index];
          return ListTile(
            tileColor: const Color(0xFFE7FFF2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              s.name,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              "Surah ke-${s.number} • ${s.ayahs.length} ayat",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TadarusDetailPage(surah: s), // ✅ kirim objek Surah
                ),
              );
            },
          );
        },
      ),
    );
  }
}
