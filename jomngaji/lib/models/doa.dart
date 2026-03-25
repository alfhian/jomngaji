class Doa {
  final String id;
  final String title;
  final String arab;
  final String latin;
  final String arti;
  final String? audioUrl;

  Doa({
    required this.id,
    required this.title,
    required this.arab,
    required this.latin,
    required this.arti,
    this.audioUrl,
  });
}
