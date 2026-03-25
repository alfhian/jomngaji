import 'package:flutter/material.dart';

import '../localization/app_localization.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final bool showSeeAll;

  const SectionTitle({
    super.key,
    required this.title,
    this.onSeeAll,
    this.showSeeAll = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            )),
        if (showSeeAll)
          TextButton(
            onPressed: onSeeAll ?? () {},
            child: Row(
              children: [
                Text(context.l10n.text('home.seeAll'), style: TextStyle(color: color)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios_rounded, color: color, size: 12),
              ],
            ),
          ),
      ],
    );
  }
}
