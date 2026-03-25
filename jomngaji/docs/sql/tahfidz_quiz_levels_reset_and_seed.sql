-- Reset quiz Tahfidz lama dan seed quiz level baru.
-- Jalankan di MySQL/MariaDB.

START TRANSACTION;

-- 1) Hapus data attempt lama untuk quiz tahfidz (agar tidak orphan).
DELETE qa
FROM quiz_attempts qa
JOIN quizzes q ON q.id = qa.quiz_id
WHERE q.quiz_type = 'tahfidz'
   OR q.quiz_code IN ('tahfidz', 'tahfidz_level_1', 'tahfidz_level_2', 'tahfidz_level_3');

-- 2) Hapus options lama untuk quiz tahfidz.
DELETE qo
FROM quiz_options qo
JOIN quiz_questions qq ON qq.id = qo.question_id
JOIN quizzes q ON q.id = qq.quiz_id
WHERE q.quiz_type = 'tahfidz'
   OR q.quiz_code IN ('tahfidz', 'tahfidz_level_1', 'tahfidz_level_2', 'tahfidz_level_3');

-- 3) Hapus question lama untuk quiz tahfidz.
DELETE qq
FROM quiz_questions qq
JOIN quizzes q ON q.id = qq.quiz_id
WHERE q.quiz_type = 'tahfidz'
   OR q.quiz_code IN ('tahfidz', 'tahfidz_level_1', 'tahfidz_level_2', 'tahfidz_level_3');

-- 4) Hapus row quiz tahfidz lama.
DELETE FROM quizzes
WHERE quiz_type = 'tahfidz'
   OR quiz_code IN ('tahfidz', 'tahfidz_level_1', 'tahfidz_level_2', 'tahfidz_level_3');

-- 5) Insert quiz level tahfidz baru.
INSERT INTO quizzes (quiz_code, quiz_type, title, xp_per_correct, is_active, created_at)
VALUES
  ('tahfidz_level_1', 'tahfidz', 'Latihan Tahfidz Level 1 (Pemula)', 10, 1, NOW()),
  ('tahfidz_level_2', 'tahfidz', 'Latihan Tahfidz Level 2 (Menengah)', 10, 1, NOW()),
  ('tahfidz_level_3', 'tahfidz', 'Latihan Tahfidz Level 3 (Mahir)', 10, 1, NOW());

-- =========================
-- LEVEL 1 (Pemula)
-- =========================
INSERT INTO quiz_questions (quiz_id, question_text, correct_answer)
SELECT q.id, t.question_text, t.correct_answer
FROM quizzes q
JOIN (
  SELECT 'Tahfidz yang baik dimulai dengan target ...' AS question_text, 'Sedikit tapi konsisten' AS correct_answer
  UNION ALL SELECT 'Aktivitas mengulang hafalan lama disebut ...', 'Muraja''ah'
  UNION ALL SELECT 'Untuk pemula, pilihan terbaik adalah menghafal ...', 'Surat pendek terlebih dahulu'
  UNION ALL SELECT 'Waktu yang sering dianjurkan untuk tahfidz adalah ...', 'Setelah Subuh'
  UNION ALL SELECT 'Agar hafalan kuat, setelah setoran sebaiknya ...', 'Diulang kembali beberapa kali'
) t
WHERE q.quiz_code = 'tahfidz_level_1';

INSERT INTO quiz_options (question_id, option_text)
SELECT qq.id, o.option_text
FROM quiz_questions qq
JOIN quizzes q ON q.id = qq.quiz_id
JOIN (
  SELECT 'Tahfidz yang baik dimulai dengan target ...' AS question_text, 'Sedikit tapi konsisten' AS option_text
  UNION ALL SELECT 'Tahfidz yang baik dimulai dengan target ...', 'Banyak sekaligus'
  UNION ALL SELECT 'Tahfidz yang baik dimulai dengan target ...', 'Acak setiap hari'

  UNION ALL SELECT 'Aktivitas mengulang hafalan lama disebut ...', 'Muraja''ah'
  UNION ALL SELECT 'Aktivitas mengulang hafalan lama disebut ...', 'Tilawah cepat'
  UNION ALL SELECT 'Aktivitas mengulang hafalan lama disebut ...', 'Tafsir harian'

  UNION ALL SELECT 'Untuk pemula, pilihan terbaik adalah menghafal ...', 'Surat pendek terlebih dahulu'
  UNION ALL SELECT 'Untuk pemula, pilihan terbaik adalah menghafal ...', 'Ayat terpanjang dulu'
  UNION ALL SELECT 'Untuk pemula, pilihan terbaik adalah menghafal ...', 'Langsung satu juz'

  UNION ALL SELECT 'Waktu yang sering dianjurkan untuk tahfidz adalah ...', 'Setelah Subuh'
  UNION ALL SELECT 'Waktu yang sering dianjurkan untuk tahfidz adalah ...', 'Saat sangat lelah'
  UNION ALL SELECT 'Waktu yang sering dianjurkan untuk tahfidz adalah ...', 'Sesuka hati tanpa jadwal'

  UNION ALL SELECT 'Agar hafalan kuat, setelah setoran sebaiknya ...', 'Diulang kembali beberapa kali'
  UNION ALL SELECT 'Agar hafalan kuat, setelah setoran sebaiknya ...', 'Langsung pindah surat'
  UNION ALL SELECT 'Agar hafalan kuat, setelah setoran sebaiknya ...', 'Tidak perlu muraja''ah'
) o ON o.question_text = qq.question_text
WHERE q.quiz_code = 'tahfidz_level_1';

-- =========================
-- LEVEL 2 (Menengah)
-- =========================
INSERT INTO quiz_questions (quiz_id, question_text, correct_answer)
SELECT q.id, t.question_text, t.correct_answer
FROM quizzes q
JOIN (
  SELECT 'Di level menengah, fokus tahfidz bertambah pada ...' AS question_text, 'Sambungan antar ayat' AS correct_answer
  UNION ALL SELECT 'Jika lupa di tengah ayat, langkah terbaik adalah ...', 'Berhenti sebentar lalu lanjut dengan tenang'
  UNION ALL SELECT 'Agar sambungan ayat lancar, metode efektif adalah ...', 'Menghafal per blok ayat'
  UNION ALL SELECT 'Muraja''ah menengah idealnya dilakukan ...', 'Harian dengan porsi terukur'
  UNION ALL SELECT 'Setoran menengah yang baik menekankan ...', 'Ketepatan urutan dan kelancaran'
) t
WHERE q.quiz_code = 'tahfidz_level_2';

INSERT INTO quiz_options (question_id, option_text)
SELECT qq.id, o.option_text
FROM quiz_questions qq
JOIN quizzes q ON q.id = qq.quiz_id
JOIN (
  SELECT 'Di level menengah, fokus tahfidz bertambah pada ...' AS question_text, 'Sambungan antar ayat' AS option_text
  UNION ALL SELECT 'Di level menengah, fokus tahfidz bertambah pada ...', 'Kecepatan semata'
  UNION ALL SELECT 'Di level menengah, fokus tahfidz bertambah pada ...', 'Volume suara'

  UNION ALL SELECT 'Jika lupa di tengah ayat, langkah terbaik adalah ...', 'Berhenti sebentar lalu lanjut dengan tenang'
  UNION ALL SELECT 'Jika lupa di tengah ayat, langkah terbaik adalah ...', 'Memaksa terus meski salah'
  UNION ALL SELECT 'Jika lupa di tengah ayat, langkah terbaik adalah ...', 'Meninggalkan hafalan hari itu'

  UNION ALL SELECT 'Agar sambungan ayat lancar, metode efektif adalah ...', 'Menghafal per blok ayat'
  UNION ALL SELECT 'Agar sambungan ayat lancar, metode efektif adalah ...', 'Lompat-lompat ayat'
  UNION ALL SELECT 'Agar sambungan ayat lancar, metode efektif adalah ...', 'Hanya mendengar tanpa mengulang'

  UNION ALL SELECT 'Muraja''ah menengah idealnya dilakukan ...', 'Harian dengan porsi terukur'
  UNION ALL SELECT 'Muraja''ah menengah idealnya dilakukan ...', 'Seminggu sekali saja'
  UNION ALL SELECT 'Muraja''ah menengah idealnya dilakukan ...', 'Saat ujian saja'

  UNION ALL SELECT 'Setoran menengah yang baik menekankan ...', 'Ketepatan urutan dan kelancaran'
  UNION ALL SELECT 'Setoran menengah yang baik menekankan ...', 'Bacaan cepat tanpa kontrol'
  UNION ALL SELECT 'Setoran menengah yang baik menekankan ...', 'Jumlah halaman saja'
) o ON o.question_text = qq.question_text
WHERE q.quiz_code = 'tahfidz_level_2';

-- =========================
-- LEVEL 3 (Mahir)
-- =========================
INSERT INTO quiz_questions (quiz_id, question_text, correct_answer)
SELECT q.id, t.question_text, t.correct_answer
FROM quizzes q
JOIN (
  SELECT 'Ciri tahfidz level mahir adalah ...' AS question_text, 'Hafalan stabil, lancar, dan siap disetor' AS correct_answer
  UNION ALL SELECT 'Saat hafalan panjang, strategi napas yang tepat adalah ...', 'Membagi ayat sesuai titik waqaf'
  UNION ALL SELECT 'Jika ada kesalahan kecil saat setoran, sebaiknya ...', 'Perbaiki segera lalu lanjutkan'
  UNION ALL SELECT 'Pada level mahir, muraja''ah bertujuan untuk ...', 'Menjaga kualitas hafalan jangka panjang'
  UNION ALL SELECT 'Adab penting saat setoran hafalan adalah ...', 'Tenang, fokus, dan rendah hati'
) t
WHERE q.quiz_code = 'tahfidz_level_3';

INSERT INTO quiz_options (question_id, option_text)
SELECT qq.id, o.option_text
FROM quiz_questions qq
JOIN quizzes q ON q.id = qq.quiz_id
JOIN (
  SELECT 'Ciri tahfidz level mahir adalah ...' AS question_text, 'Hafalan stabil, lancar, dan siap disetor' AS option_text
  UNION ALL SELECT 'Ciri tahfidz level mahir adalah ...', 'Banyak hafalan tapi sering lupa'
  UNION ALL SELECT 'Ciri tahfidz level mahir adalah ...', 'Cepat namun tidak tepat'

  UNION ALL SELECT 'Saat hafalan panjang, strategi napas yang tepat adalah ...', 'Membagi ayat sesuai titik waqaf'
  UNION ALL SELECT 'Saat hafalan panjang, strategi napas yang tepat adalah ...', 'Menahan napas terus'
  UNION ALL SELECT 'Saat hafalan panjang, strategi napas yang tepat adalah ...', 'Berhenti acak tanpa aturan'

  UNION ALL SELECT 'Jika ada kesalahan kecil saat setoran, sebaiknya ...', 'Perbaiki segera lalu lanjutkan'
  UNION ALL SELECT 'Jika ada kesalahan kecil saat setoran, sebaiknya ...', 'Diabaikan saja'
  UNION ALL SELECT 'Jika ada kesalahan kecil saat setoran, sebaiknya ...', 'Langsung berhenti total'

  UNION ALL SELECT 'Pada level mahir, muraja''ah bertujuan untuk ...', 'Menjaga kualitas hafalan jangka panjang'
  UNION ALL SELECT 'Pada level mahir, muraja''ah bertujuan untuk ...', 'Menambah cepat tanpa review'
  UNION ALL SELECT 'Pada level mahir, muraja''ah bertujuan untuk ...', 'Sekadar formalitas'

  UNION ALL SELECT 'Adab penting saat setoran hafalan adalah ...', 'Tenang, fokus, dan rendah hati'
  UNION ALL SELECT 'Adab penting saat setoran hafalan adalah ...', 'Tergesa-gesa'
  UNION ALL SELECT 'Adab penting saat setoran hafalan adalah ...', 'Meninggikan suara berlebihan'
) o ON o.question_text = qq.question_text
WHERE q.quiz_code = 'tahfidz_level_3';

COMMIT;
