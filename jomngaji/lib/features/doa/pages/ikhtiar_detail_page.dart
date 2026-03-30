import 'package:flutter/material.dart';

import '../data/doa_catalog.dart';

class IkhtiarDetailPage extends StatefulWidget {
  final IkhtiarItem item;

  const IkhtiarDetailPage({super.key, required this.item});

  @override
  State<IkhtiarDetailPage> createState() => _IkhtiarDetailPageState();
}

class _IkhtiarDetailPageState extends State<IkhtiarDetailPage> {
  @override
  Widget build(BuildContext context) {
    final done = IkhtiarDoneStore.isDone(widget.item.id);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Ikhtiar'),
        backgroundColor: const Color(0xFF41A07A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.item.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
            const SizedBox(height: 10),
            Text(widget.item.description, style: const TextStyle(height: 1.5)),
            const SizedBox(height: 16),
            const Text('Langkah Amalan', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...widget.item.steps.map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF3F9C77)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(step)),
                    ],
                  ),
                )),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() => IkhtiarDoneStore.toggleDone(widget.item.id));
                },
                icon: Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded),
                label: Text(done ? 'Sudah Dikerjakan' : 'Tandai Sudah Dikerjakan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: done ? const Color(0xFF3F9C77) : const Color(0xFF1C8D64),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
