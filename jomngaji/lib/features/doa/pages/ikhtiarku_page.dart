import 'package:flutter/material.dart';

class IkhtiarkuPage extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const IkhtiarkuPage({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ikhtiarku'),
        backgroundColor: const Color(0xFF49A178),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          final days = (item['days'] ?? 7) as int;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                Container(width: 70, height: 70, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item['title'].toString(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: 0.1, borderRadius: BorderRadius.circular(8)),
                  ]),
                ),
                const SizedBox(width: 8),
                Text('1/$days hari'),
              ],
            ),
          );
        },
      ),
    );
  }
}
