import 'package:flutter/material.dart';

import 'widgets/makhraj_category_practice_page.dart';

class SyafawiPage extends StatelessWidget {
  const SyafawiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MakhrajCategoryPracticePage(
      title: 'Syafawi (Bibir)',
      info:
          'Syafawi adalah huruf yang keluar dari bibir. Latih bukaan dan tekanan bibir dengan stabil agar bunyi tidak samar.',
      primaryColor: Color(0xFF4CAF50),
      letters: [
        MakhrajLetter(huruf: 'ف', nama: 'Fa'),
        MakhrajLetter(huruf: 'ب', nama: 'Ba'),
        MakhrajLetter(huruf: 'م', nama: 'Mim'),
      ],
    );
  }
}
