class Surah {
  final int number;
  final String name;       // alias latin
  final String arabic;
  final String? english;
  final String? indonesian;
  final int ayahCount;
  final String revelation;
  final List<Ayah> ayahs;
  final double progress;

  // getter alias untuk kompatibilitas
  String get latin => name;

  Surah({
    required this.number,
    required this.name,
    required this.arabic,
    this.english,
    this.indonesian,
    required this.ayahCount,
    required this.revelation,
    required this.ayahs,
    this.progress = 0.0,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json["number"],
      name: json["latin"] ?? json["name"] ?? "",
      arabic: json["arabic"] ?? json["ar"] ?? "",
      english: json["english"] ?? json["en"],
      indonesian: json["indonesian"] ?? json["id"],
      ayahCount: json["ayah_count"] ?? json["numberOfAyahs"] ?? 0,
      revelation: json["revelation"] ?? json["revelationType"] ?? "",
      ayahs: (json["ayahs"] as List? ?? [])
          .map((a) => Ayah.fromJson(a))
          .toList(),
      progress: (json["progress"] ?? 0.0).toDouble(),
    );
  }

  Surah copyWith({
    int? number,
    String? name,
    String? arabic,
    String? english,
    String? indonesian,
    int? ayahCount,
    String? revelation,
    List<Ayah>? ayahs,
    double? progress,
  }) {
    return Surah(
      number: number ?? this.number,
      name: name ?? this.name,
      arabic: arabic ?? this.arabic,
      english: english ?? this.english,
      indonesian: indonesian ?? this.indonesian,
      ayahCount: ayahCount ?? this.ayahCount,
      revelation: revelation ?? this.revelation,
      ayahs: ayahs ?? this.ayahs,
      progress: progress ?? this.progress,
    );
  }
}

class Ayah {
  final int surah;
  final int ayah;
  final String text;               // Arabic
  final String? transliteration;   // Latin transliteration
  final String? translation;       // Indonesian translation

  Ayah({
    required this.surah,
    required this.ayah,
    required this.text,
    this.transliteration,
    this.translation,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      surah: json["surah"] ?? 0,
      ayah: json["ayah"] ?? 0,
      text: json["text"] ?? json["arb"] ?? "",
      transliteration: json["transliteration"] ?? json["transliterasi"],
      translation: json["translation"] ?? json["ind"],
    );
  }
}
