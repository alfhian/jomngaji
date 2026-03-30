import '../../../models/doa.dart';
import 'doa_data.dart';

class DoaCategory {
  final String id;
  final String title;
  final List<String> doaIds;

  const DoaCategory({
    required this.id,
    required this.title,
    required this.doaIds,
  });
}

class IkhtiarItem {
  final String id;
  final String title;
  final String description;
  final List<String> steps;

  const IkhtiarItem({
    required this.id,
    required this.title,
    required this.description,
    required this.steps,
  });
}

class DoaCatalog {
  static final Map<String, Doa> _byId = {for (final item in doaList) item.id: item};

  static const List<DoaCategory> categories = [
    DoaCategory(
      id: 'aktivitas',
      title: 'Aktivitas',
      doaIds: [
        'doa_sebelum_makan',
        'doa_sesudah_makan',
        'doa_sebelum_tidur',
        'doa_bangun_tidur',
        'doa_sebelum_belajar',
        'doa_sesudah_belajar',
      ],
    ),
    DoaCategory(
      id: 'bepergian',
      title: 'Bepergian',
      doaIds: ['doa_keluar_rumah', 'doa_naik_kendaraan', 'doa_sampai_tujuan', 'doa_safar'],
    ),
    DoaCategory(
      id: 'keselamatan',
      title: 'Keselamatan',
      doaIds: ['doa_ketika_hujan', 'doa_setelah_hujan', 'doa_saat_angin_kencang', 'doa_saat_petir'],
    ),
    DoaCategory(
      id: 'masjid',
      title: 'Masjid',
      doaIds: ['doa_masuk_masjid', 'doa_keluar_masjid'],
    ),
    DoaCategory(
      id: 'pengampunan',
      title: 'Pengampunan',
      doaIds: ['doa_mohon_ampunan', 'sayyidul_istighfar', 'doa_taubat_nabi_adam'],
    ),
    DoaCategory(
      id: 'ramadan',
      title: 'Ramadan',
      doaIds: ['doa_berbuka_puasa', 'doa_qunut'],
    ),
  ];

  static const List<IkhtiarItem> ikhtiar = [
    IkhtiarItem(
      id: 'zikir_pagi',
      title: 'Dzikir Pagi 5 Menit',
      description: 'Awali hari dengan dzikir ringkas dan niatkan untuk menjaga lisan sepanjang hari.',
      steps: ['Baca istighfar 33x', 'Baca shalawat 10x', 'Baca doa perlindungan pagi'],
    ),
    IkhtiarItem(
      id: 'sedekah_harian',
      title: 'Sedekah Harian',
      description: 'Sisihkan sebagian rezeki untuk sedekah, walau kecil, agar hati lebih lapang.',
      steps: ['Tentukan nominal', 'Salurkan ke yang membutuhkan', 'Doakan penerima sedekah'],
    ),
    IkhtiarItem(
      id: 'tilawah_1_halaman',
      title: 'Tilawah 1 Halaman',
      description: 'Menjaga konsistensi tilawah harian walaupun sedikit.',
      steps: ['Tentukan waktu baca', 'Baca tartil', 'Tandai progres setelah selesai'],
    ),
  ];

  static List<Doa> byCategory(DoaCategory category) {
    return category.doaIds.map((id) => _byId[id]).whereType<Doa>().toList();
  }
}

class FavoriteDoaStore {
  static final Set<String> _favorites = <String>{};

  static bool isFavorite(String doaId) => _favorites.contains(doaId);

  static void toggle(String doaId) {
    if (!_favorites.remove(doaId)) {
      _favorites.add(doaId);
    }
  }

  static List<Doa> favorites() {
    return doaList.where((item) => _favorites.contains(item.id)).toList();
  }
}

class IkhtiarDoneStore {
  static final Set<String> _doneIds = <String>{};

  static bool isDone(String ikhtiarId) => _doneIds.contains(ikhtiarId);

  static void toggleDone(String ikhtiarId) {
    if (!_doneIds.remove(ikhtiarId)) {
      _doneIds.add(ikhtiarId);
    }
  }
}
