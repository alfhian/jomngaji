class Surah {
  final int number;
  final String name;
  final int ayatCount;

  // const constructor agar bisa dipakai di const lists
  const Surah({
    required this.number,
    required this.name,
    required this.ayatCount,
  });
}

final List<Surah> dummySurahList = [
  Surah(number: 1, name: 'Al-Fatihah', ayatCount: 7),
  Surah(number: 2, name: 'Al-Baqarah', ayatCount: 286),
  Surah(number: 3, name: 'Ali Imran', ayatCount: 200),
  Surah(number: 4, name: 'An-Nisa', ayatCount: 176),
  Surah(number: 5, name: 'Al-Maidah', ayatCount: 120),
];
