-- Tambah field rata-rata nilai pengucapan untuk Exam Iqra
ALTER TABLE iqra_exam_results
ADD COLUMN pronunciation_avg_score DECIMAL(5,2) NULL
AFTER correct_answers;

-- (Opsional) jika ingin menyimpan jumlah soal pengucapan juga
ALTER TABLE iqra_exam_results
ADD COLUMN pronunciation_question_count INT NULL
AFTER pronunciation_avg_score;

-- (Opsional) backfill data lama jadi 0
UPDATE iqra_exam_results
SET pronunciation_avg_score = 0,
    pronunciation_question_count = 0
WHERE pronunciation_avg_score IS NULL
   OR pronunciation_question_count IS NULL;
