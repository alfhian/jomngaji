import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../../../models/doa.dart';
import '../../../routes/app_routes.dart';
import '../../home/widgets/app_bottom_nav.dart';
import '../data/doa_data.dart';

class DoaMenuPage extends StatefulWidget {
  const DoaMenuPage({super.key});

  @override
  State<DoaMenuPage> createState() => _DoaMenuPageState();
}

class _DoaMenuPageState extends State<DoaMenuPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _dzikirTab = 0;

  final List<_DoaCategory> _categories = const [
    _DoaCategory('Ramadan', Color(0xFF3E9A70)),
    _DoaCategory('Aktivitas', Color(0xFFF49A1F)),
    _DoaCategory('Bepergian', Color(0xFF3466D5)),
    _DoaCategory('Keselamatan', Color(0xFFF75555)),
    _DoaCategory('Kesulitan', Color(0xFFB87FA4)),
    _DoaCategory('Kondisi Khusus', Color(0xFF43C974)),
    _DoaCategory('Makan dan Minum', Color(0xFFEFB600)),
    _DoaCategory('Masjid', Color(0xFF1892DE)),
    _DoaCategory('Pengampunan', Color(0xFFE86AA4)),
    _DoaCategory('Penguatan Iman', Color(0xFF65B3BC)),
  ];

  final List<_DzikirItem> _dzikirItems = const [
    _DzikirItem(title: 'Ayat Kursi', subtitle: 'QS. Al-Baqarah ayat 255', repeat: 'Dibaca 1x'),
    _DzikirItem(title: 'Al-Ikhlas', subtitle: 'QS. Al-Ikhlas ayat 1-4', repeat: 'Dibaca 3x'),
    _DzikirItem(title: 'Al-Falaq', subtitle: 'QS. Al-Falaq ayat 1-5', repeat: 'Dibaca 3x'),
    _DzikirItem(title: 'An-Nas', subtitle: 'QS. An-Nas ayat 1-6', repeat: 'Dibaca 3x'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
            _topBar(),
            TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF3F9D7D),
              labelColor: const Color(0xFF3C8E73),
              unselectedLabelColor: AppColors.textSecondary,
              onTap: (_) => setState(() {}),
              tabs: const [
                Tab(text: 'Ikhtiar'),
                Tab(text: 'Doa'),
                Tab(text: 'Dzikir'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ikhtiarTab(),
                  _doaCategoriesTab(),
                  _dzikirTabView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Container(
      color: const Color(0xFF46A37F),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF437E62)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
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
          ),
          const SizedBox(width: 10),
          const Icon(Icons.star_rounded, color: Color(0xFFFEE034), size: 34),
        ],
      ),
    );
  }

  Widget _ikhtiarTab() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: doaList.length,
      itemBuilder: (context, index) {
        final doa = doaList[index];
        return _ikhtiarCard(doa, index);
      },
    );
  }

  Widget _ikhtiarCard(Doa doa, int index) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.doaDetail, arguments: doa),
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
              radius: 20,
              backgroundColor: const Color(0xFFE9F6F0),
              child: Text(
                '${index + 1}',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF3B906F),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                doa.title,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF84A79A)),
          ],
        ),
      ),
    );
  }

  Widget _doaCategoriesTab() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      itemCount: _categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.22,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, i) {
        final category = _categories[i];
        return InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.doaDetail, arguments: doaList.first),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: category.color,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(14),
            child: Stack(
              children: [
                Text(
                  category.title,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Positioned(
                  right: -8,
                  bottom: -8,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.black.withOpacity(0.12),
                    child: const Icon(Icons.pan_tool_alt_rounded, color: Colors.white, size: 32),
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
                onSelected: (_) => setState(() => _dzikirTab = i),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                selectedColor: const Color(0xFFDCF1E8),
                backgroundColor: const Color(0xFFEFF2FA),
                labelStyle: GoogleFonts.plusJakartaSans(
                  color: active ? const Color(0xFF3D8C70) : const Color(0xFF76818D),
                  fontWeight: FontWeight.w600,
                ),
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
          child: Column(
            children: List.generate(_dzikirItems.length, (i) {
              final item = _dzikirItems[i];
              return Container(
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
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _DoaCategory {
  final String title;
  final Color color;
  const _DoaCategory(this.title, this.color);
}

class _DzikirItem {
  final String title;
  final String subtitle;
  final String repeat;
  const _DzikirItem({required this.title, required this.subtitle, required this.repeat});
}
