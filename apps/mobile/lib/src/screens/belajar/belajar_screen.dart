import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../config/router.dart';
import '../../data/surah_repository.dart';
import '../../models/surah.dart';

class BelajarScreen extends StatelessWidget {
  const BelajarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final surahRepository = GetIt.I<SurahRepository>();
    final surahList = surahRepository.getAll();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daftar Surat',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: surahList.length,
                itemBuilder: (context, index) {
                  final surah = surahList[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[200],
                        child: Text(
                          '${surah.number}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        surah.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text('${surah.ayatCount} ayat'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        context.pushNamed(
                          AppRoute.lessonDetail.name,
                          pathParameters: {'surahId': '${surah.number}'},
                          extra: surah,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
