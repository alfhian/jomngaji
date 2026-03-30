import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../models/doa.dart';
import '../../../routes/app_routes.dart';
import '../data/doa_catalog.dart';

class DoaCategoryListPage extends StatefulWidget {
  final DoaCategory category;

  const DoaCategoryListPage({super.key, required this.category});

  @override
  State<DoaCategoryListPage> createState() => _DoaCategoryListPageState();
}

class _DoaCategoryListPageState extends State<DoaCategoryListPage> {
  @override
  Widget build(BuildContext context) {
    final items = DoaCatalog.byCategory(widget.category);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.title),
        backgroundColor: const Color(0xFF41A07A),
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _doaCard(items[i], i),
      ),
    );
  }

  Widget _doaCard(Doa doa, int index) {
    final favorite = FavoriteDoaStore.isFavorite(doa.id);
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.doaDetail, arguments: doa),
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD8E7E0)),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE5F3EC),
              child: Text('${index + 1}', style: const TextStyle(color: Color(0xFF3E8D6C))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                doa.title,
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
            IconButton(
              onPressed: () => setState(() => FavoriteDoaStore.toggle(doa.id)),
              icon: Icon(
                favorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: favorite ? const Color(0xFFFACD38) : const Color(0xFF7DA494),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
