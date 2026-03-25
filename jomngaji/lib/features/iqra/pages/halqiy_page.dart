import 'package:flutter/material.dart';

import 'widgets/makhraj_category_practice_page.dart';

class HalqiyPage extends StatelessWidget {
  const HalqiyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MakhrajCategoryPracticePage(
      title: 'Halqiy (Tenggorokan)',
      info:
          'Halqiy adalah huruf yang keluar dari tenggorokan. Fokuskan suara agar jelas keluar dari pangkal tenggorokan tanpa menekan berlebihan.',
      primaryColor: Color(0xFF42C88A),
      letters: [
        MakhrajLetter(huruf: 'ء', nama: 'Hamzah'),
        MakhrajLetter(huruf: 'هـ', nama: 'Ha'),
      ],
    );
  }
}
