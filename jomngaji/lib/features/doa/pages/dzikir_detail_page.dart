import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../features/auth/services/auth_service.dart';

class DzikirDetailPage extends StatefulWidget {
  final String itemId;
  final String periodLabel;
  final int index;
  final int total;

  const DzikirDetailPage({
    super.key,
    required this.itemId,
    required this.periodLabel,
    required this.index,
    required this.total,
  });

  @override
  State<DzikirDetailPage> createState() => _DzikirDetailPageState();
}

class _DzikirDetailPageState extends State<DzikirDetailPage> {
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final headers = await AuthService.authHeaders();
    final res = await http.get(Uri.parse('${AuthService.baseUrl}/dzikir/${widget.itemId}'), headers: headers);
    if (res.statusCode == 200 && mounted) {
      setState(() => _data = (jsonDecode(res.body) as Map).cast<String, dynamic>());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF49A178),
        foregroundColor: Colors.white,
        title: Text(widget.periodLabel),
        actions: [
          Center(child: Text('${widget.index + 1} dari ${widget.total}')),
          const SizedBox(width: 16),
          const Icon(Icons.star_border_rounded),
          const SizedBox(width: 12),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF4B980C),
        child: const Icon(Icons.mic, color: Colors.white),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        color: Colors.white,
        child: Row(
          children: [
            IconButton(onPressed: null, icon: const Icon(Icons.arrow_back_rounded)),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF4A8F12))),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F3E0),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text('Ulang Bacaan', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF4A8F12))),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(_data!['title'].toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFF3EA),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFC3DED1)),
                  ),
                  child: Text(_data!['repeat'].toString(), style: const TextStyle(color: Color(0xFF4D8E76))),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFDFF3EA), borderRadius: BorderRadius.circular(28)),
              child: Center(child: Text(_data!['subtitle'].toString(), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF3C8D70)))),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(22)),
                child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 38),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _data!['arabic'].toString(),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 54, height: 1.6),
            ),
            const SizedBox(height: 12),
            Text(_data!['translation'].toString(), style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
