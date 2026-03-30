import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../core/theme/app_design_tokens.dart';
import '../../../features/auth/services/auth_service.dart';
import '../../home/widgets/app_bottom_nav.dart';
import '../data/doa_catalog.dart';
import 'doa_category_list_page.dart';
import 'favorite_doa_page.dart';
import 'ikhtiar_detail_page.dart';

class DoaMenuPage extends StatefulWidget {
  const DoaMenuPage({super.key});

  @override
  State<DoaMenuPage> createState() => _DoaMenuPageState();
}

class _DoaMenuPageState extends State<DoaMenuPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _dzikirTab = 0;
  List<_DzikirItem> _dzikirItems = const [];
  bool _loadingDzikir = true;

  final List<_DoaCategoryUi> _categories = const [
    _DoaCategoryUi('ramadan', 'Ramadan', Color(0xFF3E9A70)),
    _DoaCategoryUi('aktivitas', 'Aktivitas', Color(0xFFF49A1F)),
    _DoaCategoryUi('bepergian', 'Bepergian', Color(0xFF3466D5)),
    _DoaCategoryUi('keselamatan', 'Keselamatan', Color(0xFFF75555)),
    _DoaCategoryUi('masjid', 'Masjid', Color(0xFF1892DE)),
    _DoaCategoryUi('pengampunan', 'Pengampunan', Color(0xFFE86AA4)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDzikir();
  }

  Future<void> _loadDzikir() async {
    setState(() => _loadingDzikir = true);
    const tabs = ['pagi', 'petang', 'setelah_sholat'];
    final period = tabs[_dzikirTab];
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.get(Uri.parse('${AuthService.baseUrl}/dzikir?period=$period'), headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final items = (data['items'] as List<dynamic>? ?? [])
            .map((e) => _DzikirItem.fromJson(e as Map<String, dynamic>))
            .toList();
        if (mounted) {
          setState(() => _dzikirItems = items);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _dzikirItems = const [
            _DzikirItem(title: 'Ayat Kursi', subtitle: 'QS. Al-Baqarah ayat 255', repeat: 'Dibaca 1x'),
            _DzikirItem(title: 'Al-Ikhlas', subtitle: 'QS. Al-Ikhlas ayat 1-4', repeat: 'Dibaca 3x'),
          ];
        });
      }
    } finally {
      if (mounted) setState(() => _loadingDzikir = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      extendBody: true,
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      body: SafeArea(
        child: Column(
          children: [
            _topHeader(),
            _searchBar(),
            TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF3F9D7D),
              labelColor: const Color(0xFF3C8E73),
              unselectedLabelColor: AppColors.textSecondary,
              tabs: const [
                Tab(text: 'Ikhtiar'),
                Tab(text: 'Doa'),
                Tab(text: 'Dzikir'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_ikhtiarTab(), _doaCategoriesTab(), _dzikirTabView()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topHeader() {
    return Container(
      color: const Color(0xFF46A37F),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF437E62)),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteDoaPage())).then((_) {
                if (mounted) setState(() {});
              });
            },
            icon: const Icon(Icons.star_rounded, color: Color(0xFFFEE034), size: 34),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      color: const Color(0xFF46A37F),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: Color(0xFF689D86)),
            const SizedBox(width: 10),
            Text(
              'Cari Ikhtiar, Doa, atau Dzikir',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF95A59D),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ikhtiarTab() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: DoaCatalog.ikhtiar.length,
      itemBuilder: (context, index) {
        final item = DoaCatalog.ikhtiar[index];
        final done = IkhtiarDoneStore.isDone(item.id);
        return InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => IkhtiarDetailPage(item: item))).then((_) {
              if (mounted) setState(() {});
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFB6D9CB)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: const Color(0xFFE9F6F0),
                  child: Icon(done ? Icons.check_rounded : Icons.emoji_events_outlined, color: const Color(0xFF3B906F)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(item.title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16)),
                ),
                if (done) const Icon(Icons.done_all_rounded, color: Color(0xFF3B906F)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF84A79A)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _doaCategoriesTab() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      itemCount: _categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.25,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, i) {
        final ui = _categories[i];
        final category = DoaCatalog.categories.firstWhere((e) => e.id == ui.id);
        return InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => DoaCategoryListPage(category: category))).then((_) {
              if (mounted) setState(() {});
            });
          },
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ui.color.withOpacity(0.9), ui.color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: ui.color.withOpacity(0.25), blurRadius: 14, offset: const Offset(0, 5))],
            ),
            child: Stack(
              children: [
                Text(
                  ui.title,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.black.withOpacity(0.14),
                    child: const Icon(Icons.pan_tool_alt_rounded, color: Colors.white, size: 26),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dzikirTabView() {
    const chips = ['Pagi', 'Petang', 'Setelah Sholat'];
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 100),
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) {
              final active = i == _dzikirTab;
              return ChoiceChip(
                label: Text(chips[i]),
                selected: active,
                onSelected: (_) {
                  setState(() => _dzikirTab = i);
                  _loadDzikir();
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                selectedColor: const Color(0xFFDCF1E8),
                backgroundColor: const Color(0xFFEFF2FA),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: chips.length,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Awali hari dengan dzikir, memohon keberkahan sepanjang hari',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2E3D38),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          color: const Color(0xFFDFF0E9),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: _loadingDzikir
              ? const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
              : Column(
                  children: _dzikirItems
                      .map((item) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF78B49D)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF3C9B78),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          color: const Color(0xFF2E7B61),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.subtitle,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          color: const Color(0xFF4A7364),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6F4ED),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFFC4E0D4)),
                                  ),
                                  child: Text(
                                    item.repeat,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF4F8D76),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
        ),
      ],
    );
  }
}

class _DoaCategoryUi {
  final String id;
  final String title;
  final Color color;
  const _DoaCategoryUi(this.id, this.title, this.color);
}

class _DzikirItem {
  final String title;
  final String subtitle;
  final String repeat;

  const _DzikirItem({required this.title, required this.subtitle, required this.repeat});

  factory _DzikirItem.fromJson(Map<String, dynamic> json) {
    return _DzikirItem(
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      repeat: (json['repeat'] ?? '').toString(),
    );
  }
}
