import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  // -----------------------------
  // KONSTAN
  // -----------------------------
  static const int maxLessons = 14;
  static const int passingScore = 50;

  // -----------------------------
  // SCORE / XP
  // -----------------------------
  static Future<void> saveExamScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("exam_score", score);
  }

  static Future<int> getExamScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("exam_score") ?? 0;
  }

  static Future<void> saveXP(int xp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("xp", xp);
  }

  static Future<int> getXP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("xp") ?? 0;
  }

  // -----------------------------
  // SISTEM LEVEL (PER PELAJARAN)
  // -----------------------------
  static String _lessonScoreKey(int lessonId) => "lesson_${lessonId}_score";
  static String _lessonUnlockedKey(int lessonId) => "lesson_${lessonId}_unlocked";

  /// Lesson 1 ALWAYS unlocked
  static Future<bool> isLessonUnlocked(int lessonId) async {
    if (lessonId == 1) return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_lessonUnlockedKey(lessonId)) ?? false;
  }

  static Future<double> getLessonScore(int lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_lessonScoreKey(lessonId)) ?? 0.0;
  }

  static Future<void> saveLessonScore(int lessonId, double score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lessonScoreKey(lessonId), score);

    // Auto unlock next lesson
    if (score >= passingScore && lessonId < maxLessons) {
      await prefs.setBool(_lessonUnlockedKey(lessonId + 1), true);
    }
  }

  static Future<void> resetAllLessons() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 1; i <= maxLessons; i++) {
      await prefs.remove(_lessonScoreKey(i));
      await prefs.remove(_lessonUnlockedKey(i));
    }
  }

  // -----------------------------
  // TADARUS PROGRESS (NEW)
  // -----------------------------
  static Future<void> saveTadarusProgress({
    required String surah,
    required int ayat,
    required double progress,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("tadarus_surah", surah);
    await prefs.setInt("tadarus_ayat", ayat);
    await prefs.setDouble("tadarus_progress", progress);
  }

  static Future<Map<String, dynamic>?> getTadarusProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final surah = prefs.getString("tadarus_surah");
    final ayat = prefs.getInt("tadarus_ayat");
    final progress = prefs.getDouble("tadarus_progress");
    if (surah == null || ayat == null || progress == null) return null;
    return {
      "surah": surah,
      "ayat": ayat,
      "progress": progress,
    };
  }

  // -----------------------------
  // GOALS KHATAM (NEW)
  // -----------------------------
  static Future<void> saveTadarusGoal(int months) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("tadarus_goal_months", months);
  }

  static Future<int> getTadarusGoalMonths() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("tadarus_goal_months") ?? 6; // default 6 bulan
  }

  static int calculateDailyTarget(int monthsGoal, {int totalAyat = 6236}) {
    return (totalAyat / (monthsGoal * 30)).ceil();
  }

  // -----------------------------
  // RESET TADARUS
  // -----------------------------
  static Future<void> resetTadarus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("tadarus_surah");
    await prefs.remove("tadarus_ayat");
    await prefs.remove("tadarus_progress");
    await prefs.remove("tadarus_goal_months");
  }
}
