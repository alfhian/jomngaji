import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../../models/surah.dart';
import '../belajar/detail_surah_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  static const List<Surah> _dummySurahList = [
    Surah(number: 1, name: "Al-Fatihah", ayatCount: 7),
    Surah(number: 2, name: "Al-Ikhlas", ayatCount: 4),
    Surah(number: 3, name: "Al-Falaq", ayatCount: 5),
    Surah(number: 4, name: "An-Naas", ayatCount: 6),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4), // soft mint background
      body: SafeArea(
        child: Column(
          children: [
            // 🧕 Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Assalamu’alaikum 👋",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Ayo Mengaji Hari Ini!",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xFF16A34A)),
                  ),
                ],
              ),
            ),

            // 🌙 Banner Section (with Lottie)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF86EFAC), Color(0xFFA7F3D0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade100,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 🎬 Lottie animation
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Lottie.asset(
                      'assets/animations/quran.json',
                      repeat: true,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Terakhir dibaca",
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                        SizedBox(height: 4),
                        Text(
                          "Surah Al-Fatihah",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("Ayat ke-3",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.play_circle_fill,
                      color: Colors.white, size: 44),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),

            const SizedBox(height: 24),

            // 📜 Section title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Daftar Surah",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 📖 List Surah
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _dummySurahList.length,
                itemBuilder: (context, index) {
                  final surah = _dummySurahList[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      _createFadeRoute(DetailSurahScreen(surah: surah)),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Hero(
                            tag: surah.name,
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.green.shade50,
                              backgroundImage: const AssetImage(
                                'assets/images/kids_quran.png',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  surah.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text('${surah.ayatCount} ayat',
                                    style: const TextStyle(
                                        color: Colors.black54, fontSize: 14)),
                              ],
                            ),
                          ),
                          const Icon(Icons.play_arrow_rounded,
                              color: Color(0xFF16A34A), size: 32),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎞️ Helper untuk animasi transisi halus ke halaman detail
  Route _createFadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}
