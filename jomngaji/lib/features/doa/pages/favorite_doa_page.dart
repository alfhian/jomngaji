import 'package:flutter/material.dart';

import '../../../routes/app_routes.dart';
import '../data/doa_catalog.dart';

class FavoriteDoaPage extends StatefulWidget {
  const FavoriteDoaPage({super.key});

  @override
  State<FavoriteDoaPage> createState() => _FavoriteDoaPageState();
}

class _FavoriteDoaPageState extends State<FavoriteDoaPage> {
  @override
  Widget build(BuildContext context) {
    final items = FavoriteDoaStore.favorites();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doa Favorit'),
        backgroundColor: const Color(0xFF41A07A),
        foregroundColor: Colors.white,
      ),
      body: items.isEmpty
          ? const Center(child: Text('Belum ada doa favorit.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final doa = items[i];
                return Card(
                  child: ListTile(
                    title: Text(doa.title),
                    subtitle: Text(
                      doa.latin,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      onPressed: () => setState(() => FavoriteDoaStore.toggle(doa.id)),
                      icon: const Icon(Icons.star_rounded, color: Color(0xFFFACD38)),
                    ),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.doaDetail, arguments: doa),
                  ),
                );
              },
            ),
    );
  }
}
