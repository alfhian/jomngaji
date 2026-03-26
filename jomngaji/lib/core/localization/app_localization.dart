import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { ms, id, en }

class AppLanguageController extends ValueNotifier<AppLanguage> {
  AppLanguageController() : super(AppLanguage.ms);

  static const _prefsKey = 'app_language';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    value = AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.ms,
    );
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (value == language) return;
    value = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, language.code);
  }
}

class AppLocalization {
  AppLocalization(this.language);

  final AppLanguage language;

  static const Map<String, Map<AppLanguage, String>> _strings = {
    'app.title': {
      AppLanguage.ms: 'JomNgaji',
      AppLanguage.id: 'JomNgaji',
      AppLanguage.en: 'JomNgaji',
    },
    'nav.home': {
      AppLanguage.ms: 'Utama',
      AppLanguage.id: 'Beranda',
      AppLanguage.en: 'Home',
    },
    'nav.tadarus': {
      AppLanguage.ms: 'Tadarus',
      AppLanguage.id: 'Tadarus',
      AppLanguage.en: 'Tadarus',
    },
    'nav.doa': {
      AppLanguage.ms: 'Doa',
      AppLanguage.id: 'Doa',
      AppLanguage.en: 'Dua',
    },
    'nav.profile': {
      AppLanguage.ms: 'Profil',
      AppLanguage.id: 'Profil',
      AppLanguage.en: 'Profile',
    },
    'home.greeting': {
      AppLanguage.ms: 'Assalamu\'alaikum, {name}',
      AppLanguage.id: 'Assalamu\'alaikum, {name}',
      AppLanguage.en: 'Assalamu\'alaikum, {name}',
    },
    'home.subtitle': {
      AppLanguage.ms: 'Semoga ngaji hari ini berkat ✨',
      AppLanguage.id: 'Semoga ngaji hari ini berkah ✨',
      AppLanguage.en: 'May your recitation today be blessed ✨',
    },
    'home.findClass': {
      AppLanguage.ms: 'Temui kelas\nngaji kegemaranmu!',
      AppLanguage.id: 'Temukan kelas\nngaji favoritmu!',
      AppLanguage.en: 'Find your favorite\nQuran class!',
    },
    'home.learnTopics': {
      AppLanguage.ms: 'Belajar Iqra, Tajwid, dan Tilawah',
      AppLanguage.id: 'Belajar Iqra, Tajwid, dan Tilawah',
      AppLanguage.en: 'Learn Iqra, Tajwid, and Tilawah',
    },
    'home.categoryTitle': {
      AppLanguage.ms: 'Kategori Ngaji',
      AppLanguage.id: 'Kategori Ngaji',
      AppLanguage.en: 'Learning Categories',
    },
    'home.dailyQuizTitle': {
      AppLanguage.ms: 'Kuiz Harian',
      AppLanguage.id: 'Kuis Harian',
      AppLanguage.en: 'Daily Quiz',
    },
    'home.seeAll': {
      AppLanguage.ms: 'Lihat semua',
      AppLanguage.id: 'Lihat semua',
      AppLanguage.en: 'See all',
    },
    'category.iqra': {
      AppLanguage.ms: 'Iqra\' Asas',
      AppLanguage.id: 'Iqra\' Dasar',
      AppLanguage.en: 'Basic Iqra',
    },
    'category.tajwid': {
      AppLanguage.ms: 'Tajwid',
      AppLanguage.id: 'Tajwid',
      AppLanguage.en: 'Tajwid',
    },
    'category.tilawah': {
      AppLanguage.ms: 'Tilawah',
      AppLanguage.id: 'Tilawah',
      AppLanguage.en: 'Tilawah',
    },
    'category.tahfidz': {
      AppLanguage.ms: 'Tahfidz',
      AppLanguage.id: 'Tahfidz',
      AppLanguage.en: 'Tahfidz',
    },
    'profile.title': {
      AppLanguage.ms: 'Profil Pengguna',
      AppLanguage.id: 'Profil Pengguna',
      AppLanguage.en: 'User Profile',
    },
    'profile.avgProgress': {
      AppLanguage.ms: 'Purata kemajuan: {value}%',
      AppLanguage.id: 'Rata-rata progress: {value}%',
      AppLanguage.en: 'Average progress: {value}%',
    },
    'profile.latestExam': {
      AppLanguage.ms: 'Skor Ujian Terkini',
      AppLanguage.id: 'Skor Ujian Terbaru',
      AppLanguage.en: 'Latest Exam Scores',
    },
    'profile.learningProgress': {
      AppLanguage.ms: 'Kemajuan Pembelajaran',
      AppLanguage.id: 'Progress Pembelajaran',
      AppLanguage.en: 'Learning Progress',
    },
    'profile.resetPassword': {
      AppLanguage.ms: 'Tetapkan Semula Kata Laluan',
      AppLanguage.id: 'Reset Password',
      AppLanguage.en: 'Reset Password',
    },
    'profile.languageTitle': {
      AppLanguage.ms: 'Bahasa Aplikasi',
      AppLanguage.id: 'Bahasa Aplikasi',
      AppLanguage.en: 'App Language',
    },
    'profile.languageSubtitle': {
      AppLanguage.ms: 'Pilih bahasa untuk semua teks dalam aplikasi.',
      AppLanguage.id: 'Pilih bahasa untuk semua teks dalam aplikasi.',
      AppLanguage.en: 'Choose language for all app text.',
    },
    'profile.currentPlan': {
      AppLanguage.ms: 'Pelan Semasa',
      AppLanguage.id: 'Paket Saat Ini',
      AppLanguage.en: 'Current Plan',
    },
    'profile.planActivePro': {
      AppLanguage.ms: 'Akaun anda sudah aktif PRO. Urus pelan untuk perpanjang atau ubah.',
      AppLanguage.id: 'Akun kamu sudah aktif PRO. Kelola plan jika ingin perpanjang atau ubah.',
      AppLanguage.en: 'Your account is already PRO. Manage your plan to renew or change it.',
    },
    'profile.planFreePrompt': {
      AppLanguage.ms: 'Naik taraf ke PRO untuk membuka semua materi tanpa had.',
      AppLanguage.id: 'Upgrade ke PRO untuk membuka semua materi tanpa batas.',
      AppLanguage.en: 'Upgrade to PRO to unlock all learning content with no limits.',
    },
    'profile.managePlan': {
      AppLanguage.ms: 'Urus Pelan',
      AppLanguage.id: 'Kelola Plan',
      AppLanguage.en: 'Manage Plan',
    },
    'profile.updatePlan': {
      AppLanguage.ms: 'Kemaskini Pelan',
      AppLanguage.id: 'Update Plan',
      AppLanguage.en: 'Update Plan',
    },
    'profile.refreshTooltip': {
      AppLanguage.ms: 'Muat semula data profil',
      AppLanguage.id: 'Refresh data profile',
      AppLanguage.en: 'Refresh profile data',
    },
    'profile.logout': {
      AppLanguage.ms: 'Log Keluar',
      AppLanguage.id: 'Logout',
      AppLanguage.en: 'Logout',
    },
    'profile.logoutConfirmTitle': {
      AppLanguage.ms: 'Log Keluar',
      AppLanguage.id: 'Logout',
      AppLanguage.en: 'Logout',
    },
    'profile.logoutConfirmMessage': {
      AppLanguage.ms: 'Anda pasti mahu keluar daripada akaun ini?',
      AppLanguage.id: 'Yakin ingin keluar dari akun ini?',
      AppLanguage.en: 'Are you sure you want to log out from this account?',
    },
    'common.cancel': {
      AppLanguage.ms: 'Batal',
      AppLanguage.id: 'Batal',
      AppLanguage.en: 'Cancel',
    },
    'login.welcome': {
      AppLanguage.ms: 'Selamat datang 👋',
      AppLanguage.id: 'Selamat datang 👋',
      AppLanguage.en: 'Welcome 👋',
    },
    'login.subtitle': {
      AppLanguage.ms: 'Sila log masuk untuk teruskan belajar mengaji.',
      AppLanguage.id: 'Silakan login untuk melanjutkan belajar ngaji.',
      AppLanguage.en: 'Please log in to continue your Quran learning journey.',
    },
    'login.email': {
      AppLanguage.ms: 'E-mel',
      AppLanguage.id: 'Email',
      AppLanguage.en: 'Email',
    },
    'login.password': {
      AppLanguage.ms: 'Kata Laluan',
      AppLanguage.id: 'Password',
      AppLanguage.en: 'Password',
    },
    'login.button': {
      AppLanguage.ms: 'Log Masuk',
      AppLanguage.id: 'Login',
      AppLanguage.en: 'Login',
    },
    'login.googleButton': {
      AppLanguage.ms: 'Log Masuk dengan Google',
      AppLanguage.id: 'Login dengan Google',
      AppLanguage.en: 'Sign in with Google',
    },
    'login.noAccount': {
      AppLanguage.ms: 'Belum ada akaun? Daftar',
      AppLanguage.id: 'Belum punya akun? Register',
      AppLanguage.en: 'Don’t have an account? Register',
    },
    'register.title': {
      AppLanguage.ms: 'Cipta akaun baharu ✨',
      AppLanguage.id: 'Buat akun baru ✨',
      AppLanguage.en: 'Create a new account ✨',
    },
    'register.subtitle': {
      AppLanguage.ms: 'Isi maklumat di bawah untuk mula belajar bersama JomNgaji.',
      AppLanguage.id: 'Isi data di bawah untuk mulai belajar bersama JomNgaji.',
      AppLanguage.en: 'Fill in the details below to start learning with JomNgaji.',
    },
    'register.name': {
      AppLanguage.ms: 'Nama Penuh',
      AppLanguage.id: 'Nama Lengkap',
      AppLanguage.en: 'Full Name',
    },
    'register.button': {
      AppLanguage.ms: 'Daftar',
      AppLanguage.id: 'Register',
      AppLanguage.en: 'Register',
    },
    'register.haveAccount': {
      AppLanguage.ms: 'Sudah ada akaun? Log Masuk',
      AppLanguage.id: 'Sudah punya akun? Login',
      AppLanguage.en: 'Already have an account? Login',
    },
    'pro.upgradeTitle': {
      AppLanguage.ms: 'Naik taraf ke PRO',
      AppLanguage.id: 'Upgrade ke PRO',
      AppLanguage.en: 'Upgrade to PRO',
    },
    'pro.description': {
      AppLanguage.ms: '{feature} khas untuk ahli PRO.\nBuka semua materi PRO tanpa had.',
      AppLanguage.id: '{feature} khusus member PRO.\nBuka semua materi PRO tanpa batas.',
      AppLanguage.en: '{feature} is available for PRO members.\nUnlock all PRO learning content without limits.',
    },
    'pro.later': {
      AppLanguage.ms: 'Nanti',
      AppLanguage.id: 'Nanti',
      AppLanguage.en: 'Later',
    },
    'pro.viewPlan': {
      AppLanguage.ms: 'Lihat Pelan PRO',
      AppLanguage.id: 'Lihat Plan PRO',
      AppLanguage.en: 'View PRO Plan',
    },
    'pro.pageSoon': {
      AppLanguage.ms: 'Halaman PRO akan hadir tidak lama lagi ✨',
      AppLanguage.id: 'Halaman PRO akan segera hadir ✨',
      AppLanguage.en: 'PRO page is coming soon ✨',
    },
    'lang.ms': {
      AppLanguage.ms: 'Bahasa Malaysia',
      AppLanguage.id: 'Bahasa Malaysia',
      AppLanguage.en: 'Malay',
    },
    'lang.id': {
      AppLanguage.ms: 'Bahasa Indonesia',
      AppLanguage.id: 'Bahasa Indonesia',
      AppLanguage.en: 'Indonesian',
    },
    'lang.en': {
      AppLanguage.ms: 'Bahasa Inggeris',
      AppLanguage.id: 'Bahasa Inggris',
      AppLanguage.en: 'English',
    },
  };

  String text(String key, {Map<String, String> params = const {}}) {
    final values = _strings[key];
    var result = values?[language] ?? values?[AppLanguage.ms] ?? key;

    params.forEach((token, value) {
      result = result.replaceAll('{$token}', value);
    });

    return result;
  }
}

class AppLocalizationScope extends InheritedNotifier<AppLanguageController> {
  const AppLocalizationScope({
    super.key,
    required AppLanguageController controller,
    required Widget child,
  }) : super(notifier: controller, child: child);

  static AppLanguageController controllerOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLocalizationScope>();
    assert(scope != null, 'AppLocalizationScope not found in context');
    return scope!.notifier!;
  }

  static AppLocalization of(BuildContext context) {
    final controller = controllerOf(context);
    return AppLocalization(controller.value);
  }
}

extension AppLocalizationX on BuildContext {
  AppLocalization get l10n => AppLocalizationScope.of(this);
}

extension AppLanguageMeta on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.ms:
        return 'ms';
      case AppLanguage.id:
        return 'id';
      case AppLanguage.en:
        return 'en';
    }
  }

  String get key {
    switch (this) {
      case AppLanguage.ms:
        return 'lang.ms';
      case AppLanguage.id:
        return 'lang.id';
      case AppLanguage.en:
        return 'lang.en';
    }
  }
}
