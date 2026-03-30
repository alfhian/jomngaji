import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../features/auth/services/auth_service.dart';

class IkhtiarStepPage extends StatefulWidget {
  final String itemId;
  const IkhtiarStepPage({super.key, required this.itemId});

  @override
  State<IkhtiarStepPage> createState() => _IkhtiarStepPageState();
}

class _IkhtiarStepPageState extends State<IkhtiarStepPage> {
  Map<String, dynamic>? _item;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final headers = await AuthService.authHeaders();
    final res = await http.get(Uri.parse('${AuthService.baseUrl}/ikhtiar/${widget.itemId}'), headers: headers);
    if (res.statusCode == 200 && mounted) {
      setState(() => _item = (jsonDecode(res.body) as Map).cast<String, dynamic>());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_item == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final steps = (_item!['steps'] as List<dynamic>? ?? []);
    final step = steps.isEmpty ? null : (steps[_index] as Map).cast<String, dynamic>();
    final total = steps.isEmpty ? 1 : steps.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF49A178),
        foregroundColor: Colors.white,
        title: Text((_item!['title'] ?? '').toString()),
      ),
      body: step == null
          ? const Center(child: Text('Materi ikhtiar belum tersedia.'))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: List.generate(
                      total,
                      (i) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          height: 8,
                          decoration: BoxDecoration(
                            color: i <= _index ? const Color(0xFFF0CE63) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Hari ke ${(step['day'] ?? _index + 1)}',
                    style: const TextStyle(color: Color(0xFF7D8783)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                  child: Text(step['title'].toString(), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800)),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _stepBody(step),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _index > 0 ? () => setState(() => _index--) : null,
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          if (_index >= total - 1) {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => const Padding(
                                padding: EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, size: 52, color: Color(0xFF2BC56D)),
                                    SizedBox(height: 10),
                                    Text('Hari ke 1 selesai', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24)),
                                    SizedBox(height: 18),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            setState(() => _index++);
                          }
                        },
                        child: Text(_index >= total - 1 ? 'Selesai' : 'Lanjut'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _stepBody(Map<String, dynamic> step) {
    final kind = (step['kind'] ?? '').toString();
    if (kind == 'doa') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(height: 20),
          Text(step['arabic']?.toString() ?? '', textAlign: TextAlign.right, style: const TextStyle(fontSize: 44, height: 1.6)),
          const SizedBox(height: 14),
          Text(step['latin']?.toString() ?? '', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(step['translation']?.toString() ?? '', style: const TextStyle(fontSize: 18, color: Color(0xFF666E6A))),
        ],
      );
    }
    if (kind == 'tantangan') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎯 Tantangan', style: TextStyle(fontSize: 44, fontWeight: FontWeight.w700, color: Colors.blue)),
          const SizedBox(height: 10),
          Text(step['content']?.toString() ?? '', style: const TextStyle(fontSize: 18, height: 1.6)),
          const SizedBox(height: 20),
          OutlinedButton(onPressed: () {}, child: const Text('Ambil Tantangan')),
        ],
      );
    }
    if (kind == 'kutipan') {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFB7F0BB), Color(0xFFF2E4D6)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(step['content']?.toString() ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),
            Text(step['source']?.toString() ?? ''),
          ],
        ),
      );
    }
    return Text(step['content']?.toString() ?? '', style: const TextStyle(fontSize: 18, height: 1.8));
  }
}
