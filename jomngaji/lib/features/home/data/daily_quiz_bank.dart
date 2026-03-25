class DailyQuizItem {
  final String category;
  final String question;
  final List<String> options;
  final String answer;

  const DailyQuizItem({
    required this.category,
    required this.question,
    required this.options,
    required this.answer,
  });
}

const List<DailyQuizItem> dailyQuizBank = [
  DailyQuizItem(category: 'Iqra', question: 'Bacaan yang benar dari بَ adalah?', options: ['BA', 'BI', 'BU', 'BO'], answer: 'BA'),
  DailyQuizItem(category: 'Iqra', question: 'Huruf yang termasuk Syafawi adalah...', options: ['ف', 'ق', 'ج', 'ع'], answer: 'ف'),
  DailyQuizItem(category: 'Iqra', question: 'Bacaan yang benar dari فِي adalah...', options: ['FII', 'FAA', 'FUU', 'FI'], answer: 'FII'),
  DailyQuizItem(category: 'Iqra', question: 'Khaysyum berkaitan dengan...', options: ['Rongga hidung', 'Bibir', 'Lidah', 'Tenggorokan'], answer: 'Rongga hidung'),
  DailyQuizItem(category: 'Tajwid', question: 'Nun mati bertemu ب disebut...', options: ['Iqlab', 'Idgham', 'Izhar', 'Ikhfa'], answer: 'Iqlab'),
  DailyQuizItem(category: 'Tajwid', question: 'Mad Thabi’i dipanjangkan...', options: ['2 harakat', '4 harakat', '5 harakat', '6 harakat'], answer: '2 harakat'),
  DailyQuizItem(category: 'Tajwid', question: 'Qalqalah terjadi pada huruf...', options: ['ق ط ب ج د', 'ا و ي', 'م ن', 'س ش'], answer: 'ق ط ب ج د'),
  DailyQuizItem(category: 'Tajwid', question: 'Mim mati bertemu mim disebut...', options: ['Idgham Mimi', 'Izhar Syafawi', 'Ikhfa Syafawi', 'Iqlab'], answer: 'Idgham Mimi'),
  DailyQuizItem(category: 'Tilawah', question: 'Tujuan utama tilawah adalah...', options: ['Membaca tartil dan benar', 'Sekadar cepat selesai', 'Hanya menghafal', 'Hanya tajwid'], answer: 'Membaca tartil dan benar'),
  DailyQuizItem(category: 'Tilawah', question: 'Saat tilawah, yang dijaga adalah...', options: ['Makharijul huruf', 'Volume keras saja', 'Nada tinggi saja', 'Kecepatan'], answer: 'Makharijul huruf'),
  DailyQuizItem(category: 'Tilawah', question: 'Berhenti sejenak saat membaca disebut...', options: ['Waqaf', 'Wasal', 'Mad', 'Qasar'], answer: 'Waqaf'),
  DailyQuizItem(category: 'Tilawah', question: 'Bacaan tartil artinya...', options: ['Perlahan, jelas, teratur', 'Cepat dan tinggi', 'Pelan tanpa tajwid', 'Sama seperti hafalan'], answer: 'Perlahan, jelas, teratur'),
  DailyQuizItem(category: 'Tahfidz', question: 'Metode efektif tahfidz harian adalah...', options: ['Sedikit tapi konsisten', 'Banyak sekaligus', 'Hanya dengar audio', 'Tanpa murajaah'], answer: 'Sedikit tapi konsisten'),
  DailyQuizItem(category: 'Tahfidz', question: 'Murajaah berarti...', options: ['Mengulang hafalan', 'Mencari tafsir', 'Membaca terjemah', 'Mencatat ayat'], answer: 'Mengulang hafalan'),
  DailyQuizItem(category: 'Tahfidz', question: 'Waktu terbaik tahfidz biasanya...', options: ['Pagi setelah Subuh', 'Tengah malam saja', 'Sebelum tidur saja', 'Saat sibuk'], answer: 'Pagi setelah Subuh'),
  DailyQuizItem(category: 'Tahfidz', question: 'Agar hafalan kuat, lakukan...', options: ['Setor + murajaah rutin', 'Tambah halaman terus', 'Tanpa dengar guru', 'Lompat-lompat surat'], answer: 'Setor + murajaah rutin'),
];
