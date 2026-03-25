import 'package:flutter/material.dart';

import 'widgets/makhraj_category_practice_page.dart';

class KhaysyumPage extends StatelessWidget {
  const KhaysyumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MakhrajCategoryPracticePage(
      title: 'Khaysyum (Rongga Hidung)',
      info:
          'Khaysyum adalah resonansi suara dari rongga hidung (ghunnah). Latih dengung stabil dan jangan terlalu ditekan.',
      primaryColor: Color(0xFF66BB6A),
      letters: [
        MakhrajLetter(huruf: 'ن', nama: 'Nun (Ghunnah)'),
      ],
    );
  }
}
