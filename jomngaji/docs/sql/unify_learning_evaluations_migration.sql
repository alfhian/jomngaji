-- ============================================================
-- Migration: Unify learning evaluation & assessment attempt tables
-- DB       : MySQL / MariaDB
-- Date     : 2026-03-29
-- ============================================================
-- This script has two tracks:
-- 1) Evaluation unification (hijaiyah/tajwid/tilawah/tahfidz/tadarus -> learning_evaluations)
-- 2) Attempt/result unification (quiz_attempts + *_exam_results + suku_kata_progress -> learning_assessment_attempts)
--
-- IMPORTANT:
-- - Run each section explicitly (UP or DOWN), do not run whole file at once.
-- - If your DB is large, wrap each section in your own deployment transaction strategy.

-- ============================================================
-- ============================ UP ============================
-- ============================================================

-- ------------------------------------------------------------
-- [UP-1] Create unified evaluation table
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `learning_evaluations` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `feature_type` ENUM('iqra','tajwid','tilawah','tahfidz','tadarus') NOT NULL,
  `lesson_id` BIGINT UNSIGNED DEFAULT NULL,
  `surah` INT DEFAULT NULL,
  `ayah` INT DEFAULT NULL,
  `transcript` TEXT DEFAULT NULL,
  `score_final` INT DEFAULT NULL,
  `score_audio` INT DEFAULT NULL,
  `score_ayat` INT DEFAULT NULL,
  `feedback` TEXT DEFAULT NULL,
  `asr_user` TEXT DEFAULT NULL,
  `asr_ref` TEXT DEFAULT NULL,
  `issues` JSON DEFAULT NULL,
  `suggestions` JSON DEFAULT NULL,
  `evaluated_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_learning_eval_user_feature` (`user_id`,`feature_type`),
  KEY `idx_learning_eval_user_feature_lesson` (`user_id`,`feature_type`,`lesson_id`),
  KEY `idx_learning_eval_user_feature_surah_ayah` (`user_id`,`feature_type`,`surah`,`ayah`),
  KEY `idx_learning_eval_user_feature_score` (`user_id`,`feature_type`,`score_final`),
  UNIQUE KEY `uniq_learning_eval_tadarus` (`user_id`,`feature_type`,`surah`,`ayah`,`lesson_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- ------------------------------------------------------------
-- [UP-2] Backfill learning_evaluations from legacy evaluation tables
-- ------------------------------------------------------------
INSERT INTO `learning_evaluations`
(`user_id`,`feature_type`,`lesson_id`,`transcript`,`score_final`,`score_audio`,`score_ayat`,`feedback`,`issues`,`evaluated_at`,`updated_at`)
SELECT
  CAST(`user_id` AS UNSIGNED), 'tajwid', CAST(`lesson_id` AS UNSIGNED), `transcript`, `score_final`, `score_audio`, `score_ayat`, `feedback`, `issues`, `evaluated_at`, `updated_at`
FROM `tajwid_evaluations`;

INSERT INTO `learning_evaluations`
(`user_id`,`feature_type`,`lesson_id`,`transcript`,`score_final`,`score_audio`,`score_ayat`,`feedback`,`issues`,`evaluated_at`,`updated_at`)
SELECT
  CAST(`user_id` AS UNSIGNED), 'tilawah', CAST(`lesson_id` AS UNSIGNED), `transcript`, `score_final`, `score_audio`, `score_ayat`, `feedback`, `issues`, `evaluated_at`, `updated_at`
FROM `tilawah_evaluations`;

INSERT INTO `learning_evaluations`
(`user_id`,`feature_type`,`lesson_id`,`transcript`,`score_final`,`score_audio`,`score_ayat`,`feedback`,`issues`,`evaluated_at`,`updated_at`)
SELECT
  CAST(`user_id` AS UNSIGNED), 'tahfidz', CAST(`lesson_id` AS UNSIGNED), `transcript`, `score_final`, `score_audio`, `score_ayat`, `feedback`, `issues`, `evaluated_at`, `updated_at`
FROM `tahfidz_evaluations`;

INSERT INTO `learning_evaluations`
(`user_id`,`feature_type`,`surah`,`ayah`,`score_final`,`score_audio`,`score_ayat`,`asr_user`,`asr_ref`,`issues`,`suggestions`,`evaluated_at`,`updated_at`)
SELECT
  CAST(`user_id` AS UNSIGNED), 'tadarus', `surah`, `ayah`, `score_final`, `score_audio`, `score_ayat`, `asr_user`, `asr_ref`, `issues`, `suggestions`, `evaluated_at`, `updated_at`
FROM `tadarus_evaluations`;

INSERT INTO `learning_evaluations`
(`user_id`,`feature_type`,`lesson_id`,`transcript`,`score_final`,`score_audio`,`score_ayat`,`feedback`,`issues`,`asr_ref`,`evaluated_at`,`updated_at`)
SELECT
  CAST(`user_id` AS UNSIGNED), 'iqra', CAST(`lesson_id` AS UNSIGNED), `transcript`, `score_final`, `score_audio`, `score_ayat`, `feedback`, `issues`, `hijaiyah`, `evaluated_at`, `updated_at`
FROM `hijaiyah_evaluations`;

-- ------------------------------------------------------------
-- [UP-3] (Optional) Create unified attempt/result table
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `learning_assessment_attempts` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `feature_type` ENUM('iqra','tajwid','tilawah','tahfidz','tadarus','general') NOT NULL,
  `assessment_kind` ENUM('quiz','exam') NOT NULL,
  `quiz_id` BIGINT UNSIGNED DEFAULT NULL,
  `quiz_code` VARCHAR(100) DEFAULT NULL,
  `total_questions` INT DEFAULT NULL,
  `correct_answers` INT DEFAULT NULL,
  `score` DECIMAL(7,2) DEFAULT NULL,
  `final_score` DECIMAL(7,2) DEFAULT NULL,
  `pronunciation_avg_score` DECIMAL(7,2) DEFAULT NULL,
  `pronunciation_question_count` INT DEFAULT NULL,
  `xp_earned` INT DEFAULT 0,
  `started_at` DATETIME DEFAULT NULL,
  `finished_at` DATETIME DEFAULT NULL,
  `attempted_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_learning_assessment_user_feature_kind` (`user_id`,`feature_type`,`assessment_kind`),
  KEY `idx_learning_assessment_quiz` (`quiz_id`,`quiz_code`),
  KEY `idx_learning_assessment_score` (`user_id`,`final_score`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Quiz attempts backfill
INSERT INTO `learning_assessment_attempts`
(`user_id`,`feature_type`,`assessment_kind`,`quiz_id`,`quiz_code`,`total_questions`,`correct_answers`,`score`,`final_score`,`xp_earned`,`attempted_at`,`created_at`)
SELECT
  CAST(qa.`user_id` AS UNSIGNED),
  CASE
    WHEN q.`quiz_type` IN ('tajwid','tilawah','tahfidz','iqra','tadarus') THEN q.`quiz_type`
    ELSE 'general'
  END AS `feature_type`,
  'quiz' AS `assessment_kind`,
  CAST(qa.`quiz_id` AS UNSIGNED),
  q.`quiz_code`,
  qa.`total`,
  qa.`correct`,
  qa.`score`,
  qa.`score`,
  COALESCE(qa.`xp`, 0),
  qa.`created_at`,
  qa.`created_at`
FROM `quiz_attempts` qa
LEFT JOIN `quizzes` q ON q.`id` = qa.`quiz_id`;

-- Suku kata progress backfill as quiz attempts
INSERT INTO `learning_assessment_attempts`
(`user_id`,`feature_type`,`assessment_kind`,`quiz_id`,`quiz_code`,`total_questions`,`correct_answers`,`score`,`final_score`,`xp_earned`,`attempted_at`,`created_at`)
SELECT
  CAST(sp.`user_id` AS UNSIGNED),
  'iqra',
  'quiz',
  q.`id`,
  CONCAT('suku_kata_level_', sp.`level_id`),
  sp.`completed_questions`,
  sp.`completed_questions`,
  sp.`average_score`,
  sp.`average_score`,
  0,
  NOW(),
  NOW()
FROM `suku_kata_progress` sp
LEFT JOIN `quizzes` q ON q.`quiz_code` = CONCAT('suku_kata_level_', sp.`level_id`);

-- Exam result backfill: IQRA
INSERT INTO `learning_assessment_attempts`
(`user_id`,`feature_type`,`assessment_kind`,`total_questions`,`correct_answers`,`score`,`final_score`,`pronunciation_avg_score`,`pronunciation_question_count`,`xp_earned`,`started_at`,`finished_at`,`attempted_at`,`created_at`)
SELECT
  `user_id`, 'iqra', 'exam', `total_questions`, `correct_answers`, `score`, `final_score`, `pronunciation_avg_score`, `pronunciation_question_count`, COALESCE(`xp_earned`,0), `started_at`, `finished_at`, COALESCE(`finished_at`,`created_at`), `created_at`
FROM `iqra_exam_results`;

-- Exam result backfill: TAJWID
INSERT INTO `learning_assessment_attempts`
(`user_id`,`feature_type`,`assessment_kind`,`total_questions`,`correct_answers`,`score`,`final_score`,`pronunciation_avg_score`,`pronunciation_question_count`,`xp_earned`,`started_at`,`finished_at`,`attempted_at`,`created_at`)
SELECT
  `user_id`, 'tajwid', 'exam', `total_questions`, `correct_answers`, `score`, `final_score`, `pronunciation_avg_score`, `pronunciation_question_count`, COALESCE(`xp_earned`,0), `started_at`, `finished_at`, COALESCE(`finished_at`,`created_at`), `created_at`
FROM `tajwid_exam_results`;

-- Exam result backfill: TILAWAH
INSERT INTO `learning_assessment_attempts`
(`user_id`,`feature_type`,`assessment_kind`,`total_questions`,`correct_answers`,`score`,`final_score`,`pronunciation_avg_score`,`pronunciation_question_count`,`xp_earned`,`started_at`,`finished_at`,`attempted_at`,`created_at`)
SELECT
  `user_id`, 'tilawah', 'exam', `total_questions`, `correct_answers`, `score`, `final_score`, `pronunciation_avg_score`, `pronunciation_question_count`, COALESCE(`xp_earned`,0), `started_at`, `finished_at`, COALESCE(`finished_at`,`created_at`), `created_at`
FROM `tilawah_exam_results`;

-- Exam result backfill: TAHFIDZ
INSERT INTO `learning_assessment_attempts`
(`user_id`,`feature_type`,`assessment_kind`,`total_questions`,`correct_answers`,`score`,`final_score`,`pronunciation_avg_score`,`pronunciation_question_count`,`xp_earned`,`started_at`,`finished_at`,`attempted_at`,`created_at`)
SELECT
  `user_id`, 'tahfidz', 'exam', `total_questions`, `correct_answers`, `score`, `final_score`, `pronunciation_avg_score`, `pronunciation_question_count`, COALESCE(`xp_earned`,0), `started_at`, `finished_at`, COALESCE(`finished_at`,`created_at`), `created_at`
FROM `tahfidz_exam_results`;

-- ------------------------------------------------------------
-- [UP-4] (Optional) Drop legacy tables AFTER app code fully migrated
-- ------------------------------------------------------------
-- DROP TABLE IF EXISTS `tajwid_evaluations`;
-- DROP TABLE IF EXISTS `tilawah_evaluations`;
-- DROP TABLE IF EXISTS `tahfidz_evaluations`;
-- DROP TABLE IF EXISTS `tadarus_evaluations`;
-- DROP TABLE IF EXISTS `hijaiyah_evaluations`;
--
-- DROP TABLE IF EXISTS `quiz_attempts`;
-- DROP TABLE IF EXISTS `suku_kata_progress`;
-- DROP TABLE IF EXISTS `iqra_exam_results`;
-- DROP TABLE IF EXISTS `tajwid_exam_results`;
-- DROP TABLE IF EXISTS `tilawah_exam_results`;
-- DROP TABLE IF EXISTS `tahfidz_exam_results`;


-- ============================================================
-- =========================== DOWN ===========================
-- ============================================================
-- DOWN should rebuild ALL replaced legacy tables and restore data,
-- then drop the unified tables.

-- ------------------------------------------------------------
-- [DOWN-1] Recreate legacy evaluation tables
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `tajwid_evaluations` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `lesson_id` INT NOT NULL,
  `transcript` TEXT DEFAULT NULL,
  `score_final` INT DEFAULT NULL,
  `score_audio` INT DEFAULT NULL,
  `score_ayat` INT DEFAULT NULL,
  `feedback` TEXT DEFAULT NULL,
  `issues` JSON DEFAULT NULL,
  `evaluated_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_tajwid` (`user_id`,`lesson_id`),
  KEY `idx_user_score` (`user_id`,`score_final`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `tilawah_evaluations` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `lesson_id` INT NOT NULL,
  `transcript` TEXT DEFAULT NULL,
  `score_final` INT DEFAULT NULL,
  `score_audio` INT DEFAULT NULL,
  `score_ayat` INT DEFAULT NULL,
  `feedback` TEXT DEFAULT NULL,
  `issues` JSON DEFAULT NULL,
  `evaluated_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_tilawah` (`user_id`,`lesson_id`),
  KEY `idx_user_score_tilawah` (`user_id`,`score_final`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `tahfidz_evaluations` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `lesson_id` INT NOT NULL,
  `transcript` TEXT DEFAULT NULL,
  `score_final` INT DEFAULT NULL,
  `score_audio` INT DEFAULT NULL,
  `score_ayat` INT DEFAULT NULL,
  `feedback` TEXT DEFAULT NULL,
  `issues` JSON DEFAULT NULL,
  `evaluated_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_tahfidz` (`user_id`,`lesson_id`),
  KEY `idx_user_score_tahfidz` (`user_id`,`score_final`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `tadarus_evaluations` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `surah` INT NOT NULL,
  `ayah` INT NOT NULL,
  `score_final` INT NOT NULL,
  `score_ayat` INT NOT NULL,
  `score_audio` INT NOT NULL,
  `asr_user` TEXT DEFAULT NULL,
  `asr_ref` TEXT DEFAULT NULL,
  `issues` JSON DEFAULT NULL,
  `suggestions` JSON DEFAULT NULL,
  `evaluated_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_user_surah_ayah` (`user_id`,`surah`,`ayah`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `hijaiyah_evaluations` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `lesson_id` BIGINT NOT NULL,
  `hijaiyah` VARCHAR(16) DEFAULT NULL,
  `transcript` TEXT DEFAULT NULL,
  `score_final` INT DEFAULT NULL,
  `score_audio` INT DEFAULT NULL,
  `score_ayat` INT DEFAULT NULL,
  `feedback` TEXT DEFAULT NULL,
  `issues` JSON DEFAULT NULL,
  `evaluated_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_hij_eval_user_lesson` (`user_id`,`lesson_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

TRUNCATE TABLE `tajwid_evaluations`;
INSERT INTO `tajwid_evaluations`
(`user_id`,`lesson_id`,`transcript`,`score_final`,`score_audio`,`score_ayat`,`feedback`,`issues`,`evaluated_at`,`updated_at`)
SELECT
  CAST(`user_id` AS SIGNED), CAST(`lesson_id` AS SIGNED), `transcript`, `score_final`, `score_audio`, `score_ayat`, `feedback`, `issues`, `evaluated_at`, `updated_at`
FROM `learning_evaluations`
WHERE `feature_type`='tajwid';

TRUNCATE TABLE `tilawah_evaluations`;
INSERT INTO `tilawah_evaluations`
(`user_id`,`lesson_id`,`transcript`,`score_final`,`score_audio`,`score_ayat`,`feedback`,`issues`,`evaluated_at`,`updated_at`)
SELECT
  CAST(`user_id` AS SIGNED), CAST(`lesson_id` AS SIGNED), `transcript`, `score_final`, `score_audio`, `score_ayat`, `feedback`, `issues`, `evaluated_at`, `updated_at`
FROM `learning_evaluations`
WHERE `feature_type`='tilawah';

TRUNCATE TABLE `tahfidz_evaluations`;
INSERT INTO `tahfidz_evaluations`
(`user_id`,`lesson_id`,`transcript`,`score_final`,`score_audio`,`score_ayat`,`feedback`,`issues`,`evaluated_at`,`updated_at`)
SELECT
  CAST(`user_id` AS SIGNED), CAST(`lesson_id` AS SIGNED), `transcript`, `score_final`, `score_audio`, `score_ayat`, `feedback`, `issues`, `evaluated_at`, `updated_at`
FROM `learning_evaluations`
WHERE `feature_type`='tahfidz';

TRUNCATE TABLE `tadarus_evaluations`;
INSERT INTO `tadarus_evaluations`
(`user_id`,`surah`,`ayah`,`score_final`,`score_ayat`,`score_audio`,`asr_user`,`asr_ref`,`issues`,`suggestions`,`evaluated_at`,`updated_at`)
SELECT
  `user_id`, `surah`, `ayah`, COALESCE(`score_final`,0), COALESCE(`score_ayat`,0), COALESCE(`score_audio`,0), `asr_user`, `asr_ref`, `issues`, `suggestions`, `evaluated_at`, `updated_at`
FROM `learning_evaluations`
WHERE `feature_type`='tadarus';

TRUNCATE TABLE `hijaiyah_evaluations`;
INSERT INTO `hijaiyah_evaluations`
(`user_id`,`lesson_id`,`hijaiyah`,`transcript`,`score_final`,`score_audio`,`score_ayat`,`feedback`,`issues`,`evaluated_at`,`updated_at`)
SELECT
  `user_id`, `lesson_id`, `asr_ref`, `transcript`, `score_final`, `score_audio`, `score_ayat`, `feedback`, `issues`, `evaluated_at`, `updated_at`
FROM `learning_evaluations`
WHERE `feature_type`='iqra' AND `lesson_id` IS NOT NULL;

-- ------------------------------------------------------------
-- [DOWN-2] Recreate legacy attempts/results tables and restore
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `quiz_attempts` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT DEFAULT NULL,
  `quiz_id` INT DEFAULT NULL,
  `correct` INT DEFAULT NULL,
  `total` INT DEFAULT NULL,
  `score` INT DEFAULT NULL,
  `xp` INT DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `suku_kata_progress` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `level_id` BIGINT NOT NULL,
  `completed_questions` INT DEFAULT 0,
  `average_score` DECIMAL(7,2) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_user_level` (`user_id`,`level_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `iqra_exam_results` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `total_questions` INT NOT NULL,
  `correct_answers` INT NOT NULL,
  `pronunciation_avg_score` DECIMAL(5,2) DEFAULT NULL,
  `pronunciation_question_count` INT DEFAULT NULL,
  `score` INT DEFAULT NULL,
  `final_score` DECIMAL(5,2) DEFAULT NULL,
  `xp_earned` INT DEFAULT 0,
  `started_at` DATETIME DEFAULT NULL,
  `finished_at` DATETIME DEFAULT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `tajwid_exam_results` LIKE `iqra_exam_results`;
CREATE TABLE IF NOT EXISTS `tilawah_exam_results` LIKE `iqra_exam_results`;
CREATE TABLE IF NOT EXISTS `tahfidz_exam_results` LIKE `iqra_exam_results`;

TRUNCATE TABLE `quiz_attempts`;
INSERT INTO `quiz_attempts`
(`user_id`,`quiz_id`,`correct`,`total`,`score`,`xp`,`created_at`)
SELECT
  CAST(`user_id` AS SIGNED), CAST(`quiz_id` AS SIGNED), `correct_answers`, `total_questions`, CAST(`score` AS SIGNED), `xp_earned`, `attempted_at`
FROM `learning_assessment_attempts`
WHERE `assessment_kind`='quiz';

TRUNCATE TABLE `suku_kata_progress`;
INSERT INTO `suku_kata_progress`
(`user_id`,`level_id`,`completed_questions`,`average_score`)
SELECT
  `user_id`,
  CAST(SUBSTRING_INDEX(`quiz_code`, '_', -1) AS UNSIGNED) AS level_id,
  MAX(`total_questions`) AS completed_questions,
  MAX(`score`) AS average_score
FROM `learning_assessment_attempts`
WHERE
  `assessment_kind`='quiz'
  AND `feature_type`='iqra'
  AND `quiz_code` LIKE 'suku_kata_level_%'
GROUP BY `user_id`, CAST(SUBSTRING_INDEX(`quiz_code`, '_', -1) AS UNSIGNED);

TRUNCATE TABLE `iqra_exam_results`;
INSERT INTO `iqra_exam_results`
(`user_id`,`total_questions`,`correct_answers`,`pronunciation_avg_score`,`pronunciation_question_count`,`score`,`final_score`,`xp_earned`,`started_at`,`finished_at`,`created_at`)
SELECT
  `user_id`,`total_questions`,`correct_answers`,`pronunciation_avg_score`,`pronunciation_question_count`,CAST(`score` AS SIGNED),`final_score`,`xp_earned`,`started_at`,`finished_at`,`created_at`
FROM `learning_assessment_attempts`
WHERE `assessment_kind`='exam' AND `feature_type`='iqra';

TRUNCATE TABLE `tajwid_exam_results`;
INSERT INTO `tajwid_exam_results`
(`user_id`,`total_questions`,`correct_answers`,`pronunciation_avg_score`,`pronunciation_question_count`,`score`,`final_score`,`xp_earned`,`started_at`,`finished_at`,`created_at`)
SELECT
  `user_id`,`total_questions`,`correct_answers`,`pronunciation_avg_score`,`pronunciation_question_count`,CAST(`score` AS SIGNED),`final_score`,`xp_earned`,`started_at`,`finished_at`,`created_at`
FROM `learning_assessment_attempts`
WHERE `assessment_kind`='exam' AND `feature_type`='tajwid';

TRUNCATE TABLE `tilawah_exam_results`;
INSERT INTO `tilawah_exam_results`
(`user_id`,`total_questions`,`correct_answers`,`pronunciation_avg_score`,`pronunciation_question_count`,`score`,`final_score`,`xp_earned`,`started_at`,`finished_at`,`created_at`)
SELECT
  `user_id`,`total_questions`,`correct_answers`,`pronunciation_avg_score`,`pronunciation_question_count`,CAST(`score` AS SIGNED),`final_score`,`xp_earned`,`started_at`,`finished_at`,`created_at`
FROM `learning_assessment_attempts`
WHERE `assessment_kind`='exam' AND `feature_type`='tilawah';

TRUNCATE TABLE `tahfidz_exam_results`;
INSERT INTO `tahfidz_exam_results`
(`user_id`,`total_questions`,`correct_answers`,`pronunciation_avg_score`,`pronunciation_question_count`,`score`,`final_score`,`xp_earned`,`started_at`,`finished_at`,`created_at`)
SELECT
  `user_id`,`total_questions`,`correct_answers`,`pronunciation_avg_score`,`pronunciation_question_count`,CAST(`score` AS SIGNED),`final_score`,`xp_earned`,`started_at`,`finished_at`,`created_at`
FROM `learning_assessment_attempts`
WHERE `assessment_kind`='exam' AND `feature_type`='tahfidz';

-- ------------------------------------------------------------
-- [DOWN-3] Drop unified tables
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `learning_assessment_attempts`;
DROP TABLE IF EXISTS `learning_evaluations`;
