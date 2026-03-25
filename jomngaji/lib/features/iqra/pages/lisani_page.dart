import 'package:flutter/material.dart';

import 'widgets/makhraj_category_practice_page.dart';

class LisaniPage extends StatelessWidget {
  const LisaniPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MakhrajCategoryPracticePage(
      title: 'Lisani (Lidah)',
      info:
          'Lisani adalah huruf yang keluar dari lidah. Posisi lidah terhadap gigi/langit-langit sangat penting agar makhraj tepat.',
      primaryColor: Color(0xFF2F9E6E),
      letters: [
        MakhrajLetter(huruf: 'ت', nama: 'Ta'),
        MakhrajLetter(huruf: 'د', nama: 'Dal'),
        MakhrajLetter(huruf: 'ط', nama: 'Tha'),
        MakhrajLetter(huruf: 'ظ', nama: 'Zha'),
        MakhrajLetter(huruf: 'ل', nama: 'Lam'),
        MakhrajLetter(huruf: 'ر', nama: 'Ra'),
      ],
    );
  }
}
