-- Reset quiz Tilawah lama dan seed quiz level baru.
-- Jalankan di MySQL/MariaDB.

START TRANSACTION;

-- 1) Hapus data attempt lama untuk quiz tilawah (agar tidak orphan).
DELETE qa
FROM quiz_attempts qa
JOIN quizzes q ON q.id = qa.quiz_id
WHERE q.quiz_type = 'tilawah'
   OR q.quiz_code IN ('tilawah', 'tilawah_level_1', 'tilawah_level_2', 'tilawah_level_3');

-- 2) Hapus options lama untuk quiz tilawah.
DELETE qo
FROM quiz_options qo
JOIN quiz_questions qq ON qq.id = qo.question_id
JOIN quizzes q ON q.id = qq.quiz_id
WHERE q.quiz_type = 'tilawah'
   OR q.quiz_code IN ('tilawah', 'tilawah_level_1', 'tilawah_level_2', 'tilawah_level_3');

-- 3) Hapus question lama untuk quiz tilawah.
DELETE qq
FROM quiz_questions qq
JOIN quizzes q ON q.id = qq.quiz_id
WHERE q.quiz_type = 'tilawah'
   OR q.quiz_code IN ('tilawah', 'tilawah_level_1', 'tilawah_level_2', 'tilawah_level_3');

-- 4) Hapus row quiz tilawah lama.
DELETE FROM quizzes
WHERE quiz_type = 'tilawah'
   OR quiz_code IN ('tilawah', 'tilawah_level_1', 'tilawah_level_2', 'tilawah_level_3');

-- 5) Insert quiz level tilawah baru.
INSERT INTO quizzes (quiz_code, quiz_type, title, xp_per_correct, is_active, created_at)
VALUES
  ('tilawah_level_1', 'tilawah', 'Latihan Tilawah Level 1 (Pemula)', 10, 1, NOW()),
  ('tilawah_level_2', 'tilawah', 'Latihan Tilawah Level 2 (Menengah)', 10, 1, NOW()),
  ('tilawah_level_3', 'tilawah', 'Latihan Tilawah Level 3 (Mahir)', 10, 1, NOW());

-- =========================
-- LEVEL 1 (Pemula)
-- =========================
INSERT INTO quiz_questions (quiz_id, question_text, correct_answer)
SELECT q.id, t.question_text, t.correct_answer
FROM quizzes q
JOIN (
  SELECT 'Tilawah yang baik dibaca dengan ...' AS question_text, 'Tartil' AS correct_answer
  UNION ALL SELECT 'Saat memulai tilawah dari awal surat, disunnahkan membaca ...', 'Basmalah'
  UNION ALL SELECT 'Membaca terlalu cepat hingga makhraj tidak jelas adalah ...', 'Kurang tepat'
  UNION ALL SELECT 'Fokus utama level pemula tilawah adalah ...', 'Kelancaran dasar'
  UNION ALL SELECT 'Sikap yang dianjurkan saat tilawah adalah ...', 'Tenang dan khusyuk'
) t
WHERE q.quiz_code = 'tilawah_level_1';

INSERT INTO quiz_options (question_id, option_text)
SELECT qq.id, o.option_text
FROM quiz_questions qq
JOIN quizzes q ON q.id = qq.quiz_id
JOIN (
  SELECT 'Tilawah yang baik dibaca dengan ...' AS question_text, 'Tartil' AS option_text
  UNION ALL SELECT 'Tilawah yang baik dibaca dengan ...', 'Tergesa-gesa'
  UNION ALL SELECT 'Tilawah yang baik dibaca dengan ...', 'Tanpa aturan'

  UNION ALL SELECT 'Saat memulai tilawah dari awal surat, disunnahkan membaca ...', 'Basmalah'
  UNION ALL SELECT 'Saat memulai tilawah dari awal surat, disunnahkan membaca ...', 'Takbir'
  UNION ALL SELECT 'Saat memulai tilawah dari awal surat, disunnahkan membaca ...', 'Diam saja'

  UNION ALL SELECT 'Membaca terlalu cepat hingga makhraj tidak jelas adalah ...', 'Kurang tepat'
  UNION ALL SELECT 'Membaca terlalu cepat hingga makhraj tidak jelas adalah ...', 'Sudah benar'
  UNION ALL SELECT 'Membaca terlalu cepat hingga makhraj tidak jelas adalah ...', 'Lebih utama'

  UNION ALL SELECT 'Fokus utama level pemula tilawah adalah ...', 'Kelancaran dasar'
  UNION ALL SELECT 'Fokus utama level pemula tilawah adalah ...', 'Hafalan panjang'
  UNION ALL SELECT 'Fokus utama level pemula tilawah adalah ...', 'Kecepatan tinggi'

  UNION ALL SELECT 'Sikap yang dianjurkan saat tilawah adalah ...', 'Tenang dan khusyuk'
  UNION ALL SELECT 'Sikap yang dianjurkan saat tilawah adalah ...', 'Bercanda'
  UNION ALL SELECT 'Sikap yang dianjurkan saat tilawah adalah ...', 'Terlalu cepat'
) o ON o.question_text = qq.question_text
WHERE q.quiz_code = 'tilawah_level_1';

-- =========================
-- LEVEL 2 (Menengah)
-- =========================
INSERT INTO quiz_questions (quiz_id, question_text, correct_answer)
SELECT q.id, t.question_text, t.correct_answer
FROM quizzes q
JOIN (
  SELECT 'Di level menengah, tilawah mulai menekankan ...' AS question_text, 'Tajwid dan waqaf' AS correct_answer
  UNION ALL SELECT 'Berhenti pada akhir makna kalimat disebut ...', 'Waqaf yang tepat'
  UNION ALL SELECT 'Jika napas tidak cukup di tengah ayat, sebaiknya ...', 'Berhenti pada tempat yang aman'
  UNION ALL SELECT 'Menyambung bacaan tanpa memperhatikan tanda waqaf adalah ...', 'Kurang tepat'
  UNION ALL SELECT 'Target utama level menengah adalah ...', 'Stabil dalam tartil'
) t
WHERE q.quiz_code = 'tilawah_level_2';

INSERT INTO quiz_options (question_id, option_text)
SELECT qq.id, o.option_text
FROM quiz_questions qq
JOIN quizzes q ON q.id = qq.quiz_id
JOIN (
  SELECT 'Di level menengah, tilawah mulai menekankan ...' AS question_text, 'Tajwid dan waqaf' AS option_text
  UNION ALL SELECT 'Di level menengah, tilawah mulai menekankan ...', 'Kecepatan semata'
  UNION ALL SELECT 'Di level menengah, tilawah mulai menekankan ...', 'Volume tinggi'

  UNION ALL SELECT 'Berhenti pada akhir makna kalimat disebut ...', 'Waqaf yang tepat'
  UNION ALL SELECT 'Berhenti pada akhir makna kalimat disebut ...', 'Ibtida acak'
  UNION ALL SELECT 'Berhenti pada akhir makna kalimat disebut ...', 'Saktah wajib'

  UNION ALL SELECT 'Jika napas tidak cukup di tengah ayat, sebaiknya ...', 'Berhenti pada tempat yang aman'
  UNION ALL SELECT 'Jika napas tidak cukup di tengah ayat, sebaiknya ...', 'Dipaksakan terus'
  UNION ALL SELECT 'Jika napas tidak cukup di tengah ayat, sebaiknya ...', 'Langsung ulang dari awal surat'

  UNION ALL SELECT 'Menyambung bacaan tanpa memperhatikan tanda waqaf adalah ...', 'Kurang tepat'
  UNION ALL SELECT 'Menyambung bacaan tanpa memperhatikan tanda waqaf adalah ...', 'Sangat dianjurkan'
  UNION ALL SELECT 'Menyambung bacaan tanpa memperhatikan tanda waqaf adalah ...', 'Netral'

  UNION ALL SELECT 'Target utama level menengah adalah ...', 'Stabil dalam tartil'
  UNION ALL SELECT 'Target utama level menengah adalah ...', 'Mengejar tempo hadr saja'
  UNION ALL SELECT 'Target utama level menengah adalah ...', 'Menghafal tanpa tajwid'
) o ON o.question_text = qq.question_text
WHERE q.quiz_code = 'tilawah_level_2';

-- =========================
-- LEVEL 3 (Mahir)
-- =========================
INSERT INTO quiz_questions (quiz_id, question_text, correct_answer)
SELECT q.id, t.question_text, t.correct_answer
FROM quizzes q
JOIN (
  SELECT 'Ciri tilawah level mahir adalah ...' AS question_text, 'Lancar, tajwid tepat, dan irama terjaga' AS correct_answer
  UNION ALL SELECT 'Pada level mahir, evaluasi bacaan lebih fokus pada ...', 'Konsistensi keseluruhan bacaan'
  UNION ALL SELECT 'Jika terjadi salah makhraj kecil, langkah terbaik adalah ...', 'Perbaiki lalu lanjut dengan tenang'
  UNION ALL SELECT 'Mengabaikan adab tilawah meski bacaan bagus adalah ...', 'Tidak dianjurkan'
  UNION ALL SELECT 'Tujuan akhir level mahir tilawah adalah ...', 'Bacaan indah, benar, dan penuh penghayatan'
) t
WHERE q.quiz_code = 'tilawah_level_3';

INSERT INTO quiz_options (question_id, option_text)
SELECT qq.id, o.option_text
FROM quiz_questions qq
JOIN quizzes q ON q.id = qq.quiz_id
JOIN (
  SELECT 'Ciri tilawah level mahir adalah ...' AS question_text, 'Lancar, tajwid tepat, dan irama terjaga' AS option_text
  UNION ALL SELECT 'Ciri tilawah level mahir adalah ...', 'Cepat tanpa kontrol'
  UNION ALL SELECT 'Ciri tilawah level mahir adalah ...', 'Sekadar keras'

  UNION ALL SELECT 'Pada level mahir, evaluasi bacaan lebih fokus pada ...', 'Konsistensi keseluruhan bacaan'
  UNION ALL SELECT 'Pada level mahir, evaluasi bacaan lebih fokus pada ...', 'Satu huruf saja'
  UNION ALL SELECT 'Pada level mahir, evaluasi bacaan lebih fokus pada ...', 'Kecepatan semata'

  UNION ALL SELECT 'Jika terjadi salah makhraj kecil, langkah terbaik adalah ...', 'Perbaiki lalu lanjut dengan tenang'
  UNION ALL SELECT 'Jika terjadi salah makhraj kecil, langkah terbaik adalah ...', 'Berhenti total'
  UNION ALL SELECT 'Jika terjadi salah makhraj kecil, langkah terbaik adalah ...', 'Abaikan terus'

  UNION ALL SELECT 'Mengabaikan adab tilawah meski bacaan bagus adalah ...', 'Tidak dianjurkan'
  UNION ALL SELECT 'Mengabaikan adab tilawah meski bacaan bagus adalah ...', 'Tidak masalah'
  UNION ALL SELECT 'Mengabaikan adab tilawah meski bacaan bagus adalah ...', 'Lebih utama'

  UNION ALL SELECT 'Tujuan akhir level mahir tilawah adalah ...', 'Bacaan indah, benar, dan penuh penghayatan'
  UNION ALL SELECT 'Tujuan akhir level mahir tilawah adalah ...', 'Sekadar selesai cepat'
  UNION ALL SELECT 'Tujuan akhir level mahir tilawah adalah ...', 'Banyak jeda tak teratur'
) o ON o.question_text = qq.question_text
WHERE q.quiz_code = 'tilawah_level_3';

COMMIT;
