import '../models/surah.dart';

abstract class SurahRepository {
  List<Surah> getAll();

  Surah? findByNumber(int number);
}

class InMemorySurahRepository implements SurahRepository {
  InMemorySurahRepository();

  final List<Surah> _surah = List<Surah>.from(dummySurahList);

  @override
  List<Surah> getAll() => List<Surah>.unmodifiable(_surah);

  @override
  Surah? findByNumber(int number) {
    for (final surah in _surah) {
      if (surah.number == number) {
        return surah;
      }
    }
    return null;
  }
}
