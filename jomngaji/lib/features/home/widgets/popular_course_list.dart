import 'package:flutter/material.dart';

class PopularCourseList extends StatelessWidget {
  const PopularCourseList({super.key});

  @override
  Widget build(BuildContext context) {
    final courses = [
      ("Belajar Iqra' dari Nol", "Cocok untuk pemula.", 12),
      ("Tajwid Praktis", "Latihan tajwid sehari-hari.", 15),
      ("Tilawah Juz 30", "Irama ringan dan mudah.", 10),
    ];

    return Column(
      children: courses.map((c) => _CourseCard(c)).toList(),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final (String, String, int) data;

  const _CourseCard(this.data);

  @override
  Widget build(BuildContext context) {
    final (title, desc, lessons) = data;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 90,
      child: Stack(
        children: [
          // --- BACKGROUND IMAGE ---
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                image: const DecorationImage(
                  image: AssetImage("assets/images/background_card.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // --- OVERLAY UNTUK MENURUNKAN OPACITY ---
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white.withOpacity(0.55), 
                // 👉 atur intensitas sesuai selera (0.3 – 0.7 bagus)
              ),
            ),
          ),

          // --- CONTENT LIST TILE ---
          Positioned.fill(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

              leading: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.mosque, color: Color(0xFF42C88A)),
              ),

              title: Text(
                title,
                maxLines: 1,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),

              subtitle: Text(
                "$desc\n$lessons pelajaran",
                maxLines: 2,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.3,
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


