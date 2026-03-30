import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../features/auth/services/auth_service.dart';
import 'ikhtiarku_page.dart';
import 'ikhtiar_step_page.dart';

class IkhtiarPage extends StatefulWidget {
  const IkhtiarPage({super.key});

  @override
  State<IkhtiarPage> createState() => _IkhtiarPageState();
}

class _IkhtiarPageState extends State<IkhtiarPage> {
  String _category = 'semua';
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.get(
        Uri.parse('${AuthService.baseUrl}/ikhtiar?category=$_category'),
        headers: headers,
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _items = (data['items'] as List<dynamic>? ?? [])
            .map((e) => (e as Map).cast<String, dynamic>())
            .toList();
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    const categories = ['semua', 'bertumbuh', 'keluarga', 'muhasabah'];
    return Column(
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: 42,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) {
              final c = categories[i];
              final active = c == _category;
              return ChoiceChip(
                label: Text(c[0].toUpperCase() + c.substring(1)),
                selected: active,
                onSelected: (_) {
                  setState(() => _category = c);
                  _load();
                },
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: categories.length,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                  children: [
                    if (_items.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDEDE6),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(width: 80, height: 60, color: Colors.white),
                                const SizedBox(width: 12),
                                Expanded(child: Text(_items.first['title'].toString(), style: const TextStyle(fontSize: 16))),
                                const Text('0/10 hari'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => IkhtiarkuPage(items: _items)),
                              ),
                              child: const Text('Lihat Ikhtiarku'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    GridView.builder(
                      itemCount: _items.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.78,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 12,
                      ),
                      itemBuilder: (_, i) {
                        final item = _items[i];
                        final image = (item['cover_image'] ?? '').toString();
                        return InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => IkhtiarStepPage(itemId: item['id'].toString())),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFD2E4DC)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                  child: Image.network(
                                    image,
                                    height: 110,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(height: 110, color: Colors.grey.shade300),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    (item['title'] ?? '').toString(),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
